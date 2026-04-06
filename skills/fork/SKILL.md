---
name: fork
description: "Manage Fork.me apps: authenticate, clone, pull, push, sync. Use when the user wants to work with Fork.me apps."
---

You are helping the user manage Fork.me apps from the terminal. Fork.me is a platform where users create web apps.

## Configuration

- Token file: `~/.fork/token` (contains API key starting with `fk_`)
- App config: `.fork.json` in the project directory (contains app_id, app_name, server)
- Fork API base: the server URL from `.fork.json`, or `https://fork.me` by default

## Auth Check

First, check if the user is authenticated:

```bash
cat ~/.fork/token 2>/dev/null
```

If the file doesn't exist or is empty, the user needs to authenticate. Start the device auth flow:

```bash
FORK_SERVER="${FORK_SERVER:-https://fork.me}"
RESP=$(curl -s -X POST "$FORK_SERVER/api/auth/device/start" -H "Content-Type: application/json" -d '{"device_name":"Claude Code"}')
CODE=$(echo "$RESP" | jq -r '.code')
AUTH_URL=$(echo "$RESP" | jq -r '.auth_url')
echo "Open this URL to authorize: $AUTH_URL"
```

Tell the user to open the URL in their browser. Then poll for completion:

```bash
while true; do
  POLL=$(curl -s "$FORK_SERVER/api/auth/device/poll?code=$CODE")
  STATUS=$(echo "$POLL" | jq -r '.status')
  if [ "$STATUS" = "authorized" ]; then
    API_KEY=$(echo "$POLL" | jq -r '.api_key')
    mkdir -p ~/.fork && echo "$API_KEY" > ~/.fork/token && chmod 600 ~/.fork/token
    echo "Authorized!"
    break
  fi
  if [ "$STATUS" = "expired" ]; then
    echo "Authorization expired. Please try again."
    break
  fi
  sleep 2
done
```

## Commands

When the user says `/fork` with no arguments or `/fork` followed by a command:

### `/fork` (no args) or `/fork clone <app>`
1. Check auth (see above)
2. List apps: `curl -s -H "Authorization: Bearer $(cat ~/.fork/token)" "$FORK_SERVER/api/apps/" | jq '.apps[] | {name, id, slug}'`
3. Ask user which app to work on
4. Clone files:
```bash
APP_ID="<selected_app_id>"
TOKEN=$(cat ~/.fork/token)
FILES=$(curl -s -H "Authorization: Bearer $TOKEN" "$FORK_SERVER/api/admin/apps/$APP_ID/files")
echo "$FILES" | jq -r '.files[].path' | while read path; do
  CONTENT=$(curl -s -H "Authorization: Bearer $TOKEN" "$FORK_SERVER/api/admin/apps/$APP_ID/files/read?path=$path" | jq -r '.content // ""')
  echo -n "$CONTENT" > "$path"
done
```
5. Create `.fork.json`:
```json
{"app_id": "<id>", "app_name": "<name>", "app_slug": "<slug>", "server": "https://fork.me"}
```
6. Tell the user their app files are ready and they can start editing.

### `/fork pull`
Pull latest files from server (same as clone step 4 but into current dir).

### `/fork push`
Push all local files to server:
```bash
TOKEN=$(cat ~/.fork/token)
APP_ID=$(jq -r '.app_id' .fork.json)
SERVER=$(jq -r '.server' .fork.json)
for f in *; do
  [ -f "$f" ] || continue
  case "$f" in .fork.json|CLAUDE.md|.*) continue ;; esac
  CONTENT=$(jq -Rs . < "$f")
  curl -s -X POST "$SERVER/api/admin/apps/$APP_ID/files" \
    -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
    -d "{\"path\":\"$f\",\"content\":$CONTENT}"
done
```

### `/fork status`
Show current app info from `.fork.json` and compare local vs remote file count.

### `/fork open`
Open the app in browser: `open "$(jq -r '.server' .fork.json)/$(jq -r '.app_slug' .fork.json)"`

### `/fork list`
List all user's apps.

## Important Notes
- Fork.me apps have FLAT file structure (no subdirectories)
- Supported file types: .html, .css, .js, .json, .md
- The PostToolUse hook automatically syncs file changes to Fork — tell the user this
- Always use `jq` for JSON parsing (it's a dependency)
