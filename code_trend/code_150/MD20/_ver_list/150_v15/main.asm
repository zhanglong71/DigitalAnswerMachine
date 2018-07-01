.LIST
;-------------------------------------------------------------------------------
Main:
;---
;-------
	LACL	FlashLoc_H_f_init
	ADLL	FlashLoc_L_f_init
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_init
	ADLL	CodeSize_f_init
	CALL	LoadHostCode
;-------
	CALL	INITIAL
	CALL	INITMCU
;---
;----------------------- STAND-BY ROUTINES -------------------------------------
STAND_BY:
        CALL	INT_BIOS		;DAM_BIOS软中断
	CALL	SYS_MONITOR		;系统事件监控
	CALL	GET_MSG			;GET MESSAGE
	BS	ACZ,STAND_BY
	SAH	MSG
	
	CALL	SYS_MSG
	BS	ACZ,STAND_BY		;系统消息

	CALL	GET_FUNC		;应用定向
	CALA
	
        BS	B1,STAND_BY
;-------------------------------------------------------------------------------
	
.END

