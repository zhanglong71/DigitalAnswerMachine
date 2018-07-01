.LIST
;-------------------------------------------------------------------------------
;	Function : LOAD_LOCF_VP
;-------------------------------------------------------------------------------
LOAD_LOCF_VP:
;-------
	LACL	FlashLoc_H_f_lply
	ADLL	FlashLoc_L_f_lply
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_lply
	ADLL	CodeSize_f_lply
	CALL	LoadHostCode
;-------
	RET
;-------------------------------------------------------------------------------
;	Function : LOAD_LOCF_VR
;-------------------------------------------------------------------------------
LOAD_LOCF_VR:
;-------
	LACL	FlashLoc_H_f_lrec
	ADLL	FlashLoc_L_f_lrec
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_lrec
	ADLL	CodeSize_f_lrec
	CALL	LoadHostCode
;-------
	RET

;-------------------------------------------------------------------------------
;       Function : GET_LANGUAGE
;	Input  : no
;	Output : ACCH = ANN_FG(9,8) --- (00/01/10/11 = English/Spanish/French/Reserved)
;-------------------------------------------------------------------------------
GET_LANGUAGE:
	LAC	VOI_ATT
	SFR	8
	ANDK	0X03
	
	RET

;-------------------------------------------------------------------------------
;       RESET_WDT : initial WDT register
;	
;-------------------------------------------------------------------------------
RESET_WDT:
.if	EnableWatchDog
;---	
	LIPK	6
	OUTK	0X01,WDTCTL
;---
.endif
	RET
;-------------------------------------------------------------------------------
.END
