.LIST
LOCAL_PRO:
	LAC	PRO_VAR
	ANDK	0X0F
	BS	ACZ,LOCAL_PRO0		;(F0)0 = idle
	SBHK	1
	BS	ACZ,LOCAL_PROPLY	;(F1) = play memo/icm
	SBHK	1
	BS	ACZ,LOCAL_PROREC	;(F2) = record memo
	SBHK	1
	BS	ACZ,LOCAL_PROOGM	;(F3) = record/play OGM
	SBHK	1
	BS	ACZ,LOCAL_PROMNU	;(F4) = for set time and remote code
	SBHK	1
	BS	ACZ,LOCAL_PROTWR	;(F5) = two way record
	SBHK	1
	BS	ACZ,LOCAL_PROVOP	;(F6) = for VOP test
	SBHK	1
	BS	ACZ,LOCAL_PROTXT	;(F7) = for test mode
	
	RET
;---------------事件响应区
LOCAL_PRO0:
	LAC	PRO_VAR
	SFR	4
	ANDK	0X0F
	BS	ACZ,LOCAL_PRO0_0	;0 = idel
	SBHK	1
	BS	ACZ,LOCAL_PRO0_1	;1 = VP end(for key mode)
	SBHK	1
	BS	ACZ,LOCAL_PROERA	;2 = erase all
	SBHK	1
	BS	ACZ,LOCAL_PRO0_3	;3 = format
	
	RET
;-------------------------------------------------------------------------------	
LOCAL_PRO0_0:	
	LAC	MSG
	XORL	CMSG_INIT		;INITIAL
	BS	ACZ,LOCAL_PRO0_INIT
LOCAL_PRO0_0_1:
	LAC	MSG
	XORL	CMSG_KEY1D		;Record message
	BS	ACZ,LOCAL_PRO0_PLYMSG
LOCAL_PRO0_0_2:
	LAC	MSG
	XORL	CMSG_KEY2S		;Announce time
	BS	ACZ,LOCAL_PRO0_ANNOTIME
	LAC	MSG
	XORL	CMSG_KEY2L		;Set time
	BS	ACZ,LOCAL_PRO0_SETTIME
LOCAL_PRO0_0_3:
	LAC	MSG
	XORL	CMSG_KEY3L		;Erase all old messages
	BS	ACZ,LOCAL_PRO0_REAALL
LOCAL_PRO0_0_4:
	LAC	MSG
	XORL	CMSG_KEY4S		;Record two way
	BS	ACZ,LOCAL_PRO0_RECTWA
LOCAL_PRO0_0_4_1:	
	LAC	MSG
	XORL	CMSG_KEY4L		;Record message
	BS	ACZ,LOCAL_PRO0_RECMSG
LOCAL_PRO0_0_5:
	LAC	MSG
	XORL	CMSG_KEY5S		;OGM_PLAY
	BS	ACZ,LOCAL_PRO0_PLYOGM
LOCAL_PRO0_0_5_1:
	LAC	MSG
	XORL	CMSG_KEY5L		;OGM_RECORD
	BS	ACZ,LOCAL_PRO0_RECOGM
LOCAL_PRO0_0_6:
	LAC	MSG
	XORL	CMSG_KEY6D		;on/off
	BS	ACZ,LOCAL_PRO0_ONOFF
LOCAL_PRO0_0_7:
	LAC	MSG
	XORL	CMSG_KEY7D		;VOL+
	BS	ACZ,LOCAL_PRO0_VOLA
LOCAL_PRO0_0_8:
	LAC	MSG
	XORL	CMSG_KEY8D		;VOL-
	BS	ACZ,LOCAL_PRO0_VOLS
LOCAL_PRO0_0_16:
	LAC	MSG
	XORL	CMSG_TMR		;CMSG_TMR
	BS	ACZ,LOCAL_PRO0_TMR
LOCAL_PRO0_0_17:	
	LAC	MSG
	XORL	CCAS_TONE		;Cas-tone end
	BS	ACZ,LOCAL_PRO0_CASTONE
LOCAL_PRO0_0_18:
	LAC	MSG
	XORL	CVP_STOP		;VP_STOP
	BS	ACZ,LOCAL_PRO0_VPSTOP
LOCAL_PRO0_0_19:
	LAC	MSG
	XORL	CMSG_TMODE
	BS	ACZ,LOCAL_PRO0_TMODE
LOCAL_PRO0_0_20:	
	LAC	MSG
	XORL	CMSG_SELL
	BS	ACZ,LOCAL_PRO0_SELLANG
;---------------------------------------
	RET
LOCAL_PRO0_1:
	RET

;-------------------------------------------------------------------------------	
LOCAL_PRO0_3:
	RET
;---------------

LOCAL_PRO0_INIT:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF

	CALL	GC_CHK
	CALL	VPMSG_CHK

	CALL	GET_FILEID
	CALL	SET_FILEID	;set use_dat()
	CALL	OGM12_EXIST
	CALL	VPMSG_CHK

	LACL	500
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1
;---
	RET

;---------------------------------------
LOCAL_PRO0_VPSTOP:
	CALL	PORT_HSPLYL
	CALL	PORT_PLYL
	BS	B1,LOCAL_PRO0_INIT
;---------------------------------------
LOCAL_PRO0_TMODE:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	HANDSET_CHK
	CALL	BEEP

	LACL	0X2447
	SAH	VOI_ATT		;RING_CNT/Line_Gain/SPK_Gain/SPK_VOL

	LACL	CMODE9
	ORK	1
	CALL	DAM_BIOSFUNC	;清flash……

	LACK	0x0007
	SAH	PRO_VAR

	CALL	LOAD_TETF_VP
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PRO0_ANNOTIME:
	LACL	CANN_TIME
	SAH	MSG
	BS	B1,LOCAL_PRO0_SETTIME
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PRO0_SETTIME:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	
	CALL	HANDSET_CHK
	LACL	300
	CALL	SET_TIMER2	;for check handset on/off

	LACK	0
	SAH	PRO_VAR1	;
;---	
	LAC	MSG
	CALL	STOR_MSG

	LACK	0x0004
	SAH	PRO_VAR

	call	LOAD_MNUF_VP
;---
	RET
;-------------------------------------------------------------------------------
LOCAL_PRO0_SELLANG:
	BS	B1,LOCAL_PRO0_SETTIME
;-------------------------------------------------------------------------------
LOCAL_PRO0_PSWORD:
.if	0
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	
	CALL	LOAD_MNUF_VP

	LACK	0X014
	SAH	PRO_VAR

	LACK	0
	SAH	NEW1
	LACK	9
	SAH	NEW2

	LACL	0XF700
	SAH	MSG_ID		;"识别码"
	
	LAC	PASSWORD	;取数据并显示
	SFR	8
	ANDK	0X0F
	SAH	MSG_N
	CALL	LED_HLDISP
	
	LAC	LED_L
	ANDL	0X00FF
	OR	MSG_ID
	SAH	LED_L
.endif	
	RET
;---------------------------------------
LOCAL_PRO0_REAALL:
	CALL	INIT_DAM_FUNC
	CALL	VPMSG_CHK
	;LACL	DISP_dE
	;SAH	LED_L		;Display "dE"
	
	LACL	0X6080
	CALL	DAM_BIOSFUNC
	CALL	GC_CHK
	CALL	LOAD_LOCF_VP
		
	CALL	HANDSET_CHK
	LACL	300
	CALL	SET_TIMER2	;for check handset on/off
	
	CALL	VPMSG_CHK
	CALL	DAA_SPK
	CALL	BEEP
	
	LACK	0X0020
	SAH	PRO_VAR
	
	RET
;---------------------------------------
LOCAL_PRO0_VOLS:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	CALL	CLR_TIMER
	
	LAC	VOI_ATT
        ANDL	0X07
        SBHK	1		;下限
        BZ	SGN,LOCAL_PROX_VOLS

	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BBBEEP	
LOCAL_PROX_VOLS:
	LACL	CMSG_VOLS
	CALL	STOR_MSG
	
	RET
LOCAL_PRO0_VOLA:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	CALL	CLR_TIMER
	
	LAC	VOI_ATT
        ANDL	0X07
        SBHK	7		;上限
        BS	SGN,LOCAL_PROX_VOLA

	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BBBEEP
LOCAL_PROX_VOLA:
	LACL	CMSG_VOLA
	CALL	STOR_MSG
	
	RET
;---------------------------------------
LOCAL_PRO0_RECTWA:
	CALL	INIT_DAM_FUNC

	CALL	SET_COMPS
	LACK	0X0005
	SAH	PRO_VAR

	LACL	DISP_2r		;Didplay "2r"
	SAH	LED_L
	
	CALL	LOAD_LOCF_VP

	CALL	VPMSG_CHK
	BIT	ANN_FG,13	;check memoful?
	BS	TB,LOCAL_PRO0_RECMSG_MFUL

	LACL	CMSG_INIT
	CALL	STOR_MSG

	RET
;---------------------------------------
LOCAL_PRO0_RECMSG:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	SET_COMPS
	LACK	0X0002
	SAH	PRO_VAR
	
	CALL	HANDSET_CHK
	LACL	300
	CALL	SET_TIMER2	;for check handset on/off

	CALL	BEEP

	LACL	DISP_rE		;Didplay "rE"
	SAH	LED_L
	
	CALL	LOAD_LOCF_VP

	BIT	ANN_FG,13	;check memoful?
	BS	TB,LOCAL_PRO0_RECMSG_MFUL

	RET
LOCAL_PRO0_RECMSG_MFUL:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BBBEEP
	CALL	VP_MemoryFull
	
	LACK	0X0
	SAH	PRO_VAR
	
	RET
;---------------------------------------
LOCAL_PRO0_RECOGM:
	CALL	INIT_DAM_FUNC
	CALL	BEEP
	CALL	SET_COMPS
	
	CALL	HANDSET_CHK
	LACL	300
	CALL	SET_TIMER2	;for check handset on/off

;---delete the old OGM fisrt------------
	CALL	OGM_SELECT
	LAC	MSG_ID
	CALL	VPMSG_DEL
	CALL	GC_CHK
	
	CALL	LOAD_LOCF_VP	
	
	CALL	VPMSG_CHK	;check mfull
;---LED_L "rA"
	CALL	DAA_SPK
	
	LACL	DISP_rA		;"rA"
	SAH	LED_L

	LACK	0X0003
	SAH	PRO_VAR

	BIT	ANN_FG,13	;check memoful?
	BS	TB,LOCAL_PRO0_RECOGM_MFUL

	RET
LOCAL_PRO0_RECOGM_MFUL:	
	CALL	INIT_DAM_FUNC
	CALL	BBBEEP		;if full and VP not exist you can't record OGM
	CALL	VP_MemoryFull
	LACK	0X0013
	SAH	PRO_VAR
	
	RET
;---------------------------------------
LOCAL_PRO0_PLYOGM:		;准备播放OGM
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	LACK	0X0023
	SAH	PRO_VAR		;进入播放OGM子功能
	
	CALL	CLR_TIMER
	CALL	LOAD_LOCF_VP
;---LED_L "PA"
	LACL	DISP_PA		;"PA"
	SAH	LED_L
	
	CALL	HANDSET_CHK
	LACL	300
	CALL	SET_TIMER2	;for check handset on/off

	CALL	OGM_SELECT
	LAC	MSG_ID
	ORL	0XFE00
	CALL	STOR_VP

	CALL	OGM_SELECT
	BZ	ACZ,MAIN_PRO0_PLAY_OGM1
	
	CALL	INIT_DAM_FUNC
	CALL	VP_DefOGM

MAIN_PRO0_PLAY_OGM1:

	RET
;---------------------------------------
LOCAL_PRO0_TMR:
	CALL	DAA_OFF
	
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
LOCAL_PRO0_TMR0:

	BIT	EVENT,9
	BS	TB,LOCAL_PRO0_TMR2	;answer off ?

	BIT	ANN_FG,13
	BS	TB,LOCAL_PRO0_TMR3	;memory full ?

	BIT	EVENT,8
	BS	TB,LOCAL_PRO0_TMR0_1	;answer only ?
;---------------
	LAC	PRO_VAR1
	SBHK	6
	BS	SGN,LOCAL_PRO0_TMR0_0

	LACK	0
	SAH	PRO_VAR1
LOCAL_PRO0_TMR0_0:
	BS	B1,LOCAL_PRO0_TMR0_2
LOCAL_PRO0_TMR0_1:
	LAC	PRO_VAR1
	SBHK	8
	BS	SGN,LOCAL_PRO0_TMR0_0

	LACK	0
	SAH	PRO_VAR1
LOCAL_PRO0_TMR0_2:
;---------------
	LAC	PRO_VAR1
	BS	ACZ,LOCAL_PRO0_TMR1_2	;0 --- ""or"T总数"
	SBHK	1
	BS	ACZ,LOCAL_PRO0_TMR1	;1 --- T/N总数
	SBHK	1
	BS	ACZ,LOCAL_PRO0_TMR1_2	;2 --- ""orT总数
	SBHK	1
	BS	ACZ,LOCAL_PRO0_TMR1	;3 --- T/N总数
	SBHK	1
	BS	ACZ,LOCAL_PRO0_TMR1_3	;4 --- "--"or""orT总数
	SBHK	1
	BS	ACZ,LOCAL_PRO0_TMR1_4	;5 --- "--"or"T/N总数"
	SBHK	1
	BS	ACZ,LOCAL_PRO0_TMR7	;6 --- "A2"
	SBHK	1
	BS	ACZ,LOCAL_PRO0_TMR7	;7 --- "A2"

	RET
;-----------------------------------------------------------
;---------------
LOCAL_PRO0_TMR1:
	BIT	ANN_FG,12
	BS	TB,LOCAL_PRO0_TMR6	;New VP总数
	BS	B1,LOCAL_PRO0_TMR5	;VP总数

;---
LOCAL_PRO0_TMR1_2:
	BIT	ANN_FG,12
	BS	TB,LOCAL_PRO0_TMR4	;“”
	BS	B1,LOCAL_PRO0_TMR5	;VP总数
;---
LOCAL_PRO0_TMR1_3:
	BIT	ANN_FG,4
	BZ	TB,LOCAL_PRO0_TMR2	;“--”
	
	BIT	ANN_FG,12
	BS	TB,LOCAL_PRO0_TMR4	;“”

	BS	B1,LOCAL_PRO0_TMR5
;---
LOCAL_PRO0_TMR1_4:
	BIT	ANN_FG,4
	BZ	TB,LOCAL_PRO0_TMR2	;“--”
	BIT	ANN_FG,12
	BS	TB,LOCAL_PRO0_TMR6	;NEW Message exist ?
	BS	B1,LOCAL_PRO0_TMR5
;---------------
LOCAL_PRO0_TMR2:
	LACL	0XBFBF		;--
	SAH	LED_L

	RET
;---
LOCAL_PRO0_TMR3:
	LACL	DISP_FL		;"FL"
	SAH	LED_L

	RET
;---
LOCAL_PRO0_TMR4:
	LACL	0XFFFF		;LED灭
	SAH	LED_L

	RET
;---
LOCAL_PRO0_TMR5:
	LAC	MSG_T
	CALL	LED_HLDISP	;VP总数
	
	RET
;---
LOCAL_PRO0_TMR6:
	LAC	MSG_N
	CALL	LED_HLDISP	;NEW VP总数
	
	RET
LOCAL_PRO0_TMR7:
	LACL	DISP_A2		;"A2"
	SAH	LED_L
	
	RET
;---------------------------------------
LOCAL_PRO0_PLYVOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	LACK	0X0005
	CALL	STOR_VP
	
	LACK	0X0006
	SAH	PRO_VAR	
	
	LACK	0
	SAH	MSG_ID
	
	RET
;---------------------------------------
LOCAL_PRO0_PLYMSG:
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	LACK	0X0005
	CALL	STOR_VP

	CALL	HANDSET_CHK
	
	CALL	VPMSG_CHK		;进入播放子功能
	CALL	CLR_FLAG
	CALL	CLR_TIMER
	LACK	0X0001
	SAH	PRO_VAR	

	LACL	300
	CALL	SET_TIMER2	;for check handset on/off

	LACK	0
	SAH	MSG_ID
	SAH	FILE_ID
;--	
	CALL	LOAD_LOCF_VP

	BIT	ANN_FG,12
	BS	TB,LOCAL_PRO0_PLAY_NEW
	BIT	ANN_FG,14
	BS	TB,LOCAL_PRO0_PLAY_OLD
;LOCAL_PRO0_PLYMSG_NO:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BBBEEP
	
	LACL	0X0201
	SAH	PRO_VAR	
	
	RET
;-------play new messages---------------
LOCAL_PRO0_PLAY_NEW:
	
	RET
;-------play old messages---------------
LOCAL_PRO0_PLAY_OLD:
	
	RET
;---------------------------------------
LOCAL_PRO0_ONOFF:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	CALL	HANDSET_CHK
	CALL	CLR_TIMER
	
	LAC	EVENT		;EVENT.9
	XORL	(1<<9)
	SAH	EVENT

	BS	B1,LOCAL_PRO0_TMR0
;---------------------------------------

;-------------------------------------------------------------------------------	
LOCAL_PROEND_BEFORINIT:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BBEEP
	
	LACK	0X0
	SAH	PRO_VAR

	RET

;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
LOCAL_PROVOP:
	LAC	MSG
	XORL	CVP_STOP		;PLAY END
	BS	ACZ,LOCAL_PROVOP_OVER
LOCAL_PROVOP_1:	
	LAC	MSG
	XORL	CMSG_KEYAS		;ON/OFF(stop)
	BS	ACZ,LOCAL_PROVOP_STOP
	
	RET
LOCAL_PROVOP_OVER:
	CALL	INIT_DAM_FUNC

	LAC	MSG_ID
	SBHK	56
	BZ	SGN,LOCAL_PROVOP_STOP

	LAC	MSG_ID			;next message
	ADHK	1
	SAH	MSG_ID
	
	LAC	MSG_ID
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
LOCAL_PROVOP_STOP:
	CALL	INIT_DAM_FUNC
	BS	B1,LOCAL_PROEND_BEFORINIT
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
LOCAL_PROWORN:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BBBEEP
	
	LACK	0X0
	SAH	PRO_VAR
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PRO0_CASTONE:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACK	0
	SAH	PRO_VAR
	
	CALL	LINE_START
	
	RET
;-------------------------------------------------------------------------------
	
.END
