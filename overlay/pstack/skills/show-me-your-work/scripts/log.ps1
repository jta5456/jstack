# Windows PowerShell twin of log.sh (pstack, Lauren Tan). Same arguments and output.
# Append a well-formed row to a show-me-your-work decision log (TSV).
# Usage: log.ps1 <logfile> <phase> <decision> <why> <evidence> <result>
Set-StrictMode -Version 1
$ErrorActionPreference = 'Stop'

$argv = @($args)
if ($argv.Count -ne 6) {
	[Console]::Error.WriteLine('usage: log.ps1 <logfile> <phase> <decision> <why> <evidence> <result>')
	exit 1
}

$utf8 = New-Object System.Text.UTF8Encoding $false

# One write call per line, appended at end of file. AppendData-only access makes
# Windows place every write at EOF (O_APPEND); PowerShell 7 lacks that
# constructor, so it falls back to FileMode.Append.
function Add-Line([string]$path, [string]$text) {
	$bytes = $utf8.GetBytes($text)
	$fs = $null
	try {
		$fs = New-Object System.IO.FileStream($path, [System.IO.FileMode]::Append,
			[System.Security.AccessControl.FileSystemRights]::AppendData,
			[System.IO.FileShare]::ReadWrite, 4096, [System.IO.FileOptions]::None)
	} catch {
		$fs = [System.IO.File]::Open($path, [System.IO.FileMode]::Append,
			[System.IO.FileAccess]::Write, [System.IO.FileShare]::ReadWrite)
	}
	try { $fs.Write($bytes, 0, $bytes.Length) } finally { $fs.Dispose() }
}

try {
	$logfile = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath([string]$argv[0])
	# Long-path form so .NET Framework does not stop at MAX_PATH (260).
	if ($logfile -match '^[A-Za-z]:\\') { $logfile = '\\?\' + $logfile }
	elseif ($logfile -match '^\\\\[^?.]') { $logfile = '\\?\UNC\' + $logfile.Substring(2) }

	$logdir = [System.IO.Path]::GetDirectoryName($logfile)
	if ($logdir -and -not [System.IO.Directory]::Exists($logdir)) {
		[void][System.IO.Directory]::CreateDirectory($logdir)
	}

	# Append here, never truncate. A network mount can fail this test for a log
	# that exists. Then the cost is one stray header line, not the rows.
	$fi = New-Object System.IO.FileInfo $logfile
	if (-not ($fi.Exists -and $fi.Length -gt 0)) {
		Add-Line $logfile "ts`tphase`tdecision`twhy`tevidence`tresult`n"
	}

	$ts = [DateTime]::UtcNow.ToString("yyyy-MM-dd'T'HH:mm:ss'Z'", [System.Globalization.CultureInfo]::InvariantCulture)
	# Strip tabs/newlines/CR so cells stay on one line, and prefix any cell
	# whose first char a spreadsheet would parse as a formula (=, +, -, @)
	# with a single quote. The skill expects this log to be read in
	# spreadsheets, so attacker-controlled evidence (PR titles, filenames,
	# generated text) must not become formula execution when a reviewer
	# opens the file.
	function Clean([string]$v) {
		$v = $v.Replace("`t", ' ').Replace("`n", ' ').Replace("`r", ' ')
		if ($v.Length -gt 0 -and '=+-@'.IndexOf($v[0]) -ge 0) { return "'" + $v }
		return $v
	}
	$cells = @($ts)
	foreach ($i in 1..5) { $cells += Clean ([string]$argv[$i]) }
	Add-Line $logfile (($cells -join "`t") + "`n")
} catch {
	[Console]::Error.WriteLine("log.ps1: " + $_.Exception.Message)
	exit 1
}
exit 0
