.LIST

;---------------
;	input : no
;	output: no
;---------------
VP_DefOGM:
	BIT	EVENT,8
	;BS	TB,VP_DefOGM2	;!!!OGM1 only
;-------
VP_DefOGM1:
	CALL	GET_LANGUAGE
	BS	ACZ,VP_DefOGM1_0
	SBHK	1
	BS	ACZ,VP_DefOGM1_French
	
VP_DefOGM1_0:	;English

VP_DefOGM1_French:		;French

	LACL	0XFF00|VOPIDX_FR_DefOGM1
	CALL	STOR_VP
	RET
;---
VP_DefOGM2:
	CALL	BEEP

	RET
;-------------------------------------------------------------------------------

.END
	