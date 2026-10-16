# Writes diffs/METRICS.md from the build's metrics and rule-hit files.
param([Parameter(Mandatory)][string]$Upstream, [string]$Root)
if (-not $Root) { $Root = Split-Path $PSScriptRoot -Parent }
$enc = New-Object System.Text.UTF8Encoding($false)
. (Join-Path $PSScriptRoot 'diff.ps1')

function Words([string]$s) { ([regex]::Matches($s, '\S+')).Count }

function Summarize([string]$name) {
  $rows = Get-Content -Raw (Join-Path $Root "diffs\$name.metrics.json") | ConvertFrom-Json
  $carried = @($rows | Where-Object { $_.status -in 'identical', 'changed' })
  $upLines = ($carried | Measure-Object upstreamLines -Sum).Sum
  $same = ($carried | Measure-Object unchanged -Sum).Sum
  $rem = ($carried | Measure-Object removed -Sum).Sum
  $add = ($carried | Measure-Object added -Sum).Sum
  $wordsUp = 0; $wordsRem = 0; $wordsAdd = 0
  foreach ($r in $carried) {
    $up = Join-Path (Join-Path (Split-Path $Upstream -Parent) $name) $r.file
    if (Test-Path -LiteralPath $up) { if ($r.file -match '\.(md|sh|ts|mjs|json|yaml|tsv)$') { $wordsUp += Words ([IO.File]::ReadAllText($up, $enc)) } }
    $df = Join-Path $Root "diffs\$name\$($r.file).diff"
    if (Test-Path -LiteralPath $df) {
      # Word-level diff over each block of consecutive -/+ lines.
      $minus = @(); $plus = @()
      foreach ($l in @([IO.File]::ReadAllLines($df, $enc)) + @(' ')) {
        if ($l.StartsWith('---') -or $l.StartsWith('+++')) { continue }
        if ($l.StartsWith('-')) { $minus += $l.Substring(1); continue }
        if ($l.StartsWith('+')) { $plus += $l.Substring(1); continue }
        if ($minus.Count -or $plus.Count) {
          [string[]]$wa = @(($minus -join ' ').Split([char[]]" `t", [StringSplitOptions]::RemoveEmptyEntries))
          [string[]]$wb = @(($plus -join ' ').Split([char[]]" `t", [StringSplitOptions]::RemoveEmptyEntries))
          $res = [UDiff]::Run($wa, $wb, '', '')
          $wordsRem += $res[1]; $wordsAdd += $res[2]
          $minus = @(); $plus = @()
        }
      }
    }
  }
  [pscustomobject]@{
    name = $name; rows = $rows; carried = $carried.Count
    identical = @($rows | Where-Object status -eq 'identical').Count
    changed = @($rows | Where-Object status -eq 'changed').Count
    added = @($rows | Where-Object status -eq 'added').Count
    removed = @($rows | Where-Object status -eq 'removed').Count
    replaced = @($rows | Where-Object status -eq 'replaced').Count
    upLines = $upLines; same = $same; remLines = $rem; addLines = $add
    pctLines = if ($upLines) { [math]::Round(100 * $same / $upLines, 2) } else { 100 }
    wordsUp = $wordsUp; wordsRem = $wordsRem; wordsAdd = $wordsAdd
    pctWords = if ($wordsUp) { [math]::Round(100 * (1 - $wordsRem / $wordsUp), 2) } else { 100 }
  }
}

$sb = New-Object System.Text.StringBuilder
foreach ($name in 'pstack', 'cursor-team-kit') {
  $s = Summarize $name
  [void]$sb.AppendLine("## $name").AppendLine()
  [void]$sb.AppendLine('| Measure | Value |').AppendLine('| --- | --- |')
  [void]$sb.AppendLine("| Upstream files carried | $($s.carried) |")
  [void]$sb.AppendLine("| Byte-identical to upstream | $($s.identical) ($([math]::Round(100*$s.identical/[math]::Max(1,$s.carried),1))% of carried) |")
  [void]$sb.AppendLine("| Changed by translation | $($s.changed) |")
  [void]$sb.AppendLine("| Removed (Cursor-only) | $($s.removed) |")
  [void]$sb.AppendLine("| Replaced (Cursor manifest/README) | $($s.replaced) |")
  [void]$sb.AppendLine("| Added (Claude-only) | $($s.added) |")
  [void]$sb.AppendLine("| Upstream text lines in carried files | $($s.upLines) |")
  [void]$sb.AppendLine("| Lines unchanged | $($s.same) ($($s.pctLines)%) |")
  [void]$sb.AppendLine("| Lines removed / added | $($s.remLines) / $($s.addLines) |")
  [void]$sb.AppendLine("| Words in carried text files | $($s.wordsUp) |")
  [void]$sb.AppendLine("| Words removed / added (word-level diff) | $($s.wordsRem) / $($s.wordsAdd) |")
  [void]$sb.AppendLine("| Words untouched | $($s.pctWords)% |").AppendLine()
  [void]$sb.AppendLine('| File | Status | Upstream lines | Unchanged | Removed | Added | Diff |').AppendLine('| --- | --- | ---: | ---: | ---: | ---: | --- |')
  foreach ($r in ($s.rows | Where-Object { $_.status -ne 'identical' } | Sort-Object status, file)) {
    $link = if (Test-Path -LiteralPath (Join-Path $Root "diffs\$name\$($r.file).diff")) { "[diff](diffs/$name/$($r.file).diff)" } else { '' }
    [void]$sb.AppendLine("| ``$($r.file)`` | $($r.status) | $($r.upstreamLines) | $($r.unchanged) | $($r.removed) | $($r.added) | $link |")
  }
  [void]$sb.AppendLine()
}
$hits = Get-Content -Raw (Join-Path $Root 'diffs\pstack.rules.json') | ConvertFrom-Json
[void]$sb.AppendLine('## pstack translation rules by category').AppendLine()
[void]$sb.AppendLine('| Category | Rules | Replacements |').AppendLine('| --- | ---: | ---: |')
foreach ($g in ($hits | Group-Object cat | Sort-Object Name)) { [void]$sb.AppendLine("| $($g.Name) | $($g.Count) | $(($g.Group | Measure-Object hits -Sum).Sum) |") }
[void]$sb.AppendLine("| **total** | **$($hits.Count)** | **$(($hits | Measure-Object hits -Sum).Sum)** |")
[IO.File]::WriteAllText((Join-Path $Root 'METRICS.md'), $sb.ToString(), $enc)
$sb.ToString()
