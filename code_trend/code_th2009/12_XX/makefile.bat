:123

DEL thD20_DEV.hex
DEL thD20-v.bin

sdspccv2541.exe th_D20.asm MAIN_DEV.obj MAIN_DEV.lst -e -t1
sdspccv2541.exe f_answer.asm f_answer.obj f_answer.lst -e -t1
sdspccv2541.exe f_localplay.asm f_localplay.obj f_localplay.lst -e -t1
sdspccv2541.exe f_menu.asm f_menu.obj f_menu.lst -e -t1
sdspccv2541.exe f_tmode.asm f_tmode.obj f_tmode.lst -e -t1

SDSPL.exe D20_070919V1.obj -g0 MAIN_DEV.obj -g1 f_answer.obj -g1 f_localplay.obj -g1 f_menu.obj  -g1 f_tmode.obj -b MAIN_DEV.obj -h thD20_DEV.hex -m1  > thD20.lrr
SDSPL.exe D20_070919V1.obj -g0 MAIN_DEV.obj -g1 f_answer.obj -g1 f_localplay.obj -g1 f_menu.obj  -g1 f_tmode.obj -b MAIN_DEV.obj -h thD20-v.bin -m2
rem pause
rem CHKSUM thD20_DEV.hex 

REM xcopy thD20.bin z:\thD20.bin /y
pause

DEL _find_tmp
DEL mipsinfo.txt
DEL *.ini
DEL *.lmf
DEL *.lrr
DEL *.map
DEL *.mem
DEL *.lst
DEL f_answer.obj
DEL f_localplay.obj
DEL f_menu.obj
DEL f_tmode.obj
DEL MAIN_DEV.obj

rem goto 123