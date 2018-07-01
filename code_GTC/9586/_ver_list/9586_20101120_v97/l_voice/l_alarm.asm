.LIST
;---------------
;	input : no
;	output: no
;---------------
VP_SmokeAlarm:
	
	LACL	0XFF00|120
	CALL	STOR_VP
	RET

;---------------
;	input : no
;	output: no
;---------------
VP_SwitchAlarm:		;12 times

	LACL	0XFF00|61
	CALL	STOR_VP
	LACL	0XFF00|61
	CALL	STOR_VP
	LACL	0XFF00|61
	CALL	STOR_VP
	LACL	0XFF00|61
	CALL	STOR_VP
	
	LACL	0XFF00|61
	CALL	STOR_VP
	LACL	0XFF00|61
	CALL	STOR_VP
	LACL	0XFF00|61
	CALL	STOR_VP
	LACL	0XFF00|61
	CALL	STOR_VP
	
	LACL	0XFF00|61
	CALL	STOR_VP
	LACL	0XFF00|61
	CALL	STOR_VP
	LACL	0XFF00|61
	CALL	STOR_VP
	LACL	0XFF00|61
	CALL	STOR_VP
	
	RET
	
;---------------
;	input : no
;	output: no
;---------------
VP_DoorBell:

	LACL	0XFF00|119
	CALL	STOR_VP
	RET
;-------------------------------------------------------------------------------

.END
	