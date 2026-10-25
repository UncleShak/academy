# Installs the Academy agents into the current project, or into ~/.claude with -Global.
# Re-run to update. Safe to run more than once.
param([switch]$Global)
$ErrorActionPreference = 'Stop'

$Repo   = if ($env:ACADEMY_REPO) { $env:ACADEMY_REPO } else { 'YOUR-USER/academy' }
$Ref    = if ($env:ACADEMY_REF)  { $env:ACADEMY_REF }  else { 'main' }
$Agents = 'aristotle', 'diogenes', 'thales', 'socrates'
$Utf8   = New-Object System.Text.UTF8Encoding($false)   # no BOM, so frontmatter parses

if ($Global) {
    $Scope = 'global'; $Base = Join-Path $HOME '.claude'
    $Memory = Join-Path $Base 'CLAUDE.md'; $Import = '@~/.claude/academy.md'
} else {
    $Scope = 'project'; $Base = '.claude'
    $Memory = 'CLAUDE.md'; $Import = '@.claude/academy.md'
}

function Get-FullPath($Path) { $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path) }

# Copy from a local clone if run from one, otherwise download from GitHub.
$SrcDir = if ($PSScriptRoot -and (Test-Path (Join-Path $PSScriptRoot 'academy.md'))) { $PSScriptRoot } else { $null }
function Get-AcademyFile($Path, $Dest) {
    if ($SrcDir) { Copy-Item (Join-Path $SrcDir $Path) $Dest -Force }
    else { Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/$Repo/$Ref/$Path" -OutFile $Dest }
}
function Add-LineOnce($File, $Line) {
    $full = Get-FullPath $File
    $text = if (Test-Path $full) { [IO.File]::ReadAllText($full) } else { '' }
    if (($text -split "`r?`n") -contains $Line) { return }
    if ($text.Length -and -not $text.EndsWith("`n")) { $text += "`n" }
    [IO.File]::WriteAllText($full, $text + $Line + "`n", $Utf8)
}

New-Item -ItemType Directory -Force (Join-Path $Base 'agents') | Out-Null
foreach ($a in $Agents) { Get-AcademyFile "agents/$a.md" (Join-Path $Base "agents/$a.md") }
Get-AcademyFile 'academy.md' (Join-Path $Base 'academy.md')

# Claude Code reads CLAUDE.md, not AGENTS.md; import both.
if (-not $Global -and -not (Test-Path $Memory) -and (Test-Path 'AGENTS.md')) { Add-LineOnce $Memory '@AGENTS.md' }
Add-LineOnce $Memory $Import

# Keep the noticeboard out of git.
if (-not $Global -and ((Test-Path '.git') -or (Test-Path '.gitignore'))) { Add-LineOnce '.gitignore' '.claude/agora.md' }

Write-Host "Academy installed ($Scope): $($Agents -join ', ')"
Write-Host 'Start Claude Code as Plato with: claude --model opus'
