.LIST


;---------------
;	input : no
;	output: no
;---------------
VP_AnswerOff:
	CALL	GET_LANGUAGE
	BS	ACZ,VP_AnswerOff_0
	SBHK	1
	BS	ACZ,VP_AnswerOff_French
	SBHK	1
	BS	ACZ,VP_AnswerOff_Spanish
VP_AnswerOff_0:			;English
	LACL	0XFF00|43
	CALL	STOR_VP
	RET
VP_AnswerOff_Spanish:		;Spanish

	LACL	0XFF00|102
	CALL	STOR_VP
	RET
VP_AnswerOff_French:		;French

	LACL	0XFF00|166
	CALL	STOR_VP
	RET

;-------------------------------------------------------------------------------

.END
	