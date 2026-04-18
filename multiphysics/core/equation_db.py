#!/usr/bin/env python3
"""
CAT/EPT Equation Database Management System
============================================

This script extracts, manages, and tracks all equations from the CAT/EPT paper
for formal verification and proof consistency checking.

Features:
- Extract equations from LaTeX source
- Store in SQLite database with metadata
- Support for formal proof system integration (Coq, Lean, Isabelle, Agda)
- Track dependencies between equations
- Export to various formats (Mathematica, Maple, SymPy)
- Verify self-consistency of the theoretical framework

Author: Jorge A. Garcia-Gonzalez
Date: 2026-02-07
License: MIT
"""

import re
import sqlite3
import json
import os
from pathlib import Path
from typing import List, Dict, Optional, Tuple
from dataclasses import dataclass, asdict
from datetime import datetime
import hashlib


@dataclass
class Equation:
    """Data class representing a single equation."""
    equation_id: Optional[int]
    equation_number: Optional[str]  # e.g., "1", "2.3", "A.1"
    label: Optional[str]  # LaTeX label (from \label{eq:...})
    section: str  # Section title or number
    subsection: Optional[str]
    latex_code: str  # The actual LaTeX equation
    description: str  # What the equation represents
    mathematica_code: Optional[str]
    sympy_code: Optional[str]
    maple_code: Optional[str]
    coq_proof_uri: Optional[str]  # Path to Coq proof file
    lean_proof_uri: Optional[str]  # Path to Lean proof file
    isabelle_proof_uri: Optional[str]  # Path to Isabelle proof file
    agda_proof_uri: Optional[str]  # Path to Agda proof file
    dependencies: Optional[str]  # JSON list of equation IDs this depends on
    tags: Optional[str]  # JSON list of tags (e.g., ["complex_action", "main_result"])
    verified: bool = False  # Has formal proof been verified
    verification_date: Optional[str] = None
    notes: Optional[str] = None
    context_before: Optional[str] = None  # Text immediately before equation
    context_after: Optional[str] = None  # Text immediately after equation
    theorem_related: Optional[str] = None  # Related theorem label
    page_number: Optional[int] = None
    line_number: Optional[int] = None
    hash_md5: Optional[str] = None  # Hash of latex_code for change detection
    created_at: Optional[str] = None
    updated_at: Optional[str] = None


class EquationDatabase:
    """Manages the SQLite database of equations."""
    
    def __init__(self, db_path: str = "cat_ept_equations.db"):
        """Initialize database connection and create tables if needed."""
        self.db_path = db_path
        self.conn = sqlite3.connect(db_path)
        self.conn.row_factory = sqlite3.Row
        self.create_tables()
    
    def create_tables(self):
        """Create database schema."""
        cursor = self.conn.cursor()
        
        # Main equations table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS equations (
                equation_id INTEGER PRIMARY KEY AUTOINCREMENT,
                equation_number TEXT,
                label TEXT,
                section TEXT NOT NULL,
                subsection TEXT,
                latex_code TEXT NOT NULL,
                description TEXT,
                mathematica_code TEXT,
                sympy_code TEXT,
                maple_code TEXT,
                coq_proof_uri TEXT,
                lean_proof_uri TEXT,
                isabelle_proof_uri TEXT,
                agda_proof_uri TEXT,
                dependencies TEXT,  -- JSON array
                tags TEXT,  -- JSON array
                verified BOOLEAN DEFAULT 0,
                verification_date TEXT,
                notes TEXT,
                context_before TEXT,
                context_after TEXT,
                theorem_related TEXT,
                page_number INTEGER,
                line_number INTEGER,
                hash_md5 TEXT,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP,
                updated_at TEXT DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        # Dependency graph table (for easier querying)
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS equation_dependencies (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                equation_id INTEGER,
                depends_on_id INTEGER,
                dependency_type TEXT,  -- 'direct', 'indirect', 'proof'
                FOREIGN KEY (equation_id) REFERENCES equations(equation_id),
                FOREIGN KEY (depends_on_id) REFERENCES equations(equation_id)
            )
        ''')
        
        # Verification history table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS verification_history (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                equation_id INTEGER,
                proof_system TEXT,  -- 'coq', 'lean', 'isabelle', 'agda'
                verified BOOLEAN,
                verifier TEXT,  -- Who verified it
                verification_date TEXT,
                proof_file TEXT,
                notes TEXT,
                FOREIGN KEY (equation_id) REFERENCES equations(equation_id)
            )
        ''')
        
        # Tags table for categorization
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS tags (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                tag_name TEXT UNIQUE,
                description TEXT,
                color TEXT  -- For visualization
            )
        ''')
        
        # Create indexes for faster queries
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_label ON equations(label)')
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_section ON equations(section)')
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_verified ON equations(verified)')
        cursor.execute('CREATE INDEX IF NOT EXISTS idx_hash ON equations(hash_md5)')
        
        self.conn.commit()
    
    def add_equation(self, eq: Equation, skip_duplicates: bool = True) -> Optional[int]:
        """Add a new equation to the database."""
        cursor = self.conn.cursor()
        
        # Compute hash if not provided
        if not eq.hash_md5:
            eq.hash_md5 = hashlib.md5(eq.latex_code.encode()).hexdigest()
        
        # Check for duplicate by hash
        if skip_duplicates:
            cursor.execute('SELECT equation_id FROM equations WHERE hash_md5 = ?', (eq.hash_md5,))
            existing = cursor.fetchone()
            if existing:
                return existing[0]  # Return existing ID
        
        # Set timestamps
        now = datetime.now().isoformat()
        eq.created_at = now
        eq.updated_at = now
        
        try:
            cursor.execute('''
                INSERT INTO equations (
                    equation_number, label, section, subsection, latex_code,
                    description, mathematica_code, sympy_code, maple_code,
                    coq_proof_uri, lean_proof_uri, isabelle_proof_uri, agda_proof_uri,
                    dependencies, tags, verified, verification_date, notes,
                    context_before, context_after, theorem_related,
                    page_number, line_number, hash_md5, created_at, updated_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                eq.equation_number, eq.label, eq.section, eq.subsection, eq.latex_code,
                eq.description, eq.mathematica_code, eq.sympy_code, eq.maple_code,
                eq.coq_proof_uri, eq.lean_proof_uri, eq.isabelle_proof_uri, eq.agda_proof_uri,
                eq.dependencies, eq.tags, eq.verified, eq.verification_date, eq.notes,
                eq.context_before, eq.context_after, eq.theorem_related,
                eq.page_number, eq.line_number, eq.hash_md5, eq.created_at, eq.updated_at
            ))
            
            self.conn.commit()
            return cursor.lastrowid
        except sqlite3.IntegrityError as e:
            print(f"Warning: Could not add equation: {e}")
            return None
    
    def update_equation(self, equation_id: int, updates: Dict) -> bool:
        """Update an existing equation."""
        cursor = self.conn.cursor()
        
        # Add update timestamp
        updates['updated_at'] = datetime.now().isoformat()
        
        # Build UPDATE query dynamically
        set_clause = ', '.join([f"{key} = ?" for key in updates.keys()])
        values = list(updates.values()) + [equation_id]
        
        cursor.execute(f'''
            UPDATE equations SET {set_clause}
            WHERE equation_id = ?
        ''', values)
        
        self.conn.commit()
        return cursor.rowcount > 0
    
    def get_equation(self, equation_id: int = None, label: str = None) -> Optional[Dict]:
        """Retrieve an equation by ID or label."""
        cursor = self.conn.cursor()
        
        if equation_id:
            cursor.execute('SELECT * FROM equations WHERE equation_id = ?', (equation_id,))
        elif label:
            cursor.execute('SELECT * FROM equations WHERE label = ?', (label,))
        else:
            return None
        
        row = cursor.fetchone()
        return dict(row) if row else None
    
    def get_all_equations(self, section: str = None, verified_only: bool = False) -> List[Dict]:
        """Retrieve all equations, optionally filtered."""
        cursor = self.conn.cursor()
        
        query = 'SELECT * FROM equations WHERE 1=1'
        params = []
        
        if section:
            query += ' AND section = ?'
            params.append(section)
        
        if verified_only:
            query += ' AND verified = 1'
        
        query += ' ORDER BY line_number, equation_id'
        
        cursor.execute(query, params)
        return [dict(row) for row in cursor.fetchall()]
    
    def delete_equation(self, equation_id: int) -> bool:
        """Delete an equation (use with caution!)."""
        cursor = self.conn.cursor()
        cursor.execute('DELETE FROM equations WHERE equation_id = ?', (equation_id,))
        self.conn.commit()
        return cursor.rowcount > 0
    
    def mark_verified(self, equation_id: int, proof_system: str, 
                     proof_file: str, verifier: str, notes: str = None) -> bool:
        """Mark an equation as formally verified."""
        cursor = self.conn.cursor()
        
        # Update main equation
        now = datetime.now().isoformat()
        cursor.execute('''
            UPDATE equations 
            SET verified = 1, verification_date = ?, updated_at = ?
            WHERE equation_id = ?
        ''', (now, now, equation_id))
        
        # Add to verification history
        cursor.execute('''
            INSERT INTO verification_history (
                equation_id, proof_system, verified, verifier,
                verification_date, proof_file, notes
            ) VALUES (?, ?, 1, ?, ?, ?, ?)
        ''', (equation_id, proof_system, verifier, now, proof_file, notes))
        
        self.conn.commit()
        return True
    
    def add_dependency(self, equation_id: int, depends_on_id: int, 
                      dependency_type: str = 'direct'):
        """Add a dependency relationship between equations."""
        cursor = self.conn.cursor()
        cursor.execute('''
            INSERT INTO equation_dependencies (equation_id, depends_on_id, dependency_type)
            VALUES (?, ?, ?)
        ''', (equation_id, depends_on_id, dependency_type))
        self.conn.commit()
    
    def get_dependencies(self, equation_id: int) -> List[Dict]:
        """Get all equations that this equation depends on."""
        cursor = self.conn.cursor()
        cursor.execute('''
            SELECT e.*, ed.dependency_type
            FROM equations e
            JOIN equation_dependencies ed ON e.equation_id = ed.depends_on_id
            WHERE ed.equation_id = ?
        ''', (equation_id,))
        return [dict(row) for row in cursor.fetchall()]
    
    def get_dependents(self, equation_id: int) -> List[Dict]:
        """Get all equations that depend on this equation."""
        cursor = self.conn.cursor()
        cursor.execute('''
            SELECT e.*, ed.dependency_type
            FROM equations e
            JOIN equation_dependencies ed ON e.equation_id = ed.equation_id
            WHERE ed.depends_on_id = ?
        ''', (equation_id,))
        return [dict(row) for row in cursor.fetchall()]
    
    def export_to_json(self, output_file: str):
        """Export entire database to JSON."""
        equations = self.get_all_equations()
        with open(output_file, 'w') as f:
            json.dump(equations, f, indent=2)
    
    def export_to_mathematica(self, output_file: str):
        """Export equations with Mathematica code to .m file."""
        equations = self.get_all_equations()
        
        with open(output_file, 'w') as f:
            f.write("(* CAT/EPT Equations - Mathematica Export *)\n")
            f.write(f"(* Generated: {datetime.now().isoformat()} *)\n\n")
            
            for eq in equations:
                if eq['mathematica_code']:
                    f.write(f"(* Equation {eq['equation_number']} *)\n")
                    if eq['label']:
                        f.write(f"(* Label: {eq['label']} *)\n")
                    if eq['description']:
                        f.write(f"(* {eq['description']} *)\n")
                    f.write(f"{eq['mathematica_code']}\n\n")
    
    def get_statistics(self) -> Dict:
        """Get database statistics."""
        cursor = self.conn.cursor()
        
        stats = {}
        
        # Total equations
        cursor.execute('SELECT COUNT(*) FROM equations')
        stats['total_equations'] = cursor.fetchone()[0]
        
        # Verified equations
        cursor.execute('SELECT COUNT(*) FROM equations WHERE verified = 1')
        stats['verified_equations'] = cursor.fetchone()[0]
        
        # Equations by section
        cursor.execute('SELECT section, COUNT(*) FROM equations GROUP BY section')
        stats['by_section'] = {row[0]: row[1] for row in cursor.fetchall()}
        
        # Verification coverage
        if stats['total_equations'] > 0:
            stats['verification_percentage'] = (
                stats['verified_equations'] / stats['total_equations'] * 100
            )
        else:
            stats['verification_percentage'] = 0.0
        
        return stats
    
    def close(self):
        """Close database connection."""
        self.conn.close()


class EquationExtractor:
    """Extract equations from LaTeX source file."""
    
    def __init__(self, tex_file: str):
        """Initialize with path to LaTeX file."""
        self.tex_file = tex_file
        with open(tex_file, 'r', encoding='utf-8') as f:
            self.content = f.read()
        self.lines = self.content.split('\n')
    
    def extract_equations(self) -> List[Equation]:
        """Extract all equations from LaTeX file."""
        equations = []
        
        # Pattern for equation environment
        eq_pattern = re.compile(
            r'\\begin\{equation\}(.*?)\\end\{equation\}',
            re.DOTALL
        )
        
        # Pattern for align environment
        align_pattern = re.compile(
            r'\\begin\{align\}(.*?)\\end\{align\}',
            re.DOTALL
        )
        
        # Find all equation environments
        for match in eq_pattern.finditer(self.content):
            eq_content = match.group(1).strip()
            start_pos = match.start()
            
            # Extract label if present
            label_match = re.search(r'\\label\{([^}]+)\}', eq_content)
            label = label_match.group(1) if label_match else None
            
            # Remove label from equation content
            latex_code = re.sub(r'\\label\{[^}]+\}', '', eq_content).strip()
            
            # Get line number
            line_num = self.content[:start_pos].count('\n') + 1
            
            # Get context (surrounding text)
            context_before, context_after = self._get_context(start_pos, match.end())
            
            # Get current section
            section = self._get_section(start_pos)
            
            # Create equation object
            eq = Equation(
                equation_id=None,
                equation_number=None,  # Will be assigned later
                label=label,
                section=section,
                subsection=None,
                latex_code=latex_code,
                description=self._extract_description(context_before, context_after),
                mathematica_code=None,
                sympy_code=None,
                maple_code=None,
                coq_proof_uri=None,
                lean_proof_uri=None,
                isabelle_proof_uri=None,
                agda_proof_uri=None,
                dependencies=None,
                tags=self._auto_tag(latex_code, section),
                verified=False,
                verification_date=None,
                notes=None,
                context_before=context_before,
                context_after=context_after,
                theorem_related=None,
                page_number=None,
                line_number=line_num,
                hash_md5=None
            )
            
            equations.append(eq)
        
        # Process align environments similarly
        for match in align_pattern.finditer(self.content):
            eq_content = match.group(1).strip()
            start_pos = match.start()
            
            # For align, might have multiple equations - split by \\
            # For now, treat as single block
            
            label_match = re.search(r'\\label\{([^}]+)\}', eq_content)
            label = label_match.group(1) if label_match else None
            
            latex_code = re.sub(r'\\label\{[^}]+\}', '', eq_content).strip()
            line_num = self.content[:start_pos].count('\n') + 1
            
            context_before, context_after = self._get_context(start_pos, match.end())
            section = self._get_section(start_pos)
            
            eq = Equation(
                equation_id=None,
                equation_number=None,
                label=label,
                section=section,
                subsection=None,
                latex_code=latex_code,
                description=self._extract_description(context_before, context_after),
                mathematica_code=None,
                sympy_code=None,
                maple_code=None,
                coq_proof_uri=None,
                lean_proof_uri=None,
                isabelle_proof_uri=None,
                agda_proof_uri=None,
                dependencies=None,
                tags=self._auto_tag(latex_code, section),
                verified=False,
                verification_date=None,
                notes=None,
                context_before=context_before,
                context_after=context_after,
                theorem_related=None,
                page_number=None,
                line_number=line_num,
                hash_md5=None
            )
            
            equations.append(eq)
        
        # Sort by line number
        equations.sort(key=lambda x: x.line_number)
        
        # Assign equation numbers
        for i, eq in enumerate(equations, 1):
            eq.equation_number = str(i)
        
        return equations
    
    def _get_context(self, start_pos: int, end_pos: int, 
                     context_chars: int = 200) -> Tuple[str, str]:
        """Get text before and after equation."""
        before = self.content[max(0, start_pos - context_chars):start_pos].strip()
        after = self.content[end_pos:min(len(self.content), end_pos + context_chars)].strip()
        return before, after
    
    def _get_section(self, pos: int) -> str:
        """Find the section this equation belongs to."""
        # Search backwards for \section command
        text_before = self.content[:pos]
        section_matches = list(re.finditer(r'\\section\{([^}]+)\}', text_before))
        
        if section_matches:
            return section_matches[-1].group(1)
        return "Introduction"
    
    def _extract_description(self, context_before: str, context_after: str) -> str:
        """Try to extract a description from surrounding text."""
        # Look for sentences that might describe the equation
        # This is a heuristic and might need refinement
        
        # Check if there's a clear introductory phrase
        intro_patterns = [
            r'where\s+(.{0,100})',
            r'given by\s+(.{0,100})',
            r'defined as\s+(.{0,100})',
            r'we have\s+(.{0,100})',
        ]
        
        for pattern in intro_patterns:
            match = re.search(pattern, context_before + ' ' + context_after, re.IGNORECASE)
            if match:
                return match.group(1).strip()[:200]
        
        # Otherwise, take last sentence before equation
        sentences = re.split(r'[.!?]\s+', context_before)
        if sentences and len(sentences[-1]) > 10:
            return sentences[-1].strip()[:200]
        
        return "Description to be added"
    
    def _auto_tag(self, latex_code: str, section: str) -> str:
        """Automatically generate tags based on equation content."""
        tags = []
        
        # Check for specific mathematical objects
        if 'H_R' in latex_code or 'H_I' in latex_code:
            tags.append('complex_hamiltonian')
        if 'S_R' in latex_code or 'S_I' in latex_code:
            tags.append('complex_action')
        if r'\tau_{\mathrm{ent}}' in latex_code or r'\tau_{ent}' in latex_code:
            tags.append('entropic_time')
        if r'\lambda' in latex_code:
            tags.append('entropic_rate')
        if 'rho' in latex_code or r'\rho' in latex_code:
            tags.append('density_matrix')
        if 'Psi' in latex_code or r'\Psi' in latex_code:
            tags.append('wavefunction')
        if 'ds^2' in latex_code or 'g_{' in latex_code:
            tags.append('metric')
        if 'int' in latex_code or r'\int' in latex_code:
            tags.append('integral')
        if 'sum' in latex_code or r'\sum' in latex_code:
            tags.append('summation')
        
        # Tag by section
        section_lower = section.lower()
        if 'complex action' in section_lower:
            tags.append('section_complex_action')
        elif 'page' in section_lower or 'wootters' in section_lower:
            tags.append('section_page_wootters')
        elif 'quantum' in section_lower and 'gravity' in section_lower:
            tags.append('section_quantum_gravity')
        
        return json.dumps(tags)


def main():
    """Main function demonstrating usage."""
    import argparse
    
    parser = argparse.ArgumentParser(
        description='CAT/EPT Equation Database Management System'
    )
    parser.add_argument('command', choices=[
        'extract', 'add', 'update', 'delete', 'get', 'list',
        'verify', 'export', 'stats', 'init'
    ], help='Command to execute')
    
    parser.add_argument('--tex-file', default='main.tex',
                       help='Path to LaTeX source file')
    parser.add_argument('--db', default='cat_ept_equations.db',
                       help='Path to database file')
    parser.add_argument('--equation-id', type=int,
                       help='Equation ID for operations')
    parser.add_argument('--label', help='Equation label')
    parser.add_argument('--output', help='Output file path')
    parser.add_argument('--section', help='Filter by section')
    parser.add_argument('--verified-only', action='store_true',
                       help='Show only verified equations')
    
    args = parser.parse_args()
    
    db = EquationDatabase(args.db)
    
    if args.command == 'extract':
        # Extract equations from LaTeX and populate database
        print(f"Extracting equations from {args.tex_file}...")
        extractor = EquationExtractor(args.tex_file)
        equations = extractor.extract_equations()
        
        print(f"Found {len(equations)} equations")
        
        for eq in equations:
            eq_id = db.add_equation(eq)
            print(f"Added equation {eq.equation_number} (ID: {eq_id})")
            if eq.label:
                print(f"  Label: {eq.label}")
            print(f"  Section: {eq.section}")
            print(f"  LaTeX: {eq.latex_code[:80]}...")
            print()
        
        print(f"\nDatabase populated with {len(equations)} equations")
    
    elif args.command == 'list':
        # List all equations
        equations = db.get_all_equations(
            section=args.section,
            verified_only=args.verified_only
        )
        
        print(f"\nFound {len(equations)} equations:\n")
        for eq in equations:
            print(f"ID: {eq['equation_id']}")
            print(f"Number: {eq['equation_number']}")
            if eq['label']:
                print(f"Label: {eq['label']}")
            print(f"Section: {eq['section']}")
            print(f"LaTeX: {eq['latex_code'][:100]}...")
            print(f"Verified: {'✓' if eq['verified'] else '✗'}")
            print("-" * 70)
    
    elif args.command == 'get':
        # Get specific equation
        eq = db.get_equation(
            equation_id=args.equation_id,
            label=args.label
        )
        
        if eq:
            print("\nEquation Details:")
            for key, value in eq.items():
                if value is not None:
                    print(f"{key}: {value}")
        else:
            print("Equation not found")
    
    elif args.command == 'stats':
        # Show statistics
        stats = db.get_statistics()
        
        print("\n=== CAT/EPT Equation Database Statistics ===\n")
        print(f"Total Equations: {stats['total_equations']}")
        print(f"Verified: {stats['verified_equations']}")
        print(f"Verification Coverage: {stats['verification_percentage']:.1f}%")
        print("\nEquations by Section:")
        for section, count in stats['by_section'].items():
            print(f"  {section}: {count}")
    
    elif args.command == 'export':
        # Export database
        if not args.output:
            print("Error: --output required for export")
            return
        
        if args.output.endswith('.json'):
            db.export_to_json(args.output)
            print(f"Exported to {args.output}")
        elif args.output.endswith('.m'):
            db.export_to_mathematica(args.output)
            print(f"Exported Mathematica code to {args.output}")
        else:
            print("Error: Unsupported format. Use .json or .m")
    
    elif args.command == 'init':
        # Initialize database (already done in constructor)
        print(f"Database initialized at {args.db}")
        print("Tables created:")
        print("  - equations")
        print("  - equation_dependencies")
        print("  - verification_history")
        print("  - tags")
    
    db.close()


if __name__ == '__main__':
    main()
