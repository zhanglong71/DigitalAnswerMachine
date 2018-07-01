.LIST
;-------------------------------------------------------------------------
;	Function : DUMPIIC_DAT	
;	将数据从(ADDR_D,OFFSET_D)送到发送缓冲区中
;	INPUT : COUNT = length of data
;		(ADDR_S,OFFSET_S)
;	output: no
;-------------------------------------------------------------------------
DUMPIIC_DAT:
	LAC	COUNT
	SBHK	1
	SAH	COUNT
	BS	SGN,DUMPIIC_DAT_END
	
	CALL	GETBYTE_DAT
	CALL	SEND_DAT
	BS	B1,DUMPIIC_DAT
DUMPIIC_DAT_END:
	RET

;-------------------------------------------------------------------------------
.END
