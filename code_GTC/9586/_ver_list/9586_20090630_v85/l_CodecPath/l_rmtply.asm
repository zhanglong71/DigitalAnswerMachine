.LIST
;-------------------------------------------------------------------------------
DAA_LIN_SPK:	;(SW1)&(SW3) ==> (LIN->ADC)&(DAC->LOUT)
	CALL	ALCPORT_L	;HW-ALC enable
	LIPK    6
	OUTL	(CADCML_PGA<<4),AGC
        OUTL    ((1<<1)|(1<<3)),SWITCH
        NOP
	OUTL	((CLINE_DRV<<5)|(0x17<<10)),LOUTSPK

	NOP

	RET
;-------------------------------------------------------------------------------
.END
