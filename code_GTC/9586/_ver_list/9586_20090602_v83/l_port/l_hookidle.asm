.LIST
;-------------------------------------------------------------------------------
HOOK_IDLE:		;Set (GPAD.CbHOOK) as input port
	LIPK	8

	IN	SYSTMP0,GPAC
	LAC	SYSTMP0
	ANDL	~(1<<CbHOOK)
	SAH	SYSTMP0
	OUT	SYSTMP0,GPAC
	ADHK	0

	LAC	EVENT
	ANDL	~(1<<10)
	SAH	EVENT
	
	RET
;-------------------------------------------------------------------------------
.END
