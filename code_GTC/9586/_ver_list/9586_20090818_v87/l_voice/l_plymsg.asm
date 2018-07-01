.LIST

;---------------
;	input : no
;	output: no
;---------------
VP_Erased:
	CALL	GET_LANGUAGE
	BS	ACZ,VP_Erased_0
	SBHK	1
	BS	ACZ,VP_Erased_French
	SBHK	1
	BS	ACZ,VP_Erased_Spanish
VP_Erased_0:		;English
	LACL	0XFF00|49
	CALL	STOR_VP
	RET
VP_Erased_Spanish:		;Spanish
	LACL	0XFF00|108
	CALL	STOR_VP
	RET
VP_Erased_French:		;French
	LACL	0XFF00|172
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_Message:
	CALL	GET_LANGUAGE
	BS	ACZ,VP_Message_0
	SBHK	1
	BS	ACZ,VP_Message_French
	SBHK	1
	BS	ACZ,VP_Message_Spanish
VP_Message_0:		;English
	LACL	0XFF00|45
	CALL	STOR_VP
	RET
VP_Message_Spanish:		;Spanish
	LACL	0XFF00|104
	CALL	STOR_VP
	RET
VP_Message_French:		;French
	LACL	0XFF00|168
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_Messages:
	CALL	GET_LANGUAGE
	BS	ACZ,VP_Messages_0
	SBHK	1
	BS	ACZ,VP_Messages_French
	SBHK	1
	BS	ACZ,VP_Messages_Spanish
VP_Messages_0:		;English
	LACL	0XFF00|46
	CALL	STOR_VP
	RET
VP_Messages_Spanish:		;Spanish
	LACL	0XFF00|105
	CALL	STOR_VP
	RET
VP_Messages_French:		;French
	LACL	0XFF00|169
	CALL	STOR_VP
	RET

;---------------
;	input : no
;	output: no
;---------------
VP_NewMessage:
	CALL	GET_LANGUAGE
	BS	ACZ,VP_NewMessage_0
	SBHK	1
	BS	ACZ,VP_NewMessage_French
	SBHK	1
	BS	ACZ,VP_NewMessage_Spanish
VP_NewMessage_0:		;English
	LACL	0XFF00|39
	CALL	STOR_VP
	RET
VP_NewMessage_Spanish:		;Spanish
	LACL	0XFF00|98
	CALL	STOR_VP
	RET
VP_NewMessage_French:		;French
	LACL	0XFF00|162
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_NewMessages:
	CALL	GET_LANGUAGE
	BS	ACZ,VP_NewMessages_0
	SBHK	1
	BS	ACZ,VP_NewMessages_French
	SBHK	1
	BS	ACZ,VP_NewMessages_Spanish
VP_NewMessages_0:		;English
	LACL	0XFF00|47
	CALL	STOR_VP
	RET
VP_NewMessages_Spanish:		;Spanish
	LACL	0XFF00|106
	CALL	STOR_VP
	RET
VP_NewMessages_French:		;French
	LACL	0XFF00|170
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_No:
	CALL	GET_LANGUAGE
	BS	ACZ,VP_No_0
	SBHK	1
	BS	ACZ,VP_No_French
	SBHK	1
	BS	ACZ,VP_No_Spanish
VP_No_0:		;English
	LACL	0XFF00|48
	CALL	STOR_VP
	RET
VP_No_Spanish:		;Spanish
	LACL	0XFF00|107
	CALL	STOR_VP
	RET
VP_No_French:		;French
	LACL	0XFF00|171
	CALL	STOR_VP
	RET

;---------------
;	input : no
;	output: no
;---------------
VP_YouHave:
	CALL	GET_LANGUAGE
	BS	ACZ,VP_YouHave_0
	SBHK	1
	BS	ACZ,VP_YouHave_French
	SBHK	1
	BS	ACZ,VP_YouHave_Spanish
VP_YouHave_0:		;English
	LACL	0XFF00|44
	CALL	STOR_VP
	RET
VP_YouHave_Spanish:		;Spanish
	LACL	0XFF00|103
	CALL	STOR_VP
	RET
VP_YouHave_French:		;French
	LACL	0XFF00|167
	CALL	STOR_VP
	RET

;-------------------------------------------------------------------------------

.END
	