.LIST
;-------------------------------------------------------------------------------
;	ANNOUNCE_NUM
;-------------------------------------------------------------------------------

ANNOUNCE_NUM:
	SAH	SYSTMP3
	BS	ACZ,ANNOUNCE_NUM_0
	SBHK	21
	BS	SGN,ANNOUNCE_NUM2
	
	LAC	SYSTMP3
	CALL	HEX_DGT
	SAH	SYSTMP3
	
	SFR	4
	ADHK	18
	ORL	0XFF00
	CALL	STOR_VP
	
	LAC	SYSTMP3
	ANDL	0X0F
	BS	ACZ,ANNOUNCE_NUM_END
	ORL	0XFF00
	CALL	STOR_VP
	BS	B1,ANNOUNCE_NUM_END
ANNOUNCE_NUM_0:

	LACL	0XFF00|195
	CALL	STOR_VP
	BS	B1,ANNOUNCE_NUM_END
ANNOUNCE_NUM2:
	LAC	SYSTMP3
	ORL	0XFF00
	CALL	STOR_VP
ANNOUNCE_NUM_END:
	
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_AllOldMessageErased:
	LACL	0XFF00|184
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_AnswerOn:
	LACL	0XFF00|136
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_AnswerOff:
	LACL	0XFF00|137
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_DefOGM:
	LACL	0XFF00|133
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_DoYouWantToDelAllMessage:
	LACL	0XFF00|210
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_EndOfMessage:
	LACL	0XFF00|183
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_ErrorCode:
	LACL	0XFF00|213
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_AllOldMessagesErased:
	LACL	0XFF00|184
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_Message:
	LACL	0XFF00|60
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_MemoryFull:
	LACL	0XFF00|186
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_Messages:
	LACL	0XFF00|61
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_NEW:
	LACL	0XFF00|117
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_NewCodeIs:
	LACL	0XFF00|209
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_No:
	LACL	0XFF00|202
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_NoMessage:
	LACL	0XFF00|153
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_Oclock:
	LACL	0XFF00|57
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_OutGoingMessage:
	LACL	0XFF00|198
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_PlsInputYourRCode:
	LACL	0XFF00|212
	CALL	STOR_VP
	RET
;---------------
;	input : ACCH = WEEK(0/1/2/3/4/5/6)
;	output: no
;---------------
VP_WEEK:
	ADHL	0XFF00|34
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_YouHave:
	LACL	0XFF00|201
	CALL	STOR_VP
	RET
;-------------------------------------------------------------------------------

.END
	