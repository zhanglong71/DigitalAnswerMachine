;-------------------------------------------------------------------------------
.NOLIST
.INCLUDE	include/REG_D22.inc
.INCLUDE	include/MD22U.inc
.INCLUDE	include/CONST.inc
.INCLUDE	include/EXTERN.inc

.GLOBAL	ANS_STATE
;-------------------------------------------------------------------------------
.EXTERN	SetFlashStartAddress
.EXTERN	LoadHostCode
.EXTERN	GetOneConst

;-------------------------------------------------------------------------------
.LIST
;-------------------------------------------------------------------------------
.ORG	ADDR_SECOND
;-------------------------------------------------------------------------------
ANS_STATE:
	CALL	GET_RESPOND
	
	CALL	GET_MSG
	BS	ACZ,ANS_STATE_END
	SAH	MSG	
;-------------------------------------------------------------------------------
	LAC	MSG
	XORL	CPHONE_ON
	BS	ACZ,ANS_STATE_HFREE
	LAC	MSG
	XORL	CHOOK_OFF
	BS	ACZ,ANS_STATE_HSETOFF
	
	LAC	MSG
	XORL	CSEG_END
	BS	ACZ,ANS_STATE_SEGEND	;SEG-end
;---
	LAC	MSG
	XORL	CMSG_SER
	BS	ACZ,ANS_STATE_SER	;SEG-end
;-----
	LAC	PRO_VAR
	ANDK	0XF
	BS	ACZ,ANS_STATE0		;for initial
	SBHK	1
	BS	ACZ,ANS_STATE_REC	;for record(ANSWER AND RECORD ICM)
	SBHK	1
	BS	ACZ,ANS_STATE_LINE	;for line(ANSWER ONLY)
	SBHK	1
	BS	ACZ,ANS_STATE_EXIT	;for end(TimeOut/BTONE/CTONE/VOX_ON/CPC)
ANS_STATE_END:
	RET
;---------------------------------------
ANS_STATE0_CPC:			;Not recording exit
ANS_STATE_LINE_CPC:
	BS	B1,ANS_STATE_EXIT_END
;---------------------------------------
ANS_STATE_SEGEND:
	CALL	GET_VP
	BS	ACZ,ANS_STATE_SEGEND0
	CALL	INT_BIOS_START
	
	RET
ANS_STATE_SEGEND0:
	CALL	INIT_DAM_FUNC
	LACL	CVP_STOP		;通知系统播放完毕
	CALL	STOR_MSG
	
	RET
;---------------------------------------
ANS_STATE_SER:
	CALL	GETR_DAT
	ANDL	0XFF
	SAH	MSG
;-------------------
	LAC	MSG
	SBHK	0X4A
	BS	ACZ,ANS_STATE_SER_0X4A	;(0X4A)vol
;---
	LAC	MSG
	SBHK	0X5A
	BS	ACZ,ANS_STATE_SER_0X5A	;(0X5A)stop
	SBHK	0X04
	BS	ACZ,ANS_STATE_SER_0X5E	;(0X5E)Phone on/off
	SBHK	0X02
	BS	ACZ,ANS_STATE_SER_0X60	;(0X60)Handset on/off
	
	RET
;---------------------------------------
ANS_STATE_SER_0X4A:		;set Volume
	LAC	VOI_ATT
	ANDL	0XFFF0
	SAH	VOI_ATT
	
	CALL	GETR_DAT
	ANDK	0X000F
	OR	VOI_ATT
	SAH	VOI_ATT

	LAC	CODECREG2
	ANDL	0XFFE0
	SAH	CODECREG2
	
	LAC	VOI_ATT
	ANDK	0X07
	ADHL	VOL_TAB
	CALL    GetOneConst
        OR	CODECREG2
        SAH	CODECREG2
	
	LIPK    6
	OUT	CODECREG2,LOUTSPK
	ADHK	0

	RET
;-----------------------------
ANS_STATE_SER_0X5A:	;Stop(Same as CPC)
	LACL	CMSG_CPC
	CALL	STOR_MSG
	
	RET
;-----------------------------
ANS_STATE_SER_0X5E:
	CALL	GETR_DAT
	ANDL	0X0FF
	BS	ACZ,ANS_STATE_SER_0X5E0X00
	SBHK	1
	BS	ACZ,ANS_STATE_SER_0X5E0X01
	
	RET
;---------
ANS_STATE_SER_0X5E0X00:
	LACL	CMSG_CPC
	CALL	STOR_MSG

	LACL	CPHONE_OFF	;speaker phone mode
	CALL	STOR_MSG

	RET
;---------	
ANS_STATE_SER_0X5E0X01:
ANS_STATE_HFREE:
	LACL	CMSG_CPC
	CALL	STOR_MSG

	LACL	CPHONE_ON	;speaker phone mode
	CALL	STOR_MSG
	
	RET
;---------------------------------------
ANS_STATE_SER_0X60:
	CALL	GETR_DAT
	ANDL	0X0FF
	BS	ACZ,ANS_STATE_SER_0X600X00
	SBHK	1
	BS	ACZ,ANS_STATE_SER_0X600X01
	
	RET
ANS_STATE_SER_0X600X00:
	LACL	CMSG_CPC
	CALL	STOR_MSG
	
	LACL	CHOOK_ON	;put down the handset to on hook for end a call
	CALL	STOR_MSG
	
	RET
ANS_STATE_SER_0X600X01:
ANS_STATE_HSETOFF:
	LACL	CMSG_CPC
	CALL	STOR_MSG
	
	LACL	CHOOK_OFF	;pickup the handset to off hook in handset mode
	CALL	STOR_MSG
	
	RET
;-------------------------------------------------------------------------------
ANS_STATE0:
	LAC	MSG
	XORL	CMSG_INIT		;INITIAL
	BS	ACZ,ANS_STATE_INIT
;ANS_STATE0_1:	
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,ANS_STATE0_VPSTOP	;CVP_STOP,OGM播放完毕
;ANS_STATE0_2:
	LAC	MSG
	XORL	CREV_DTMF		;DTMF detect
	BS	ACZ,ANS_STATE0_DTMF
;ANS_STATE0_3:
	LAC	MSG
	XORL	CMSG_TMR		;TMR
	BS	ACZ,ANS_STATE0_TMR
;ANS_STATE0_4:	
	LAC	MSG
	XORL	CMSG_CPC		;接线后摘机(相当于CPC)
	BS	ACZ,ANS_STATE0_CPC
;ANS_STATE0_5:

	RET
;---------------
ANS_STATE0_TMR:
	;LAC	PRO_VAR1
	;ADHK	1
	;SAH	PRO_VAR1
	
	CALL	BCVOX_INIT

	
	RET
;---------------
ANS_STATE_INIT:
	CALL	INIT_DAM_FUNC
;-------
	LACL	FlashLoc_H_fs_cpc
	ADLL	FlashLoc_L_fs_cpc
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_fs_cpc
	ADLL	CodeSize_fs_cpc
	CALL	LoadHostCode
;-------
	

	CALL	CIDTALK_L	;Unmute CIDTALK
	CALL	HOOK_OFF	;摘机
	CALL	DAA_ANS_SPK

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	0X2C		;line seize
	CALL	SEND_DAT
	LACK	0X2C
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	0X2A		;Tell MCU OGM to line
	CALL	SEND_DAT
	LACK	0X2A
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	CALL	SET_COMPS

	LACL	CMODE9|(1<<3)	;Line-on
	CALL	DAM_BIOSFUNC

	LACL	1000
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1
	SAH	MSGLED_FG	;MsgLED on

	LACL	0X0FFF		;!!!Note PSWORD_TMP(15..12)是计数器
	SAH	PSWORD_TMP
;---------------Set DTMF play 	
	LACK	CDTMF_DETP
	CALL	SET_DTMFTYPE	;0/1 = for normal/CID mode

	BIT	ANN_FG,13		;memoful?
	BS	TB,ANS_STATE_INIT4
	BIT	EVENT,9			;answer off?
	BS	TB,ANS_STATE_INIT2

;---可以录音---OGM1

	LACK	0X0010
	SAH	PRO_VAR

	CALL	OGM_STATUS

	LACK	0X07D
	CALL	STOR_VP			;延时1 second
	LAC	MSG_ID
	ORL	0XFE00
	CALL	STOR_VP
	CALL	LBEEP

	CALL	OGM_SELECT
	BZ	ACZ,ANS_STATE_INIT1_1
	
	CALL	INIT_DAM_FUNC
	LACK	0X07D
	CALL	STOR_VP			;延时1 second
	CALL	VP_DefOGM
	CALL	LBEEP

ANS_STATE_INIT1_1:
	RET
;---Answer off---
ANS_STATE_INIT2:

	LACK	0X0020
	SAH	PRO_VAR

	CALL	INIT_DAM_FUNC
	LACK	0X037
	CALL	STOR_VP		;延时300ms second
	
	CALL	VP_AnswerOff
	;CALL	VP_YouCannotLeaveAMsg	;;!!!Give up it
	LACL	0X00FA
	CALL	STOR_VP		;延时2.0 second
	CALL	BBBEEP

	RET
;---------------------------------------
ANS_STATE_INIT4:		;full

	LACK	0X0020
	SAH	PRO_VAR

	CALL	INIT_DAM_FUNC
	LACK	0X03E
	CALL	STOR_VP		;延时0.5 second
	CALL	VP_MemoryIsFull
	;CALL	VP_YouCannotLeaveAMsg	;!!!Give up it
	LACL	0X00FA
	CALL	STOR_VP		;延时2.0 second
	CALL	BBBEEP
	
	RET
;---------------------------------------
ANS_STATE0_VPSTOP:		;开始录音(ICM)/ON_LINE(only)
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_REC
	CALL	BCVOX_INIT
;---------------Set DTMF play 	
	LACK	CDTMF_DETR
	CALL	SET_DTMFTYPE	
	
	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER
;---	
	LAC	PRO_VAR
	SFR	4
	ANDK	0XF
	SBHK	1
	BS	ACZ,ANS_STATE0_VPSTOP1
	SBHK	1
	BS	ACZ,ANS_STATE0_VPSTOP2
	
	RET
;---PRO_VAR = 0X0010
ANS_STATE0_VPSTOP1:
	LACK	0X0001
	SAH	PRO_VAR

	CALL	VPMSG_CHK

	LAC	TMR_YEAR
	CALL	SET_USR1ID
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	2		;ICM record start
	CALL	SEND_RECSTART
		
	LACK	30
	CALL	DELAY
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0xD700|CRVOX_LEVEL
	CALL	DAM_BIOSFUNC
	LACL	0x7700|CRSILENCE_LEVEL
	CALL	DAM_BIOSFUNC

	CALL	REC_START

	RET
ANS_STATE0_VPSTOP2:	
	LACK	0X0002
	SAH	PRO_VAR

	LACL	0xD700|CRVOX_LEVEL
	CALL	DAM_BIOSFUNC
	LACL	0x7700|CRSILENCE_LEVEL
	CALL	DAM_BIOSFUNC
	
	CALL	LINE_START
	
	RET
;---------------for DTMF
ANS_STATE0_DTMF:
	LAC	DTMF_VAL
	XORL	0XFE
	BZ	ACZ,ANS_STATE_DTMF
;---放OGM时,有"*"键按下
	LACK	0X0020
	SAH	PRO_VAR

	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_SPK

	LACK	0X040
	CALL	STOR_VP		;延时0.5 second

	RET

ANS_STATE_LINE_DTMF:		;Line Mode
	LACK	0
	SAH	PRO_VAR1	

ANS_STATE_DTMF:			;比较密码
	CALL	BCVOX_INIT	;有键按下BCVOX要清零

	LAC	DTMF_VAL
	ANDK	0X0F
	CALL	PSWORD_CHK
	SAH	SYSTMP1
	SBHK	0X30
	BS	ACZ,ANS_STATE_DTMF_PASS	;次数到3,并且PASSWORD匹配成功
	SBHK	0X30
	BS	ACZ,ANS_STATE_DTMF_PASS	;次数到6,并且PASSWORD匹配成功
	SBHK	0X30
	BS	ACZ,ANS_STATE_DTMF_PASS	;次数到9,并且PASSWORD匹配成功
;---匹配不成功
	LAC	SYSTMP1
	ANDL	0XF0
	SBHK	0X30
	BS	ACZ,ANS_STATE_DTMF_NOPASS	;次数到3,并且PASSWORD匹配不成功
	SBHK	0X30
	BS	ACZ,ANS_STATE_DTMF_NOPASS	;次数到6,并且PASSWORD匹配不成功
	SBHK	0X30
	BS	ACZ,ANS_STATE_DTMF_FAIL		;次数到9,并且PASSWORD匹配不成功
	
	RET
ANS_STATE_DTMF_NOPASS:

	LACK	0X0020
	SAH	PRO_VAR

	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_SPK
	CALL	BBBEEP

	RET
ANS_STATE_DTMF_FAIL:
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_SPK
	CALL	BBEEP
	
	LACK	0X003
	SAH	PRO_VAR
	
	RET
;---------------------------------------
ANS_STATE_DTMF_PASS:		;密码成功
	
ICM_REV_DTMF_YES1:	
	CALL	INIT_DAM_FUNC
	;CALL	DAA_ANS_REC
	
	CALL	CLR_FUNC
   	LACL	LOCAL_PRO	;goto local mode
     	CALL	PUSH_FUNC
     	LACK	0
     	SAH	PRO_VAR

	LACL	CRMOT_OK
	CALL	STOR_MSG

	RET
;-------

;=============================================================
ANS_STATE_REC:
	LAC	MSG
	XORL	CREV_DTMF		;DTMF detect
	BS	ACZ,ANS_STATE_REC_DTMF
;ANS_STATE_REC_1:
	LAC	MSG
	XORL	CMSG_TMR		;TMR 1s
	BS	ACZ,ANS_STATE_REC_TMR
;ANS_STATE_REC_2:
	LAC	MSG
	XORL	CMSG_VOX		;VOX_ON 7s
	BS	ACZ,ANS_STATE_REC_VOX
;ANS_STATE_REC_3:
	LAC	MSG
	XORL	CMSG_CTONE		;CTONE 7s
	BS	ACZ,ANS_STATE_REC_CTONE
;ANS_STATE_REC_4:
	LAC	MSG
	XORL	CMSG_BTONE		;BTONE xs
	BS	ACZ,ANS_STATE_REC_BTONE
;ANS_STATE_REC_5:
	LAC	MSG
	XORL	CREC_FULL		;REC_FULL
	BS	ACZ,ANS_STATE_REC_FULL
;ANS_STATE_REC_6:
	LAC	MSG
	XORL	CMSG_CPC		;接线后摘机(相当于CPC)
	BS	ACZ,ANS_STATE_REC_CPC
	
;ANS_STATE_REC_7:
	RET
	
;---------------------------------------
ANS_STATE_REC_DTMF:
	CALL	BCVOX_INIT	;有键按下BCVOX要清零

	LAC	DTMF_VAL
	ANDK	0X0F
	CALL	PSWORD_CHK
	SAH	SYSTMP1
	SBHK	0X30
	BS	ACZ,ANS_STATE_REC_DTMF_PASS	;次数到3,并且PASSWORD匹配成功
	SBHK	0X30
	BS	ACZ,ANS_STATE_REC_DTMF_PASS	;次数到6,并且PASSWORD匹配成功
	SBHK	0X30
	BS	ACZ,ANS_STATE_REC_DTMF_PASS	;次数到9,并且PASSWORD匹配成功
;---匹配不成功
	LAC	SYSTMP1
	ANDL	0XF0
	SBHK	0X30
	BS	ACZ,ANS_STATE_REC_DTMF_NOPASS	;次数到3,并且PASSWORD匹配不成功
	SBHK	0X30
	BS	ACZ,ANS_STATE_REC_DTMF_NOPASS	;次数到6,并且PASSWORD匹配不成功
	SBHK	0X30
	BS	ACZ,ANS_STATE_DTMF_FAIL		;次数到9,并且PASSWORD匹配不成功
	
	RET
;---------------------------------------
ANS_STATE_REC_DTMF_NOPASS:
	CALL	DAA_ANS_SPK
	LAC	CONF
	ORL	1<<7
	CALL	DAM_BIOSFUNC	;Recording pause
	
	CALL	WBEEP		;BBBEEP
	
	CALL	DAA_ANS_REC
	LAC	CONF
	ANDL	~(1<<7)
	CALL	DAM_BIOSFUNC	;Recording pause

	RET
;---------------------------------------
ANS_STATE_REC_DTMF_PASS:
	LAC	CONF
	ORL	1<<11
	CALL	DAM_BIOSFUNC	;若是录音过程,则删除之
	
	BS	B1,ICM_REV_DTMF_YES1
ANS_STATE_REC_DTMF_FIAL:
	
	LAC	CONF
	ORL	1<<11
	CALL	DAM_BIOSFUNC	;PASSWORD匹配不成功,删除录音
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_SPK
	CALL	VP_EndOf
	CALL	VP_Call
	CALL	BBEEP
	
	CALL	GC_CHK

	CALL	VPMSG_CHK
	
	LACK	0X0003
	SAH	PRO_VAR
	
	RET
;---------------------------------------
ANS_STATE_REC_CPC:		;录音时
	LAC	PRO_VAR1
	SBHK	2
	BZ	SGN,ANS_STATE_REC_CPC1
	
	LAC	CONF
	ORL	1<<11
	SAH	CONF
	CALL	DAM_BIOSFUNC
ANS_STATE_REC_CPC1:	
	CALL	INIT_DAM_FUNC
	CALL	GC_CHK

	LACK	0X005
	CALL	STOR_VP
	
	LACK	0X0003
	SAH	PRO_VAR

	RET

;---------------------------------------
ANS_STATE_REC_VOX:		;由于后BTONE,CTONE,VOX要持续一段时间,要考虑小长度的录音删除问题
ANS_STATE_REC_CTONE:
	LAC	CONF
	ORK	17
	SAH	CONF		;切除静音/TONE声
ANS_STATE_REC_BTONE:
	CALL	INIT_DAM_FUNC
	CALL	VPMSG_CHK
	LAC	MSG_T
	CALL	GET_VPTLEN
	SBHK	3
	BZ	SGN,ANS_STATE_BTONE_DET
;---删除比3s短的录音
	LAC	MSG_T
	ORL	0X6000		;delete
	CALL	DAM_BIOSFUNC
	CALL	GC_CHK
ANS_STATE_BTONE_DET:
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_SPK		;???????????????????
	CALL	BBEEP		;替换语音BB

	LACK	0X0003
	SAH	PRO_VAR

	RET

;---------------------------------------
ANS_STATE_REC_TMR:
	LAC	PRO_VAR1	;
	ADHK	1
	SAH	PRO_VAR1

	SBHL	CICM_LEN	;ICM录音时长
	BZ	SGN,ICM_TMR_DET_END

	RET

ICM_TMR_DET_END:	
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_SPK
	CALL	BBEEP
	
	LACK	0X0003
	SAH	PRO_VAR

	RET
;-------
ANS_STATE_REC_FULL:		;录满退出
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_SPK
	CALL	VP_MemoryIsFull
	CALL	BBEEP
	CALL	SEND_MFULL	;!!!
	LACK	0X0003
	SAH	PRO_VAR
	
	CALL	VPMSG_CHK

	RET

;=================================================================
ANS_STATE_EXIT:
	LAC	MSG
	XORL	CVP_STOP		
	BS	ACZ,ANS_STATE_EXIT_END	;CVP_STOP,EXIT播放完毕
	
	RET
ANS_STATE_EXIT_END:		;exit answer mode
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	CALL	HOOK_IDLE	;hook idle

	CALL	CLR_FUNC
   	LACL	LOCAL_PRO	;goto local mode
     	CALL	PUSH_FUNC
	
	LACL	CMODE9
	CALL	DAM_BIOSFUNC
	
	CALL	VPMSG_CHK

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;-check memoryfull
	LACK	0X26
	CALL	SEND_DAT
	LAC	ANN_FG
	SFR	13
	ANDK	0X01
	CALL	SEND_DAT
;-new message number
	LACK	0X20
	CALL	SEND_DAT
	LAC	MSG_N
	CALL	SEND_DAT
;-total message number
	LACK	0X21
	CALL	SEND_DAT
	LAC	MSG_T
	CALL	SEND_DAT
	CALL	EXIT_TOIDLE
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	MSGLED_IDLE

	LACK	0
	SAH	PRO_VAR
	
;-!!!
	;CALL	MSGLED_H
	

	RET
;========================================================================
ANS_STATE_LINE:		;off/full
	LAC	MSG
	XORL	CREV_DTMF		;DTMF detect
	BS	ACZ,ANS_STATE_LINE_DTMF
;ANS_STATE_LINE_1:
	LAC	MSG
	XORL	CMSG_TMR		;time 1s
	BS	ACZ,ANS_STATE_LINE_TMR
;ANS_STATE_LINE_2:
	LAC	MSG
	XORL	CMSG_BTONE		;BTONE 8s
	BS	ACZ,ANS_STATE_BTONE_DET
;ANS_STATE_LINE_3:
	LAC	MSG
	XORL	CMSG_CPC		;接线后摘机(相当于CPC)
	BS	ACZ,ANS_STATE_LINE_CPC
;ANS_STATE_LINE_4:
	RET
;---------------
ANS_STATE_LINE_TMR:		;for memful/answer only/answer off

	LACL	CTMR_CTONE
	SAH	TMR_VOX
	SAH	TMR_CTONE

	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	20		;20s wait for PASSWORD
	BZ	SGN,ANS_STATE_LINE_TMR_END
	
	RET
;---
ANS_STATE_LINE_TMR_END:	
	LACK	0X0003
	SAH	PRO_VAR
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_SPK
	CALL	BBEEP	;替换语音BB

	RET
;-------------------------------------------------------------------------------
;###############################################################################
;----------------------------------------------------------------------------
;       Function : PSWORD_CHK
;       Password check
;	Input  : ACCH = VALUE(DTMF_VAL)
;       Output : ACCH = x0 - password in ok(x = the count of key DTMF)
;                       xF - password fail
;-------------------------------------------------------------------------------
PSWORD_CHK:
        SAH	SYSTMP0
PSWORD_CHK1:
;---先把计数器PSWORD_TMP(15..12)加1后放到PSWORD_TMP(11..8)
	LAC     PSWORD_TMP
	ANDL	0XF0FF
        SAH     PSWORD_TMP
	
	LAC     PSWORD_TMP
	SFR	4
	ANDL	0X0F00
	ADHL	0X0100
	OR	PSWORD_TMP
	SAH	PSWORD_TMP
;---	
        LAC     PSWORD_TMP
        SFL     4
	OR	SYSTMP0
        SAH     PSWORD_TMP        ; PSWORD_TMP keep the new input digit string
;-------------------------------------------------------------------------------
        LAC     PSWORD_TMP
        XOR     PASSWORD
        ANDL	0X0FFF
        BS      ACZ,PSWORD_IN_OK
;---
PSWORD_NOT_IN:		;the intput not digital or wrong remote access code
	LAC	PSWORD_TMP
	SFR	8
	ANDL	0XF0
	ORK	0X0F
	
        RET	
PSWORD_IN_OK:
	LAC	PSWORD_TMP
	SFR	8
	ANDL	0XF0
	
        RET
;-------------------------------------------------------------------------------
;############################################################################
;	FUNCTION : GET_VPTLEN
;	INPUT : ACCH = MSG_ID
;	OUTPUT: ACCH = RECORD LENGTH
;############################################################################
GET_VPTLEN:
	ANDK	0X7F
	ORL	0XA400
	CALL	DAM_BIOSFUNC

	RET

;-------------------------------------------------------------------------------
.INCLUDE	l_beep/l_beep.asm
.INCLUDE	l_beep/l_bbeep.asm
.INCLUDE	l_beep/l_bbbeep.asm
.INCLUDE	l_beep/l_lbeep.asm
.INCLUDE	l_beep/l_wbeep.asm

.INCLUDE	l_CodecPath/l_allopen.asm
.INCLUDE	l_CodecPath/l_ansply.asm
.INCLUDE	l_CodecPath/l_ansrec.asm

.INCLUDE	l_flashmsg/l_biosfull.asm
.INCLUDE	l_flashmsg/l_flashmsg.asm
.INCLUDE	l_flashmsg/l_flashogm.asm

.INCLUDE	l_rec/l_compress.asm
.INCLUDE	l_rec/l_rec.asm

.INCLUDE	l_iic/l_storsqueue.asm
.INCLUDE	l_iic/l_getrqueue.asm
.INCLUDE	l_iic/l_flashfull.asm
.INCLUDE	l_iic/l_exit.asm
.INCLUDE	l_iic/l_rec.asm

.INCLUDE	l_line.asm

.INCLUDE	l_port/l_cidtalk.asm
.INCLUDE	l_port/l_hookidle.asm
.INCLUDE	l_port/l_hookoff.asm
.INCLUDE	l_port/l_hookon.asm
.INCLUDE	l_port/l_hwalc.asm
.INCLUDE	l_port/l_msgled.asm
.INCLUDE	l_port/l_spkctl.asm

.INCLUDE	l_respond/l_btone.asm
.INCLUDE	l_respond/l_ctone.asm
.INCLUDE	l_respond/l_vox.asm
.INCLUDE	l_respond/l_dtmf.asm
.INCLUDE	l_respond/l_ansrmt_resp.asm
.INCLUDE	l_respond/l_vpqueue.asm

.INCLUDE	l_table/l_voltable.asm
.INCLUDE	l_table/l_dtmftable.asm

.INCLUDE	l_voice/l_answeroff.asm
.INCLUDE	l_voice/l_call.asm
.INCLUDE	l_voice/l_defogm.asm
.INCLUDE	l_voice/l_endof.asm
.INCLUDE	l_voice/l_memfull.asm
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
.END
