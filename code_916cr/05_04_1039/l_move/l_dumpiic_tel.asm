.LIST
;-------------------------------------------------------------------------
;	Function : SEND_TEL	
;	�����ݴ�(ADDR_S,OFFSET_S)�͵����ͻ�������
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
