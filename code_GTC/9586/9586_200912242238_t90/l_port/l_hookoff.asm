.LIST
;-------------------------------------------------------------------------------
HOOK_OFF:		;Set (GPAD.CbHOOK)&(EVENT.10)(ժ��״̬)
	LIPK	8

	IN	SYSTMP0,GPAC	;Set (GPAD.CbHOOK) as output port
	LAC	SYSTMP0
	ORL	1<<CbHOOK
	SAH	SYSTMP0
	OUT	SYSTMP0,GPAC
	ADHK	0
	nop
	nop
	nop
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
