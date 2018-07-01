
/*************************************************
application ЫЕУї
1.  гЩprogramБЃДцГЬађЕФIDЃЌЭЌЪБИУIDвВдкstackжаЃЌВЛвЛЖЈдкеЛЖЅЁЃ
    ШчЙћprogram=0ЃЌБэУїЕБЧАЕФГЬађвбО­вбО­ЭЃжЙЃЌгЩprogramДгstackжаГіеЛЃЌШЁГіЩЯвЛМЖГЬађIDЁЃ
2.  СНИіживЊЮЛЃЌsys_flag,PROGRAMINITКЭsys_flag,PROGRAMREINЁЃ
    ЕБднЭЃБОГЬађЕїгУвЛИіаТЕФГЬађЃЌдђsys_flag,PROGRAMINITжУ1ЃЌЕквЛДЮжДааГЬађЁЃ
    ЕБГЬађЭЫГіЃЌЛиЕНЩЯвЛМЖГЬађЪБЃЌдђsys_flag,PROGRAMREINжУ1ЃЌГЬађжиаТНјШыЁЃ
    гЩГЬађздМКЧх0ЁЃ
    ЕквЛДЮжДааГЬађsys_flag,PROGRAMINITКЭsys_flag,PROGRAMREINЖМБЛжУ1ЁЃ
3.  ПЩвдНЋprogramжаЕФживЊЪ§ОнБЃДцдкstackжаЁЃ
    ЕквЛДЮжДааГЬађЃЌгЩapplicationДгstackжаГіеЛШЁЕУГЬађIDВЂБЃДцдкprogramжаЁЃ
    ашвЊЕїгУвЛИіаТЕФГЬађЃЌБиаыНЋГЬађЕФживЊЪ§ОнБЃДцЕНstackжаЃЌШЛКѓБЃДцБОГЬађЕФIDЃЌдйБЃДцаТГЬађЕФIDЁЃ
    БОГЬађЭЫГіЃЌжЛашвЊНЋprogramЧх0ЁЃ
    БОГЬађЭЫГіВЂНјШывЛИіаТЕФГЬађЃЌжЛашвЊБЃДцаТГЬађЕФIDЁЃ
4.  sys_flag.PROGRAMINIT=1ЃЌЖдГЬађзїГѕЪМЛЏЁЃ
    sys_flag.PROGRAMREIN=1ЃЌжиаТМЄЛюГЬађЃЌашвЊНЋГЬађЕФБЃДцЪ§ОнЛжИДЃЌЪ§ОнБиаыКЭЕїгУаТГЬађЪБДцШыЕФЪ§ОнЯрЦЅХфЁЃ
5.  ЙтБъБиаыБЃДцЁЃ
6.  ВЛФмСЌајбЙеЛГЌЙ§2ИіаТГЬађЁЃ
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
	JMP	Applicationџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџџ	LibSendOneCommand
	JMP	AppDialingPhone_return

AppDialingPhone_flash:				; flashМќАДЯТ
	LCALL	LibStoreRedialNumber
	CLR	_RC
	AND	_RD,@(0xf8)
	ADD	_RD,@(0x04)			; АДЯТflashМќЃЌЯШmute
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
AppDialingPhone_mute:				; muteМќАДЯТ
	INVB	_RD,4				; ИФБфmuteзДЬЌ
	JPNB	hardware,HANDSET,AppDialingPhone_mute_handset	; ЪжБњФУЦ№ЃЌmuteЪжБњ
	JMP	AppDialingPhone_mute_spk	; ЗёдђmuteУтЬс
AppDialingPhone_mute_handset:
	ANDA	_RD,@(0x07)
	JPNZ	AppDialingPhone_status		; ВЛдкД§ЛњзДЬЌЃЌБОРДОЭДІгкmuteзДЬЌ
	JPNB	_RD,4,AppDialingPhone_mute_handset_unmute
	BC	_P9,3				; handset, mute=0
	JMP	AppDialingPhone_status
AppDialingPhone_mute_handset_unmute:
	BS	_P9,3
	JMP	AppDialingPhone_status
AppDialingPhone_mute_spk:
	/*
	COMMAND:етРяЯђDSPЗЂЫЭSPK onУќСю
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
AppDialingPhone_spk:				; SPKМќАДЯТ
	JPNB	hardware,POWERSTATUS,AppDialingPhone_dial	; POWER down, SPKМќАДЯТЮоЯьгІЁЃ
AppDialingPhone_spk_1:
	INVB	sys_flag,SPKPHONE		; ИФБфSPKзДЬЌ
	
	/*
	COMMAND:етРяЯђDSPЗЂЫЭSPK ON/OFFУќСюЃЌЗЂЫЭONУќСюЪБЭЌЪБашвЊНЋMUTEзДЬЌЗЂЫЭГіШЅЁЃ
	*/
	JPNB	sys_flag,SPKPHONE,AppDialingPhone_spk_off
AppDialingPhone_spk_on:
	JPB	hardware,HANDSET,AppDialingPhone_status	;ERROR: ЪжБњЙвЛњзДЬЌЃЌSPKеЊЛњЃЌУЛгаетжжЧщПіЃЌПЩвдЕБГіДэДІРэЁЃ
AppDialingPhone_handset_spk:			; ЪжБњеЊЛњзДЬЌЯТАДЯТSPK
	CALL	AppPhoneIdle
	JMP	AppDialingPhone_status
AppDialingPhone_spk_off:
	JPB	hardware,HANDSET,AppDialingPhone_release	; ЪжБњЙвЛњзДЬЌЃЌSPKЙвЛњЃЌЙвЛњ
	CALL	AppPhoneIdle
	JMP	AppDialingPhone_status
	
AppDialingPhone_handset:
	XORA	sys_data,@(HANDSET_ON)
	JPZ	AppDialingPhone_handset_on
	XORA	sys_data,@(HANDSET_OFF)
	JPZ	AppDialingPhone_handset_off
AppDialingPhone_handset_on:			; ЪжБњЙвЛњ
	JPNB	sys_flag,SPKPHONE,AppDialingPhone_release	; SPK offзДЬЌЃЌЪжБњЙвЛњЃЌЙвЛњ
	CALL	AppPhoneIdle
	JMP	AppDialingPhone_status
AppDialingPhone_handset_off:			; ЪжБњеЊЛњ
	JPNB	sys_flag,SPKPHONE,AppDialingPhone_status	;ERROR: SPK offзДЬЌЃЌЪжБњеЊЛњЃЌУЛгаетжжЧщПіЃЌПЩвдЕБГіДэДІРэЁЃ
	BC	sys_flag,SPKPHONE		; SPK onзДЬЌЃЌЪжБњеЊЛњЃЌSPKзЊЮЊOFFзДЬЌ
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
	BC	_RD,6				; ЪЭЗХАДМќ
	JMP	AppDialingPhone_dial

AppDialingPhone_power:
	XORA	sys_data,@(POWER_ON)
	JPZ	AppDialingPhone_dial
	JPNB	sys_flag,SPKPHONE,AppDialingPhone_dial
	JMP	AppDialingPhone_spk_1		; SPK onзДЬЌЃЌpower downЃЌSPKЙвЛњЁЃ

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
	MOV	_RB,@(0xff)			; ВІКХЭЃжЙ
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
	BC	_P9,7				; ЙвЛњ
	BC	sys_flag,HOOKSTATUS
	PAGE	#(VGA)
	MOV	A,@(0)
	CALL	VgaNum2
	CALL	VgaDrawNum2
	PAGE	#($)
	MOV	A,@(PRO_AppDialingExit)		; НјШыЙвЛњЯдЪОбгЪБ5sЁЃ
	LCALL	LibPushProgram
	LCALL	LibDisplayDialingStatus
	JMP	AppDialingPhone_ret

AppDialingPhone_status:
	LCALL	LibDisplayDialingStatus
AppDialingPhone_dial:
	BANK	2
	MOV	A,r2_tmr_dial1
	JPNZ	AppDialingPhone_ret		; ВІКХЙ§ГЬжаЕФбгЪБЪБМфЮДЕНЁЃ
	MOV	A,r2_tmr_dial
	JPNZ	AppDialingPhone_ret		; ВІКХЙ§ГЬжаЕФбгЪБЪБМфЮДЕНЁЃ
	
	BLOCK	3
	CLR	_RC
	ANDA	_RD,@(0x07)
	TBL
	JMP	AppDialingPhone_dial_idle	; Д§Лњ
	JMP	AppDialingPhone_dial_mute1	; ВІКХЧАЕФmute
	JMP	AppDialingPhone_dial_number	; ВІКХ
	JMP	AppDialingPhone_dial_mute2	; ВІКХКѓЕФmute
	JMP	AppDialingPhone_dial_mute3	; flashЧАЕФmute
	JMP	AppDialingPhone_dial_flash	; flash
	JMP	AppDialingPhone_dial_mute4	; flashКѓЕФmute
AppDialingPhone_ret:
	RETL	@(0)				; ЗЕЛи
AppDialingPhone_dial_idle:			; Д§ЛњзДЬЌ
	INC	_RC
	MOV	A,_RD
	JPZ	AppDialingPhone_ret		; УЛгаД§ВІКХТы
	INC	_RC
	PAGE	#(VGA)
	MOV	A,_RD
	CALL	VgaNum2				; ЯдЪОКХТы
	CALL	VgaDrawNum2
	PAGE	#($)
	BLOCK	3
	MOV	_RC,@(2)
	MOV	A,_RD
	LCALL	LibNumTone			; ЖдКХТыНјааМьВщЃЌЭЌЪБзЊЛЛ
	ADD	A,@(0)
	JPZ	AppDialingPhone_dial_shiftnum	; ЮоаЇКХТыЃЌНЋКХТызѓвЦ
	XOR	A,@(0xff)
	JPZ	AppDialingPhone_dial_pause	; pause
	CLR	_RC
	AND	_RD,@(0xf8)
	ADD	_RD,@(0x01)			; гааЇКХТыЃЌНјШыВІКХЧАЕФmute
AppDialingPhone_mute1:
	DISI
	MOV	r2_tmr_dial,@(5)
	CLR	r2_tmr_dial1
	ENI
	BC	_P9,2				; ВЛЙмspkphoneДІгкФФжжзДЬЌЃЌВІКХmuteЗНЪНЖМвЛбљЁЃ
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
	LCALL	LibCopyRam			; НЋЪЃгрЕФКХТызѓвЦвЛЮЛ
	JMP	AppDialingPhone_ret
AppDialingPhone_dial_wait:			; waitзДЬЌ
	AND	_RD,@(0xf8)			; waitЪБМфЕНЃЌНјШыidleзДЬЌ
	JMP	AppDialingPhone_ret
AppDialingPhone_dial_mute1:			; ВІКХЧАЕФmuteзДЬЌ
	AND	_RD,@(0xf8)
	ADD	_RD,@(0x02)			; muteЪБМфЕНЃЌНјШыВІКХзДЬЌ
	DISI
	MOV	r2_tmr_dial,@(25)		; ВІКХ100ms
	CLR	r2_tmr_dial1
	ENI
	
	INC	_RC
	INC	_RC
	MOV	A,_RD
	LCALL	LibNumTone			; ЖдКХТыНјааМьВщЃЌЭЌЪБзЊЛЛ
	MOV	_RB,A
	JMP	AppDialingPhone_ret
AppDialingPhone_dial_number:			; ВІКХзДЬЌ
	JPNB	_RD,6,AppDialingPhone_dial_number_1	; АДМќЪЧЗёГжајжа
	INC	_RC
	SUBA	_RD,@(2)
	JPC	AppDialingPhone_dial_number_1	; ВЛЪЧзюКѓвЛИіКХТы
	JMP	AppDialingPhone_ret		; зюКѓвЛИіКХТыЃЌЧвВІКХМќАДМќГжајжаЁЃ
AppDialingPhone_dial_number_1:
	CLR	_RC
	MOV	_RB,@(0xff)			; ЭЃжЙВІКХ (ВІКХ100msЪБМфЕНЃЌзюКѓвЛИіКХТыАДМќЫЩЦ№)
	AND	_RD,@(0xf8)
	ADD	_RD,@(0x03)			; ВІКХЭъБЯЃЌНјШыВІКХжЎКѓЕФMUTEЪБЦкЁЃ
	DISI
	MOV	r2_tmr_dial,@(5)		; mute 20ms
	CLR	r2_tmr_dial1
	ENI
	JMP	AppDialingPhone_dial_shiftnum	; НЋЪЃгрЕФКХТызѓвЦвЛЮЛ
AppDialingPhone_dial_mute2:			; ВІКХжЎКѓЕФmuteзДЬЌЃЌmuteЭъЛиЕНtalkingзДЬЌЕФmute.
	AND	_RD,@(0xf8)			; muteЭъБЯЃЌбгЪБ60msЃЌНјШыidle
	DISI
	MOV	r2_tmr_dial,@(15)		; delay 60ms
	CLR	r2_tmr_dial1
	ENI
AppDialingPhone_mute2:
	
	CALL	AppPhoneIdle			; ЭЈЛАзДЬЌЃЌвВОЭЪЧД§ЛњзДЬЌ
	
	JMP	AppDialingPhone_ret
AppDialingPhone_dial_mute3:			; flashЧАЕФmute
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
AppDialingPhone_dial_mute4:			; flashКѓЕФmute
	AND	_RD,@(0xf8)
	DISI
	MOV	r2_tmr_dial,@(100)		; flashжЎКѓБиаыЕШД§400msжЎКѓВХФмПЊЪМВІКХ
	CLR	r2_tmr_dial1
	ENI
	JMP	AppDialingPhone_mute2

AppPhoneIdle:					; ЭЈЛАЕФД§ЛњзДЬЌ
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
дЄВІКХТыБрМ­ГЬађ
ГѕЪМЛЏ:	
	
ЯдЪО:	
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
КХТыБрМ­
БрМ­жИеыжИЯђвЊБрМ­ЕФКХТыЃЌЭЌЪБИУКХТыЩСЫИЃЌДІгкЙтБъзДЬЌЁЃ
АДЯТЪ§зжМќдкИУКХТыЕФЧАУцЬэМгвЛИіКХТыЃЌКѓУцКХТывРДЮгввЦЃЌБрМ­жИеыШдШЛжИЯђИУКХТыЃЌВЂЧвЙтБъгввЦвЛЮЛЁЃ
АДЯТBACKМќЃЌЩОГ§ЧАУцЕФвЛЮЛКХТыЃЌЧАУцЕФКХТывРДЮгввЦЃЌЙтБъЮЛжУВЛБфЁЃ
АДЯТDELМќЃЌЩОГ§ЕБЧАКХТыЃЌКѓУцвРДЮзѓвЦЃЌЙтБъЮЛжУВЛБфЁЃ
АДЯТLEFTЛђепUPМќЃЌЙтБъзѓвЦвЛЮЛЃЌЕБЕНДязюзѓБпЪБЃЌКХТыгввЦЃЌзѓБпУЛгаКХТыСЫЃЌВЛзіЯьгІЁЃ
АДЯТRIGHTЛђепDOWNМќЃЌЙтБъгввЦвЛЮЛЃЌЕБЙтБъЕНДязюгвБпЕФЯТвЛЮЛЪБЃЌЙтБъЯћЪЇЃЌКХТызѓвЦЃЌгвБпУЛгаКХТыЪБЃЌВЛзіЯьгІЁЃ
ГѕЪМзДЬЌЃК
    КХТыАДППгвХХСаЗХдкЕкЖўааЪ§зжЧјЁЃ
    ЙтБъЯћЪЇзДЬЌЃЌКХТыБрМ­жИеыЮЊзюКѓвЛИіКХТыЕФЯТвЛЮЛЁЃ
    r2_ax:	ЪфШыЕФБрМ­КХТы
    r2_cnt:	ДІгкБрМ­зДЬЌЕФКХТыЕФЮЛжУЃЌЦСФЛЕФЙтБъдкетИіКХТыЩЯЁЃ
    r2_bx:	ЯдЪОЦСгвЖЫКХТыЕФЮЛжУЃЌКХТыдкБрМ­ЧјЕФЮЛжУ
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
; ЪфШывЛИіКХТы
; дкЙтБъЮЛжУГіЪфШыИУКХТыЃЌВЂНЋЙтБъЮЛжУЕФд­КХТыКЭЦфКѓЕФКХТыгввЦвЛЮЛЁЃ
; ЭЌЪБЙтБъгввЦвЛЮЛЃЌЕБЙтБъ=ЦСЮЛжУЪБЃЌЦСЮЛжУвВвЊгввЦвЛЮЛЁЃ
AppEditNumber32_edit_num:
	MOV	r2_ax,A
	SUBA	_RD,@(32)
	JPC	AppEditNumber32_full		; БрМ­ГЄЖШЕНСЫ32ЮЛЃЌТњЃЌВЛФмЪфШыКХТыЁЃ
	INC	_RD				; ЪфШывЛЮЛКХТыЃЌГЄЖШ+1ЁЃ
	ADDA	r2_cnt,@(131)			; ЕУЕНБрМ­ЮЛжУ
	MOV	ax,A				; БрМ­ЮЛжУЕФЕижЗ
	MOV	bx,A				; БрМ­ЮЛжУЕФЯТвЛЮЛЕижЗ
	INC	bx
	SUBA	_RD,r2_cnt
	MOV	cnt,A				; гввЦЕФГЄЖШ
	LCALL	LibCopyRam
	ADDA	r2_cnt,@(131)
	MOV	_RC,A
	MOV	_RD,r2_ax
	MOV	_RC,@(131)
	JMP	AppEditNumber32_edit_right	; ЭЌЪБЙтБъвЊгввЦЁЃ
; ЩОГ§ЙтБъЧАУцЕФвЛЮЛКХТы
; ЩОГ§ЧАЕФКХТыЃЌЙтБъЕБЧАЮЛЕФКХТыМАЦфКѓЕФКХТызѓвЦвЛЮЛЁЃ
; ЙтБъЯрЖдБрМ­ЧјЮЛжУзѓвЦЃЌЦСЯрЖдБрМ­ЧјЮЛжУзѓвЦЁЃЙтБъЯдЪОЮЛжУВЛБфЁЃ
AppEditNumber32_edit_back:
	SUBA	r2_cnt,@(2)
	JPNC	AppEditNumber32_edit_ret	; ЙтБъЮЛжУдкЕквЛИіКХТыДІЃЌЮоЗЈЩОГ§ЧАУцЕФКХТыЁЃ
	DEC	_RD				; ЩОГ§вЛИіКХТыЃЌГЄЖШ-1
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
	JPNC	AppEditNumber32_edit_ret	; ЙтБъЮЛжУдкзюКѓвЛИіКХТыЕФЯТвЛЮЛЃЌЮоЗЈЩОГ§ЕБЧАЮЛЁЃ
	DEC	_RD				; ЩОГ§вЛИіКХТыЃЌГЄЖШ-1
	SUBA	_RD,r2_cnt
	JPNC	AppEditNumber32_edit_screen	; ЩОГ§зюКѓвЛЮЛКХТыЃЌВЛашвЊвЦЮЛЃЌжБНгЕїећЦСФЛЁЃ
	ADDA	r2_cnt,@(131)
	MOV	ax,A
	MOV	bx,A
	INC	ax
	SUBA	_RD,r2_cnt
	MOV	cnt,A
	INC	cnt
	LCALL	LibCopyRam
	MOV	_RC,@(131)
	JMP	AppEditNumber32_edit_screen	; ЙтБъЮЛжУВЛБфЃЌжБНгЕїећЦСФЛЁЃ
	

; ЙтБъзѓвЦЃЌЙтБъзѓвЦЪМжегавЛИіЯдЪОЁЃ
; ШчЙћЙтБъЫљдкБрМ­ЧјвбО­ЕНДяЕквЛИіКХТыЃЌЮоЗЈзѓвЦЁЃ
AppEditNumber32_edit_left:
	SUBA	r2_cnt,@(1)
	JPZ	AppEditNumber32_edit_ret	; ЕквЛИіКХТыЃЌЮоЗЈзѓвЦЁЃ
	DEC	r2_cnt				; ЙтБъзѓвЦЁЃ
	JMP	AppEditNumber32_edit_screen	; ЕїећЦСФЛ

; ЙтБъгввЦЃЌПЩвдвЦЖЏЕНЦСФЛжЎЭтЃЌетЪБr2_cnt=r2_bxЃЌЯдЪОЦСЩЯУЛгаЙтБъЁЃ
; ШчЙћЙтБъвбО­ЕНДязюКѓвЛИіКХТыЕФЯТвЛЮЛЃЌЮоЗЈгввЦЁЃ
AppEditNumber32_edit_right:
	SUBA	_RD,r2_cnt
	JPNC	AppEditNumber32_edit_ret	; зюКѓвЛИіКХТыЕФЯТвЛЮЛЃЌЮоЗЈгввЦЁЃ
	INC	r2_cnt				; ЙтБъгввЦ

; ЕїећЦСФЛ
; БЃжЄЙтБъДІгкЦСФЛЕФ2~15ИёЕФЗЖЮЇЃЌР§ЭтЃК
; 1. ЕквЛИіКХТыЃЌЙтБъдкЦСФЛЕФЕк1Иё
; 2. зюКѓвЛИіКХТыЃЌЙтБъдкЦСФЛЕФЕк16Иё
; 3. зюКѓвЛИіКХТыЕФЯТвЛЮЛЃЌЙтБъдкЦСФЛЕФ17Иё(ЦСФЛЩЯУЛгаЙтБъ)
AppEditNumber32_edit_screen:
	SUBA	_RD,r2_bx
	JPNC	AppEditNumber32_edit_screen_0	; ШчЙћЦСФЛЮЛжУДѓгкгааЇЪ§ОнГЄЖШЃЌЦСФЛЮЛжУЖЈЮЊзюКѓвЛЮЛЁЃ
	SUBA	_RD,@(17)
	JPNC	AppEditNumber32_edit_screen_0
	JMP	$+3
AppEditNumber32_edit_screen_0:
	MOV	r2_bx,_RD
	
	SUBA	r2_bx,r2_cnt
	JPNC	AppEditNumber32_edit_screen_2	; ЙтБъдкЦСФЛЕФгвЖЫ
	ADD	A,@(256-15)
	JPC	AppEditNumber32_edit_screen_1	; ЙтБъдкЦСФЛЕФЕк2ИёзѓВр
	ADD	A,@(15-1)
	JPNC	AppEditNumber32_edit_screen_2	; ЙтБъдкЦСФЛЕФЕк15ИёгвВр
	JMP	AppEditNumber32_edit_screen_ret
AppEditNumber32_edit_screen_1:			; ЙтБъдкЦСФЛЕФЕк2ИёзѓВрЁЃ
	SUBA	r2_cnt,@(1)
	JPZ	AppEditNumber32_edit_screen_1_1	; ЕквЛИіКХТы
	ADDA	r2_cnt,@(14)			; ЙтБъжИЕНЕкЖўИіКХТыДІЁЃ
	MOV	r2_bx,A
	JMP	AppEditNumber32_edit_screen_ret
AppEditNumber32_edit_screen_1_1:
	MOV	r2_bx,@(16)			; ЕквЛЦСЁЃ
	JMP	AppEditNumber32_edit_screen_ret
AppEditNumber32_edit_screen_2:
	SUBA	r2_cnt,_RD
	JPC	AppEditNumber32_edit_screen_2_1	; зюКѓвЛИіКХТыЛђзюКѓвЛИіКХТыЕФЯТвЛЮЛ
	ADDA	r2_cnt,@(1)			; ЙтБъжИЕНЕк15ИіКХТыДІЁЃ
	MOV	r2_bx,A
	JMP	AppEditNumber32_edit_screen_ret
AppEditNumber32_edit_screen_2_1:
	MOV	r2_bx,_RD			; зюКѓвЛЦСЁЃ
AppEditNumber32_edit_screen_ret:
	RETL	@(1)

AppEditNumber32_full:
	LJMP	AppEditFull

AppDisplayEditNumber:
	BANK	2
	LCALL	VgaBlankNum2			; ЯћГ§ВагАЁЃ
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
зЈгУВІКХЭЫГіГЬађЃЌЙвЛњКѓЭЫГіЕНетРяЃЌЯдЪОЭЈЛАаХЯЂ5sЁЃ
ГѕЪМЛЏ:	
	
ЯдЪО:	
Д§Лњ:	1. ДІРэhookМрВтГЬађ
	2. ЕШД§5sЁЃ
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
	MOV	A,@(PRO_AppDialingPhone)		; ЕчЛАеЊЛњЃЌНјШыВІКХГЬађ
	LCALL	LibPushProgram
	RETL	@(0)



ORG	0x1c00


AppMenuTab:
	TBL
; main menu
	DB	4,PRO_AppMenuMain	; ЕквЛЬѕЪЧГЄЖШКЭБОГЬађЕФID
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
жїВЫЕЅ
ГѕЪМЛЏ:	
	
ЯдЪО:	
Д§Лњ:	1. Call List
	2. Phone Book
	3. System Setting
	4. Digital Answering Machine
*************************************************/
AppMenuMain:
	MOV	A,@(0)
	JMP	AppMenu

/*************************************************
AppMenuPhoneBook
жїВЫЕЅ
ГѕЪМЛЏ:	
	
ЯдЪО:	
Д§Лњ:	1. Browse Phonebook
	2. Edit Phonebook
	3. Delete all
*************************************************/
AppMenuPhoneBook:
	MOV	A,@(5)
	JMP	AppMenu

/*************************************************
AppMenuSystemSetting
жїВЫЕЅ
ГѕЪМЛЏ:	
	
ЯдЪО:	
Д§Лњ:	1. Clock Setting
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
жїВЫЕЅ
ГѕЪМЛЏ:	
	
ЯдЪО:	
Д§Лњ:	1. Ring melody
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
жїВЫЕЅ
ГѕЪМЛЏ:	
	
ЯдЪО:	
Д§Лњ:	1. Play
	2. Record
	3. Delete all
*************************************************/
AppMenuDAM:
	MOV	A,@(22)
	JMP	AppMenu

/*************************************************
AppMenuRecord
жїВЫЕЅ
ГѕЪМЛЏ:	
	
ЯдЪО:	
Д§Лњ:	1. Memo Record
	2. OGM 1 record
	3. OGM 2 record
*************************************************/
AppMenuRecord:
	MOV	A,@(26)
	JMP	AppMenu

/*************************************************
AppMenuRecorderOn
жїВЫЕЅ
ГѕЪМЛЏ:	
	
ЯдЪО:	
Д§Лњ:	1. Set ring delay
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
input:	r2_ax -- ВЫЕЅРИЕФЯдЪОзжЗћДЎID.
	r2_bx -- АДЯТENTERМќКѓНјШыЕФГЬађID
	r2_cnt -- ВЫЕЅРИГЄЖШ(ЙВЖрЩйИіПЩбЁВЫЕЅ)
	r2_exb -- БОГЬађЕФГЬађID(гУгкЗЕЛи)
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
;		!0 -- ИУmenu_idБЛШЗШЯЃЌвЊЧѓНјШыИУmenu_idЕФГЬађ
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
дкВщПДКХТыЪБАДЯТmenuМќГіЯжвдЯТВЫЕЅ:
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
ВщПДКХТы
input:		acc вЊВщПДЕФЕижЗ
ГѕЪМЛЏ:	

	
ЯдЪО:	
Д§Лњ:
	ЪЙгУUPКЭDOWNМќЗ­ВщЁЃ
	r3_id	З­ВщЕФIDКХ, =0 end of list
	r3_flag
		.7 =0, ШЁКХТыЮДЭъБЯЃЌВЛФмАДUPЁЂDOWNМќ
		   =1, ПЩвдАДUPЁЂDOWNМќЗ­ВщЁЃ
		.6 =0, ЗжЦСЯдЪОЧА16ЮЛ
		   =1, ЗжЦСЯдЪОКѓ16ЮЛ
		.5 =0, КХТые§ГЃЯдЪО,
		   =1, КХТыЗжСНЦСЯдЪОЁЃ
		.4 =0, ШЫУће§ГЃЯдЪО
		   =1, ШЫУћЗжСНЦСЯдЪОЁЃ
		.3 =0, normal
		   =1, ЩОГ§зДЬЌ
	ЗжЦСЯдЪОЪБЃЌАД"LEFT","RIGHT"МќПЩвдПьЫйПДЧАвЛЦСКЭКѓвЛЦС

note:
	вђЮЊdialed callГЄЖШЮЊ32ЮЛЃЌЫљвдВЛФмДцЕНphonebookжаЁЃ
	
	
	
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
	MOV	r3_id,@(1)			; ДгЕквЛЬѕПЊЪМ
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
	
	CALL	AppGetCallInfo			; ЕУЕНКХТыаХЯЂ
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
AppLookOverCall_key_1:				; ЗжЦСЯдЪОЪБ
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
AppLookOverCall_left:				; АДЯТ"LEFT"ЯдЪОЕНЕквЛЦС
	BC	r3_flag,6
	JMP	AppLookOverCallDisplay
AppLookOverCall_right:				; АДЯТ"RIGHT"ЯдЪОЕНЕкЖўЦС
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
	MOV	r2_tmr_dial1,@(2)		; 3УыЛЛЦСЯдЪО
	ENI
	
	BANK	3
	ANDA	r3_flag,@(0x40)			; ЛЛЦСЯдЪОЁЃ
	OR	A,@(0x20)			; ЯдЪОЕкШ§аа
	LJMP	DisplayCallerPackage
	


;AppLookOverCallDisplay:
;	BANK	2
;	DISI
;	CLR	r2_tmr_dial
;	MOV	r2_tmr_dial1,@(3)		; 3УыЛЛЦСЯдЪО
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
;	MOV	r3_ax,@(8+4+1)			; ЯдЪОЧА16ЮЛКХТы
;	JMP	AppLookOverCallDisplay_number_loop
;AppLookOverCallDisplay_number_2:
;	MOV	r3_ax,@(8+4+1+16)			; ЯдЪОКѓ16ЮЛКХТы
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
;	MOV	r3_ax,@(8+4+1+32+1)		; ЯдЪОЧА16ЮЛШЫУћ
;	JMP	AppLookOverCallDisplay_name_loop
;AppLookOverCallDisplay_name_2:
;	MOV	r3_ax,@(8+4+1+32+1)		; ЯдЪОКѓ16ЮЛШЫУћ
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
ЩшжУЧјгђТы
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
ЩшжУЪБжг
ГѕЪМЛЏ:	
	ЛёШЁЯЕЭГЪБМф
	
ЯдЪО:	
Д§Лњ:
	1. ЩшжУаЁЪБ
	2. ЩшжУЗжжг
	3. ЩшжУУы
	
	r1_flag
		.7	=0 ЛЙУЛЪфШыШЮКЮЪ§жЕЃЌетЪБЯдЪОЫцзХЪБжгИќаТ
			=1 ПЊЪМЩшжУЃЌЯдЪОВЛИќаТ
		.6	=0 ВЛИФБфЙтБъ
			=1 ИФБфЙтБъ
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
AppSetClock_adjust:				; ЖдЪфШыжЕНјаааЃбщ
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
	BS	hardware,SYNCCLOCK		; ЪБжгЭЌВН
	
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
ЩшжУШеЦк
ГѕЪМЛЏ:	
	ЛёШЁЯЕЭГШеЦк
	
ЯдЪО:	
Д§Лњ:
	1. ЩшжУЪРМЭ
	2. ЩшжУФъЗн
	3. ЩшжУдТЗн
	4. ЩшжУЬь
	
	r1_flag
		.7	=0 ЛЙУЛЪфШыШЮКЮЪ§жЕЃЌетЪБЯдЪОЫцзХЪБжгИќаТ
			=1 ПЊЪМЩшжУЃЌЯдЪОВЛИќаТ
		.6	=0 ВЛИФБфЙтБъ
			=1 ИФБфЙтБъ
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
AppSetDate_adjust:				; ЖдЪфШыжЕНјаааЃбщ
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
	BS	hardware,SYNCCLOCK		; ЪБжгЭЌВН
	
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
input:	ax:  ЕБЧАжЕ
	bx:  ИУЕїећжЕФмЕїећЕФзюаЁжЕ
	exb: ИУЕїећжЕФмЕїећЕФзюДѓжЕ
output:	acc
	0 -- ЮоБфЛЏ (вдЯТАДМќУЛгаАДЯТ)
	1 -- ЕБЧАжЕБЛИФБф (ax=ИФБфКѓЕФжЕ)(UP/DOWN)
	2 -- зѓвЦ (LEFT)
	3 -- гввЦ (RIGHT)
	4 -- ШЗШЯ (OK)
	5 -- ШЁЯћ (EXIT)
note:
	БиаыЪЧАДМќЯТВХФмЕїгУ
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
	MOV	ax,bx				; ЕБЧАжЕГЌЙ§зюДѓжЕЃЌИГзюаЁжЕ
	JMP	AppSetValue_value
AppSetValue_down:
	SUBA	bx,ax
	JPC	$+3
	DEC	ax
	JMP	AppSetValue_value
	MOV	ax,exb				; ЕБЧАжЕГЌЙ§зюаЁжЕЃЌИГзюДѓжЕ
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
	_RSR	bank3 вЊЕїећЕФМФДцЦї
	acc	Ип4ЮЛ	зюаЁжЕ
		ЕЭ4ЮЛ	зюДѓжЕ
output:	acc
	0 -- ЮоБфЛЏ (вдЯТАДМќУЛгаАДЯТ)
	1 -- ЕБЧАжЕБЛИФБф (ax=ИФБфКѓЕФжЕ)(UP/DOWN)
	2 -- зѓвЦ (LEFT)
	3 -- гввЦ (RIGHT)
	4 -- ШЗШЯ (OK)
	5 -- ШЁЯћ (EXIT)
note:	МьВтUPЁЂDOWNЁЂLEFTЁЂRIGHTЁЂOKЁЂEXITАДМќ
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
ЩшжУСхЩљРраЭ
ГѕЪМЛЏ:	
	ЛёШЁЕБЧАЕФСхЩљ
	
ЯдЪО:	
Д§Лњ:
	r3_ringmelody
	=0	УЛгаСхЩљЃЌЮоЗЈЩшжУ
	=!0	СхЩљID
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
ЩшжУСхЩљвєСП
ГѕЪМЛЏ:	
	ЛёШЁЕБЧАЕФСхЩљвєСП
	
ЯдЪО:	
Д§Лњ:
	r3_ringvolume
	ЙВ5ЕЕЃЌзюаЁЕЕЮЊOFF
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
ЩшжУflashЪБМф
ГѕЪМЛЏ:	
	ЛёШЁЕБЧАЕФflashЪБМф
	
ЯдЪО:	
Д§Лњ:
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
ЩшжУpauseЪБМф
ГѕЪМЛЏ:	
	ЛёШЁЕБЧАЕФpauseЪБМф
	
ЯдЪО:	
Д§Лњ:
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
ЩшжУpauseЪБМф
ГѕЪМЛЏ:	
	ЛёШЁЕБЧАЕФpauseЪБМф
	
ЯдЪО:	
Д§Лњ:
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
ЩшжУД№ТМЛњ
ГѕЪМЛЏ:	
ЯдЪО:	
Д§Лњ:
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
ВЅЗХ(АДЯТPLAYМќ)
ГѕЪМЛЏ:	
	ЯђDSPЗЂЫЭВЅЗХУќСю
ЯдЪО:	
Д§Лњ:	
	r3_flag		ВЅЗХЪБЕФБъжОЮЛ
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
	CALL	LibInitTimer			; вЛИіаТЕФmsgВЅЗХЃЌжиаТМЦЪБ
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
OGMбЁдё(АДЯТOGMМќ)
ГѕЪМЛЏ:	
	
ЯдЪО:	
Д§Лњ:	
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
	ADD	r3_ogm,r3_id			; ШЗШЯКѓБЃДцogm
	BS	hardware,SYNCSETTING		; ЗЂЫЭЩшжУ
AppOgmSelect_exit:
	CLR	program				; ЭЫГіГЬађ
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
ТМmemo/OGMЃЌЛиЗХmemo/OGM
ГѕЪМЛЏ:	
	ЯђDSPЗЂЫЭТМвє/ЗХвєУќСю
ЯдЪО:	
Д§Лњ:	
	r3_id		ТМвє/ЗХвєЕФРраЭ
		.7	0-record 1-play
		.3~.0	0 - memo
			!0 - ogm

	r3_flag		ТМвєЪБЕФБъжОЮЛ
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
	JPB	r3_id,7,AppOneMessage_init_1	; ЛиЗХВЛгУЗЂЫЭВЅЗХУќСю
	MOV	A,@(0x46)			; record memo
	LCALL	LibSendOneCommand
	JMP	AppOneMessage_init_1
AppOneMessage_init_ogm:
	JPB	r3_id,7,$+3			; ЛиЗХ
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
	JPB	r3_id,7,AppOneMessage_idle_1	; play, жБНгМЦЪБ
	JPNB	r3_flag,7,AppOneMessage_idle_2	; record, ЕШЕНПЊЪМТМвєЪБВХМЦЪБ
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
	JPB	r3_id,7,AppOneMessage_stop_ret	; play, ЭЃжЙКѓЛиЕНЩЯвЛзДЬЌ
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
ЩшжУСхЩљДЮЪ§
ЙВ3жжЃЌ2 4 6
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
	BS	hardware,SYNCSETTING		; ЭЌВНЩшжУ
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
ЩшжУвЃПиУмТыЃЌ4ЮЛ

r3_id
r3_flag
	.7	=0 ЕквЛДЮЪфШызДЬЌ =1 ШЗШЯзДЬЌ
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
ЩшжУТМвєЪБМфЃЌМДбЙЫѕБШЁЃ

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
ИФБфД№ТМЛњon/offзДЬЌ
ГѕЪМЛЏ:	
ЯдЪО:	
Д§Лњ:
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
	JPB	r3_ogm,7,AppOnoffSelect_exit	; offзДЬЌЃЌ2sКѓздЖЏЭЫГі
	MOV	A,@(PRO_AppMenuRecorderOn)	; onзДЬЌЃЌ2sКѓздЖЏНјШыЩшжУВЫЕЅ
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
діМгвЛИіЕчЛАБОМЧТМ
ГѕЪМЛЏБрМ­ЧјЃЌвЛИіаТЕФЕчЛАБОЁЃ
*************************************************/
AppNewBook:
	BLOCK	3
	CLR	ax
	MOV	_RC,@(131)
	MOV	cnt,@(68)
	PAGE	#(LibPushStack)
	CALL	LibClearRam			; Ъєгкphonebook
	MOV	A,@(PRO_AppEditBook)
	CALL	LibPushProgram
	PAGE	#($)
	RETL	@(0)

/*************************************************
AppEditBook
БрМ­вЛИіЕчЛАБОМЧТМ
ГѕЪМЛЏ:	

	
ЯдЪО:	
Д§Лњ:
	КХТы16ЮЛ
	ШЫУћ16ЮЛ
	
	LEFT	- ЙтБъзѓвЦвЛЮЛ
	RIGHT	- ЙтБъгввЦвЛЮЛ
	BACK	- ЩОГ§ЙтБъЧАУцвЛЮЛ
	ERASE	- ЩОГ§ЙтБъЕБЧАЮЛ
	
	r2_flag:
		.7	=0 first display (ГѕЪМЛЏЕквЛДЮЙтБъЕФЮЛжУ)
		.6	=0 ДѓаД		(БрМ­ШЫУћ)
			=1 аЁаД
		.5	=0 ШЫУћШЗЖЈ
			=1 ШЫУћБИбЁжа	(БрМ­ШЫУћ)
		.4	=0 normal
			=1 searching
		.1~.0
			=0 edit number
			=1 edit name
			=2 edit music
	r2_cnt	- БрМ­ЮЛжУ

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
	MOV	A,_RD				; УЛгаКХТы
	JPZ	AppEditBook_ret			; ВЛФмАДOK
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
	JPZ	AppEditBook_ret			; УЛгаШЫУћЃЌВЛФмАДOKМќ
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
AppEditBook_ok_music:				; дкбЁдёmusicЪБАДOKМќЃЌБЃДцЁЃ
	MOV	A,@(0x54)			; ЯШЭЃжЙВЅЗХmusic
	LCALL	LibSendOneCommand
	
AppEditBook_save:
	MOV	A,r2_id
	JPZ	AppEditBook_save_ok
	CALL	AppEditorToMemory


AppEditBook_save_ok:
	
	CALL	AppSendEditorPackage		; ЗЂЫЭБрМ­Аќ
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
	MOV	A,@(PRO_AppSuccessfull)		; БЃДцЭъБЯЃЌЯдЪОГЩЙІ
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


AppSendEditorPackage:				; НЋБрМ­ЧјЕФКХТыЁЂШЫУћЕШаХЯЂДђАќЗЂИјDSPЁЃ
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
	LCALL	LibStoreCursor			; ЙтБъЮЛжУ
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
	LCALL	LibStoreCursor			; ЙтБъЮЛжУ
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
16ЮЛКХТыБрМ­

"LEFT"		ЙтБъзѓвЦ
"RIGHT"		ЙтБъгввЦ
"BACK"		ЩОГ§ЙтБъЧАУцЕФКХТы
"ERASE"		ЩОГ§ЙтБъЕБЧАЕФКХТы
"123"		дкЕБЧАЙтБъДІЪфШыКХТы
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
; ЪфШывЛИіКХТы
; дкЙтБъЮЛжУГіЪфШыИУКХТыЃЌВЂНЋЙтБъЮЛжУЕФд­КХТыКЭЦфКѓЕФКХТыгввЦвЛЮЛЁЃ
; ЭЌЪБЙтБъгввЦвЛЮЛ
AppEditNumber_num:
	MOV	r2_ax,A
	SUBA	_RD,@(16)
	JPC	AppEditFull			; БрМ­ГЄЖШЕНСЫ16ЮЛЃЌТњЃЌВЛФмЪфШыКХТыЁЃ
	INC	_RD				; ЪфШывЛЮЛКХТыЃЌГЄЖШ+1ЁЃ
	ADDA	r2_cnt,@(131)			; ЕУЕНБрМ­ЮЛжУ
	MOV	ax,A				; БрМ­ЮЛжУЕФЕижЗ
	MOV	bx,A				; БрМ­ЮЛжУЕФЯТвЛЮЛЕижЗ
	INC	bx
	SUBA	_RD,r2_cnt
	MOV	cnt,A				; гввЦЕФГЄЖШ
	LCALL	LibCopyRam
	ADDA	r2_cnt,@(131)
	MOV	_RC,A
	MOV	_RD,r2_ax
	MOV	_RC,@(131)
	JMP	AppEditNumber_right		; ЭЌЪБЙтБъвЊгввЦЁЃ
; ЩОГ§ЙтБъЧАУцЕФвЛЮЛКХТы
; ЩОГ§ЧАЕФКХТыЃЌЙтБъЕБЧАЮЛЕФКХТыМАЦфКѓЕФКХТызѓвЦвЛЮЛЁЃ
; ЙтБъзѓвЦвЛЮЛ
AppEditNumber_back:
	SUBA	r2_cnt,@(2)
	JPNC	AppEditNumber_ret		; ЙтБъЮЛжУдкЕквЛИіКХТыДІЃЌЮоЗЈЩОГ§ЧАУцЕФКХТыЁЃ
	DEC	_RD				; ЩОГ§вЛИіКХТыЃЌГЄЖШ-1
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
; ЩОГ§ЙтБъЕБЧАЕФвЛЮЛКХТы
; ЙтБъЦфКѓЕФКХТызѓвЦвЛЮЛЁЃ
; ЙтБъЮЛжУВЛБф
AppEditNumber_erase:
	SUBA	_RD,r2_cnt
	JPNC	AppEditNumber_ret		; ЙтБъЮЛжУдкзюКѓвЛИіКХТыЕФЯТвЛЮЛЃЌЮоЗЈЩОГ§ЕБЧАЮЛЁЃ
	DEC	_RD				; ЩОГ§вЛИіКХТыЃЌГЄЖШ-1
	SUBA	_RD,r2_cnt
	JPNC	AppEditNumber_display		; ЩОГ§зюКѓвЛЮЛКХТыЃЌВЛашвЊвЦЮЛЃЌжБНгЯдЪОЁЃ
	ADDA	r2_cnt,@(131)
	MOV	ax,A
	MOV	bx,A
	INC	ax
	SUBA	_RD,r2_cnt
	MOV	cnt,A
	INC	cnt
	LCALL	LibCopyRam
	MOV	_RC,@(131)
	JMP	AppEditNumber_display		; ЙтБъЮЛжУВЛБфЃЌжБНгЯдЪОЁЃ
; ЙтБъзѓвЦ
; ШчЙћЙтБъЫљдкБрМ­ЧјвбО­ЕНДяЕквЛИіКХТыЃЌЮоЗЈзѓвЦЁЃ
AppEditNumber_left:
	SUBA	r2_cnt,@(1)
	JPZ	AppEditNumber_ret		; ЕквЛИіКХТыЃЌЮоЗЈзѓвЦЁЃ
	DEC	r2_cnt				; ЙтБъзѓвЦЁЃ
	JMP	AppEditNumber_display		; ЯдЪО
; ЙтБъгввЦЃЌПЩвдвЦЖЏЕНЦСФЛжЎЭтЃЌетЪБr2_cnt=r2_bxЃЌЯдЪОЦСЩЯУЛгаЙтБъЁЃ
; ШчЙћЙтБъвбО­ЕНДязюКѓвЛИіКХТыЕФЯТвЛЮЛЃЌЮоЗЈгввЦЁЃ
AppEditNumber_right:
	SUBA	_RD,r2_cnt
	JPNC	AppEditNumber_ret		; зюКѓвЛИіКХТыЕФЯТвЛЮЛЃЌЮоЗЈгввЦЁЃ
	INC	r2_cnt				; ЙтБъгввЦ
	JMP	AppEditNumber_display		; ЯдЪО


AppEditNumber_display:
	RETL	@(1)



/*************************************************
16ЮЛШЫУћБрМ­

"LEFT"		ЙтБъзѓвЦ
"RIGHT"		ЙтБъгввЦ
"BACK"		ЩОГ§ЙтБъЧАУцЕФШЫУћ
"ERASE"		ЩОГ§ЙтБъЕБЧАЕФШЫУћ
"123"		дкЕБЧАЙтБъДІЪфШыШЫУћ

r2_bx		БЃДцАДЯТЕФАДМќ
r2_flag:
		.7	=0 first display (ГѕЪМЛЏЕквЛДЮЙтБъЕФЮЛжУ)
		.6	=0 ДѓаД		(БрМ­ШЫУћ)
			=1 аЁаД
		.5	=0 ШЫУћШЗЖЈ
			=1 ШЫУћБИбЁжа	(БрМ­ШЫУћ)
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
	JMP	AppEditName_right		; БИбЁГЌЪБЃЌЙтБъгввЦ
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
; ЪфШывЛИіКХТы
; дкЙтБъЮЛжУГіЪфШыИУКХТыЃЌВЂНЋЙтБъЮЛжУЕФд­КХТыКЭЦфКѓЕФКХТыгввЦвЛЮЛЁЃ
; ЭЌЪБЙтБъгввЦвЛЮЛ
AppEditName_num:
	MOV	r2_ax,A
	XOR	A,@(42)				; ХаЖЯЪЧЗё*АДЯТ
	JPZ	AppEditName_case
	JPB	r2_flag,5,AppEditName_num_1
	
	SUBA	_RD,@(16)
	JPC	AppEditFull			; БрМ­ГЄЖШЕНСЫ16ЮЛЃЌТњЃЌВЛФмЪфШыКХТыЁЃ
AppEditName_num_0:
	BS	r2_flag,5			; НјШыБИбЁ
	
	MOV	r2_bx,r2_ax			; БЃДцЪфШыЕФАДМќ
	CLR	r2_exb				; ДгЕквЛИізжЗћПЊЪМ
	
	INC	_RD				; ЪфШывЛЮЛКХТыЃЌГЄЖШ+1ЁЃ
	ADDA	r2_cnt,@(164)			; ЕУЕНБрМ­ЮЛжУ
	MOV	ax,A				; БрМ­ЮЛжУЕФЕижЗ
	MOV	bx,A				; БрМ­ЮЛжУЕФЯТвЛЮЛЕижЗ
	INC	bx
	SUBA	_RD,r2_cnt
	MOV	cnt,A				; гввЦЕФГЄЖШ
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
	

AppEditName_case:				; *АДЯТЃЌЧаЛЛДѓаЁаДЁЃ
	INVB	r2_flag,6
	MOV	A,@(0x00)
	LCALL	LibPromptBeep
	JMP	AppEditName_ret
; ЩОГ§ЙтБъЧАУцЕФвЛЮЛКХТы
; ЩОГ§ЧАЕФКХТыЃЌЙтБъЕБЧАЮЛЕФКХТыМАЦфКѓЕФКХТызѓвЦвЛЮЛЁЃ
; ЙтБъзѓвЦвЛЮЛ
AppEditName_back:
	BC	r2_flag,5
	SUBA	r2_cnt,@(2)
	JPNC	AppEditName_ret		; ЙтБъЮЛжУдкЕквЛИіКХТыДІЃЌЮоЗЈЩОГ§ЧАУцЕФКХТыЁЃ
	DEC	_RD				; ЩОГ§вЛИіКХТыЃЌГЄЖШ-1
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
; ЩОГ§ЙтБъЕБЧАЕФвЛЮЛКХТы
; ЙтБъЦфКѓЕФКХТызѓвЦвЛЮЛЁЃ
; ЙтБъЮЛжУВЛБф
AppEditName_erase:
	BC	r2_flag,5
	SUBA	_RD,r2_cnt
	JPNC	AppEditName_ret		; ЙтБъЮЛжУдкзюКѓвЛИіКХТыЕФЯТвЛЮЛЃЌЮоЗЈЩОГ§ЕБЧАЮЛЁЃ
	DEC	_RD				; ЩОГ§вЛИіКХТыЃЌГЄЖШ-1
	SUBA	_RD,r2_cnt
	JPNC	AppEditName_display		; ЩОГ§зюКѓвЛЮЛКХТыЃЌВЛашвЊвЦЮЛЃЌжБНгЯдЪОЁЃ
	ADDA	r2_cnt,@(164)
	MOV	ax,A
	MOV	bx,A
	INC	ax
	SUBA	_RD,r2_cnt
	MOV	cnt,A
	INC	cnt
	LCALL	LibCopyRam
	MOV	_RC,@(164)
	JMP	AppEditName_display		; ЙтБъЮЛжУВЛБфЃЌжБНгЯдЪОЁЃ
; ЙтБъзѓвЦ
; ШчЙћЙтБъЫљдкБрМ­ЧјвбО­ЕНДяЕквЛИіКХТыЃЌЮоЗЈзѓвЦЁЃ
AppEditName_left:
	BC	r2_flag,5
	SUBA	r2_cnt,@(1)
	JPZ	AppEditName_ret		; ЕквЛИіКХТыЃЌЮоЗЈзѓвЦЁЃ
	DEC	r2_cnt				; ЙтБъзѓвЦЁЃ
	JMP	AppEditName_display		; ЯдЪО
; ЙтБъгввЦЃЌПЩвдвЦЖЏЕНЦСФЛжЎЭтЃЌетЪБr2_cnt=r2_bxЃЌЯдЪОЦСЩЯУЛгаЙтБъЁЃ
; ШчЙћЙтБъвбО­ЕНДязюКѓвЛИіКХТыЕФЯТвЛЮЛЃЌЮоЗЈгввЦЁЃ
AppEditName_right:
	BC	r2_flag,5
	SUBA	_RD,r2_cnt
	JPNC	AppEditName_ret		; зюКѓвЛИіКХТыЕФЯТвЛЮЛЃЌЮоЗЈгввЦЁЃ
	INC	r2_cnt				; ЙтБъгввЦ
	JMP	AppEditName_display		; ЯдЪО


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
	MOV	_RD,A				; БрМ­ЧјЪєгкM1~M3
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
НЋM1~M3ЕФФкШнПНБДжСБрМ­Чј
*************************************************/
AppMemoryToEditor:
	MOV	ax,A
	CALL	LibClearEditor
	
	BLOCK	1
	MOV	_RC,ax
	MOV	A,_RD
	JPZ	AppMemoryToEditor_null		; memory ЮЊПе
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
НЋcallerid packageЕФФкШнПНБДжСБрМ­Чј
*************************************************/
AppCallerToEditor:
	CALL	LibClearEditor
	
	BLOCK	1
	MOV	_RC,@(8+4)
	MOV	A,_RD
	JPZ	AppCallerToEditor_null
	;SUBA	_RD,@(17)
	;JPC	AppCallerToEditor_null		; ГЄЖШГЌЙ§16ЮЛ
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

; ax:	дДЕижЗ(block 1)
; exa:	дДгааЇГЄЖШзюДѓГЄЖШ
; bx:	ФПБъЕижЗ(block 3)
; зюДѓ16ЮЛ
LibCopyRamEx1:
	CLR	cnt
LibCopyRamEx1_loop:
	SUBA	cnt,@(16)
	JPC	LibCopyRamEx1_end		; ГЄЖШЕН16ЮЛ
	SUBA	cnt,exa				; ГЄЖШЕНдДГЄЖШ
	JPC	LibCopyRamEx1_end
	BLOCK	1
	ADDA	ax,cnt
	MOV	_RC,A
	MOV	A,_RD
	JPZ	LibCopyRamEx1_end		; Ъ§ОнНсЪј
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
РДЕч
ЕБгаСхЩљРД(command=0x1900)ЃЌНјШыБОГЬађЯдЪОnew callЃЌ(ЛЙУЛгаЪеЕНcaller id)
ЕБгаcaller id(command=0x1a00)ЃЌНјШыБОГЬађЯдЪОРДЕчКХТыаХЯЂЁЃ
БОГЬађжаЃК
ШчЙћФУЦ№ЪжБњЛђАДЯТspkЃЌНјШыЭЈЛАГЬађ
ШчЙћД№ТМЛњгІД№(command=0x1700)ЃЌЯдЪОanswered ogmXЃЌЭЌЪБД№ТМЛњДІгкНгЯпзДЬЌЁЃ
ШчЙћД№ТМЛњТМвє(command=0x1200)ЃЌЯдЪОICMТМвєЃЌВЂМЦЪБЁЃ
ШчЙћД№ТМЛњНјШывЃПи(command=0x1300)ЃЌЯдЪОremoteЃЌВЂМЦЪБЁЃ
ШчЙћД№ТМЛњЭЫГі(command=0x13XX)ЃЌБОГЬађЭЫГіЁЃ

r2_flag
	.7	=0,ЯьСхжаЃЛ=1Д№ТМЛњгІД№
	.6	ЗжЦСЯдЪОгУ
	.5	=0,УЛгаЯьСхЛђЯьСхЭЃжЙЃЛ=1гаЯьСх
	.4	=0,УЛгаcaller idЃЛ=1гаcaller id
	.3	=0,ВЛгУМЦЪБЃЛ=1МЦЪБ

NOTE:
	НјШыБОГЬађЪБЃЌЯћЯЂВЛФмЖЊЪЇ
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
	BS	r2_flag,3			; МЦЪБ
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

AppNewCall_exit:				; РДСхГЌЪБЃЌЭЫГі
	JPB	r2_flag,7,AppNewCall_exit_seize
	BC	r2_flag,5
	BLOCK	3
	MOV	_RC,@(200)
	CLR	_RD				; ЧхПеРДЕч
	DISI
	MOV	r2_tmr_dial1,@(5)		; ЕШД§5Уы
	CLR	r2_tmr_dial
	ENI
	RETL	@(0)
AppNewCall_exit_seize:
	BC	_P9,7
	CLR	program
	RETL	@(0)
AppNewCall_answer:				; гІД№
	MOV	A,@(PRO_AppDialingPhone)	; зЊжСЭЈЛАГЬађЁЃ
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
	MOV	r2_tmr_dial1,@(5)		; ЕШД§5Уы
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
	BS	r1_rtc_flag,1			; ИќаТЪБжгЯдЪО
	
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
	JPZ	AppNewCall_callerid_wrong	; УЛгаКХТыЃЌДэЮѓЕФаХЯЂ
	SUBA	_RD,@(112)			; "P"
	JPZ	AppNewCall_callerid_private

AppNewCall_copy_cid:				; ЪзЯШНЋКХТыПНБДжСРДЕчЧј
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


AppNewCall_name:				; ЪеЕНШЫУћЃЌжБНгЯдЪО
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
	
	






