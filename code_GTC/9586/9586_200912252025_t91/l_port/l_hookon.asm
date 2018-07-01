.LIST
;-------------------------------------------------------------------------------
HOOK_ON:		;Reset (GPAD.CbHOOK)&(EVENT.10)(¹Ò»ú×´Ì¬)
	LIPK	8

	IN	SYSTMP0,GPAC	;Set (GPAD.CbHOOK) as output port
	LAC	SYSTMP0
	ORL	1<<CbHOOK
	SAH	SYSTMP0
	OUT	SYSTMP0,GPAC
	ADHK	0

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
