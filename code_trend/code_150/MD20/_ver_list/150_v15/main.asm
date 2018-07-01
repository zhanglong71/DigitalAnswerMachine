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
        CALL	INT_BIOS		;DAM_BIOS���ж�
	CALL	SYS_MONITOR		;ϵͳ�¼����
	CALL	GET_MSG			;GET MESSAGE
	BS	ACZ,STAND_BY
	SAH	MSG
	
	CALL	SYS_MSG
	BS	ACZ,STAND_BY		;ϵͳ��Ϣ

	CALL	GET_FUNC		;Ӧ�ö���
	CALA
	
        BS	B1,STAND_BY
;-------------------------------------------------------------------------------
	
.END

