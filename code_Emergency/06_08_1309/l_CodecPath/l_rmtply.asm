.LIST
;-------------------------------------------------------------------------------
DAA_LIN_SPK:	;(SW1)&(SW3) ==> (LIN->ADC)&(DAC->LOUT)
	CALL	ALCPORT_L	;HW-ALC enable
	CALL	SPK_H
	
	LIPK    6
	OUTL	(CAD0_GAIN<<4),AGC
        OUTL    ((1<<1)|(1<<3)),SWITCH
	OUTL	((CLINE_DRV<<5)|(0x17<<10)),LOUTSPK

	RET
;-------------------------------------------------------------------------------
.END
