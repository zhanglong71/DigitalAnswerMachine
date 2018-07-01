.LIST
;-------------------------------------------------------------------------------
DAA_REC:	;(SW0) ==> (MIC->ADC)
	
	CALL	SPK_H		;
	CALL	ALCPORT_L	;HW-ALC enable
	
	LIPK    6
	
	OUTL	(CLMIC_GAIN<<8)|(CLAD1_GAIN<<4),AGC
	OUTK	1,SWITCH

;		Mic_Gain  	ADCM	?!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;---
	RET
;-------------------------------------------------------------------------------
.END
