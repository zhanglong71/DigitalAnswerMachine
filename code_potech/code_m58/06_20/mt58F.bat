:abc
Dspa2523.exe mt58.asm obj.OBJ MX93L111.LST
Dspl2523.exe obj.OBJ -m2

@echo off
del obj.obj
del out.map

xcopy out.bin z:\M58.BIN /y

pause
REM goto abc