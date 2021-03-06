/***************************************
����ASCII
***************************************/
ASC_REG	==	INT_TEMP0

ASCII_NUM:
	DISI
	MOV	ASC_REG,A
	SUB	A,@32
	JPZ	ASCII_NUM_SPACE
	SUBA	ASC_REG,@45
	JPZ	ASCII_NUM_LINE
	SUBA	ASC_REG,@48
	JPNC	ASCII_NUM_ERROR
	SUBA	ASC_REG,@58
	JPNC	ASCII_NUM_NUM
	JMP	ASCII_NUM_ERROR
ASCII_NUM_SPACE:
ASCII_NUM_ERROR:
	MOV	A,@(0X10)
	JMP	ASCII_RET
ASCII_NUM_LINE:
	MOV	A,@(0X11)
	JMP	ASCII_RET
ASCII_NUM_NUM:
	SUBA	ASC_REG,@48
	JMP	ASCII_RET

ASCII_CH:
	DISI
	MOV	ASC_REG,A
	SUB	A,@32
	JPZ	ASCII_CH_SPACE
	ADD	A,@(33-32)
	JPZ	ASCII_CH_EXC
	ADD	A,@(46-33)
	JPZ	ASCII_CH_POINT
	ADD	A,@(47-46)
	JPZ	ASCII_CH_SCH1
	SUBA	ASC_REG,@48
	JPNC	ASCII_CH_ERROR
	SUBA	ASC_REG,@58
	JPNC	ASCII_CH_NUM
	JPZ	ASCII_CH_COLON
	SUBA	ASC_REG,@63
	JPZ	ASCII_CH_INTE
	SUBA	ASC_REG,@65
	JPNC	ASCII_CH_ERROR
	SUBA	ASC_REG,@91
	JPNC	ASCII_CH_CLETTER
	SUBA	ASC_REG,@92
	JPZ	ASCII_CH_SCH2
	SUBA	ASC_REG,@95
	JPZ	ASCII_CH__
	SUBA	ASC_REG,@97
	JPNC	ASCII_CH_ERROR
	SUBA	ASC_REG,@123
	JPNC	ASCII_CH_SLETTER
	JMP	ASCII_CH_ERROR			; ERROR
ASCII_CH_SPACE:
ASCII_CH_ERROR:
	MOV	A,@CH_BLANK
	JMP	ASCII_RET
ASCII_CH_EXC:
	MOV	A,@CH_EXC
	JMP	ASCII_RET
ASCII_CH_SCH1:
	MOV	A,@CH_SCH1
	JMP	ASCII_RET
ASCII_CH_POINT:
	MOV	A,@CH_POINT
	JMP	ASCII_RET
ASCII_CH_NUM:
	SUBA	ASC_REG,@48
	JMP	ASCII_RET
ASCII_CH_COLON:
	MOV	A,@CH_COLON
	JMP	ASCII_RET
ASCII_CH_INTE:
	MOV	A,@CH_INTE
	JMP	ASCII_RET
ASCII_CH_CLETTER:
	SUBA	ASC_REG,@65
	ADD	A,@CH_A
	JMP	ASCII_RET
ASCII_CH_SCH2:
	MOV	A,@CH_SCH2
	JMP	ASCII_RET
ASCII_CH__:
	MOV	A,@CH__
	JMP	ASCII_RET
ASCII_CH_SLETTER:
	SUBA	ASC_REG,@97
	ADD	A,@CH_A

ASCII_RET:
	ENI
	RET
