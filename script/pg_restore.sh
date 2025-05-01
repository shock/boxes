#!/bin/bash

# Check if exactly two arguments are provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <target_database> <dump_file.dump>"
  exit 1
fi

TARGET_DB="$1"
DUMP_FILE="$2"

# Check if dump file exists
if [ ! -f "$DUMP_FILE" ]; then
  echo "Error: Dump file '$DUMP_FILE' does not exist."
  exit 1
fi

# Restore the dump into the target database
pg_restore -d "$TARGET_DB" --clean --no-owner "$DUMP_FILE"

# Explanation:
# --clean: drops database objects before recreating them
# --no-owner: prevents restoring ownership (useful if restoring as a different use