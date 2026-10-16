## pstack

| Measure | Value |
| --- | --- |
| Upstream files carried | 148 |
| Byte-identical to upstream | 94 (63.5% of carried) |
| Changed by translation | 54 |
| Removed (Cursor-only) | 18 |
| Replaced (Cursor manifest/README) | 3 |
| Added (Claude-only) | 6 |
| Upstream text lines in carried files | 13641 |
| Lines unchanged | 13398 (98.22%) |
| Lines removed / added | 243 / 251 |
| Words in carried text files | 96665 |
| Words removed / added (word-level diff) | 947 / 762 |
| Words untouched | 99.02% |

| File | Status | Upstream lines | Unchanged | Removed | Added | Diff |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| `.claude-plugin/plugin.json` | added | 0 | 0 | 0 | 25 | [diff](diffs/pstack/.claude-plugin/plugin.json.diff) |
| `agents/readonly.md` | added | 0 | 0 | 0 | 7 | [diff](diffs/pstack/agents/readonly.md.diff) |
| `skills/poteto-mode/references/claude-code.md` | added | 0 | 0 | 0 | 54 | [diff](diffs/pstack/skills/poteto-mode/references/claude-code.md.diff) |
| `skills/poteto-mode/scripts/watch-pr/watch-pr.cmd` | added | 0 | 0 | 0 | 0 |  |
| `skills/poteto-mode/scripts/worktree-audit.ps1` | added | 0 | 0 | 0 | 0 |  |
| `skills/show-me-your-work/scripts/log.ps1` | added | 0 | 0 | 0 | 0 |  |
| `agents/poteto-agent.md` | changed | 9 | 6 | 3 | 3 | [diff](diffs/pstack/agents/poteto-agent.md.diff) |
| `automations/benny/FOR_AGENTS.md` | changed | 89 | 72 | 17 | 22 | [diff](diffs/pstack/automations/benny/FOR_AGENTS.md.diff) |
| `automations/benny/README.md` | changed | 23 | 14 | 9 | 14 | [diff](diffs/pstack/automations/benny/README.md.diff) |
| `automations/benny/skills/reproduce-and-fix-issues/references/control-adapter.md` | changed | 169 | 168 | 1 | 1 | [diff](diffs/pstack/automations/benny/skills/reproduce-and-fix-issues/references/control-adapter.md.diff) |
| `automations/benny/skills/reproduce-and-fix-issues/references/feature-map.example.md` | changed | 205 | 204 | 1 | 1 | [diff](diffs/pstack/automations/benny/skills/reproduce-and-fix-issues/references/feature-map.example.md.diff) |
| `automations/benny/skills/reproduce-and-fix-issues/SKILL.md` | changed | 310 | 303 | 7 | 7 | [diff](diffs/pstack/automations/benny/skills/reproduce-and-fix-issues/SKILL.md.diff) |
| `automations/benny/skills/setup-benny/SKILL.md` | changed | 266 | 219 | 47 | 52 | [diff](diffs/pstack/automations/benny/skills/setup-benny/SKILL.md.diff) |
| `automations/benny/skills/triage-issue-reports/references/routing.example.md` | changed | 61 | 60 | 1 | 1 | [diff](diffs/pstack/automations/benny/skills/triage-issue-reports/references/routing.example.md.diff) |
| `automations/benny/skills/triage-issue-reports/SKILL.md` | changed | 240 | 236 | 4 | 4 | [diff](diffs/pstack/automations/benny/skills/triage-issue-reports/SKILL.md.diff) |
| `automations/benny/templates/configuration.example.yaml` | changed | 84 | 77 | 7 | 8 | [diff](diffs/pstack/automations/benny/templates/configuration.example.yaml.diff) |
| `automations/benny/templates/reproduce-automation-prompt.md` | changed | 33 | 30 | 3 | 3 | [diff](diffs/pstack/automations/benny/templates/reproduce-automation-prompt.md.diff) |
| `automations/benny/templates/triage-automation-prompt.md` | changed | 39 | 37 | 2 | 2 | [diff](diffs/pstack/automations/benny/templates/triage-automation-prompt.md.diff) |
| `skills/architect/SKILL.md` | changed | 79 | 78 | 1 | 1 | [diff](diffs/pstack/skills/architect/SKILL.md.diff) |
| `skills/arena/SKILL.md` | changed | 48 | 46 | 2 | 2 | [diff](diffs/pstack/skills/arena/SKILL.md.diff) |
| `skills/automate-me/SKILL.md` | changed | 104 | 92 | 12 | 12 | [diff](diffs/pstack/skills/automate-me/SKILL.md.diff) |
| `skills/create-verification-skill/SKILL.md` | changed | 44 | 41 | 3 | 3 | [diff](diffs/pstack/skills/create-verification-skill/SKILL.md.diff) |
| `skills/figure-it-out/SKILL.md` | changed | 52 | 51 | 1 | 1 | [diff](diffs/pstack/skills/figure-it-out/SKILL.md.diff) |
| `skills/how/SKILL.md` | changed | 36 | 35 | 1 | 1 | [diff](diffs/pstack/skills/how/SKILL.md.diff) |
| `skills/interrogate/SKILL.md` | changed | 74 | 69 | 5 | 5 | [diff](diffs/pstack/skills/interrogate/SKILL.md.diff) |
| `skills/ketchup/SKILL.md` | changed | 37 | 35 | 2 | 2 | [diff](diffs/pstack/skills/ketchup/SKILL.md.diff) |
| `skills/maintain-verification-skill/SKILL.md` | changed | 39 | 38 | 1 | 1 | [diff](diffs/pstack/skills/maintain-verification-skill/SKILL.md.diff) |
| `skills/no-comments/SKILL.md` | changed | 24 | 23 | 1 | 1 | [diff](diffs/pstack/skills/no-comments/SKILL.md.diff) |
| `skills/poteto-help/SKILL.md` | changed | 156 | 138 | 18 | 11 | [diff](diffs/pstack/skills/poteto-help/SKILL.md.diff) |
| `skills/poteto-mode/playbooks/authoring-a-skill.md` | changed | 12 | 11 | 1 | 1 | [diff](diffs/pstack/skills/poteto-mode/playbooks/authoring-a-skill.md.diff) |
| `skills/poteto-mode/playbooks/autonomous-run.md` | changed | 13 | 11 | 2 | 2 | [diff](diffs/pstack/skills/poteto-mode/playbooks/autonomous-run.md.diff) |
| `skills/poteto-mode/playbooks/autopilot-full.md` | changed | 25 | 23 | 2 | 2 | [diff](diffs/pstack/skills/poteto-mode/playbooks/autopilot-full.md.diff) |
| `skills/poteto-mode/playbooks/babysit.md` | changed | 23 | 22 | 1 | 1 | [diff](diffs/pstack/skills/poteto-mode/playbooks/babysit.md.diff) |
| `skills/poteto-mode/playbooks/bug-fix.md` | changed | 15 | 12 | 3 | 3 | [diff](diffs/pstack/skills/poteto-mode/playbooks/bug-fix.md.diff) |
| `skills/poteto-mode/playbooks/eval.md` | changed | 25 | 23 | 2 | 2 | [diff](diffs/pstack/skills/poteto-mode/playbooks/eval.md.diff) |
| `skills/poteto-mode/playbooks/feature.md` | changed | 21 | 20 | 1 | 1 | [diff](diffs/pstack/skills/poteto-mode/playbooks/feature.md.diff) |
| `skills/poteto-mode/playbooks/hillclimb.md` | changed | 21 | 20 | 1 | 1 | [diff](diffs/pstack/skills/poteto-mode/playbooks/hillclimb.md.diff) |
| `skills/poteto-mode/playbooks/multi-phase-plan.md` | changed | 155 | 153 | 2 | 2 | [diff](diffs/pstack/skills/poteto-mode/playbooks/multi-phase-plan.md.diff) |
| `skills/poteto-mode/playbooks/opening-a-pr.md` | changed | 34 | 33 | 1 | 1 | [diff](diffs/pstack/skills/poteto-mode/playbooks/opening-a-pr.md.diff) |
| `skills/poteto-mode/playbooks/orchestrate.md` | changed | 112 | 106 | 6 | 6 | [diff](diffs/pstack/skills/poteto-mode/playbooks/orchestrate.md.diff) |
| `skills/poteto-mode/playbooks/perf-issue.md` | changed | 25 | 24 | 1 | 1 | [diff](diffs/pstack/skills/poteto-mode/playbooks/perf-issue.md.diff) |
| `skills/poteto-mode/playbooks/refactoring.md` | changed | 16 | 15 | 1 | 1 | [diff](diffs/pstack/skills/poteto-mode/playbooks/refactoring.md.diff) |
| `skills/poteto-mode/playbooks/runtime-forensics.md` | changed | 11 | 10 | 1 | 1 | [diff](diffs/pstack/skills/poteto-mode/playbooks/runtime-forensics.md.diff) |
| `skills/poteto-mode/playbooks/session-pickup.md` | changed | 11 | 10 | 1 | 1 | [diff](diffs/pstack/skills/poteto-mode/playbooks/session-pickup.md.diff) |
| `skills/poteto-mode/playbooks/shipping.md` | changed | 12 | 11 | 1 | 1 | [diff](diffs/pstack/skills/poteto-mode/playbooks/shipping.md.diff) |
| `skills/poteto-mode/playbooks/trace-forensics.md` | changed | 14 | 13 | 1 | 1 | [diff](diffs/pstack/skills/poteto-mode/playbooks/trace-forensics.md.diff) |
| `skills/poteto-mode/playbooks/worktree-cleanup.md` | changed | 12 | 9 | 3 | 3 | [diff](diffs/pstack/skills/poteto-mode/playbooks/worktree-cleanup.md.diff) |
| `skills/poteto-mode/scripts/orch/orch.test.ts` | changed | 761 | 757 | 4 | 4 | [diff](diffs/pstack/skills/poteto-mode/scripts/orch/orch.test.ts.diff) |
| `skills/poteto-mode/scripts/worktree-audit.sh` | changed | 126 | 123 | 3 | 3 | [diff](diffs/pstack/skills/poteto-mode/scripts/worktree-audit.sh.diff) |
| `skills/poteto-mode/SKILL.md` | changed | 149 | 140 | 9 | 9 | [diff](diffs/pstack/skills/poteto-mode/SKILL.md.diff) |
| `skills/recall/SKILL.md` | changed | 35 | 33 | 2 | 2 | [diff](diffs/pstack/skills/recall/SKILL.md.diff) |
| `skills/reflect/references/divergent-reviewer.md` | changed | 38 | 37 | 1 | 1 | [diff](diffs/pstack/skills/reflect/references/divergent-reviewer.md.diff) |
| `skills/reflect/references/judgment-reviewer.md` | changed | 37 | 36 | 1 | 1 | [diff](diffs/pstack/skills/reflect/references/judgment-reviewer.md.diff) |
| `skills/reflect/references/synthesizer.md` | changed | 56 | 54 | 2 | 2 | [diff](diffs/pstack/skills/reflect/references/synthesizer.md.diff) |
| `skills/reflect/references/tooling-reviewer.md` | changed | 48 | 47 | 1 | 1 | [diff](diffs/pstack/skills/reflect/references/tooling-reviewer.md.diff) |
| `skills/reflect/SKILL.md` | changed | 67 | 57 | 10 | 10 | [diff](diffs/pstack/skills/reflect/SKILL.md.diff) |
| `skills/setup-pstack/SKILL.md` | changed | 74 | 53 | 21 | 20 | [diff](diffs/pstack/skills/setup-pstack/SKILL.md.diff) |
| `skills/show-me-your-work/SKILL.md` | changed | 82 | 80 | 2 | 2 | [diff](diffs/pstack/skills/show-me-your-work/SKILL.md.diff) |
| `skills/swarm/SKILL.md` | changed | 41 | 38 | 3 | 3 | [diff](diffs/pstack/skills/swarm/SKILL.md.diff) |
| `skills/why/SKILL.md` | changed | 98 | 94 | 4 | 4 | [diff](diffs/pstack/skills/why/SKILL.md.diff) |
| `docs/guide/01-setup.md` | removed | 62 | 0 | 62 | 0 | [diff](diffs/pstack/docs/guide/01-setup.md.diff) |
| `docs/guide/02-poteto-mode.md` | removed | 131 | 0 | 131 | 0 | [diff](diffs/pstack/docs/guide/02-poteto-mode.md.diff) |
| `docs/guide/03-understand.md` | removed | 79 | 0 | 79 | 0 | [diff](diffs/pstack/docs/guide/03-understand.md.diff) |
| `docs/guide/04-design.md` | removed | 133 | 0 | 133 | 0 | [diff](diffs/pstack/docs/guide/04-design.md.diff) |
| `docs/guide/05-build-and-clean.md` | removed | 83 | 0 | 83 | 0 | [diff](diffs/pstack/docs/guide/05-build-and-clean.md.diff) |
| `docs/guide/06-verify-and-ship.md` | removed | 130 | 0 | 130 | 0 | [diff](diffs/pstack/docs/guide/06-verify-and-ship.md.diff) |
| `docs/guide/07-overnight.md` | removed | 120 | 0 | 120 | 0 | [diff](diffs/pstack/docs/guide/07-overnight.md.diff) |
| `docs/guide/08-principles.md` | removed | 72 | 0 | 72 | 0 | [diff](diffs/pstack/docs/guide/08-principles.md.diff) |
| `docs/guide/09-make-it-yours.md` | removed | 100 | 0 | 100 | 0 | [diff](diffs/pstack/docs/guide/09-make-it-yours.md.diff) |
| `docs/guide/10-recipes-and-pitfalls.md` | removed | 156 | 0 | 156 | 0 | [diff](diffs/pstack/docs/guide/10-recipes-and-pitfalls.md.diff) |
| `docs/guide/images/design.jpg` | removed | 0 | 0 | 0 | 0 |  |
| `docs/guide/images/overnight.jpg` | removed | 0 | 0 | 0 | 0 |  |
| `docs/guide/images/recipes.jpg` | removed | 0 | 0 | 0 | 0 |  |
| `docs/guide/images/router.jpg` | removed | 0 | 0 | 0 | 0 |  |
| `docs/guide/images/understanding.jpg` | removed | 0 | 0 | 0 | 0 |  |
| `docs/guide/images/verification.jpg` | removed | 0 | 0 | 0 | 0 |  |
| `docs/guide/README.md` | removed | 38 | 0 | 38 | 0 | [diff](diffs/pstack/docs/guide/README.md.diff) |
| `skills/make-bot-ui/SKILL.md` | removed | 115 | 0 | 115 | 0 | [diff](diffs/pstack/skills/make-bot-ui/SKILL.md.diff) |
| `.cursor-plugin/plugin.json` | replaced | 31 | 0 | 31 | 0 | [diff](diffs/pstack/.cursor-plugin/plugin.json.diff) |
| `plugin.json` | replaced | 21 | 0 | 21 | 0 | [diff](diffs/pstack/plugin.json.diff) |
| `README.md` | replaced | 274 | 0 | 274 | 0 | [diff](diffs/pstack/README.md.diff) |

## cursor-team-kit

| Measure | Value |
| --- | --- |
| Upstream files carried | 26 |
| Byte-identical to upstream | 19 (73.1% of carried) |
| Changed by translation | 7 |
| Removed (Cursor-only) | 2 |
| Replaced (Cursor manifest/README) | 1 |
| Added (Claude-only) | 3 |
| Upstream text lines in carried files | 1531 |
| Lines unchanged | 1507 (98.43%) |
| Lines removed / added | 24 / 38 |
| Words in carried text files | 7969 |
| Words removed / added (word-level diff) | 26 / 142 |
| Words untouched | 99.67% |

| File | Status | Upstream lines | Unchanged | Removed | Added | Diff |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| `.claude-plugin/plugin.json` | added | 0 | 0 | 0 | 21 | [diff](diffs/cursor-team-kit/.claude-plugin/plugin.json.diff) |
| `rules/no-inline-imports.md` | added | 0 | 0 | 0 | 3 | [diff](diffs/cursor-team-kit/rules/no-inline-imports.md.diff) |
| `rules/typescript-exhaustive-switch.md` | added | 0 | 0 | 0 | 1 | [diff](diffs/cursor-team-kit/rules/typescript-exhaustive-switch.md.diff) |
| `agents/ci-watcher.md` | changed | 28 | 26 | 2 | 2 | [diff](diffs/cursor-team-kit/agents/ci-watcher.md.diff) |
| `agents/thermo-nuclear-code-quality-review.md` | changed | 23 | 20 | 3 | 3 | [diff](diffs/cursor-team-kit/agents/thermo-nuclear-code-quality-review.md.diff) |
| `README.md` | changed | 52 | 50 | 2 | 4 | [diff](diffs/cursor-team-kit/README.md.diff) |
| `skills/control-cli/SKILL.md` | changed | 109 | 108 | 1 | 1 | [diff](diffs/cursor-team-kit/skills/control-cli/SKILL.md.diff) |
| `skills/make-pr-easy-to-review/SKILL.md` | changed | 59 | 58 | 1 | 3 | [diff](diffs/cursor-team-kit/skills/make-pr-easy-to-review/SKILL.md.diff) |
| `skills/pr-review-canvas/SKILL.md` | changed | 176 | 162 | 14 | 24 | [diff](diffs/cursor-team-kit/skills/pr-review-canvas/SKILL.md.diff) |
| `skills/workflow-from-chats/SKILL.md` | changed | 50 | 49 | 1 | 1 | [diff](diffs/cursor-team-kit/skills/workflow-from-chats/SKILL.md.diff) |
| `rules/no-inline-imports.mdc` | removed | 0 | 0 | 0 | 0 |  |
| `rules/typescript-exhaustive-switch.mdc` | removed | 0 | 0 | 0 | 0 |  |
| `.cursor-plugin/plugin.json` | replaced | 33 | 0 | 33 | 0 | [diff](diffs/cursor-team-kit/.cursor-plugin/plugin.json.diff) |

## pstack translation rules by category

| Category | Rules | Replacements |
| --- | ---: | ---: |
| builtin | 14 | 32 |
| cloud | 10 | 11 |
| harness | 1 | 1 |
| install | 4 | 4 |
| model | 18 | 73 |
| path | 10 | 37 |
| readonly | 5 | 6 |
| removed | 8 | 8 |
| spawn | 10 | 28 |
| transcript | 12 | 21 |
| **total** | **92** | **221** |
