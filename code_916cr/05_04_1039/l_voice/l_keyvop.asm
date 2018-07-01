.LIST
;---------------
;	input : no
;	output: no
;---------------
VP_SetUpMenu:
	CALL	GET_LANGUAGE
	BS	ACZ,VP_SetUpMenu_0
	SBHK	1
	BS	ACZ,VP_SetUpMenu_French
	SBHK	1
	BS	ACZ,VP_SetUpMenu_Spanish
VP_SetUpMenu_0:		;English
	LACL	0XFF00|59
	CALL	STOR_VP
	RET
VP_SetUpMenu_Spanish:		;Spanish	
	LACL	0XFF00|118
	CALL	STOR_VP
	RET
VP_SetUpMenu_French:		;French	
	LACL	0XFF00|182
	CALL	STOR_VP
	RET

;---------------
;	input : no
;	output: no
;---------------
VP_MemoHelp:
	LACK	0X005
	CALL	STOR_VP
	RET

;-------------------------------------------------------------------------------

.END
	