:123


sdspccv2541.exe D20.asm MAIN_DEV.obj MAIN_DEV.lst -e -t1
sdspccv2541.exe f_answer.asm f_answer.obj f_answer.lst -e -t1
sdspccv2541.exe f_localplay.asm f_localplay.obj f_localplay.lst -e -t1
sdspccv2541.exe f_menu.asm f_menu.obj f_menu.lst -e -t1
sdspccv2541.exe f_tmode.asm f_tmode.obj f_tmode.lst -e -t1


sdsplcv2541.exe D20_070509V1.obj -g0 MAIN_DEV.obj -g1 f_answer.obj -g1 f_localplay.obj -g1 f_menu.obj  -g1 f_tmode.obj -b MAIN_DEV.obj -h R52.hex -m1
sdsplcv2541.exe D20_070509V1.obj -g0 MAIN_DEV.obj -g1 f_answer.obj -g1 f_localplay.obj -g1 f_menu.obj  -g1 f_tmode.obj -b MAIN_DEV.obj -h R52.bin -m2

pause
CHKSUM R52.bin

xcopy R52.bin z:\R52.bin /y
pause

DEL _fine_tmp
DEL *.lmf
DEL *.map
DEL *.mem
DEL *.lst
DEL f_answer.obj
DEL f_localplay.obj
DEL f_menu.obj
DEL f_tmode.obj
DEL MAIN_DEV.obj

rem goto 123