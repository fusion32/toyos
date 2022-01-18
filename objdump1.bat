@REM Don't rename this to objdump.bat or it won't work.

objdump -D -b binary -mi386 -Maddr16,data16 bin/setup.bin
