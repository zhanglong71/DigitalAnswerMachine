.LIST

;-------------------------------------------------------------------------------
;	Function : GETBYTE_DAT	
;	从以ADDR_S为起始地址以COUNT为offset的队列取数据(一个字节)
;	INPUT : OFFSET_S = the offset you will get data from
;		ADDR_S = the BASE you will get data from
;	output: ACCH = the data you got
;	variable:No(SYSTMP1)
;-------------------------------------------------------------------------------
GETBYTE_DAT:
	DINT
	PSH	SYSTMP1
GETBYTEDAT_GET:
	LAC	OFFSET_S
	SFR	1
	ADH	ADDR_S
	SAH	SYSTMP1		;GET ADDR(row)
	
	MAR	+0,1
	LAR	SYSTMP1,1
	
	LAC	OFFSET_S
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
;	Function : STORBYTE_DAT	
;	将数据存在以ADDR_D为起始地址以COUNT为offset的空间(一个字节)
;	INPUT : ACCH = the data you will stor
;		OFFSET_D = the offset you will stor data
;		ADDR_D = the BASE you will stor data
;	output: ACCH = no
;	variable:No(SYSTMP1,SYSTMP2)
;-------------------------------------------------------------------------------
STORBYTE_DAT:
	DINT
	PSH	SYSTMP1
	PSH	SYSTMP2
	
	ANDL	0XFF
	SAH	SYSTMP2		;stor DAT
STORBYTEDAT_STOR:
	LAC	OFFSET_D
	SFR	1
	ADH	ADDR_D
	SAH	SYSTMP1		;GET ADDR(row)
	
	MAR	+0,1
	LAR	SYSTMP1,1

	LAC	OFFSET_D
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
;	Function : MOVE_DAT	
;	将以ADDR_S为起始地址的数据放到以ADDR_D为起始地址的区域(多个word)
;	INPUT : ACCH = the length you will move(word)
;	output: no
;-------------------------------------------------------------------------------
MOVE_DAT:		;由于地址增长方向的原因(先高地址),适合低地址处数据向高地址处移动
	SBHK	1
	SAH	SYSTMP1		;length

	LAC	ADDR_S
	ADH	SYSTMP1
	SAH	ADDR_S
	
	LAC	ADDR_D
	ADH	SYSTMP1
	SAH	ADDR_D

	LAR	ADDR_S,1
	LAR	ADDR_D,2
	MAR	+0,1
MOVE_DAT_LOOP:
	LAC	SYSTMP1
	BS	SGN,MOVE_DAT_END

	LAC	-,2
	SAH	-,1

	LAC	SYSTMP1
	SBHK	1
	SAH	SYSTMP1
	BS	B1,MOVE_DAT_LOOP
MOVE_DAT_END:	
	RET
;############################################################################
;       Function : SEND_TEL
;将指定地址,指定长度的数据装入发送缓冲器
;
;	input  : ADDR_S = 数据的所在地址的基地址
;		 OFFSET_S = 数据的所在地址的偏移
;		 COUNT = length(Bytes)
;	OUTPUT : no
;############################################################################
SEND_TEL:

	CALL	GETBYTE_DAT
	nop
	nop
	nop
	CALL	SEND_DAT
	
	LAC	OFFSET_S
	ADHK	1
	SAH	OFFSET_S

	LAC	COUNT
	SBHK	1
	SAH	COUNT
	BS	SGN,SEND_TEL_END
	BZ	ACZ,SEND_TEL
SEND_TEL_END:	
	RET	
	
;-------------------------------------------------------------------------------
.END
