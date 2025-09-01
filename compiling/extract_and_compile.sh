#!/bin/bash

# Check if an argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <number>"
  exit 1
fi

NUMBER_ARG=$1

# Extract the NthPrime.tgz archive
tar -xzf NthPrime.tgz > /dev/null

# Check if the extraction was successful and the directory exists
if [ ! -d "NthPrime" ]; then
  echo "Error: NthPrime directory not found after extraction."
  exit 1
fi

# Change into the NthPrime directory
cd NthPrime || { echo "Error: Failed to change directory to NthPrime."; exit 1; }

# Compile the C program
gcc -o NthPrime *.c > /dev/null

# Check if the compilation was successful
if [ ! -f "NthPrime" ]; then
  echo "Error: Compilation failed. NthPrime executable not created."
  exit 1
fi

# Run the executable with the provided argument
./NthPrime "$NUMBER_ARG"