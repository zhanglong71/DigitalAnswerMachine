;-------------------------------------------------------------------------------
.NOLIST
;---------------------------------------
.INCLUDE	include.inc
;---------------------------------------
.GLOBAL	ANS_STATE
.EXTERN	SYS_MSG_RMT
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
ANS_STATE_MSG:
	LAC	MSG
	XORL	CHF_WORK
	BS	ACZ,ANS_STATE_HFREE
	LAC	MSG
	XORL	CHS_WORK
	BS	ACZ,ANS_STATE_HSETOFF
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
	BS	ACZ,ANS_STATE_EXIT	;for end(TimeOut/BTONE/CTONE/VOX_ON)
	
ANS_STATE_END:
	RET
;---------------------------------------	
ANS_STATE_CPC:
	BS	B1,ANS_STATE_EXIT_VPSTOP
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

	CALL	SET_SPKVOL
	MSET_UPDATE_FG		;volum set

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

	LACL	CHF_IDLE	;speaker phone mode
	CALL	STOR_MSG

	RET
;---------	
ANS_STATE_SER_0X5E0X01:
ANS_STATE_HFREE:
	LACL	CMSG_CPC
	CALL	STOR_MSG

	LACL	CHF_WORK	;speaker phone mode
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
	
	LACL	CHS_IDLE	;put down the handset to on hook for end a call
	CALL	STOR_MSG
	
	RET
ANS_STATE_SER_0X600X01:
ANS_STATE_HSETOFF:
	LACL	CMSG_CPC
	CALL	STOR_MSG
	
	LACL	CHS_WORK	;pickup the handset to off hook in handset mode
	CALL	STOR_MSG
	
	RET	
;=============================================================
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
	XORL	CREV_DTMF		;CREV_DTMF
	BS	ACZ,ANS_STATE_LINE_DTMF
;ANS_STATE0_3:
	LAC	MSG
	XORL	CREV_DTMFS		;DTMF START
	BS	ACZ,ANS_STATE_DTMFS
;ANS_STATE0_4:
	LAC	MSG
	XORL	CMSG_2TMR		;TMR2
	BS	ACZ,ANS_STATE_TMR2
;ANS_STATE0_5:	
	LAC	MSG
	XORL	CMSG_CPC		;接线后摘机(相当于CPC)
	BS	ACZ,ANS_STATE_CPC

	RET
;---
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
	CALL	HOOK_OFF	;摘机
	CALL	DAA_ANS_SPK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	;LACK	CMDT_LineSeize		;line seize
	;CALL	SEND_DAT
	;LACK	CMDT_LineSeize
	;CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	CMDT_StartAnswer		;Tell MCU OGM to line
	CALL	SEND_DAT
	LACK	CMDT_StartAnswer
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	CALL	SET_COMPS

	LACL	CMODE9|(1<<3)	;Line-on
	CALL	DAM_BIOSFUNC

	LACL	CTMR1S
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1
	SAH	MSGLED_FG	;MsgLED on

	LACL	0XFFFF
	SAH	PSWORD_TMP
	
	BIT	EVENT,9		;answer off?
	BS	TB,ANS_STATE_INIT3
	BIT	ANN_FG,13	;memoful?
	BS	TB,ANS_STATE_INIT4
	BIT	EVENT,8		;answer only?
	BS	TB,ANS_STATE_INIT2

;---可以录音---OGM1
	LACK	0X0010
	SAH	PRO_VAR

	CALL	OGM_STATUS

	LACK	0X07D
	CALL	STOR_VP		;延时1 second
	LAC	MSG_ID
	ORL	0XFE00
	CALL	STOR_VP
	CALL	LBEEP

	CALL	OGM_SELECT
	BZ	ACZ,ANS_STATE_INIT1
	
	CALL	INIT_DAM_FUNC
	LACK	0X07D
	CALL	STOR_VP		;延时1 second
	CALL	VP_DefOGM
	CALL	LBEEP

ANS_STATE_INIT1:
	RET
;---不能录音---OGM2
ANS_STATE_INIT2:
	LACK	0X0020
	SAH	PRO_VAR

	CALL	OGM_STATUS

	LACK	0X07D
	CALL	STOR_VP		;延时1 second
	LAC	MSG_ID
	ORL	0XFE00
	CALL	STOR_VP
	CALL	BEEP

	CALL	OGM_STATUS
	BZ	ACZ,ANS_STATE_INIT2_1
	
	CALL	INIT_DAM_FUNC
	LACK	0X07D
	CALL	STOR_VP		;延时1 second
	CALL	VP_DefOGM
	CALL	BEEP
ANS_STATE_INIT2_1:	
	RET
;---------------------------------------
ANS_STATE_INIT3:		;off
	LACK	0X0020
	SAH	PRO_VAR

	CALL	OGM_STATUS

	LACK	0X07D
	CALL	STOR_VP		;延时1 second
	LAC	MSG_ID
	ORL	0XFE00
	CALL	STOR_VP
	CALL	LLBEEP

	CALL	OGM_STATUS
	BZ	ACZ,ANS_STATE_INIT3_1
	
	CALL	INIT_DAM_FUNC
	LACK	0X07D
	CALL	STOR_VP		;延时1 second
	CALL	LLBEEP		;3s
ANS_STATE_INIT3_1:
	
	RET
ANS_STATE_INIT4:		;full
	LACK	0X0020
	SAH	PRO_VAR

	CALL	OGM_STATUS

	LACK	0X07D
	CALL	STOR_VP		;延时1 second
	LAC	MSG_ID
	ORL	0XFE00
	CALL	STOR_VP
	CALL	BEEP
	CALL	BEEP
	CALL	BEEP

	CALL	OGM_STATUS
	BZ	ACZ,ANS_STATE_INIT4_1
	
	CALL	INIT_DAM_FUNC
	LACK	0X07D
	CALL	STOR_VP		;延时1 second
	CALL	BEEP
	CALL	BEEP
	CALL	BEEP
ANS_STATE_INIT4_1:
	
	RET
;---------------------------------------
ANS_STATE0_VPSTOP:			;开始录音/监听(ICM)/ON_LINE(only)
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_REC
	CALL	BCVOX_INIT

	LACK	0
	SAH	PRO_VAR1
	LACL	CTMR1S
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
;---------------------------------------
;-PRO_VAR = 0X0010
ANS_STATE0_VPSTOP1:

	LACK	0X0001
	SAH	PRO_VAR
	
	CALL	VPMSG_CHK
	CALL	REC_START

	RET
;---------------------------------------
ANS_STATE0_VPSTOP2:
	LACK	0X0002
	SAH	PRO_VAR

	CALL	LINE_START
	
	RET
;---------------for DTMF
;---------------------------------------
ANS_STATE_LINE_DTMF:	;Line Mode
	LACK	0
	SAH	PRO_VAR1	;有按键计时清零(仅ANS ONLY时)

	CALL	PAUBEEP	;???????????????????????????????????????????????????????

ANS_STATE_REC_DTMF:	;Record Mode,Can't clean record time	;比较密码
	CALL	BCVOX_INIT	;有键按下BCVOX要清零
	
	CALL	CLR_TIMER2	;只要有DTMF检测到就清该时钟
	
	LAC	DTMF_VAL
	ANDK	0X0F
	CALL	PSWORD_CHK
	BS	ACZ,ANS_STATE_DTMF_PASS

	RET
;---------------------------------------
ANS_STATE_DTMF_PASS:		;密码成功
	LAC	COMMAND
	SFR	12
	SBHK	1
	BZ	ACZ,ANS_STATE_DTMF_PASS1

	LAC	COMMAND
	ORL	1<<11
	CALL	DAM_BIOSFUNC	;若是录音过程,则删除之
ANS_STATE_DTMF_PASS1:	
	CALL	INIT_DAM_FUNC
.if	1	
	BS	B1,SYS_MSG_RMT
.else	
	CALL	CLR_FUNC
   	LACL	LOCAL_PRO	;goto local mode
     	CALL	PUSH_FUNC
     	LACK	0
     	SAH	PRO_VAR
     		
	LACL	CRMOT_OK
	CALL	STOR_MSG

	RET
.endif
;---------------------------------------
ANS_STATE_TMR2:			;进入答录时收到长按"*"
	LAC	DTMF_VAL
	XORL	0XFE
	BS	ACZ,ANS_STATE_TMR2_DTMFEND	;"*"
;ANS_STATE_DTMFTMR_NO:
	RET
;---
ANS_STATE_TMR2_DTMFEND:
	LAC	COMMAND
	SFR	12
	SBHK	1
	BZ	ACZ,ANS_STATE_DTMFTMR1
	
	LAC	COMMAND
	ORL	1<<11
	CALL	DAM_BIOSFUNC	;若是录音过程,则删除之

ANS_STATE_DTMFTMR1:
	CALL	CLR_TIMER2
	BS	B1,ANS_STATE_EXIT_VPSTOP
;-------------------------------------------------------------------------------
ANS_STATE_REC:
	LAC	MSG
	XORL	CREV_DTMF		;CREV_DTMF
	BS	ACZ,ANS_STATE_REC_DTMF
;ANS_STATE_REC_1:
	LAC	MSG
	XORL	CMSG_TMR		;time 1s
	BS	ACZ,ANS_STATE_REC_TMR
;ANS_STATE_REC_2:
	LAC	MSG
	XORL	CMSG_VOX		;VOX_ON 8s
	BS	ACZ,ANS_STATE_REC_VOX
;ANS_STATE_REC_3:
	LAC	MSG
	XORL	CMSG_CTONE		;CTONE 8s
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
	XORL	CVP_STOP		;PLAY END
	BS	ACZ,ANS_STATE_REC_EVP
;ANS_STATE_REC_7:
	LAC	MSG
	XORL	CREV_DTMFS		;DTMF START
	BS	ACZ,ANS_STATE_DTMFS
;ANS_STATE_REC_8:
	LAC	MSG
	XORL	CMSG_2TMR		;TMR2
	BS	ACZ,ANS_STATE_TMR2
;ANS_STATE_REC_9:	
	LAC	MSG
	XORL	CMSG_CPC		;接线后摘机(相当于CPC)
	BS	ACZ,ANS_STATE_REC_CPC
	
	RET
;---------------------------------------
ANS_STATE_DTMFS:
	LAC	DTMF_VAL
	XORL	0XFE
	BS	ACZ,ANS_STATE_DTMFS_STAR	;是"*"吗?
	
	RET
ANS_STATE_DTMFS_STAR:
	LACL	1600
	CALL	SET_TIMER2	;1.6s定时
	
	RET		
;---------------------------------------
ANS_STATE_REC_CPC:		;录音时
	LAC	PRO_VAR1
	SBHK	2
	BZ	SGN,ANS_STATE_REC_CPC1
	
	LAC	COMMAND
	ORL	1<<11
	SAH	COMMAND
	CALL	DAM_BIOSFUNC
ANS_STATE_REC_CPC1:	
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACK	0X005
	CALL	STOR_VP

	CALL	VPMSG_CHK
	
	LACK	0X0003
	SAH	PRO_VAR

	RET

;---------------------------------------
ANS_STATE_REC_VOX:		;由于后BTONE,CTONE,VOX要持续一段时间,要考虑小长度的录音删除问题
ANS_STATE_REC_CTONE:
	LAC	COMMAND
	ORK	20
	SAH	COMMAND		;切除静音/TONE声
ANS_STATE_REC_BTONE:
	CALL	INIT_DAM_FUNC
	CALL	VPMSG_CHK
	
	LAC	MSG_T
	ORL	0XA400
	CALL	DAM_BIOSFUNC
	SBHK	3
	BZ	SGN,ANS_STATE_REC_BTONE_DET
;---删除比3s短的录音
	LAC	MSG_T
	ORL	0X6000
	CALL	DAM_BIOSFUNC
	CALL	GC_CHK
ANS_STATE_REC_BTONE_DET:
	CALL	INIT_DAM_FUNC
	CALL	VPMSG_CHK
;---
	LACK	0X0003
	SAH	PRO_VAR
	
	CALL	DAA_SPK		;???????????????????
	CALL	BBEEP		;替换语音BB

	RET

;---------------------------------------
ANS_STATE_REC_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	
	SBHK	120			;ICM录音时长2分钟
	;SBHK	CICM_LEN		;ICM录音时长
	BS	SGN,ANS_STATE_REC_TMR_END
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_SPK
	CALL	BBEEP
	
	LACK	0X0003
	SAH	PRO_VAR

ANS_STATE_REC_TMR_END:
	RET
;---------------------------------------
ANS_STATE_REC_FULL:			;录满退出
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_SPK
	CALL	BBEEP
	
	LACK	0X0003
	SAH	PRO_VAR
	
	RET
;---------------------------------------
ANS_STATE_REC_EVP:
	LACK	0
	SAH	PRO_VAR1
	CALL	INIT_DAM_FUNC
	CALL	LINE_START
	
	RET
;-------------------------------------------------------------------------------
ANS_STATE_LINE:
	LAC	MSG
	XORL	CREV_DTMF		;CREV_DTMF
	BS	ACZ,ANS_STATE_LINE_DTMF
	LAC	MSG
	XORL	CMSG_TMR		;time 1s
	BS	ACZ,ANS_STATE_LINE_TMR
	LAC	MSG
	XORL	CREV_DTMFS		;DTMF START
	BS	ACZ,ANS_STATE_DTMFS
	LAC	MSG
	XORL	CMSG_BTONE		;BTONE 8s
	BS	ACZ,ANS_STATE_REC_BTONE_DET
	LAC	MSG
	XORL	CMSG_2TMR		;CDTMF_TMR(长)
	BS	ACZ,ANS_STATE_TMR2
	LAC	MSG
	XORL	CMSG_CPC		;接线后摘机(相当于CPC)
	BS	ACZ,ANS_STATE_CPC

	RET
;---------------------------------------
ANS_STATE_LINE_TMR:		;for memful/answer only/answer off
	LACL	CTMR_CTONE
	SAH	TMR_VOX
	SAH	TMR_CTONE

	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	20
	BS	SGN,LINE_TMR_DET_END

	LACK	0X0003
	SAH	PRO_VAR
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_SPK
	CALL	BBEEP	;替换语音BB

LINE_TMR_DET_END:
	RET
;-------------------------------------------------------------------------------
ANS_STATE_EXIT:
	LAC	MSG
	XORL	CVP_STOP		
	BS	ACZ,ANS_STATE_EXIT_VPSTOP	;CVP_STOP,EXIT播放完毕
	
	RET
ANS_STATE_EXIT_VPSTOP:		;exit answer mode
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	CALL	HOOK_ON

	CALL	CLR_FUNC
   	LACL	LOCAL_PRO	;goto local mode
     	CALL	PUSH_FUNC
	
	LACL	CMODE9
	CALL	DAM_BIOSFUNC
	
	CALL	VPMSG_CHK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	SEND_MSGNUM
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
	LACL	CMSG_INIT
	CALL	STOR_MSG

	CALL	MSGLED_IDLE

	LACK	0
	SAH	PRO_VAR
	
;-!!!
	RET
;-------------------------------------------------------------------------------
;###############################################################################
;----------------------------------------------------------------------------
;       Function : PSWORD_CHK
;       Password check
;	Input  : ACCH = VALUE(DTMF_VAL)
;       Output : ACCH = 0 - password in ok
;                       1 - password for mailbox 1
;                       2 - password for mailbox 2
;                       3 - password for mailbox 3
;                       0XFF - password fail
;-------------------------------------------------------------------------------
PSWORD_CHK:
        SAH	SYSTMP0
PSWORD_CHK1:
        LAC     PSWORD_TMP
        SFL     4
	OR	SYSTMP0
        SAH     PSWORD_TMP        ; PSWORD_TMP keep the new input digit string
;-------------------------------------------------------------------------------
        LAC     PSWORD_TMP
        SBH     PASSWORD
        ANDL	0X0FFF
        BS      ACZ,PSWORD_IN_OK
;---
PSWORD_NOT_IN:		;the intput not digital or wrong remote access code
        LACL    0XFF
        RET	
PSWORD_IN_OK:
	LACK	0
        RET

;-------------------------------------------------------------------------------
.INCLUDE	l_beep/l_bbbeep.asm
.INCLUDE	l_beep/l_lbeep.asm
.INCLUDE	l_beep/l_llbeep.asm
.INCLUDE	l_beep/l_wbeep.asm
.INCLUDE	l_beep/l_pbeep.asm	;???????????????????????????????????????

;.INCLUDE	l_CodecPath/l_allopen.asm
.INCLUDE	l_CodecPath/l_ansply.asm
.INCLUDE	l_CodecPath/l_ansrec.asm

;.INCLUDE	l_flashmsg/l_biosfull.asm
;.INCLUDE	l_flashmsg/l_flashmsg.asm
.INCLUDE	l_flashmsg/l_flashogm.asm

.INCLUDE	l_rec/l_compress.asm
.INCLUDE	l_rec/l_rec.asm

.INCLUDE	l_iic/l_storsqueue.asm
.INCLUDE	l_iic/l_getrqueue.asm
.INCLUDE	l_iic/l_flashfull.asm
.INCLUDE	l_iic/l_flashmsg.asm
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

.INCLUDE	l_table/l_dtmftable.asm

.INCLUDE	l_voice/l_answeroff.asm
.INCLUDE	l_voice/l_call.asm
.INCLUDE	l_voice/l_defogm.asm
.INCLUDE	l_voice/l_endof.asm
.INCLUDE	l_voice/l_memfull.asm
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
.END
