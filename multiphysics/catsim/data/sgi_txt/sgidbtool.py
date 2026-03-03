import os
import hashlib
import sqlite3
import argparse
from datetime import datetime
from pathlib import Path

# Dependency: pip install pypdf
from pypdf import PdfReader

def compute_file_hash(file_path: str, chunk_size: int = 8192) -> str:
    """Compute SHA-256 hash of a file."""
    sha256 = hashlib.sha256()
    with open(file_path, "rb") as f:
        for chunk in iter(lambda: f.read(chunk_size), b""):
            sha256.update(chunk)
    return sha256.hexdigest()

def extract_text_from_pdf(file_path: str) -> dict[int, str]:
    """Extract text from each page of a PDF and return as {page_num: text}."""
    try:
        reader = PdfReader(file_path)
        pages = {}
        for page_num, page in enumerate(reader.pages, start=1):
            text = page.extract_text() or ""  # Handle cases with no extractable text
            pages[page_num] = text
        return pages
    except Exception as e:
        print(f"Error reading PDF {file_path}: {e}")
        return {}

def extract_text_from_file(file_path: str) -> str:
    """Extract text from supported file types (PDF or plain text)."""
    _, ext = os.path.splitext(file_path.lower())
    if ext == ".pdf":
        pages = extract_text_from_pdf(file_path)
        # Concatenate all pages for storage (pages stored separately in DB)
        return "\n\n---PAGE BREAK---\n\n".join(pages.values())
    elif ext in {".txt", ".md", ".py", ".json", ".csv", ".html", ".xml"}:
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                return f.read()
        except UnicodeDecodeError:
            try:
                with open(file_path, "r", encoding="latin-1") as f:
                    return f.read()
            except Exception as e:
                print(f"Error reading text file {file_path}: {e}")
                return ""
    else:
        print(f"Skipping unsupported file type: {file_path}")
        return None

def initialize_database(db_path: str):
    """Create SQLite database and tables if they do not exist."""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS files (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            path TEXT UNIQUE NOT NULL,
            hash TEXT NOT NULL,
            file_size INTEGER,
            modified_timestamp REAL,
            last_updated TEXT
        )
    """)
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS content (
            file_id INTEGER,
            page_number INTEGER DEFAULT 1,  -- 1 for non-PDF files
            text TEXT,
            PRIMARY KEY (file_id, page_number),
            FOREIGN KEY (file_id) REFERENCES files(id) ON DELETE CASCADE
        )
    """)
    conn.commit()
    return conn

def process_directory(directory: str, db_path: str, recursive: bool = True):
    """Scan directory, verify against database, and update if necessary."""
    conn = initialize_database(db_path)
    cursor = conn.cursor()

    path_obj = Path(directory)
    pattern = "**/*" if recursive else "*"
    files = [str(p) for p in path_obj.glob(pattern) if p.is_file()]

    print(f"Found {len(files)} file(s) in {directory} (recursive={recursive}). Processing...")

    updated_count = 0
    skipped_count = 0

    for file_path in files:
        current_hash = compute_file_hash(file_path)
        stat = os.stat(file_path)
        current_size = stat.st_size
        current_mtime = stat.st_mtime

        # Check if file exists in database
        cursor.execute("SELECT id, hash FROM files WHERE path = ?", (file_path,))
        row = cursor.fetchone()

        if row and row[1] == current_hash:
            print(f"Up-to-date: {file_path}")
            skipped_count += 1
            continue

        # File is new or changed → extract and update
        content = extract_text_from_file(file_path)
        if content is None:
            continue  # Unsupported file skipped

        file_id = None
        if row:
            file_id = row[0]
            # Update existing file entry
            cursor.execute("""
                UPDATE files SET hash = ?, file_size = ?, modified_timestamp = ?, last_updated = ?
                WHERE id = ?
            """, (current_hash, current_size, current_mtime, datetime.now().isoformat(), file_id))
            # Clear old content
            cursor.execute("DELETE FROM content WHERE file_id = ?", (file_id,))
        else:
            # Insert new file entry
            cursor.execute("""
                INSERT INTO files (path, hash, file_size, modified_timestamp, last_updated)
                VALUES (?, ?, ?, ?, ?)
            """, (file_path, current_hash, current_size, current_mtime, datetime.now().isoformat()))
            file_id = cursor.lastrowid

        # Insert content (handle PDF pages separately if needed)
        _, ext = os.path.splitext(file_path.lower())
        if ext == ".pdf":
            pages = extract_text_from_pdf(file_path)
            for page_num, page_text in pages.items():
                cursor.execute("""
                    INSERT INTO content (file_id, page_number, text) VALUES (?, ?, ?)
                """, (file_id, page_num, page_text))
        else:
            cursor.execute("""
                INSERT INTO content (file_id, page_number, text) VALUES (?, 1, ?)
            """, (file_id, content))

        conn.commit()
        print(f"Updated database for: {file_path}")
        updated_count += 1

    print(f"\nProcessing complete: {skipped_count} file(s) unchanged, {updated_count} file(s) updated/added.")
    conn.close()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Create and maintain a SQLite database of file contents with change detection via hashing."
    )
    parser.add_argument("directory", help="Directory containing files to process")
    parser.add_argument("--db", default="files_database.db", help="SQLite database file (default: files_database.db)")
    parser.add_argument("--non-recursive", action="store_true", help="Do not scan subdirectories")
    args = parser.parse_args()

    process_directory(
        directory=args.directory,
        db_path=args.db,
        recursive=not args.non_recursive
    )

