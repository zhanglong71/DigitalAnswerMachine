.LIST
;-------------------------------------------------------------------------
;	Function : GETBYTE_DAT	
;	从以ADDR_S为起始地址以OFFSET_S为offset的队列取数据(一个字节),然后OFFSET_S增1
;	INPUT : OFFSET_S = the offset you will get data from
;		ADDR_S = the BASE you will get data from
;	output: ACCH = the data you got
;
;!!!NOTE: Only OFFSET_S changed,no another temporary changed
;
;-------------------------------------------------------------------------
GETBYTE_DAT:
	DINT	;?????????????????????????????????????
	PSH	SYSTMP1
GETBYTEDAT_GET:
	LAC	OFFSET_S
	SFR	1
	ADH	ADDR_S
	SAH	SYSTMP1		;GET ADDR(row)
	
	LAC	OFFSET_S
	ADHK	1
	SAH	OFFSET_S	;!!!Update for next Byte(offset_s对应下一个地址，所以下面的判断要注意)
	
	MAR	+0,1
	LAR	SYSTMP1,1
	
	LAC	OFFSET_S
	ANDK	0X01			;GET ADDR(col)
	BS	ACZ,GETBYTEDAT_GET2	;!!!OFFSET_S	;Updated for next Byte

	LAC	+0,1			;奇地址
	ANDL	0X0FF
	BS	B1,GETBYTEDAT_END
GETBYTEDAT_GET2:			;偶地址
	LAC	+0,1
	SFR	8
	ANDL	0X0FF
GETBYTEDAT_END:

	POP	SYSTMP1	
	EINT	;????????????????????????????????
	RET
;-------------------------------------------------------------------------------
.END
