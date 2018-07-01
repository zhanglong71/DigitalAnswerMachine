.LIST

;---------------
;	input : no
;	output: no
;---------------
VP_AnswerOn:
	CALL	GET_LANGUAGE
	BS	ACZ,VP_AnswerOn_0
	SBHK	1
	BS	ACZ,VP_AnswerOn_French
	SBHK	1
	BS	ACZ,VP_AnswerOn_Spanish
VP_AnswerOn_0:		;English
	LACL	0XFF00|42
	CALL	STOR_VP
	RET
VP_AnswerOn_Spanish:		;Spanish

	LACL	0XFF00|101
	CALL	STOR_VP
	RET
VP_AnswerOn_French:		;French

	LACL	0XFF00|165
	CALL	STOR_VP
	RET

;-------------------------------------------------------------------------------

.END
	