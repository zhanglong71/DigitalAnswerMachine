.LIST
;-------------------------------------------------------------------------------
;	Function : RAM_STOR
;	将起始地址为(ADDR_D,OFFSET_D),长度为COUNT的地方,填充数据
;	INPUT : ACCH = 要填充的数据
;		COUNT = 要填充的数据的长度byte
;		OFFSET_D = the offset
;		ADDR_D = BASE address
;	OUTPUT: no
;NOTE : move low address data first(ADDR_S+OFFSET_S/2 > ADDR_D+OFFSET_D/2)
;-------------------------------------------------------------------------------
RAM_STOR:
	SAH	SYSTMP1
RAM_STOR_LOOP:	
	LAC	COUNT
	SBHK	1
	SAH	COUNT
	BS	SGN,RAM_STOR_END

	LAC	SYSTMP1
	CALL	STORBYTE_DAT
	BS	B1,RAM_STOR_LOOP
RAM_STOR_END:
	
	RET
;-------------------------------------------------------------------------------
.END
