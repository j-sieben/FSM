@echo off
setlocal

rem Rebuild the Natural Docs output for this repository on Windows.
rem Optional override:
rem   set NATURALDOCS_EXE=C:\Path\To\NaturalDocs.exe

set "SCRIPT_DIR=%~dp0"
set "REPO_ROOT=%SCRIPT_DIR:~0,-1%"
set "PROJECT_DIR=%REPO_ROOT%\ND"
set "PROJECT_FILE=%PROJECT_DIR%\Project.txt"

if not exist "%PROJECT_FILE%" (
  echo [ERROR] Natural Docs project file not found: "%PROJECT_FILE%"
  exit /b 1
)

if defined NATURALDOCS_EXE (
  set "ND_EXE=%NATURALDOCS_EXE%"
) else if exist "C:\Program Files\Natural Docs\NaturalDocs.exe" (
  set "ND_EXE=C:\Program Files\Natural Docs\NaturalDocs.exe"
) else if exist "C:\Program Files (x86)\Natural Docs\NaturalDocs.exe" (
  set "ND_EXE=C:\Program Files (x86)\Natural Docs\NaturalDocs.exe"
) else (
  set "ND_EXE=NaturalDocs.exe"
)

if /i "%ND_EXE%"=="NaturalDocs.exe" (
  where /q NaturalDocs.exe
  if errorlevel 1 (
    echo [ERROR] NaturalDocs executable not found.
    echo         Set NATURALDOCS_EXE or install Natural Docs in the default path.
    exit /b 2
  )
) else (
  if not exist "%ND_EXE%" (
    echo [ERROR] NaturalDocs executable not found: "%ND_EXE%"
    exit /b 2
  )
)

echo Rebuilding Natural Docs for "%REPO_ROOT%"...
"%ND_EXE%" -p "%PROJECT_DIR%" -r
if errorlevel 1 (
  echo [ERROR] Natural Docs rebuild failed.
  exit /b 3
)

echo Documentation rebuilt successfully.
echo Open "%REPO_ROOT%\Doc\index.html" to review the result.
exit /b 0
