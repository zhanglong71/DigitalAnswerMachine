.LIST
;-------------------------------------------------------------------------------
;
;set vol
;
;input: ACCH = vol
;output: no
;
;-------------------------------------------------------------------------------
SET_VOL:
	ANDK	0X07
	SAH	SYSTMP0
	
	LAC	CODECREG2
	ANDL	0XFFE0
	SAH	CODECREG2
	
	;LAC	VOI_ATT
	LAC	SYSTMP0
	ADHL	VOL_TAB
	CALL    GetOneConst
        OR	CODECREG2
        SAH	CODECREG2
	
	LIPK    6
	OUT	CODECREG2,LOUTSPK
	ADHK	0

	RET
;-------------------------------------------------------------------------------
.END
