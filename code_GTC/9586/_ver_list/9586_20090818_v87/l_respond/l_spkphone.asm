.LIST
;-------------------------------------------------------------------------------
;	Function : GET_RESPOND	
;	input : ACCH(0..F)
;	output: ACCH
;-------------------------------------------------------------------------------
GET_RESPOND:
	;BIT	EVENT,7
	;BS	TB,GET_RESPOND_REC	;RECORD
	;BIT	EVENT,6
	;BS	TB,GET_RESPOND_PLY	;PLAY
	BIT	EVENT,5
	BS	TB,GET_RESPOND_END	;BEEP不作处理
	;BIT	EVENT,4
	;BS	TB,GET_RESPOND_LIN	;LINE
	BIT	EVENT,3
	BS	TB,GET_RESPOND_PHO	;speakerphone

	RET
GET_RESPOND_PLY:		;play(voice prompt) mode
	
GET_RESPOND_PHO:
GET_RESPOND_END:
	RET

;-------------------------------------------------------------------------------
.END
