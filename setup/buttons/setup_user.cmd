@echo off
setlocal

set "configFile=.\setup\config.txt"

set "installDir="
for /f "usebackq delims=" %%a in ("%configFile%") do (
    set "installDir=%%a"
)

set "tempDir=C:\temp"
set "bocchiDir=%installDir%\BocchiBot"
set "dataDir=.\setup\data"
set "byUserDir=.\setup\user"

echo Installing Chocolatey...

:check_choco
where choco >nul 2>nul
if %errorlevel% neq 0 (
    start ""  /wait /i .\setup\chocolatey-2.2.2.0.msi /quiet /norestart
    goto check_choco_done
)

:check_choco_done
echo Chocolatey installation complete!

echo Installing Node.js...

if exist "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" (
    powershell -Command "Start-Process 'cmd' -Verb RunAs -ArgumentList '/c choco install nodejs-lts -y'"
) else (
    runas /user:Administrator "cmd /c choco install nodejs-lts -y"
)

:check_node
where node >nul 2>nul
if %errorlevel% neq 0 (
    timeout /t 1 /nobreak >nul
    goto check_node
)

echo Node.js installation complete!

echo Installing Git...

if exist "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" (
    powershell -Command "Start-Process 'cmd' -Verb RunAs -ArgumentList '/c choco install git -y'"
) else (
    runas /user:Administrator "cmd /c choco install git -y"
)

:check_git
where git >nul 2>nul
if %errorlevel% neq 0 (
    timeout /t 1 /nobreak >nul
    goto check_git
)

echo Git installation complete!

echo Dependencies installed successfully!

echo Cloning Git repository...
git clone https://github.com/SlavyanDesu/BocchiBot.git "C:\temp\BocchiBot"

echo Copy data...
xcopy /E /I /Y /S /H "%tempDir%\*" "%installDir%"
rmdir /s /q "%tempDir%"

xcopy /I /Y ".\setup\config.txt" "%installDir%"
xcopy /E /I /Y /S "%dataDir%" "%installDir%"
xcopy /E /I /Y /S "%byUserDir%" "%bocchiDir%"

del /f /q "%bocchiDir%\function\quizizz.js"
del /f /q "%bocchiDir%\lib\downloader.js"
del /f /q "%bocchiDir%\message\text\lang\ind.js"

if exist "%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" (
    powershell -Command "Start-Process 'cmd' -Verb RunAs -ArgumentList '/c call \"%installDir%\install.cmd\"'"
) else (
    runas /user:Administrator "cmd /c call \"%installDir%\install.cmd\""
)
