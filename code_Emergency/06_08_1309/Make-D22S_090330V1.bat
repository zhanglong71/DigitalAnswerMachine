:123


DEL *.bin

set MAIN=MAIN_DEV
set BIOS=D22S_090330V1.obj
set COMP=sdspccv2541_090601.exe
set LINK=sdsplcv2541_080918.exe
set VERSION=1

%COMP% 	 916cr_D22.asm %MAIN%.obj %MAIN%.lst -e -t1
%COMP%	 f_initdsp.asm f_initdsp.obj f_initdsp.lst -e -t1
%COMP%	 f_IdleComm.asm f_IdleComm.obj f_IdleComm.lst -e -t1
%COMP%	 f_answer.asm f_answer.obj f_answer.lst -e -t1
%COMP%	 f_lply.asm f_lply.obj f_lply.lst -e -t1
%COMP%	 f_lcid.asm f_lcid.obj f_lcid.lst -e -t1
%COMP%	 f_lrec.asm f_lrec.obj f_lrec.lst -e -t1
%COMP%	 f_logm.asm f_logm.obj f_logm.lst -e -t1
%COMP%	 f_phone.asm f_phone.obj f_phone.lst -e -t1
%COMP%	 f_remote.asm f_remote.obj f_remote.lst -e -t1

%COMP%	 f_tmode.asm f_tmode.obj f_tmode.lst -e -t1
%COMP%	 fs_cpc.asm fs_cpc.obj fs_cpc.lst -e -t1

%LINK% %BIOS% -g0 %MAIN%.obj -g11 f_initdsp.obj -g11 f_lply.obj -g11 f_lcid.obj  -g11 f_lrec.obj  -g11 f_logm.obj  -g11 f_tmode.obj -g11 f_IdleComm.obj -g11 fs_cpc.obj  -g12 f_answer.obj -g12 f_remote.obj -g12 f_phone.obj -b %MAIN%.obj -h %MAIN%.hex -m1
@rem CHKSUM.EXE %MAIN%.hex
pause

%LINK% %BIOS% -g0 %MAIN%.obj -g11 f_initdsp.obj -g11 f_lply.obj -g11 f_lcid.obj  -g11 f_lrec.obj  -g11 f_logm.obj  -g11 f_tmode.obj -g11 f_IdleComm.obj -g11 fs_cpc.obj  -g12 f_answer.obj -g12 f_remote.obj -g12 f_phone.obj -b %MAIN%.obj  -sbl -h 916cr-v%VERSION%-.bin -m2  > %MAIN%.lrr


DEL _find_tmp
DEL *.hex
DEL *.ini
DEL *.lmf
DEL *.lrr
DEL *.map
DEL *.mem
DEL *.lst
DEL *.tmp
DEL f_initdsp.obj
DEL f_initmcu.obj
DEL f_IdleComm.obj
DEL f_answer.obj
DEL f_remote.obj
DEL f_rmtply.obj
DEL f_lply.obj
DEL f_lvop.obj
DEL f_lrec.obj
DEL f_lcid.obj
DEL f_logm.obj
DEL f_menu.obj
DEL f_phone.obj
DEL f_tmode.obj
DEL fs_cpc.obj
DEL MAIN_DEV.obj
DEL mipsinfo.txt


rem goto 123