.LIST
;-------�������������----------------------------------------------------------
Main:
	CALL	INITDSP
;-------
	LACL	1000
	CALL	SET_TIMER

;--------standby----------------------------------------------------------------
STAND_BY:
	CALL	INT_BIOS		;DAM_BIOS
	;CALL	SYS_MONITOR		;ϵͳ�¼����
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
