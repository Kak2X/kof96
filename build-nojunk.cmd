@echo off
echo Assembling...
rgbds\rgbasm -h -L -vo -v -o kof96.o config-nojunk.asm
if %ERRORLEVEL% neq 0 goto assemble_fail

echo Linking...
rgbds\rgblink -m kof96.map -n kof96.sym -d -o kof96.gb kof96.o
if %ERRORLEVEL% neq 0 goto link_fail

echo ==========================
echo   Build Success.
echo ==========================
echo Fixing header checksum...
rgbds\rgbfix -v kof96.gb

goto end

:assemble_fail
echo Error while assembling.
goto fail
:link_fail
echo Error while linking.
:fail

echo ==========================
echo   Build failure.
echo ==========================

:end
pause