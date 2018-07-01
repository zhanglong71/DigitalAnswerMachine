.LIST
;-------------------------------------------------------------------------------
DAA_SPK:	;(SW7) ==> (DAC->SPK)
	LIPK    6
        OUTL    (1<<7),SWITCH

	NOP
	LAC	VOI_ATT		;
	ANDK	0X07
	ADHL	VOL_TAB
	CALL	GetOneConst
	SAH	CODECREG2
	OUT	CODECREG2,LOUTSPK
	ADHK	0
;---
	CALL	SPK_L		;

	RET
;-------------------------------------------------------------------------------
.END
