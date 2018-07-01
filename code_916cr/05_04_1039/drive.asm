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
;	Function : BEEP
;	
;	Generate a "BEEP"	---Ã· æ”√(100mSec Duration @Frequency=1KHz)
;-------------------------------------------------------------------------------	
BEEP:
	CALL	SILENCE40MS_VP
	CALL	BEEP_RAW		;B
	
	RET
;-------------------------------------------------------------------------------
;	Function : BBEEP
;	
;	Generate two "BEEP"	;BB
;-------------------------------------------------------------------------------	
BBEEP:
	CALL	BEEP
	CALL	BEEP
	
	RET
;-------------------------------------------------------------------------------
;       Function : GET_LANGUAGE
;	Input  : no
;	Output : ACCH = ANN_FG(9,8) --- (00/01/10/11 = English/French/Spanish/Reserved)
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
;---	
	LIPK	6
	OUTK	0X01,WDTCTL
;---
	RET
;-------------------------------------------------------------------------------
.END
