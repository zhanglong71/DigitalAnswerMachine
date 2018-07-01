.LIST
;-------------------------------------------------------------------------------
INT_KEYMUTE:	
	BIT	EVENT,3
	BZ	TB,INT_KEYMUTE_END	;SPKPHONE(ÃâÌá×´Ì¬)Âð?
		
	LIPK	8
	IN	INT_TTMP1,GPBD
	BIT	INT_TTMP1,12
	BZ	TB,INT_KEYMUTE_LOW

	BIT	ANN_FG,11
	BS	TB,INT_KEYMUTE_END
;---LOW -> HIGH	
	LACL	CMSG_UNMUTE
	CALL	INT_STOR_MSG
	
	LAC	ANN_FG
	ORL	(1<<11)
	SAH	ANN_FG

	BS	B1,INT_KEYMUTE_END
INT_KEYMUTE_LOW:
	BIT	ANN_FG,11
	BZ	TB,INT_KEYMUTE_END
;---HIGH -> LOW
	LACL	CMSG_MUTE
	CALL	INT_STOR_MSG
	
	LAC	ANN_FG
	ANDL	~(1<<11)
	SAH	ANN_FG
	;BS	B1,INT_KEYMUTE_END	
INT_KEYMUTE_END:	
	RET
;-------------------------------------------------------------------------------
.END
