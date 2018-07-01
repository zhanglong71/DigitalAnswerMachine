.LIST
DAA_ANS_REC:	
	;CALL	ALCPORT_L	;HW-ALC enable
;---
	LIPK    6

	;BIT	VOI_ATT,11
	;BZ	TB,DAA_LIN_REC

        OUTL    ((1<<1)|(1<<7)),SWITCH	;(SW1)&(SW7) ==> (LIN->ADC)&(DAC->SPK)
	OUTK	0X0,ANAPWR	;all power on
DAA_ANS_REC_0:
;---
	OUTL	(CAD0_GAIN<<4),AGC

	LAC	VOI_ATT		;
	ANDK	0X07
	ADHL	VOL_TAB
	CALL	GetOneConst
	ORL	(CLINE_DRV<<5)	;Lout gain
	SAH	SYSTMP0
	OUT	SYSTMP0,LOUTSPK
	ADHK	0

	;CALL	SPK_L		;

	RET
;-------------------------------------------------------------------------------
.END
