# Makefile for building and verifying pipeline

PYTHON   := python3
SCRIPT   := build_and_verify_pipeline.py
DBFILE   := double_slit.sqlite3
REPORT   := verification_report.csv

.PHONY: all run split tidy load verify summary check clean rebuild help

# Default target
all: run

# Full pipeline
run:
	$(PYTHON) $(SCRIPT) run

# Stage-specific targets
split:
	$(PYTHON) $(SCRIPT) split

tidy:
	$(PYTHON) $(SCRIPT) tidy

load:
	$(PYTHON) $(SCRIPT) load

verify:
	$(PYTHON) $(SCRIPT) verify

summary:
	$(PYTHON) $(SCRIPT) summary

# Precheck environment variables only
check:
	$(PYTHON) $(SCRIPT) check

# Clean up generated files
clean:
	rm -f $(DBFILE) $(REPORT)

# Clean and rerun
rebuild: clean run

# Show help
help:
	echo "Available targets:"
	echo "  make run      - Run full pipeline (split, tidy, load, verify)"
	echo "  make check    - Check environment variables before running pipeline"
	echo "  make split    - Split original Excel workbooks"
	echo "  make tidy     - Run tidy converters"
	echo "  make load     - Load tidy CSVs into SQLite"
	echo "  make verify   - Verify DB vs CSV"
	echo "  make summary  - Summarize DB coverage"
	echo "  make clean    - Remove database and report"
	echo "  make rebuild  - Clean and rerun pipeline"
	echo "  make help     - Show this help message"
