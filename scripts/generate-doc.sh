#!/bin/bash

SNIPPETS_DIR="./snippets"
SNIPPETS_FILE_EXTENSION=".code-snippets"
README_FILE="./README.md"

generate_snippet_table() {
  local file=$1
  echo "| Prefix | Description |"
  echo "|--------|-------------|"
  local file_content
  file_content=$(sed '/^\s*\/\//d' "$file")
  echo "$file_content" | jq -r 'to_entries[] | "| `\(.value.prefix)` | \(.value.description) |"'
}

filename_to_title() {
  local filename=$1
  echo "$filename" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2))}1'
}

update_readme() {
  local tables=""
  for file in "$SNIPPETS_DIR"/*"$SNIPPETS_FILE_EXTENSION"; do
    echo "Processing $file"
    filename=$(basename "$file" "$SNIPPETS_FILE_EXTENSION")
    formatted_filename=$(filename_to_title "$filename")
    table=$(generate_snippet_table "$file")
    tables+="#### ${formatted_filename} Snippets\n\n$table\n\n"
  done

  awk -v tables="$tables" '
    BEGIN {p=1}
    /^<!-- SNIPPETS TABLE START -->$/ {print; print tables; p=0}
    /^<!-- SNIPPETS TABLE END -->$/ {p=1}
    p' "$README_FILE" > "$README_FILE.tmp" && mv "$README_FILE.tmp" "$README_FILE"
}

update_readme
