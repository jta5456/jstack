# Claude Code

pstack's skills use these harness terms.

## Model slugs

A slug is `<model>-<effort>`. On the `Agent` call, `claude-opus-5-5-xhigh` is `model: "claude-opus-5-5"` with `effort: "xhigh"`.

- Models: `claude-opus-5-5`, `claude-fable-5-1`, `claude-sonnet-5-5`, `claude-haiku-5-5`.
- Efforts, highest first: `max`, `xhigh`, `high`, `medium`, `low`.
- `auto` and `inherit-parent` leave `model` and `effort` unset.

These are the slugs `/setup-pstack` detects and writes.

## Spawns

- `Agent` takes `subagent_type`, `model`, `effort`, `run_in_background`, `isolation`, and `name`. Several calls in one message run in parallel. A background agent reports through a completion notification.
- `subagent_type: "pstack:poteto-agent"` is the playbook delegate. `subagent_type: "pstack:readonly"` is the readonly mode for explorers, reviewers, and judges, without file writes or MCP. `subagent_type: "general-purpose"` is agent mode with every tool, MCP included.
- `isolation: "remote"` runs a cloud agent on its own machine. `isolation: "worktree"` gives a local writer its own git worktree under `.claude/worktrees/`.
- Give a long-lived agent a `name`. Resume or message it with `SendMessage` to that name. Stop it with `TaskStop`. `ListAgents` shows live agents.

## Files

- `/setup-pstack` writes its rule to `~/.claude/rules/pstack-models.md`. A rule without `paths` frontmatter loads in every session.
- Orchestrate and autopilot stores live under `~/.claude/orchestrate/`.
- Transcripts are `~/.claude/projects/<encoded-cwd>/<session>.jsonl`, with subagents in `<session>/subagents/agent-<id>.jsonl`. `<encoded-cwd>` is the workspace's absolute path with every non-alphanumeric character as `-`.
- `~/.claude` is `$CLAUDE_CONFIG_DIR` when that is set.

## Windows

Claude Code runs commands in Git Bash when Git for Windows is installed, and in PowerShell otherwise. In PowerShell, use these forms.

| Skill text | PowerShell |
| --- | --- |
| `scripts/worktree-audit.sh` | `scripts/worktree-audit.ps1`, same arguments |
| `scripts/log.sh` (show-me-your-work) | `scripts/log.ps1`, same arguments |
| `scripts/watch-pr/watch-pr` | `scripts/watch-pr/watch-pr.cmd`, same arguments |
| `bun scripts/orch/orch.ts` | unchanged |
| `/tmp/<path>` | `$env:TEMP\<path>` |
| `ls -t <a> <b> 2>/dev/null \| head -10` | `Get-ChildItem <a>,<b> -ErrorAction SilentlyContinue \| Sort-Object LastWriteTime -Descending \| Select-Object -First 10` |
| `df -h /` | `Get-PSDrive C` |
| `command -v <tool>` | `Get-Command <tool> -ErrorAction SilentlyContinue` |
| `curl -fsSL https://tailscale.com/install.sh \| sudo sh` | `winget install Tailscale.Tailscale` |
| `~/<path>` as a program argument | `$HOME/<path>` |
| `<a> && <b>` | `<a>; if ($?) { <b> }` |
| `<VAR>=<value>` | `$env:<VAR> = '<value>'` |
| `rm -rf <path>` | `Remove-Item -Recurse -Force <path>` |
| `ls -t <paths>` | `Get-ChildItem <paths> \| Sort-Object LastWriteTime -Descending` |
| `column -s$'\t' -t decisions.tsv` | `Import-Csv decisions.tsv -Delimiter ([char]9) \| Format-Table` |
| `top`, `pidstat` | `Get-Process \| Sort-Object CPU -Descending` |

`xcrun simctl`, Xcode `DerivedData`, and `iOS DeviceSupport` apply only on macOS.

Prerequisites: `winget install Git.Git GitHub.cli Oven-sh.Bun OpenJS.NodeJS.LTS BurntSushi.ripgrep.MSVC jqlang.jq`.
