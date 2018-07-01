.LIST
;---------------
;	input : no
;	output: no
;---------------
VP_YourAnnouncementIs:
	CALL	GET_LANGUAGE
	BS	ACZ,VP_YourAnnouncementIs_0
	SBHK	1
	BS	ACZ,VP_YourAnnouncementIs_French
	SBHK	1
	BS	ACZ,VP_YourAnnouncementIs_Spanish
VP_YourAnnouncementIs_0:	;English	
	LACL	0XFF00|53
	CALL	STOR_VP
	RET
VP_YourAnnouncementIs_Spanish:	;Spanish
	LACL	0XFF00|112
	CALL	STOR_VP
	RET
VP_YourAnnouncementIs_French:	;French
	LACL	0XFF00|176
	CALL	STOR_VP
	RET
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
	SBHK	1
	BS	ACZ,VP_DefOGM1_Spanish
VP_DefOGM1_0:		;English
	LACL	0XFF00|54
	CALL	STOR_VP
	RET
VP_DefOGM1_Spanish:		;Spanish

	LACL	0XFF00|113
	CALL	STOR_VP
	RET
VP_DefOGM1_French:		;French

	LACL	0XFF00|177
	CALL	STOR_VP
	RET
;---
VP_DefOGM2:
	CALL	BEEP

	RET
;---------------
;	input : no
;	output: no
;---------------
VP_PressAndHoldAnnKeyToRecAnnouncement:
	CALL	GET_LANGUAGE
	BS	ACZ,VP_PressAndHoldAnnKeyToRecAnnouncement_0
	SBHK	1
	BS	ACZ,VP_PressAndHoldAnnKeyToRecAnnouncement_French
	SBHK	1
	BS	ACZ,VP_PressAndHoldAnnKeyToRecAnnouncement_Spanish
VP_PressAndHoldAnnKeyToRecAnnouncement_0:	;English
	LACL	0XFF00|58
	CALL	STOR_VP
	RET
VP_PressAndHoldAnnKeyToRecAnnouncement_Spanish:	;Spanish
	LACL	0XFF00|117
	CALL	STOR_VP
	RET
VP_PressAndHoldAnnKeyToRecAnnouncement_French:	;French
	LACL	0XFF00|181
	CALL	STOR_VP
	RET
;-------------------------------------------------------------------------------

.END
	