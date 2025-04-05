#!/bin/bash
# This script automatically parses the .gitignore file and deletes all matching files and folders

echo "========== GitIgnore Cleanup Script =========="
echo "This script will delete all files and folders matched by your .gitignore"
echo "CAUTION: This will permanently delete files from your system"
echo "================================================"

# Ask for confirmation before proceeding
read -p "Are you sure you want to continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "Operation cancelled."
    exit 1
fi

# Create a temporary directory for processing
TEMP_DIR=$(mktemp -d)
echo "Working in temporary directory: $TEMP_DIR"

# Process .gitignore and create find commands
echo "Parsing .gitignore file..."
cat .gitignore | grep -v "^#" | grep -v "^$" | while read pattern; do
    # Skip negation patterns (those starting with !)
    if [[ $pattern == !* ]]; then
        continue
    fi
    
    # Remove trailing slashes for directory patterns
    pattern="${pattern%/}"
    
    # Skip patterns with special git syntax
    if [[ $pattern == */** ]] || [[ $pattern == **/* ]]; then
        pattern=$(echo "$pattern" | sed 's/\*\*/\*/g')
    fi
    
    # Convert glob pattern to find pattern
    # Replace *.ext with *.ext
    # Replace directory/ with directory
    find_pattern=$(echo "$pattern" | sed 's/\*/\\*/g')
    
    # Handle different pattern types
    if [[ $pattern == /* ]]; then
        # Absolute path pattern (rare in .gitignore)
        echo "Skipping absolute path pattern: $pattern"
    elif [[ $pattern == */* ]]; then
        # Path pattern with directories
        echo "Searching for path pattern: $pattern"
        find . -path "*$pattern" -not -path "*/\.*" 2>/dev/null >> "$TEMP_DIR/to_remove.txt"
    else
        # Simple filename or extension pattern
        echo "Searching for file pattern: $pattern"
        find . -name "$pattern" -not -path "*/\.*" 2>/dev/null >> "$TEMP_DIR/to_remove.txt"
    fi
done

# Special handling for file extensions
grep "^\*\." .gitignore | sed 's/^\*\.//' | while read ext; do
    echo "Searching for extension: $ext"
    find . -name "*.$ext" -not -path "*/\.*" 2>/dev/null >> "$TEMP_DIR/to_remove.txt"
done

# Handle specific directory patterns
grep "/$" .gitignore | sed 's/\/$//' | while read dir; do
    echo "Searching for directory: $dir"
    find . -type d -name "$dir" -not -path "*/\.*" 2>/dev/null >> "$TEMP_DIR/to_remove.txt"
done

# Sort and remove duplicates
if [ -f "$TEMP_DIR/to_remove.txt" ]; then
    sort "$TEMP_DIR/to_remove.txt" | uniq > "$TEMP_DIR/unique_to_remove.txt"
    
    # Get count of files to remove
    FILE_COUNT=$(wc -l < "$TEMP_DIR/unique_to_remove.txt")
    
    if [ "$FILE_COUNT" -gt 0 ]; then
        echo "================================================"
        echo "Found $FILE_COUNT files/directories to remove."
        echo "================================================"
        
        # Show first 10 files for review
        if [ "$FILE_COUNT" -gt 10 ]; then
            head -10 "$TEMP_DIR/unique_to_remove.txt"
            echo "... and $(($FILE_COUNT - 10)) more files/directories"
        else
            cat "$TEMP_DIR/unique_to_remove.txt"
        fi
        
        # Confirm deletion
        echo "================================================"
        read -p "Delete these files? This CANNOT be undone. (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "Deleting files..."
            # First handle untracked files
            while IFS= read -r file; do
                if [ -e "$file" ]; then
                    echo "Removing $file"
                    rm -rf "$file"
                fi
            done < "$TEMP_DIR/unique_to_remove.txt"
            
            echo "Removing files from Git tracking (if they were tracked)..."
            git rm --cached -r $(cat "$TEMP_DIR/unique_to_remove.txt") 2>/dev/null
            
            echo "Cleanup complete."
        else
            echo "Operation cancelled."
        fi
    else
        echo "No files found matching .gitignore patterns."
    fi
else
    echo "No files matched the patterns in .gitignore."
fi

# Cleanup
rm -rf "$TEMP_DIR"
echo "Temporary files removed."
echo "Done."