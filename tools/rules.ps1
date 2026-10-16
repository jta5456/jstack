# Cursor -> Claude Code translation rules for pstack.
# Each rule is a literal find/replace applied in order. `file` is a regex on the
# upstream-relative path ('' means every translated file). `min` is the number
# of hits the build requires, so a rule that stops matching upstream fails loudly.
# Categories: model, spawn, readonly, cloud, transcript, path, builtin, install, harness.

function New-Rule($id, $cat, $file, $find, $repl, $min = 1) {
  [pscustomobject]@{ id = $id; cat = $cat; file = $file; find = $find; repl = $repl; min = $min }
}

$Rules = @(
  # --- harness pointer (the one added sentence in poteto-mode) ---
  New-Rule 'harness-pointer' 'harness' '^skills/poteto-mode/SKILL\.md$' `
    'so put this file''s absolute path in every `poteto-agent` prompt.' `
    'so put this file''s absolute path in every `poteto-agent` prompt. `references/claude-code.md` covers model slugs, readonly and cloud spawns, transcripts, and Windows.'

  # --- models: Grok seats move to Sonnet; slug grammar stays <model>-<effort> ---
  New-Rule 'grok-default' 'model' '' 'grok-4.7-xhigh-fast' 'claude-sonnet-5-5-xhigh' 10
  New-Rule 'grok-medium' 'model' '^skills/setup-pstack/' 'grok-4.7-medium-fast' 'claude-sonnet-5-5-medium'
  New-Rule 'families-arena' 'model' '^skills/arena/' `
    'Families go by prefix: `claude-*`, and `grok-*` with `cursor-grok-*` and `composer-*`. A refused `composer-*` entry runs on `claude-sonnet-5-5-xhigh`.' `
    'Families go by prefix: `claude-opus-*`, `claude-sonnet-*`, `claude-fable-*`, and `claude-haiku-*`.'
  New-Rule 'families-interrogate' 'model' '^skills/interrogate/' `
    'Families go by prefix: `claude-*`, and `grok-*` with `cursor-grok-*` and `composer-*`. A refused `composer-*` entry runs on Reviewer B''s default.' `
    'Families go by prefix: `claude-opus-*`, `claude-sonnet-*`, `claude-fable-*`, and `claude-haiku-*`.'
  New-Rule 'budget-fast-token' 'model' '^skills/setup-pstack/' `
    'The effort token is the last token, or the one before a trailing `fast`, on the ladder' `
    'The effort token is the last token, on the ladder'
  New-Rule 'budget-grok-cap' 'model' '^skills/setup-pstack/' `
    ' Grok slugs top out at `xhigh`, so under `unlimited` the fallback puts Grok at `xhigh` and keeps `claude-sonnet-5-5-xhigh` as it is.' `
    ''
  New-Rule 'setup-models-api' 'model' '^skills/setup-pstack/' 'If Cursor also exposes a models API or CLI' 'If Claude Code also exposes a models API or CLI'
  New-Rule 'slug-split-line' 'model' '' `
    'Set `model` to that line''s value, or to the default if the rule or the line is missing.' `
    'Set `model` and `effort` from that line''s slug (`<model>-<effort>`), or from the default if the rule or the line is missing.' 3
  New-Rule 'slug-split-interrogate' 'model' '^skills/interrogate/' `
    'and `model` set to its configured entry, or its table default' `
    'and `model` and `effort` set from its configured entry (`<model>-<effort>`), or its table default'
  New-Rule 'slug-split-defaults' 'model' '^skills/poteto-mode/SKILL\.md$' `
    'explicit model per role (configurable via `/setup-pstack`.' `
    'explicit model per role (a slug such as `claude-opus-5-5-xhigh` is `model: "claude-opus-5-5"` with `effort: "xhigh"`, configurable via `/setup-pstack`.'
  New-Rule 'omit-model' 'model' '' 'omit Task `model`' 'omit `Agent` `model` and `effort`' 2
  New-Rule 'speed-pick' 'model' '' 'reasoning level and fast or standard speed for the job' 'reasoning level for the job' 15
  New-Rule 'speed-match' 'model' '^skills/poteto-mode/SKILL\.md$' 'pick the reasoning level and speed the job needs.' 'pick the reasoning level the job needs.'
  New-Rule 'speed-fast-mode' 'model' '^skills/poteto-mode/SKILL\.md$' `
    ' Use fast mode only when the job is urgent, meaning CI or trunk is red or a person is blocked on the result right now. Otherwise use standard speed, the same slug without `-fast`.' `
    ''
  New-Rule 'speed-verify' 'model' '^skills/poteto-mode/SKILL\.md$' 'stays on the `swarm workers` model and speed (' 'stays on the `swarm workers` model and effort ('
  New-Rule 'speed-family' 'model' '^skills/poteto-mode/SKILL\.md$' 'Change only the effort level and whether the slug is fast, and keep the family' 'Change only the effort level, and keep the family'
  New-Rule 'speed-nearest' 'model' '^skills/poteto-mode/SKILL\.md$' 'If the family has no slug at that level and speed, use its nearest slug.' 'If the family has no slug at that level, use its nearest slug.'

  # --- readonly spawns -> pstack:readonly agent (no write tools, no MCP, like Cursor readonly) ---
  New-Rule 'ro-how' 'readonly' '^skills/how/SKILL\.md$' `
    'Every spawn is a Task subagent with `subagent_type: generalPurpose` and `readonly: true`.' `
    'Every spawn is an `Agent` subagent with `subagent_type: "pstack:readonly"`.'
  New-Rule 'ro-interrogate' 'readonly' '^skills/interrogate/' `
    'Each reviewer gets `subagent_type: generalPurpose`, `readonly: true`, and' `
    'Each reviewer gets `subagent_type: "pstack:readonly"`, and'
  New-Rule 'ro-arena-judge' 'readonly' '^skills/arena/' 'Spawn one readonly judge subagent on that model.' 'Spawn one readonly judge subagent (`subagent_type: "pstack:readonly"`) on that model.'
  New-Rule 'ro-agent-mode' 'readonly' '' 'agent mode (`readonly: false`)' 'agent mode (not `pstack:readonly`)' 2
  New-Rule 'ro-why' 'readonly' '^skills/why/SKILL\.md$' `
    'Every spawn is `generalPurpose` with `readonly: false` (agent mode). **Do not use readonly/Ask mode.**' `
    'Every spawn is `general-purpose` (agent mode), never `pstack:readonly`. **Do not use readonly mode.**'

  # --- spawn tool and agent types ---
  New-Rule 'gp-typed' 'spawn' '' '`subagent_type: generalPurpose`' '`subagent_type: "general-purpose"`' 3
  New-Rule 'gp-bare' 'spawn' '' '`generalPurpose`' '`general-purpose`' 1
  New-Rule 'poteto-agent-type' 'spawn' '' 'subagent_type: "poteto-agent"' 'subagent_type: "pstack:poteto-agent"' 3
  New-Rule 'comment-sicko-type' 'spawn' '' 'subagent_type: "comment-sicko"' 'subagent_type: "pstack:comment-sicko"'
  New-Rule 'task-nested' 'spawn' '^skills/poteto-mode/playbooks/orchestrate\.md$' `
    '(nesting works to depth 3, and a nested spawn has the full Task schema including `environment`)' `
    '(nesting works, and a nested spawn has the full `Agent` schema including `isolation`)'
  New-Rule 'task-tool' 'spawn' '' 'the Task tool' 'the `Agent` tool' 8
  New-Rule 'task-spawn' 'spawn' '' 'every Task spawn' 'every `Agent` spawn'
  New-Rule 'task-subagent' 'spawn' '' 'Task subagent' '`Agent` subagent' 0
  New-Rule 'setup-detect' 'model' '^skills/setup-pstack/' `
    'Enumerate the model slugs you can pass to a `Task` subagent in this session.' `
    'Enumerate the model slugs you can pass to an `Agent` subagent in this session, per `../poteto-mode/references/claude-code.md`.'
  New-Rule 'task-article' 'spawn' '' 'a `Task` prompt' 'an `Agent` prompt' 3
  New-Rule 'task-ticked' 'spawn' '' '`Task`' '`Agent`' 5

  # --- cloud agents -> isolation: "remote" (Claude cloud sandbox) ---
  New-Rule 'cloud-env' 'cloud' '' '`environment: "cloud"`' '`isolation: "remote"`' 2
  New-Rule 'local-env' 'cloud' '' '`environment: "local"`' '`isolation: "worktree"`'
  New-Rule 'cloud-base-branch' 'cloud' '^skills/swarm/' `
    'When a worker must start from a non-default pushed branch, pass `cloud_base_branch`.' `
    'When a worker must start from a non-default pushed branch, name that branch in its brief so it checks the branch out first.'
  New-Rule 'cloud-owner' 'cloud' '' 'Each owner is a Cursor cloud agent that builds' 'Each owner is a cloud agent (`isolation: "remote"`) that builds'
  New-Rule 'cloud-verifier' 'cloud' '' 'each a Cursor cloud agent, runs' 'each a cloud agent (`isolation: "remote"`), runs'
  New-Rule 'cloud-dashboard' 'cloud' '' 'the cloud agent''s status in the Cursor dashboard' 'the cloud agent''s status in `ListAgents` or its claude.ai/code session'
  New-Rule 'restart-after' 'cloud' '' 'After a Cursor restart:' 'After a Claude Code restart:'
  New-Rule 'restart-a' 'cloud' '' 'a Cursor restart' 'a Claude Code restart'
  New-Rule 'store-root' 'cloud' '' 'in the root agent''s store (path in the system prompt)' 'in the root agent''s store (`~/.claude/orchestrate/`)'
  New-Rule 'store-current' 'cloud' '' 'in the current agent''s store (path in the system prompt)' 'in the current agent''s store (`~/.claude/`)'

  # --- transcripts ---
  New-Rule 'tx-system-prompt' 'transcript' '' `
    'The system prompt names the workspace''s `agent-transcripts/` directory. Use only that path.' `
    'Claude Code keeps them in `~/.claude/projects/<encoded-cwd>/`, where `<encoded-cwd>` is the workspace''s absolute path with every non-alphanumeric character turned into `-`. Use only that path.'
  New-Rule 'tx-active-this' 'transcript' '' `
    'the active workspace''s `agent-transcripts/` directory (the system prompt names this path)' `
    'the active workspace''s transcripts directory (`~/.claude/projects/<encoded-cwd>/`, the workspace path with every non-alphanumeric character as `-`)'
  New-Rule 'tx-active-the' 'transcript' '' `
    'the active workspace''s `agent-transcripts/` directory (the system prompt names the path' `
    'the active workspace''s transcripts directory (`~/.claude/projects/<encoded-cwd>/`, the workspace path with every non-alphanumeric character as `-`' 2
  New-Rule 'tx-reflect' 'transcript' '^skills/reflect/SKILL\.md$' `
    'find this conversation''s transcript in the `agent-transcripts/` directory the system prompt names.' `
    'find this conversation''s transcript in the workspace''s transcripts directory, `~/.claude/projects/<encoded-cwd>/` (the workspace path with every non-alphanumeric character as `-`).'
  New-Rule 'tx-reflect-ls' 'transcript' '^skills/reflect/SKILL\.md$' '<agent-transcripts>' '<transcripts>' 3
  New-Rule 'tx-orchestrate' 'transcript' '' 'Reading local transcripts under `agent-transcripts/`.' 'Reading local transcripts under `~/.claude/projects/`.'
  New-Rule 'tx-recall' 'transcript' '^skills/recall/' `
    'Transcripts live at `~/.cursor/projects/<slug>/agent-transcripts/<uuid>/<uuid>.jsonl`, where `<slug>` is the workspace path with the leading slash dropped and each "/" turned into "-" (so `/Users/you/proj` becomes `Users-you-proj`).' `
    'Transcripts live at `~/.claude/projects/<slug>/<uuid>.jsonl`, with subagents under `<uuid>/subagents/`, where `<slug>` is the workspace path with every non-alphanumeric character turned into "-" (so `/Users/you/proj` becomes `-Users-you-proj` and `C:\Users\you\proj` becomes `C--Users-you-proj`).'
  New-Rule 'tx-glob' 'transcript' '' '`~/.cursor/projects/*/`' '`~/.claude/projects/*/`' 5
  New-Rule 'tx-shell-tool' 'transcript' '^skills/reflect/references/' 'a tool call (Shell, Grep, MCP, etc.)' 'a tool call (Bash, PowerShell, Grep, MCP, etc.)' 3
  New-Rule 'tx-audit-comment' 'transcript' '^skills/poteto-mode/scripts/worktree-audit\.sh$' `
    '# Transcripts dir: ~/.cursor/projects/<slugified-repo-path>/agent-transcripts.' `
    '# Transcripts dir: ~/.claude/projects/<repo-path with every non-alphanumeric char as ->.'
  New-Rule 'tx-audit-slug' 'transcript' '^skills/poteto-mode/scripts/worktree-audit\.sh$' `
    'slug=$(printf ''%s'' "$main_wt" | sed ''s#^/##; s#/#-#g'')' `
    'slug=$(printf ''%s'' "$main_wt" | sed ''s#[^A-Za-z0-9]#-#g'')'
  New-Rule 'tx-audit-dir' 'transcript' '^skills/poteto-mode/scripts/worktree-audit\.sh$' `
    'transcripts="$HOME/.cursor/projects/$slug/agent-transcripts"' `
    'transcripts="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects/$slug"'

  # --- paths and config ---
  New-Rule 'models-rule-path' 'path' '' '~/.cursor/rules/pstack-models.mdc' '~/.claude/rules/pstack-models.md' 5
  New-Rule 'models-rule-name' 'path' '' '`pstack-models.mdc`' '`pstack-models.md`' 3
  New-Rule 'setup-always' 'path' '^skills/setup-pstack/' 'with `alwaysApply: true`, a `# budget` line' 'with no `paths` frontmatter, so it always applies, a `# budget` line'
  New-Rule 'setup-always-shape' 'path' '^skills/setup-pstack/' "alwaysApply: true`n" ''
  New-Rule 'user-skills' 'path' '' '~/.cursor/skills/' '~/.claude/skills/' 2
  New-Rule 'project-skills' 'path' '' '.cursor/skills/' '.claude/skills/' 4
  New-Rule 'plugins-dir' 'path' '' '~/.cursor/plugins/' '~/.claude/plugins/' 2
  New-Rule 'plugin-manifest' 'path' '' '.cursor-plugin/plugin.json' '.claude-plugin/plugin.json'
  New-Rule 'worktrees-dir' 'path' '' '`.cursor/worktrees/myrepo/x`' '`.claude/worktrees/x`'
  New-Rule 'app-caches' 'path' '' `
    '`~/Library/Application Support/Cursor` (`state.vscdb.backup`, and `snapshots/roots/<root>` where a `<root>` named for a folder you opened as a workspace balloons)' `
    'Claude Code''s own caches (old transcripts under `~/.claude/projects/` and `~/.claude/shell-snapshots/`)'

  # --- built-ins ---
  New-Rule 'ask-question' 'builtin' '' 'AskQuestion' 'AskUserQuestion' 4
  New-Rule 'create-skill-built-in-skill' 'builtin' '' 'Cursor''s built-in `create-skill` skill' 'the `skill-creator` skill (`/plugin install skill-creator@claude-plugins-official`)' 2
  New-Rule 'create-skill-built-in' 'builtin' '' 'Cursor''s built-in `create-skill`' 'the `skill-creator` skill'
  New-Rule 'create-skill-bold' 'builtin' '' '**create-skill** skill (Cursor''s built-in for authoring SKILL.md files)' '**skill-creator** skill (Claude Code''s official plugin for authoring SKILL.md files)' 2
  New-Rule 'create-skill-help' 'builtin' '^skills/poteto-help/' '`/loop` and `/create-skill` are Cursor built-ins.' '`/loop` is a Claude Code built-in, and `/skill-creator` ships in Claude Code''s official `skill-creator` plugin.'
  New-Rule 'create-skill-bare' 'builtin' '' 'create-skill' 'skill-creator' 8
  New-Rule 'babysit-playbook' 'builtin' '^skills/poteto-mode/playbooks/babysit\.md$' ' This playbook replaces Cursor''s built-in babysit skill for these requests, so do not route there even though its description matches the same words.' ''
  New-Rule 'babysit-trigger' 'builtin' '^skills/poteto-mode/SKILL\.md$' ', not Cursor''s built-in babysit skill, whose description matches the same words.' '.'
  New-Rule 'babysit-own' 'builtin' '^skills/poteto-help/' 'Without `/poteto-mode`, a phrase such as "babysit this pr" can start Cursor''s own skill for the same job instead. ' ''
  New-Rule 'loop-command' 'builtin' '' 'Cursor''s `/loop` command' 'Claude Code''s `/loop` command' 2
  New-Rule 'visualize-diagram' 'builtin' '^skills/ketchup/' 'a chart or diagram from `/visualize`' 'a chart or diagram from the visualize or Artifact tool'
  New-Rule 'visualize-chart' 'builtin' '^skills/ketchup/' 'a `/visualize` chart for numbers' 'a visualize or Artifact chart for numbers'
  New-Rule 'why-mcps' 'builtin' '^skills/why/SKILL\.md$' `
    'list the available MCPs from the Cursor environment. Use the available-tools map when present. Otherwise inspect the `mcps/` directory Cursor exposes for enabled MCP servers.' `
    'list the available MCPs from the Claude Code environment. Use the tool list when present (MCP tools are named `mcp__<server>__<tool>`, and deferred ones load through ToolSearch). Otherwise run `claude mcp list` for enabled MCP servers.'

  # --- poteto-help install and modes ---
  New-Rule 'help-install' 'install' '^skills/poteto-help/' `
    '1. Install with `/add-plugin pstack` in chat, or from Customize in the sidebar.' `
    '1. Install with `/plugin marketplace add jta5456/jstack`, then `/plugin install pstack@jstack`, in chat, or from the `/plugin` manager.'
  New-Rule 'help-portability' 'install' '^skills/poteto-help/' `
    "pstack is built for Cursor. Its skills use the Agent Skills format, so other tools can read them. But most workflow skills, including ``/poteto-mode``, ``/how``, ``/why``, and ``/teach``, spawn Cursor subagents with per-role models, and Custom Modes and ``/loop`` are Cursor features, so those parts may not work there.`n`n" `
    ''
  New-Rule 'help-modes' 'install' '^skills/poteto-help/' `
    ("`n- Option+Enter on Mac or Alt+Enter on Windows, or Use as Mode from the skill entry, makes it a Custom Mode. It stays in context every turn until the user exits the mode, and it stays out of casual turns.`n- Cursor's docs list Custom Modes in the Agents Window and the CLI. Elsewhere, start each new task with ``/poteto-mode``.") `
    ''
  New-Rule 'help-plan-mode' 'builtin' '^skills/poteto-help/' 'Cursor''s Plan Mode works alongside it.' 'Claude Code''s plan mode works alongside it.'
  New-Rule 'help-docs-link' 'install' '^skills/poteto-help/' '[Cursor''s skills docs](https://cursor.com/docs/skills)' '[Claude Code''s skills docs](https://code.claude.com/docs/en/skills)'

  # --- Cursor-only docs and the Grok Bot skill are not shipped, so their links go ---
  New-Rule 'help-guide-1' 'removed' '^skills/poteto-help/' ' The [README](../../README.md) and [guide page 1](../../docs/guide/01-setup.md) have the details.' ''
  New-Rule 'help-guide-2' 'removed' '^skills/poteto-help/' ' [Guide page 2](../../docs/guide/02-poteto-mode.md) has examples.' ''
  New-Rule 'help-guide-6' 'removed' '^skills/poteto-help/' ' [Guide page 6](../../docs/guide/06-verify-and-ship.md) covers opening, babysitting, and landing a PR.' ''
  New-Rule 'help-guide-8' 'removed' '^skills/poteto-help/' ' [Guide page 8](../../docs/guide/08-principles.md) lists them.' ''
  New-Rule 'help-guide-7' 'removed' '^skills/poteto-help/' ' See [guide page 7](../../docs/guide/07-overnight.md).' ''
  New-Rule 'help-guide-10' 'removed' '^skills/poteto-help/' ' [Guide page 10](../../docs/guide/10-recipes-and-pitfalls.md) has more pitfalls and the recipes worth copying.' ''
  New-Rule 'help-guide-9' 'removed' '^skills/poteto-help/' "`n`n[Guide page 9](../../docs/guide/09-make-it-yours.md) covers each of these." ''
  New-Rule 'help-bot-ui' 'removed' '^skills/poteto-help/' "| Build a page whose buttons wake a Grok Bot over a webhook | [``/make-bot-ui``](../make-bot-ui/SKILL.md) |`n" ''
)
