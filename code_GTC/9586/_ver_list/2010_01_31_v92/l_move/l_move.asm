.LIST
;-------------------------------------------------------------------------
;	Function : MOVE_DAT	
;	将以ADDR_S为起始地址的数据放到以ADDR_D为起始地址的区域(多个word)
;	INPUT : ACCH = the length you will move(word)
;	output: no
;-------------------------------------------------------------------------
MOVE_DAT:		;由于地址增长方向的原因(先高地址),适合低地址处数据向高地址处移动
	SBHK	1
	SAH	SYSTMP1		;Offset=length-1

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

;-------------------------------------------------------------------------------
.END
