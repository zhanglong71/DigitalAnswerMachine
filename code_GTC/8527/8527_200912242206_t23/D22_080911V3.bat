:123

DEL *.hex
DEL *.bin

set MAIN=MAIN_DEV
set BIOS=D22_080911V3.obj
set COMP=sdspccv2541.exe
set LINK=SDSPL.exe
set VERSION=23

%COMP% 	 GTC_D22.asm %MAIN%.obj %MAIN%.lst -e -t1
%COMP%	 f_initdsp.asm f_initdsp.obj f_initdsp.lst -e -t1
%COMP%	 f_initmcu.asm f_initmcu.obj f_initmcu.lst -e -t1
%COMP%	 f_IdleComm.asm f_IdleComm.obj f_IdleComm.lst -e -t1
%COMP%	 f_answer.asm f_answer.obj f_answer.lst -e -t1
%COMP%	 f_lply.asm f_lply.obj f_lply.lst -e -t1
%COMP%	 f_lvop.asm f_lvop.obj f_lvop.lst -e -t1
%COMP%	 f_lrec.asm f_lrec.obj f_lrec.lst -e -t1
%COMP%	 f_logm.asm f_logm.obj f_logm.lst -e -t1
%COMP%	 f_phone.asm f_phone.obj f_phone.lst -e -t1
%COMP%	 f_remote.asm f_remote.obj f_remote.lst -e -t1

%COMP%	 f_tmode.asm f_tmode.obj f_tmode.lst -e -t1
%COMP%	 fs_cpc.asm fs_cpc.obj fs_cpc.lst -e -t1

%LINK% %BIOS% -g0 %MAIN%.obj -g11 f_initdsp.obj -g11 f_initmcu.obj -g11 f_lply.obj -g11 f_lvop.obj  -g11 f_lrec.obj  -g11 f_logm.obj  -g11 f_tmode.obj -g11 f_IdleComm.obj -g11 fs_cpc.obj  -g12 f_answer.obj -g12 f_remote.obj -g12 f_phone.obj -b %MAIN%.obj -h %MAIN%.hex -m1  > %MAIN%.lrr
%LINK% %BIOS% -g0 %MAIN%.obj -g11 f_initdsp.obj -g11 f_initmcu.obj -g11 f_lply.obj -g11 f_lvop.obj  -g11 f_lrec.obj  -g11 f_logm.obj  -g11 f_tmode.obj -g11 f_IdleComm.obj -g11 fs_cpc.obj  -g12 f_answer.obj -g12 f_remote.obj -g12 f_phone.obj -b %MAIN%.obj  -sbl -h 9527-v%VERSION%-.bin -m2

@rem CHKSUM GTC_DEV.hex
pause

DEL _find_tmp
DEL *.ini
DEL *.lmf
DEL *.lrr
DEL *.map
DEL *.mem
DEL *.lst
DEL f_initdsp.obj
DEL f_initmcu.obj
DEL f_IdleComm.obj
DEL f_answer.obj
DEL f_remote.obj
DEL f_rmtply.obj
DEL f_lply.obj
DEL f_lvop.obj
DEL f_lrec.obj
DEL f_logm.obj
DEL f_menu.obj
DEL f_phone.obj
DEL f_tmode.obj
DEL fs_cpc.obj
DEL MAIN_DEV.obj
DEL mipsinfo.txt

rem goto 123