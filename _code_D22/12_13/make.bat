:123

sdspccv2541.exe D22.asm MAIN_DEV.obj MAIN_DEV.lst
sdspccv2541.exe f_menu.asm f_menu.obj f_menu.lst
sdspccv2541.exe f_answer.asm f_answer.obj f_answer.lst
sdspccv2541.exe f_localplay.asm f_localplay.obj f_localplay.lst
REM sdspccv2541.exe testmode.asm testmode.obj testmode.lst

REM sdsplcv2541.exe -d d22_071203V1.obj -g0 MAIN_DEV.obj  -g1 f_localplay.obj -g1 f_answer.obj -g1 f_menu.obj -b MAIN_DEV.obj -h D22DSP_DEV.hex 
SDSPL d22_071203V1.obj -g0 MAIN_DEV.obj  -g1 f_localplay.obj -g1 f_answer.obj -g1 f_menu.obj -b MAIN_DEV.obj -h D22DSP.hex
SDSPL d22_071203V1.obj -g0 MAIN_DEV.obj  -g1 f_localplay.obj -g1 f_answer.obj -g1 f_menu.obj -b MAIN_DEV.obj -h D22DSP.bin -m2

pause
CHKSUM D22DSP.bin
PAUSE

del *.lst

del *.lmf
del *.map

del MAIN_DEV.obj
del testmode.obj
del f_answer.obj
del f_localplay.obj
del f_menu.obj

del *.mem

rem goto 123