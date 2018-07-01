.LIST
;---------------
;	input : no
;	output: no
;---------------
VP_AllOldMessagesEraseed:
	CALL	GET_LANGUAGE
	BS	ACZ,VP_AllOldMessagesEraseed_0
	SBHK	1
	BS	ACZ,VP_AllOldMessagesEraseed_French
	SBHK	1
	BS	ACZ,VP_AllOldMessagesEraseed_Spanish
VP_AllOldMessagesEraseed_0:		;English
	LACL	0XFF00|184
	CALL	STOR_VP
	RET
VP_AllOldMessagesEraseed_Spanish:	;Spanish
	LACL	0XFF00|185
	CALL	STOR_VP
	RET
VP_AllOldMessagesEraseed_French:	;French	
	LACL	0XFF00|186
	CALL	STOR_VP
	RET
;-------------------------------------------------------------------------------

.END
	