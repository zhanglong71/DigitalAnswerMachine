.LIST
DAA_ANS_REC:	
	CALL	ALCPORT_L	;HW-ALC enable
;---
	LIPK    6

	;BIT	VOI_ATT,11
	;BZ	TB,DAA_LIN_REC

        OUTL    ((1<<1)|(1<<7)),SWITCH	;(SW1)&(SW7) ==> (LIN->ADC)&(DAC->SPK)
	NOP
DAA_ANS_REC_0:
;---
	OUTL	(CADCML_PGA<<4),AGC
	NOP
;---
	LAC	VOI_ATT		;
	ANDK	0X07
	ADHL	VOL_TAB
	CALL	GetOneConst
	ORL	(CLINE_DRV<<5)	;Lout gain
	SAH	CODECREG2
	OUT	CODECREG2,LOUTSPK
	ADHK	0

	CALL	SPK_L		;

	RET
;-------------------------------------------------------------------------------
.END
