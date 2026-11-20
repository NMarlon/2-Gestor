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
  [string]$Agent,
  [switch]$NoAuto,
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

$args = @('run')
if (-not $NoAuto) { $args += '--auto' }
if ($Agent) { $args += @('--agent', $Agent) }
$args += '--archived'
if ($Standalone) { $args += '--standalone' }
if ($PrintLogs) { $args += '--print-logs' }
$args += $prompt

Push-Location -LiteralPath $Dir
# O opencode-cli resolve o cwd por $env:PWD. Vindo do bash/MSYS ele chega como
# /c/... e o binario nativo falha em "change directory". Normalizamos.
$env:PWD = (Get-Location).ProviderPath
$env:OLDPWD = $env:PWD
# PATH do processo pai pode ter o git do WindowsApps (MSIX) na frente; esse
# binario nega execucao fora do package ("Acesso negado"), quebrando qualquer
# comando git do agente. Colocamos o Git for Windows real na frente do PATH.
$gitCmd = 'C:\Program Files\Git\cmd'
if (Test-Path -LiteralPath (Join-Path $gitCmd 'git.exe')) {
  $env:PATH = $gitCmd + ';' + (($env:PATH -split ';' | Where-Object { $_ -and $_ -notlike '*WindowsApps*HermesAgent*\git*' }) -join ';')
}
try {
  Write-Host "[oc-brief] exe=$exe"
  Write-Host "[oc-brief] dir=$Dir"
  Write-Host "[oc-brief] brief=$Brief ($($prompt.Length) chars)"
  Write-Host "[oc-brief] log=$LogPath"
  Write-Host '[oc-brief] ---- inicio da resposta do OpenCode ----'
  # stderr vai para arquivo temporario: com 2>&1 o PowerShell 5.1 transforma
  # cada linha de stderr em ErrorRecord e, com ErrorActionPreference=Stop, aborta
  # o pipeline inteiro (NativeCommandError). Isso matava o canal sem log.
  $errFile = [System.IO.Path]::GetTempFileName()
  # PS 5.1 tambem dispara NativeCommandError mesmo com 2> arquivo quando
  # ErrorActionPreference=Stop. Suspende o Stop so durante a chamada nativa.
  $prevEap = $ErrorActionPreference
  # SilentlyContinue durante a chamada nativa: o PS 5.1 transforma cada linha
  # que o CLI escreve em stderr em um bloco "NativeCommandError" no console. O
  # stderr continua indo para $errFile e para o log, entao nada se perde.
  $ErrorActionPreference = 'SilentlyContinue'
  # Tee-Object do PS 5.1 nao tem -Encoding e grava UTF-16 (grep ve bytes nulos).
  # StreamWriter em UTF-8 sem BOM: log legivel e ainda transmite ao vivo.
  $sw = New-Object System.IO.StreamWriter($LogPath, $true, (New-Object System.Text.UTF8Encoding($false)))
  $sw.AutoFlush = $true
  try {
    & $exe @args 2> $errFile | ForEach-Object { $sw.WriteLine($_); Write-Output $_ }
    $code = $LASTEXITCODE
    $errText = Get-Content -LiteralPath $errFile -Raw -ErrorAction SilentlyContinue
    if ($errText) {
      Write-Host $errText
      $sw.WriteLine('---- stderr ----')
      $sw.WriteLine($errText)
    }
  }
  finally {
    $sw.Close()
    $ErrorActionPreference = $prevEap
    Remove-Item -LiteralPath $errFile -Force -ErrorAction SilentlyContinue
  }
  Write-Host '[oc-brief] ---- fim da resposta do OpenCode ----'
  Write-Host "[oc-brief] exit=$code"
  exit $code
}
finally {
  Pop-Location
}
