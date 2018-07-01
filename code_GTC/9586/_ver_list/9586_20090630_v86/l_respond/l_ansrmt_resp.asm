.LIST
;-------------------------------------------------------------------------------
;	Function : GET_RESPOND	
;	input : ACCH(0..F)
;	output: ACCH
;-------------------------------------------------------------------------------
GET_RESPOND:
	BIT	EVENT,7
	BS	TB,GET_RESPOND_REC	;RECORD
	BIT	EVENT,6
	BS	TB,GET_RESPOND_PLY	;PLAY
	BIT	EVENT,5
	BS	TB,GET_RESPOND_END	;BEEP不作处理
	BIT	EVENT,4
	BS	TB,GET_RESPOND_LIN	;LINE
	;BIT	EVENT,3
	;BS	TB,GET_RESPOND_PHO	;speakerphone
	CALL	GET_VP
	BZ	ACZ,INT_BIOS_START

	RET
;---------------------------------------
GET_RESPOND_PLY:		;play(voice prompt) mode
	BIT	RESP,6
	BZ	TB,GET_RESPOND_BTONE

	LACL	CSEG_END
	CALL	STOR_MSG		;产生结束消息
	BS	B1,GET_RESPOND_BTONE
;---------------------------------------
GET_RESPOND_REC:		;record mode
	BIT	RESP,7
	BZ	TB,GET_RESPOND_VOX
	
	LACL	CREC_FULL		;产生memfull消息
	CALL	STOR_MSG
	BS	B1,GET_RESPOND_VOX
;---------------------------------------
GET_RESPOND_LIN:
;---------------------------------------
;---------
GET_RESPOND_VOX:	
	CALL	VOX_CHK
	BS	ACZ,GET_RESPOND_VOX_END
	LACL	CMSG_VOX
	CALL	STOR_MSG
GET_RESPOND_VOX_END:	
;---------	
;---------
GET_RESPOND_BTONE:			;for record/play/line/voice_prompt mode 
	CALL	BTONE_CHK
	BS	ACZ,GET_RESPOND_BTONE_END
	LACL	CMSG_BTONE
	CALL	STOR_MSG
GET_RESPOND_BTONE_END:
;---------
;---------
GET_RESPOND_CTONE:			;for record/play/line/voice_prompt mode 
	CALL	CTONE_CHK
	BS	ACZ,GET_RESPOND_CTONE_END
	LACL	CMSG_CTONE
	CALL	STOR_MSG
GET_RESPOND_CTONE_END:
;---------	
;---------	
GET_RESPOND_DTMF:			;for record/play/line/voice_prompt mode 
	CALL	DTMF_CHK
	BS	ACZ,GET_RESPOND_DTMF_END
	SBHK	1
	BS	ACZ,GET_RESPOND_DTMFSTART
	SBHK	1
	BS	ACZ,GET_RESPOND_EDTMF
	BS	B1,GET_RESPOND_DTMF_END
GET_RESPOND_DTMFSTART:
;---返回 1
	LACL	CREV_DTMFS
	CALL	STOR_MSG
	BS	B1,GET_RESPOND_DTMF_END
GET_RESPOND_EDTMF:
;---返回 2
	LACL	CREV_DTMF
	CALL	STOR_MSG
GET_RESPOND_DTMF_END:
;---------
;---------------------------------------
GET_RESPOND_PHO:
;---------------------------------------
GET_RESPOND_END:
	RET
;-------------------------------------------------------------------------------
;       Function : BCVOX_INIT
;	input : no
;	output: no
;	variable : no
;-------------------------------------------------------------------------------
BCVOX_INIT:
	LACL	CTMR_CTONE
	SAH	TMR_VOX
	SAH	TMR_CTONE
	
	LACK	0
	SAH	BUF1
	SAH	BUF2
	SAH	BUF3
	SAH	TMR_BTONE
	SAH	BTONE_BUF
	
	RET
;-------------------------------------------------------------------------------
.END
