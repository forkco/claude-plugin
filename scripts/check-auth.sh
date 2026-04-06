#!/usr/bin/env bash
# SessionStart hook: check if user is authenticated with Fork.me
# If not, prompt them to run /fork

TOKEN=$(cat "$HOME/.fork/token" 2>/dev/null)

if [ -z "$TOKEN" ]; then
    cat <<'JSON'
{
  "additionalContext": "The Fork.me plugin is installed but not yet authenticated. Tell the user: 'Fork plugin detected! Run /fork to connect your Fork.me account and start developing.' Keep it brief and friendly."
}
JSON
fi

exit 0
