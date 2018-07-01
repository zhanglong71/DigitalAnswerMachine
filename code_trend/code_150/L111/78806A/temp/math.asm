ORG	0X1100
/***************************************
16����ת10����
Դ��GENE_A
�����EXT_RESULT,RESULT
***************************************/
MATH_HTD:
	CLR	RESULT
	CLR	EXT_RESULT
	MOV	MATH_CONT,@8
MATH_HTD_LOOP:
	ADDA	RESULT,@0X03
	MOV	GENE_B,A
	JPNB	GENE_B,3,MATH_HTD_LOOP_1
	MOV	RESULT,GENE_B
MATH_HTD_LOOP_1:
	ADDA	RESULT,@0X30
	MOV	GENE_B,A
	JPNB	GENE_B,7,MATH_HTD_LOOP_2
	MOV	RESULT,GENE_B
MATH_HTD_LOOP_2:
	CLRC
	RLC	GENE_A
	RLC	RESULT
	RLC	EXT_RESULT
	
	DEC	MATH_CONT
	JPNZ	MATH_HTD_LOOP
	MOV	A,RESULT
	RET

/***************************************
16���Ƴ˷�
GENE_A*GENE_B=EXT_RESULT,RESULT
***************************************/

MATH_MUL:
	CLR	RESULT
	CLR	EXT_RESULT
	MOV	MATH_CONT,@8
MATH_MUL_LOOP:
	CLRC
	RRC	RESULT
	RRC	EXT_RESULT
	RRC	GENE_B
	JPNC	MATH_MUL_LOOP_1
	ADD	RESULT,GENE_A
	JPNC	MATH_MUL_LOOP_1
	INC	EXT_RESULT
MATH_MUL_LOOP_1:
	DEC	MATH_CONT
	JPNZ	MATH_MUL_LOOP
	RET
	


MATH_ADD:
	CLRC
	ADD	RESULT,GENE_B
	JPNC	$+2
	INC	EXT_RESULT
	ADD	EXT_RESULT,GENE_A
	RET


;�޸ĵ�ǰֵ
MATH_MODULE:
	SUBA	MOD_MAX,CURRENT_VALUE
	JPNC	MATH_MODULE_OUT
	SUBA	CURRENT_VALUE,MOD_MIN
	JPNC	MATH_MODULE_OUT
	JMP	MATH_MODULE_1
MATH_MODULE_OUT:				; ����
	JPB	INCREMENT,7,$+4
	MOV	CURRENT_VALUE,MOD_MIN
	JMP	$+3
	MOV	CURRENT_VALUE,MOD_MAX
MATH_MODULE_1:
	SUBA	MOD_MAX,MOD_MIN
	ADD	A,@1
	MOV	MOD_TEMP,A			; ģ
MATH_MODULE_2:
	ANDA	INCREMENT,@0X7F
	SUB	A,MOD_TEMP
	JPC	MATH_MODULE_3
	SUB	INCREMENT,MOD_TEMP
	JMP	MATH_MODULE_2
MATH_MODULE_3:
	JPB	INCREMENT,7,MATH_MODULE_4
	SUBA	MOD_TEMP,INCREMENT
	ADD	A,CURRENT_VALUE
	JMP	MATH_MODULE_5
MATH_MODULE_4:
	CRAM	INCREMENT,7
	ADDA	CURRENT_VALUE,INCREMENT
MATH_MODULE_5:
	MOV	CURRENT_VALUE,A
	SUBA	MOD_MAX,CURRENT_VALUE
	JPC	$+3
	SUB	CURRENT_VALUE,MOD_TEMP
	RET

; �ӳ���

COPYCIDRAM	MACRO	@SOURCE_ADDR,@TARGET_ADDR,@END_ADDR
; ����CID RAM�е�����	Դ��ַ,Ŀ���ַ,������ַ
	MOV	TEMP0,@SOURCE_ADDR
	MOV	TEMP1,@TARGET_ADDR
	MOV	TEMP2,@END_ADDR
	CALL	#COPY_CIDRAM
	ENDM
COPYCIDRAM	MACRO	SOURCE_REG,TARGET_REG,END_REG
	MOV	TEMP0,SOURCE_REG
	MOV	TEMP1,TARGET_REG
	MOV	TEMP2,END_REG
	CALL	#COPY_CIDRAM
	ENDM
COPYCIDRAM	MACRO	SOURCE_REG,@TARGET_ADDR,END_REG
	MOV	TEMP0,SOURCE_REG
	MOV	TEMP1,@TARGET_ADDR
	MOV	TEMP2,END_REG
	CALL	#COPY_CIDRAM
	ENDM
COPYCIDRAM	MACRO	@SOURCE_ADDR,TARGET_REG,END_REG
	MOV	TEMP0,@SOURCE_ADDR
	MOV	TEMP1,TARGET_REG
	MOV	TEMP2,END_REG
	CALL	#COPY_CIDRAM
	ENDM

COPY_CIDRAM:
	CLR	TEMP3
COPY_CIDRAM_LOOP:
	ADDA	TEMP0,TEMP3
	MOV	_RC,A
	SUB	A,TEMP2
	JPZ	COPY_CIDRAM_RET
	MOV	TEMP4,_RD
	ADDA	TEMP1,TEMP3
	MOV	_RC,A
	SUB	A,TEMP2
	JPZ	COPY_CIDRAM_RET
	MOV	_RD,TEMP4
	INC	TEMP3
	JMP	COPY_CIDRAM_LOOP
COPY_CIDRAM_RET:
	RET

CLRCIDRAM	MACRO	@RAM_ADDR,@SIZE,@CLR_CH
; ��CID RAM�е�����	�׵�ַ,��С,���ַ�
	MOV	TEMP0,@RAM_ADDR
	MOV	TEMP1,@SIZE
	MOV	TEMP2,@CLR_CH
	CALL	#CLR_CIDRAM
	ENDM
CLRCIDRAM	MACRO	REG,@SIZE,@CLR_CH
	MOV	TEMP0,REG
	MOV	TEMP1,@SIZE
	MOV	TEMP2,@CLR_CH
	CALL	#CLR_CIDRAM
	ENDM

CLRCIDRAM	MACRO	REG,SIZE,@CLR_CH
	MOV	TEMP0,REG
	MOV	TEMP1,SIZE
	MOV	TEMP2,@CLR_CH
	CALL	#CLR_CIDRAM
	ENDM

CLR_CIDRAM:
	CLR	TEMP3
CLR_CIDRAM_LOOP:
	SUBA	TEMP1,TEMP3
	JPZ	CLR_CIDRAM_RET
	ADDA	TEMP0,TEMP3
	MOV	_RC,A
	MOV	_RD,TEMP2
	INC	TEMP3
	JMP	CLR_CIDRAM_LOOP
CLR_CIDRAM_RET:
	RET
	
CHKLEFTBLANK	MACRO	@RAM_ADDR,@SIZE,@CLR_CH
; ��黺������ߵĿ��ַ��ĸ���
	MOV	TEMP0,@RAM_ADDR
	MOV	TEMP1,@SIZE
	MOV	TEMP2,@CLR_CH
	CALL	#CHK_LEFTBLANK
	ENDM
CHK_LEFTBLANK:
	CLR	TEMP3
	CLR	TEMP4
CHK_LEFTBLANK_LOOP:
	SUBA	TEMP1,TEMP3
	JPZ	CHK_LEFTBLANK_RET
	ADDA	TEMP0,TEMP3
	MOV	_RC,A
	SUBA	_RD,TEMP2
	JPNZ	CHK_LEFTBLANK_RET
	INC	TEMP3
	INC	TEMP4
	JMP	CHK_LEFTBLANK_LOOP
CHK_LEFTBLANK_RET:
	MOV	A,TEMP4
	RET

CHKRIGHTBLANK	MACRO	@RAM_ADDR,@SIZE,@CLR_CH
; ��黺�����ұߵĿ��ַ��ĸ���
	MOV	TEMP0,@RAM_ADDR
	MOV	TEMP1,@SIZE
	MOV	TEMP2,@CLR_CH
	CALL	#CHK_RIGHTBLANK
	ENDM

CHK_RIGHTBLANK:
	CLR	TEMP4
	MOV	TEMP3,TEMP1
CHK_RIGHTBLANK_LOOP:
	DEC	TEMP3
	JPZ	CHK_RIGHTBLANK_RET
	ADDA	TEMP0,TEMP3
	MOV	_RC,A
	SUBA	_RD,TEMP2
	JPNZ	CHK_RIGHTBLANK_RET
	INC	TEMP4
	JMP	CHK_RIGHTBLANK_LOOP
CHK_RIGHTBLANK_RET:
	MOV	A,TEMP4
	RET

; �ӳ������