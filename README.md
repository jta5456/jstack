# jstack

Lauren Tan's [pstack](https://github.com/cursor/plugins/tree/main/pstack), ported natively to Claude Code with as little change to her text as the harness allows. It ships with its `cursor-team-kit` dependency and runs natively on Windows 11.

- **Upstream pin.** `cursor/plugins` commit [`99743e9`](https://github.com/cursor/plugins/commit/99743e9c151c8537cbbf1f98bb38f34ef3368453), pstack **v0.15.25** (2026-10-15).
- **Target.** Claude Code **v2.1.301**, verified against that release's own frontmatter parser and tool schemas.

## Install

Prerequisites (Windows):

```powershell
winget install Git.Git GitHub.cli Oven-sh.Bun OpenJS.NodeJS.LTS BurntSushi.ripgrep.MSVC jqlang.jq
```

In Claude Code:

```
/plugin marketplace add jta5456/jstack
/plugin install pstack@jstack
```

`cursor-team-kit` installs automatically as a dependency. Then run `/setup-pstack` once, and start real work with `/poteto-mode`.

Without the Claude Code UI, use the CLI:

```powershell
claude plugin marketplace add jta5456/jstack
claude plugin install pstack@jstack
```

## How close is this to Lauren's pstack?

Every number below comes from `tools/build.ps1`, which rebuilds the plugin from upstream and diffs every file. Per-file numbers are in [METRICS.md](METRICS.md). Each changed file has its own unified diff under [`diffs/`](diffs).

| | pstack | cursor-team-kit |
| --- | ---: | ---: |
| Upstream files carried | 148 | 26 |
| Byte-identical to upstream | 94 (63.5%) | 19 (73.1%) |
| Changed only by translation | 54 | 7 |
| Upstream lines unchanged | **98.22%** (13,398 of 13,641) | **98.43%** |
| Upstream words untouched (word-level diff) | **99.02%** (947 removed, 762 added, of 96,665) | **99.67%** |
| Removed (Cursor-only) | 18 | 2 |
| Added (Claude-only) | 6 | 3 |

### What is the same

- Every skill, playbook, principle, reference, and script Lauren ships for agents is here, under the same names and paths.
  - 39 workflow skills.
  - 24 principles.
  - 23 playbooks.
  - `orch`, `watch-pr`, `check-plan`, `bootstrap`, `worktree-audit`, and `log.sh`.
- Her frontmatter is kept, including `disable-model-invocation: true` on every skill but `/setup-pstack`. Claude Code honors it exactly as Cursor does: you type `/poteto-mode`, and poteto-mode reads its leaf skills by path.
- Her policies are kept unchanged: autonomy, review separation, shipping, merge authority, and the Bugbot posture. This port has no policy forks.
- Her model defaults survive word for word wherever Claude can run them. `claude-opus-5-5-xhigh` is still the judgment, prose, and hardest-changes default.
- Benny (`automations/benny/`) keeps her layout. It holds direct automation instructions, not registered skills.

### What changed, and why

Changes are token-level translations from a Cursor primitive to the Claude Code primitive that does the same job. Each is a literal rule in [`tools/rules.ps1`](tools/rules.ps1), and the build fails if a rule stops matching upstream. 92 rules make 221 replacements:

| Category | Rules | Replacements | Cursor → Claude Code |
| --- | ---: | ---: | --- |
| model | 18 | 73 | `grok-4.7-xhigh-fast` → `claude-sonnet-5-5-xhigh`. A slug `<model>-<effort>` splits into the `Agent` call's `model` and `effort`. Families: `claude-opus-*`, `claude-sonnet-*`, `claude-fable-*`, `claude-haiku-*`. Per-spawn fast/standard speed is removed, because fast mode is session-wide (`/fast`). |
| path | 10 | 37 | `~/.cursor/rules/pstack-models.mdc` → `~/.claude/rules/pstack-models.md`, a native always-applied rule. `.cursor/skills/` → `.claude/skills/`. `.cursor/worktrees/` → `.claude/worktrees/`. |
| builtin | 14 | 32 | `AskQuestion` → `AskUserQuestion`. `create-skill` → `skill-creator` (official plugin). Cursor's `/loop` → Claude's `/loop`. `/visualize` → the visualize or Artifact tool. MCP discovery → `mcp__*` tools and ToolSearch. Plan Mode → Claude's plan mode. |
| spawn | 10 | 28 | `Task` → `Agent`. `generalPurpose` → `general-purpose`. `poteto-agent` → `pstack:poteto-agent`. `comment-sicko` → `pstack:comment-sicko`. |
| transcript | 12 | 21 | `agent-transcripts/` → `~/.claude/projects/<encoded-cwd>/`. Includes the slug rule, subagent layout, and `worktree-audit.sh`'s lookup. |
| cloud | 10 | 11 | `environment: "cloud"` → `isolation: "remote"`. `environment: "local"` → `isolation: "worktree"`. Cursor dashboard → `ListAgents`. The agent store moves to `~/.claude/orchestrate/`. |
| removed | 8 | 8 | Links to the guide pages and to `make-bot-ui`, which are not shipped. |
| readonly | 5 | 6 | `readonly: true` → `subagent_type: "pstack:readonly"`. |
| install | 4 | 4 | `/add-plugin` → `/plugin install`. Removed the Custom Mode and portability paragraphs, which describe features Claude Code doesn't have. |
| harness | 1 | 1 | One added sentence in poteto-mode points to [`references/claude-code.md`](plugins/pstack/skills/poteto-mode/references/claude-code.md). |

Two more frontmatter edits: `name: Poteto Mode` → `poteto-mode` and `is_background: true` → `background: true`. Claude uses `name` as the slash command, and spells the background flag `background`.

**Rule of thumb used throughout:** when a Cursor feature has no Claude Code counterpart, the sentence is removed rather than explained around. Naming a missing feature primes the model toward it.

### Removed (Cursor-only)

- `docs/guide/` (17 files): Lauren's walkthrough of Cursor's UI. Read it [upstream](https://github.com/cursor/plugins/tree/main/pstack/docs/guide).
- `skills/make-bot-ui`: builds a page that wakes a Grok Bot over Cursor's webhook routines. Claude Code has no equivalent.
- The Cursor manifests and Lauren's README, replaced by `.claude-plugin/plugin.json` and this file. Her README is [upstream](https://github.com/cursor/plugins/blob/main/pstack/README.md).

### Added (Claude-only)

| File | Why |
| --- | --- |
| `.claude-plugin/plugin.json` | Claude manifest with the same name, version, description, author, and license, plus `dependencies: ["cursor-team-kit"]`. |
| `agents/readonly.md` | Cursor's `readonly: true` spawn as an agent: read, search, and run read-only commands, with no write tools and no MCP. Lauren's "readonly strips MCP" stays literally true. |
| `skills/poteto-mode/references/claude-code.md` | The harness map: slugs, spawns, files, and Windows command forms. |
| `scripts/worktree-audit.ps1`, `show-me-your-work/scripts/log.ps1` | PowerShell twins of Lauren's shell scripts, with the same arguments and output. |
| `scripts/watch-pr/watch-pr.cmd` | Runs the watcher from PowerShell. |

`orch.test.ts` also skips its three bash-only fake-forge tests on Windows.

### Model mapping

Upstream pairs Opus with Grok for vendor diversity. Claude Code runs only Claude models, so every Grok seat becomes `claude-sonnet-5-5-xhigh`, Claude's fast code model. Panels (arena, architect, interrogate) stay two models from different Claude families. `/setup-pstack` lets you swap any role to `claude-fable-5-1-*` or another model.

### Effort

Every default slug ends in `-xhigh`, as upstream's do. Lauren's `large` budget is the skill default, and poteto-mode starts each role at xhigh, then raises or lowers it per spawn ("Match the model to the job"). The suffix is the same Anthropic `effort` parameter Cursor sets, so `claude-opus-5-5-xhigh` runs exactly as it does in Cursor.

For scale, Claude Code's own recommended efforts are `medium` for Opus 5.5, Sonnet 5.5, and Haiku 5.5, and `high` for Fable 5.1, so pstack's defaults run hotter on purpose. All four models accept every level from `low` to `max`. To spend less, run `/setup-pstack` and pick `medium — high reasoning` or `small — medium reasoning`. That rewrites every role in `~/.claude/rules/pstack-models.md`.

## Windows

- Runs with or without Git Bash. Claude Code uses Git Bash for its Bash tool when Git for Windows is installed, and PowerShell otherwise.
- `.gitattributes` keeps shell scripts and the `watch-pr` shebang LF on checkout.
- Lauren's TypeScript (`orch`, `watch-pr`, `check-plan`) needed no changes: it uses `path.join`, spawns `gh`/`git` without a shell, and tolerates CRLF.
- Every POSIX command an agent might run from skill text has a PowerShell form in [`claude-code.md`](plugins/pstack/skills/poteto-mode/references/claude-code.md#windows).
- cursor-team-kit's `pr-review-canvas`, `control-cli`, and `make-pr-easy-to-review` got inline PowerShell forms where the POSIX command would fail.

## Why not an existing port?

All ~34 public Claude-targeting pstack ports were downloaded and checked against upstream on 2026-10-16.

- Only [michael-denyer/pstack-claude](https://github.com/michael-denyer/pstack-claude) and its T3 derivative carried Lauren's 2026-10-15 trims.
- pstack-claude has 46 declared policy forks of her text. It also makes every skill model-invocable, auto-routes through a SessionStart hook, and passes a `readonly` argument the `Agent` tool doesn't have.
- No port used Claude's `isolation: "remote"`, `SendMessage`, or `background:` agent frontmatter consistently.

jstack starts from upstream itself, and its diffs show every word that changed.

## Rebuild and sync upstream

```powershell
git clone https://github.com/cursor/plugins $env:TEMP\cursor-plugins
powershell -File tools/build.ps1 -Upstream $env:TEMP\cursor-plugins\pstack
```

The build regenerates `plugins/pstack` and `diffs/`, and writes `METRICS.md`. It fails if a rule no longer matches upstream, or if anything shipped still names Cursor's harness or Grok.

- `overlay/pstack/` holds the Claude-only files.
- `plugins/cursor-team-kit/` is a hand port, diffed against its upstream on every build.

## Credits

pstack is by [Lauren Tan](https://github.com/poteto). cursor-team-kit is by Eric Zakariasson. Both are MIT licensed, © Cursor. This port is MIT as well. See [LICENSE](LICENSE) and [NOTICE.md](NOTICE.md).
