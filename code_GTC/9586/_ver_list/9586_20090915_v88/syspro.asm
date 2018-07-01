.LIST
;-------------------------------------------------------------------------------
INT_BIOS:
	BIT	EVENT,7
	BS	TB,INT_BIOS_REC		;RECORD
	BIT	EVENT,6
	BS	TB,INT_BIOS_PLAY	;PLAY
	BIT	EVENT,5
	BS	TB,INT_BIOS_END		;BEEP不作处理
	BIT	EVENT,4
	BS	TB,INT_BIOS_LINE	;LINE
	BIT	EVENT,3
	BS	TB,INT_BIOS_PHONE	;speakerphone

	RET
;-------------------
INT_BIOS_PHONE:
INT_BIOS_LINE:
INT_BIOS_REC:
INT_BIOS_PLAY:		;play(voice prompt) mode
	CALL	DAM_BIOS
INT_BIOS_END:
	
	RET

;-------------------------------------------------------------------------------
INIT_DAM_FUNC:
	CALL	DAM_STOP	;停止DAM_BIOS
	LACK	0
	SAH	VP_QUEUE	;发声队列清空
	RET
;-------------------------------------------------------------------------------
DAM_STOP:			;关闭前面操作和标志位并设成IDLE模式
	LACK	0
	SAH	TMR_BEEP	;BEEP TMR清
	LAC	EVENT
	ANDL	0XFF00
	SAH	EVENT		;标志清空
	
	LAC	CONF
	BS	ACZ,DAM_STOP_IDLE
	SFR	12
	SBHK	1
	BS      ACZ,DAM_STOP_REC	;// 0X1000
	SBHK	1
	BS      ACZ,DAM_STOP_PLAY	;// 0X2000
	SBHK	2
	BS      ACZ,DAM_STOP_BEEP	;// 0X4000
	SBHK	1
	BS      ACZ,DAM_STOP_LINE	;// 0X5000
	SBHK	6
	BS      ACZ,DAM_STOP_PLAY	;// 0XB000
	SBHK	1
	BS      ACZ,DAM_STOP_PHONE	;// 0XC000
	BS	B1,DAM_STOP_IDLE
DAM_STOP_REC:
	LAC	CONF
	ORK	0X40
	CALL	DAM_BIOSFUNC
	BS	B1,DAM_STOP_IDLE
DAM_STOP_PHONE:
	LACL    0XC080
	CALL    DAM_BIOSFUNC
	BS	B1,DAM_STOP_IDLE
DAM_STOP_LINE:
	LACL    0X5001
	CALL    DAM_BIOSFUNC
	BS	B1,DAM_STOP_IDLE
DAM_STOP_PLAY:
	LAC	CONF
	ORL     0X0200
	CALL	DAM_BIOSFUNC
	BS	B1,DAM_STOP_IDLE
DAM_STOP_BEEP:
	LACL	0X4400
	CALL	DAM_BIOSFUNC
DAM_STOP_IDLE:				;// IDLE MODE
	LACK	0
	SAH     CONF
	
	RET
;----------------------------------------------------------------------------
;	Function : REC_START
;	input : no
;	output: no
;----------------------------------------------------------------------------
REC_START:
	LAC	EVENT		;SET flag(bit7)
	ANDL	0XFF00
	ORL	1<<7
	SAH	EVENT

	LACL	0X1000
	SAH	CONF
	
	RET
;----------------------------------------------------------------------------
;	Function : LINE_START
;	input : no
;	output: no
;----------------------------------------------------------------------------
LINE_START:
	LAC	EVENT		;SET flag(bit4)
	ANDL	0XFF00
	ORK	1<<4
	SAH	EVENT
	
	LACL	0X5000
	SAH	CONF
	
	RET

;-------------------------------------------------------------------------------
;	Function : SET_TIMER
;	SET/CLEAR  TIMER/COUNTER
;-------------------------------------------------------------------------------
SET_TIMER:
	SAH	TMR
	SAH	TMR_BAK
	RET
CLR_TIMER:
	LACK	0X00
	SAH	TMR
	SAH	TMR_BAK
	RET

;-------------------------------------------------------------------------------

.END
	