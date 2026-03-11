@echo off
REM ======================================
REM ResourceBarText One-Shot Deploy Script
REM ======================================

REM Project root (parent of scripts/)
set "SOURCE=%~dp0.."

call "%~dp0config.bat"

echo Deploying ResourceBarText from %SOURCE% to %TARGET%...
robocopy "%SOURCE%" "%TARGET%" /MIR /XD ".git" "scripts" /XF "CLAUDE.md" ".gitignore" ".pkgmeta" /NFL /NDL /NJH /NJS /nc /ns /np
echo Deployment complete!
