.LIST
;-------------------------------------------------------------------------------
;	
;-------------------------------------------------------------------------------
MCRAM	.MACRO	VAR1,VAR2

	LACK	VAR2
	CALL	CLR_BIT
	AND	VAR1
	SAH	VAR1

	.ENDM
;-------------------------------------------------------------------------------
MSRAM	.MACRO	VAR1,VAR2

	LACK	VAR2
	CALL	SET_BIT
	OR	VAR1
	SAH	VAR1
	
	.ENDM
;-------------------------------------------------------------------------------
MCIO	.MACRO	IOREG,VAR2
	
	IN	SYSTMP1,IOREG
	
	LACK	VAR2
	CALL	CLR_BIT
	AND	SYSTMP1
	SAH	SYSTMP1
	
	OUT	SYSTMP1,IOREG
	ADHK	0

	.ENDM
;-------------------------------------------------------------------------------
MSIO	.MACRO	IOREG,VAR2

	IN	SYSTMP1,IOREG
	
	LACK	VAR2
	CALL	SET_BIT
	OR	SYSTMP1
	SAH	SYSTMP1
	
	OUT	SYSTMP1,IOREG
	ADHK	0
	
	.ENDM
;-------------------------------------------------------------------------------
.END
