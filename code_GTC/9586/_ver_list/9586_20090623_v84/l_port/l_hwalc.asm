.LIST
;-------------------------------------------------------------------------------
;	Function : ALCPORT_H/ALCPORT_L
;-------------------------------------------------------------------------------
ALCPORT_H:
	LIPK	8

	IN	SYSTMP1,GPBD	;GPBD.CbALC = 1
	LAC	SYSTMP1
	ORL	1<<CbALC
	SAH	SYSTMP1
	OUT	SYSTMP1,GPBD
	ADHK	0
	
	RET
;---------------
ALCPORT_L:
	LIPK	8

	IN	SYSTMP1,GPBD	;GPBD.CbALC = 0
	LAC	SYSTMP1
	ANDL	~(1<<CbALC)
	SAH	SYSTMP1
	OUT	SYSTMP1,GPBD
	ADHK	0
	
	RET
;-------------------------------------------------------------------------------
.END
