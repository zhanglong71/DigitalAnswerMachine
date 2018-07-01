.LIST

;-------------------------------------------------------------------------------
;	Function : DGT_HEX
;
;	Transform a BCD value to binary value
;	Input  : ACCH = the BCD value
;	Output : ACCH = the binary value
;	Variable : SYSTMP1,SYSTMP2
;-------------------------------------------------------------------------------
DGT_HEX:
	PSH	SYSTMP1
	PSH	SYSTMP2
	
	SAH	SYSTMP1		;LOW(3..0)
	SFR	4
	ANDK	0XF
	SAH	SYSTMP2		;HIGH(7..4)

	LAC	SYSTMP1
	ANDK	0X0F
	SAH	SYSTMP1
DGT_HEX_LOOP:
	LAC	SYSTMP2
	BS	ACZ,DGT_HEX_END
	
	LAC	SYSTMP1
	ADHK	10
	SAH	SYSTMP1
	
	LAC	SYSTMP2
	SBHK	1
	SAH	SYSTMP2
	BS	B1,DGT_HEX_LOOP
DGT_HEX_END:
	LAC	SYSTMP1
	
	POP	SYSTMP2
	POP	SYSTMP1
	
        RET

;-------------------------------------------------------------------------------
.END
