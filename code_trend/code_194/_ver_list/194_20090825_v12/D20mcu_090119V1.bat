:123


DEL *.bin

set MAIN=MAIN_DEV
set BIOS=D20mcu_090119V1.obj
set COMP=sdspccv2541.exe
set LINK=SDSPL.exe
set VERSION=12

%COMP%	D20_194.asm %MAIN%.obj %MAIN%.lst -e -t1
%COMP%	f_answer.asm f_answer.obj f_answer.lst -e -t1
%COMP%	f_init.asm f_init.obj f_init.lst -e -t1
%COMP%	f_play.asm f_play.obj f_play.lst -e -t1

%COMP%	f_menu1.asm f_menu1.obj f_menu1.lst -e -t1
%COMP%	f_menu2.asm f_menu2.obj f_menu2.lst -e -t1
%COMP%	f_menu3.asm f_menu3.obj f_menu3.lst -e -t1
%COMP%	f_menu4.asm f_menu4.obj f_menu4.lst -e -t1
%COMP%	f_menu5.asm f_menu5.obj f_menu5.lst -e -t1
%COMP%	f_menu6.asm f_menu6.obj f_menu6.lst -e -t1
%COMP%	f_menu7.asm f_menu7.obj f_menu7.lst -e -t1

%COMP%	f_book1.asm f_book1.obj f_book1.lst -e -t1
%COMP%	f_book2.asm f_book2.obj f_book2.lst -e -t1
%COMP%	f_book3.asm f_book3.obj f_book3.lst -e -t1
%COMP%	f_book4.asm f_book4.obj f_book4.lst -e -t1

%COMP%	f_cid.asm f_cid.obj f_cid.lst -e -t1
%COMP%	f_ogm.asm f_ogm.obj f_ogm.lst -e -t1
%COMP%	f_memo.asm f_memo.obj f_memo.lst -e -t1
%COMP%	f_fixf.asm f_fixf.obj f_fixf.lst -e -t1
%COMP%	f_2way.asm f_2way.obj f_2way.lst -e -t1
%COMP%	f_remote.asm f_remote.obj f_remote.lst -e -t1

%LINK%	%BIOS% -g0 MAIN_DEV.obj -g1 f_init.obj -g1 f_answer.obj -g1 f_play.obj -g1 f_menu1.obj -g1 f_menu2.obj -g1 f_menu3.obj -g1 f_menu4.obj -g1 f_menu5.obj -g1 f_menu6.obj -g1 f_menu7.obj  -g1 f_cid.obj  -g1 f_book1.obj -g1 f_book2.obj -g1 f_book3.obj -g1 f_book4.obj -g1 f_ogm.obj -g1 f_memo.obj -g1 f_2way.obj -g1 f_remote.obj -g1 f_fixf.obj -b MAIN_DEV.obj -h MAIN_DEV.hex -m1  > D201160.lrr
%LINK%	%BIOS% -g0 MAIN_DEV.obj -g1 f_init.obj -g1 f_answer.obj -g1 f_play.obj -g1 f_menu1.obj -g1 f_menu2.obj -g1 f_menu3.obj -g1 f_menu4.obj -g1 f_menu5.obj -g1 f_menu6.obj -g1 f_menu7.obj  -g1 f_cid.obj  -g1 f_book1.obj -g1 f_book2.obj -g1 f_book3.obj -g1 f_book4.obj -g1 f_ogm.obj -g1 f_memo.obj -g1 f_2way.obj -g1 f_remote.obj -g1 f_fixf.obj -b MAIN_DEV.obj -h thend194-v%VERSION%-.bin -m2

pause

DEL _find_tmp
DEL mipsinfo.txt
DEL *.hex
DEL *.ini
DEL *.lmf

DEL *.map
DEL *.mem
DEL *.lst
DEL *.lrr

DEL MAIN_DEV.obj
DEL f_init.obj
DEL f_answer.obj
DEL f_play.obj
DEL f_menu1.obj
DEL f_menu2.obj
DEL f_menu3.obj
DEL f_menu4.obj
DEL f_menu5.obj
DEL f_menu6.obj
DEL f_menu7.obj

DEL f_book1.obj
DEL f_book2.obj
DEL f_book3.obj
DEL f_book4.obj
DEL f_cid.obj
DEL f_ogm.obj
DEL f_memo.obj
DEL f_2way.obj
DEL f_remote.obj
DEL f_fixf.obj

rem pause
rem goto 123