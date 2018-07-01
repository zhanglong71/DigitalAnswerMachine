:123

DEL *.hex
DEL *.bin
rem pause
sdspccv2541.exe GCT_D20.asm MAIN_DEV.obj MAIN_DEV.lst -e -t1
sdspccv2541.exe f_answer.asm f_answer.obj f_answer.lst -e -t1
sdspccv2541.exe f_remote.asm f_remote.obj f_remote.lst -e -t1
sdspccv2541.exe f_plynew.asm f_plynew.obj f_plynew.lst -e -t1
sdspccv2541.exe f_plyall.asm f_plyall.obj f_plyall.lst -e -t1
sdspccv2541.exe f_localrec.asm f_localrec.obj f_localrec.lst -e -t1
sdspccv2541.exe f_menu.asm f_menu.obj f_menu.lst -e -t1
sdspccv2541.exe f_tmode.asm f_tmode.obj f_tmode.lst -e -t1

SDSPL.exe D20mcu_080324V1.obj -g0 MAIN_DEV.obj -g1 f_answer.obj -g1 f_remote.obj -g1 f_plynew.obj -g1 f_plyall.obj -g1 f_localrec.obj -g1 f_menu.obj  -g1 f_tmode.obj -b MAIN_DEV.obj -h MAIN_DEV.hex -m1  > GCT_DEV.lrr
SDSPL.exe D20mcu_080324V1.obj -g0 MAIN_DEV.obj -g1 f_answer.obj -g1 f_remote.obj -g1 f_plynew.obj -g1 f_plyall.obj -g1 f_localrec.obj -g1 f_menu.obj  -g1 f_tmode.obj -b MAIN_DEV.obj  -sbl -h GCT-v0x- -m2

pause

DEL _find_tmp
DEL *.ini
DEL *.lmf
DEL *.lrr
DEL *.map
DEL *.mem
DEL *.lst
DEL f_answer.obj
DEL f_remote.obj
DEL f_localplay.obj
DEL f_plynew.obj
DEL f_plyall.obj
DEL f_localrec.obj
DEL f_menu.obj
DEL f_tmode.obj
DEL MAIN_DEV.obj
DEL mipsinfo.txt

rem goto 123