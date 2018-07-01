
;------------------------------------------------------------------------------
;	Function : VP_MESSAGE
;	
;	Generate a VP "message"
;------------------------------------------------------------------------------
VP_MESSAGE:
	
	CALL	GET_LANGUAGE
	BS	ACZ,VP_GMESSAGE

	LACK	0x005
	CALL	STOR_VP
	
	RET
VP_GMESSAGE:
	LACL	0XFF00|VOP_INDEX_Message
	CALL	STOR_VP
	
	RET
;------------------------------------------------------------------------------
;	Function : VP_MESSAGES
;	
;	Generate a VP "messages"
;------------------------------------------------------------------------------
VP_MESSAGES:
	
	CALL	GET_LANGUAGE
	BS	ACZ,VP_GMESSAGES

	LACK	0x005
	CALL	STOR_VP
	
	RET
VP_GMESSAGES:
	LACL	0XFF00|VOP_INDEX_Messages
	CALL	STOR_VP
	
	RET
;------------------------------------------------------------------------------
;	Function : VP_ENDOF
;	
;	Generate a VP "end of"
;------------------------------------------------------------------------------
VP_ENDOF:
	
	CALL	GET_LANGUAGE
	BS	ACZ,VP_GENDOF

	LACK	0x005
	CALL	STOR_VP
	
	RET
VP_GENDOF:
	
	LACL	0XFF00|VOP_INDEX_EndOf
	CALL	STOR_VP
	
	RET

;-------------------------------------------------------------------------------
;	Function : VP_DEFAULTOGM
;	
;	Generate a VP "DEFAULTOGM"
;-------------------------------------------------------------------------------
VP_DEFAULTOGM:
	
	CALL	GET_LANGUAGE
	BS	ACZ,VP_GDEFAULTOGM

	LACK	0x005
	CALL	STOR_VP
	
	RET
VP_GDEFAULTOGM:
	LACL	0XFF00|VOP_INDEX_DefaultOGM
	CALL	STOR_VP
	
	RET
;-------------------------------------------------------------------------------
;	Function : VP_DEFOGM5
;	
;	Generate a VP "DEFAULTOGM5"
;-------------------------------------------------------------------------------
VP_DEFOGM5:
	
	CALL	GET_LANGUAGE
	BS	ACZ,VP_GDEFOGM5

	LACK	0x005
	CALL	STOR_VP
	
	RET
VP_GDEFOGM5:
	LACL	0XFF00|VOP_INDEX_Default5OGM
	CALL	STOR_VP
	
	RET
;------------------------------------------------------------------------------
;	Function : VP_NO
;	
;	Generate a VP "no"
;------------------------------------------------------------------------------
VP_NO:
	
	CALL	GET_LANGUAGE
	BS	ACZ,VP_GNO

	LACK	0x005
	CALL	STOR_VP
	
	RET
VP_GNO:
	LACL	0XFF00|VOP_INDEX_No
	CALL	STOR_VP
	
	RET
;------------------------------------------------------------------------------
;	Function : VP_NEW
;	
;	Generate a VP "new"
;------------------------------------------------------------------------------
VP_NEW:
	
	CALL	GET_LANGUAGE
	BS	ACZ,VP_GNEW

	LACK	0x005
	CALL	STOR_VP
	
	RET
VP_GNEW:
	LACL	0XFF00|VOP_INDEX_New
	CALL	STOR_VP
	
	RET
;------------------------------------------------------------------------------
;	Function : VP_MAILBOX
;	
;	Generate a VP "mail box"
;------------------------------------------------------------------------------
VP_MAILBOX:
	
	CALL	GET_LANGUAGE
	BS	ACZ,VP_GMAILBOX

	LACK	0x005
	CALL	STOR_VP
	
	RET
VP_GMAILBOX:
	LACL	0XFF00|VOP_INDEX_MailBox
	CALL	STOR_VP
	
	RET

;------------------------------------------------------------------------------
;	Function : VP_MEMFUL
;	
;	Generate a VP "memory is full"
;------------------------------------------------------------------------------
VP_MEMFUL:
	
	CALL	GET_LANGUAGE
	BS	ACZ,VP_GMEMFUL

	LACK	0x005
	CALL	STOR_VP
	
	RET
VP_GMEMFUL:
	LACL	0XFF00|VOP_INDEX_MemoryIsFull
	CALL	STOR_VP
	
	RET
;-------------------------------------------------------------------------
;	Function : VP_EINE
;	input :  no
;	output : no
;-------------------------------------------------------------------------
VP_ONE:
	
	CALL	GET_LANGUAGE
	BS	ACZ,VP_GONE

	LACK	0x005
	CALL	STOR_VP
	
	RET
VP_GONE:
	
	LACL	0XFF00|VOP_INDEX_Eine
	CALL	STOR_VP
	
	RET

;-------------------------------------------------------------------------
;	Function : ANNOUNCE_NUM/ANNOUNCE_GNUM --- 数字入播放队列
;	input : ACCH = 要播放的数字(0..99)
;	output : no
;-------------------------------------------------------------------------
ANNOUNCE_NUM:
	SAH	SYSTMP3
	
	CALL	GET_LANGUAGE
	BS	ACZ,ANNOUNCE_GNUM
	
	LACK	0X005
	CALL	STOR_VP
	
	RET
;---------------
ANNOUNCE_GNUM:		;for German

	LAC	SYSTMP3
	BS	ACZ,ANNOUNCE_GNUM_0	;0
	SBHK	21
	BS	SGN,ANNOUNCE_GNUM_1_20	;1..20

;-------------------20..99	
	LAC	SYSTMP3
	CALL	HEX_DGT
	SAH	SYSTMP3

	LAC	SYSTMP3
	ANDL	0X0F
	BS	ACZ,ANNOUNCE_GNUM0_0	;
	SBHK	1
	BS	ACZ,ANNOUNCE_GNUM0_0_1
	BS	B1,ANNOUNCE_GNUM0_X2_X9
ANNOUNCE_GNUM0_0_1:
	LACL	0XFF00|VOP_INDEX_Ein	;1(ein)
	CALL	STOR_VP
	BS	B1,ANNOUNCE_GNUM0_UND
ANNOUNCE_GNUM0_X2_X9:	
	LAC	SYSTMP3
	ANDL	0X0F		;(个位2..9)
	ORL	0XFF00
	CALL	STOR_VP
ANNOUNCE_GNUM0_UND:	
	LACL	0XFF00|VOP_INDEX_Und	;(und)
	CALL	STOR_VP
ANNOUNCE_GNUM0_0:		;20/30/40/50/60/70/80/90
	LAC	SYSTMP3
	SFR	4
	ADHK	18		;(十位2..9)
	ORL	0XFF00
	CALL	STOR_VP

	BS	B1,ANNOUNCE_GNUM_END
;-------------------0
ANNOUNCE_GNUM_0:
	LACL	0XFF00|VOP_INDEX_Null
	CALL	STOR_VP
	BS	B1,ANNOUNCE_GNUM_END
;-------------------1..20
ANNOUNCE_GNUM_1_20:
	LAC	SYSTMP3
	ORL	0XFF00
	CALL	STOR_VP
	BS	B1,ANNOUNCE_GNUM_END

ANNOUNCE_GNUM_END:
	
	RET

;-------------------------------------------------------------------------------

.END
	