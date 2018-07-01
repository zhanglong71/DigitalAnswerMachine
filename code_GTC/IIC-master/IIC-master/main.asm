.LIST
;-------程序从这里启动----------------------------------------------------------
Main:
	CALL	INITDSP
;-------
	LACL	1000
	CALL	SET_TIMER

;--------standby----------------------------------------------------------------
STAND_BY:
	CALL	INT_BIOS		;DAM_BIOS
	;CALL	SYS_MONITOR		;系统事件监控
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
