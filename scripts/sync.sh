#!/usr/bin/env bash
# PostToolUse hook: sync changed file to Fork.me API
# Receives tool use info as JSON on stdin

# Check if we're in a Fork project
[ -f ".fork.json" ] || exit 0

# Read token
TOKEN=$(cat "$HOME/.fork/token" 2>/dev/null)
[ -z "$TOKEN" ] && exit 0

# Read app config
APP_ID=$(jq -r '.app_id' .fork.json 2>/dev/null)
SERVER=$(jq -r '.server // "https://fork.me"' .fork.json 2>/dev/null)
[ -z "$APP_ID" ] && exit 0

# Parse hook input
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)
[ -z "$FILE_PATH" ] && exit 0

# Get just the filename (Fork uses flat files)
FILENAME=$(basename "$FILE_PATH")

# Skip config files
case "$FILENAME" in
    .fork.json|CLAUDE.md|.gitignore|.*) exit 0 ;;
esac

# Skip if file doesn't exist (might have been deleted)
[ -f "$FILE_PATH" ] || exit 0

# Read content and push to Fork API (async, don't block)
CONTENT=$(jq -Rs . < "$FILE_PATH")
curl -s -X POST "$SERVER/api/admin/apps/$APP_ID/files" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"path\":\"$FILENAME\",\"content\":$CONTENT}" > /dev/null 2>&1 &

exit 0
