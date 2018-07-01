.LIST
DAA_ANS_SPK:	
	CALL	ALCPORT_L	;HW-ALC enable
	LIPK    6

	;BIT	VOI_ATT,11
	;BZ	TB,DAA_LIN_SPK

	OUTL    ((1<<1)|(1<<3)|(1<<7)),SWITCH	;(SW1)&(SW3)&(SW7) ==> (LIN->ADC0)&(DAC1->LOUT)&(DAC0->SPK)
	NOP
;DAA_ANS_SPK_0:
	OUTL	(CADCML_PGA<<4),AGC
	NOP

	;LACK	CVOL_CALLSCREEN	;SPK Vol
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
