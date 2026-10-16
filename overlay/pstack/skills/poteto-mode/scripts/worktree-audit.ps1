# Windows PowerShell twin of worktree-audit.sh (pstack, Lauren Tan). Same arguments and output.
# Read-only worktree prune audit. Classifies every git worktree by size, merge
# state, uncommitted work, remote/PR state, and the most recent chat that
# operated in it. Emits a table sorted by size with a suggested bucket. Never
# deletes anything; deletion stays a human-gated step in the playbook.
#
# Usage: worktree-audit.ps1 [-b|--base <ref>] [repo-path]
#   repo-path defaults to the current repo.
#   -b sets the ref the MERGED column checks against (e.g. origin/integration).
#   Without it the base is origin/HEAD, then origin/main, then origin/master.
#   origin/HEAD is the remote's default branch, not necessarily the branch PRs
#   merge into; pass -b when they differ.
Set-StrictMode -Version 1
# Native stderr is discarded with 2>$null; under 'Stop' PowerShell 5.1 would
# turn that stderr into terminating errors.
$ErrorActionPreference = 'Continue'

$inv = [System.Globalization.CultureInfo]::InvariantCulture
function Err([string]$msg) { [Console]::Error.WriteLine($msg) }

$argv = @($args)
$base = ''
$i = 0
while ($i -lt $argv.Count) {
	$a = [string]$argv[$i]
	if ($a -ceq '-b' -or $a -ceq '--base') {
		if ($i + 1 -ge $argv.Count) { Err "error: $a needs a ref"; exit 2 }
		$base = [string]$argv[$i + 1]; $i += 2
	} elseif ($a -ceq '-h' -or $a -ceq '--help') {
		$lines = [System.IO.File]::ReadAllLines($PSCommandPath)
		for ($n = 1; $n -lt $lines.Count; $n++) {
			if ($lines[$n].StartsWith('Set-StrictMode')) { break }
			Write-Output ($lines[$n] -replace '^# ?', '')
		}
		exit 0
	} elseif ($a.StartsWith('-')) {
		Err "error: unknown option: $a"; exit 2
	} else { break }
}

# Native command runner: output lines in, exit code in $script:rc (127 when the
# tool is not installed, like a shell's "command not found").
$tools = @{}
function Find-Tool([string]$name) {
	if (-not $tools.ContainsKey($name)) {
		$c = Get-Command $name -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
		if ($c) { $tools[$name] = $c.Source } else { $tools[$name] = $null }
	}
	return $tools[$name]
}
$script:rc = 0
function Run {
	$exe = Find-Tool ([string]$args[0])
	if (-not $exe) { $script:rc = 127; return }
	$rest = @()
	if ($args.Count -gt 1) { $rest = @($args[1..($args.Count - 1)]) }
	$out = & $exe @rest 2>$null
	$script:rc = $LASTEXITCODE
	$out
}
function First($out) { $o = @($out); if ($o.Count -gt 0 -and $null -ne $o[0]) { return [string]$o[0] }; return '' }
function WinPath([string]$p) { return $p.Replace('/', '\') }

# Git prints UTF-8; decode it as such (restored on exit).
$prevOutEnc = $null
try { $prevOutEnc = [Console]::OutputEncoding; [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding $false } catch { $prevOutEnc = $null }
$pushed = $false
$patFile = $null

try {
	if ($i -lt $argv.Count -and [string]$argv[$i] -ne '') { $repo = [string]$argv[$i] }
	else { $repo = First (Run git rev-parse --show-toplevel) }
	if (-not $repo) { Err 'not in a git repo; pass a repo path'; exit 1 }
	try { Push-Location -LiteralPath $repo -ErrorAction Stop; $pushed = $true }
	catch { Err "cd: ${repo}: $($_.Exception.Message)"; exit 1 }
	[void](Run git rev-parse --git-dir)
	if ($script:rc -ne 0) { Err "error: not a git repo: $repo"; exit 1 }

	# Main worktree is the first entry; everything else is a candidate.
	$wtList = @(Run git worktree list --porcelain | Where-Object { $_ -clike 'worktree *' } | ForEach-Object { WinPath $_.Substring(9) })
	$mainWt = ''
	if ($wtList.Count -gt 0) { $mainWt = $wtList[0] }

	if (-not $base) {
		foreach ($cand in @((First (Run git symbolic-ref --short refs/remotes/origin/HEAD)), 'origin/main', 'origin/master')) {
			if (-not $cand) { continue }
			[void](Run git rev-parse --verify --quiet "${cand}^{commit}")
			if ($script:rc -eq 0) { $base = $cand; break }
		}
		if (-not $base) { Err 'error: no base ref (origin/HEAD, origin/main, origin/master all missing); pass -b <ref>'; exit 1 }
		Err "warn: no -b given; MERGED checks against $base"
	}

	# The base drives the merge check. The fetch is best-effort (stale is fine for
	# a first pass) and runs before the check, since -b may name a branch not
	# fetched yet. The explicit refspec creates it even in a single-branch clone.
	if ($base.StartsWith('origin/')) {
		$refspec = '+refs/heads/' + $base.Substring(7) + ':refs/remotes/' + $base
		[void](Run git fetch origin $refspec --quiet)
		if ($script:rc -ne 0) { Err "warn: could not fetch $base; merged column may be stale" }
	}
	[void](Run git rev-parse --verify --quiet "${base}^{commit}")
	if ($script:rc -ne 0) { Err "error: base ref not found: $base"; exit 1 }

	# PR state by branch, fetched once as [{number, state, head}] with a lowercase
	# state. Origin when its CLI can read this repo's PRs, otherwise gh. Empty when
	# neither can.
	$prs = @()
	$raw = $null; $src = ''
	if (Find-Tool origin) {
		$raw = Run origin pr list --author '@me' --state all --limit 1000 --json 'number,status,headRef'
		if ($script:rc -eq 0) { $src = 'origin' }
	}
	if (-not $src) {
		$raw = Run gh pr list --author '@me' --state all --limit 1000 --json 'number,state,headRefName'
		if ($script:rc -eq 0) { $src = 'gh' }
	}
	if ($src) {
		try {
			$json = (@($raw) -join "`n")
			$parsed = ConvertFrom-Json -InputObject $json
			# 5.1 returns a JSON array as one array; 7 enumerates it.
			if ($json.TrimStart().StartsWith('[')) {
				$list = @()
				foreach ($p in @($parsed)) {
					if ($null -eq $p) { continue }
					if ($src -eq 'origin') {
						$list += [pscustomobject]@{ number = $p.number; state = $p.status; head = $p.headRef }
					} else {
						if (-not ($p.state -is [string])) { throw 'state is not a string' }
						$list += [pscustomobject]@{ number = $p.number; state = $p.state.ToLowerInvariant(); head = $p.headRefName }
					}
				}
				$prs = $list
			}
		} catch { $prs = @() }
	}
	function JqStr($v) {
		if ($null -eq $v) { return 'null' }
		if ($v -is [bool]) { if ($v) { return 'true' } else { return 'false' } }
		return [string]::Format($inv, '{0}', $v)
	}

	# Transcripts dir: $CLAUDE_CONFIG_DIR (default ~\.claude)\projects\<slugified-repo-path>.
	$cfg = [Environment]::GetEnvironmentVariable('CLAUDE_CONFIG_DIR')
	if (-not $cfg) { $cfg = Join-Path $HOME '.claude' }
	$slug = $mainWt -replace '[^A-Za-z0-9]', '-'
	$transcripts = [System.IO.Path]::Combine($cfg, 'projects', $slug)
	$now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()

	$rg = Find-Tool rg
	$jsonl = $null
	if ([System.IO.Directory]::Exists($transcripts)) {
		if ($rg) { $patFile = [System.IO.Path]::GetTempFileName() }
		else { $jsonl = @(Get-ChildItem -LiteralPath $transcripts -Recurse -File -Filter '*.jsonl' -ErrorAction SilentlyContinue) }
	}

	# Apparent size of a tree, not following junctions/symlinks (du -s skips them too).
	function Get-TreeBytes([string]$path) {
		if (-not [System.IO.Directory]::Exists($path)) { return [long]-1 }
		$root = $path
		if ($path -match '^[A-Za-z]:\\') { $root = '\\?\' + $path }
		elseif ($path -match '^\\\\[^?.]') { $root = '\\?\UNC\' + $path.Substring(2) }
		$total = [long]0
		$stack = New-Object 'System.Collections.Generic.Stack[string]'
		$stack.Push($root)
		while ($stack.Count -gt 0) {
			$d = $stack.Pop()
			try {
				foreach ($e in (New-Object System.IO.DirectoryInfo $d).EnumerateFileSystemInfos()) {
					if ($e -is [System.IO.DirectoryInfo]) {
						if (($e.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -eq 0) { $stack.Push($e.FullName) }
					} else { $total += $e.Length }
				}
			} catch { }
		}
		return $total
	}
	# du -h style: one decimal under 10, whole units above, 1024 steps.
	function Format-Size([long]$b) {
		if ($b -lt 0) { return '' }
		$units = 'B', 'K', 'M', 'G', 'T', 'P'
		$u = 0; $v = [double]$b
		while ($v -ge 1024 -and $u -lt 5) { $v = $v / 1024; $u++ }
		if ($u -eq 0) { return "${b}B" }
		if ($v -lt 9.95) { return $v.ToString('0.0', $inv) + $units[$u] }
		$r = [Math]::Round($v)
		if ($r -ge 1024 -and $u -lt 5) { return '1.0' + $units[$u + 1] }
		return $r.ToString('0', $inv) + $units[$u]
	}

	Write-Output "# base: $base"
	Write-Output "SIZE`tAGE`tMERGED`tDIRTY`tREMOTE`tPR`tLAST_CHAT`tBUCKET`tWORKTREE"

	$rows = @()
	foreach ($wt in $wtList) {
		if ($wt -eq $mainWt) { continue }

		$bytes = Get-TreeBytes $wt
		$size = Format-Size $bytes
		$head = First (Run git -C $wt rev-parse HEAD)
		$headTs = [long]0
		[void][long]::TryParse((First (Run git -C $wt log -1 --format=%ct HEAD)), [ref]$headTs)
		if ($headTs -gt 0) { $age = [string][long][Math]::Truncate(($now - $headTs) / 86400) + 'd' } else { $age = '?' }

		# Squash-merged branches are not ancestors of the base, so PR state is the
		# real signal; merge-base only catches fast-forward/rebase merges.
		$merged = 'no'
		if ($head) {
			[void](Run git merge-base --is-ancestor $head $base)
			if ($script:rc -eq 0) { $merged = 'YES' }
		}

		# Distinguish real WIP (tracked edits) from disposable untracked scratch.
		$porcelain = @(Run git -C $wt status --porcelain | Where-Object { $null -ne $_ })
		if ($porcelain.Count -eq 0) { $dirty = 'clean' }
		else {
			$tracked = @($porcelain | Where-Object { -not $_.StartsWith('??') }).Count
			if ($tracked -gt 0) { $dirty = "wip:$tracked" }
			else { $dirty = 'scratch:' + @($porcelain | Where-Object { $_.StartsWith('??') }).Count }
		}

		$branch = First (Run git -C $wt symbolic-ref --quiet --short HEAD)
		if ($script:rc -ne 0) { $branch = '' }
		if (-not $branch) { $remote = 'detached' }
		else {
			[void](Run git -C $wt show-ref --verify --quiet "refs/remotes/origin/${branch}")
			if ($script:rc -eq 0) {
				if ((First (Run git -C $wt rev-parse "origin/${branch}")) -ceq $head) { $remote = 'pushed' }
				else { $remote = 'ahead' + (First (Run git -C $wt rev-list --count "origin/${branch}..HEAD")) }
			} else { $remote = 'no-remote' }
		}

		$pr = '-'
		if ($branch) {
			foreach ($p in $prs) {
				if ($p.head -is [string] -and $p.head -ceq $branch) { $pr = '#' + (JqStr $p.number) + '/' + (JqStr $p.state); break }
			}
		}

		# Most recent chat whose transcript operated in this worktree. Match path
		# followed by a separator or a quote so glint-482 does not match glint-482-r37.
		$last = '-'; $lastTs = [long]0
		if ([System.IO.Directory]::Exists($transcripts)) {
			$fwd = $wt.Replace('\', '/'); $esc = $wt.Replace('\', '\\')
			$pats = @()
			foreach ($stem in @($wt, $fwd, $esc)) { foreach ($sep in @('/', '\', '"')) { $pats += $stem + $sep } }
			$pats = @($pats | Select-Object -Unique)
			$hits = @()
			if ($rg) {
				[System.IO.File]::WriteAllText($patFile, ($pats -join "`n") + "`n", (New-Object System.Text.UTF8Encoding $false))
				$hits = @(Run rg -l -F -i --no-messages -g '*.jsonl' -f $patFile '--' $transcripts | Where-Object { $_ } | ForEach-Object { New-Object System.IO.FileInfo $_ })
			} else {
				foreach ($f in $jsonl) {
					if (Select-String -LiteralPath $f.FullName -Pattern $pats -SimpleMatch -List -Encoding UTF8 -ErrorAction SilentlyContinue) { $hits += $f }
				}
			}
			$newest = $hits | Where-Object { $_.Exists } | Sort-Object LastWriteTimeUtc -Descending | Select-Object -First 1
			if ($newest) {
				$lastTs = (New-Object DateTimeOffset $newest.LastWriteTimeUtc).ToUnixTimeSeconds()
				$last = $newest.LastWriteTime.ToString('yyyy-MM-dd', $inv)
			}
		}
		$recent = 'no'
		if ($lastTs -gt 0 -and [long][Math]::Truncate(($now - $lastTs) / 86400) -le 4) { $recent = 'yes' }

		if ($dirty -clike 'wip:*') { $bucket = 'hold-wip' }
		elseif ($pr -clike '*/open' -or $pr -clike '*/draft') { $bucket = 'hold-open-pr' }
		elseif ($recent -eq 'yes') { $bucket = 'verify-recent-chat' }
		elseif ($merged -ceq 'YES' -or $pr -ne '-') { $bucket = 'safe' }
		else { $bucket = 'review' }

		$line = @($size, $age, $merged, $dirty, $remote, $pr, $last, $bucket, $wt) -join "`t"
		$rows += [pscustomobject]@{ Bytes = $bytes; Line = $line }
	}
	$rows | Sort-Object -Property @{ Expression = 'Bytes'; Descending = $true }, @{ Expression = 'Line'; Descending = $true } |
		ForEach-Object { Write-Output $_.Line }
} finally {
	if ($patFile) { try { [System.IO.File]::Delete($patFile) } catch { } }
	if ($pushed) { Pop-Location }
	if ($null -ne $prevOutEnc) { try { [Console]::OutputEncoding = $prevOutEnc } catch { } }
}
exit 0
