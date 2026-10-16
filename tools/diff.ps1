# Line diff between an upstream tree and a port tree: one unified diff per changed file plus metrics.
Add-Type -TypeDefinition @"
using System; using System.Collections.Generic; using System.Text;
public static class UDiff {
  // Returns [unchanged, removed, added, diffText].
  public static object[] Run(string[] a, string[] b, string nameA, string nameB) {
    int n = a.Length, m = b.Length;
    var L = new int[n + 1, m + 1];
    for (int i = n - 1; i >= 0; i--) for (int j = m - 1; j >= 0; j--)
      L[i, j] = a[i] == b[j] ? L[i + 1, j + 1] + 1 : Math.Max(L[i + 1, j], L[i, j + 1]);
    var ops = new List<char>(); var ai = new List<int>(); var bi = new List<int>();
    int x = 0, y = 0;
    while (x < n && y < m) {
      if (a[x] == b[y]) { ops.Add(' '); ai.Add(x); bi.Add(y); x++; y++; }
      else if (L[x + 1, y] >= L[x, y + 1]) { ops.Add('-'); ai.Add(x); bi.Add(y); x++; }
      else { ops.Add('+'); ai.Add(x); bi.Add(y); y++; }
    }
    while (x < n) { ops.Add('-'); ai.Add(x); bi.Add(y); x++; }
    while (y < m) { ops.Add('+'); ai.Add(x); bi.Add(y); y++; }
    int same = 0, rem = 0, add = 0;
    foreach (var o in ops) { if (o == ' ') same++; else if (o == '-') rem++; else add++; }
    var sb = new StringBuilder();
    sb.Append("--- upstream/" + nameA + "\n+++ jstack/" + nameB + "\n");
    int ctx = 2, k = 0;
    while (k < ops.Count) {
      if (ops[k] == ' ') { k++; continue; }
      int s = Math.Max(0, k - ctx), e = k;
      while (true) {
        int nxt = e + 1; while (nxt < ops.Count && ops[nxt] == ' ' && nxt - e <= 2 * ctx) nxt++;
        if (nxt < ops.Count && ops[nxt] != ' ' && nxt - e <= 2 * ctx) { e = nxt; continue; }
        break;
      }
      int end = Math.Min(ops.Count - 1, e + ctx);
      int a0 = ai[s], b0 = bi[s], ac = 0, bc = 0;
      for (int t = s; t <= end; t++) { if (ops[t] != '+') ac++; if (ops[t] != '-') bc++; }
      sb.Append("@@ -" + (a0 + 1) + "," + ac + " +" + (b0 + 1) + "," + bc + " @@\n");
      for (int t = s; t <= end; t++) sb.Append(ops[t] + (ops[t] == '+' ? b[bi[t]] : a[ai[t]]) + "\n");
      k = end + 1;
    }
    return new object[] { same, rem, add, sb.ToString() };
  }
}
"@

function Read-Lines([string]$path) {
  $t = [IO.File]::ReadAllText($path, (New-Object System.Text.UTF8Encoding($false))) -replace "`r", ''
  if ($t.EndsWith("`n")) { $t = $t.Substring(0, $t.Length - 1) }
  if ($t -eq '') { return [string[]]@() }
  return [string[]]($t -split "`n")
}

function Write-Diffs([string]$Upstream, [string]$Port, [string]$DiffDir, [string[]]$Skip = @()) {
  if (Test-Path $DiffDir) { [IO.Directory]::Delete($DiffDir, $true) }
  [IO.Directory]::CreateDirectory($DiffDir) | Out-Null
  $enc = New-Object System.Text.UTF8Encoding($false)
  $text = '\.(md|sh|ts|mjs|js|json|yaml|yml|tsv|css|html|txt)$|(^|/)watch-pr$|(^|/)\.gitignore$|(^|/)LICENSE$'
  $rows = @()
  $upFiles = @{}; Get-ChildItem -LiteralPath $Upstream -Recurse -File | ForEach-Object { $upFiles[$_.FullName.Substring($Upstream.Length + 1).Replace('\', '/')] = $_.FullName }
  $portFiles = @{}; Get-ChildItem -LiteralPath $Port -Recurse -File | ForEach-Object { $portFiles[$_.FullName.Substring($Port.Length + 1).Replace('\', '/')] = $_.FullName }
  foreach ($rel in ($upFiles.Keys + $portFiles.Keys | Sort-Object -Unique)) {
    $u = $upFiles[$rel]; $p = $portFiles[$rel]
    if (-not $u) { $status = 'added' } elseif (-not $p) { $status = if ($Skip -contains $rel) { 'replaced' } else { 'removed' } }
    elseif ([IO.File]::ReadAllBytes($u).Length -eq [IO.File]::ReadAllBytes($p).Length -and (Get-FileHash -LiteralPath $u).Hash -eq (Get-FileHash -LiteralPath $p).Hash) { $status = 'identical' }
    else { $status = 'changed' }
    $ul = 0; $pl = 0; $same = 0; $rem = 0; $add = 0
    if ($rel -match $text) {
      [string[]]$a = @(if ($u) { Read-Lines $u })
      [string[]]$b = @(if ($p) { Read-Lines $p })
      $ul = $a.Count; $pl = $b.Count
      if ($status -eq 'identical') { $same = $ul }
      else {
        $r = [UDiff]::Run($a, $b, $rel, $rel); $same = $r[0]; $rem = $r[1]; $add = $r[2]
        $df = Join-Path $DiffDir ($rel + '.diff')
        [IO.Directory]::CreateDirectory((Split-Path $df)) | Out-Null
        [IO.File]::WriteAllText($df, $r[3], $enc)
      }
    }
    $rows += [pscustomobject]@{ file = $rel; status = $status; upstreamLines = $ul; portLines = $pl; unchanged = $same; removed = $rem; added = $add }
  }
  $rows | ConvertTo-Json -Depth 3 | Set-Content -Encoding utf8 ($DiffDir + '.metrics.json')
  $rows
}
