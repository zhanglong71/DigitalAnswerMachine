.LIST
REMOTE_PRO:
	;LAC	MSG			;接线后按ON/OFF
	;XORL	CMSG_KEY6S
	;BS	ACZ,REMOTE_CPC_RUN
	
	LAC	MSG			;接线后摘机(相当于CPC)
	XORL	CMSG_CPC
	BS	ACZ,REMOTE_CPC_RUN
	
	LAC	PRO_VAR
	ANDL	0X0F
	BS	ACZ,REMOTE_PRO0		;Idle
	SBHK	1
	BS	ACZ,REMOTE_PRO1		;play new messages
	SBHK	1
	BS	ACZ,REMOTE_PRO2		;play old messages
	SBHK	1
	BS	ACZ,REMOTE_PRO3		;play voice prompt
	SBHK	1
	;BS	ACZ,REMOTE_PRO4		;reserved
	SBHK	1
	;BS	ACZ,REMOTE_PRO5		;reserved
	SBHK	1
	;BS	ACZ,REMOTE_PRO6		;reserved
	SBHK	1
	BS	ACZ,REMOTE_PRO7		;record/play OGM
	SBHK	1
	BS	ACZ,REMOTE_PRO8		;Indoor monitor
	SBHK	1
	BS	ACZ,REMOTE_PRO9
	SBHK	1
	BS	ACZ,REMOTE_PRO10	;exit
	SBHK	1
	BS	ACZ,REMOTE_PRO11
	SBHK	1
	BS	ACZ,REMOTE_PRO12
	SBHK	1
	BS	ACZ,REMOTE_PRO13
	
	RET
REMOTE_CPC_RUN:
	CALL	INIT_DAM_FUNC
	;CALL	BBEEP
	LACK	0X020
	CALL	STOR_VP

	LACK	10
	SAH	PRO_VAR

	;LACL	0XFF01
	;CALL	STOR_VP
	;CALL	DAA_LIN_SPK
	
	RET
	
	;BS	B1,REMOTE_PRO10_END
;===============================================================================
REMOTE_PRO0:
	LAC	MSG
	XORL	CMSG_INIT		;INITIAL(发两声BEEP)
	BS	ACZ,REMOTE_PRO0_INIT
;REMOTE_PRO0_1:
	LAC	MSG
	XORL	CREV_DTMF		;CREV_DTMF
	BS	ACZ,REMOTE_PRO0_REV_DTMF
;REMOTE_PRO0_2:	
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,REMOTE_PRO0_STOPVP	;VP完
;REMOTE_PRO0_3:	
	LAC	MSG
	XORL	CMSG_BTONE
	BS	ACZ,REMOTE_PRO0_TONE
;REMOTE_PRO0_4:	
	LAC	MSG
	XORL	CMSG_CTONE
	BS	ACZ,REMOTE_PRO0_TONE
;REMOTE_PRO0_5:	
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,REMOTE_PRO0_TMR
		
	RET
REMOTE_PRO0_INIT:
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK
	CALL	BBEEP
	
	RET
REMOTE_PRO0_STOPVP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_REC
	
	CALL	LINE_START
	
	LACK	0			;开始计时
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER
	
	CALL	BCVOX_INIT
	
	RET
	
REMOTE_PRO0_REV_DTMF:
	LACK	0
	SAH	PRO_VAR1
	
	CALL	BCVOX_INIT
	
	LAC	DTMF_VAL
	SBHL	0X0F0
	BS	ACZ,REMOTE_PRO0_REV_DTMF_0	;0
	SBHK	1
	BS	ACZ,REMOTE_PRO0_REV_DTMF_1	;1---play new
	SBHK	1
	BS	ACZ,REMOTE_PRO0_REV_DTMF_2	;2---play all
	SBHK	1
	BS	ACZ,REMOTE_PRO0_REV_DTMF_3	;3---erase all
	SBHK	1
	;BS	ACZ,REMOTE_PRO0_REV_DTMF_4	;4
	SBHK	1
	;BS	ACZ,REMOTE_PRO0_REV_DTMF_5	;5
	SBHK	1
	;BS	ACZ,REMOTE_PRO0_REV_DTMF_6	;6
	SBHK	1
	BS	ACZ,REMOTE_PRO0_REV_DTMF_7	;7---record/play OGM
	SBHK	1
	BS	ACZ,REMOTE_PRO0_REV_DTMF_8	;8---indoormonitor
	SBHK	1
	BS	ACZ,REMOTE_PRO0_REV_DTMF_9	;9---on/off
	SBHK	5
	BS	ACZ,REMOTE_PRO0_REV_DTMF_A	;*---remote prompt
	SBHK	1
	BS	ACZ,REMOTE_PRO0_REV_DTMF_B	;#---hang off	
	
	RET
REMOTE_PRO0_REV_DTMF_0:
	RET
REMOTE_PRO0_REV_DTMF_1:
	CALL	DAA_LIN_REC
	CALL	INIT_DAM_FUNC
	CALL	LINE_START
	
	LACK	11
	SAH	PRO_VAR
		
	RET	
REMOTE_PRO0_REV_DTMF_2:	
	CALL	DAA_LIN_REC
	CALL	INIT_DAM_FUNC
	CALL	LINE_START
	
	LACK	12
	SAH	PRO_VAR
	
	RET
REMOTE_PRO0_REV_DTMF_3:
	CALL	DAA_LIN_REC
	CALL	INIT_DAM_FUNC
	CALL	LINE_START
	
	LACK	13
	SAH	PRO_VAR

	RET
;REMOTE_PRO0_REV_DTMF_4:
	
	;RET
;REMOTE_PRO0_REV_DTMF_5:
	
	;RET
;REMOTE_PRO0_REV_DTMF_6:
	;RET
	
REMOTE_PRO0_REV_DTMF_7:
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK
	
	BIT	ANN_FG,13
	BS	TB,REMOTE_PRO0_REV_DTMF_7_FUL
	
	LACK	0X17
	SAH	PRO_VAR

	CALL	LBEEP

	RET
REMOTE_PRO0_REV_DTMF_7_FUL:	;直接退出
	CALL	BBBEEP
	
	RET
REMOTE_PRO0_REV_DTMF_8:
	CALL	INIT_DAM_FUNC
	
	LACK	0X18
	SAH	PRO_VAR
	
	;LACL	54		;act...
	;ORL	0XFF00
	;CALL	STOR_VP
	
	CALL	LBEEP		;BEEP
	CALL	DAA_LIN_SPK
	
	RET

REMOTE_PRO0_REV_DTMF_9:
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK
	CALL	BEEP		;BEEP
	
	LAC	EVENT
	XORL	0X0200
	SAH	EVENT
	
	LACK	0
	SAH	PRO_VAR
	
	RET
REMOTE_PRO0_REV_DTMF_A:
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK
	
        LACL    VP_MENU_QUEUE
        SAH	ADDR_S
	
	CALL	GET_LANGUAGE
	BS	ACZ,REMOTE_PRO0_REV_DTMF_A_CHK

        LACL    VP_GMENU_QUEUE
        SAH	ADDR_S
REMOTE_PRO0_REV_DTMF_A_CHK:
	
	LAC	ADDR_S
        RPTK    0
        TBR     MSG_T
	
	LACK	1
	SAH	MSG_ID
	
	
	LAC	ADDR_S
	ADH	MSG_ID
        RPTK    0
        TBR     SYSTMP0
        LAC     SYSTMP0
        ORL	0XFF00
        CALL	STOR_VP
        
	LACK	3
	SAH	PRO_VAR

	RET
	
REMOTE_PRO0_REV_DTMF_B:		;退出准备
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK
	CALL	BBEEP

	LACK	0X0A
	SAH	PRO_VAR
	
	;LACL	58		;release line
	;ORL	0XFF00
	;CALL	STOR_VP

	RET

	
REMOTE_PRO0_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	8
	BZ	SGN,REMOTE_PRO0_REV_DTMF_B
	
	RET	
;=======================================================================
;11111111111111111111111111111111111111111111111111111111111111111111111
REMOTE_PRO1:				;播放新message
	LAC	PRO_VAR
	SFR	4	
	BZ	ACZ,REMOTE_PROX_PAUSE
	
	LAC	MSG
	XORL	CVP_STOP		;PLAY END
	BS	ACZ,REMOTE_PRO1_PLAY_OVER
;REMOTE_PRO1_1:
	LAC	MSG
	XORL	CREV_DTMF		;CREV_DTMF
	BS	ACZ,REMOTE_PRO1_REV_DTMF
;REMOTE_PRO1_2:
	LAC	MSG
	XORL	CMSG_BTONE		;CMSG_BTONE
	BS	ACZ,REMOTE_PRO10_END
	RET
;---------------处理消息
REMOTE_PRO1_PLAY_OVER:
	CALL	GET_TOTALMSG
	SAH	MSG_T
	
	LAC	MSG_ID
	SBH	MSG_T
	BZ	SGN,REMOTE_PROX_EXIST_PLY
;REMOTE_PRO1_PLAY_OVER1:
	LAC	MSG_ID			;next message
	ADHK	1
	SAH	MSG_ID
	
	LAC	FILE_ID			;next message
	ADHK	1
	SAH	FILE_ID

	CALL	FFW_MANAGE	
	BZ	ACZ,REMOTE_PROX_EXIST_PLY	;没新的了
	
	BS	B1,REMOTE_PROX_PLAY_LOADVP
;-------	
REMOTE_PRO1_REV_DTMF:
	LAC	DTMF_VAL
	SBHL	0X0F0
	SBHK	3
	BS	ACZ,REMOTE_PROX_REV_DTMF_3	;3
	SBHK	1
	BS	ACZ,REMOTE_PRO1_REV_DTMF_4	;4
	SBHK	1
	BS	ACZ,REMOTE_PROX_REV_DTMF_5	;5
	SBHK	1
	BS	ACZ,REMOTE_PROX_REV_DTMF_6	;6
	SBHK	8
	BS	ACZ,REMOTE_PROX_REV_DTMF_STAR	;*
	SBHK	1
	BS	ACZ,REMOTE_PROX_EXIST_PLY	;#
	RET

REMOTE_PROX_REV_DTMF_3:
	CALL	INIT_DAM_FUNC
	CALL	DEL_VPMSG
	
	LAC	MSG_ID
	CALL	GET_USRDAT
	CALL	GET_TELID
	CALL	DEL_ONETEL

	CALL	BBEEP
	
	RET
REMOTE_PRO1_REV_DTMF_4:
	
	CALL	INIT_DAM_FUNC
	CALL	SETOLD_VPMSG
	
	LAC	MSG_ID
	ANDL	0X0FF
	SBHK	1
	BS	ACZ,REMOTE_PRO1_REV_DTMF_4_1 ;第一个吗?

	LAC	MSG_ID
	SBHK	1
	SBH	FILE_LEN
	SAH	MSG_ID	
	
	LAC	FILE_ID
	SBHK	1
	SAH	FILE_ID	
	
	CALL	REW_MANAGE
REMOTE_PRO1_REV_DTMF_4_1:
	LAC	MSG_ID
	CALL	GET_RVPLEN
	
	BS	B1,REMOTE_PROX_PLAY_LOADVP
	
REMOTE_PROX_REV_DTMF_5:
	CALL	INIT_DAM_FUNC
	CALL	SETOLD_VPMSG
	
	LAC	MSG_ID
	CALL	GET_RVPLEN		;将MSG_ID转化成具有相同的USER_DATA的VP的最小值
	BS	B1,REMOTE_PROX_PLAY_LOADVP
	

REMOTE_PROX_REV_DTMF_STAR:
	LAC	CONF
	ORL	0X0100
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	PRO_VAR
	ORK	0X10
	SAH	PRO_VAR
	
	LACL	1000
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1
	
	RET

REMOTE_PROX_PAUSE:
	LAC	MSG
	XORL	CREV_DTMF		;CREV_DTMF
	BS	ACZ,REMOTE_PROX_PAUSE_REV_DTMF
;REMOTE_PROX_PAUSE_1:
	LAC	MSG
	XORL	CMSG_TMR		;CMSG_TMR
	BS	ACZ,REMOTE_PROX_PAUSE_TIMER
	
	RET
REMOTE_PROX_PAUSE_REV_DTMF:
	LAC	DTMF_VAL
	SBHL	0X0F0
	SBHK	3
	BS	ACZ,REMOTE_PROX_REV_DTMF_3	;3	
	SBHK	1
	BS	ACZ,REMOTE_PRO1_REV_DTMF_4	;4
	SBHK	1
	BS	ACZ,REMOTE_PROX_REV_DTMF_5	;5
	SBHK	1
	BS	ACZ,REMOTE_PROX_REV_DTMF_6	;6
	SBHK	8
	BS	ACZ,REMOTE_PRO1_PAUSE_REV_DTMF_STAR	;*
	SBHK	1
	BS	ACZ,REMOTE_PROX_EXIST_PLY	;#
	
	RET
REMOTE_PROX_PAUSE_TIMER:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	10
	BZ	ACZ,REMOTE_PRO1_PAUSE_TIMER_1
	
	CALL	INIT_DAM_FUNC
	CALL	SETOLD_VPMSG	

	CALL	VP_ENDOF
	CALL	VP_MESSAGES

	CALL	BBEEP
	
	LACK	0
	SAH	PRO_VAR
	
REMOTE_PRO1_PAUSE_TIMER_1:		
	RET
REMOTE_PRO1_PAUSE_REV_DTMF_STAR:
	
	CRAM	CONF,8
	CALL	DAM_BIOS
	
	LAC	PRO_VAR
	ANDL	0XFF0F
	SAH	PRO_VAR
	
	RET
;=======================================================================
;22222222222222222222222222222222222222222222222222222222222222222222222
REMOTE_PRO2:
	LAC	PRO_VAR
	SFR	4	
	BZ	ACZ,REMOTE_PROX_PAUSE
	
	LAC	MSG
	XORL	CVP_STOP		;PLAY END
	BS	ACZ,REMOTE_PRO2_PLAY_OVER
;REMOTE_PRO2_1:
	LAC	MSG
	XORL	CREV_DTMF		;CREV_DTMF
	BS	ACZ,REMOTE_PRO2_REV_DTMF
;REMOTE_PRO2_2:
	LAC	MSG
	XORL	CMSG_BTONE		;CMSG_BTONE
	BS	ACZ,REMOTE_PRO10_END
	RET
;-------
REMOTE_PRO2_PLAY_OVER:
	CALL	GET_TOTALMSG
	SAH	MSG_T
	
	LAC	MSG_ID
	SBH	MSG_T
	BZ	SGN,REMOTE_PROX_EXIST_PLY
;REMOTE_PRO2_PLAY_OVER1:
	LAC	FILE_ID			;next message
	ADHK	1
	SAH	FILE_ID
	
	LAC	MSG_ID			;next message
	ADHK	1
	SAH	MSG_ID
	
REMOTE_PROX_PLAY_LOADVP:
	CALL	VP_MESSAGE
	LAC	FILE_ID			;message_ID(VP)
	CALL	ANNOUNCE_NUM
	
	CALL	MSG_WEEK
	CALL	MSG_HOUR
	CALL	MSG_MIN

	LAC	MSG_ID
	CALL	GET_VPLEN
	CALL	GET_VPMSG
		
	RET
REMOTE_PRO2_REV_DTMF:
	LAC	DTMF_VAL
	SBHL	0X0F0
	SBHK	3
	BS	ACZ,REMOTE_PROX_REV_DTMF_3	;3
	SBHK	1
	BS	ACZ,REMOTE_PRO2_REV_DTMF_4	;4
	SBHK	1
	BS	ACZ,REMOTE_PROX_REV_DTMF_5	;5
	SBHK	1
	BS	ACZ,REMOTE_PROX_REV_DTMF_6	;6
	SBHK	8
	BS	ACZ,REMOTE_PROX_REV_DTMF_STAR	;*
	SBHK	1
	BS	ACZ,REMOTE_PROX_EXIST_PLY	;#
	
	RET

REMOTE_PRO2_REV_DTMF_4:
	CALL	INIT_DAM_FUNC
	CALL	SETOLD_VPMSG
	
	LAC	MSG_ID
	ANDK	0X07F
	SBHK	1
	BS	ACZ,REMOTE_PRO2_REV_DTMF_4_1 ;第一个吗?
	LAC	MSG_ID
	SBHK	1
	SBH	FILE_LEN
	SAH	MSG_ID
	
	LAC	FILE_ID
	SBHK	1
	SAH	FILE_ID
	
	BS	B1,REMOTE_PRO2_REV_DTMF_4_2
REMOTE_PRO2_REV_DTMF_4_1:
	LACK	1
	SAH	MSG_ID
REMOTE_PRO2_REV_DTMF_4_2:
	LAC	MSG_ID
	CALL	GET_RVPLEN
	
	BS	B1,REMOTE_PROX_PLAY_LOADVP
	

REMOTE_PROX_REV_DTMF_6:
	CALL	INIT_DAM_FUNC
	CALL	SETOLD_VPMSG
		
	LACL	CVP_STOP
	CALL	STOR_MSG
	
	RET

REMOTE_PROX_EXIST_PLY:			;退出remote playing
	CALL	INIT_DAM_FUNC
	CALL	SETOLD_VPMSG
	CALL	REAL_DEL		;0x6100
	
	CALL	NEWICM_CHK
	
	CALL	VP_ENDOF		;END OF
	CALL	VP_MESSAGES		;MESSAGES
	CALL	BBEEP
	

	LACK	0
	SAH	PRO_VAR
	
	RET
;=======================================================================
;33333333333333333333333333333333333333333333333333333333333333333333333
REMOTE_PRO3:
;REMOTE_PRO3_0_0:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,REMOTE_PRO3_STOPVP	;VP完
;REMOTE_PRO3_0_1:	
	LAC	MSG
	XORL	CREV_DTMF		;CREV_DTMF
	BS	ACZ,REMOTE_PRO3_REV_DTMF

	RET
REMOTE_PRO3_REV_DTMF:
	;CALL	DAA_LIN_REC
	;CALL	INIT_DAM_FUNC
	BS	B1,REMOTE_PRO0_REV_DTMF

REMOTE_PRO3_STOPVP:
	LAC	ADDR_S
        RPTK    0
        TBR     MSG_T
	
	LAC	MSG_ID	
	ADHK	1
	SAH	MSG_ID
	
	SBHK	1
	SBH	MSG_T
	BZ	SGN,REMOTE_PRO3_OVERVP
	
	CALL	INIT_DAM_FUNC
	
	LAC	ADDR_S
	ADH	MSG_ID
        RPTK    0
        TBR     SYSTMP0
        LAC     SYSTMP0
        ORL	0XFF00
        CALL	STOR_VP
	
	RET
REMOTE_PRO3_OVERVP:
	CALL	BBEEP
	
	LACK	0
	SAH	PRO_VAR
	SAH	PRO_VAR1
	
	
	RET
;=======================================================================
;44444444444444444444444444444444444444444444444444444444444444444444444
;REMOTE_PRO4:
	;RET
;=======================================================================
;55555555555555555555555555555555555555555555555555555555555555555555555
;REMOTE_PRO5:
	;RET
;=======================================================================
;66666666666666666666666666666666666666666666666666666666666666666666666
;REMOTE_PRO6:
	;RET
;=======================================================================
;77777777777777777777777777777777777777777777777777777777777777777777777
REMOTE_PRO7:
	LAC	PRO_VAR
	SFR	4
	BS	ACZ,REMOTE_PRO7_RECORD
	SBHK	1
	BS	ACZ,REMOTE_PRO7_1	;play LBEEP
	SBHK	1
	BS	ACZ,REMOTE_PRO7_2	;play OGM
	
	RET
;-------
REMOTE_PRO7_RECORD:
	LAC	MSG
	XORL	CMSG_TMR		;TIMER
	BS	ACZ,REMOTE_PRO7_RECORD_TIMER
;REMOTE_PRO7_RECORD_1:
	LAC	MSG
	XORL	CREV_DTMF		;DTMF
	BS	ACZ,REMOTE_PRO7_RECORD_DTMF
;REMOTE_PRO7_RECORD_2:	
	LAC	MSG
	XORL	CMSG_BTONE
	BS	ACZ,REMOTE_PRO0_TONE
;REMOTE_PRO7_RECORD_3:	
	LAC	MSG
	XORL	CMSG_CTONE
	BS	ACZ,REMOTE_PRO0_TONE
;REMOTE_PRO7_RECORD_4:	
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,REMOTE_PRO0_TMR
;REMOTE_PRO7_RECORD_5:
	LAC	MSG
	XORL	CREC_FULL		;REC_FULL
	BS	ACZ,REMOTE_PRO7_RECORD_DTMF_1

	RET
REMOTE_PRO7_RECORD_TIMER:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	
	SBHK	120
	BZ	SGN,REMOTE_PRO7_RECORD_DTMF_1
	
;REMOTE_PRO7_RECORD_TIMER_END:	
	RET
;-------	
REMOTE_PRO7_RECORD_DTMF:
	LAC	DTMF_VAL
	SBHL	0X0FF
	BZ	ACZ,REMOTE_PRO7_RECORD_DTMF_END	;pressed "#"?

REMOTE_PRO7_RECORD_DTMF_1:		;处理"#","mfull"
	CALL	INIT_DAM_FUNC
	
	CALL	DAA_LIN_SPK
	
	LAC	PRO_VAR
	ANDL	0XFF0F
	ORL	0X020
	SAH	PRO_VAR
	
	CALL	OGM_STATUS
	
	LAC	MSG_ID
	ANDL	0X0FF
	ORL	0XFE00
	CALL	STOR_VP
		
	LAC	PRO_VAR
	ANDL	0XFF0F
	ORL	0X020
	SAH	PRO_VAR
REMOTE_PRO7_RECORD_DTMF_END:
	RET
;-------
REMOTE_PRO7_1:	
	LAC	MSG
	XORL	CVP_STOP		;PLAY END
	BS	ACZ,REMOTE_PRO7_PLAY_OVER
	
	RET
REMOTE_PRO7_PLAY_OVER:	
	LAC	PRO_VAR
	ANDL	0XFF0F
	SAH	PRO_VAR
	
	CALL	OGM_STATUS
;-------delete the old OGM----------------	
	LAC	MSG_ID
	CALL	MSG_DEL
	
	LAC	MSG_N
	ADHK	100
    	ORL	0X7500
    	SAH	CONF
    	CALL	DAM_BIOS

	CALL	DAA_LIN_REC
	
	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER
	
	CALL	REC_START
	
	RET
REMOTE_PRO7_2:
	LAC	MSG
	XORL	CVP_STOP		;CVP_STOP
	BS	ACZ,REMOTE_PRO7_VPSTOP
;REMOTE_PRO7_2_1:
	LAC	MSG
	XORL	CREV_DTMF		;CREV_DTMF
	BS	ACZ,REMOTE_PRO7_2_REV_DTMF
	
	RET
REMOTE_PRO7_VPSTOP:
	CALL	INIT_DAM_FUNC
	LACK	0
	SAH	PRO_VAR

	CALL	BBEEP
	
	RET
REMOTE_PRO7_2_REV_DTMF:
	LAC	DTMF_VAL
	SBHL	0X0F0
	SBHK	3
	BS	ACZ,REMOTE_PRO7_2_REV_DTMF_3	;3
	SBHK	12
	BS	ACZ,REMOTE_PRO7_VPSTOP	;#
	
	RET
REMOTE_PRO7_2_REV_DTMF_3:
	CALL	INIT_DAM_FUNC
	
	CALL	OGM_STATUS
;-------delete the OGM----------------	
	LAC	MSG_ID
	ORL	0X2080
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	CONF
	ANDL	0X007F
	ORL	0X6100
	SAH	CONF
	CALL	DAM_BIOS

	CALL	BBEEP
	
	LACK	0
	SAH	PRO_VAR
	
	RET

;=======================================================================
;88888888888888888888888888888888888888888888888888888888888888888888888
REMOTE_PRO8:
	LAC	PRO_VAR
	SFR	4
	BS	ACZ,REMOTE_PRO8_0_0
	SBHK	1
	BS	ACZ,REMOTE_PRO8_VOPLAY
	
;---------------------------------------
REMOTE_PRO8_0_0:	
	LAC	MSG
	XORL	CREV_DTMF		;CREV_DTMF
	BS	ACZ,REMOTE_PRO8_REV_DTMF
;REMOTE_PRO8_0_1:
	LAC	MSG
	XORL	CMSG_TMR		;TIMER
	BS	ACZ,REMOTE_PRO8_TIMER
;REMOTE_PRO8_0_2:
	LAC	MSG
	XORL	CMSG_BTONE		;BTONE
	BS	ACZ,REMOTE_PRO0_TONE

	
	RET
;---------------处理消息
REMOTE_PRO8_REV_DTMF:
	LAC	DTMF_VAL
	SBHL	0X0F0
	SBHK	14
	BS	ACZ,REMOTE_PRO8_REV_DTMF_STAR	;*
	SBHK	1
	BS	ACZ,REMOTE_PRO8_REV_DTMF_POUND	;#	
	
	RET
REMOTE_PRO8_REV_DTMF_STAR:
	LACK	0
	SAH	PRO_VAR1
	CALL	BCVOX_INIT
	
	RET
REMOTE_PRO8_REV_DTMF_POUND:
	CALL	INIT_DAM_FUNC
	CALL	BCVOX_INIT
	
	LACK	0
	SAH	PRO_VAR
	SAH	PRO_VAR1
	
	LACL	CMSG_INIT
	CALL	STOR_MSG

	RET
REMOTE_PRO8_TIMER:
	LACL	8000
	SAH	TMR_VOX
	SAH	TMR_CTONE	;防止其值为负值时挤暴消息队列而造成计时不准确
	
	LAC	PRO_VAR1	;计时
	ADHK	1
	SAH	PRO_VAR1
	SBHK	30
	BZ	SGN,REMOTE_PRO8_REV_DTMF_POUND	;30s计时
REMOTE_PRO8_TIMER_END:
		
	RET
;-------
REMOTE_PRO8_VOPLAY:
	LAC	MSG
	XORL	CVP_STOP			;CVP_STOP
	BS	ACZ,REMOTE_PRO8_VOPLAY_END
	
	RET	
REMOTE_PRO8_VOPLAY_END:
	CALL	INIT_DAM_FUNC
	CALL	DAA_ROM_MOR
	CALL	LINE_START
	CALL	BCVOX_INIT
	
	LACK	8
	SAH	PRO_VAR
	
	LACL	1000
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1
	

	RET	
;=======================================================================
;99999999999999999999999999999999999999999999999999999999999999999999999
REMOTE_PRO9:	
	LACK	0
	SAH	PRO_VAR
	
	LACL	CMSG_INIT
	CALL	STOR_MSG
	RET
;=======================================================================
;#######################################################################
REMOTE_PRO10:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,REMOTE_PRO10_END
	
	RET
REMOTE_PRO0_TONE:
REMOTE_PRO10_END:
	CALL	INIT_DAM_FUNC
	CALL	REAL_DEL	;0x6100
	CALL	CLR_FUNC	;先空	
	LACK	0
	SAH	PRO_VAR
;!!!!!!!!!!!!!!!
	LACL	0XD0		;告诉MCU挂机了
	CALL	STOR_DAT
	LACK	1
	CALL	STOR_DAT
	LACL	0XFF
	CALL	STOR_DAT
;!!!!!!!!!!!!!!!	
	LACL	0X9000		;Line OFF
	ORK	CMODE9
	SAH	CONF
	CALL	DAM_BIOS
	
	LACL	CMSG_INIT
	CALL	STOR_MSG
		
	CALL	DAA_OFF	
	CALL	HOOK_OFF
		
	RET

;=========================================================================
REMOTE_PRO11:
	LAC	MSG
	XORL	CREV_DTMF		;CREV_DTMF
	BS	ACZ,REMOTE_PRO11_REVDTMF
;REMOTE_PRO11_0:
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,REMOTE_PRO0_TMR
;REMOTE_PRO11_0_1:	
	LAC	MSG
	XORL	CMSG_BTONE
	BS	ACZ,REMOTE_PRO0_TONE
;REMOTE_PRO11_0_2:	
	LAC	MSG
	XORL	CMSG_CTONE
	BS	ACZ,REMOTE_PRO0_TONE

	RET
;-------
REMOTE_PRO11_REVDTMF:
	LACK	0
	SAH	PRO_VAR1
	
	CALL	BCVOX_INIT
	
	LAC	DTMF_VAL
	SBHL	0X0F0
	;BS	ACZ,REMOTE_PRO11_1_0	;0
	SBHK	1
	BS	ACZ,REMOTE_PRO11_1_1	;1---play new
	SBHK	1
	BS	ACZ,REMOTE_PRO11_1_2
	SBHK	1
	BS	ACZ,REMOTE_PRO11_1_3
	SBHK	4
	BS	ACZ,REMOTE_PRO0_REV_DTMF_7	;7---record/play OGM
	SBHK	1
	BS	ACZ,REMOTE_PRO0_REV_DTMF_8	;8---indoormonitor
	SBHK	1
	BS	ACZ,REMOTE_PRO0_REV_DTMF_9	;9---on/off
	SBHK	5
	BS	ACZ,REMOTE_PRO0_REV_DTMF_A	;*---remote prompt
	SBHK	1
	BS	ACZ,REMOTE_PRO0_REV_DTMF_B	;#---hang off	
	
	
	RET	
	
REMOTE_PRO11_1_1:
	LACK	1
	SAH	MBOX_ID
	BS	B1,REMOTE_PRO11_1
REMOTE_PRO11_1_2:
	LACK	2
	SAH	MBOX_ID
	BS	B1,REMOTE_PRO11_1
REMOTE_PRO11_1_3:
	LACK	3
	SAH	MBOX_ID
REMOTE_PRO11_1:
	
	CALL	INIT_DAM_FUNC
	CALL	MSG_CHK
	CALL	CLR_FLAG
	BIT	ANN_FG,12
	BS	TB,REMOTE_PRO11_1_4

	CALL	VP_NO			;no
	CALL	VP_NEW			;new
	CALL	VP_MESSAGES		;MESSAGES

	CALL	BBEEP

	LACK	0
	SAH	PRO_VAR
	BS	B1,REMOTE_PRO11_1_END
REMOTE_PRO11_1_4:
	LACK	1
	SAH	PRO_VAR

	LACK	0
	SAH	FILE_LEN
	SAH	FILE_ID
	SAH	MSG_ID

	CALL	GET_VPMSGN
	SAH	MSG_N
	SBHK	1
	BS	ACZ,REMOTE_PRO11_1_ONEMESSAGE
	
	LAC	MSG_N
	CALL	ANNOUNCE_NUM
	CALL	VP_NEW			;new
	CALL	VP_MESSAGES		;MESSAGES
	
	BS	B1,REMOTE_PRO11_1_END
REMOTE_PRO11_1_ONEMESSAGE:
	CALL	VP_ONE
	CALL	VP_NEW			;new
;REMOTE_PRO11_1_VPMESSAGE:
	CALL	VP_MESSAGE		;MESSAGE
REMOTE_PRO11_1_END:
	CALL	DAA_LIN_SPK
	
	RET
;====================================================================
REMOTE_PRO12:
	LAC	MSG
	XORL	CREV_DTMF		;CREV_DTMF
	BS	ACZ,REMOTE_PRO12_REVDTMF
;REMOTE_PRO12_0:
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,REMOTE_PRO0_TMR
;REMOTE_PRO12_0_1:	
	LAC	MSG
	XORL	CMSG_BTONE
	BS	ACZ,REMOTE_PRO0_TONE
;REMOTE_PRO12_0_2:
	LAC	MSG
	XORL	CMSG_CTONE
	BS	ACZ,REMOTE_PRO0_TONE
	
	RET
;-------
REMOTE_PRO12_REVDTMF:
	LACK	0
	SAH	PRO_VAR1
	
	CALL	BCVOX_INIT
	
	LAC	DTMF_VAL
	SBHL	0X0F0
	;BS	ACZ,REMOTE_PRO12_1_0	;0
	SBHK	1
	BS	ACZ,REMOTE_PRO12_1_1	;1
	SBHK	1
	BS	ACZ,REMOTE_PRO12_1_2	;2
	SBHK	1
	BS	ACZ,REMOTE_PRO12_1_3	;3
	SBHK	4
	BS	ACZ,REMOTE_PRO0_REV_DTMF_7	;7---record/play OGM
	SBHK	1
	BS	ACZ,REMOTE_PRO0_REV_DTMF_8	;8---indoormonitor
	SBHK	1
	BS	ACZ,REMOTE_PRO0_REV_DTMF_9	;9---on/off
	SBHK	5
	BS	ACZ,REMOTE_PRO0_REV_DTMF_A	;*---remote prompt
	SBHK	1
	BS	ACZ,REMOTE_PRO0_REV_DTMF_B	;#---hang off	

	RET	
	
REMOTE_PRO12_1_1:
	LACK	1
	SAH	MBOX_ID
	BS	B1,REMOTE_PRO12_1
REMOTE_PRO12_1_2:
	LACK	2
	SAH	MBOX_ID
	BS	B1,REMOTE_PRO12_1
REMOTE_PRO12_1_3:
	LACK	3
	SAH	MBOX_ID
REMOTE_PRO12_1:
	
	CALL	INIT_DAM_FUNC
	CALL	MSG_CHK
	
	LACK	0
	SAH	FILE_LEN
	SAH	FILE_ID
	SAH	MSG_ID
	
	BIT	ANN_FG,14
	BS	TB,REMOTE_PRO12_4

	CALL	VP_NO			;no
	CALL	VP_MESSAGES		;MESSAGES
	CALL	BBEEP
	
	LACK	0
	SAH	PRO_VAR
	
	BS	B1,REMOTE_PRO12_1_END
REMOTE_PRO12_4:
	LACK	2
	SAH	PRO_VAR

	CALL	GET_VPMSGT
	SAH	MSG_T
	SBHK	1
	BS	ACZ,REMOTE_PRO12_4_ONEMESAGE
	
	LAC	MSG_T
	CALL	ANNOUNCE_NUM
	CALL	VP_MESSAGES		;MESSAGES
	
	BS	B1,REMOTE_PRO12_1_END
REMOTE_PRO12_4_ONEMESAGE:
	CALL	VP_ONE
	CALL	VP_MESSAGE		;MESSAGE
REMOTE_PRO12_1_END:
	CALL	DAA_LIN_SPK
	
	RET
;====================================================================
REMOTE_PRO13:
	LAC	MSG
	XORL	CREV_DTMF		;CREV_DTMF
	BS	ACZ,REMOTE_PRO13_REVDTMF
;REMOTE_PRO13_0:
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,REMOTE_PRO0_TMR
;REMOTE_PRO13_0_1:	
	LAC	MSG
	XORL	CMSG_BTONE
	BS	ACZ,REMOTE_PRO0_TONE
;REMOTE_PRO13_0_2:
	LAC	MSG
	XORL	CMSG_CTONE
	BS	ACZ,REMOTE_PRO0_TONE
	
	RET
;-------
REMOTE_PRO13_REVDTMF:
	LACK	0
	SAH	PRO_VAR1
	
	CALL	BCVOX_INIT
	
	LAC	DTMF_VAL
	SBHL	0X0F0
	;BS	ACZ,REMOTE_PRO13_1_0	;0
	SBHK	1
	BS	ACZ,REMOTE_PRO13_1_1	;1---play new
	SBHK	1
	BS	ACZ,REMOTE_PRO13_1_2
	SBHK	1
	BS	ACZ,REMOTE_PRO13_1_3
	SBHK	4
	BS	ACZ,REMOTE_PRO0_REV_DTMF_7	;7---record/play OGM
	SBHK	1
	BS	ACZ,REMOTE_PRO0_REV_DTMF_8	;8---indoormonitor
	SBHK	1
	BS	ACZ,REMOTE_PRO0_REV_DTMF_9	;9---on/off
	SBHK	5
	BS	ACZ,REMOTE_PRO0_REV_DTMF_A	;*---remote prompt
	SBHK	1
	BS	ACZ,REMOTE_PRO0_REV_DTMF_B	;#---hang off	

	RET	
	
REMOTE_PRO13_1_1:
	LACK	1
	SAH	MBOX_ID
	BS	B1,REMOTE_PRO13_1
REMOTE_PRO13_1_2:
	LACK	2
	SAH	MBOX_ID
	BS	B1,REMOTE_PRO13_1
REMOTE_PRO13_1_3:
	LACK	3
	SAH	MBOX_ID
REMOTE_PRO13_1:
	CALL	INIT_DAM_FUNC
	LACK	0
	SAH	PRO_VAR

	CALL	MSG_CHK
	BIT	ANN_FG,14
	BS	TB,REMOTE_PRO13_4
	
	CALL	VP_NO			;no
	CALL	VP_MESSAGES		;MESSAGES
	
	CALL	BBEEP
	
	BS	B1,REMOTE_PRO13_END
REMOTE_PRO13_4:
	LACL	0X6100
	SAH	CONF
	CALL	DAM_BIOS
	
	LACL	0X6080
	SAH	CONF
	CALL	DAM_BIOS
	
	CALL	TELNUMALL_DEL	;删除没有对应message的电话号码

	;CALL	VP_MESSAGES	;messages
	;CALL	VP_ERASE	;erase

	CALL	BBEEP
REMOTE_PRO13_END:	
	CALL	DAA_LIN_SPK
	
	
	RET
;===============================================================================
VP_MENU_QUEUE:	;for English
;
.DATA	46	;长度	
	;press	1	and	mailbox	number	t0	play	new	messages
.DATA	46	1	60	62	63	47	48	40	42
	;press	2	and	mailbox	number	t0	play	all	messages
.DATA	46	2	60	62	63	47	48	49	42
	;press	3	and	mailbox	number	t0	erase	messages
.DATA	46	3	60	62	63	47	50	42
	;press	7				t0	record	announcement
.DATA	46	7				47	51	52
	;press	8				t0	activat_room_monitor
.DATA	46	8				47	54
	;press	9				t0	turn_on_or_off
.DATA	46	9				47	53
	;press	asteris	for_menu
.DATA	46	55	57
	;press	asterisk			to	release_line
.DATA	46	56				47	58
;-------------------------------------------------------------------------------
VP_GMENU_QUEUE:		;for German
;
.DATA	8	;长度	
;
.DATA	133	134	135	136	137	138	139	140

.END
	