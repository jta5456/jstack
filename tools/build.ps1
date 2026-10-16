# Builds plugins/pstack from upstream cursor/plugins/pstack and writes per-file diffs and metrics.
# Usage: powershell -NoProfile -File tools/build.ps1 -Upstream <path-to-cursor-plugins>/pstack
param(
  [Parameter(Mandatory)][string]$Upstream,
  [string]$Root
)
$ErrorActionPreference = 'Stop'
if (-not $Root) { $Root = Split-Path $PSScriptRoot -Parent }
$enc = New-Object System.Text.UTF8Encoding($false)
. "$PSScriptRoot\rules.ps1"
. "$PSScriptRoot\diff.ps1"

$out = Join-Path $Root 'plugins\pstack'
$overlay = Join-Path $Root 'overlay\pstack'
if (Test-Path $out) { [IO.Directory]::Delete($out, $true) }

# Upstream files that are not carried: the Cursor manifests (their content moves to .claude-plugin/plugin.json),
# and Cursor-only material: the README and guide describe Cursor's UI, and make-bot-ui drives Grok Bot routines.
$skip = @('.cursor-plugin/plugin.json', 'plugin.json', 'README.md')
$skipDirs = @('docs/', 'skills/make-bot-ui/', 'automations/')
# Files kept byte-for-byte: Lauren's README, guide, assets, and code.
$translate = '^(skills/.*\.md|agents/.*\.md|skills/poteto-mode/scripts/worktree-audit\.sh)$'

$hits = @{}; foreach ($r in $Rules) { $hits[$r.id] = 0 }
Get-ChildItem -LiteralPath $Upstream -Recurse -File | ForEach-Object {
  $rel = $_.FullName.Substring($Upstream.Length + 1).Replace('\', '/')
  if ($skip -contains $rel -or ($skipDirs | Where-Object { $rel.StartsWith($_) })) { return }
  $dst = Join-Path $out $rel
  [IO.Directory]::CreateDirectory((Split-Path $dst)) | Out-Null
  if ($rel -notmatch $translate) { [IO.File]::Copy($_.FullName, $dst, $true); return }
  $t = [IO.File]::ReadAllText($_.FullName, $enc)
  foreach ($r in $Rules) {
    if ($r.file -and $rel -notmatch $r.file) { continue }
    $n = ([regex]::Matches($t, [regex]::Escape($r.find))).Count
    if ($n) { $t = $t.Replace($r.find, $r.repl); $hits[$r.id] += $n }
  }
  # Frontmatter: Claude uses `name` as the slash command, so it must match the directory.
  $t = $t -replace '(?m)^name: Poteto Mode$', 'name: poteto-mode'
  $t = $t -replace '(?m)^name: Make Bot UI$', 'name: make-bot-ui'
  # Agent frontmatter: Cursor `is_background` is Claude `background`.
  $t = $t -replace '(?m)^is_background: true$', 'background: true'
  [IO.File]::WriteAllText($dst, $t, $enc)
}

# Overlay: Claude-only files (manifest, readonly agent, harness reference, Windows twins, translated Benny).
Get-ChildItem -LiteralPath $overlay -Recurse -File | ForEach-Object {
  $rel = $_.FullName.Substring($overlay.Length + 1)
  $dst = Join-Path $out $rel
  [IO.Directory]::CreateDirectory((Split-Path $dst)) | Out-Null
  [IO.File]::Copy($_.FullName, $dst, $true)
}

$bad = $Rules | Where-Object { $hits[$_.id] -lt $_.min }
$Rules | ForEach-Object { [pscustomobject]@{ id = $_.id; cat = $_.cat; hits = $hits[$_.id]; min = $_.min } } |
  ConvertTo-Json | Set-Content -Encoding utf8 (Join-Path $Root 'diffs\pstack.rules.json')
if ($bad) { throw "rules below their minimum hits: $(($bad | ForEach-Object { "$($_.id)=$($hits[$_.id])/$($_.min)" }) -join ', ')" }

# Gate: nothing shipped may still name Cursor's harness or Grok.
$leak = Get-ChildItem -LiteralPath $out -Recurse -File -Include *.md, *.json, *.sh, *.ps1, *.yaml |
  Select-String -CaseSensitive -Pattern '[Gg]rok\b|\bCursor\b|\.cursor/|~/\.cursor|generalPurpose|is_background|readonly: (true|false)|agent-transcripts|AskQuestion|composer-' |
  Where-Object { $_.Line -notmatch 'cursor-team-kit' }
if ($leak) { $leak | ForEach-Object { Write-Warning ("{0}:{1}: {2}" -f $_.Path.Substring($out.Length + 1), $_.LineNumber, $_.Line.Trim()) }; throw "$(@($leak).Count) Cursor/Grok leftovers" }

Write-Diffs -Upstream $Upstream -Port $out -DiffDir (Join-Path $Root 'diffs\pstack') -Skip $skip

# cursor-team-kit is ported by hand in place; diff it against its upstream too.
$kit = Join-Path (Split-Path $Upstream -Parent) 'cursor-team-kit'
Write-Diffs -Upstream $kit -Port (Join-Path $Root 'plugins\cursor-team-kit') -DiffDir (Join-Path $Root 'diffs\cursor-team-kit') -Skip @('.cursor-plugin/plugin.json') | Out-Null
& (Join-Path $PSScriptRoot 'metrics.ps1') -Upstream $Upstream -Root $Root | Out-Null
