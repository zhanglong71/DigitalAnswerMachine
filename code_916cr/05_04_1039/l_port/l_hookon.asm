.LIST
;-------------------------------------------------------------------------------
HOOK_ON:		;Reset (GPAD.CbHOOK)&(EVENT.10)
	LIPK	8

	IN	SYSTMP0,GPAD
	LAC	SYSTMP0
	ANDL	~(1<<CbHOOK)
	SAH	SYSTMP0
	OUT	SYSTMP0,GPAD
	ADHK	0
	
	LAC	EVENT
	ANDL	~(1<<10)
	SAH	EVENT
	
	RET

;-------------------------------------------------------------------------------
.END
