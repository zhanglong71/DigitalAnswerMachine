.LIST
;-------------------------------------------------------------------------------
;       RESET_WDT : initial WDT register
;	
;-------------------------------------------------------------------------------
RESET_WDT:
.if	DebugWatchDog
;---	
	LIPK	6
	;IN	SYSTMP0,WDTCTL
	;LAC	SYSTMP0			;I/O interrupt mask control = Disable
	;ORK	0X001		;Set WDTCTL.0 = 1
	;SAH	SYSTMP0
	;OUT	SYSTMP0,WDTCTL
	;ADHK	0
	OUTK	0X01,WDTCTL
.endif
;---

	RET
;-------------------------------------------------------------------------------
.END
