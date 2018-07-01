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
	BS	ACZ,LOCAL_PROERA_ALL	;2 = erase all
	SBHK	1
	BS	ACZ,LOCAL_PRO0_3	;3 = format
	
	RET
	
LOCAL_PRO0_0:	
	LAC	MSG
	XORL	CMSG_INIT		;INITIAL
	BS	ACZ,LOCAL_PRO0_INIT
LOCAL_PRO0_0_1:
	LAC	MSG
	XORL	CMSG_KEY1S		;Record message
	BS	ACZ,LOCAL_PRO0_PLYMSG
LOCAL_PRO0_0_2:
	LAC	MSG
	XORL	CMSG_KEY2S		;Announce time
	BS	ACZ,LOCAL_PRO0_ANNOTIME
LOCAL_PRO0_0_2_1:
	LAC	MSG
	XORL	CMSG_KEY2L		;Announce time
	BS	ACZ,LOCAL_PRO0_PSWORD
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
	XORL	CMSG_KEY6S		;on/off
	BS	ACZ,LOCAL_PRO0_ONOFF
LOCAL_PRO0_0_7:
	LAC	MSG
	XORL	CMSG_KEY7S		;VOL+
	BS	ACZ,LOCAL_PRO0_VOLA
LOCAL_PRO0_0_8:
	LAC	MSG
	XORL	CMSG_KEY8S		;VOL-
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

;---------------------------------------
	RET
LOCAL_PRO0_1:
	RET
;-------------------------------------------------------------------------------
LOCAL_PROERA_ALL:
	LAC	MSG
	XORL	CMSG_KEY3S		;erase key released
	BS	ACZ,LOCAL_PROERA_ALL_RELE
	LAC	MSG
	XORL	CVP_STOP		;erase key released
	BS	ACZ,LOCAL_PROERA_ALL_VPSTOP
	
	RET
LOCAL_PROERA_ALL_RELE:
	LACL	CMSG_INIT
	CALL	STOR_MSG
	
	LACK	0
	SAH	PRO_VAR

	RET
LOCAL_PROERA_ALL_VPSTOP:
	BS	B1,LOCAL_PROERA_ALL_RELE
;-------------------------------------------------------------------------------	
LOCAL_PRO0_3:
	RET
;---------------

LOCAL_PRO0_INIT:
	CALL	DAA_OFF
	CALL	GC_CHK
	CALL	VPMSG_CHK

	CALL	LINE_START	;Note : check CID in standby

	CALL	GET_FILEID
	CALL	SET_FILEID	;set use_dat()

	CALL	VPMSG_CHK

	LACL	1000
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1
;---

	RET
LOCAL_PRO0_PROPHO:

	RET
;---------------------------------------
LOCAL_PRO0_VPSTOP:
	BS	B1,LOCAL_PRO0_INIT

;-------------------------------------------------------------------------------
LOCAL_PRO0_ANNOTIME:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	CURR_WEEK
	CALL	CURR_HOUR
	CALL	CURR_MIN
;????????????????????????????????	
	lack	0x0007
	sah	PRO_VAR
	CALL	BBEEP
	call	LOAD_TETF_VP
;????????????????????????????????
	RET
LOCAL_PRO0_PSWORD:
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
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PRO0_REAALL:
	CALL	INIT_DAM_FUNC
	LACL	0XA186
	SAH	LED_L		;Display "dE"
	
	LACL	0X6080
	CALL	DAM_BIOSFUNC
	CALL	GC_CHK

	CALL	VPMSG_CHK
	CALL	DAA_SPK
	CALL	LBEEP
	
	LACK	0X0020
	SAH	PRO_VAR
	
	RET
LOCAL_PRO0_VOLS:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	
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
LOCAL_PRO0_RECTWA:
	CALL	INIT_DAM_FUNC
	CALL	VPMSG_CHK
	BIT	ANN_FG,13	;check memoful?
	BS	TB,LOCAL_PRO0_RECMSG_MFUL
	
	CALL	INIT_DAM_FUNC
	CALL	SET_COMPS
	LACK	0X0005
	SAH	PRO_VAR

	LACL	0XA4AF		;Didplay "2r"
	SAH	LED_L
	
	CALL	LOAD_LOCF_VP

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

	CALL	BEEP

	LACL	0XAF86	;Didplay "rE"
	SAH	LED_L
	
	CALL	LOAD_LOCF_VP

	BIT	ANN_FG,13	;check memoful?
	BS	TB,LOCAL_PRO0_RECMSG_MFUL

	RET
LOCAL_PRO0_RECMSG_MFUL:
	BS	B1,LOCAL_PROWORN
;---------------------------------------
LOCAL_PRO0_RECOGM:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	LBEEP
	CALL	SET_COMPS
;---LED_L "rA"
	LACL	0XAF88
	SAH	LED_L

	LACK	0X0003
	SAH	PRO_VAR

	BIT	ANN_FG,13	;check memoful?
	BS	TB,LOCAL_PROWORN
	
	CALL	LOAD_LOCF_VP

	RET
LOCAL_PRO0_PLYOGM:		;准备播放OGM
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	LACK	0X0023
	SAH	PRO_VAR		;进入播放OGM子功能
	
	CALL	LOAD_LOCF_VP

	CALL	OGM_SELECT

	LAC	MSG_ID
	ORL	0XFE00
	CALL	STOR_VP
;---LED_L "PA"
	LACL	0X8C88
	SAH	LED_L

	CALL	OGM_SELECT
	BZ	ACZ,MAIN_PRO0_PLAY_OGM1
	
	LACK	0X0
	SAH	PRO_VAR
	
	CALL	INIT_DAM_FUNC
	CALL	BBEEP

MAIN_PRO0_PLAY_OGM1:

	RET
;---------------------------------------
LOCAL_PRO0_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
LOCAL_PRO0_TMR0:	
	BIT	EVENT,9
	BS	TB,LOCAL_PRO0_TMR2
	
	BIT	PRO_VAR1,0
	BS	TB,LOCAL_PRO0_TMR1
LOCAL_PRO0_TMR0_0:
	LAC	MSG_T
	CALL	LED_HLDISP	;VP总数
	
	RET
LOCAL_PRO0_TMR1:
	BIT	ANN_FG,13
	BS	TB,LOCAL_PRO0_TMR3

	LAC	MSG_T
	CALL	LED_HLDISP	;VP总数
	
	RET
LOCAL_PRO0_TMR2:
	LACL	0XBFBF		;--
	SAH	LED_L

	RET
LOCAL_PRO0_TMR3:
	LACL	0X8EC7		;"FL"
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
LOCAL_PRO0_PLYMSG:
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	LACK	0X0005
	CALL	STOR_VP

	CALL	VPMSG_CHK		;进入播放子功能
	CALL	CLR_FLAG
	LACK	0X0001
	SAH	PRO_VAR	

	LACK	0
	SAH	MSG_ID
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

	LACK	0X0
	SAH	PRO_VAR	
	
	RET
;-------play new messages
LOCAL_PRO0_PLAY_NEW:
	
	
	RET
;-------play old messages
LOCAL_PRO0_PLAY_OLD:
	
	RET
;---------------------------------------
LOCAL_PRO0_ONOFF:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	
	LAC	EVENT		;EVENT.9
	XORL	(1<<9)
	SAH	EVENT

	BS	B1,LOCAL_PRO0_TMR0
;---------------------------------------
LOCAL_PRO0_PDWN:
	
	RET
LOCAL_PRO0_PUP:
	
	RET

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
;LOCAL_PROMNU:
;LOCAL_PROSET:
;	RET
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
