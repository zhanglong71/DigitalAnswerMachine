.LIST
;-------------------------------------------------------------------------
;	Function : DUMPIIC_DAT	
;	�����ݴ�(ADDR_D,OFFSET_D)�͵����ͻ�������
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
