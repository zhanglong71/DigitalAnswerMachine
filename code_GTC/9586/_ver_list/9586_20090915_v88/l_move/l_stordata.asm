.LIST
;-------------------------------------------------------------------------
;	Function : STORBYTE_DAT	
;	将数据存在以ADDR_D为起始地址以COUNT为offset的空间(一个字节)
;	INPUT : ACCH = the data you will stor
;		COUNT = the offset you will stor data
;		ADDR_D = the BASE you will stor data
;	output: ACCH = no
;-------------------------------------------------------------------------
STORBYTE_DAT:
	DINT
	PSH	SYSTMP1
	PSH	SYSTMP2
	
	ANDL	0XFF
	SAH	SYSTMP2		;stor DAT
STORBYTEDAT_STOR:
	LAC	COUNT
	SFR	1
	ADH	ADDR_D
	SAH	SYSTMP1		;GET ADDR(row)
	
	MAR	+0,1
	LAR	SYSTMP1,1

	LAC	COUNT
	ANDK	0X01			;GET ADDR(col)
	BS	ACZ,STORBYTEDAT_STOR2
	LAC	+0,1		;奇地址
	ANDL	0XFF
	SAH	+0,1
	
	LAC	SYSTMP2
	SFL	8
	ANDL	0XFF00
	OR	+0,1
	SAH	+0,1
	BS	B1,STORBYTEDAT_END	
STORBYTEDAT_STOR2:		;偶地址
	LAC	+0,1
	ANDL	0XFF00
	OR	SYSTMP2
	SAH	+0,1
STORBYTEDAT_END:
	POP	SYSTMP2
	POP	SYSTMP1	
	EINT
	RET
;-------------------------------------------------------------------------------
.END
