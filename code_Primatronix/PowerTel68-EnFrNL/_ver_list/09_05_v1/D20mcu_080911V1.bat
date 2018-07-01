:123

DEL *.hex
DEL *.bin


set MAIN=MAIN_DEV
set BIOS=D20mcu_080911V1.obj
set COMP=sdspccv2541.exe
set LINK=SDSPL.exe
set VERSION=1


%COMP% R52_D20.asm %MAIN%.obj %MAIN%.lst -e -t1
%COMP% f_answer.asm f_answer.obj f_answer.lst -e -t1
%COMP% f_remote.asm f_remote.obj f_remote.lst -e -t1
%COMP% f_localplay.asm f_localplay.obj f_localplay.lst -e -t1
%COMP% f_menu.asm f_menu.obj f_menu.lst -e -t1
%COMP% f_tmode.asm f_tmode.obj f_tmode.lst -e -t1


rem pause
rem CHKSUM PowerTel68.bin
%LINK% %BIOS% -g0 %MAIN%.obj -g1 f_answer.obj -g1 f_remote.obj -g1 f_localplay.obj -g1 f_menu.obj  -g1 f_tmode.obj -b %MAIN%.obj -h %MAIN%.hex -m1  > R52D20.lrr
%LINK% %BIOS% -g0 %MAIN%.obj -g1 f_answer.obj -g1 f_remote.obj -g1 f_localplay.obj -g1 f_menu.obj  -g1 f_tmode.obj -b %MAIN%.obj -h PowerTel68-EnFrNL-v%VERSION%.bin -m2


pause

DEL *.ini
DEL *.lmf
DEL *.map
DEL *.mem
DEL *.lrr
DEL *.lst
DEL f_answer.obj
DEL f_remote.obj
DEL f_localplay.obj
DEL f_menu.obj
DEL f_tmode.obj
DEL MAIN_DEV.obj
DEL _find_tmp

rem goto 123