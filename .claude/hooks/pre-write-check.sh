#!/bin/bash
# Pre-write check for xavs-ansible-collection
# Warns about critical collection files

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Warn if editing galaxy.yml — collection metadata
if [[ "$FILE_PATH" == *galaxy.yml ]]; then
  cat <<EOF
{
  "additionalContext": "CAUTION: galaxy.yml defines the collection metadata (name, version, dependencies). Version changes trigger a new collection build."
}
EOF
fi

exit 0
