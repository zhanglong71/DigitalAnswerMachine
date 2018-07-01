.LIST
;-------------------------------------------------------------------------------
;-------
CIDTALK_L:
	LIPK	8

	IN	SYSTMP0,GPAD	;GPAD.CbCIDMUTE = 0
	LAC	SYSTMP0
	ANDL	~(1<<CbCIDMUTE)
	SAH	SYSTMP0
	OUT	SYSTMP0,GPAD
	ADHK	0
	
	RET
CIDTALK_H:
	LIPK	8

	IN	SYSTMP0,GPAD	;GPAD.CbCIDMUTE = 1
	LAC	SYSTMP0
	ORL	1<<CbCIDMUTE
	SAH	SYSTMP0
	OUT	SYSTMP0,GPAD
	ADHK	0

	RET
;-------------------------------------------------------------------------------
.END
