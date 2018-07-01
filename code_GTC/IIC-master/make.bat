:123

DEL MAIN_DEV.hex
DEL IIC-host.hex

sdspccv2541.exe D20.asm MAIN_DEV.obj MAIN_DEV.lst -e -t1

sdsplcv2541.exe MAIN_DEV.obj D20_070315V1.obj -h MAIN_DEV.hex -k9 -m1 -d

sdsplcv2541.exe MAIN_DEV.obj D20_070315V1.obj -h IIC-host.hex -k9 -m1

del MAIN_DEV.obj
del _find_tmp

DEL *.ini
DEL *.lmf
DEL *.lrr
DEL *.map
DEL *.mem
DEL *.lst

pause
rem goto 123