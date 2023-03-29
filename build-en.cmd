@echo off
echo Assembling...
rgbds\rgbasm -h -L -vo -v -o kof96e.o config-en.asm
if %ERRORLEVEL% neq 0 goto assemble_fail

echo Linking...
rgbds\rgblink -m kof96e.map -n kof96e.sym -d -o kof96e.gb kof96e.o
if %ERRORLEVEL% neq 0 goto link_fail

echo ==========================
echo   Build Success.
echo ==========================
echo Fixing header checksum...
rgbds\rgbfix -v kof96e.gb
if EXIST original_en.gb ( fc /B kof96e.gb original_en.gb | more )

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