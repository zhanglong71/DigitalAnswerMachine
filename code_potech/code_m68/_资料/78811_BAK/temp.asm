/*************************************************
CallerPackage:
0~3	timer
4	number info
5~36	32 bytes ASCII number
37	name info
38~53	16 bytes ASCII name
54	music id
55	RPT counter
56	caller flag
; ------------------
acc	display flag
	.7	=0/1 disble/enable display timer
	.6	=0/1 left/right 16bytes display
	.5	=0/1 disble/enable display name
*************************************************/
BLOCK_CallerPackage	==	1
ADDR_CallerPackage	==	8

DisplayCallerPackage:
	MOV	r_exa,A

DisplayCallerPackage_timer:
	JPNB	r_exa,7,DisplayCallerPackage_number
	MOV	A,@(STYLE_LEFT)
	LCALL	VgaNum1
	CLR	r_cnt
DisplayCallerPackage_timer_loop:
	BLOCK	BLOCK_CallerPackage
	ADDA	r_cnt,@(ADDR_CallerPackage+0)
	MOV	_RC,A
	MOV	ax,_RD
	PAGE	#(LibMathHexToBcd)
	CALL	LibMathHexToBcd
	MOV	r_ax,A
	SWAPA	r_ax
	AND	A,@(0x0f)
	ADD	A,@(48)
	CALL	VgaNum1
	ANDA	r_ax,@(0x0f)
	ADD	A,@(48)
	CALL	VgaNum1
	PAGE	#($)
	INC	r_cnt
	SUBA	r_cnt,@(4)
	JPNC	DisplayCallerPackage_timer_loop
	PAGE	#(VGA)
	MOV	A,@(0)
	CALL	VgaNum1
	CALL	VgaDrawNum1

DisplayCallerPackage_number:
	PAGE	#(VGA)
	CALL	VgaBlankNum2
	PAGE	#($)
	
	BLOCK	BLOCK_CallerPackage
	MOV	_RC,@(ADDR_CallerPackage+4)
	MOV	A,_RD
	JPZ	DisplayCallerPackage_wrong	; 0
	MOV	r_bx,A
	SUB	A,@(32)
	JPNC	DisplayCallerPackage_invalid
	MOV	A,r_bx
	SUB	A,@(16)
	JPC	DisplayCallerPackage_number_left
	JPB	r_exa,6,DisplayCallerPackage_number_right
DisplayCallerPackage_number_left:
	MOV	A,@(STYLE_RIGHT)
	LCALL	VgaNum2
	MOV	A,@(ADDR_CallerPackage+5)
	JMP	DisplayCallerPackage_number_1
DisplayCallerPackage_number_right:
	MOV	A,@(STYLE_LEFT)
	LCALL	VgaNum2
	SUB	r_bx,@(16)
	MOV	A,@(ADDR_CallerPackage+5+16)
DisplayCallerPackage_number_1:
	MOV	r_exb,A
	CLR	r_cnt
DisplayCallerPackage_number_loop:
	BLOCK	BLOCK_CallerPackage
	ADDA	r_cnt,r_exb
	MOV	_RC,A
	MOV	A,_RD
	JPZ	DisplayCallerPackage_number_end
	LCALL	VgaNum2
	INC	r_cnt
	SUBA	r_cnt,r_bx
	JPC	DisplayCallerPackage_number_end
	SUBA	r_cnt,@(16)
	JPNC	DisplayCallerPackage_number_loop
DisplayCallerPackage_number_end:
	PAGE	#(VGA)
	MOV	A,@(0)
	CALL	VgaNum2
	CALL	VgaDrawNum2
	PAGE	#($)

DisplayCallerPackage_name:
	JPNB	r_exa,5,DisplayCallerPackage_ret
	BLOCK	BLOCK_CallerPackage
	MOV	_RC,@(ADDR_CallerPackage+37)
	MOV	A,_RD
	JPZ	DisplayCallerPackage_ret
	MOV	r_bx,A
	SUB	A,@(16)
	JPNC	DisplayCallerPackage_invalid
	PAGE	#(VGA)
	CALL	VgaBlankChar
	MOV	A,@(STYLE_LEFT)
	CALL	VgaChar
	PAGE	#($)
	CLR	r_cnt
DisplayCallerPackage_name_loop:
	BLOCK	BLOCK_CallerPackage
	ADDA	r_cnt,@(ADDR_CallerPackage+38)
	MOV	_RC,A
	MOV	A,_RD
	JPZ	DisplayCallerPackage_name_end
	LCALL	VgaChar
	INC	r_cnt
	SUBA	r_cnt,r_bx
	JPC	DisplayCallerPackage_name_end
	SUBA	r_cnt,@(16)
	JPNC	DisplayCallerPackage_name_loop
DisplayCallerPackage_name_end:
	PAGE	#(VGA)
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)
DisplayCallerPackage_ret:
	RETL	@(0)

DisplayCallerPackage_invalid:
	JPNB	r_exa,5,DisplayCallerPackage_ret
	SUBA	r_bx,@(79)
	JPZ	DisplayCallerPackage_unavallable
	SUBA	r_bx,@(111)
	JPZ	DisplayCallerPackage_unavallable
	SUBA	r_bx,@(80)			; "P"
	JPZ	DisplayCallerPackage_private
	SUBA	r_bx,@(112)			; "p"
	JPZ	DisplayCallerPackage_private	; >32
DisplayCallerPackage_wrong:
	MOV	A,@(STR_WrongMessage)
	JMP	DisplayCallerPackage_invalid_1
DisplayCallerPackage_private:
	MOV	A,@(STR_Private)
	JMP	DisplayCallerPackage_invalid_1
DisplayCallerPackage_unavallable:
	MOV	A,@(STR_Unavallable)
DisplayCallerPackage_invalid_1:
	MOV	r_bx,A
	PAGE	#(VGA)
	CALL	VgaBlankChar
	MOV	A,@(STYLE_LEFT)
	CALL	VgaChar
	MOV	A,r_bx
	CALL	VgaString
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)
	RETL	@(0)
	
	
	


