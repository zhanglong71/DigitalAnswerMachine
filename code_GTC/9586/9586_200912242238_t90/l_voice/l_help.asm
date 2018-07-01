.LIST
;-------------------------------------------------------------------------------
;	Function : VP_Help	
;	INPUT : no
;	output: no
;	for help on
;-------------------------------------------------------------------------------
VP_DefHelp:
;VP_Help:
	CALL	GET_LANGUAGE
	BS	ACZ,VP_Help_0
	SBHK	1
	BS	ACZ,VP_Help_French
	SBHK	1
	BS	ACZ,VP_Help_Spanish
VP_Help_0:		;English
	LACL	0XFF00|253
	CALL	STOR_VP
	RET
VP_Help_Spanish:	;Spanish
	LACL	0XFF00|254
	CALL	STOR_VP
	RET
VP_Help_French:		;French
	LACL	0XFF00|255
	CALL	STOR_VP
	RET
;-------------------------------------------------------------------------------

.END
	