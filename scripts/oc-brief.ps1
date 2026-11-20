<#
  oc-brief.ps1 — canal oficial gestor -> OpenCode.

  Uso:
    powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\oc-brief.ps1 `
      -Dir "C:\MarlonScripts\1-Mini-Projetos\Hermes-Mobile" `
      -Brief ".\briefs\2026-11-20-mono-hermes.md"

  - Le o brief de um arquivo UTF-8 (evita inferno de quoting).
  - Resolve a versao mais nova de opencode-cli.exe sozinho.
  - Sessao arquivada: nao polui a lista de sessoes do usuario.
  - stdout vai para o console E para -LogPath (default: <Dir>\logs\oc-<timestamp>.log).
#>
param(
  [Parameter(Mandatory = $true)][string]$Dir,
  [Parameter(Mandatory = $true)][string]$Brief,
  [string]$LogPath,
  [switch]$Standalone,
  [switch]$PrintLogs
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $Dir)) { throw "Diretorio inexistente: $Dir" }
if (-not (Test-Path -LiteralPath $Brief)) { throw "Brief inexistente: $Brief" }

$cliRoot = Join-Path $env:APPDATA 'ai.opencode.desktop\cli'
$exe = Get-ChildItem -LiteralPath $cliRoot -Directory -ErrorAction SilentlyContinue |
  Sort-Object { [version]($_.Name -replace '[^0-9.].*$', '') } -Descending |
  ForEach-Object { Join-Path $_.FullName 'opencode-cli.exe' } |
  Where-Object { Test-Path -LiteralPath $_ } |
  Select-Object -First 1
if (-not $exe) { throw "opencode-cli.exe nao encontrado em $cliRoot" }

$prompt = Get-Content -LiteralPath $Brief -Raw -Encoding UTF8
if ([string]::IsNullOrWhiteSpace($prompt)) { throw "Brief vazio: $Brief" }

if (-not $LogPath) {
  $logDir = Join-Path $Dir 'logs'
  if (-not (Test-Path -LiteralPath $logDir)) { New-Item -ItemType Directory -Path $logDir | Out-Null }
  $LogPath = Join-Path $logDir ("oc-" + (Get-Date -Format 'yyyyMMdd-HHmmss') + ".log")
}

$args = @('run', '--auto', '--archived')
if ($Standalone) { $args += '--standalone' }
if ($PrintLogs) { $args += '--print-logs' }
$args += $prompt

Push-Location -LiteralPath $Dir
# O opencode-cli resolve o cwd por $env:PWD. Vindo do bash/MSYS ele chega como
# /c/... e o binario nativo falha em "change directory". Normalizamos.
$env:PWD = (Get-Location).ProviderPath
$env:OLDPWD = $env:PWD
try {
  Write-Host "[oc-brief] exe=$exe"
  Write-Host "[oc-brief] dir=$Dir"
  Write-Host "[oc-brief] brief=$Brief ($($prompt.Length) chars)"
  Write-Host "[oc-brief] log=$LogPath"
  Write-Host '[oc-brief] ---- inicio da resposta do OpenCode ----'
  & $exe @args 2>&1 | Tee-Object -FilePath $LogPath
  $code = $LASTEXITCODE
  Write-Host '[oc-brief] ---- fim da resposta do OpenCode ----'
  Write-Host "[oc-brief] exit=$code"
  exit $code
}
finally {
  Pop-Location
}
