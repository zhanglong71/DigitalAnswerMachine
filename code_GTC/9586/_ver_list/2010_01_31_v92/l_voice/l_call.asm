.LIST

;---------------
;	input : no
;	output: no
;---------------
VP_Call:
	CALL	GET_LANGUAGE
	BS	ACZ,VP_Call_0
	SBHK	1
	BS	ACZ,VP_Call_French
	SBHK	1
	BS	ACZ,VP_Call_Spanish
VP_Call_0:		;English
	LACL	0XFF00|51
	CALL	STOR_VP
	RET
VP_Call_Spanish:	;Spanish
	
	LACL	0XFF00|110
	CALL	STOR_VP
	RET
VP_Call_French:		;French
	LACL	0XFF00|174
	CALL	STOR_VP
	RET
;-------------------------------------------------------------------------------

.END
	