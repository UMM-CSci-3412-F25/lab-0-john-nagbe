#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# 1. Argument Handling and Variable Setup

# Check if exactly one argument (the archive name) is provided.
if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <archive_name.tgz>"
  exit 1
fi

# Store the path to the original tar archive.
ORIGINAL_ARCHIVE="$1"

# Check if the original archive exists.
if [[ ! -f "$ORIGINAL_ARCHIVE" ]]; then
  echo "Error: Archive '$ORIGINAL_ARCHIVE' not found."
  exit 1
fi

# Store the absolute path of the directory where the script was called from.
ORIGINAL_DIR=$(pwd)

# Use basename to get the filename without the path, e.g., "big_dir.tgz".
ARCHIVE_BASENAME=$(basename "$ORIGINAL_ARCHIVE")

# Construct the name for the new, cleaned archive.
CLEANED_ARCHIVE_NAME="cleaned_$ARCHIVE_BASENAME"

# 2. Create a Temporary "Scratch" Directory and Set Up Cleanup

# Use mktemp to create a secure, temporary directory.
# The "-d" flag ensures a directory is created.
SCRATCH_DIR=$(mktemp -d)

# Set a trap to ensure the temporary directory is removed automatically
# when the script exits, even if an error occurs.
trap 'rm -rf "$SCRATCH_DIR"' EXIT

echo "Working in temporary directory: $SCRATCH_DIR"

# 3. Extract the Archive Contents

# Extract the contents of the archive directly into the scratch directory.
# The -C flag tells tar to change to the specified directory before extracting.
echo "Extracting contents from '$ORIGINAL_ARCHIVE'..."
tar -xzf "$ORIGINAL_ARCHIVE" -C "$SCRATCH_DIR"

# 4. Remove Files Marked for Deletion

echo "Removing files marked with 'DELETE ME!'..."

# Change into the scratch directory to perform the cleanup.
cd "$SCRATCH_DIR"

# Find all files containing "DELETE ME!" and pipe their names to xargs to remove them.
# The '-l' flag in grep prints only the filename.

grep -lr "DELETE ME!" . | xargs rm

# 5. Create the New, Cleaned Archive

# Change back to the original directory.
cd "$ORIGINAL_DIR"

# Create the new archive from the cleaned files in the scratch directory.
# The -C flag is used again, this time to ensure the new archive's file paths
# are relative to the scratch directory, not the user's home directory.
echo "Creating new archive: '$CLEANED_ARCHIVE_NAME'..."
tar -czf "$CLEANED_ARCHIVE_NAME" -C "$SCRATCH_DIR" .

echo "Successfully created '$CLEANED_ARCHIVE_NAME' in '$ORIGINAL_DIR'."
echo "Cleanup complete. The temporary directory '$SCRATCH_DIR' has been removed."