.LIST
;-------------------------------------------------------------------------------
;	Function : SPK_H/SPK_L
;-------------------------------------------------------------------------------
SPK_H:
	LIPK	8

	IN	SYSTMP1,GPAD	;GPAD.CbSPK = 1
	LAC	SYSTMP1
	ORL	1<<CbSPK
	SAH	SYSTMP1
	OUT	SYSTMP1,GPAD
	ADHK	0
	
	RET
;---------------
SPK_L:
	LIPK	8

	IN	SYSTMP1,GPAD	;GPAD.CbSPK = 0
	LAC	SYSTMP1
	ANDL	~(1<<CbSPK)
	SAH	SYSTMP1
	OUT	SYSTMP1,GPAD
	ADHK	0
	
	RET
;-------------------------------------------------------------------------------
.END
