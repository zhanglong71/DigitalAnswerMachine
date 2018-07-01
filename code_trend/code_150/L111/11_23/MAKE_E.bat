:abc
@echo on

del DSC-150.bin

Dspa2523.exe key_det.asm keyscan.obj keyscan.lst

Dspa2523.exe ring_det.asm ring.obj ring.lst

Dspa2523.exe ser_com.asm ser_com.obj ser_com.lst

Dspa2523.exe DSC_150.asm obj.obj DSC-150.lst

Dspl2523.exe obj.OBJ ser_com.obj ring.obj keyscan.obj 1000WORD.OBJ -h DSC-150.bin -m2
@echo off

xcopy DSC-150.bin z:\DSC-150.BIN /y

pause

del obj.obj
del DSC-150.lst
del ser_com.obj
del ser_com.lst
del keyscan.obj
del keyscan.lst
del ring.obj
del ring.lst
del *.MAP

rem goto abc