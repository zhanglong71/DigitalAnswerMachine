:123

DEL *.hex
DEL *.bin

sdspccv2541.exe D20.asm MAIN_DEV.obj MAIN_DEV.lst -e -t1

SDSPL.exe MAIN_DEV.obj D20_070315V1.obj -h MAIN_DEV.hex -m1  > DSC150.lrr
SDSPL.exe MAIN_DEV.obj D20_070315V1.obj -h IIC-host.bin -m2

pause

del MAIN_DEV.obj
del _find_tmp

DEL *.ini
DEL *.lmf
DEL *.lrr
DEL *.map
DEL *.mem
DEL *.lst


rem goto 123