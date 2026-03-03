#!/bin/bash
# Post-write validation for xavs-ansible-collection
# Validates YAML syntax and Python syntax

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Check Python files
if [[ "$FILE_PATH" == *.py ]]; then
  python3 - "$FILE_PATH" <<'PYEOF' 2>&1
import ast, sys
fpath = sys.argv[1]
try:
    with open(fpath) as f:
        ast.parse(f.read())
except SyntaxError as e:
    print(f'SYNTAX ERROR in {fpath} line {e.lineno}: {e.msg}', file=sys.stderr)
    sys.exit(2)
PYEOF
  if [ $? -ne 0 ]; then
    exit 2
  fi
fi

# Check YAML files
if [[ "$FILE_PATH" == *.yml || "$FILE_PATH" == *.yaml ]]; then
  python3 - "$FILE_PATH" <<'PYEOF' 2>&1
import yaml, sys
fpath = sys.argv[1]
try:
    with open(fpath) as f:
        yaml.safe_load(f.read())
except yaml.YAMLError as e:
    print(f'YAML ERROR in {fpath}: {e}', file=sys.stderr)
    sys.exit(2)
PYEOF
  if [ $? -ne 0 ]; then
    exit 2
  fi
fi

exit 0
