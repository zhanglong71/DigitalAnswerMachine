.LIST
;---------------
;	input : no
;	output: no
;---------------
VP_RecMsgAfterTheTone:
	CALL	GET_LANGUAGE
	BS	ACZ,VP_RecMsgAfterTheTone_0
	SBHK	1
	BS	ACZ,VP_RecMsgAfterTheTone_French
	SBHK	1
	BS	ACZ,VP_RecMsgAfterTheTone_Spanish
VP_RecMsgAfterTheTone_0:	;English
	LACL	0XFF00|56
	CALL	STOR_VP
	RET
VP_RecMsgAfterTheTone_Spanish:	;Spanish	
	LACL	0XFF00|115
	CALL	STOR_VP
	RET
VP_RecMsgAfterTheTone_French:	;French	
	LACL	0XFF00|179
	CALL	STOR_VP
	RET
;-------------------------------------------------------------------------------

.END
	