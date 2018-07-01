.LIST

;---------------
;	input : no
;	output: no
;---------------
VP_EndOf:
	CALL	GET_LANGUAGE
	BS	ACZ,VP_EndOf_0
	SBHK	1
	BS	ACZ,VP_EndOf_French
	SBHK	1
	BS	ACZ,VP_EndOf_Spanish
VP_EndOf_0:		;English
	LACL	0XFF00|50
	CALL	STOR_VP
	RET
VP_EndOf_Spanish:		;Spanish

	LACL	0XFF00|109
	CALL	STOR_VP
	RET
VP_EndOf_French:		;French
	LACL	0XFF00|173
	CALL	STOR_VP
	RET

;-------------------------------------------------------------------------------

.END
	