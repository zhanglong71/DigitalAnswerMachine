.LIST
;-------程序从这里启动----------------------------------------------------------
Main:
;-------
	LACL	FlashLoc_H_f_initdsp
	ADLL	FlashLoc_L_f_initdsp
	CALL	SetFlashStartAddress
	nop	
	LACL	RamLoc_f_initdsp
	ADLL	CodeSize_f_initdsp
	CALL	LoadHostCode
;-------	
	CALL	INITDSP
;--------standby----------------------------------------------------------------
STAND_BY:
	CALL	INT_BIOS		;DAM_BIOS
	
	CALL	GET_FUNC		;应用定向
	CALA
	BS	B1,STAND_BY
;-------------------------------------------------------------------------------

.END
