.LIST

;-------------------------------------------------------------------------------
;       Function : SEND_MFULL
;
;       Input  : ACCH
;       Output : no
;-------------------------------------------------------------------------------
SEND_MFULL:		;Use to tell the MCU memful when recording only
	SAH	SYSTMP0
	LACK	0X26
	CALL	SEND_DAT
	LAC	SYSTMP0
	CALL	SEND_DAT
	
	RET
;-------------------------------------------------------------------------------
.END
