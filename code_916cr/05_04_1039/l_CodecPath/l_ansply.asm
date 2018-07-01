.LIST
DAA_ANS_SPK:	
	CALL	SPK_L		;
	CALL	ALCPORT_L	;HW-ALC enable
	LIPK    6

	OUTL    ((1<<1)|(1<<3)|(1<<7)),SWITCH	;(SW1)&(SW3)&(SW7) ==> (LIN->ADC0)&(DAC1->LOUT)&(DAC0->SPK)
	OUTK	0X0,ANAPWR	;all power on
DAA_ANS_SPK_0:
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
