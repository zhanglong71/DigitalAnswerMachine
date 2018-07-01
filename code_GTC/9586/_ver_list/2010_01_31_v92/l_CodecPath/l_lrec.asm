.LIST
;-------------------------------------------------------------------------------
DAA_REC:	;(SW0) ==> (MIC->ADC)
	
	CALL	SPK_H		;
	CALL	ALCPORT_L	;HW-ALC enable
	
	LIPK    6
	OUTK	1,SWITCH

	NOP
	OUTL	(CLMIC_GAIN<<8)|(CLAD1_GAIN<<4),AGC
;		Mic_Gain  	ADCM	?!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;---
	RET
;-------------------------------------------------------------------------------
.END
