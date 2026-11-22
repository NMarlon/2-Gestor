@echo off
setlocal
rem Abre o Reconhecedor de Rostos. Se a API nao estiver no ar, sobe ela antes.
rem Atencao: a pasta do projeto tem DOIS espacos entre "de" e "Imagens".
set "PROJ=C:\MarlonScripts\1-Mini-Projetos\Reconhecedor de Rostos de  Imagens"
set "URL=http://127.0.0.1:8011/"

rem Sonda por TCP: nao depende de curl nem de arquivo temporario.
powershell -NoProfile -Command "try{$c=New-Object Net.Sockets.TcpClient;$c.Connect('127.0.0.1',8011);$c.Close();exit 0}catch{exit 1}" >nul 2>&1
if %errorlevel%==0 goto abrir

if not exist "%PROJ%\.venv\Scripts\python.exe" (
  echo Nao achei o Python do projeto em:
  echo   %PROJ%\.venv\Scripts\python.exe
  pause
  exit /b 1
)

echo Subindo a API em %URL% ...
start "Reconhecedor API" /min cmd /c "cd /d ""%PROJ%"" && .venv\Scripts\python.exe -m uvicorn app.main:app --host 127.0.0.1 --port 8011"

for /l %%i in (1,1,40) do (
  powershell -NoProfile -Command "try{$c=New-Object Net.Sockets.TcpClient;$c.Connect('127.0.0.1',8011);$c.Close();exit 0}catch{exit 1}" >nul 2>&1
  if not errorlevel 1 goto abrir
  timeout /t 1 >nul
)

echo A API nao respondeu em 40s. Veja a janela "Reconhecedor API".
pause
exit /b 1

:abrir
start "" "%URL%"
exit /b 0
