.LIST
;---------------
;	input : no
;	output: no
;---------------
VP_RecAnnAfterTheTone:
	CALL	GET_LANGUAGE
	BS	ACZ,VP_RecAnnAfterTheTone_0
	SBHK	1
	BS	ACZ,VP_RecAnnAfterTheTone_French
	SBHK	1
	BS	ACZ,VP_RecAnnAfterTheTone_Spanish
VP_RecAnnAfterTheTone_0:	;English
	LACL	0XFF00|55
	CALL	STOR_VP
	RET
VP_RecAnnAfterTheTone_Spanish:	;Spanish	
	LACL	0XFF00|114
	CALL	STOR_VP
	RET
VP_RecAnnAfterTheTone_French:	;French	
	LACL	0XFF00|178
	CALL	STOR_VP
	RET
;-------------------------------------------------------------------------------

.END
	