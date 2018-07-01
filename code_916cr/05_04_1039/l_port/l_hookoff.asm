.LIST
;-------------------------------------------------------------------------------
HOOK_OFF:		;Set (GPAD.CbHOOK)&(EVENT.10)(Õª»ú×´Ì¬)
	LIPK	8

	IN	SYSTMP0,GPAD
	LAC	SYSTMP0
	ORL	1<<CbHOOK
	SAH	SYSTMP0
	OUT	SYSTMP0,GPAD
	ADHK	0

	LAC	EVENT
	ORL	1<<10
	SAH	EVENT
	
	RET

;-------------------------------------------------------------------------------
.END
