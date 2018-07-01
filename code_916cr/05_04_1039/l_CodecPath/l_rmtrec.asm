.LIST
;-------------------------------------------------------------------------------
DAA_LIN_REC:	;(SW1) ==> (LIN->ADC)
	CALL	ALCPORT_L	;HW-ALC enable
	
	LIPK    6
        OUTL    (1<<1),SWITCH
	;OUTK	0X0,ANAPWR	;all power on
	OUTL	((CLINE_DRV<<5)|(0x17<<10)),LOUTSPK
	OUTL	(CAD0_GAIN<<4),AGC
	
	RET

;-------------------------------------------------------------------------------
.END
