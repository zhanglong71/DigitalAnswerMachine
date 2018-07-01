.LIST
;-------------------------------------------------------------------------
;	Function : SEND_TEL	
;	将数据从(ADDR_S,OFFSET_S)送到发送缓冲区中
;	INPUT : COUNT = length of data
;		(ADDR_S,OFFSET_S)
;	output: no
;-------------------------------------------------------------------------
SEND_TEL:
	LAC	COUNT
	SBHK	1
	SAH	COUNT
	BS	SGN,SEND_TEL_END
	
	CALL	GETBYTE_DAT
	CALL	SEND_DAT
	BS	B1,SEND_TEL
SEND_TEL_END:
	RET
;-------------------------------------------------------------------------------
.END
