.LIST
;-------------------------------------------------------------------------------
;	Function : AMP_ON/AMP_OFF
;-------------------------------------------------------------------------------
AMP_ON:		;Enable amplify
	LIPK	8

	IN	SYSTMP0,GPAD
	LAC	SYSTMP0
	ORL	(1<<CbHFAMP)
	SAH	SYSTMP0
	OUT	SYSTMP0,GPAD
	ADHK	0
	
	LAC	EVENT
	ORL	(1<<13)
	SAH	EVENT
	
	RET
AMP_OFF:		;Disable amplify
	LIPK	8

	IN	SYSTMP0,GPAD
	LAC	SYSTMP0
	ANDL	~(1<<CbHFAMP)
	SAH	SYSTMP0
	OUT	SYSTMP0,GPAD
	ADHK	0
	
	LAC	EVENT
	ANDL	~(1<<13)
	SAH	EVENT
	
	RET
;-------------------------------------------------------------------------------
.END
