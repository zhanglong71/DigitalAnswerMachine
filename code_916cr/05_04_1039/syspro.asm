.LIST
;-------------------------------------------------------------------------------
INT_BIOS:
	BIT	EVENT,7
	BS	TB,INT_BIOS_REC		;RECORD
	BIT	EVENT,6
	BS	TB,INT_BIOS_PLAY	;PLAY
	BIT	EVENT,5
	BS	TB,INT_BIOS_BEEP	;BEEP
	BIT	EVENT,4
	BS	TB,INT_BIOS_LINE	;LINE
	BIT	EVENT,3
	BS	TB,INT_BIOS_PHONE	;speakerphone
	CALL	GET_VP
	BZ	ACZ,INT_BIOS_START

INT_BIOS_END:

	RET
;-------------------
INT_BIOS_PHONE:
	CALL	DAM_BIOS
	BS	B1,INT_BIOS_END
INT_BIOS_LINE:	
	LACL	0X5000
	CALL	DAM_BIOSFUNC

	CALL	CID_CHK
	ORK	0
	BZ	ACZ,INT_BIOS_END
;---CS/MS/DS Detect
;???????????????????????????????????????????????????????????????????????????????
.if	0
INT_BIOS_LINE_TTT:
	DINT
	bs	b1,INT_BIOS_LINE_TTT	
.endif
;???????????????????????????????????????????????????????????????????????????????
		
	LACL	CRDY_CID		;!!!!!!!!
	CALL	STOR_MSG
	BS	B1,INT_BIOS_END
INT_BIOS_REC:
	CALL	DAM_BIOS
	BIT	RESP,7
	BZ	TB,INT_BIOS_END
	
	LACL	CREC_FULL		;产生memfull消息
	CALL	STOR_MSG
	BS	B1,INT_BIOS_END

INT_BIOS_BEEP:
	LAC	TMR_BEEP
	BS	ACZ,INT_BIOS_PLAYSEGOVER
	BS	B1,INT_BIOS_END
INT_BIOS_PLAY:		;play(voice prompt) mode
	CALL	DAM_BIOS
	BIT	RESP,6
	BZ	TB,INT_BIOS_END
INT_BIOS_PLAYSEGOVER:
	CALL	GET_VP
	BS	ACZ,INT_BIOS_PLAY_01
	CALL	INT_BIOS_START
	BS	B1,INT_BIOS_END
INT_BIOS_PLAY_01:
	CALL	INIT_DAM_FUNC
	LACL	CVP_STOP		;通知系统播放完毕
	CALL	STOR_MSG
	
	BS	B1,INT_BIOS_END
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
	ANDL	0XFF07
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
;-------------------------------------------------------------------------------
GET_VP:
	LAC	VP_QUEUE
	ANDK	0X0F
	SAH	SYSTMP0
	LAC	VP_QUEUE
	SFR	8
	SBH	SYSTMP0
	BS	ACZ,GET_VP_END
	
	LAC	VP_QUEUE
	ADHK	1
	ANDL	0X0F0F
	SAH	VP_QUEUE
	
	ANDK	0XF
	ADHL	VP_ADDR
	SAH	SYSTMP0		;ADDRESS
	
	MAR	+0,1
	LAR	SYSTMP0,1
	LAC	+0,1
GET_VP_END:
	RET
;------------------------------------------------------------------------------
;	Function : STOR_VP
;
;		input : ACCH
;		output: no
;------------------------------------------------------------------------------
STOR_VP:
	SAH	SYSTMP0
	LAC	VP_QUEUE
	ADHL	0X100
	ANDL	0X0F0F
	SAH	VP_QUEUE
	
	SFR	8
	ADHL	VP_ADDR
	SAH	SYSTMP1		;ADDRESS
	
	MAR	+0,1
	LAR	SYSTMP1,1
	LAC	SYSTMP0
	SAH	+0,1
	RET
;---
BEEP_RAW:
	LACL	0X200C
	BS	B1,STOR_VP
SILENCE40MS_VP:
	LACK	0X005
	BS	B1,STOR_VP
;-------------------------------------------------------------------------------
INT_BIOS_START:
	SAH	SYSTMP2
	CALL	DAM_STOP
	
	LAC	SYSTMP2
	ANDL	0XFF
	SAH	SYSTMP0
	
	LAC	SYSTMP2
	SFR	8
	SAH	SYSTMP1
	
	SBHL	0XFF
	BS	ACZ,INT_BIOS_START_VOP
	LAC	SYSTMP1
	SBHL	0XFE
	BS	ACZ,INT_BIOS_START_PLAY_TOTAL
	LAC	SYSTMP1
	SBHL	0XFD
	BS	ACZ,INT_BIOS_START_PLAY_NEW
INT_BIOS_START_BEEP:
	LAC	SYSTMP0
	SFL	3
	SAH	TMR_BEEP		;length of time
	LAC	SYSTMP1
	SFL	8
	BS	ACZ,INT_BIOS_START_BEEP0	;frequency = 0(发声间隙)
	SAH	BUF1			;frequency
	
	LACL	CBEEP_COMMAND		;ON
	CALL    DAM_BIOSFUNC
	
	LAC	BUF1
	CALL    DAM_BIOSFUNC
	LACK	0
	CALL    DAM_BIOSFUNC
INT_BIOS_START_BEEP0:	
	LACL	CBEEP_COMMAND		;
	SAH	CONF

INT_BIOS_START_BEEP_END:	
	LAC	EVENT		;SET flag(bit5)
	ORK	0X020
	SAH	EVENT


	RET
;---
INT_BIOS_START_PLAY_TOTAL:
	LAC	SYSTMP0
	ORL	0X2000
	SAH	CONF
	BS	B1,INT_BIOS_START_VP_FLAG
;---
INT_BIOS_START_PLAY_NEW:
	LAC	SYSTMP0
	ORL	0X2400
	SAH	CONF
	BS	B1,INT_BIOS_START_VP_FLAG
;---
INT_BIOS_START_VOP:
	LAC	SYSTMP0
	ORL	0XB000
	SAH	CONF
INT_BIOS_START_VP:
	
INT_BIOS_START_VP_FLAG:
	LAC	EVENT		;SET flag(bit6)
	ORK	0X040
	SAH	EVENT

	RET
;----------------------------------------------------------------------------
;	Function : REC_START
;	input : no
;	output: no
;----------------------------------------------------------------------------
REC_START:
	LAC	EVENT		;SET flag(bit7)
	ANDL	0XFF07
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
	ANDL	0XFF07
	ORK	1<<4
	SAH	EVENT
	
	LACL	0X5000
	SAH	CONF
	
	RET

;-------------------------------------------------------------------------------

.END
	