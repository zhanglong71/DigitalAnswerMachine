.LIST
;-------------------------------------------------------------------------
;	Function : MOVEIIC_DAT	
;	���Խ��ջ������е�����ת�Ƶ�(ADDR_D,OFFSET_D)
;	INPUT : COUNT = length of data
;		(ADDR_D,OFFSET_D)
;	output: no
;-------------------------------------------------------------------------
MOVEIIC_DAT:
	LAC	COUNT
	SBHK	1
	SAH	COUNT
	BS	SGN,MOVEIIC_DAT_END
	
	CALL	GETR_DAT
	CALL	STORBYTE_DAT
	BS	B1,MOVEIIC_DAT
MOVEIIC_DAT_END:
	RET

;-------------------------------------------------------------------------------
.END
