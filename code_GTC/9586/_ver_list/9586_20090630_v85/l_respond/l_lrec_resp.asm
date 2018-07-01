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
	;BIT	EVENT,4
	;BS	TB,GET_RESPOND_LIN	;LINE
	;BIT	EVENT,3
	;BS	TB,GET_RESPOND_PHO	;speakerphone
	CALL	GET_VP
	BZ	ACZ,INT_BIOS_START

	RET
GET_RESPOND_PLY:		;play(voice prompt) mode
	BIT	RESP,6
	BZ	TB,GET_RESPOND_END

	LACL	CSEG_END
	CALL	STOR_MSG		;产生结束消息
	BS	B1,GET_RESPOND_END
GET_RESPOND_REC:		;record mode
	BIT	RESP,7
	BZ	TB,GET_RESPOND_END
	
	LACL	CREC_FULL		;产生memfull消息
	CALL	STOR_MSG
	;BS	B1,GET_RESPOND_END
GET_RESPOND_LIN:
GET_RESPOND_PHO:
GET_RESPOND_END:
	RET
;-------------------------------------------------------------------------------
.END
