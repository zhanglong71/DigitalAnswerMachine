.LIST
;-------------------------------------------------------------------------------
DAA_LIN_REC:	;(SW1) ==> (LIN->ADC)
	CALL	ALCPORT_L	;HW-ALC enable
	LIPK    6
        OUTL    (1<<1),SWITCH
	NOP
	OUTL	((CLINE_DRV<<5)|(0x17<<10)),LOUTSPK
	NOP
	OUTL	(CADCML_PGA<<4),AGC
	NOP	
	
	RET

;-------------------------------------------------------------------------------
.END
