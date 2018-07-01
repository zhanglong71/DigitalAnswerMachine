:123

DEL *.hex
DEL *.bin

sdspccv2541.exe M68_D22.asm MAIN_DEV.obj MAIN_DEV.lst -e -t1
sdspccv2541.exe f_init.asm f_init.obj f_init.lst -e -t1
rem sdspccv2541.exe f_midi.asm f_midi.obj f_midi.lst -e -t1
sdspccv2541.exe f_answer.asm f_answer.obj f_answer.lst -e -t1
sdspccv2541.exe f_remote.asm f_remote.obj f_remote.lst -e -t1
sdspccv2541.exe f_localplay.asm f_localplay.obj f_localplay.lst -e -t1
sdspccv2541.exe f_localrec.asm f_localrec.obj f_localrec.lst -e -t1
sdspccv2541.exe f_localtwr.asm f_localtwr.obj f_localtwr.lst -e -t1
sdspccv2541.exe f_menu.asm f_menu.obj f_menu.lst -e -t1
sdspccv2541.exe f_phone.asm f_phone.obj f_phone.lst -e -t1
sdspccv2541.exe f_tmode.asm f_tmode.obj f_tmode.lst -e -t1
sdspccv2541.exe f_reccid.asm f_reccid.obj f_reccid.lst -e -t1
sdspccv2541.exe f_findtel.asm f_findtel.obj f_findtel.lst -e -t1

SDSPL.exe d22_080313V1.obj  -g0 MAIN_DEV.obj -g1 f_init.obj -g1 f_answer.obj -g1 f_remote.obj -g1 f_localplay.obj  -g1 f_localrec.obj  -g1 f_localtwr.obj -g1 f_menu.obj -g1 f_phone.obj  -g1 f_reccid.obj  -g1 f_findtel.obj  -g1 f_tmode.obj -b MAIN_DEV.obj -h MAIN_DEV.hex -m1  > MAIN_DEV.lrr
SDSPL.exe d22_080313V1.obj  -g0 MAIN_DEV.obj -g1 f_init.obj -g1 f_answer.obj -g1 f_remote.obj -g1 f_localplay.obj  -g1 f_localrec.obj  -g1 f_localtwr.obj -g1 f_menu.obj -g1 f_phone.obj  -g1 f_reccid.obj  -g1 f_findtel.obj  -g1 f_tmode.obj -b MAIN_DEV.obj  -sbl -h M68-v3-.bin -m2

@rem CHKSUM M68_DEV.hex
pause

DEL _find_tmp
DEL *.ini
DEL *.lmf
DEL *.lrr
DEL *.map
DEL *.mem
DEL *.lst
DEL f_init.obj
DEL f_midi.obj
DEL f_answer.obj
DEL f_localplay.obj
DEL f_localrec.obj
DEL f_localtwr.obj
DEL f_menu.obj
DEL f_phone.obj
DEL f_reccid.obj
DEL f_findtel.obj
DEL f_remote.obj
DEL f_tmode.obj
DEL MAIN_DEV.obj
DEL mipsinfo.txt

rem goto 123