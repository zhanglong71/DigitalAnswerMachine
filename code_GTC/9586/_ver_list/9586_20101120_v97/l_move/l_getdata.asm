.LIST
;-------------------------------------------------------------------------
;	Function : GETBYTE_DAT	
;	从以ADDR_S为起始地址以COUNT为offset的队列取数据(一个字节)
;	INPUT : COUNT = the offset you will get data from
;		ADDR_S = the BASE you will get data from
;	output: ACCH = the data you got
;	variable:SYSTMP1
;-------------------------------------------------------------------------
GETBYTE_DAT:
	DINT
	PSH	SYSTMP1
GETBYTEDAT_GET:
	LAC	COUNT
	SFR	1
	ADH	ADDR_S
	SAH	SYSTMP1		;GET ADDR(row)
	
	MAR	+0,1
	LAR	SYSTMP1,1
	
	LAC	COUNT
	ANDK	0X01			;GET ADDR(col)
	BS	ACZ,GETBYTEDAT_GET2
	LAC	+0,1			;奇地址
	SFR	8
	ANDL	0X0FF
	BS	B1,GETBYTEDAT_END
GETBYTEDAT_GET2:			;偶地址
	LAC	+0,1
	ANDL	0X0FF
GETBYTEDAT_END:
	POP	SYSTMP1	
	EINT
	RET
;-------------------------------------------------------------------------------
.END
