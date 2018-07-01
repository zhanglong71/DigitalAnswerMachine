
/*************************************************
application ËµÃ÷
1.  ÓÉprogram±£´æ³ÌÐòµÄID£¬Í¬Ê±¸ÃIDÒ²ÔÚstackÖÐ£¬²»Ò»¶¨ÔÚÕ»¶¥¡£
    Èç¹ûprogram=0£¬±íÃ÷µ±Ç°µÄ³ÌÐòÒÑ¾­ÒÑ¾­Í£Ö¹£¬ÓÉprogram´ÓstackÖÐ³öÕ»£¬È¡³öÉÏÒ»¼¶³ÌÐòID¡£
2.  Á½¸öÖØÒªÎ»£¬sys_flag,PROGRAMINITºÍsys_flag,PROGRAMREIN¡£
    µ±ÔÝÍ£±¾³ÌÐòµ÷ÓÃÒ»¸öÐÂµÄ³ÌÐò£¬Ôòsys_flag,PROGRAMINITÖÃ1£¬µÚÒ»´ÎÖ´ÐÐ³ÌÐò¡£
    µ±³ÌÐòÍË³ö£¬»Øµ½ÉÏÒ»¼¶³ÌÐòÊ±£¬Ôòsys_flag,PROGRAMREINÖÃ1£¬³ÌÐòÖØÐÂ½øÈë¡£
    ÓÉ³ÌÐò×Ô¼ºÇå0¡£
    µÚÒ»´ÎÖ´ÐÐ³ÌÐòsys_flag,PROGRAMINITºÍsys_flag,PROGRAMREIN¶¼±»ÖÃ1¡£
3.  ¿ÉÒÔ½«programÖÐµÄÖØÒªÊý¾Ý±£´æÔÚstackÖÐ¡£
    µÚÒ»´ÎÖ´ÐÐ³ÌÐò£¬ÓÉapplication´ÓstackÖÐ³öÕ»È¡µÃ³ÌÐòID²¢±£´æÔÚprogramÖÐ¡£
    ÐèÒªµ÷ÓÃÒ»¸öÐÂµÄ³ÌÐò£¬±ØÐë½«³ÌÐòµÄÖØÒªÊý¾Ý±£´æµ½stackÖÐ£¬È»ºó±£´æ±¾³ÌÐòµÄID£¬ÔÙ±£´æÐÂ³ÌÐòµÄID¡£
    ±¾³ÌÐòÍË³ö£¬Ö»ÐèÒª½«programÇå0¡£
    ±¾³ÌÐòÍË³ö²¢½øÈëÒ»¸öÐÂµÄ³ÌÐò£¬Ö»ÐèÒª±£´æÐÂ³ÌÐòµÄID¡£
4.  sys_flag.PROGRAMINIT=1£¬¶Ô³ÌÐò×÷³õÊ¼»¯¡£
    sys_flag.PROGRAMREIN=1£¬ÖØÐÂ¼¤»î³ÌÐò£¬ÐèÒª½«³ÌÐòµÄ±£´æÊý¾Ý»Ö¸´£¬Êý¾Ý±ØÐëºÍµ÷ÓÃÐÂ³ÌÐòÊ±´æÈëµÄÊý¾ÝÏàÆ¥Åä¡£
5.  ¹â±ê±ØÐë±£´æ¡£
6.  ²»ÄÜÁ¬ÐøÑ¹Õ»³¬¹ý2¸öÐÂ³ÌÐò¡£
*************************************************/

ORG	0x1400
Application_error:
	PAGE	#(VGA)
	CALL	VgaBlankChar
	MOV	A,@(STYLE_CENTER)
	CALL	VgaChar
	MOV	A,@(98)
	CALL	VgaChar
	MOV	A,@(105)
	CALL	VgaChar
	MOV	A,@(103)
	CALL	VgaChar
	MOV	A,@(32)
	CALL	VgaChar
	MOV	A,@(101)
	CALL	VgaChar
	MOV	A,@(114)
	CALL	VgaChar
	MOV	A,@(114)
	CALL	VgaChar
	MOV	A,@(111)
	CALL	VgaChar
	MOV	A,@(114)
	CALL	VgaChar
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	RET


ApplicationBackGround:
	SUBA	program,@(7)
	JPNC	ApplicationBackGround_ret
	XORA	sys_msg,@(WM_HANDSET)
	JPZ	ApplicationBackGround_handset
	XORA	sys_msg,@(WM_POWER)
	JPZ	ApplicationBackGround_power
	JPNB	hardware,DTAMPOWER,ApplicationBackGround_power
	XORA	sys_msg,@(WM_COMMAND)
	JPZ	ApplicationBackGround_command
ApplicationBackGround_ret:
	RETL	@(0)
ApplicationBackGround_handset:
	MOV	A,@(PRO_AppDialingPhone)
	JMP	ApplicationBackGround_newprogram
ApplicationBackGround_power:
	PAGE	#(LibPushStack)
	CALL	LibClearStack
	MOV	A,@(PRO_AppIdle)
	CALL	LibPushProgram
	PAGE	#($)
	RETL	@(1)
ApplicationBackGround_command:
	XORA	sys_data,@(0x19)
	JPZ	ApplicationBackGround_ringin
	XORA	sys_data,@(0x1a)
	JPZ	ApplicationBackGround_call
	JMP	ApplicationBackGround_ret
ApplicationBackGround_call:
	MOV	A,@(1)
	LCALL	LibGetCommand
	ADD	A,@(0)
	JPNZ	ApplicationBackGround_ret
ApplicationBackGround_ringin:
	MOV	A,@(PRO_AppNewCall)
	JMP	ApplicationBackGround_newprogram
ApplicationBackGround_newprogram:
	MOV	ax,A
	PAGE	#(LibPushStack)
	CALL	LibClearStack
	MOV	A,@(0x00)
	CALL	LibPushStack
	MOV	A,@(PRO_AppIdle)
	CALL	LibPushStack
	MOV	A,ax
	CALL	LibPushProgram
	PAGE	#($)
	RETL	@(1)
	
	
	


Application:
	MOV	A,program
	JPNZ	Application_0
	LCALL	LibDisplayStamp
	LCALL	LibPopProgram
	MOV	program,A
	ADD	A,@(0)
	JPZ	Application_error
Application_0:
	CALL	ApplicationBackGround
	ADD	A,@(0)
	JPNZ	Application
Application_1:
	JPB	sys_flagext,DSPSTATUS,Application_ret
	SUBA	program,@(1)
	;AND	A,@(0x7f)
	TBL
	JMP	Application_001
	JMP	Application_002
	JMP	Application_003
	JMP	Application_004
	JMP	Application_005
	JMP	Application_006
	JMP	Application_007
	JMP	Application_008
	JMP	Application_009
	JMP	Application_010
	JMP	Application_011
	JMP	Application_012
	JMP	Application_013
	JMP	Application_014
	JMP	Application_015
	JMP	Application_016
	JMP	Application_017
	JMP	Application_018
	JMP	Application_019
	JMP	Application_020
	JMP	Application_021
	JMP	Application_022
	JMP	Application_023
	JMP	Application_024
	JMP	Application_025
	JMP	Application_026
	JMP	Application_027
	JMP	Application_028
	JMP	Application_029
	JMP	Application_030
	JMP	Application_031
	JMP	Application_032
	JMP	Application_033
	JMP	Application_034
	JMP	Application_035
	JMP	Application_036
	JMP	Application_037
	JMP	Application_038
	JMP	Application_039
	JMP	Application_040
	JMP	Application_041
	JMP	Application_042
	JMP	Application_043
	JMP	Application_044
	JMP	Applicationÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ	LibSendOneCommand
	JMP	AppDialingPhone_return

AppDialingPhone_flash:				; flash¼ü°´ÏÂ
	LCALL	LibStoreRedialNumber
	CLR	_RC
	AND	_RD,@(0xf8)
	ADD	_RD,@(0x04)			; °´ÏÂflash¼ü£¬ÏÈmute
	PAGE	#(VGA)
	MOV	A,@(0)
	CALL	VgaNum2
	MOV	A,@(STYLE_RIGHT)
	CALL	VgaNum2
	CALL	VgaDrawNum2
	CALL	VgaBlankNum2
	CALL	VgaBlankChar
	PAGE	#(LibInitTimer)
	CALL	LibInitTimer
	PAGE	#($)
	BS	r2_flag,5
	JPNB	r2_flag,7,AppDialingPhone_mute1
	BC	r2_flag,7
	MOV	A,@(0x54)
	LCALL	LibSendOneCommand
	JMP	AppDialingPhone_mute1
AppDialingPhone_mute:				; mute¼ü°´ÏÂ
	INVB	_RD,4				; ¸Ä±ämute×´Ì¬
	JPNB	hardware,HANDSET,AppDialingPhone_mute_handset	; ÊÖ±úÄÃÆð£¬muteÊÖ±ú
	JMP	AppDialingPhone_mute_spk	; ·ñÔòmuteÃâÌá
AppDialingPhone_mute_handset:
	ANDA	_RD,@(0x07)
	JPNZ	AppDialingPhone_status		; ²»ÔÚ´ý»ú×´Ì¬£¬±¾À´¾Í´¦ÓÚmute×´Ì¬
	JPNB	_RD,4,AppDialingPhone_mute_handset_unmute
	BC	_P9,3				; handset, mute=0
	JMP	AppDialingPhone_status
AppDialingPhone_mute_handset_unmute:
	BS	_P9,3
	JMP	AppDialingPhone_status
AppDialingPhone_mute_spk:
	/*
	COMMAND:ÕâÀïÏòDSP·¢ËÍSPK onÃüÁî
	*/
	JMP	AppDialingPhone_status
AppDialingPhone_redial:
	CLR	cnt
AppDialingPhone_redial_1:
	ADDA	cnt,@(99)
	MOV	_RC,A
	MOV	A,_RD
	JPZ	AppDialingPhone_dial
	LCALL	LibStoreDialNumber
	INC	cnt
	SUBA	cnt,@(32)
	JPNC	AppDialingPhone_redial_1
	JMP	AppDialingPhone_dial
AppDialingPhone_spk:				; SPK¼ü°´ÏÂ
	JPNB	hardware,POWERSTATUS,AppDialingPhone_dial	; POWER down, SPK¼ü°´ÏÂÎÞÏìÓ¦¡£
AppDialingPhone_spk_1:
	INVB	sys_flag,SPKPHONE		; ¸Ä±äSPK×´Ì¬
	
	/*
	COMMAND:ÕâÀïÏòDSP·¢ËÍSPK ON/OFFÃüÁî£¬·¢ËÍONÃüÁîÊ±Í¬Ê±ÐèÒª½«MUTE×´Ì¬·¢ËÍ³öÈ¥¡£
	*/
	JPNB	sys_flag,SPKPHONE,AppDialingPhone_spk_off
AppDialingPhone_spk_on:
	JPB	hardware,HANDSET,AppDialingPhone_status	;ERROR: ÊÖ±ú¹Ò»ú×´Ì¬£¬SPKÕª»ú£¬Ã»ÓÐÕâÖÖÇé¿ö£¬¿ÉÒÔµ±³ö´í´¦Àí¡£
AppDialingPhone_handset_spk:			; ÊÖ±úÕª»ú×´Ì¬ÏÂ°´ÏÂSPK
	CALL	AppPhoneIdle
	JMP	AppDialingPhone_status
AppDialingPhone_spk_off:
	JPB	hardware,HANDSET,AppDialingPhone_release	; ÊÖ±ú¹Ò»ú×´Ì¬£¬SPK¹Ò»ú£¬¹Ò»ú
	CALL	AppPhoneIdle
	JMP	AppDialingPhone_status
	
AppDialingPhone_handset:
	XORA	sys_data,@(HANDSET_ON)
	JPZ	AppDialingPhone_handset_on
	XORA	sys_data,@(HANDSET_OFF)
	JPZ	AppDialingPhone_handset_off
AppDialingPhone_handset_on:			; ÊÖ±ú¹Ò»ú
	JPNB	sys_flag,SPKPHONE,AppDialingPhone_release	; SPK off×´Ì¬£¬ÊÖ±ú¹Ò»ú£¬¹Ò»ú
	CALL	AppPhoneIdle
	JMP	AppDialingPhone_status
AppDialingPhone_handset_off:			; ÊÖ±úÕª»ú
	JPNB	sys_flag,SPKPHONE,AppDialingPhone_status	;ERROR: SPK off×´Ì¬£¬ÊÖ±úÕª»ú£¬Ã»ÓÐÕâÖÖÇé¿ö£¬¿ÉÒÔµ±³ö´í´¦Àí¡£
	BC	sys_flag,SPKPHONE		; SPK on×´Ì¬£¬ÊÖ±úÕª»ú£¬SPK×ªÎªOFF×´Ì¬
	CALL	AppPhoneIdle
	JMP	AppDialingPhone_status

AppDialingPhone_vola:
	JPB	sys_flag,SPKPHONE,AppDialingPhone_spk_vola
	BC	_P9,5
	JMP	AppDialingPhone_dial
AppDialingPhone_vols:
	JPB	sys_flag,SPKPHONE,AppDialingPhone_spk_vols
	BS	_P9,5
	JMP	AppDialingPhone_dial
AppDialingPhone_spk_vola:
AppDialingPhone_spk_vols:
	LCALL	LibVolAdjust
	JMP	AppDialingPhone_dial

AppDialingPhone_keyrelease:
	BC	_RD,6				; ÊÍ·Å°´¼ü
	JMP	AppDialingPhone_dial

AppDialingPhone_power:
	XORA	sys_data,@(POWER_ON)
	JPZ	AppDialingPhone_dial
	JPNB	sys_flag,SPKPHONE,AppDialingPhone_dial
	JMP	AppDialingPhone_spk_1		; SPK on×´Ì¬£¬power down£¬SPK¹Ò»ú¡£

AppDialingPhone_command:
	XORA	sys_data,@(0x12)
	JPZ	AppDialingPhone_record
	JPNB	r2_flag,7,AppDialingPhone_dial
	XORA	sys_data,@(0x13)
	JPZ	AppDialingPhone_return
	XORA	sys_data,@(0x18)
	JPZ	AppDialingPhone_mfull
	JMP	AppDialingPhone_dial
AppDialingPhone_record:
	PAGE	#(VGA)
	CALL	VgaBlankChar
	MOV	A,@(STYLE_LEFT)
	CALL	VgaChar
	MOV	A,@(STR_TwoWay)
	CALL	VgaString
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)
	BS	r2_flag,7
	MOV	r2_msec_bak,r2_msec
	MOV	r2_second_bak,r2_second
	MOV	r2_minute_bak,r2_minute
	MOV	r2_hour_bak,r2_hour
	PAGE	#(LibInitTimer)
	CALL	LibInitTimer
	CALL	LibDisplayTimer
	PAGE	#($)
	JMP	AppDialingPhone_dial
AppDialingPhone_mfull:
	BS	r2_flag,6
AppDialingPhone_return:
	PAGE	#(VGA)
	CALL	VgaBlankChar
	BC	r2_flag,7
	ADD	r2_msec,r2_msec_bak
	ADD	r2_second,r2_second_bak
	ADD	r2_minute,r2_minute_bak
	ADD	r2_hour,r2_hour_bak
	PAGE	#(LibInitTimer)
	MOV	A,@(1)
	CALL	LibDisplayTimer
	PAGE	#($)
	JMP	AppDialingPhone_dial

AppDialingPhone_release:
	MOV	_RB,@(0xff)			; ²¦ºÅÍ£Ö¹
	JPNB	r2_flag,7,AppDialingPhone_release_1
	PAGE	#(LibSendOneCommand)
	MOV	A,@(0x54)
	CALL	LibSendOneCommand
	PAGE	#(VGA)
	CALL	VgaBlankChar
	BC	r2_flag,7
	ADD	r2_msec,r2_msec_bak
	ADD	r2_second,r2_second_bak
	ADD	r2_minute,r2_minute_bak
	ADD	r2_hour,r2_hour_bak
	PAGE	#(LibInitTimer)
	MOV	A,@(1)
	CALL	LibDisplayTimer
	PAGE	#($)
AppDialingPhone_release_1:
	LCALL	LibStoreRedialNumber
	BC	_P9,2
	BC	_P9,3
	BC	_P9,4
	BC	_P9,7				; ¹Ò»ú
	BC	sys_flag,HOOKSTATUS
	PAGE	#(VGA)
	MOV	A,@(0)
	CALL	VgaNum2
	CALL	VgaDrawNum2
	PAGE	#($)
	MOV	A,@(PRO_AppDialingExit)		; ½øÈë¹Ò»úÏÔÊ¾ÑÓÊ±5s¡£
	LCALL	LibPushProgram
	LCALL	LibDisplayDialingStatus
	JMP	AppDialingPhone_ret

AppDialingPhone_status:
	LCALL	LibDisplayDialingStatus
AppDialingPhone_dial:
	BANK	2
	MOV	A,r2_tmr_dial1
	JPNZ	AppDialingPhone_ret		; ²¦ºÅ¹ý³ÌÖÐµÄÑÓÊ±Ê±¼äÎ´µ½¡£
	MOV	A,r2_tmr_dial
	JPNZ	AppDialingPhone_ret		; ²¦ºÅ¹ý³ÌÖÐµÄÑÓÊ±Ê±¼äÎ´µ½¡£
	
	BLOCK	3
	CLR	_RC
	ANDA	_RD,@(0x07)
	TBL
	JMP	AppDialingPhone_dial_idle	; ´ý»ú
	JMP	AppDialingPhone_dial_mute1	; ²¦ºÅÇ°µÄmute
	JMP	AppDialingPhone_dial_number	; ²¦ºÅ
	JMP	AppDialingPhone_dial_mute2	; ²¦ºÅºóµÄmute
	JMP	AppDialingPhone_dial_mute3	; flashÇ°µÄmute
	JMP	AppDialingPhone_dial_flash	; flash
	JMP	AppDialingPhone_dial_mute4	; flashºóµÄmute
AppDialingPhone_ret:
	RETL	@(0)				; ·µ»Ø
AppDialingPhone_dial_idle:			; ´ý»ú×´Ì¬
	INC	_RC
	MOV	A,_RD
	JPZ	AppDialingPhone_ret		; Ã»ÓÐ´ý²¦ºÅÂë
	INC	_RC
	PAGE	#(VGA)
	MOV	A,_RD
	CALL	VgaNum2				; ÏÔÊ¾ºÅÂë
	CALL	VgaDrawNum2
	PAGE	#($)
	BLOCK	3
	MOV	_RC,@(2)
	MOV	A,_RD
	LCALL	LibNumTone			; ¶ÔºÅÂë½øÐÐ¼ì²é£¬Í¬Ê±×ª»»
	ADD	A,@(0)
	JPZ	AppDialingPhone_dial_shiftnum	; ÎÞÐ§ºÅÂë£¬½«ºÅÂë×óÒÆ
	XOR	A,@(0xff)
	JPZ	AppDialingPhone_dial_pause	; pause
	CLR	_RC
	AND	_RD,@(0xf8)
	ADD	_RD,@(0x01)			; ÓÐÐ§ºÅÂë£¬½øÈë²¦ºÅÇ°µÄmute
AppDialingPhone_mute1:
	DISI
	MOV	r2_tmr_dial,@(5)
	CLR	r2_tmr_dial1
	ENI
	BC	_P9,2				; ²»¹Üspkphone´¦ÓÚÄÄÖÖ×´Ì¬£¬²¦ºÅmute·½Ê½¶¼Ò»Ñù¡£
	BC	_P9,3
	BC	_P9,4
	JMP	AppDialingPhone_ret
AppDialingPhone_dial_pause:
	DISI
	CLR	r2_tmr_dial
	BANK	3
	MOV	A,r3_pausetime
	BANK	2
	MOV	r2_tmr_dial1,A			; pause time
	ENI
AppDialingPhone_dial_shiftnum:
	MOV	_RC,@(1)
	DEC	_RD
	MOV	cnt,_RD
	MOV	ax,@(3)
	MOV	bx,@(2)
	LCALL	LibCopyRam			; ½«Ê£ÓàµÄºÅÂë×óÒÆÒ»Î»
	JMP	AppDialingPhone_ret
AppDialingPhone_dial_wait:			; wait×´Ì¬
	AND	_RD,@(0xf8)			; waitÊ±¼äµ½£¬½øÈëidle×´Ì¬
	JMP	AppDialingPhone_ret
AppDialingPhone_dial_mute1:			; ²¦ºÅÇ°µÄmute×´Ì¬
	AND	_RD,@(0xf8)
	ADD	_RD,@(0x02)			; muteÊ±¼äµ½£¬½øÈë²¦ºÅ×´Ì¬
	DISI
	MOV	r2_tmr_dial,@(25)		; ²¦ºÅ100ms
	CLR	r2_tmr_dial1
	ENI
	
	INC	_RC
	INC	_RC
	MOV	A,_RD
	LCALL	LibNumTone			; ¶ÔºÅÂë½øÐÐ¼ì²é£¬Í¬Ê±×ª»»
	MOV	_RB,A
	JMP	AppDialingPhone_ret
AppDialingPhone_dial_number:			; ²¦ºÅ×´Ì¬
	JPNB	_RD,6,AppDialingPhone_dial_number_1	; °´¼üÊÇ·ñ³ÖÐøÖÐ
	INC	_RC
	SUBA	_RD,@(2)
	JPC	AppDialingPhone_dial_number_1	; ²»ÊÇ×îºóÒ»¸öºÅÂë
	JMP	AppDialingPhone_ret		; ×îºóÒ»¸öºÅÂë£¬ÇÒ²¦ºÅ¼ü°´¼ü³ÖÐøÖÐ¡£
AppDialingPhone_dial_number_1:
	CLR	_RC
	MOV	_RB,@(0xff)			; Í£Ö¹²¦ºÅ (²¦ºÅ100msÊ±¼äµ½£¬×îºóÒ»¸öºÅÂë°´¼üËÉÆð)
	AND	_RD,@(0xf8)
	ADD	_RD,@(0x03)			; ²¦ºÅÍê±Ï£¬½øÈë²¦ºÅÖ®ºóµÄMUTEÊ±ÆÚ¡£
	DISI
	MOV	r2_tmr_dial,@(5)		; mute 20ms
	CLR	r2_tmr_dial1
	ENI
	JMP	AppDialingPhone_dial_shiftnum	; ½«Ê£ÓàµÄºÅÂë×óÒÆÒ»Î»
AppDialingPhone_dial_mute2:			; ²¦ºÅÖ®ºóµÄmute×´Ì¬£¬muteÍê»Øµ½talking×´Ì¬µÄmute.
	AND	_RD,@(0xf8)			; muteÍê±Ï£¬ÑÓÊ±60ms£¬½øÈëidle
	DISI
	MOV	r2_tmr_dial,@(15)		; delay 60ms
	CLR	r2_tmr_dial1
	ENI
AppDialingPhone_mute2:
	
	CALL	AppPhoneIdle			; Í¨»°×´Ì¬£¬Ò²¾ÍÊÇ´ý»ú×´Ì¬
	
	JMP	AppDialingPhone_ret
AppDialingPhone_dial_mute3:			; flashÇ°µÄmute
	AND	_RD,@(0xf8)
	ADD	_RD,@(0x05)
	BC	_P9,7				; on hook
	BANK	3
	MOV	ax,r3_flashtime
	MOV	exa,@(25)
	LCALL	LibMathHexMul
	BANK	2
	DISI
	MOV	r2_tmr_dial,ax			; flash time
	MOV	r2_tmr_dial1,exa
	ENI
	JMP	AppDialingPhone_ret
AppDialingPhone_dial_flash:			; flash
	AND	_RD,@(0xf8)
	ADD	_RD,@(0x06)
	BS	_P9,7				; off hook
	DISI
	MOV	r2_tmr_dial,@(5)		; mute 20ms
	CLR	r2_tmr_dial1
	ENI
	BC	r2_flag,5
	LCALL	LibDisplayTimer
	JMP	AppDialingPhone_ret
AppDialingPhone_dial_mute4:			; flashºóµÄmute
	AND	_RD,@(0xf8)
	DISI
	MOV	r2_tmr_dial,@(100)		; flashÖ®ºó±ØÐëµÈ´ý400msÖ®ºó²ÅÄÜ¿ªÊ¼²¦ºÅ
	CLR	r2_tmr_dial1
	ENI
	JMP	AppDialingPhone_mute2

AppPhoneIdle:					; Í¨»°µÄ´ý»ú×´Ì¬
	BLOCK	3
	CLR	_RC
	CLR	ax
	ANDA	_RD,@(0x07)
	JPNZ	AppPhoneIdle_1
	JPB	hardware,7,$+3
	BS	ax,3
	BS	ax,4
	JPNB	sys_flag,SPKPHONE,$+2
	BS	ax,2
	JPNB	_RD,4,$+2
	BC	ax,3
AppPhoneIdle_1:
	AND	_P9,@(0xe3)
	OR	_P9,ax
	RETL	@(0)

/*************************************************
AppPreDial
Ô¤²¦ºÅÂë±à¼­³ÌÐò
³õÊ¼»¯:	
	
ÏÔÊ¾:	
*************************************************/
AppPreDial:
	JPB	sys_flag,PROGRAMINIT,AppPreDial_init
	JPB	sys_flag,PROGRAMREIN,AppPreDial_rein
	JMP	AppPreDial_idle
AppPreDial_init:
	BC	sys_flag,PROGRAMINIT
	BANK	2
	BLOCK	3
	MOV	_RC,@(131)
	MOV	A,_RD
	MOV	r2_bx,A
	MOV	r2_cnt,A
	INC	r2_cnt
	CALL	AppDisplayEditNumber
	PAGE	#(VGA)
	CALL	VgaBlankChar
	MOV	A,@(STYLE_LEFT)
	CALL	VgaChar
	MOV	A,@(STR_PreHFdial)
	CALL	VgaString
	MOV	A,@(58)
	CALL	VgaChar
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)
	JMP	AppPreDial_display
AppPreDial_rein:
AppPreDial_display:
	BC	sys_flag,PROGRAMREIN
AppPreDial_idle:
	LCALL	LibHookCheck
	ADD	A,@(0)
	JPNZ	AppPreDial_offhook
	
	CALL	AppEditNumber32
	ADD	A,@(0)
	JPNZ	AppPreDial_number
	
	XORA	sys_msg,@(WM_KEYPRESS)
	JPZ	AppPreDial_keypress
AppPreDial_idle_ret:
	RETL	@(0)

AppPreDial_offhook:
	BLOCK	3
	CLR	cnt
AppPreDial_offhook_store:
	MOV	_RC,@(131)
	SUBA	cnt,_RD
	JPZ	AppPreDial_offhook_1
	INC	cnt
	ADD	_RC,cnt
	MOV	A,_RD
	LCALL	LibStoreDialNumber
	JMP	AppPreDial_offhook_store
AppPreDial_offhook_1:
	
	MOV	A,@(PRO_AppDialingPhone)
	LCALL	LibPushProgram
	RETL	@(0)

AppPreDial_number:
	CALL	AppDisplayEditNumber
	RETL	@(0)

AppPreDial_keypress:
	XORA	sys_data,@(KEY_EXIT)
	JPZ	AppPreDial_exit
	RETL	@(0)
AppPreDial_exit:
	PAGE	#(LibPushStack)
	CALL	LibClearStack
	MOV	A,@(PRO_AppIdle)
	CALL	LibPushProgram
	PAGE	#(0)
	RETL	@(0)

/*************************************************
ºÅÂë±à¼­
±à¼­Ö¸ÕëÖ¸ÏòÒª±à¼­µÄºÅÂë£¬Í¬Ê±¸ÃºÅÂëÉÁË¸£¬´¦ÓÚ¹â±ê×´Ì¬¡£
°´ÏÂÊý×Ö¼üÔÚ¸ÃºÅÂëµÄÇ°ÃæÌí¼ÓÒ»¸öºÅÂë£¬ºóÃæºÅÂëÒÀ´ÎÓÒÒÆ£¬±à¼­Ö¸ÕëÈÔÈ»Ö¸Ïò¸ÃºÅÂë£¬²¢ÇÒ¹â±êÓÒÒÆÒ»Î»¡£
°´ÏÂBACK¼ü£¬É¾³ýÇ°ÃæµÄÒ»Î»ºÅÂë£¬Ç°ÃæµÄºÅÂëÒÀ´ÎÓÒÒÆ£¬¹â±êÎ»ÖÃ²»±ä¡£
°´ÏÂDEL¼ü£¬É¾³ýµ±Ç°ºÅÂë£¬ºóÃæÒÀ´Î×óÒÆ£¬¹â±êÎ»ÖÃ²»±ä¡£
°´ÏÂLEFT»òÕßUP¼ü£¬¹â±ê×óÒÆÒ»Î»£¬µ±µ½´ï×î×ó±ßÊ±£¬ºÅÂëÓÒÒÆ£¬×ó±ßÃ»ÓÐºÅÂëÁË£¬²»×öÏìÓ¦¡£
°´ÏÂRIGHT»òÕßDOWN¼ü£¬¹â±êÓÒÒÆÒ»Î»£¬µ±¹â±êµ½´ï×îÓÒ±ßµÄÏÂÒ»Î»Ê±£¬¹â±êÏûÊ§£¬ºÅÂë×óÒÆ£¬ÓÒ±ßÃ»ÓÐºÅÂëÊ±£¬²»×öÏìÓ¦¡£
³õÊ¼×´Ì¬£º
    ºÅÂë°´¿¿ÓÒÅÅÁÐ·ÅÔÚµÚ¶þÐÐÊý×ÖÇø¡£
    ¹â±êÏûÊ§×´Ì¬£¬ºÅÂë±à¼­Ö¸ÕëÎª×îºóÒ»¸öºÅÂëµÄÏÂÒ»Î»¡£
    r2_ax:	ÊäÈëµÄ±à¼­ºÅÂë
    r2_cnt:	´¦ÓÚ±à¼­×´Ì¬µÄºÅÂëµÄÎ»ÖÃ£¬ÆÁÄ»µÄ¹â±êÔÚÕâ¸öºÅÂëÉÏ¡£
    r2_bx:	ÏÔÊ¾ÆÁÓÒ¶ËºÅÂëµÄÎ»ÖÃ£¬ºÅÂëÔÚ±à¼­ÇøµÄÎ»ÖÃ
*************************************************/
AppEditNumber32:
	BANK	2
	BLOCK	3
AppEditNumber32_edit:
	MOV	_RC,@(131)
	
	XORA	sys_msg,@(WM_KEYPRESS)
	JPZ	AppEditNumber32_edit_key
AppEditNumber32_edit_ret:
	RETL	@(0)
AppEditNumber32_edit_key:
	
	XORA	sys_data,@(KEY_BACK)
	JPZ	AppEditNumber32_edit_back
	XORA	sys_data,@(KEY_ERASE)
	JPZ	AppEditNumber32_edit_erase
	XORA	sys_data,@(KEY_LEFT)
	JPZ	AppEditNumber32_edit_left
	XORA	sys_data,@(KEY_UP)
	JPZ	AppEditNumber32_edit_left
	XORA	sys_data,@(KEY_RIGHT)
	JPZ	AppEditNumber32_edit_right
	XORA	sys_data,@(KEY_DOWN)
	JPZ	AppEditNumber32_edit_right
	
	LCALL	LibDialNumCheck
	ADD	A,@(0)
	JPZ	AppEditNumber32_edit_ret
; ÊäÈëÒ»¸öºÅÂë
; ÔÚ¹â±êÎ»ÖÃ³öÊäÈë¸ÃºÅÂë£¬²¢½«¹â±êÎ»ÖÃµÄÔ­ºÅÂëºÍÆäºóµÄºÅÂëÓÒÒÆÒ»Î»¡£
; Í¬Ê±¹â±êÓÒÒÆÒ»Î»£¬µ±¹â±ê=ÆÁÎ»ÖÃÊ±£¬ÆÁÎ»ÖÃÒ²ÒªÓÒÒÆÒ»Î»¡£
AppEditNumber32_edit_num:
	MOV	r2_ax,A
	SUBA	_RD,@(32)
	JPC	AppEditNumber32_full		; ±à¼­³¤¶Èµ½ÁË32Î»£¬Âú£¬²»ÄÜÊäÈëºÅÂë¡£
	INC	_RD				; ÊäÈëÒ»Î»ºÅÂë£¬³¤¶È+1¡£
	ADDA	r2_cnt,@(131)			; µÃµ½±à¼­Î»ÖÃ
	MOV	ax,A				; ±à¼­Î»ÖÃµÄµØÖ·
	MOV	bx,A				; ±à¼­Î»ÖÃµÄÏÂÒ»Î»µØÖ·
	INC	bx
	SUBA	_RD,r2_cnt
	MOV	cnt,A				; ÓÒÒÆµÄ³¤¶È
	LCALL	LibCopyRam
	ADDA	r2_cnt,@(131)
	MOV	_RC,A
	MOV	_RD,r2_ax
	MOV	_RC,@(131)
	JMP	AppEditNumber32_edit_right	; Í¬Ê±¹â±êÒªÓÒÒÆ¡£
; É¾³ý¹â±êÇ°ÃæµÄÒ»Î»ºÅÂë
; É¾³ýÇ°µÄºÅÂë£¬¹â±êµ±Ç°Î»µÄºÅÂë¼°ÆäºóµÄºÅÂë×óÒÆÒ»Î»¡£
; ¹â±êÏà¶Ô±à¼­ÇøÎ»ÖÃ×óÒÆ£¬ÆÁÏà¶Ô±à¼­ÇøÎ»ÖÃ×óÒÆ¡£¹â±êÏÔÊ¾Î»ÖÃ²»±ä¡£
AppEditNumber32_edit_back:
	SUBA	r2_cnt,@(2)
	JPNC	AppEditNumber32_edit_ret	; ¹â±êÎ»ÖÃÔÚµÚÒ»¸öºÅÂë´¦£¬ÎÞ·¨É¾³ýÇ°ÃæµÄºÅÂë¡£
	DEC	_RD				; É¾³ýÒ»¸öºÅÂë£¬³¤¶È-1
	ADDA	r2_cnt,@(131)
	MOV	ax,A
	MOV	bx,A
	DEC	bx
	SUBA	_RD,r2_cnt
	MOV	cnt,A
	INC	cnt
	INC	cnt
	LCALL	LibCopyRam
	MOV	_RC,@(131)
	JMP	AppEditNumber32_edit_left

AppEditNumber32_edit_erase:
	SUBA	_RD,r2_cnt
	JPNC	AppEditNumber32_edit_ret	; ¹â±êÎ»ÖÃÔÚ×îºóÒ»¸öºÅÂëµÄÏÂÒ»Î»£¬ÎÞ·¨É¾³ýµ±Ç°Î»¡£
	DEC	_RD				; É¾³ýÒ»¸öºÅÂë£¬³¤¶È-1
	SUBA	_RD,r2_cnt
	JPNC	AppEditNumber32_edit_screen	; É¾³ý×îºóÒ»Î»ºÅÂë£¬²»ÐèÒªÒÆÎ»£¬Ö±½Óµ÷ÕûÆÁÄ»¡£
	ADDA	r2_cnt,@(131)
	MOV	ax,A
	MOV	bx,A
	INC	ax
	SUBA	_RD,r2_cnt
	MOV	cnt,A
	INC	cnt
	LCALL	LibCopyRam
	MOV	_RC,@(131)
	JMP	AppEditNumber32_edit_screen	; ¹â±êÎ»ÖÃ²»±ä£¬Ö±½Óµ÷ÕûÆÁÄ»¡£
	

; ¹â±ê×óÒÆ£¬¹â±ê×óÒÆÊ¼ÖÕÓÐÒ»¸öÏÔÊ¾¡£
; Èç¹û¹â±êËùÔÚ±à¼­ÇøÒÑ¾­µ½´ïµÚÒ»¸öºÅÂë£¬ÎÞ·¨×óÒÆ¡£
AppEditNumber32_edit_left:
	SUBA	r2_cnt,@(1)
	JPZ	AppEditNumber32_edit_ret	; µÚÒ»¸öºÅÂë£¬ÎÞ·¨×óÒÆ¡£
	DEC	r2_cnt				; ¹â±ê×óÒÆ¡£
	JMP	AppEditNumber32_edit_screen	; µ÷ÕûÆÁÄ»

; ¹â±êÓÒÒÆ£¬¿ÉÒÔÒÆ¶¯µ½ÆÁÄ»Ö®Íâ£¬ÕâÊ±r2_cnt=r2_bx£¬ÏÔÊ¾ÆÁÉÏÃ»ÓÐ¹â±ê¡£
; Èç¹û¹â±êÒÑ¾­µ½´ï×îºóÒ»¸öºÅÂëµÄÏÂÒ»Î»£¬ÎÞ·¨ÓÒÒÆ¡£
AppEditNumber32_edit_right:
	SUBA	_RD,r2_cnt
	JPNC	AppEditNumber32_edit_ret	; ×îºóÒ»¸öºÅÂëµÄÏÂÒ»Î»£¬ÎÞ·¨ÓÒÒÆ¡£
	INC	r2_cnt				; ¹â±êÓÒÒÆ

; µ÷ÕûÆÁÄ»
; ±£Ö¤¹â±ê´¦ÓÚÆÁÄ»µÄ2~15¸ñµÄ·¶Î§£¬ÀýÍâ£º
; 1. µÚÒ»¸öºÅÂë£¬¹â±êÔÚÆÁÄ»µÄµÚ1¸ñ
; 2. ×îºóÒ»¸öºÅÂë£¬¹â±êÔÚÆÁÄ»µÄµÚ16¸ñ
; 3. ×îºóÒ»¸öºÅÂëµÄÏÂÒ»Î»£¬¹â±êÔÚÆÁÄ»µÄ17¸ñ(ÆÁÄ»ÉÏÃ»ÓÐ¹â±ê)
AppEditNumber32_edit_screen:
	SUBA	_RD,r2_bx
	JPNC	AppEditNumber32_edit_screen_0	; Èç¹ûÆÁÄ»Î»ÖÃ´óÓÚÓÐÐ§Êý¾Ý³¤¶È£¬ÆÁÄ»Î»ÖÃ¶¨Îª×îºóÒ»Î»¡£
	SUBA	_RD,@(17)
	JPNC	AppEditNumber32_edit_screen_0
	JMP	$+3
AppEditNumber32_edit_screen_0:
	MOV	r2_bx,_RD
	
	SUBA	r2_bx,r2_cnt
	JPNC	AppEditNumber32_edit_screen_2	; ¹â±êÔÚÆÁÄ»µÄÓÒ¶Ë
	ADD	A,@(256-15)
	JPC	AppEditNumber32_edit_screen_1	; ¹â±êÔÚÆÁÄ»µÄµÚ2¸ñ×ó²à
	ADD	A,@(15-1)
	JPNC	AppEditNumber32_edit_screen_2	; ¹â±êÔÚÆÁÄ»µÄµÚ15¸ñÓÒ²à
	JMP	AppEditNumber32_edit_screen_ret
AppEditNumber32_edit_screen_1:			; ¹â±êÔÚÆÁÄ»µÄµÚ2¸ñ×ó²à¡£
	SUBA	r2_cnt,@(1)
	JPZ	AppEditNumber32_edit_screen_1_1	; µÚÒ»¸öºÅÂë
	ADDA	r2_cnt,@(14)			; ¹â±êÖ¸µ½µÚ¶þ¸öºÅÂë´¦¡£
	MOV	r2_bx,A
	JMP	AppEditNumber32_edit_screen_ret
AppEditNumber32_edit_screen_1_1:
	MOV	r2_bx,@(16)			; µÚÒ»ÆÁ¡£
	JMP	AppEditNumber32_edit_screen_ret
AppEditNumber32_edit_screen_2:
	SUBA	r2_cnt,_RD
	JPC	AppEditNumber32_edit_screen_2_1	; ×îºóÒ»¸öºÅÂë»ò×îºóÒ»¸öºÅÂëµÄÏÂÒ»Î»
	ADDA	r2_cnt,@(1)			; ¹â±êÖ¸µ½µÚ15¸öºÅÂë´¦¡£
	MOV	r2_bx,A
	JMP	AppEditNumber32_edit_screen_ret
AppEditNumber32_edit_screen_2_1:
	MOV	r2_bx,_RD			; ×îºóÒ»ÆÁ¡£
AppEditNumber32_edit_screen_ret:
	RETL	@(1)

AppEditNumber32_full:
	LJMP	AppEditFull

AppDisplayEditNumber:
	BANK	2
	LCALL	VgaBlankNum2			; Ïû³ý²ÐÓ°¡£
	MOV	A,@(STYLE_RIGHT)
	LCALL	VgaNum2
	CLR	r2_exa
AppDisplayEditNumber_loop:
	SUBA	r2_exa,r2_bx
	JPZ	AppDisplayEditNumber_end
	INC	r2_exa
	BLOCK	3
	ADDA	r2_exa,@(131)
	MOV	_RC,A
	MOV	A,_RD
	LCALL	VgaNum2
	JMP	AppDisplayEditNumber_loop
AppDisplayEditNumber_end:
	MOV	A,@(0)
	LCALL	VgaNum2
	LCALL	VgaDrawNum2
	SUBA	r2_bx,r2_cnt
	JPNC	AppDisplayEditNumber_end0
	SUB	A,@(15)
	ADD	A,@(0x20)
	JMP	AppDisplayEditNumber_end1
AppDisplayEditNumber_end0:
	MOV	A,@(0)
AppDisplayEditNumber_end1:
	LCALL	LibStoreCursor
	RET



/*************************************************
AppDialingExit
×¨ÓÃ²¦ºÅÍË³ö³ÌÐò£¬¹Ò»úºóÍË³öµ½ÕâÀï£¬ÏÔÊ¾Í¨»°ÐÅÏ¢5s¡£
³õÊ¼»¯:	
	
ÏÔÊ¾:	
´ý»ú:	1. ´¦Àíhook¼à²â³ÌÐò
	2. µÈ´ý5s¡£
*************************************************/
AppDialingExit:
	JPB	sys_flag,PROGRAMINIT,AppDialingExit_init
	JPB	sys_flag,PROGRAMREIN,AppDialingExit_rein
	JMP	AppDialingExit_idle
AppDialingExit_init:
	BC	sys_flag,PROGRAMINIT
	JMP	AppDialingExit_display
AppDialingExit_rein:
AppDialingExit_display:
	BC	sys_flag,PROGRAMREIN
	BANK	2
	CLR	r2_tmr_dial
	MOV	r2_tmr_dial1,@(5)
AppDialingExit_idle:
	LCALL	LibHookCheck
	ADD	A,@(0)
	JPNZ	AppDialingExit_offhook
	XORA	sys_msg,@(WM_KEYPRESS)
	JPZ	AppDialingExit_key
	XORA	sys_msg,@(WM_COMMAND)
	JPZ	AppDialingExit_command
AppDialingExit_ret:
	BANK	2
	MOV	A,r2_tmr_dial
	JPNZ	AppDialingExit_return_1
	MOV	A,r2_tmr_dial1
	JPNZ	AppDialingExit_return_1
AppDialingExit_return:
	PAGE	#(LibPushStack)
	CALL	LibClearStack
	MOV	A,@(PRO_AppIdle)
	CALL	LibPushProgram
	PAGE	#(0)
AppDialingExit_return_1:
	RETL	@(0)
AppDialingExit_key:
	XORA	sys_data,@(KEY_EXIT)
	JPZ	AppDialingExit_return
	JMP	AppDialingExit_ret
AppDialingExit_command:
	XORA	sys_data,@(0x19)
	JPZ	AppDialingExit_ringin
	XORA	sys_data,@(0x1a)
	JPZ	AppDialingExit_cid
	JMP	AppDialingExit_ret
AppDialingExit_cid:
	MOV	A,@(0x01)
	LCALL	LibGetCommand
	ADD	A,@(0x00)
	JPNZ	AppDialingExit_ret
AppDialingExit_ringin:
	CLR	program
	RETL	@(1)
AppDialingExit_offhook:
	MOV	A,@(PRO_AppDialingPhone)		; µç»°Õª»ú£¬½øÈë²¦ºÅ³ÌÐò
	LCALL	LibPushProgram
	RETL	@(0)



ORG	0x1c00


AppMenuTab:
	TBL
; main menu
	DB	4,PRO_AppMenuMain	; µÚÒ»ÌõÊÇ³¤¶ÈºÍ±¾³ÌÐòµÄID
	DB	STR_CallList,PRO_AppCallList
	DB	STR_PhoneBook,PRO_AppMenuPhoneBook
	DB	STR_SystemSetting,PRO_AppMenuSystemSetting
	DB	STR_DAM,PRO_AppMenuDAM
; Phone book
	DB	3,PRO_AppMenuPhoneBook
	DB	STR_BrowsePhonebook,PRO_AppBrowsePbook
	DB	STR_EditPhonebook,PRO_AppNewBook
	DB	STR_Deleteall,PRO_AppDeleteBook
; System setting
	DB	5,PRO_AppMenuSystemSetting
	DB	STR_ClockSetting,PRO_AppSetClock
	DB	STR_DateSetting,PRO_AppSetDate
	DB	STR_PhoneSetting,PRO_AppMenuPhoneSetting
	DB	STR_DAMSetting,PRO_AppSetDam
	DB	STR_RestoreDefault,PRO_AppRestoreDefault
; Phone Setting
	DB	6,PRO_AppMenuPhoneSetting
	DB	STR_Ringmelody,PRO_AppSetRingMelody
	DB	STR_Ringvolume,PRO_AppSetRingVolume
	DB	STR_Areacode,PRO_AppSetAreaCode
	DB	STR_Flashtime,PRO_AppSetFlashTime
	DB	STR_Pausetime,PRO_AppSetPauseTime
	DB	STR_LCDcontrast,PRO_AppSetLcdContrast
; Digital Answering Machine
	DB	3,PRO_AppMenuDAM
	DB	STR_Play,PRO_AppPlay
	DB	STR_Record,PRO_AppMenuRecord
	DB	STR_Deleteall,PRO_AppDeleteAllMsg
; record
	DB	3,PRO_AppMenuRecord
	DB	STR_MemoRecord,PRO_AppMemoRecord
	DB	STR_OGM1record,PRO_AppOgm1Record
	DB	STR_OGM2record,PRO_AppOgm2Record
; Recorder ON
	DB	4,PRO_AppMenuRecorderOn
	DB	STR_Setringdelay,PRO_AppSetRingDelay
	DB	STR_Setremotecode,PRO_AppSetRemoteCode
	DB	STR_Setrecordtime,PRO_AppSetRecordTime
	DB	STR_SetOGM,PRO_AppOgmSelect

/*************************************************
AppMenuMain
Ö÷²Ëµ¥
³õÊ¼»¯:	
	
ÏÔÊ¾:	
´ý»ú:	1. Call List
	2. Phone Book
	3. System Setting
	4. Digital Answering Machine
*************************************************/
AppMenuMain:
	MOV	A,@(0)
	JMP	AppMenu

/*************************************************
AppMenuPhoneBook
Ö÷²Ëµ¥
³õÊ¼»¯:	
	
ÏÔÊ¾:	
´ý»ú:	1. Browse Phonebook
	2. Edit Phonebook
	3. Delete all
*************************************************/
AppMenuPhoneBook:
	MOV	A,@(5)
	JMP	AppMenu

/*************************************************
AppMenuSystemSetting
Ö÷²Ëµ¥
³õÊ¼»¯:	
	
ÏÔÊ¾:	
´ý»ú:	1. Clock Setting
	2. Date Setting
	3. Phone Setting
	4. DAM Setting
	5. Restore Default
*************************************************/
AppMenuSystemSetting:
	MOV	A,@(9)
	JMP	AppMenu

/*************************************************
AppMenuPhoneSetting
Ö÷²Ëµ¥
³õÊ¼»¯:	
	
ÏÔÊ¾:	
´ý»ú:	1. Ring melody
	2. Ring volume
	3. Area code
	4. Flash time
	5. Pause time
	6. LCD contrast
*************************************************/
AppMenuPhoneSetting:
	MOV	A,@(15)
	JMP	AppMenu

/*************************************************
AppMenuDAM
Ö÷²Ëµ¥
³õÊ¼»¯:	
	
ÏÔÊ¾:	
´ý»ú:	1. Play
	2. Record
	3. Delete all
*************************************************/
AppMenuDAM:
	MOV	A,@(22)
	JMP	AppMenu

/*************************************************
AppMenuRecord
Ö÷²Ëµ¥
³õÊ¼»¯:	
	
ÏÔÊ¾:	
´ý»ú:	1. Memo Record
	2. OGM 1 record
	3. OGM 2 record
*************************************************/
AppMenuRecord:
	MOV	A,@(26)
	JMP	AppMenu

/*************************************************
AppMenuRecorderOn
Ö÷²Ëµ¥
³õÊ¼»¯:	
	
ÏÔÊ¾:	
´ý»ú:	1. Set ring delay
	2. Set remote code
	3. Set record time
	4. Set OGM
*************************************************/
AppMenuRecorderOn:
	MOV	A,@(30)
	JMP	AppMenu

/*************************************************
AppMenu
input:	acc	-- Table address
input:	r2_ax -- ²Ëµ¥À¸µÄÏÔÊ¾×Ö·û´®ID.
	r2_bx -- °´ÏÂENTER¼üºó½øÈëµÄ³ÌÐòID
	r2_cnt -- ²Ëµ¥À¸³¤¶È(¹²¶àÉÙ¸ö¿ÉÑ¡²Ëµ¥)
	r2_exb -- ±¾³ÌÐòµÄ³ÌÐòID(ÓÃÓÚ·µ»Ø)
*************************************************/
AppMenu:
	BANK	2
	MOV	r2_ax,A
	JPB	sys_flag,PROGRAMINIT,AppMenu_init
	JPB	sys_flag,PROGRAMREIN,AppMenu_rein
	MOV	A,@(0)
	JMP	AppMenu_idle
AppMenu_init:
	CLR	r2_id
	BC	sys_flag,PROGRAMINIT
	JMP	AppMenu_display
AppMenu_rein:
	PAGE	#(LibPushStack)
	CALL	LibPopStack
	MOV	r2_id,A
	CALL	LibPopStack
	CALL	LibStoreCursor
	PAGE	#(VGA)
	CALL	VgaBlankNum2
	CALL	VgaBlankChar
	PAGE	#($)
AppMenu_display:
	
	BC	sys_flag,PROGRAMREIN
	MOV	A,@(1)
AppMenu_idle:
	MOV	ax,A
	RLCA	r2_ax
	AND	A,@(0xfe)
	MOV	bx,A
	CALL	AppMenuTab
	MOV	r2_cnt,A
	MOV	A,ax


; input:	acc r2_ax,r2_bx,r2_cnt
; output:	0 -- none
;		!0 -- ¸Ãmenu_id±»È·ÈÏ£¬ÒªÇó½øÈë¸Ãmenu_idµÄ³ÌÐò
AppMenuList:
	JPNZ	AppMenuList_display
	XORA	sys_msg,@(WM_KEYPRESS)
	JPZ	AppMenuList_key
	RETL	@(0)
AppMenuList_key:
	BANK	2
	XORA	sys_data,@(KEY_UP)
	JPZ	AppMenuList_up
	XORA	sys_data,@(KEY_DOWN)
	JPZ	AppMenuList_down
	XORA	sys_data,@(KEY_ENTER)
	JPZ	AppMenuList_enter
	XORA	sys_data,@(KEY_EXIT)
	JPZ	AppMenuList_exit
	RETL	@(0)
AppMenuList_up:
	INC	r2_id
	
	SUBA	r2_id,r2_cnt
	JPNC	$+2
	CLR	r2_id
	JMP	AppMenuList_display
	
AppMenuList_down:
	MOV	A,r2_id
	JPNZ	$+3
	MOV	r2_id,r2_cnt
	DEC	r2_id
	JMP	AppMenuList_display
	
AppMenuList_enter:
	CALL	AppMenuData
	
	PAGE	#(LibPushStack)
	MOV	A,cursor
	CALL	LibPushStack
	MOV	A,r2_id
	CALL	LibPushStack
	MOV	A,r2_exb
	CALL	LibPushStack
	MOV	A,r2_bx
	CALL	LibPushProgram
	PAGE	#($)
	RETL	@(0)
AppMenuList_exit:
	CLR	program
	RETL	@(0)
AppMenuList_display:
	CALL	AppMenuData

	PAGE	#(VGA)
	CALL	VgaBlankNum2
	CALL	VgaBlankChar
	MOV	A,@(STYLE_LEFT)
	CALL	VgaNum2
	ADDA	r2_id,@(49)
	CALL	VgaNum2
	MOV	A,@(0)
	CALL	VgaNum2
	CALL	VgaDrawNum2
	MOV	A,@(STYLE_LEFT)
	CALL	VgaChar
	MOV	A,r2_ax
	CALL	VgaString
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)
	RETL	@(0)

AppMenuData:
	INC	bx
	MOV	A,bx
	CALL	AppMenuTab
	MOV	r2_exb,A
	INC	bx
	RLCA	r2_id
	AND	A,@(0xfe)
	ADD	bx,A
	MOV	A,bx
	CALL	AppMenuTab
	MOV	r2_ax,A
	INC	bx
	MOV	A,bx
	CALL	AppMenuTab
	MOV	r2_bx,A
	RET


/*************************************************
AppMenuPhone
ÔÚ²é¿´ºÅÂëÊ±°´ÏÂmenu¼ü³öÏÖÒÔÏÂ²Ëµ¥:
1. Pre-dial
2. HF dialing
3. To Phonebook
4. Delete?
5. Delete all?
*************************************************/
AppMenuPhone:
	BANK	3
	JPB	sys_flag,PROGRAMINIT,AppMenuPhone_init
	JPB	sys_flag,PROGRAMREIN,AppMenuPhone_rein
	JMP	AppMenuPhone_idle
AppMenuPhone_init:
	BC	sys_flag,PROGRAMINIT
	CLR	r3_id
	CLR	r3_flag
	CLR	r3_callmenu
	JMP	AppMenuPhone_display
AppMenuPhone_rein:
AppMenuPhone_display:
	CALL	AppMenuPhoneDisplay
AppMenuPhone_idle:
	XORA	sys_msg,@(WM_KEYPRESS)
	JPZ	AppMenuPhone_key
	RETL	@(0)
AppMenuPhone_key:
	XORA	sys_data,@(KEY_UP)
	JPZ	AppMenuPhone_up
	XORA	sys_data,@(KEY_DOWN)
	JPZ	AppMenuPhone_down
	XORA	sys_data,@(KEY_EXIT)
	JPZ	AppMenuPhone_exit
	XORA	sys_data,@(KEY_OK)
	JPZ	AppMenuPhone_ok
	RETL	@(0)
AppMenuPhone_up:
	INC	r3_id
	SUBA	r3_id,@(5)
	JPNC	AppMenuPhoneDisplay
	CLR	r3_id
	JMP	AppMenuPhoneDisplay
AppMenuPhone_down:
	MOV	A,r3_id
	JPNZ	$+3
	MOV	r3_id,@(5)
	DEC	r3_id
	JMP	AppMenuPhoneDisplay
AppMenuPhone_exit:
	CLR	program
	RETL	@(0)
TabAppMenuPhoneDisplay:
	TBL
	RETL	@(STR_PreHFdial)
	RETL	@(STR_HFDialing)
	RETL	@(STR_ToPhonebook)
	RETL	@(STR_Delete)
	RETL	@(STR_Deleteall)
AppMenuPhoneDisplay:
	MOV	A,r3_id
	CALL	TabAppMenuPhoneDisplay
	MOV	r3_ax,A
	PAGE	#(VGA)
	CALL	VgaBlankChar
	MOV	A,@(STYLE_LEFT)
	CALL	VgaChar
	MOV	A,r3_ax
	CALL	VgaString
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)
	RETL	@(0)
AppMenuPhone_ok:
	MOV	A,r3_id
	TBL
	JMP	AppMenuPhone_predial
	JMP	AppMenuPhone_hfdial
	JMP	AppMenuPhone_tophonebook
	JMP	AppMenuPhone_delete
	JMP	AppMenuPhone_deleteall
AppMenuPhone_predial:
	MOV	A,@(PRO_AppPreDial)
	LCALL	LibPushProgram
	RETL	@(0)
AppMenuPhone_hfdial:
	BLOCK	3
	MOV	A,@(131)
	MOV	bx,_RD
	CLR	cnt
AppMenuPhone_hfdial_0:
	SUBA	cnt,bx
	JPZ	AppMenuPhone_hfdial_1
	ADDA	cnt,@(132)
	MOV	_RC,A
	MOV	A,_RD
	JPZ	AppMenuPhone_hfdial_1
	LCALL	LibStoreDialNumber
	INC	cnt
	JMP	AppMenuPhone_hfdial_0
AppMenuPhone_hfdial_1:
	BS	sys_flag,SPKPHONE
	MOV	A,@(PRO_AppDialingPhone)
	LCALL	LibPushProgram
	RETL	@(0)
	
AppMenuPhone_tophonebook:
	MOV	A,@(PRO_AppEditBook)
	LCALL	LibPushProgram
	RETL	@(0)
AppMenuPhone_delete:
	BS	r3_callmenu,0
	JMP	AppMenuPhone_exit
AppMenuPhone_deleteall:
	BS	r3_callmenu,1
	JMP	AppMenuPhone_exit
	
	

AppCallList:
	MOV	A,@(r3_totalcall+0xc0)
	JMP	AppLookOverCall
AppBrowsePbook:
	MOV	A,@(r3_book+0xc0)
	JMP	AppLookOverCall


/*************************************************
AppLookOverCall
²é¿´ºÅÂë
input:		acc Òª²é¿´µÄµØÖ·
³õÊ¼»¯:	

	
ÏÔÊ¾:	
´ý»ú:
	Ê¹ÓÃUPºÍDOWN¼ü·­²é¡£
	r3_id	·­²éµÄIDºÅ, =0 end of list
	r3_flag
		.7 =0, È¡ºÅÂëÎ´Íê±Ï£¬²»ÄÜ°´UP¡¢DOWN¼ü
		   =1, ¿ÉÒÔ°´UP¡¢DOWN¼ü·­²é¡£
		.6 =0, ·ÖÆÁÏÔÊ¾Ç°16Î»
		   =1, ·ÖÆÁÏÔÊ¾ºó16Î»
		.5 =0, ºÅÂëÕý³£ÏÔÊ¾,
		   =1, ºÅÂë·ÖÁ½ÆÁÏÔÊ¾¡£
		.4 =0, ÈËÃûÕý³£ÏÔÊ¾
		   =1, ÈËÃû·ÖÁ½ÆÁÏÔÊ¾¡£
		.3 =0, normal
		   =1, É¾³ý×´Ì¬
	·ÖÆÁÏÔÊ¾Ê±£¬°´"LEFT","RIGHT"¼ü¿ÉÒÔ¿ìËÙ¿´Ç°Ò»ÆÁºÍºóÒ»ÆÁ

note:
	ÒòÎªdialed call³¤¶ÈÎª32Î»£¬ËùÒÔ²»ÄÜ´æµ½phonebookÖÐ¡£
	
	
	
*************************************************/
AppLookOverCall:
	MOV	_RSR,A
	AND	A,@(0x3f)
	MOV	r3_ax,A
	JPB	sys_flag,PROGRAMINIT,AppLookOverCall_init
	JPB	sys_flag,PROGRAMREIN,AppLookOverCall_rein
	JMP	AppLookOverCall_idle
AppLookOverCall_init:
	BC	sys_flag,PROGRAMINIT
	MOV	A,_R0
	JPZ	AppLookOverCall_none
	MOV	r3_id,@(1)			; ´ÓµÚÒ»Ìõ¿ªÊ¼
	CLR	r3_flag
	JMP	AppLookOverCall_display
AppLookOverCall_rein:
	PAGE	#(LibPushStack)
	CALL	LibPopStack
	MOV	r3_id,A
	CALL	LibPopStack
	MOV	r3_flag,A
	PAGE	#($)
AppLookOverCall_display:
	BC	sys_flag,PROGRAMREIN
	
	CALL	AppGetCallInfo			; µÃµ½ºÅÂëÐÅÏ¢
	SUBA	r3_ax,@(r3_totalcall)
	JPZ	AppLookOverCall_display_call
	SUBA	r3_ax,@(r3_book)
	JPNZ	AppLookOverCall_idle
AppLookOverCall_display_book:
	BANK	2
	BS	r2_stamp2,0
	BC	r2_stamp1,0
	BS	sys_flag,STAMP
	JMP	AppLookOverCall_idle
AppLookOverCall_display_call:
	BANK	2
	BS	r2_stamp1,1
	BC	r2_stamp1,0
	BS	sys_flag,STAMP
AppLookOverCall_idle:
	BANK	3
	;ADDA	r3_ax,@(0xc0)
	;MOV	_RSR,A
	
	XORA	sys_msg,@(WM_KEYPRESS)
	JPZ	AppLookOverCall_key
	XORA	sys_msg,@(WM_COMMAND)
	JPZ	AppLookOverCall_command
AppLookOverCall_ret:
	BANK	3
	JPNB	r3_flag,7,AppLookOverCall_ret_1
	JPB	r3_flag,5,AppLookOverCall_ret_2
	JPB	r3_flag,4,AppLookOverCall_ret_2
	JPB	r3_callmenu,0,AppLookOverCall_erase
	JPB	r3_callmenu,1,AppLookOverCall_eraseall
AppLookOverCall_ret_1:
	RETL	@(0)
AppLookOverCall_ret_2:
	BANK	2
	MOV	A,r2_tmr_dial1
	JPNZ	AppLookOverCall_ret_1
	MOV	A,r2_tmr_dial
	JPNZ	AppLookOverCall_ret_1
	BANK	3
	INVB	r3_flag,6
	JMP	AppLookOverCallDisplay
AppLookOverCall_key:
	XORA	sys_data,@(KEY_EXIT)
	JPZ	AppLookOverCall_exit
	JPB	r3_flag,3,AppLookOverCall_ret
	JPNB	r3_flag,7,AppLookOverCall_ret
	JPB	r3_callmenu,0,AppLookOverCall_ret
	JPB	r3_callmenu,1,AppLookOverCall_ret
	XORA	sys_data,@(KEY_UP)
	JPZ	AppLookOverCall_up
	XORA	sys_data,@(KEY_DOWN)
	JPZ	AppLookOverCall_down
	MOV	A,r3_id
	JPZ	AppLookOverCall_ret
	XORA	sys_data,@(KEY_ERASE)
	JPZ	AppLookOverCall_erase
	XORA	sys_data,@(KEY_MENU)
	JPZ	AppLookOverCall_menu
	JPB	r3_flag,5,AppLookOverCall_key_1
	JPB	r3_flag,4,AppLookOverCall_key_1
	JMP	AppLookOverCall_ret
AppLookOverCall_key_1:				; ·ÖÆÁÏÔÊ¾Ê±
	XORA	sys_data,@(KEY_LEFT)
	JPZ	AppLookOverCall_left
	XORA	sys_data,@(KEY_RIGHT)
	JPZ	AppLookOverCall_right
	JMP	AppLookOverCall_ret
AppLookOverCall_exit:
	CLR	r3_callmenu
	LCALL	LibClearDisplaySerialNumber
	BANK	2
	BC	r2_stamp2,0
	BS	sys_flag,STAMP
	CLR	program
	RETL	@(0)
AppLookOverCall_up:
	INC	r3_id
	SUBA	_R0,r3_id
	JPC	AppGetCallInfo
	CLR	r3_id
	JMP	AppGetCallInfo
AppLookOverCall_down:
	MOV	A,r3_id
	JPZ	AppLookOverCall_down_1
	DEC	r3_id
	JMP	AppGetCallInfo
AppLookOverCall_down_1:
	MOV	r3_id,_R0
	JMP	AppGetCallInfo
AppLookOverCall_erase:
	BC	r3_callmenu,0
	MOV	A,r3_id
	CALL	AppEraseCall
	RETL	@(0)
AppLookOverCall_eraseall:
	BC	r3_callmenu,1
	MOV	A,@(0)
	CALL	AppEraseCall
	RETL	@(0)
	
AppLookOverCall_erased:
	BC	r3_flag,3
	JMP	AppGetCallInfo
AppLookOverCall_menu:
	PAGE	#(AppCallerToEditor)
	CALL	AppCallerToEditor
	PAGE	#(LibPushStack)
	MOV	A,r3_flag
	CALL	LibPushStack
	MOV	A,r3_id
	CALL	LibPushStack
	MOV	A,program
	CALL	LibPushStack
	MOV	A,@(PRO_AppMenuPhone)
	CALL	LibPushProgram
	RETL	@(0)
AppLookOverCall_left:				; °´ÏÂ"LEFT"ÏÔÊ¾µ½µÚÒ»ÆÁ
	BC	r3_flag,6
	JMP	AppLookOverCallDisplay
AppLookOverCall_right:				; °´ÏÂ"RIGHT"ÏÔÊ¾µ½µÚ¶þÆÁ
	BS	r3_flag,6
	JMP	AppLookOverCallDisplay
AppLookOverCall_command:
	JPNB	r3_flag,3,AppLookOverCall_command_1
	XORA	sys_data,@(0x03)
	JPZ	AppLookOverCall_erased
	XORA	sys_data,@(0x05)
	JPZ	AppLookOverCall_erased
	RETL	@(0)

AppLookOverCall_command_1:
	XORA	sys_data,@(0x1a)
	JPZ	AppLookOverCall_update
	JMP	AppLookOverCall_ret
AppLookOverCall_update:
	CLR	r3_flag
	BS	r3_flag,7
	BLOCK	1
	
	MOV	_RC,@(8+4)
	SUBA	_RD,@(17)
	JPNC	$+2
	BS	r3_flag,5
	
	MOV	ax,r3_id
	PAGE	#(LibMathHexToBcd)
	CALL	LibMathHexToBcd
	MOV	r3_ax,A
	PAGE	#(VGA)
	MOV	A,@(STYLE_RIGHT)
	CALL	VgaNum1
	SWAPA	r3_ax
	AND	A,@(0x0f)
	ADD	A,@(48)
	CALL	VgaNum1
	ANDA	r3_ax,@(0x0f)
	ADD	A,@(48)
	CALL	VgaNum1
	MOV	A,@(0)
	CALL	VgaNum1
	CALL	VgaDrawNum1
	PAGE	#($)
	
	JMP	AppLookOverCallDisplay
	

AppLookOverCallDisplay:
	BANK	2
	DISI
	CLR	r2_tmr_dial
	MOV	r2_tmr_dial1,@(2)		; 3Ãë»»ÆÁÏÔÊ¾
	ENI
	
	BANK	3
	ANDA	r3_flag,@(0x40)			; »»ÆÁÏÔÊ¾¡£
	OR	A,@(0x20)			; ÏÔÊ¾µÚÈýÐÐ
	LJMP	DisplayCallerPackage
	


;AppLookOverCallDisplay:
;	BANK	2
;	DISI
;	CLR	r2_tmr_dial
;	MOV	r2_tmr_dial1,@(3)		; 3Ãë»»ÆÁÏÔÊ¾
;	ENI
;	
;	BANK	3
;	MOV	ax,r3_id
;	PAGE	#(LibMathHexToBcd)
;	CALL	LibMathHexToBcd
;	MOV	r3_ax,A
;	PAGE	#(VGA)
;	MOV	A,@(STYLE_RIGHT)
;	CALL	VgaNum1
;	SWAPA	r3_ax
;	AND	A,@(0x0f)
;	ADD	A,@(48)
;	CALL	VgaNum1
;	ANDA	r3_ax,@(0x0f)
;	ADD	A,@(48)
;	CALL	VgaNum1
;	MOV	A,@(0)
;	CALL	VgaNum1
;	CALL	VgaDrawNum1
;	
;	
;	;PAGE	#(VGA)
;	CALL	VgaBlankNum2
;	CALL	VgaBlankChar
;	
;
;AppLookOverCallDisplay_number:
;	MOV	A,@(STYLE_LEFT)
;	CALL	VgaNum2
;	PAGE	#($)
;	CLR	r3_cnt
;	JPNB	r3_flag,5,AppLookOverCallDisplay_number_1
;	JPB	r3_flag,6,AppLookOverCallDisplay_number_2
;AppLookOverCallDisplay_number_1:
;	MOV	r3_ax,@(8+4+1)			; ÏÔÊ¾Ç°16Î»ºÅÂë
;	JMP	AppLookOverCallDisplay_number_loop
;AppLookOverCallDisplay_number_2:
;	MOV	r3_ax,@(8+4+1+16)			; ÏÔÊ¾ºó16Î»ºÅÂë
;AppLookOverCallDisplay_number_loop:
;	CALL	AppLookOverCallDisplayValue
;	JPZ	AppLookOverCallDisplay_number_end
;	LCALL	VgaNum2
;	JMP	AppLookOverCallDisplay_number_loop
;	/*
;	BLOCK	1
;	ADDA	r3_cnt,r3_ax
;	MOV	_RC,A
;	MOV	A,_RD
;	JPZ	AppLookOverCallDisplay_number_end
;	LCALL	VgaNum2
;	INC	r3_cnt
;	SUBA	r3_cnt,@(16)
;	JPNZ	AppLookOverCallDisplay_number_loop
;	*/
;AppLookOverCallDisplay_number_end:
;	PAGE	#(VGA)
;	CALL	VgaNum2
;	CALL	VgaDrawNum2
;
;AppLookOverCallDisplay_name:
;	MOV	A,@(STYLE_LEFT)
;	CALL	VgaChar
;	PAGE	#($)
;	CLR	r3_cnt
;	JPNB	r3_flag,4,AppLookOverCallDisplay_name_1
;	JPB	r3_flag,6,AppLookOverCallDisplay_name_2
;AppLookOverCallDisplay_name_1:
;	MOV	r3_ax,@(8+4+1+32+1)		; ÏÔÊ¾Ç°16Î»ÈËÃû
;	JMP	AppLookOverCallDisplay_name_loop
;AppLookOverCallDisplay_name_2:
;	MOV	r3_ax,@(8+4+1+32+1)		; ÏÔÊ¾ºó16Î»ÈËÃû
;AppLookOverCallDisplay_name_loop:
;	CALL	AppLookOverCallDisplayValue
;	JPZ	AppLookOverCallDisplay_name_end
;	LCALL	VgaChar
;	JMP	AppLookOverCallDisplay_name_loop
;	/*
;	BLOCK	1
;	ADDA	r3_cnt,r3_ax
;	MOV	_RC,A
;	MOV	A,_RD
;	JPZ	AppLookOverCallDisplay_name_end
;	LCALL	VgaChar
;	INC	r3_cnt
;	SUBA	r3_cnt,@(16)
;	JPNZ	AppLookOverCallDisplay_name_loop
;	*/
;AppLookOverCallDisplay_name_end:
;	PAGE	#(VGA)
;	CALL	VgaChar
;	CALL	VgaDrawChar
;	PAGE	#($)
;	RETL	@(0)
;
;AppLookOverCallDisplayValue:
;	BLOCK	1
;	SUBA	r3_cnt,@(16)
;	JPZ	AppLookOverCallDisplayValue_ret
;	ADDA	r3_cnt,r3_ax
;	MOV	_RC,A
;	INC	r3_cnt
;	MOV	A,_RD
;AppLookOverCallDisplayValue_ret:
;	RET


AppLookOverCall_end:
	PAGE	#(LibClearDisplaySerialNumber)
	CALL	LibClearDisplaySerialNumber
	PAGE	#(VGA)
	CALL	VgaBlankNum2
	CALL	VgaBlankChar
	MOV	A,@(STYLE_LEFT)
	CALL	VgaChar
	MOV	A,@(STR_EndOfList)
	CALL	VgaString
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	RETL	@(0)

AppLookOverCall_none:
	PAGE	#(LibClearDisplaySerialNumber)
	CALL	LibClearDisplaySerialNumber
	MOV	A,@(PRO_AppNoContent)
	CALL	LibPushProgram
	RETL	@(1)

	
	
AppEraseCall:
	MOV	r3_bx,A
	SUBA	r3_ax,@(r3_totalcall)
	JPZ	AppEraseCall_totalcall
	SUBA	r3_ax,@(r3_dialedcall)
	JPZ	AppEraseCall_dialedcall
	SUBA	r3_ax,@(r3_book)
	JPZ	AppEraseCall_book
	JMP	AppEraseCall_none
AppEraseCall_totalcall:
	MOV	A,@(0x5d)
	JMP	AppEraseCall_1
AppEraseCall_dialedcall:
	MOV	A,@(0x5e)
	JMP	AppEraseCall_1
AppEraseCall_book:
	MOV	A,@(0x5f)
AppEraseCall_1:
	PAGE	#(IIC)
	CALL	IicSendData
	MOV	A,r3_bx
	CALL	IicSendData
	CALL	IicSer
	PAGE	#($)
	;DEC	_R0
	BS	r3_flag,3
AppEraseCall_none:
	RETL	@(0)
	

AppGetCallInfo:
	SUBA	_R0,r3_id
	JPC	AppGetCallInfo_0
	MOV	r3_id,_R0
AppGetCallInfo_0:
	MOV	A,_R0
	JPZ	AppLookOverCall_none
	MOV	A,r3_id
	JPZ	AppLookOverCall_end
	SUBA	r3_ax,@(r3_totalcall)
	JPZ	AppGetCallInfo_answeredcall
	SUBA	r3_ax,@(r3_dialedcall)
	JPZ	AppGetCallInfo_dialedcall
	SUBA	r3_ax,@(r3_book)
	JPZ	AppGetCallInfo_book
	JMP	AppLookOverCall_none
AppGetCallInfo_answeredcall:
	MOV	A,@(0x57)
	JMP	AppGetCallInfo_1
AppGetCallInfo_dialedcall:
	MOV	A,@(0x58)
	JMP	AppGetCallInfo_1
AppGetCallInfo_book:
	MOV	A,@(0x59)
AppGetCallInfo_1:
	PAGE	#(IIC)
	CALL	IicSendData
	MOV	A,r3_id
	CALL	IicSendData
	CALL	IicSer
	;PAGE	#($)
	CLR	r3_flag
	PAGE	#(VGA)
	CALL	VgaBlankNum2
	CALL	VgaBlankChar
	PAGE	#(LibClearDisplaySerialNumber)
	CALL	LibClearDisplaySerialNumber
	PAGE	#($)
AppGetCallInfo_end:
	RETL	@(0)
	


AppMemory1:
	MOV	A,@(128)
	JMP	AppMemory
AppMemory2:
	MOV	A,@(162)
	JMP	AppMemory
AppMemory3:
	MOV	A,@(196)
AppMemory:
	BANK	3
	MOV	r3_id,A
	MOV	r3_ax,A
	MOV	_RC,A
	BLOCK	1
	MOV	A,_RD
	LJPZ	AppNone
	JPB	sys_flag,PROGRAMINIT,AppMemory_init
	JPB	sys_flag,PROGRAMREIN,AppMemory_rein
	JMP	AppMemory_idle
AppMemory_init:
	BC	sys_flag,PROGRAMINIT
	JMP	AppMemory_display
AppMemory_rein:
AppMemory_display:
	BC	sys_flag,PROGRAMREIN
	PAGE	#(VGA)
	CALL	VgaBlankNum2
	CALL	VgaBlankChar
	MOV	A,@(STYLE_RIGHT)
	CALL	VgaNum2
	PAGE	#($)
	INC	r3_ax
	CLR	r3_cnt
AppMemory_display_number:
	BLOCK	1
	ADDA	r3_ax,r3_cnt
	MOV	_RC,A
	MOV	A,_RD
	JPZ	AppMemory_display_number_end
	LCALL	VgaNum2
	INC	r3_cnt
	SUBA	r3_cnt,@(16)
	JPNC	AppMemory_display_number
AppMemory_display_number_end:
	PAGE	#(VGA)
	MOV	A,@(0)
	CALL	VgaNum2
	CALL	VgaDrawNum2
	
	MOV	A,@(STYLE_LEFT)
	CALL	VgaChar
	PAGE	#($)
	ADD	r3_ax,@(16)
	CLR	r3_cnt
AppMemory_display_char:
	BLOCK	1
	ADDA	r3_ax,r3_cnt
	MOV	_RC,A
	MOV	A,_RD
	JPZ	AppMemory_display_char_end
	LCALL	VgaChar
	INC	r3_cnt
	SUBA	r3_cnt,@(16)
	JPNC	AppMemory_display_char
AppMemory_display_char_end:
	PAGE	#(VGA)
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)
	
AppMemory_idle:
	JPB	r3_callmenu,0,AppMemory_erase
	JPB	r3_callmenu,1,AppMemory_eraseall
	XORA	sys_msg,@(WM_KEYPRESS)
	JPZ	AppMemory_key
	;MOV	A,r2_tmr_dial1
	;JPNZ	AppMemory_ret
	;MOV	A,r2_tmr_dial
	;JPZ	AppMemory_exit
AppMemory_ret:
	RETL	@(0)
AppMemory_erase:
	BLOCK	1
	MOV	_RC,r3_id
	CLR	_RD
	BC	r3_callmenu,0
	LJMP	AppNone
AppMemory_eraseall:
	BC	r3_callmenu,1
	MOV	A,@(0x01)
	LCALL	LibPromptBeep
	RETL	@(0)
AppMemory_key:
	XORA	sys_data,@(KEY_EXIT)
	JPZ	AppMemory_exit
	XORA	sys_data,@(KEY_MENU)
	JPZ	AppMemory_menu
	RETL	@(0)
AppMemory_exit:
	CLR	program
	RETL	@(0)
AppMemory_menu:
	MOV	A,r3_id
	PAGE	#(AppMemoryToEditor)
	CALL	AppMemoryToEditor
	PAGE	#(LibPushStack)
	MOV	A,program
	CALL	LibPushStack
	MOV	A,@(PRO_AppMenuPhone)
	CALL	LibPushProgram
	PAGE	#($)
	RETL	@(0)


/*************************************************
AppSetAreaCode
ÉèÖÃÇøÓòÂë
*************************************************/
AppSetAreaCode:
	BANK	3
	JPB	sys_flag,PROGRAMINIT,AppSetAreaCode_init
	JPB	sys_flag,PROGRAMREIN,AppSetAreaCode_rein
	JMP	AppSetAreaCode_idle
AppSetAreaCode_init:
	BC	sys_flag,PROGRAMINIT
	CLR	r3_id
	BLOCK	3
	MOV	_RC,@(233)
	SWAPA	r3_areacode1
	AND	A,@(0x0f)
	MOV	ax,A
	SUB	A,@(9)
	JPNC	AppSetAreaCode_init_1
	ADDA	ax,@(48)
	MOV	_RD,A
	INC	r3_id
	INC	_RC
	ANDA	r3_areacode1,@(0x0f)
	MOV	ax,A
	SUB	A,@(9)
	JPNC	AppSetAreaCode_init_1
	ADDA	ax,@(48)
	MOV	_RD,A
	INC	r3_id
	INC	_RC
	SWAPA	r3_areacode2
	AND	A,@(0x0f)
	MOV	ax,A
	SUB	A,@(9)
	JPNC	AppSetAreaCode_init_1
	ADDA	ax,@(48)
	MOV	_RD,A
	INC	r3_id
	INC	_RC
	ANDA	r3_areacode2,@(0x0f)
	MOV	ax,A
	SUB	A,@(9)
	JPNC	AppSetAreaCode_init_1
	ADDA	ax,@(48)
	MOV	_RD,A
	INC	r3_id
AppSetAreaCode_init_1:
	JMP	AppSetAreaCode_display
AppSetAreaCode_rein:
AppSetAreaCode_display:
	BC	sys_flag,PROGRAMREIN
	PAGE	#(VGA)
	CALL	VgaBlankChar
	MOV	A,@(STYLE_LEFT)
	CALL	VgaChar
	MOV	A,@(STR_PleaseInput)
	CALL	VgaString
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)
	CALL	AppSetAreaCodeDisplay
	
AppSetAreaCode_idle:
	;BANK	3
	BLOCK	3
	XORA	sys_msg,@(WM_KEYPRESS)
	JBS	_STATUS,Z
	RETL	@(0)
AppSetAreaCode_key:
	XORA	sys_data,@(KEY_EXIT)
	JPZ	AppSetAreaCode_exit
	XORA	sys_data,@(KEY_OK)
	JPZ	AppSetAreaCode_ok
	XORA	sys_data,@(KEY_BACK)
	JPZ	AppSetAreaCode_back
	LCALL	LibNumberCheck
	ADD	A,@(0)
	JBC	_STATUS,Z
	RETL	@(0)
AppSetAreaCode_number:
	MOV	r3_ax,A
	SUBA	r3_id,@(4)
	JPC	AppSetAreaCode_out
	ADDA	r3_id,@(233)
	MOV	_RC,A
	MOV	_RD,r3_ax
	INC	r3_id
	JMP	AppSetAreaCodeDisplay
AppSetAreaCode_out:
	RETL	@(0)
AppSetAreaCode_back:
	MOV	A,r3_id
	JPZ	AppSetAreaCode_out
	DEC	r3_id
	JMP	AppSetAreaCodeDisplay
AppSetAreaCode_ok:
	MOV	A,@(0xff)
	MOV	r3_areacode1,A
	MOV	r3_areacode2,A
	MOV	A,r3_id
	JPZ	AppSetAreaCode_ok_1
	MOV	_RC,@(233)
	AND	r3_areacode1,@(0xf0)
	SUBA	_RD,@(48)
	OR	r3_areacode1,A
	SWAP	r3_areacode1
	DEC	r3_id
	JPZ	AppSetAreaCode_ok_1
	INC	_RC
	AND	r3_areacode1,@(0xf0)
	SUBA	_RD,@(48)
	OR	r3_areacode1,A
	DEC	r3_id
	JPZ	AppSetAreaCode_ok_1
	INC	_RC
	AND	r3_areacode2,@(0xf0)
	SUBA	_RD,@(48)
	OR	r3_areacode2,A
	SWAP	r3_areacode2
	DEC	r3_id
	JPZ	AppSetAreaCode_ok_1
	INC	_RC
	AND	r3_areacode2,@(0xf0)
	SUBA	_RD,@(48)
	OR	r3_areacode2,A
AppSetAreaCode_ok_1:
	BS	hardware,SYNCSETTING
AppSetAreaCode_exit:
	CLR	program
	RETL	@(0)
AppSetAreaCodeDisplay:
	PAGE	#(VGA)
	CALL	VgaBlankNum2
	MOV	A,@(STYLE_RIGHT)
	CALL	VgaNum2
	PAGE	#($)
	CLR	r3_cnt
AppSetAreaCodeDisplay_1:
	SUBA	r3_cnt,r3_id
	JPC	AppSetAreaCodeDisplay_end
	BLOCK	3
	ADDA	r3_cnt,@(233)
	MOV	_RC,A
	MOV	A,_RD
	LCALL	VgaNum2
	INC	r3_cnt
	JMP	AppSetAreaCodeDisplay_1
AppSetAreaCodeDisplay_end:
	PAGE	#(VGA)
	MOV	A,@(0)
	CALL	VgaNum2
	CALL	VgaDrawNum2
	PAGE	#($)
	RETL	@(0)

ORG	0x2000
/*************************************************
AppSetClock
ÉèÖÃÊ±ÖÓ
³õÊ¼»¯:	
	»ñÈ¡ÏµÍ³Ê±¼ä
	
ÏÔÊ¾:	
´ý»ú:
	1. ÉèÖÃÐ¡Ê±
	2. ÉèÖÃ·ÖÖÓ
	3. ÉèÖÃÃë
	
	r1_flag
		.7	=0 »¹Ã»ÊäÈëÈÎºÎÊýÖµ£¬ÕâÊ±ÏÔÊ¾Ëæ×ÅÊ±ÖÓ¸üÐÂ
			=1 ¿ªÊ¼ÉèÖÃ£¬ÏÔÊ¾²»¸üÐÂ
		.6	=0 ²»¸Ä±ä¹â±ê
			=1 ¸Ä±ä¹â±ê
*************************************************/
AppSetClock:
	BANK	1
	JPB	sys_flag,PROGRAMINIT,AppSetClock_init
	JPB	sys_flag,PROGRAMREIN,AppSetClock_rein
	MOV	A,@(0)
	JMP	AppSetClock_idle
AppSetClock_init:
	BC	sys_flag,PROGRAMINIT
	MOV	r1_second,r1_rtc_second
	MOV	r1_minute,r1_rtc_second
	MOV	r1_hour,r1_rtc_second
	CALL	AppSetClock_htd
	CLR	r1_id
	CLR	r1_flag
	JMP	AppSetClock_display
AppSetClock_rein:
	PAGE	#(LibPopStack)
	CALL	LibPopStack
	CALL	LibStoreCursor
AppSetClock_display:
	BC	sys_flag,PROGRAMREIN
	PAGE	#(VGA)
	CALL	VgaBlankNum2
	CALL	VgaBlankChar
	MOV	A,@(0x37)
	PAGE	#(LibStoreCursor)
	CALL	LibStoreCursor
	PAGE	#($)
	MOV	A,@(1)
AppSetClock_idle:
	MOV	r1_ax,A
	XORA	sys_msg,@(WM_KEYPRESS)
	JPZ	AppSetClock_keypress
	
	JPB	r1_flag,7,AppSetClock_idle_1
	JPNB	r1_rtc_flag,0,AppSetClock_idle_1
	BC	r1_rtc_flag,0
	MOV	r1_second,r1_rtc_second
	MOV	r1_minute,r1_rtc_minute
	MOV	r1_hour,r1_rtc_hour
	CALL	AppSetClock_htd
	JMP	AppSetClockDisplay
	
AppSetClock_idle_1:
	MOV	A,r1_ax
	JPNZ	AppSetClockDisplay
AppSetClock_ret:
	RETL	@(0)
AppSetClock_keypress:
	XORA	sys_data,@(KEY_LEFT)
	JPZ	AppSetClock_left
	XORA	sys_data,@(KEY_RIGHT)
	JPZ	AppSetClock_right
	XORA	sys_data,@(KEY_EXIT)
	JPZ	AppSetClock_exit
	XORA	sys_data,@(KEY_OK)
	JPZ	AppSetClock_ok
	LCALL	LibNumberCheck
	ADD	A,@(0)
	JPZ	AppSetClock_ret

AppSetClock_num:
	MOV	r1_ax,A
	SUB	r1_ax,@(48)
	BS	r1_flag,7
	MOV	A,r1_id
	TBL
	JMP	AppSetClock_num_hour0
	JMP	AppSetClock_num_hour1
	JMP	AppSetClock_num_minute0
	JMP	AppSetClock_num_minute1
	JMP	AppSetClock_num_second0
	JMP	AppSetClock_num_second1
AppSetClock_num_hour0:
	AND	r1_hour,@(0x0f)
	SWAPA	r1_ax
	AND	A,@(0xf0)
	OR	r1_hour,A
	JMP	AppSetClock_adjust
AppSetClock_num_hour1:
	AND	r1_hour,@(0xf0)
	ANDA	r1_ax,@(0x0f)
	OR	r1_hour,A
	JMP	AppSetClock_adjust
AppSetClock_num_minute0:
	AND	r1_minute,@(0x0f)
	SWAPA	r1_ax
	AND	A,@(0xf0)
	OR	r1_minute,A
	JMP	AppSetClock_adjust
AppSetClock_num_minute1:
	AND	r1_minute,@(0xf0)
	ANDA	r1_ax,@(0x0f)
	OR	r1_minute,A
	JMP	AppSetClock_adjust
AppSetClock_num_second0:
	AND	r1_second,@(0x0f)
	SWAPA	r1_ax
	AND	A,@(0xf0)
	OR	r1_second,A
	JMP	AppSetClock_adjust
AppSetClock_num_second1:
	AND	r1_second,@(0xf0)
	ANDA	r1_ax,@(0x0f)
	OR	r1_second,A
AppSetClock_adjust:				; ¶ÔÊäÈëÖµ½øÐÐÐ£Ñé
	CALL	AppSetClock_dth
	
	SUBA	r1_hour,@(24)
	JPNC	$+3
	MOV	r1_hour,@(23)
	SUBA	r1_minute,@(60)
	JPNC	$+3
	MOV	r1_minute,@(59)
	SUBA	r1_second,@(60)
	JPNC	$+3
	MOV	r1_second,@(59)
	CALL	AppSetClock_htd
	JMP	AppSetClock_right
	
AppSetClock_left:
	MOV	A,r1_id
	JPNZ	$+3
	MOV	r1_id,@(6)
	DEC	r1_id
	BS	r1_flag,6
	JMP	AppSetClockDisplay
AppSetClock_right:
	INC	r1_id
	SUBA	r1_id,@(6)
	JPNC	$+2
	CLR	r1_id
	BS	r1_flag,6
	JMP	AppSetClockDisplay

AppSetClock_exit:
	CLR	program
	RETL	@(0)
AppSetClock_ok:
	CALL	AppSetClock_dth
	
	MOV	r1_rtc_hour,r1_hour
	MOV	r1_rtc_minute,r1_minute
	MOV	r1_rtc_second,r1_second
	BS	r1_rtc_flag,1
	BS	hardware,SYNCCLOCK		; Ê±ÖÓÍ¬²½
	
	CLR	program
	RETL	@(0)

AppSetClockDisplay:
	PAGE	#(VGA)
	MOV	A,@(STYLE_RIGHT)
	CALL	VgaChar
	SWAPA	r1_hour
	AND	A,@(0x0f)
	ADD	A,@(48)
	CALL	VgaChar
	ANDA	r1_hour,@(0x0f)
	ADD	A,@(48)
	CALL	VgaChar
	MOV	A,@(58)
	CALL	VgaChar
	
	SWAPA	r1_minute
	AND	A,@(0x0f)
	ADD	A,@(48)
	CALL	VgaChar
	ANDA	r1_minute,@(0x0f)
	ADD	A,@(48)
	CALL	VgaChar
	MOV	A,@(58)
	CALL	VgaChar
	
	SWAPA	r1_second
	AND	A,@(0x0f)
	ADD	A,@(48)
	CALL	VgaChar
	ANDA	r1_second,@(0x0f)
	ADD	A,@(48)
	CALL	VgaChar
	
	MOV	A,@(32)
	CALL	VgaChar
	
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)

	JPNB	r1_flag,6,AppSetClockDisplay_ret
	BC	r1_flag,6
	MOV	A,r1_id
	CALL	AppSetClock_cursor
	LCALL	LibStoreCursor
AppSetClockDisplay_ret:
	RETL	@(0)

AppSetClock_cursor:
	TBL
	RETL	@(0x37)
	RETL	@(0x38)
	RETL	@(0x3a)
	RETL	@(0x3b)
	RETL	@(0x3d)
	RETL	@(0x3e)
	
AppSetClock_htd:
	PAGE	#(LibMathHexToBcd)
	MOV	ax,r1_hour
	CALL	LibMathHexToBcd
	MOV	r1_hour,A
	MOV	ax,r1_minute
	CALL	LibMathHexToBcd
	MOV	r1_minute,A
	MOV	ax,r1_second
	CALL	LibMathHexToBcd
	MOV	r1_second,A
	PAGE	#($)
	RETL	@(0)

AppSetClock_dth:
	PAGE	#(LibMathBcdToHex)
	MOV	ax,r1_hour
	CALL	LibMathBcdToHex
	MOV	r1_hour,A
	MOV	ax,r1_minute
	CALL	LibMathBcdToHex
	MOV	r1_minute,A
	MOV	ax,r1_second
	CALL	LibMathBcdToHex
	MOV	r1_second,A
	PAGE	#($)
	RETL	@(0)


/*************************************************
AppSetDate
ÉèÖÃÈÕÆÚ
³õÊ¼»¯:	
	»ñÈ¡ÏµÍ³ÈÕÆÚ
	
ÏÔÊ¾:	
´ý»ú:
	1. ÉèÖÃÊÀ¼Í
	2. ÉèÖÃÄê·Ý
	3. ÉèÖÃÔÂ·Ý
	4. ÉèÖÃÌì
	
	r1_flag
		.7	=0 »¹Ã»ÊäÈëÈÎºÎÊýÖµ£¬ÕâÊ±ÏÔÊ¾Ëæ×ÅÊ±ÖÓ¸üÐÂ
			=1 ¿ªÊ¼ÉèÖÃ£¬ÏÔÊ¾²»¸üÐÂ
		.6	=0 ²»¸Ä±ä¹â±ê
			=1 ¸Ä±ä¹â±ê
*************************************************/
AppSetDate:
	BANK	1
	JPB	sys_flag,PROGRAMINIT,AppSetDate_init
	JPB	sys_flag,PROGRAMREIN,AppSetDate_rein
	MOV	A,@(0)
	JMP	AppSetDate_idle
AppSetDate_init:
	BC	sys_flag,PROGRAMINIT
	MOV	r1_century,r1_rtc_century
	MOV	r1_year,r1_rtc_year
	MOV	r1_month,r1_rtc_month
	MOV	r1_day,r1_rtc_day
	CALL	AppSetDate_htd
	CLR	r1_id
	CLR	r1_flag
	JMP	AppSetDate_display
AppSetDate_rein:
	LCALL	LibPopStack
	LCALL	LibStoreCursor
AppSetDate_display:
	BC	sys_flag,PROGRAMREIN
	PAGE	#(VGA)
	CALL	VgaBlankNum2
	CALL	VgaBlankChar
	PAGE	#($)
	MOV	A,@(0x31)
	LCALL	LibStoreCursor
	MOV	A,@(1)
AppSetDate_idle:
	MOV	r1_ax,A
	XORA	sys_msg,@(WM_KEYPRESS)
	JPZ	AppSetDate_keypress
	
	JPB	r1_flag,7,AppSetDate_idle_1
	JPNB	r1_rtc_flag,0,AppSetDate_idle_1
	BC	r1_rtc_flag,0
	MOV	r1_century,r1_rtc_century
	MOV	r1_year,r1_rtc_year
	MOV	r1_month,r1_rtc_month
	MOV	r1_day,r1_rtc_day
	CALL	AppSetDate_htd
	JMP	AppSetDateDisplay
	
AppSetDate_idle_1:
	MOV	A,r1_ax
	JPNZ	AppSetDateDisplay
AppSetDate_ret:
	RETL	@(0)
AppSetDate_keypress:
	XORA	sys_data,@(KEY_LEFT)
	JPZ	AppSetDate_left
	XORA	sys_data,@(KEY_RIGHT)
	JPZ	AppSetDate_right
	XORA	sys_data,@(KEY_EXIT)
	JPZ	AppSetDate_exit
	XORA	sys_data,@(KEY_OK)
	JPZ	AppSetDate_ok
	LCALL	LibNumberCheck
	ADD	A,@(0)
	JPZ	AppSetDate_ret

AppSetDate_num:
	MOV	r1_ax,A
	SUB	r1_ax,@(48)
	BS	r1_flag,7
	MOV	A,r1_id
	TBL
	JMP	AppSetDate_num_century0
	JMP	AppSetDate_num_century1
	JMP	AppSetDate_num_year0
	JMP	AppSetDate_num_year1
	JMP	AppSetDate_num_month0
	JMP	AppSetDate_num_month1
	JMP	AppSetDate_num_day0
	JMP	AppSetDate_num_day1
AppSetDate_num_century0:
	AND	r1_century,@(0x0f)
	SWAPA	r1_ax
	AND	A,@(0xf0)
	OR	r1_century,A
	JMP	AppSetDate_adjust
AppSetDate_num_century1:
	AND	r1_century,@(0xf0)
	ANDA	r1_ax,@(0x0f)
	OR	r1_century,A
	JMP	AppSetDate_adjust
AppSetDate_num_year0:
	AND	r1_year,@(0x0f)
	SWAPA	r1_ax
	AND	A,@(0xf0)
	OR	r1_year,A
	JMP	AppSetDate_adjust
AppSetDate_num_year1:
	AND	r1_year,@(0xf0)
	ANDA	r1_ax,@(0x0f)
	OR	r1_year,A
	JMP	AppSetDate_adjust
AppSetDate_num_month0:
	AND	r1_month,@(0x0f)
	SWAPA	r1_ax
	AND	A,@(0xf0)
	OR	r1_month,A
	JMP	AppSetDate_adjust
AppSetDate_num_month1:
	AND	r1_month,@(0xf0)
	ANDA	r1_ax,@(0x0f)
	OR	r1_month,A
	JMP	AppSetDate_adjust
AppSetDate_num_day0:
	AND	r1_day,@(0x0f)
	SWAPA	r1_ax
	AND	A,@(0xf0)
	OR	r1_day,A
	JMP	AppSetDate_adjust
AppSetDate_num_day1:
	AND	r1_day,@(0xf0)
	ANDA	r1_ax,@(0x0f)
	OR	r1_day,A
AppSetDate_adjust:				; ¶ÔÊäÈëÖµ½øÐÐÐ£Ñé
	CALL	AppSetDate_dth
	
	MOV	A,r1_month
	JPNZ	$+3
	MOV	r1_month,@(1)
	SUBA	r1_month,@(13)
	JPNC	$+3
	MOV	r1_month,@(12)
	
	MOV	A,r1_day
	JPNZ	$+3
	MOV	r1_day,@(1)
	SUBA	r1_month,@(1)
	LCALL	TabMonth
	MOV	ax,A
	SUBA	r1_month,@(2)
	JPNZ	$+5
	LCALL	LibLeapYear
	ADD	ax,A
	SUBA	ax,r1_day
	JPC	$+3
	MOV	r1_day,ax
	
	LCALL	LibWeekCheck
	CALL	AppSetDate_htd
	JMP	AppSetDate_right
	
AppSetDate_left:
	MOV	A,r1_id
	JPNZ	$+3
	MOV	r1_id,@(8)
	DEC	r1_id
	BS	r1_flag,6
	JMP	AppSetDateDisplay
AppSetDate_right:
	INC	r1_id
	SUBA	r1_id,@(8)
	JPNC	$+2
	CLR	r1_id
	BS	r1_flag,6
	JMP	AppSetDateDisplay

AppSetDate_exit:
	CLR	program
	RETL	@(0)
AppSetDate_ok:
	CALL	AppSetDate_dth
	
	MOV	r1_rtc_century,r1_century
	MOV	r1_rtc_year,r1_year
	MOV	r1_rtc_month,r1_month
	MOV	r1_rtc_day,r1_day
	MOV	r1_rtc_week,r1_week
	BS	r1_rtc_flag,1
	BS	hardware,SYNCCLOCK		; Ê±ÖÓÍ¬²½
	
	CLR	program
	RETL	@(0)

AppSetDateDisplay:
	PAGE	#(VGA)
	MOV	A,@(STYLE_LEFT)
	CALL	VgaChar
	MOV	A,@(32)
	CALL	VgaChar
	
	SWAPA	r1_century
	AND	A,@(0x0f)
	ADD	A,@(48)
	CALL	VgaChar
	ANDA	r1_century,@(0x0f)
	ADD	A,@(48)
	CALL	VgaChar
	SWAPA	r1_year
	AND	A,@(0x0f)
	ADD	A,@(48)
	CALL	VgaChar
	ANDA	r1_year,@(0x0f)
	ADD	A,@(48)
	CALL	VgaChar
	MOV	A,@(45)
	CALL	VgaChar
	
	SWAPA	r1_month
	AND	A,@(0x0f)
	ADD	A,@(48)
	CALL	VgaChar
	ANDA	r1_month,@(0x0f)
	ADD	A,@(48)
	CALL	VgaChar
	MOV	A,@(45)
	CALL	VgaChar
	
	SWAPA	r1_day
	AND	A,@(0x0f)
	ADD	A,@(48)
	CALL	VgaChar
	ANDA	r1_day,@(0x0f)
	ADD	A,@(48)
	CALL	VgaChar
	
	MOV	A,@(32)
	CALL	VgaChar
	
	ADDA	r1_week,@(STR_Sun)
	CALL	VgaString
	
	MOV	A,@(46)
	CALL	VgaChar
	
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)

	JPNB	r1_flag,6,AppSetDateDisplay_ret
	BC	r1_flag,6
	MOV	A,r1_id
	CALL	AppSetDate_cursor
	LCALL	LibStoreCursor
AppSetDateDisplay_ret:
	RETL	@(0)

AppSetDate_cursor:
	TBL
	RETL	@(0x31)
	RETL	@(0x32)
	RETL	@(0x33)
	RETL	@(0x34)
	RETL	@(0x36)
	RETL	@(0x37)
	RETL	@(0x39)
	RETL	@(0x3a)
	
AppSetDate_htd:
	PAGE	#(LibMathHexToBcd)
	MOV	ax,r1_century
	CALL	LibMathHexToBcd
	MOV	r1_century,A
	MOV	ax,r1_year
	CALL	LibMathHexToBcd
	MOV	r1_year,A
	MOV	ax,r1_month
	CALL	LibMathHexToBcd
	MOV	r1_month,A
	MOV	ax,r1_day
	CALL	LibMathHexToBcd
	MOV	r1_day,A
	PAGE	#($)
	RETL	@(0)

AppSetDate_dth:
	PAGE	#(LibMathBcdToHex)
	MOV	ax,r1_century
	CALL	LibMathBcdToHex
	MOV	r1_century,A
	MOV	ax,r1_year
	CALL	LibMathBcdToHex
	MOV	r1_year,A
	MOV	ax,r1_month
	CALL	LibMathBcdToHex
	MOV	r1_month,A
	MOV	ax,r1_day
	CALL	LibMathBcdToHex
	MOV	r1_day,A
	PAGE	#($)
	RETL	@(0)







/*************************************************
input:	ax:  µ±Ç°Öµ
	bx:  ¸Ãµ÷ÕûÖµÄÜµ÷ÕûµÄ×îÐ¡Öµ
	exb: ¸Ãµ÷ÕûÖµÄÜµ÷ÕûµÄ×î´óÖµ
output:	acc
	0 -- ÎÞ±ä»¯ (ÒÔÏÂ°´¼üÃ»ÓÐ°´ÏÂ)
	1 -- µ±Ç°Öµ±»¸Ä±ä (ax=¸Ä±äºóµÄÖµ)(UP/DOWN)
	2 -- ×óÒÆ (LEFT)
	3 -- ÓÒÒÆ (RIGHT)
	4 -- È·ÈÏ (OK)
	5 -- È¡Ïû (EXIT)
note:
	±ØÐëÊÇ°´¼üÏÂ²ÅÄÜµ÷ÓÃ
*************************************************/
AppSetValue:
	XORA	sys_data,@(KEY_UP)
	JPZ	AppSetValue_up
	XORA	sys_data,@(KEY_DOWN)
	JPZ	AppSetValue_down
	XORA	sys_data,@(KEY_LEFT)
	JPZ	AppSetValue_left
	XORA	sys_data,@(KEY_RIGHT)
	JPZ	AppSetValue_right
	XORA	sys_data,@(KEY_OK)
	JPZ	AppSetValue_ok
	XORA	sys_data,@(KEY_EXIT)
	JPZ	AppSetValue_exit
	RETL	@(0)
AppSetValue_up:
	SUBA	ax,exb
	JPC	$+3
	INC	ax
	JMP	AppSetValue_value
	MOV	ax,bx				; µ±Ç°Öµ³¬¹ý×î´óÖµ£¬¸³×îÐ¡Öµ
	JMP	AppSetValue_value
AppSetValue_down:
	SUBA	bx,ax
	JPC	$+3
	DEC	ax
	JMP	AppSetValue_value
	MOV	ax,exb				; µ±Ç°Öµ³¬¹ý×îÐ¡Öµ£¬¸³×î´óÖµ
AppSetValue_value:
	RETL	@(1)
AppSetValue_left:
	RETL	@(2)
AppSetValue_right:
	RETL	@(3)
AppSetValue_ok:
	RETL	@(4)
AppSetValue_exit:
	RETL	@(5)

/*************************************************
AppSetBank3

input:	_RSR,acc
	_RSR	bank3 Òªµ÷ÕûµÄ¼Ä´æÆ÷
	acc	¸ß4Î»	×îÐ¡Öµ
		µÍ4Î»	×î´óÖµ
output:	acc
	0 -- ÎÞ±ä»¯ (ÒÔÏÂ°´¼üÃ»ÓÐ°´ÏÂ)
	1 -- µ±Ç°Öµ±»¸Ä±ä (ax=¸Ä±äºóµÄÖµ)(UP/DOWN)
	2 -- ×óÒÆ (LEFT)
	3 -- ÓÒÒÆ (RIGHT)
	4 -- È·ÈÏ (OK)
	5 -- È¡Ïû (EXIT)
note:	¼ì²âUP¡¢DOWN¡¢LEFT¡¢RIGHT¡¢OK¡¢EXIT°´¼ü
*************************************************/
AppSetBank3:
	BANK	3
	MOV	r3_bx,A
	JPB	sys_flag,PROGRAMINIT,AppSetBank3_init
	JPB	sys_flag,PROGRAMREIN,AppSetBank3_rein
	MOV	A,@(0)
	JMP	AppSetBank3_idle
AppSetBank3_init:
	BC	sys_flag,PROGRAMINIT
	CLR	r3_flag
	MOV	r3_id,_R0
	JMP	AppSetBank3_display
AppSetBank3_rein:
AppSetBank3_display:
	BC	sys_flag,PROGRAMREIN
	PAGE	#(VGA)
	CALL	VgaBlankNum2
	CALL	VgaBlankChar
	PAGE	#($)
	MOV	A,@(1)
AppSetBank3_idle:
	MOV	r3_ax,A
	
	XORA	sys_msg,@(WM_KEYPRESS)
	JPZ	AppSetBank3_keypress
AppSetBank3_ret:
	SUBA	r3_ax,@(4)
	JPNZ	$+2
	BS	hardware,SYNCSETTING
	MOV	A,r3_ax
	RET
AppSetBank3_keypress:
	MOV	ax,r3_id
	SWAPA	r3_bx
	AND	A,@(0x0f)
	MOV	bx,A
	ANDA	r3_bx,@(0x0f)
	MOV	exb,A
	CALL	AppSetValue
	ADD	A,@(0)
	JPZ	AppSetBank3_ret
	MOV	r3_ax,A
	SUB	A,@(1)
	JPNZ	AppSetBank3_ret
	MOV	r3_id,ax
	JMP	AppSetBank3_ret

/*************************************************
AppSetRingMelody
ÉèÖÃÁåÉùÀàÐÍ
³õÊ¼»¯:	
	»ñÈ¡µ±Ç°µÄÁåÉù
	
ÏÔÊ¾:	
´ý»ú:
	r3_ringmelody
	=0	Ã»ÓÐÁåÉù£¬ÎÞ·¨ÉèÖÃ
	=!0	ÁåÉùID
	1.  Jingle
	2.  Baby Elephant
	3.  Bonanza
	4.  Choopeta
	5.  For Elise
	6.  Marche Turque
	7.  A Little Night
	8.  Smoke On Water
	9.  The Entertainer
	10. Final Countdown
	11. Twin Peaks
	12. Zorba Le Grec
*************************************************/
AppSetRingMelody:
	BANK	3
	MOV	_RSR,@(r3_ringmelody)
	MOV	A,@(0x1c)
	CALL	AppSetBank3
	TBL
	RETL	@(0)
	JMP	AppSetRingMelody_display
	RETL	@(0)
	RETL	@(0)
	JMP	AppSetRingMelody_ok
	JMP	AppSetRingMelody_exit

AppSetRingMelody_ok:
	MOV	r3_ringmelody,r3_id
AppSetRingMelody_exit:
	MOV	A,@(0x54)
	LCALL	LibSendOneCommand
	CLR	program
	RETL	@(0)
AppSetRingMelody_display:
	MOV	ax,r3_id
	PAGE	#(LibMathHexToBcd)
	CALL	LibMathHexToBcd
	MOV	r3_ax,A
	SUBA	r3_id,@(1)
	PAGE	#(TabRingMelody)
	CALL	TabRingMelody
	MOV	r3_bx,A
	
	PAGE	#(VGA)
	CALL	VgaBlankNum2
	CALL	VgaBlankChar
	
	MOV	A,@(STYLE_LEFT)
	CALL	VgaNum2
	SWAPA	r3_ax
	AND	A,@(0x0f)
	ADD	A,@(48)
	CALL	VgaNum2
	ANDA	r3_ax,@(0x0f)
	ADD	A,@(48)
	CALL	VgaNum2
	MOV	A,@(0)
	CALL	VgaNum2
	CALL	VgaDrawNum2
	
	MOV	A,@(STYLE_LEFT)
	CALL	VgaChar
	MOV	A,r3_bx
	CALL	VgaString
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	
	PAGE	#(IIC)
	MOV	A,@(0x53)
	CALL	IicSendData
	MOV	A,r3_id
	CALL	IicSendData
	CALL	IicSer
	PAGE	#($)
	RETL	@(0)


	


/*************************************************
AppSetRingVolume
ÉèÖÃÁåÉùÒôÁ¿
³õÊ¼»¯:	
	»ñÈ¡µ±Ç°µÄÁåÉùÒôÁ¿
	
ÏÔÊ¾:	
´ý»ú:
	r3_ringvolume
	¹²5µµ£¬×îÐ¡µµÎªOFF
*************************************************/
AppSetRingVolume:
	MOV	_RSR,@(r3_ringvolume)
	MOV	A,@(0x04)
	CALL	AppSetBank3
	TBL
	RETL	@(0)
	JMP	AppSetRingVolume_display
	RETL	@(0)
	RETL	@(0)
	JMP	AppSetRingVolume_ok
	JMP	AppSetRingVolume_exit

AppSetRingVolume_ok:
	MOV	r3_ringvolume,r3_id
AppSetRingVolume_exit:
	CLR	program
	RETL	@(0)
AppSetRingVolume_display:
	
	PAGE	#(VGA)
	CALL	VgaBlankNum2
	CALL	VgaBlankChar
	
	MOV	A,@(STYLE_LEFT)
	CALL	VgaChar
	MOV	A,@(STR_Ringvolume)
	CALL	VgaString
	MOV	A,@(32)
	CALL	VgaChar
	PAGE	#($)
	MOV	A,r3_id
	JPZ	AppSetRingVolume_display_off
	MOV	A,@(7)
	LCALL	VgaChar
	SUBA	r3_id,@(1)
	JPZ	AppSetRingVolume_display_end
	MOV	A,@(9)
	LCALL	VgaChar
	SUBA	r3_id,@(2)
	JPZ	AppSetRingVolume_display_end
	MOV	A,@(11)
	LCALL	VgaChar
	SUBA	r3_id,@(3)
	JPZ	AppSetRingVolume_display_end
	MOV	A,@(13)
	LCALL	VgaChar
	JMP	AppSetRingVolume_display_end
AppSetRingVolume_display_off:
	MOV	A,@(STR_OFF)
	LCALL	VgaString
AppSetRingVolume_display_end:
	PAGE	#(VGA)
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)
	RETL	@(0)


/*************************************************
AppSetFlashTime
ÉèÖÃflashÊ±¼ä
³õÊ¼»¯:	
	»ñÈ¡µ±Ç°µÄflashÊ±¼ä
	
ÏÔÊ¾:	
´ý»ú:
	r3_flashtime
	100ms
	200ms
	300ms
	400ms
	500ms
	600ms
	700ms
	800ms
	900ms
*************************************************/
AppSetFlashTime:
	BANK	3
	MOV	A,r3_flashtime
	LJPZ	AppNone
	MOV	_RSR,@(r3_flashtime)
	MOV	A,@(0x19)
	CALL	AppSetBank3
	TBL
	RETL	@(0)
	JMP	AppSetFlashTime_display
	RETL	@(0)
	RETL	@(0)
	JMP	AppSetFlashTime_ok
	JMP	AppSetFlashTime_exit

AppSetFlashTime_ok:
	MOV	r3_flashtime,r3_id
AppSetFlashTime_exit:
	CLR	program
	RETL	@(0)
AppSetFlashTime_display:
	
	PAGE	#(VGA)
	CALL	VgaBlankNum2
	CALL	VgaBlankChar
	
	MOV	A,@(STYLE_LEFT)
	CALL	VgaChar
	MOV	A,@(STR_Flashtime)
	CALL	VgaString
	MOV	A,@(58)
	CALL	VgaChar
	ADDA	r3_id,@(48)
	CALL	VgaChar
	MOV	A,@(48)
	CALL	VgaChar
	MOV	A,@(48)
	CALL	VgaChar
	MOV	A,@(109)
	CALL	VgaChar
	MOV	A,@(115)
	CALL	VgaChar
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)
	RETL	@(0)


/*************************************************
AppSetPauseTime
ÉèÖÃpauseÊ±¼ä
³õÊ¼»¯:	
	»ñÈ¡µ±Ç°µÄpauseÊ±¼ä
	
ÏÔÊ¾:	
´ý»ú:
	r3_flashtime
	1s
	2s
	3s
	4s
	5s
	6s
*************************************************/
AppSetPauseTime:
	BANK	3
	MOV	A,r3_pausetime
	LJPZ	AppNone
	MOV	_RSR,@(r3_pausetime)
	MOV	A,@(0x16)
	CALL	AppSetBank3
	TBL
	RETL	@(0)
	JMP	AppSetPauseTime_display
	RETL	@(0)
	RETL	@(0)
	JMP	AppSetPauseTime_ok
	JMP	AppSetPauseTime_exit

AppSetPauseTime_ok:
	MOV	r3_pausetime,r3_id
AppSetPauseTime_exit:
	CLR	program
	RETL	@(0)
AppSetPauseTime_display:
	
	PAGE	#(VGA)
	CALL	VgaBlankNum2
	CALL	VgaBlankChar
	
	MOV	A,@(STYLE_LEFT)
	CALL	VgaChar
	MOV	A,@(STR_Pausetime)
	CALL	VgaString
	MOV	A,@(58)
	CALL	VgaChar
	ADDA	r3_id,@(48)
	CALL	VgaChar
	MOV	A,@(115)
	CALL	VgaChar
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)
	RETL	@(0)


/*************************************************
AppSetLcdContrast
ÉèÖÃpauseÊ±¼ä
³õÊ¼»¯:	
	»ñÈ¡µ±Ç°µÄpauseÊ±¼ä
	
ÏÔÊ¾:	
´ý»ú:
	r3_contrast
	20%
	30%
	40%
	50%
	60%
	70%
	80%
*************************************************/
AppSetLcdContrast:
	;BANK	3
	;MOV	A,r3_contrast
	;LJPZ	AppNone
	MOV	_RSR,@(r3_contrast+0xc0)
	MOV	A,@(0x28)
	CALL	AppSetBank3
	TBL
	RETL	@(0)
	JMP	AppSetLcdContrast_display
	RETL	@(0)
	RETL	@(0)
	JMP	AppSetLcdContrast_ok
	JMP	AppSetLcdContrast_exit

AppSetLcdContrast_ok:
	MOV	r3_contrast,r3_id
AppSetLcdContrast_exit:
	MOV	A,r3_contrast
	LCALL	LibLcdContrast
	CLR	program
	RETL	@(0)
AppSetLcdContrast_display:
	MOV	A,r3_id
	LCALL	LibLcdContrast
	
	PAGE	#(VGA)
	CALL	VgaBlankNum2
	CALL	VgaBlankChar
	
	MOV	A,@(STYLE_LEFT)
	CALL	VgaChar
	MOV	A,@(STR_LCDcontrast)
	CALL	VgaString
	MOV	A,@(58)
	CALL	VgaChar
	ADDA	r3_id,@(48)
	CALL	VgaChar
	MOV	A,@(48)
	CALL	VgaChar
	MOV	A,@(37)
	CALL	VgaChar
	MOV	A,@(115)
	CALL	VgaChar
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)
	RETL	@(0)


/*************************************************
AppSetDam
ÉèÖÃ´ðÂ¼»ú
³õÊ¼»¯:	
ÏÔÊ¾:	
´ý»ú:
*************************************************/
AppSetDam:
	BANK	3
	JPB	sys_flag,PROGRAMINIT,AppSetDam_init
	JPB	sys_flag,PROGRAMREIN,AppSetDam_rein
	JMP	AppSetDam_idle
AppSetDam_init:
	BC	sys_flag,PROGRAMINIT
	MOV	r3_flag,r3_ogm
	JMP	AppSetDam_display
AppSetDam_rein:
AppSetDam_display:
	BC	sys_flag,PROGRAMREIN
	LCALL	VgaBlankNum2
	CALL	AppSetDamDisplay
AppSetDam_idle:
	XORA	sys_msg,@(WM_KEYPRESS)
	JBS	_STATUS,Z
	RETL	@(0)
AppSetDam_key:
	XORA	sys_data,@(KEY_UP)
	JPZ	AppSetDam_up
	XORA	sys_data,@(KEY_DOWN)
	JPZ	AppSetDam_down
	XORA	sys_data,@(KEY_OK)
	JPZ	AppSetDam_ok
	XORA	sys_data,@(KEY_EXIT)
	JPZ	AppSetDam_exit
	RETL	@(0)
AppSetDam_up:
AppSetDam_down:
	INVB	r3_flag,7
	JMP	AppSetDamDisplay
AppSetDam_ok:
	AND	r3_ogm,@(~(1<<7))
	ANDA	r3_flag,@(1<<7)
	OR	r3_ogm,A
	JPB	r3_flag,7,AppSetDam_exit
	MOV	A,@(PRO_AppMenuRecorderOn)
	PAGE	#(LibPushProgram)
	CALL	LibPushProgram
	RETL	@(0)
AppSetDam_exit:
	CLR	program
	RETL	@(0)
AppSetDamDisplay:
	JPB	r3_flag,7,AppSetDamDisplay_off
	MOV	A,@(STR_RecorderON)
	JMP	AppSetDamDisplay_1
AppSetDamDisplay_off:
	MOV	A,@(STR_RecorderOFF)
AppSetDamDisplay_1:
	MOV	r3_ax,A
	PAGE	#(VGA)
	CALL	VgaBlankChar
	MOV	A,@(STYLE_LEFT)
	CALL	VgaChar
	MOV	A,r3_ax
	CALL	VgaString
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)
	RETL	@(0)

ORG	0x2400
	


/*************************************************
AppPlay
²¥·Å(°´ÏÂPLAY¼ü)
³õÊ¼»¯:	
	ÏòDSP·¢ËÍ²¥·ÅÃüÁî
ÏÔÊ¾:	
´ý»ú:	
	r3_flag		²¥·ÅÊ±µÄ±êÖ¾Î»
	.7		0-no message
	.6		0-play 1-pause
	.5		0-old  1-new
	.4		0-memo 1-icm
	
*************************************************/
AppPlay:
	JPB	sys_flag,PROGRAMINIT,AppPlay_init
	JPB	sys_flag,PROGRAMREIN,AppPlay_rein
	JMP	AppPlay_idle
AppPlay_init:
	BC	sys_flag,PROGRAMINIT
	MOV	A,@(0x41)			; play
	PAGE	#(LibSendOneCommand)
	CALL	LibSendOneCommand
	CALL	LibInitTimer
	PAGE	#($)
	BANK	3
	MOV	A,r3_totalmsg
	JPZ	AppPlay_nomessage
	CLR	r3_flag
	CLR	r3_id
	MOV	A,r3_newmsg
	JBS	_STATUS,Z
	BS	r3_flag,5
	JMP	AppPlay_display
AppPlay_rein:
AppPlay_display:
	BC	sys_flag,PROGRAMREIN
	CALL	AppDisplayPlayMessage
AppPlay_idle:
	BANK	3
	JPB	r3_flag,6,AppPlay_idle_1
	MOV	A,r3_id
	JPZ	AppPlay_idle_1
	PAGE	#(LibUpdateTimer)
	CALL	LibUpdateTimer
	CALL	LibDisplayTimer
	PAGE	#($)
AppPlay_idle_1:
	BANK	3
	XORA	sys_msg,@(WM_KEYPRESS)
	JPZ	AppPlay_keypress
	XORA	sys_msg,@(WM_COMMAND)
	JPZ	AppPlay_command
	RETL	@(0)
AppPlay_keypress:
	XORA	sys_data,@(KEY_PLAY)
	JPZ	AppPlay_play
	XORA	sys_data,@(KEY_STOP)
	JPZ	AppPlay_stop
	XORA	sys_data,@(KEY_LEFT)
	JPZ	AppPlay_left
	XORA	sys_data,@(KEY_RIGHT)
	JPZ	AppPlay_right
	XORA	sys_data,@(KEY_ERASE)
	JPZ	AppPlay_erase
	LCALL	LibVolAdjust
	RETL	@(0)
AppPlay_play:
	INVB	r3_flag,6
	JPB	r3_flag,6,AppPlay_pause
	MOV	A,@(0x41)			; play
	JMP	AppPlay_play_1
AppPlay_pause:
	MOV	A,@(0x42)			; pause
AppPlay_play_1:
	LCALL	LibSendOneCommand
	JMP	AppDisplayPlayMessage
AppPlay_stop:
	MOV	A,@(0x54)			; stop
	JMP	AppPlay_send
AppPlay_left:
	MOV	A,@(0x44)			; repeat/previous
	JMP	AppPlay_send
AppPlay_right:
	MOV	A,@(0x43)			; skip
	JMP	AppPlay_send
AppPlay_erase:
	MOV	A,@(0x4c)			; erase
	JMP	AppPlay_send
AppPlay_send:
	PAGE	#(LibSendOneCommand)
	CALL	LibSendOneCommand
	RETL	@(0)
AppPlay_command:
	XORA	sys_data,@(0x13)		; return to idle
	JPZ	AppPlay_exit
	XORA	sys_data,@(0x10)		; msg serial
	JPZ	AppPlay_id
	XORA	sys_data,@(0x11)		; msg type
	JPZ	AppPlay_type
	RETL	@(0)
AppPlay_exit:
	CLR	program
	RETL	@(0)
AppPlay_id:
	MOV	A,@(1)
	PAGE	#(LibGetCommand)
	CALL	LibGetCommand
	MOV	r3_id,A
	BC	r3_flag,6
	CALL	LibInitTimer			; Ò»¸öÐÂµÄmsg²¥·Å£¬ÖØÐÂ¼ÆÊ±
	PAGE	#($)
	JMP	AppDisplayPlayMessage
AppPlay_type:
	BANK	3
	BC	r3_flag,5
	MOV	A,@(1)
	LCALL	LibGetCommand
	JPNZ	$+2
	BS	r3_flag,5
	JMP	AppDisplayPlayMessage

AppPlay_nomessage:
	MOV	A,@(PRO_AppNoMessage)
	LCALL	LibPushProgram
	RETL	@(1)
	

AppDisplayPlayMessage:
	BANK	2
	MOV	ax,r2_stamp2
	BANK	3
	AND	ax,@(0xe7)
	JPB	r3_flag,6,$+3
	BS	ax,3
	JMP	$+2
	BS	ax,4
	BANK	2
	MOV	r2_stamp2,ax
	BS	sys_flag,STAMP

	PAGE	#(VGA)
	CALL	VgaBlankNum2
	CALL	VgaBlankChar
	PAGE	#($)
	BANK	3
	MOV	A,r3_id
	JPZ	AppDisplayPlayMessage_1
	MOV	ax,A
	LCALL	LibMathHexToBcd
	MOV	r3_ax,A
	PAGE	#(VGA)
	MOV	A,@(STYLE_LEFT)
	CALL	VgaNum2
	SWAPA	r3_ax
	AND	A,@(0x0f)
	ADD	A,@(48)
	CALL	VgaNum2
	ANDA	r3_ax,@(0x0f)
	ADD	A,@(48)
	CALL	VgaNum2
	MOV	A,@(0)
	CALL	VgaNum2
	CALL	VgaDrawNum2
	PAGE	#($)
AppDisplayPlayMessage_1:
	MOV	A,@(STYLE_LEFT)
	LCALL	VgaChar
	JPB	r3_flag,6,AppDisplayPlayMessage_pause
	MOV	A,@(STR_Play)
	JMP	AppDisplayPlayMessage_2
AppDisplayPlayMessage_pause:
	MOV	A,@(STR_Pause)
AppDisplayPlayMessage_2:
	PAGE	#(VGA)
	CALL	VgaString
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)
	MOV	A,r3_id
	JPZ	AppDisplayPlayMessage_3
	MOV	A,@(1)
	LCALL	LibDisplayTimer
AppDisplayPlayMessage_3:
	RETL	@(0)
	

/*************************************************
AppOgmSelect
OGMÑ¡Ôñ(°´ÏÂOGM¼ü)
³õÊ¼»¯:	
	
ÏÔÊ¾:	
´ý»ú:	
*************************************************/
AppOgmSelect:
	BANK	3
	JPB	sys_flag,PROGRAMINIT,AppOgmSelect_init
	JPB	sys_flag,PROGRAMREIN,AppOgmSelect_rein
	JMP	AppOgmSelect_idle
AppOgmSelect_init:
	BC	sys_flag,PROGRAMINIT
	ANDA	r3_ogm,@(0x0f)
	MOV	r3_id,A
	JMP	AppOgmSelect_display
AppOgmSelect_rein:
	PAGE	#(LibPushStack)
	CALL	LibPopStack
	MOV	r3_id,A
AppOgmSelect_display:
	BC	sys_flag,PROGRAMREIN
	PAGE	#(VGA)
	CALL	VgaBlankNum2
	CALL	VgaBlankChar
	MOV	A,@(STYLE_LEFT)
	CALL	VgaChar
	MOV	A,@(STR_OGM)
	CALL	VgaString
	MOV	A,@(48+1)
	CALL	VgaChar
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	MOV	A,@(STYLE_RIGHT)
	CALL	VgaChar
	MOV	A,@(STR_OGM)
	CALL	VgaString
	MOV	A,@(48+2)
	CALL	VgaChar
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)
	CALL	AppOgmSelectDisplay
AppOgmSelect_idle:
	
	XORA	sys_msg,@(WM_KEYPRESS)
	JBS	_STATUS,Z
	RETL	@(0)

AppOgmSelect_key:
	XORA	sys_data,@(KEY_LEFT)
	JPZ	AppOgmSelect_change
	XORA	sys_data,@(KEY_RIGHT)
	JPZ	AppOgmSelect_change
	XORA	sys_data,@(KEY_OK)
	JPZ	AppOgmSelect_ok
	XORA	sys_data,@(KEY_PLAY)
	JPZ	AppOgmSelect_play
	XORA	sys_data,@(KEY_OGM)
	JPZ	AppOgmSelect_record
	XORA	sys_data,@(KEY_EXIT)
	JPZ	AppOgmSelect_exit
	RETL	@(0)
AppOgmSelect_change:
	INC	r3_id
	SUBA	r3_id,@(3)
	JPNC	$+3
	MOV	r3_id,@(1)
	JMP	AppOgmSelectDisplay
AppOgmSelect_ok:
	AND	r3_ogm,@(0xf0)
	ADD	r3_ogm,r3_id			; È·ÈÏºó±£´æogm
	BS	hardware,SYNCSETTING		; ·¢ËÍÉèÖÃ
AppOgmSelect_exit:
	CLR	program				; ÍË³ö³ÌÐò
	CALL	AppOgmSelectDisplay_return
	RETL	@(0)
AppOgmSelect_play:
	SUBA	r3_id,@(1)
	JPZ	AppOgmSelect_play_1
	SUB	A,@(1)
	JPZ	AppOgmSelect_play_2
	RETL	@(0)
AppOgmSelect_play_1:
	MOV	A,@(PRO_AppOgm1Play)
	JMP	AppOgmSelect_play_ret
AppOgmSelect_play_2:
	MOV	A,@(PRO_AppOgm2Play)
AppOgmSelect_play_ret:
AppOgmSelect_record_ret:
	MOV	r3_ax,A
	PAGE	#(LibPushStack)
	MOV	A,r3_id
	CALL	LibPushStack
	MOV	A,@(PRO_AppOgmSelect)
	CALL	LibPushStack
	MOV	A,r3_ax
	CALL	LibPushProgram
	PAGE	#($)
	CALL	AppOgmSelectDisplay_return
	RETL	@(0)

AppOgmSelect_record:
	SUBA	r3_id,@(1)
	JPZ	AppOgmSelect_record_1
	SUB	A,@(1)
	JPZ	AppOgmSelect_record_2
	RETL	@(0)
AppOgmSelect_record_1:
	MOV	A,@(PRO_AppOgm1Record)
	JMP	AppOgmSelect_record_ret
AppOgmSelect_record_2:
	MOV	A,@(PRO_AppOgm2Record)
	JMP	AppOgmSelect_record_ret

AppOgmSelectDisplay:
	CLR	r3_ax
	CLR	r3_bx
	SUBA	r3_id,@(1)
	JPZ	AppOgmSelectDisplay_1
	SUB	A,@(1)
	JPZ	AppOgmSelectDisplay_2
	JMP	AppOgmSelectDisplay_3
AppOgmSelectDisplay_1:
	MOV	r3_ax,@(0x80)
	JMP	AppOgmSelectDisplay_3
AppOgmSelectDisplay_2:
	MOV	r3_bx,@(0x80)
	JMP	AppOgmSelectDisplay_3
AppOgmSelectDisplay_return:
	CLR	r3_ax
	CLR	r3_bx
	
AppOgmSelectDisplay_3:
	PAGE	#(VGA)
	ADDA	r3_ax,@(0x00+0x00+0x07)
	CALL	VgaFlash
	ADDA	r3_ax,@(0x00+0x10+0x07)
	CALL	VgaFlash
	ADDA	r3_ax,@(0x00+0x20+0x07)
	CALL	VgaFlash
	ADDA	r3_ax,@(0x00+0x30+0x07)
	CALL	VgaFlash
	ADDA	r3_bx,@(0x00+0x40+0x08)
	CALL	VgaFlash
	ADDA	r3_bx,@(0x00+0x50+0x08)
	CALL	VgaFlash
	ADDA	r3_bx,@(0x00+0x60+0x08)
	CALL	VgaFlash
	ADDA	r3_bx,@(0x00+0x70+0x08)
	CALL	VgaFlash
	PAGE	#($)
	RETL	@(0)
	
	
/*************************************************
AppOneMessage
input:		acc
		.7	0-record 1-play
		.3~.0	0 - memo
			!0 - ogm
Â¼memo/OGM£¬»Ø·Åmemo/OGM
³õÊ¼»¯:	
	ÏòDSP·¢ËÍÂ¼Òô/·ÅÒôÃüÁî
ÏÔÊ¾:	
´ý»ú:	
	r3_id		Â¼Òô/·ÅÒôµÄÀàÐÍ
		.7	0-record 1-play
		.3~.0	0 - memo
			!0 - ogm

	r3_flag		Â¼ÒôÊ±µÄ±êÖ¾Î»
	.7		0-none 1-recording/playing
*************************************************/
AppOneMessage:
	BANK	3
	MOV	r3_ax,A
	JPB	sys_flag,PROGRAMINIT,AppOneMessage_init
	JPB	sys_flag,PROGRAMREIN,AppOneMessage_rein
	JMP	AppOneMessage_idle
AppOneMessage_init:
	BC	sys_flag,PROGRAMINIT
	CLR	r3_flag
	MOV	r3_id,r3_ax
	AND	A,@(0x0f)
	JPNZ	AppOneMessage_init_ogm
AppOneMessage_init_memo:
	JPB	r3_id,7,AppOneMessage_init_1	; »Ø·Å²»ÓÃ·¢ËÍ²¥·ÅÃüÁî
	MOV	A,@(0x46)			; record memo
	LCALL	LibSendOneCommand
	JMP	AppOneMessage_init_1
AppOneMessage_init_ogm:
	JPB	r3_id,7,$+3			; »Ø·Å
	MOV	A,@(0x4b)			; record ogm
	JMP	$+2
	MOV	A,@(0x4a)			; play ogm
	PAGE	#(IIC)
	CALL	IicSendData
	ANDA	r3_id,@(0x0f)
	CALL	IicSendData
	CALL	IicSer
AppOneMessage_init_1:
	PAGE	#(LibInitTimer)
	CALL	LibInitTimer
	PAGE	#($)
	JMP	AppOneMessage_display
AppOneMessage_rein:
AppOneMessage_display:
	BC	sys_flag,PROGRAMREIN
	CALL	AppOneMessageDisplay
	BANK	3
	JPNB	r3_id,7,AppOneMessage_idle
	MOV	A,@(1)
	LCALL	LibDisplayTimer
AppOneMessage_idle:
	BANK	3
	JPB	r3_id,7,AppOneMessage_idle_1	; play, Ö±½Ó¼ÆÊ±
	JPNB	r3_flag,7,AppOneMessage_idle_2	; record, µÈµ½¿ªÊ¼Â¼ÒôÊ±²Å¼ÆÊ±
AppOneMessage_idle_1:
	PAGE	#(LibUpdateTimer)
	CALL	LibUpdateTimer
	CALL	LibDisplayTimer
	PAGE	#($)
	BANK	3
AppOneMessage_idle_2:
	XORA	sys_msg,@(WM_KEYPRESS)
	JPZ	AppOneMessage_key
	XORA	sys_msg,@(WM_COMMAND)
	JPZ	AppOneMessage_command
	RETL	@(0)
AppOneMessage_key:
	XORA	sys_data,@(KEY_STOP)
	JPZ	AppOneMessage_key_stop
	JPB	r3_id,7,AppOneMessage_key_play
	MOV	A,r3_id
	JPZ	AppOneMessage_key_memo
	XORA	sys_data,@(KEY_OGM)
	JPZ	AppOneMessage_key_stop
	RETL	@(0)
AppOneMessage_key_memo:
	XORA	sys_data,@(KEY_MEMO)
	JPZ	AppOneMessage_key_stop
	RETL	@(0)
AppOneMessage_key_play:
	XORA	sys_data,@(KEY_ERASE)
	JPZ	AppOneMessage_erase
	RETL	@(0)
AppOneMessage_key_stop:
	MOV	A,@(0x54)			; stop
	LCALL	LibSendOneCommand
AppOneMessage_stop:
	JPB	r3_id,7,AppOneMessage_stop_ret	; play, Í£Ö¹ºó»Øµ½ÉÏÒ»×´Ì¬
	MOV	A,r3_id
	JPZ	AppOneMessage_stop_memo
	SUB	A,@(1)
	JPZ	AppOneMessage_stop_ogm1
	ADD	A,@(1)
	JPZ	AppOneMessage_stop_ogm2
	JMP	AppOneMessage_stop_ret
AppOneMessage_stop_memo:
	MOV	A,@(PRO_AppMemoPlay)
	JMP	AppOneMessage_stop_1
AppOneMessage_stop_ogm1:
	MOV	A,@(PRO_AppOgm1Play)
	JMP	AppOneMessage_stop_1
AppOneMessage_stop_ogm2:
	MOV	A,@(PRO_AppOgm2Play)
	;JMP	AppOneMessage_stop_1
AppOneMessage_stop_1:
	LCALL	LibPushProgram
AppOneMessage_stop_ret:
	CLR	program
	RETL	@(0)

AppOneMessage_erase:
	MOV	A,@(0x4c)
	PAGE	#(LibSendOneCommand)
	CALL	LibSendOneCommand
	RETL	@(0)

AppOneMessage_command:
	XORA	sys_data,@(0x18)
	JPZ	AppOneMessage_mfull
	XORA	sys_data,@(0x12)
	JPZ	AppOneMessage_start
	XORA	sys_data,@(0x13)
	JPZ	AppOneMessage_return
	RETL	@(0)
AppOneMessage_mfull:
	BS	r3_ogm,6
	BC	r3_flag,7
	RETL	@(0)
	JMP	AppOneMessage_stop
AppOneMessage_start:
	BS	r3_flag,7
	MOV	A,@(1)
	PAGE	#(LibDisplayTimer)
	CALL	LibDisplayTimer
	RETL	@(0)
AppOneMessage_return:
	JMP	AppOneMessage_stop

AppOneMessageDisplay:
	BANK	3
	PAGE	#(VGA)
	CALL	VgaBlankNum2
	CALL	VgaBlankChar
	MOV	A,@(STYLE_LEFT)
	CALL	VgaChar
	PAGE	#($)
	ANDA	r3_id,@(0x0f)
	JPZ	AppOneMessageDisplay_memo
	PAGE	#(VGA)
	MOV	A,@(STR_OGM)
	CALL	VgaString
	ANDA	r3_id,@(0x0f)
	ADD	A,@(48)
	CALL	VgaChar
	PAGE	#($)
	JMP	AppOneMessageDisplay_1
AppOneMessageDisplay_memo:
	MOV	A,@(STR_Memo)
	LCALL	VgaString
AppOneMessageDisplay_1:
	PAGE	#(VGA)
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)
	RETL	@(0)



AppMemoRecord:
	MOV	A,@(0x00)
	JMP	AppOneMessage

AppOgm1Record:
	MOV	A,@(0x01)
	JMP	AppOneMessage

AppOgm2Record:
	MOV	A,@(0x02)
	JMP	AppOneMessage

AppMemoPlay:
	MOV	A,@(0x80)
	JMP	AppOneMessage
AppOgm1Play:
	MOV	A,@(0x81)
	JMP	AppOneMessage
AppOgm2Play:
	MOV	A,@(0x82)
	JMP	AppOneMessage




/*************************************************
AppSetRingDelay
ÉèÖÃÁåÉù´ÎÊý
¹²3ÖÖ£¬2 4 6
*************************************************/
AppSetRingDelay:
	BANK	3
	JPB	sys_flag,PROGRAMINIT,AppSetRingDelay_init
	JPB	sys_flag,PROGRAMREIN,AppSetRingDelay_rein
	JMP	AppSetRingDelay_idle
AppSetRingDelay_init:
	BC	sys_flag,PROGRAMINIT
	RRCA	r3_ringdelay
	AND	A,@(0x03)
	MOV	r3_id,A
	CLR	r3_flag
	JMP	AppSetRingDelay_display
AppSetRingDelay_rein:
AppSetRingDelay_display:
	PAGE	#(VGA)
	CALL	VgaBlankNum2
	MOV	A,@(STYLE_LEFT)
	CALL	VgaNum2
	MOV	A,@(32)
	CALL	VgaNum2
	MOV	A,@(50)
	CALL	VgaNum2
	MOV	A,@(32)
	CALL	VgaNum2
	MOV	A,@(52)
	CALL	VgaNum2
	MOV	A,@(32)
	CALL	VgaNum2
	MOV	A,@(54)
	CALL	VgaNum2
	MOV	A,@(0)
	CALL	VgaNum2
	CALL	VgaDrawNum2
	CALL	VgaBlankChar
	MOV	A,@(STYLE_LEFT)
	CALL	VgaChar
	MOV	A,@(32)
	CALL	VgaChar
	MOV	A,@(STR_RingTimes)
	CALL	VgaString
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)
	CALL	AppSetRingDelayDisplay
AppSetRingDelay_idle:
	XORA	sys_msg,@(WM_KEYPRESS)
	JBS	_STATUS,Z
	RETL	@(0)
AppSetRingDelay_key:
	XORA	sys_data,@(KEY_UP)
	JPZ	AppSetRingDelay_up
	XORA	sys_data,@(KEY_DOWN)
	JPZ	AppSetRingDelay_down
	XORA	sys_data,@(KEY_EXIT)
	JPZ	AppSetRingDelay_exit
	XORA	sys_data,@(KEY_OK)
	JPZ	AppSetRingDelay_ok
	RETL	@(0)
AppSetRingDelay_up:
	INC	r3_id
	SUBA	r3_id,@(4)
	JPNC	AppSetRingDelayDisplay
	MOV	r3_id,@(1)
	JMP	AppSetRingDelayDisplay
AppSetRingDelay_down:
	DEC	r3_id
	JPNZ	AppSetRingDelayDisplay
	MOV	r3_id,@(3)
	JMP	AppSetRingDelayDisplay
AppSetRingDelay_ok:
	RLCA	r3_id
	AND	A,@(0x06)
	MOV	r3_ringdelay,A
	BS	hardware,SYNCSETTING		; Í¬²½ÉèÖÃ
AppSetRingDelay_exit:
	CLR	r3_id
	CALL	AppSetRingDelayDisplay
	CLR	program
	RETL	@(0)
AppSetRingDelayDisplay:
	PAGE	#(VGA)
	MOV	A,@(0x17)
	CALL	VgaFlash
	MOV	A,@(0x37)
	CALL	VgaFlash
	MOV	A,@(0x57)
	CALL	VgaFlash
	PAGE	#($)
	MOV	A,r3_id
	JPZ	AppSetRingDelayDisplay_ret
	RLCA	r3_id
	AND	A,@(0x06)
	MOV	ax,A
	DEC	ax
	SWAPA	ax
	ADD	A,@(0x87)
	PAGE	#(VGA)
	CALL	VgaFlash
	PAGE	#($)
AppSetRingDelayDisplay_ret:
	RETL	@(0)



/*************************************************
AppSetRemoteCode
ÉèÖÃÒ£¿ØÃÜÂë£¬4Î»

r3_id
r3_flag
	.7	=0 µÚÒ»´ÎÊäÈë×´Ì¬ =1 È·ÈÏ×´Ì¬
*************************************************/
AppSetRemoteCode:
	BANK	3
	JPB	sys_flag,PROGRAMINIT,AppSetRemoteCode_init
	JPB	sys_flag,PROGRAMREIN,AppSetRemoteCode_rein
	JMP	AppSetRemoteCode_idle
AppSetRemoteCode_init:
	BC	sys_flag,PROGRAMINIT
	CLR	r3_id
	CLR	r3_flag
	JMP	AppSetRemoteCode_display
AppSetRemoteCode_rein:
AppSetRemoteCode_display:
	BC	sys_flag,PROGRAMREIN
	LCALL	VgaBlankNum2
	CALL	AppSetRemoteCodeDisplay
AppSetRemoteCode_idle:
	XORA	sys_msg,@(WM_KEYPRESS)
	JBS	_STATUS,Z
	RETL	@(0)
AppSetRemoteCode_key:
	XORA	sys_data,@(KEY_OK)
	JPZ	AppSetRemoteCode_ok
	XORA	sys_data,@(KEY_EXIT)
	JPZ	AppSetRemoteCode_exit
	LCALL	LibNumberCheck
	ADD	A,@(0)
	JBC	_STATUS,Z
	RETL	@(0)
AppSetRemoteCode_number:
	MOV	r3_ax,A
	SUBA	r3_id,@(4)
	JPC	AppSetRemoteCode_err
	BLOCK	3
	ADDA	r3_id,@(233)
	MOV	_RC,A
	JPB	r3_flag,7,AppSetRemoteCode_confirm
	MOV	_RD,r3_ax
	JMP	AppSetRemoteCode_number_1
AppSetRemoteCode_confirm:
	XORA	_RD,r3_ax
	JPNZ	AppSetRemoteCode_fail
AppSetRemoteCode_number_1:
	INC	r3_id
	JMP	AppSetRemoteCodeDisplay
AppSetRemoteCode_ok:
	JPB	r3_flag,7,AppSetRemoteCode_ok_1
	SUBA	r3_id,@(4)
	JPNC	AppSetRemoteCode_err
	BS	r3_flag,7
	CLR	r3_id
	JMP	AppSetRemoteCodeDisplay
AppSetRemoteCode_ok_1:
	SUBA	r3_id,@(4)
	JPNC	AppSetRemoteCode_fail
	BLOCK	3
	MOV	_RC,@(233)
	SUBA	_RD,@(48)
	MOV	r3_remotecode1,A
	SWAP	r3_remotecode1
	INC	_RC
	SUBA	_RD,@(48)
	ADD	r3_remotecode1,A
	INC	_RC
	SUBA	_RD,@(48)
	MOV	r3_remotecode2,A
	SWAP	r3_remotecode2
	INC	_RC
	SUBA	_RD,@(48)
	ADD	r3_remotecode2,A
	BS	hardware,SYNCSETTING
	MOV	A,@(PRO_AppSuccessfull)
	PAGE	#(LibPushProgram)
	CALL	LibPushProgram
	RETL	@(0)
AppSetRemoteCode_exit:
	MOV	A,@(0x01)
	LCALL	LibPromptBeep
AppSetRemoteCode_fail:
	CLR	program
	RETL	@(0)
AppSetRemoteCode_err:
	MOV	A,@(0x01)
	LCALL	LibPromptBeep
	RETL	@(0)
AppSetRemoteCodeDisplay:
	JPB	r3_flag,7,AppSetRemoteCodeDisplay_1
	MOV	A,@(STR_Input)
	JMP	AppSetRemoteCodeDisplay_2
AppSetRemoteCodeDisplay_1:
	MOV	A,@(STR_Again)
AppSetRemoteCodeDisplay_2:
	MOV	r3_ax,A
	PAGE	#(VGA)
	CALL	VgaBlankChar
	MOV	A,@(STYLE_LEFT)
	CALL	VgaChar
	MOV	A,r3_ax
	CALL	VgaString
	MOV	A,@(58)
	CALL	VgaChar
	PAGE	#($)
	MOV	r3_cnt,r3_id
AppSetRemoteCodeDisplay_3:
	MOV	A,r3_cnt
	JPZ	AppSetRemoteCodeDisplay_end
	MOV	A,@(42)
	LCALL	VgaChar
	DEC	r3_cnt
	JMP	AppSetRemoteCodeDisplay_3
AppSetRemoteCodeDisplay_end:
	PAGE	#(VGA)
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)
	RETL	@(0)


/*************************************************
AppSetRecordTime
ÉèÖÃÂ¼ÒôÊ±¼ä£¬¼´Ñ¹Ëõ±È¡£

r3_flag
	.7	=0 low; =1 high

*************************************************/
AppSetRecordTime:
	BANK	3
	JPB	sys_flag,PROGRAMINIT,AppSetRecordTime_init
	JPB	sys_flag,PROGRAMREIN,AppSetRecordTime_rein
	JMP	AppSetRecordTime_idle
AppSetRecordTime_init:
	BC	sys_flag,PROGRAMINIT
	CLR	r3_flag
	SUBA	r3_rate,@(5)
	JPNC	AppSetRecordTime_display
	BS	r3_flag,7
	JMP	AppSetRecordTime_display
AppSetRecordTime_rein:
AppSetRecordTime_display:
	BC	sys_flag,PROGRAMREIN
	LCALL	VgaBlankNum2
	CALL	AppSetRecordTimeDisplay
AppSetRecordTime_idle:
	XORA	sys_msg,@(WM_KEYPRESS)
	JPZ	AppSetRecordTime_key
	RETL	@(0)
AppSetRecordTime_key:
	XORA	sys_data,@(KEY_UP)
	JPZ	AppSetRecordTime_up
	XORA	sys_data,@(KEY_DOWN)
	JPZ	AppSetRecordTime_down
	XORA	sys_data,@(KEY_OK)
	JPZ	AppSetRecordTime_ok
	XORA	sys_data,@(KEY_EXIT)
	JPZ	AppSetRecordTime_exit
	RETL	@(0)
AppSetRecordTime_up:
AppSetRecordTime_down:
	INVB	r3_flag,7
	JMP	AppSetRecordTimeDisplay
AppSetRecordTime_ok:
	BS	hardware,SYNCSETTING
	JPB	r3_flag,7,AppSetRecordTime_ok_1
	MOV	A,@(1)
	JMP	AppSetRecordTime_ok_2
AppSetRecordTime_ok_1:
	MOV	A,@(5)
AppSetRecordTime_ok_2:
	MOV	r3_rate,A
AppSetRecordTime_exit:
	CLR	program
	RETL	@(0)
AppSetRecordTimeDisplay:
	JPB	r3_flag,7,AppSetRecordTimeDisplay_1
	MOV	A,@(STR_LowQuality)
	JMP	AppSetRecordTimeDisplay_2
AppSetRecordTimeDisplay_1:
	MOV	A,@(STR_HighQuality)
AppSetRecordTimeDisplay_2:
	MOV	r3_ax,A
	PAGE	#(VGA)
	CALL	VgaBlankChar
	MOV	A,@(STYLE_LEFT)
	CALL	VgaChar
	MOV	A,r3_ax
	CALL	VgaString
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)
	RETL	@(0)
	

/*************************************************
AppOnoffSelect
¸Ä±ä´ðÂ¼»úon/off×´Ì¬
³õÊ¼»¯:	
ÏÔÊ¾:	
´ý»ú:
*************************************************/
AppOnoffSelect:
	BANK	3
	JPB	sys_flag,PROGRAMINIT,AppOnoffSelect_init
	JPB	sys_flag,PROGRAMREIN,AppOnoffSelect_rein
	JMP	AppOnoffSelect_idle
AppOnoffSelect_init:
	BC	sys_flag,PROGRAMINIT
	INVB	r3_ogm,7
	JMP	AppOnoffSelect_display
AppOnoffSelect_rein:
AppOnoffSelect_display:
	BC	sys_flag,PROGRAMREIN
	CALL	AppOnoffSelectDisplay
	
	
AppOnoffSelect_idle:
	XORA	sys_msg,@(WM_KEYPRESS)
	JPZ	AppOnoffSelect_key
	BANK	2
	MOV	A,r2_tmr_dial1
	JPNZ	AppOnoffSelect_ret
	MOV	A,r2_tmr_dial
	JPNZ	AppOnoffSelect_ret
AppOnoffSelect_ok:
	BANK	3
	JPB	r3_ogm,7,AppOnoffSelect_exit	; off×´Ì¬£¬2sºó×Ô¶¯ÍË³ö
	MOV	A,@(PRO_AppMenuRecorderOn)	; on×´Ì¬£¬2sºó×Ô¶¯½øÈëÉèÖÃ²Ëµ¥
	PAGE	#(LibPushProgram)
	CALL	LibPushProgram
	BS	hardware,SYNCSETTING
AppOnoffSelect_ret:
	RETL	@(0)
AppOnoffSelect_key:
	XORA	sys_data,@(KEY_UP)
	JPZ	AppOnoffSelect_adjust
	XORA	sys_data,@(KEY_DOWN)
	JPZ	AppOnoffSelect_adjust
	XORA	sys_data,@(KEY_ONOFF)
	JPZ	AppOnoffSelect_adjust
	XORA	sys_data,@(KEY_EXIT)
	JPZ	AppOnoffSelect_exit
	XORA	sys_data,@(KEY_MENU)
	JPZ	AppOnoffSelect_ok
	RETL	@(0)
AppOnoffSelect_adjust:
	INVB	r3_ogm,7
	JMP	AppOnoffSelectDisplay
AppOnoffSelect_exit:
	CLR	program
	BS	hardware,SYNCSETTING
	RETL	@(0)

AppOnoffSelectDisplay:
	JPB	r3_ogm,7,AppOnoffSelectDisplay_off
	MOV	A,@(STR_RecorderON)
	JMP	AppOnoffSelectDisplay_1
AppOnoffSelectDisplay_off:
	MOV	A,@(STR_RecorderOFF)
AppOnoffSelectDisplay_1:
	MOV	r3_ax,A
	PAGE	#(VGA)
	CALL	VgaBlankNum2
	CALL	VgaBlankChar
	MOV	A,@(STYLE_LEFT)
	CALL	VgaChar
	MOV	A,r3_ax
	CALL	VgaString
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)
	
	BANK	2
	DISI
	CLR	r2_tmr_dial
	MOV	r2_tmr_dial1,@(2)
	ENI
	RETL	@(0)

ORG	0x2800

/*************************************************
AppNewBook
Ôö¼ÓÒ»¸öµç»°±¾¼ÇÂ¼
³õÊ¼»¯±à¼­Çø£¬Ò»¸öÐÂµÄµç»°±¾¡£
*************************************************/
AppNewBook:
	BLOCK	3
	CLR	ax
	MOV	_RC,@(131)
	MOV	cnt,@(68)
	PAGE	#(LibPushStack)
	CALL	LibClearRam			; ÊôÓÚphonebook
	MOV	A,@(PRO_AppEditBook)
	CALL	LibPushProgram
	PAGE	#($)
	RETL	@(0)

/*************************************************
AppEditBook
±à¼­Ò»¸öµç»°±¾¼ÇÂ¼
³õÊ¼»¯:	

	
ÏÔÊ¾:	
´ý»ú:
	ºÅÂë16Î»
	ÈËÃû16Î»
	
	LEFT	- ¹â±ê×óÒÆÒ»Î»
	RIGHT	- ¹â±êÓÒÒÆÒ»Î»
	BACK	- É¾³ý¹â±êÇ°ÃæÒ»Î»
	ERASE	- É¾³ý¹â±êµ±Ç°Î»
	
	r2_flag:
		.7	=0 first display (³õÊ¼»¯µÚÒ»´Î¹â±êµÄÎ»ÖÃ)
		.6	=0 ´óÐ´		(±à¼­ÈËÃû)
			=1 Ð¡Ð´
		.5	=0 ÈËÃûÈ·¶¨
			=1 ÈËÃû±¸Ñ¡ÖÐ	(±à¼­ÈËÃû)
		.4	=0 normal
			=1 searching
		.1~.0
			=0 edit number
			=1 edit name
			=2 edit music
	r2_cnt	- ±à¼­Î»ÖÃ

*************************************************/
AppEditBook:
	JPB	sys_flag,PROGRAMINIT,AppEditBook_init
	JPB	sys_flag,PROGRAMREIN,AppEditBook_rein
	JMP	AppEditBook_idle
AppEditBook_init:
	BC	sys_flag,PROGRAMINIT
	BANK	2
	CLR	r2_flag
	JMP	AppEditBook_display
AppEditBook_rein:
AppEditBook_display:
	BC	sys_flag,PROGRAMREIN
	CALL	AppEditBookDisplay
AppEditBook_idle:
	BANK	2
	BLOCK	3
	MOV	_RC,@(198)
	MOV	r2_id,_RD
	
	XORA	sys_msg,@(WM_KEYPRESS)
	JPZ	AppEditBook_key
	XORA	sys_msg,@(WM_COMMAND)
	JPZ	AppEditBook_command
AppEditBook_idle_1:
	ANDA	r2_flag,@(3)
	TBL
	JMP	AppEditBook_number
	JMP	AppEditBook_name
	JMP	AppEditBook_music
	JMP	AppEditBook_ret
AppEditBook_number:
	CALL	AppEditNumber
	JMP	AppEditBook_idle_2
AppEditBook_name:
	CALL	AppEditName
	JMP	AppEditBook_idle_2
AppEditBook_music:
	CALL	AppEditMusic
AppEditBook_idle_2:
	ADD	A,@(0)
	JPNZ	AppEditBookDisplay
AppEditBook_ret:
	RETL	@(0)
AppEditBook_command:
	XORA	sys_data,@(0x1a)
	JPNZ	AppEditBook_idle_1
	MOV	A,@(1)
	LCALL	LibGetCommand
	SUB	A,@(0x04)
	JPNZ	AppEditBook_idle_1
	BC	r2_flag,4
	LCALL	AppCallerToEditor
	JMP	AppEditBookDisplay
AppEditBook_key:
	XORA	sys_data,@(KEY_EXIT)
	JPZ	AppEditBook_exit
	JPB	r2_flag,4,AppEditBook_ret
	XORA	sys_data,@(KEY_OK)
	JPZ	AppEditBook_ok
	JMP	AppEditBook_idle_1
AppEditBook_exit:
	PAGE	#(LibSendOneCommand)
	MOV	A,@(0x54)
	CALL	LibSendOneCommand
	MOV	A,@(0x00)
	CALL	LibStoreCursor
	PAGE	#($)
	CLR	program
	RETL	@(0)
AppEditBook_ok:
	ANDA	r2_flag,@(3)
	TBL
	JMP	AppEditBook_ok_number
	JMP	AppEditBook_ok_name
	JMP	AppEditBook_ok_music
	JMP	AppEditBook_ret
AppEditBook_ok_number:
	MOV	_RC,@(131)
	MOV	A,_RD				; Ã»ÓÐºÅÂë
	JPZ	AppEditBook_ret			; ²»ÄÜ°´OK
	BC	r2_flag,7
	INC	r2_flag
	MOV	A,r2_id
	JPNZ	AppEditBookDisplay
	BS	r2_flag,4
	CALL	AppSendEditorPackage
	MOV	A,@(0x5a)
	LCALL	LibSendOneCommand
	RETL	@(0)
AppEditBook_ok_name:
	MOV	_RC,@(164)
	MOV	A,_RD
	JPZ	AppEditBook_ret			; Ã»ÓÐÈËÃû£¬²»ÄÜ°´OK¼ü
	BC	r2_flag,7
	INC	r2_flag
	MOV	_RC,@(197)
	MOV	A,_RD
	JPNZ	AppEditBook_ok_name_1
	MOV	_RD,@(DEFAULT_ringmelody)
AppEditBook_ok_name_1:
	MOV	exa,A
	PAGE	#(IIC)
	MOV	A,@(0x53)
	CALL	IicSendData
	MOV	A,exa
	CALL	IicSendData
	CALL	IicSer
	PAGE	#($)
	JMP	AppEditBookDisplay
AppEditBook_ok_music:				; ÔÚÑ¡ÔñmusicÊ±°´OK¼ü£¬±£´æ¡£
	MOV	A,@(0x54)			; ÏÈÍ£Ö¹²¥·Åmusic
	LCALL	LibSendOneCommand
	
AppEditBook_save:
	MOV	A,r2_id
	JPZ	AppEditBook_save_ok
	CALL	AppEditorToMemory


AppEditBook_save_ok:
	
	CALL	AppSendEditorPackage		; ·¢ËÍ±à¼­°ü
	BLOCK	3
	MOV	_RC,@(198)
	MOV	bx,_RD
	PAGE	#(IIC)
	MOV	A,@(0x52)
	CALL	IicSendData
	MOV	A,bx
	CALL	IicSendData
	CALL	IicSer
	
	PAGE	#(LibPushProgram)
	MOV	A,@(PRO_AppSuccessfull)		; ±£´æÍê±Ï£¬ÏÔÊ¾³É¹¦
	CALL	LibPushProgram
	PAGE	#($)
	RETL	@(0)


AppEditorToMemory:
	MOV	ax,A
	TBL
	JMP	AppEditorToMemory_ret
	JMP	AppEditorToMemory_m1
	JMP	AppEditorToMemory_m2
	JMP	AppEditorToMemory_m3
AppEditorToMemory_ret:
	RETL	@(0)
AppEditorToMemory_m1:
	MOV	A,@(128)
	JMP	AppEditorToMemory_1
AppEditorToMemory_m2:
	MOV	A,@(162)
	JMP	AppEditorToMemory_1
AppEditorToMemory_m3:
	MOV	A,@(196)
AppEditorToMemory_1:
	MOV	_RC,A
	MOV	bx,A
	BLOCK	1
	MOV	_RD,ax
	CLR	cnt
	INC	bx
AppEditorToMemory_number:
	BLOCK	3
	MOV	_RC,@(131)
	SUBA	_RD,cnt
	JPZ	AppEditorToMemory_number_end
	ADDA	cnt,@(132)
	MOV	_RC,A
	MOV	ax,_RD
	BLOCK	1
	ADDA	bx,cnt
	MOV	_RC,A
	MOV	_RD,ax
	INC	cnt
	SUBA	cnt,@(16)
	JPNC	AppEditorToMemory_number
AppEditorToMemory_number_end:
	ADD	bx,@(16)
	CLR	cnt
AppEditorToMemory_name:
	BLOCK	3
	MOV	_RC,@(164)
	SUBA	_RD,cnt
	JPZ	AppEditorToMemory_name_end
	ADDA	cnt,@(165)
	MOV	_RC,A
	MOV	ax,_RD
	BLOCK	1
	ADDA	bx,cnt
	MOV	_RC,A
	MOV	_RD,ax
	INC	cnt
	SUBA	cnt,@(16)
	JPNC	AppEditorToMemory_name
AppEditorToMemory_name_end:
	ADD	bx,@(16)
	BLOCK	3
	MOV	_RC,@(197)
	MOV	ax,_RD
	BLOCK	1
	MOV	_RC,bx
	MOV	_RD,ax
	RETL	@(0)


AppSendEditorPackage:				; ½«±à¼­ÇøµÄºÅÂë¡¢ÈËÃûµÈÐÅÏ¢´ò°ü·¢¸øDSP¡£
	BANK	1
	BLOCK	3
	MOV	_RC,@(131)
	MOV	r1_cnt,_RD
	MOV	_RC,@(197)
	MOV	r1_ax,_RD
AppSendEditorPackage_time:
	PAGE	#(IIC)
	MOV	A,@(0x80)
	CALL	IicSendData
	MOV	A,r1_rtc_month
	CALL	IicSendData
	MOV	A,r1_rtc_day
	CALL	IicSendData
	MOV	A,r1_rtc_hour
	CALL	IicSendData
	MOV	A,r1_rtc_minute
	CALL	IicSendData
	MOV	A,r1_cnt
	CALL	IicSendData
	PAGE	#($)

	CLR	cnt
AppSendEditorPackage_number:
	INC	cnt
	SUBA	r1_cnt,cnt
	JPNC	AppSendEditorPackage_number_1
	BLOCK	3
	ADDA	cnt,@(131)
	MOV	_RC,A
	MOV	A,_RD
	JMP	$+2
AppSendEditorPackage_number_1:
	MOV	A,@(0)
	LCALL	IicSendData
	SUBA	cnt,@(32)
	JPNC	AppSendEditorPackage_number
	
	BLOCK	3
	MOV	_RC,@(164)
	MOV	r1_cnt,_RD
	LCALL	IicSendData
	
	CLR	cnt
AppSendEditorPackage_name:
	INC	cnt
	SUBA	r1_cnt,cnt
	JPNC	AppSendEditorPackage_name_1
	BLOCK	3
	ADDA	cnt,@(164)
	MOV	_RC,A
	MOV	A,_RD
	JMP	$+2
AppSendEditorPackage_name_1:
	MOV	A,@(0)
	LCALL	IicSendData
	SUBA	cnt,@(16)
	JPNC	AppSendEditorPackage_name
	
	PAGE	#(IIC)
	MOV	A,r1_ax
	CALL	IicSendData
	MOV	A,@(0)				; RPT
	CALL	IicSendData
	MOV	A,@(0x80)
	CALL	IicSendData
	CALL	IicSer
	PAGE	#($)
	RETL	@(0)



AppEditBookDisplay:
	MOV	A,@(0)
	LCALL	LibStoreCursor
	BANK	2
	BLOCK	3
	ANDA	r2_flag,@(3)
	TBL
	JMP	AppEditBookDisplayNumber
	JMP	AppEditBookDisplayName
	JMP	AppEditBookDisplayMusic
	JMP	AppEditBookDisplay_ret

AppEditBookDisplayNumber:
	MOV	_RC,@(131)
	MOV	A,_RD
	JPB	r2_flag,7,AppEditBookDisplayNumber_1
	MOV	r2_cnt,A
	INC	r2_cnt
	BS	r2_flag,7
	PAGE	#(VGA)
	CALL	VgaBlankNum2
	CALL	VgaBlankChar
	MOV	A,@(STYLE_LEFT)
	CALL	VgaChar
	MOV	A,@(STR_InputNumber)
	CALL	VgaString
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)
AppEditBookDisplayNumber_1:
	PAGE	#(VGA)
	CALL	VgaBlankNum2
	MOV	A,@(STYLE_LEFT)
	CALL	VgaNum2
	PAGE	#($)
	CLR	r2_ax
AppEditBookDisplayNumber_loop:
	BLOCK	3
	MOV	_RC,@(131)
	SUBA	r2_ax,_RD
	JPC	AppEditBookDisplayNumber_end
	INC	r2_ax
	ADD	_RC,r2_ax
	MOV	A,_RD
	JPZ	AppEditBookDisplayNumber_end
	LCALL	VgaNum2
	JMP	AppEditBookDisplayNumber_loop
AppEditBookDisplayNumber_end:
	PAGE	#(VGA)
	MOV	A,@(0)
	CALL	VgaNum2
	CALL	VgaDrawNum2
	PAGE	#($)
	
	SUBA	r2_cnt,@(17)
	JPC	AppEditBookDisplayNumber_2
	SUBA	r2_cnt,@(1)
	ADD	A,@(0x20)
	LCALL	LibStoreCursor			; ¹â±êÎ»ÖÃ
AppEditBookDisplayNumber_2:
	RETL	@(0)

AppEditBookDisplayName:
	MOV	_RC,@(164)
	MOV	A,_RD
	JPB	r2_flag,7,AppEditBookDisplayName_1
	MOV	r2_cnt,A
	INC	r2_cnt
	BS	r2_flag,7
	PAGE	#(VGA)
	CALL	VgaBlankNum2
	MOV	A,@(STYLE_LEFT)
	CALL	VgaNum2
	PAGE	#($)
	CLR	r2_ax
AppEditBookDisplayName_1_loop:
	BLOCK	3
	MOV	_RC,@(131)
	SUBA	r2_ax,_RD
	JPC	AppEditBookDisplayName_1_end
	INC	r2_ax
	ADD	_RC,r2_ax
	MOV	A,_RD
	JPZ	AppEditBookDisplayName_1_end
	LCALL	VgaNum2
	JMP	AppEditBookDisplayName_1_loop
AppEditBookDisplayName_1_end:
	PAGE	#(VGA)
	MOV	A,@(0)
	CALL	VgaNum2
	CALL	VgaDrawNum2
	PAGE	#($)
AppEditBookDisplayName_1:
	;MOV	A,r2_cnt
	;JPZ	AppEditBookDisplayName_none
	PAGE	#(VGA)
	CALL	VgaBlankChar
	MOV	A,@(STYLE_LEFT)
	CALL	VgaChar
	PAGE	#($)
	CLR	r2_ax
AppEditBookDisplayName_loop:
	BLOCK	3
	MOV	_RC,@(164)
	SUBA	r2_ax,_RD
	JPC	AppEditBookDisplayName_end
	INC	r2_ax
	ADD	_RC,r2_ax
	MOV	A,_RD
	JPZ	AppEditBookDisplayName_end
	LCALL	VgaChar
	JMP	AppEditBookDisplayName_loop
AppEditBookDisplayName_end:
	PAGE	#(VGA)
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)
	SUBA	r2_cnt,@(17)
	JPC	AppEditBookDisplayName_2
	SUBA	r2_cnt,@(1)
	ADD	A,@(0x30)
	LCALL	LibStoreCursor			; ¹â±êÎ»ÖÃ
AppEditBookDisplayName_none:
AppEditBookDisplayName_2:
	RETL	@(0)

AppEditBookDisplayMusic:
	MOV	_RC,@(197)
	MOV	r2_ax,_RD
	JPB	r2_flag,7,AppEditBookDisplayMusic_1
	PAGE	#(VGA)
	CALL	VgaBlankNum2
	CALL	VgaBlankChar
	MOV	A,@(STYLE_LEFT)
	CALL	VgaChar
	MOV	A,@(STR_SelectRingTone)
	CALL	VgaString
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)
	MOV	A,@(0)
	LCALL	LibStoreCursor
AppEditBookDisplayMusic_1:
	MOV	ax,r2_ax
	LCALL	LibMathHexToBcd
	MOV	r2_ax,A
	PAGE	#(VGA)
	MOV	A,@(STYLE_RIGHT)
	CALL	VgaNum2
	SWAPA	r2_ax
	AND	A,@(0x0f)
	ADD	A,@(48)
	CALL	VgaNum2
	ANDA	r2_ax,@(0x0f)
	ADD	A,@(48)
	CALL	VgaNum2
	MOV	A,@(0)
	CALL	VgaNum2
	CALL	VgaDrawNum2
	PAGE	#($)
AppEditBookDisplay_ret:
	RETL	@(0)
	
	





/*************************************************
16Î»ºÅÂë±à¼­

"LEFT"		¹â±ê×óÒÆ
"RIGHT"		¹â±êÓÒÒÆ
"BACK"		É¾³ý¹â±êÇ°ÃæµÄºÅÂë
"ERASE"		É¾³ý¹â±êµ±Ç°µÄºÅÂë
"123"		ÔÚµ±Ç°¹â±ê´¦ÊäÈëºÅÂë
*************************************************/
AppEditNumber:
	BANK	2
	BLOCK	3
	
	MOV	_RC,@(131)
	
	XORA	sys_msg,@(WM_KEYPRESS)
	JPZ	AppEditNumber_key
AppEditNumber_ret:
	RETL	@(0)
AppEditNumber_key:
	XORA	sys_data,@(KEY_LEFT)
	JPZ	AppEditNumber_left
	XORA	sys_data,@(KEY_RIGHT)
	JPZ	AppEditNumber_right
	XORA	sys_data,@(KEY_BACK)
	JPZ	AppEditNumber_back
	XORA	sys_data,@(KEY_ERASE)
	JPZ	AppEditNumber_erase
	
	LCALL	LibDialNumCheck
	ADD	A,@(0)
	JPZ	AppEditNumber_ret
; ÊäÈëÒ»¸öºÅÂë
; ÔÚ¹â±êÎ»ÖÃ³öÊäÈë¸ÃºÅÂë£¬²¢½«¹â±êÎ»ÖÃµÄÔ­ºÅÂëºÍÆäºóµÄºÅÂëÓÒÒÆÒ»Î»¡£
; Í¬Ê±¹â±êÓÒÒÆÒ»Î»
AppEditNumber_num:
	MOV	r2_ax,A
	SUBA	_RD,@(16)
	JPC	AppEditFull			; ±à¼­³¤¶Èµ½ÁË16Î»£¬Âú£¬²»ÄÜÊäÈëºÅÂë¡£
	INC	_RD				; ÊäÈëÒ»Î»ºÅÂë£¬³¤¶È+1¡£
	ADDA	r2_cnt,@(131)			; µÃµ½±à¼­Î»ÖÃ
	MOV	ax,A				; ±à¼­Î»ÖÃµÄµØÖ·
	MOV	bx,A				; ±à¼­Î»ÖÃµÄÏÂÒ»Î»µØÖ·
	INC	bx
	SUBA	_RD,r2_cnt
	MOV	cnt,A				; ÓÒÒÆµÄ³¤¶È
	LCALL	LibCopyRam
	ADDA	r2_cnt,@(131)
	MOV	_RC,A
	MOV	_RD,r2_ax
	MOV	_RC,@(131)
	JMP	AppEditNumber_right		; Í¬Ê±¹â±êÒªÓÒÒÆ¡£
; É¾³ý¹â±êÇ°ÃæµÄÒ»Î»ºÅÂë
; É¾³ýÇ°µÄºÅÂë£¬¹â±êµ±Ç°Î»µÄºÅÂë¼°ÆäºóµÄºÅÂë×óÒÆÒ»Î»¡£
; ¹â±ê×óÒÆÒ»Î»
AppEditNumber_back:
	SUBA	r2_cnt,@(2)
	JPNC	AppEditNumber_ret		; ¹â±êÎ»ÖÃÔÚµÚÒ»¸öºÅÂë´¦£¬ÎÞ·¨É¾³ýÇ°ÃæµÄºÅÂë¡£
	DEC	_RD				; É¾³ýÒ»¸öºÅÂë£¬³¤¶È-1
	ADDA	r2_cnt,@(131)
	MOV	ax,A
	MOV	bx,A
	DEC	bx
	SUBA	_RD,r2_cnt
	MOV	cnt,A
	INC	cnt
	INC	cnt
	LCALL	LibCopyRam
	MOV	_RC,@(131)
	JMP	AppEditNumber_left
; É¾³ý¹â±êµ±Ç°µÄÒ»Î»ºÅÂë
; ¹â±êÆäºóµÄºÅÂë×óÒÆÒ»Î»¡£
; ¹â±êÎ»ÖÃ²»±ä
AppEditNumber_erase:
	SUBA	_RD,r2_cnt
	JPNC	AppEditNumber_ret		; ¹â±êÎ»ÖÃÔÚ×îºóÒ»¸öºÅÂëµÄÏÂÒ»Î»£¬ÎÞ·¨É¾³ýµ±Ç°Î»¡£
	DEC	_RD				; É¾³ýÒ»¸öºÅÂë£¬³¤¶È-1
	SUBA	_RD,r2_cnt
	JPNC	AppEditNumber_display		; É¾³ý×îºóÒ»Î»ºÅÂë£¬²»ÐèÒªÒÆÎ»£¬Ö±½ÓÏÔÊ¾¡£
	ADDA	r2_cnt,@(131)
	MOV	ax,A
	MOV	bx,A
	INC	ax
	SUBA	_RD,r2_cnt
	MOV	cnt,A
	INC	cnt
	LCALL	LibCopyRam
	MOV	_RC,@(131)
	JMP	AppEditNumber_display		; ¹â±êÎ»ÖÃ²»±ä£¬Ö±½ÓÏÔÊ¾¡£
; ¹â±ê×óÒÆ
; Èç¹û¹â±êËùÔÚ±à¼­ÇøÒÑ¾­µ½´ïµÚÒ»¸öºÅÂë£¬ÎÞ·¨×óÒÆ¡£
AppEditNumber_left:
	SUBA	r2_cnt,@(1)
	JPZ	AppEditNumber_ret		; µÚÒ»¸öºÅÂë£¬ÎÞ·¨×óÒÆ¡£
	DEC	r2_cnt				; ¹â±ê×óÒÆ¡£
	JMP	AppEditNumber_display		; ÏÔÊ¾
; ¹â±êÓÒÒÆ£¬¿ÉÒÔÒÆ¶¯µ½ÆÁÄ»Ö®Íâ£¬ÕâÊ±r2_cnt=r2_bx£¬ÏÔÊ¾ÆÁÉÏÃ»ÓÐ¹â±ê¡£
; Èç¹û¹â±êÒÑ¾­µ½´ï×îºóÒ»¸öºÅÂëµÄÏÂÒ»Î»£¬ÎÞ·¨ÓÒÒÆ¡£
AppEditNumber_right:
	SUBA	_RD,r2_cnt
	JPNC	AppEditNumber_ret		; ×îºóÒ»¸öºÅÂëµÄÏÂÒ»Î»£¬ÎÞ·¨ÓÒÒÆ¡£
	INC	r2_cnt				; ¹â±êÓÒÒÆ
	JMP	AppEditNumber_display		; ÏÔÊ¾


AppEditNumber_display:
	RETL	@(1)



/*************************************************
16Î»ÈËÃû±à¼­

"LEFT"		¹â±ê×óÒÆ
"RIGHT"		¹â±êÓÒÒÆ
"BACK"		É¾³ý¹â±êÇ°ÃæµÄÈËÃû
"ERASE"		É¾³ý¹â±êµ±Ç°µÄÈËÃû
"123"		ÔÚµ±Ç°¹â±ê´¦ÊäÈëÈËÃû

r2_bx		±£´æ°´ÏÂµÄ°´¼ü
r2_flag:
		.7	=0 first display (³õÊ¼»¯µÚÒ»´Î¹â±êµÄÎ»ÖÃ)
		.6	=0 ´óÐ´		(±à¼­ÈËÃû)
			=1 Ð¡Ð´
		.5	=0 ÈËÃûÈ·¶¨
			=1 ÈËÃû±¸Ñ¡ÖÐ	(±à¼­ÈËÃû)
*************************************************/
AppEditName:
	BANK	2
	BLOCK	3
	
	MOV	_RC,@(164)
	
	XORA	sys_msg,@(WM_KEYPRESS)
	JPZ	AppEditName_key
	JPNB	r2_flag,5,AppEditName_ret
	MOV	A,r2_tmr_dial1
	JPNZ	AppEditName_ret
	MOV	A,r2_tmr_dial
	JPNZ	AppEditName_ret
	JMP	AppEditName_right		; ±¸Ñ¡³¬Ê±£¬¹â±êÓÒÒÆ
AppEditName_ret:
	RETL	@(0)
AppEditName_key:
	XORA	sys_data,@(KEY_LEFT)
	JPZ	AppEditName_left
	XORA	sys_data,@(KEY_RIGHT)
	JPZ	AppEditName_right
	XORA	sys_data,@(KEY_BACK)
	JPZ	AppEditName_back
	XORA	sys_data,@(KEY_ERASE)
	JPZ	AppEditName_erase
	
	LCALL	LibCharNumCheck
	ADD	A,@(0)
	JPZ	AppEditName_ret
; ÊäÈëÒ»¸öºÅÂë
; ÔÚ¹â±êÎ»ÖÃ³öÊäÈë¸ÃºÅÂë£¬²¢½«¹â±êÎ»ÖÃµÄÔ­ºÅÂëºÍÆäºóµÄºÅÂëÓÒÒÆÒ»Î»¡£
; Í¬Ê±¹â±êÓÒÒÆÒ»Î»
AppEditName_num:
	MOV	r2_ax,A
	XOR	A,@(42)				; ÅÐ¶ÏÊÇ·ñ*°´ÏÂ
	JPZ	AppEditName_case
	JPB	r2_flag,5,AppEditName_num_1
	
	SUBA	_RD,@(16)
	JPC	AppEditFull			; ±à¼­³¤¶Èµ½ÁË16Î»£¬Âú£¬²»ÄÜÊäÈëºÅÂë¡£
AppEditName_num_0:
	BS	r2_flag,5			; ½øÈë±¸Ñ¡
	
	MOV	r2_bx,r2_ax			; ±£´æÊäÈëµÄ°´¼ü
	CLR	r2_exb				; ´ÓµÚÒ»¸ö×Ö·û¿ªÊ¼
	
	INC	_RD				; ÊäÈëÒ»Î»ºÅÂë£¬³¤¶È+1¡£
	ADDA	r2_cnt,@(164)			; µÃµ½±à¼­Î»ÖÃ
	MOV	ax,A				; ±à¼­Î»ÖÃµÄµØÖ·
	MOV	bx,A				; ±à¼­Î»ÖÃµÄÏÂÒ»Î»µØÖ·
	INC	bx
	SUBA	_RD,r2_cnt
	MOV	cnt,A				; ÓÒÒÆµÄ³¤¶È
	LCALL	LibCopyRam
	JMP	AppEditName_char

AppEditName_num_1:
	XORA	r2_ax,r2_bx
	JPZ	AppEditName_num_2
	INC	r2_cnt
	BC	r2_flag,5
	SUBA	_RD,@(16)
	JPNC	AppEditName_num_0
	MOV	A,@(0x01)
	LCALL	LibPromptBeep
	JMP	AppEditName_display
AppEditName_num_2:
	INC	r2_exb

AppEditName_char:
	DISI
	CLR	r2_tmr_dial
	MOV	r2_tmr_dial1,@(3)
	ENI
	
	ADDA	r2_cnt,@(164)
	MOV	_RC,A
AppEditName_char_0:
	CALL	AppEditNameGetCharAddress
	ADD	A,r2_exb
	LCALL	TabSelectChar
	ADD	A,@(0)
	JPNZ	AppEditName_char_1
	CLR	r2_exb
	JMP	AppEditName_char_0
AppEditName_char_1:
	MOV	_RD,A
	JMP	AppEditName_display
	

AppEditName_case:				; *°´ÏÂ£¬ÇÐ»»´óÐ¡Ð´¡£
	INVB	r2_flag,6
	MOV	A,@(0x00)
	LCALL	LibPromptBeep
	JMP	AppEditName_ret
; É¾³ý¹â±êÇ°ÃæµÄÒ»Î»ºÅÂë
; É¾³ýÇ°µÄºÅÂë£¬¹â±êµ±Ç°Î»µÄºÅÂë¼°ÆäºóµÄºÅÂë×óÒÆÒ»Î»¡£
; ¹â±ê×óÒÆÒ»Î»
AppEditName_back:
	BC	r2_flag,5
	SUBA	r2_cnt,@(2)
	JPNC	AppEditName_ret		; ¹â±êÎ»ÖÃÔÚµÚÒ»¸öºÅÂë´¦£¬ÎÞ·¨É¾³ýÇ°ÃæµÄºÅÂë¡£
	DEC	_RD				; É¾³ýÒ»¸öºÅÂë£¬³¤¶È-1
	ADDA	r2_cnt,@(164)
	MOV	ax,A
	MOV	bx,A
	DEC	bx
	SUBA	_RD,r2_cnt
	MOV	cnt,A
	INC	cnt
	INC	cnt
	LCALL	LibCopyRam
	MOV	_RC,@(164)
	JMP	AppEditName_left
; É¾³ý¹â±êµ±Ç°µÄÒ»Î»ºÅÂë
; ¹â±êÆäºóµÄºÅÂë×óÒÆÒ»Î»¡£
; ¹â±êÎ»ÖÃ²»±ä
AppEditName_erase:
	BC	r2_flag,5
	SUBA	_RD,r2_cnt
	JPNC	AppEditName_ret		; ¹â±êÎ»ÖÃÔÚ×îºóÒ»¸öºÅÂëµÄÏÂÒ»Î»£¬ÎÞ·¨É¾³ýµ±Ç°Î»¡£
	DEC	_RD				; É¾³ýÒ»¸öºÅÂë£¬³¤¶È-1
	SUBA	_RD,r2_cnt
	JPNC	AppEditName_display		; É¾³ý×îºóÒ»Î»ºÅÂë£¬²»ÐèÒªÒÆÎ»£¬Ö±½ÓÏÔÊ¾¡£
	ADDA	r2_cnt,@(164)
	MOV	ax,A
	MOV	bx,A
	INC	ax
	SUBA	_RD,r2_cnt
	MOV	cnt,A
	INC	cnt
	LCALL	LibCopyRam
	MOV	_RC,@(164)
	JMP	AppEditName_display		; ¹â±êÎ»ÖÃ²»±ä£¬Ö±½ÓÏÔÊ¾¡£
; ¹â±ê×óÒÆ
; Èç¹û¹â±êËùÔÚ±à¼­ÇøÒÑ¾­µ½´ïµÚÒ»¸öºÅÂë£¬ÎÞ·¨×óÒÆ¡£
AppEditName_left:
	BC	r2_flag,5
	SUBA	r2_cnt,@(1)
	JPZ	AppEditName_ret		; µÚÒ»¸öºÅÂë£¬ÎÞ·¨×óÒÆ¡£
	DEC	r2_cnt				; ¹â±ê×óÒÆ¡£
	JMP	AppEditName_display		; ÏÔÊ¾
; ¹â±êÓÒÒÆ£¬¿ÉÒÔÒÆ¶¯µ½ÆÁÄ»Ö®Íâ£¬ÕâÊ±r2_cnt=r2_bx£¬ÏÔÊ¾ÆÁÉÏÃ»ÓÐ¹â±ê¡£
; Èç¹û¹â±êÒÑ¾­µ½´ï×îºóÒ»¸öºÅÂëµÄÏÂÒ»Î»£¬ÎÞ·¨ÓÒÒÆ¡£
AppEditName_right:
	BC	r2_flag,5
	SUBA	_RD,r2_cnt
	JPNC	AppEditName_ret		; ×îºóÒ»¸öºÅÂëµÄÏÂÒ»Î»£¬ÎÞ·¨ÓÒÒÆ¡£
	INC	r2_cnt				; ¹â±êÓÒÒÆ
	JMP	AppEditName_display		; ÏÔÊ¾


AppEditName_display:
	RETL	@(1)

AppEditNameGetCharAddress:
	SUBA	r2_ax,@(35)
	JPZ	AppEditNameGetCharAddress_hash
	JPB	r2_flag,6,AppEditNameGetCharAddress_l
	SUBA	r2_ax,@(48)
	TBL
	JMP	AppEditNameGetCharAddress_0
	JMP	AppEditNameGetCharAddress_1
	JMP	AppEditNameGetCharAddress_2
	JMP	AppEditNameGetCharAddress_3
	JMP	AppEditNameGetCharAddress_4
	JMP	AppEditNameGetCharAddress_5
	JMP	AppEditNameGetCharAddress_6
	JMP	AppEditNameGetCharAddress_7
	JMP	AppEditNameGetCharAddress_8
	JMP	AppEditNameGetCharAddress_9
AppEditNameGetCharAddress_l:
	SUBA	r2_ax,@(48)
	TBL
	JMP	AppEditNameGetCharAddress_0
	JMP	AppEditNameGetCharAddress_1
	JMP	AppEditNameGetCharAddress_2l
	JMP	AppEditNameGetCharAddress_3l
	JMP	AppEditNameGetCharAddress_4l
	JMP	AppEditNameGetCharAddress_5l
	JMP	AppEditNameGetCharAddress_6l
	JMP	AppEditNameGetCharAddress_7l
	JMP	AppEditNameGetCharAddress_8l
	JMP	AppEditNameGetCharAddress_9l
AppEditNameGetCharAddress_hash:
	RETL	@(0)
AppEditNameGetCharAddress_0:
	RETL	@(5)
AppEditNameGetCharAddress_1:
	RETL	@(20)
AppEditNameGetCharAddress_2:
	RETL	@(40)
AppEditNameGetCharAddress_2l:
	RETL	@(53)
AppEditNameGetCharAddress_3:
	RETL	@(66)
AppEditNameGetCharAddress_3l:
	RETL	@(75)
AppEditNameGetCharAddress_4:
	RETL	@(84)
AppEditNameGetCharAddress_4l:
	RETL	@(93)
AppEditNameGetCharAddress_5:
	RETL	@(102)
AppEditNameGetCharAddress_5l:
	RETL	@(107)
AppEditNameGetCharAddress_6:
	RETL	@(112)
AppEditNameGetCharAddress_6l:
	RETL	@(123)
AppEditNameGetCharAddress_7:
	RETL	@(134)
AppEditNameGetCharAddress_7l:
	RETL	@(141)
AppEditNameGetCharAddress_8:
	RETL	@(148)
AppEditNameGetCharAddress_8l:
	RETL	@(157)
AppEditNameGetCharAddress_9:
	RETL	@(166)
AppEditNameGetCharAddress_9l:
	RETL	@(175)
	



AppEditMusic:
	BANK	2
	BLOCK	3
	MOV	_RC,@(197)
	
	XORA	sys_msg,@(WM_KEYPRESS)
	JPZ	AppEditMusic_key
	RETL	@(0)
AppEditMusic_key:
	XORA	sys_data,@(KEY_UP)
	JPZ	AppEditMusic_up
	XORA	sys_data,@(KEY_DOWN)
	JPZ	AppEditMusic_down
	XORA	sys_data,@(KEY_PLAY)
	JPZ	AppEditMusic_play
	RETL	@(0)
AppEditMusic_up:
	INC	_RD
	SUBA	_RD,@(13)
	JPNC	AppEditMusic_display
	MOV	_RD,@(1)
	JMP	AppEditMusic_display
AppEditMusic_down:
	DEC	_RD
	JPNZ	AppEditMusic_display
	MOV	_RD,@(12)
	JMP	AppEditMusic_display
AppEditMusic_play:
	MOV	A,@(0)
	JMP	AppEditMusic_view
AppEditMusic_display:
	MOV	A,@(1)
AppEditMusic_view:
	MOV	r2_exa,A
	MOV	bx,_RD
	PAGE	#(IIC)
	MOV	A,@(0x53)
	CALL	IicSendData
	MOV	A,bx
	CALL	IicSendData
	CALL	IicSer
	PAGE	#($)
	MOV	A,r2_exa
	RET


AppEditFull:
	MOV	A,@(0x01)
	LCALL	LibPromptBeep
	RETL	@(0)


ORG	0x2c00

AppProgram:
	BANK	2
	JPB	sys_flag,PROGRAMINIT,AppProgram_init
	JPB	sys_flag,PROGRAMREIN,AppProgram_rein
	JMP	AppProgram_idle
AppProgram_init:
	BC	sys_flag,PROGRAMINIT
	CLR	r2_id
	CLR	r2_flag
	JMP	AppProgram_display
AppProgram_rein:
	PAGE	#(LibPushStack)
	CALL	LibPopStack
	MOV	r2_flag,A
	CALL	LibPopStack
	MOV	r2_id,A
	CALL	LibPopStack
	CALL	LibStoreCursor
	PAGE	#($)
AppProgram_display:
	BC	sys_flag,PROGRAMREIN
	PAGE	#(VGA)
	CALL	VgaBlankNum2
	CALL	VgaBlankChar
	PAGE	#($)
	CALL	AppProgramDisplay
AppProgram_idle:
	XORA	sys_msg,@(WM_KEYPRESS)
	JPZ	AppProgram_key
	RETL	@(0)
AppProgram_key:
	XORA	sys_data,@(KEY_UP)
	JPZ	AppProgram_up
	XORA	sys_data,@(KEY_DOWN)
	JPZ	AppProgram_down
	XORA	sys_data,@(KEY_EXIT)
	JPZ	AppProgram_exit
	XORA	sys_data,@(KEY_ENTER)
	JPZ	AppProgram_enter
	RETL	@(0)
AppProgram_up:
	INC	r2_id
	SUBA	r2_id,@(3)
	JPNC	AppProgramDisplay
	CLR	r2_id
	JMP	AppProgramDisplay
AppProgram_down:
	MOV	A,r2_id
	JPNZ	$+3
	MOV	r2_id,@(3)
	DEC	r2_id
	JMP	AppProgramDisplay
AppProgram_exit:
	CLR	program
	RETL	@(0)
AppProgram_enter:
	BLOCK	1
	MOV	A,r2_id
	TBL
	JMP	AppProgram_enter_m1
	JMP	AppProgram_enter_m2
	JMP	AppProgram_enter_m3
AppProgram_enter_m1:
	MOV	A,@(128)
	JMP	AppProgram_enter_1
AppProgram_enter_m2:
	MOV	A,@(162)
	JMP	AppProgram_enter_1
AppProgram_enter_m3:
	MOV	A,@(196)
AppProgram_enter_1:
	CALL	AppMemoryToEditor

	BLOCK	3
	MOV	_RC,@(198)
	ADDA	r2_id,@(1)
	MOV	_RD,A				; ±à¼­ÇøÊôÓÚM1~M3
	PAGE	#(LibPushStack)
	MOV	A,cursor
	CALL	LibPushStack
	MOV	A,r2_id
	CALL	LibPushStack
	MOV	A,r2_flag
	CALL	LibPushStack
	MOV	A,@(PRO_AppProgram)
	CALL	LibPushStack
	MOV	A,@(PRO_AppEditBook)
	CALL	LibPushProgram
	PAGE	#($)
	RETL	@(0)

AppProgramDisplay:
	PAGE	#(VGA)
	MOV	A,@(STYLE_LEFT)
	CALL	VgaChar
	MOV	A,@(77)
	CALL	VgaChar
	ADDA	r2_id,@(48+1)
	CALL	VgaChar
	MOV	A,@(32)
	CALL	VgaChar
	MOV	A,@(STR_memoryset)
	CALL	VgaString
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)
	RETL	@(0)

/*************************************************
AppMemoryToEditor
½«M1~M3µÄÄÚÈÝ¿½±´ÖÁ±à¼­Çø
*************************************************/
AppMemoryToEditor:
	MOV	ax,A
	CALL	LibClearEditor
	
	BLOCK	1
	MOV	_RC,ax
	MOV	A,_RD
	JPZ	AppMemoryToEditor_null		; memory Îª¿Õ
	MOV	exa,@(16)
	INC	ax
	MOV	bx,@(132)
	CALL	LibCopyRamEx1
	BLOCK	3
	MOV	_RC,@(131)
	MOV	_RD,cnt
	
	ADD	ax,@(16)
	MOV	bx,@(165)
	CALL	LibCopyRamEx1
	BLOCK	3
	MOV	_RC,@(164)
	MOV	_RD,cnt
	
	BLOCK	1
	ADDA	ax,@(16)
	MOV	_RC,A
	MOV	exa,_RD
	BLOCK	3
	MOV	_RC,@(197)
	MOV	_RD,exa
	RETL	@(1)
AppMemoryToEditor_null:
	RETL	@(0)

/*************************************************
AppCallerToEditor
½«callerid packageµÄÄÚÈÝ¿½±´ÖÁ±à¼­Çø
*************************************************/
AppCallerToEditor:
	CALL	LibClearEditor
	
	BLOCK	1
	MOV	_RC,@(8+4)
	MOV	A,_RD
	JPZ	AppCallerToEditor_null
	;SUBA	_RD,@(17)
	;JPC	AppCallerToEditor_null		; ³¤¶È³¬¹ý16Î»
	MOV	exa,_RD
	MOV	ax,@(8+4+1)
	MOV	bx,@(132)
	CALL	LibCopyRamEx1
	BLOCK	3
	MOV	_RC,@(131)
	MOV	_RD,cnt
	
	BLOCK	1
	MOV	_RC,@(8+4+33)
	MOV	A,_RD
	JPZ	AppCallerToEditor_name_end
	SUBA	_RD,@(17)
	JPC	AppCallerToEditor_name_end
	MOV	exa,_RD
	MOV	ax,@(8+4+33+1)
	MOV	bx,@(165)
	CALL	LibCopyRamEx1
	BLOCK	3
	MOV	_RC,@(164)
	MOV	_RD,cnt
AppCallerToEditor_name_end:
	
	BLOCK	1
	MOV	_RC,@(8+4+33+17)
	MOV	exa,_RD
	BLOCK	3
	MOV	_RC,@(197)
	MOV	_RD,exa
	RETL	@(1)
AppCallerToEditor_null:
	RETL	@(0)
	
	
LibClearEditor:
	BLOCK	3
	MOV	_RC,@(131)
	CLR	_RD
	MOV	_RC,@(164)
	CLR	_RD
	MOV	_RC,@(197)
	CLR	_RD
	RETL	@(0)

; ax:	Ô´µØÖ·(block 1)
; exa:	Ô´ÓÐÐ§³¤¶È×î´ó³¤¶È
; bx:	Ä¿±êµØÖ·(block 3)
; ×î´ó16Î»
LibCopyRamEx1:
	CLR	cnt
LibCopyRamEx1_loop:
	SUBA	cnt,@(16)
	JPC	LibCopyRamEx1_end		; ³¤¶Èµ½16Î»
	SUBA	cnt,exa				; ³¤¶Èµ½Ô´³¤¶È
	JPC	LibCopyRamEx1_end
	BLOCK	1
	ADDA	ax,cnt
	MOV	_RC,A
	MOV	A,_RD
	JPZ	LibCopyRamEx1_end		; Êý¾Ý½áÊø
	MOV	exb,A
	BLOCK	3
	ADDA	bx,cnt
	MOV	_RC,A
	MOV	_RD,exb
	INC	cnt
	JMP	LibCopyRamEx1_loop
LibCopyRamEx1_end:
	RETL	@(0)

/*************************************************
AppNewCall
À´µç
µ±ÓÐÁåÉùÀ´(command=0x1900)£¬½øÈë±¾³ÌÐòÏÔÊ¾new call£¬(»¹Ã»ÓÐÊÕµ½caller id)
µ±ÓÐcaller id(command=0x1a00)£¬½øÈë±¾³ÌÐòÏÔÊ¾À´µçºÅÂëÐÅÏ¢¡£
±¾³ÌÐòÖÐ£º
Èç¹ûÄÃÆðÊÖ±ú»ò°´ÏÂspk£¬½øÈëÍ¨»°³ÌÐò
Èç¹û´ðÂ¼»úÓ¦´ð(command=0x1700)£¬ÏÔÊ¾answered ogmX£¬Í¬Ê±´ðÂ¼»ú´¦ÓÚ½ÓÏß×´Ì¬¡£
Èç¹û´ðÂ¼»úÂ¼Òô(command=0x1200)£¬ÏÔÊ¾ICMÂ¼Òô£¬²¢¼ÆÊ±¡£
Èç¹û´ðÂ¼»ú½øÈëÒ£¿Ø(command=0x1300)£¬ÏÔÊ¾remote£¬²¢¼ÆÊ±¡£
Èç¹û´ðÂ¼»úÍË³ö(command=0x13XX)£¬±¾³ÌÐòÍË³ö¡£

r2_flag
	.7	=0,ÏìÁåÖÐ£»=1´ðÂ¼»úÓ¦´ð
	.6	·ÖÆÁÏÔÊ¾ÓÃ
	.5	=0,Ã»ÓÐÏìÁå»òÏìÁåÍ£Ö¹£»=1ÓÐÏìÁå
	.4	=0,Ã»ÓÐcaller id£»=1ÓÐcaller id
	.3	=0,²»ÓÃ¼ÆÊ±£»=1¼ÆÊ±

NOTE:
	½øÈë±¾³ÌÐòÊ±£¬ÏûÏ¢²»ÄÜ¶ªÊ§
*************************************************/
AppNewCall:
	BANK	2
	JPB	sys_flag,PROGRAMINIT,AppNewCall_init
	JPB	sys_flag,PROGRAMREIN,AppNewCall_rein
	JMP	AppNewCall_idle
AppNewCall_init:
	BC	sys_flag,PROGRAMINIT
AppNewCall_rein:
AppNewCall_display:
	BC	sys_flag,PROGRAMREIN
	PAGE	#(VGA)
	CALL	VgaBlankNum2
	CALL	VgaBlankChar
	PAGE	#($)
	CLR	r2_flag
AppNewCall_idle:
	XORA	sys_msg,@(WM_KEYPRESS)
	JPZ	AppNewCall_key
	XORA	sys_msg,@(WM_HANDSET)
	JPZ	AppNewCall_handset
	XORA	sys_msg,@(WM_COMMAND)
	JPZ	AppNewCall_command
AppNewCall_ret:
	JPNB	r2_flag,7,AppNewCall_ring
	JPNB	r2_flag,3,AppNewCall_ret_1
	PAGE	#(LibUpdateTimer)
	CALL	LibUpdateTimer
	CALL	LibDisplayTimer
	PAGE	#($)
	JMP	AppNewCall_ret_1
AppNewCall_ring:
	JPB	r2_flag,5,AppNewCall_ret_1
	JPNB	r2_flag,4,AppNewCall_ret_0
	MOV	A,r2_tmr_dial
	JPNZ	AppNewCall_ret_1
	MOV	A,r2_tmr_dial1
	JPNZ	AppNewCall_ret_1
	MOV	A,@(0x54)
	LCALL	LibSendOneCommand
AppNewCall_ret_0:
	CLR	program
AppNewCall_ret_1:
	RETL	@(0)
AppNewCall_key:
	XORA	sys_data,@(KEY_SPK)
	JPZ	AppNewCall_spk
	JMP	AppNewCall_ret
AppNewCall_spk:
	BS	sys_flag,SPKPHONE
	JMP	AppNewCall_answer
AppNewCall_handset:
	XORA	sys_data,@(HANDSET_OFF)
	JPZ	AppNewCall_answer
	JMP	AppNewCall_ret
AppNewCall_command:
	XORA	sys_data,@(0x19)
	JPZ	AppNewCall_ringin
	XORA	sys_data,@(0x1a)
	JPZ	AppNewCall_cid
	XORA	sys_data,@(0x15)
	JPZ	AppNewCall_seize
	XORA	sys_data,@(0x12)
	JPZ	AppNewCall_record
	XORA	sys_data,@(0x14)
	JPZ	AppNewCall_remote
	XORA	sys_data,@(0x13)
	JPZ	AppNewCall_exit
	JMP	AppNewCall_ret
AppNewCall_ringin:
	JPB	r2_flag,5,AppNewCall_ret
	BS	r2_flag,5
	JPB	r2_flag,4,AppNewCall_ret
	PAGE	#(VGA)
	CALL	VgaBlankNum2
	CALL	VgaBlankChar
	MOV	A,@(STYLE_CENTER)
	CALL	VgaChar
	MOV	A,@(STR_NewCall)
	CALL	VgaString
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)
	RETL	@(0)
AppNewCall_seize:
	BS	r2_flag,7
	BS	_P9,7
	MOV	A,@(1)
	LCALL	LibGetCommand
	MOV	r2_ax,A
	PAGE	#(VGA)
	CALL	VgaBlankChar
	MOV	A,@(STYLE_LEFT)
	CALL	VgaChar
	MOV	A,@(STR_Answered)
	CALL	VgaString
	;ADDA	r2_ax,@(0x48)
	;CALL	VgaChar
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)
	RETL	@(0)
AppNewCall_record:
	MOV	A,@(STR_ICM)
	JMP	AppNewCall_timer
AppNewCall_remote:
	MOV	A,@(STR_Remote)
	JMP	AppNewCall_timer
AppNewCall_timer:
	MOV	r2_ax,A
	BS	r2_flag,3			; ¼ÆÊ±
	PAGE	#(VGA)
	CALL	VgaBlankChar
	MOV	A,@(STYLE_LEFT)
	CALL	VgaChar
	MOV	A,r2_ax
	CALL	VgaString
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	
	PAGE	#(LibInitTimer)
	CALL	LibInitTimer
	CALL	LibDisplayTimer
	PAGE	#($)
	
	RETL	@(0)

AppNewCall_exit:				; À´Áå³¬Ê±£¬ÍË³ö
	JPB	r2_flag,7,AppNewCall_exit_seize
	BC	r2_flag,5
	BLOCK	3
	MOV	_RC,@(200)
	CLR	_RD				; Çå¿ÕÀ´µç
	DISI
	MOV	r2_tmr_dial1,@(5)		; µÈ´ý5Ãë
	CLR	r2_tmr_dial
	ENI
	RETL	@(0)
AppNewCall_exit_seize:
	BC	_P9,7
	CLR	program
	RETL	@(0)
AppNewCall_answer:				; Ó¦´ð
	MOV	A,@(PRO_AppDialingPhone)	; ×ªÖÁÍ¨»°³ÌÐò¡£
	LCALL	LibPushProgram
	RETL	@(0)

AppNewCall_cid:
	MOV	A,@(1)
	LCALL	LibGetCommand
	ADD	A,@(0)
	JPNZ	AppNewCall_ret
AppNewCall_callerid:
	
	BS	r2_flag,4
	DISI
	MOV	r2_tmr_dial1,@(5)		; µÈ´ý5Ãë
	CLR	r2_tmr_dial
	ENI
	
	BANK	1
	
	PAGE	#(VGA)
	CALL	VgaBlankNum2
	CALL	VgaBlankChar
	PAGE	#($)
	BLOCK	1
	MOV	_RC,@(8)
	MOV	r1_month,_RD
	INC	_RC
	MOV	r1_day,_RD
	MOV	r1_century,r1_rtc_century
	MOV	r1_year,r1_rtc_year
	LCALL	LibWeekCheck
	MOV	r1_rtc_week,r1_week
	MOV	r1_rtc_month,r1_month
	MOV	r1_rtc_day,r1_day
	INC	_RC
	MOV	r1_rtc_hour,_RD
	INC	_RC
	MOV	r1_rtc_minute,_RD
	BS	r1_rtc_flag,1			; ¸üÐÂÊ±ÖÓÏÔÊ¾
	
	BANK	2
	BC	r2_stamp3,7
	BLOCK	1
	MOV	_RC,@(8+4+33+17+1)
	MOV	A,_RD
	JPZ	$+2
	BS	r2_stamp3,7
	BS	r2_stamp1,0
	BS	sys_flag,STAMP
	
	MOV	A,@(0x20)
	LJMP	DisplayCallerPackage

/*
	INC	_RC
	MOV	A,_RD
	JPZ	AppNewCall_callerid_wrong	; Ã»ÓÐºÅÂë£¬´íÎóµÄÐÅÏ¢
	SUBA	_RD,@(112)			; "P"
	JPZ	AppNewCall_callerid_private

AppNewCall_copy_cid:				; Ê×ÏÈ½«ºÅÂë¿½±´ÖÁÀ´µçÇø
	CLR	cnt
AppNewCall_copy_cid_loop:
	BLOCK	1
	ADDA	cnt,@(13)
	MOV	_RC,A
	MOV	A,_RD
	JPZ	AppNewCall_copy_cid_end
	MOV	ax,A
	BLOCK	3
	ADDA	cnt,@(201)
	MOV	_RC,A
	MOV	_RD,ax
	INC	cnt
	SUBA	cnt,@(32)
	JPNC	AppNewCall_copy_cid_loop
AppNewCall_copy_cid_end:
	BLOCK	3
	MOV	_RC,@(200)
	MOV	_RD,cnt

AppNewCall_number:
	MOV	A,_RD
	JPZ	AppNewCall_name
	MOV	r1_ax,A
	
	CLR	r1_cnt
	MOV	A,@(STYLE_RIGHT)
	LCALL	VgaNum2
AppNewCall_number_loop:
	BLOCK	3
	ADDA	r1_cnt,@(201)
	MOV	_RC,A
	MOV	A,_RD
	JPZ	AppNewCall_number_end
	LCALL	VgaNum2
	INC	r1_cnt
	SUBA	r1_cnt,@(16)
	JPC	AppNewCall_number_end
	SUBA	r1_cnt,r1_ax
	JPNC	AppNewCall_number_loop
AppNewCall_number_end:
	PAGE	#(VGA)
	MOV	A,@(0)
	CALL	VgaNum2
	CALL	VgaDrawNum2
	PAGE	#($)


AppNewCall_name:				; ÊÕµ½ÈËÃû£¬Ö±½ÓÏÔÊ¾
	BLOCK	1
	MOV	_RC,@(8+4+33)
	MOV	A,_RD
	JPZ	AppNewCall_name_noname
	SUBA	_RD,@(112)
	JPZ	AppNewCall_callerid_private
	
	CLR	r1_cnt
	MOV	A,@(STYLE_LEFT)
	LCALL	VgaChar
AppNewCall_name_loop:
	BLOCK	1
	ADDA	r1_cnt,@(8+4+33+1)
	MOV	_RC,A
	MOV	A,_RD
	JPZ	AppNewCall_name_end
	LCALL	VgaChar
	INC	r1_cnt
	SUBA	r1_cnt,@(16)
	JPNC	AppNewCall_name_loop
AppNewCall_name_end:
	PAGE	#(VGA)
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)
AppNewCall_name_noname:
	BANK	2
	BC	r2_stamp3,7
	BLOCK	1
	MOV	_RC,@(8+4+33+17+1)
	MOV	A,_RD
	JPZ	$+2
	BS	r2_stamp3,7
	BS	r2_stamp1,0
	BS	sys_flag,STAMP
	

	RETL	@(0)

AppNewCall_callerid_wrong:
	MOV	A,@(STR_WrongMessage)
	JMP	$+2
AppNewCall_callerid_private:
	MOV	A,@(STR_Private)
	MOV	r1_ax,A
	PAGE	#(VGA)
	MOV	A,@(STYLE_LEFT)
	CALL	VgaChar
	MOV	A,r1_ax
	CALL	VgaString
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)
	RETL	@(0)
*/

	



AppNone:
	MOV	A,@(PRO_AppNoContent)
	LCALL	LibPushProgram
	RETL	@(1)
	
	






