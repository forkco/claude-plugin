# Fork — Claude Code Plugin

Develop [Fork.me](https://fork.me) apps with Claude Code. Clone apps locally, edit with Claude, and changes sync automatically.

## Install

Run in Claude Code:

```
/plugin marketplace add forkco/claude-plugin
/plugin install fork@forkco-claude-plugin
```

Then type `/fork` to get started.

## What it does

- **`/fork`** — Authenticate via browser, choose an app, clone files locally
- **Auto-sync** — Every file you edit syncs to Fork.me automatically (PostToolUse hook)
- **MCP** — Connects to Fork's API for search, commits, and app management

## Commands

| Command | Description |
|---------|-------------|
| `/fork` | Auth + choose app + clone files |
| `/fork pull` | Pull latest files from server |
| `/fork push` | Push all local files to server |
| `/fork list` | List your apps |
| `/fork open` | Open app in browser |
| `/fork status` | Show sync status |

## How it works

1. `/fork` opens your browser for authentication (device auth flow)
2. You pick an app — files are cloned to the current directory
3. Claude edits files normally using Read/Write/Edit
4. A PostToolUse hook catches every Write/Edit and pushes the changed file to Fork.me API
5. Your app updates live at `fork.me/you/app-name`

## Requirements

- [Claude Code](https://claude.ai/code)
- `jq` (for JSON parsing in sync script)

## Links

- [Fork.me](https://fork.me)
- [Install page](https://fork.me/cli)
- [API docs](https://fork.me/docs)
