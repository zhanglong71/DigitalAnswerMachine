.LIST
;-------------------------------------------------------------------------------
;	ANNOUNCE_NUM
;-------------------------------------------------------------------------------

ANNOUNCE_NUM:
	BS	SGN,ANNOUNCE_NUM_END	;小于0
	SAH	SYSTMP3
	SBHK	21
	BS	SGN,ANNOUNCE_NUM2	;0..20
	SBHK	9
	BS	ACZ,ANNOUNCE_NUM30	;30
	SBHK	10
	BS	ACZ,ANNOUNCE_NUM40	;40
	SBHK	10
	BS	ACZ,ANNOUNCE_NUM50	;50
	
	LAC	SYSTMP3
	CALL	HEX_DGT
	SAH	SYSTMP3

	SFR	4
	ADHK	23
	ORL	0XFF00
	CALL	STOR_VP
	
	LAC	SYSTMP3
	ANDL	0X0F
	BS	ACZ,ANNOUNCE_NUM_END
	ADHK	1		;!!序号加1才是对应的VOP
	ORL	0XFF00
	CALL	STOR_VP
	BS	B1,ANNOUNCE_NUM_END
ANNOUNCE_NUM30:
	LACL	0XFF00|22
	CALL	STOR_VP
	BS	B1,ANNOUNCE_NUM_END
ANNOUNCE_NUM40:
	LACL	0XFF00|23
	CALL	STOR_VP
	BS	B1,ANNOUNCE_NUM_END
ANNOUNCE_NUM50:
	LACL	0XFF00|24
	CALL	STOR_VP
	BS	B1,ANNOUNCE_NUM_END
ANNOUNCE_NUM2:
	LAC	SYSTMP3
	ADHK	1
	ORL	0XFF00
	CALL	STOR_VP
ANNOUNCE_NUM_END:
	
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_All:
	LACL	0XFF00|47
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_Announcement:
	LACL	0XFF00|40
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_AnswerOn:
	LACL	0XFF00|41
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_AnswerOff:
	LACL	0XFF00|42
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_DefOGM:
	BIT	EVENT,8
	BS	TB,VP_DefOGM2
;---
VP_DefOGM1:
	LACL	0XFF00|56
	CALL	STOR_VP
	RET
;---
VP_DefOGM2:
	LACL	0XFF00|58
	CALL	STOR_VP
	RET

;---------------
;	input : no
;	output: no
;---------------
VP_EndOfMessages:
	LACL	0XFF00|46
	CALL	STOR_VP
	RET

;---------------
;	input : no
;	output: no
;---------------
VP_Erased:
	LACL	0XFF00|44
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_Message:
	LACL	0XFF00|37
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_Messages:
	LACL	0XFF00|38
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_MemoryFull:
	LACL	0XFF00|53
	CALL	STOR_VP
	RET

;---------------
;	input : no
;	output: no
;---------------
VP_NEW:
	LACL	0XFF00|43
	CALL	STOR_VP
	RET

;---------------
;	input : no
;	output: no
;---------------
VP_No:
	LACL	0XFF00|29
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_PleaseSet:
	LACL	0XFF00|57
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_Rings:
	LACL	0XFF00|50
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_SecurityCode:
	LACL	0XFF00|39
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_TollSaver:
	LACL	0XFF00|51
	CALL	STOR_VP
	RET
;---------------
;	input : ACCH = WEEK(0/1/2/3/4/5/6)
;	output: no
;---------------
VP_WEEK:
	ADHL	0XFF00|30
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_YouHave:
	LACL	0XFF00|48
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_YouHaveNoMessages:
	LACL	0XFF00|49
	CALL	STOR_VP
	RET

;-------------------------------------------------------------------------------
VP_CHKMemoryFull:
	BIT	ANN_FG,13
	BZ	TB,VP_CHKMemoryFull_END
	CALL	VP_MemoryFull
VP_CHKMemoryFull_END:
	RET
;-------------------------------------------------------------------------------
.END
	