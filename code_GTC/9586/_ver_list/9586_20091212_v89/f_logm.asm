.NOLIST
.INCLUDE	include/REG_D22.inc
.INCLUDE	include/MD22U.inc
.INCLUDE	include/CONST.inc
.INCLUDE	include/EXTERN.inc

.GLOBAL	LOCAL_PROOGM
;-------------------------------------------------------------------------------
.EXTERN	SYS_MSG_ANS
.EXTERN	SYS_MSG_RMT
;---------------------------------------
.EXTERN	GetOneConst
;-------------------------------------------------------------------------------
.LIST
;-------------------------------------------------------------------------------
.ORG	ADDR_SECOND
;-------------------------------------------------------------------------------
LOCAL_PROOGM:				;0Xyyy3
	CALL	GET_RESPOND
	
	CALL	GET_MSG
	BS	ACZ,LOCAL_PROOGM_END
	SAH	MSG
;-------------------------------------------------------------------------------
	LAC	MSG
	XORL	CHOOK_OFF
	BS	ACZ,LOCAL_PROOGM_PHONE	;摘机
	LAC	MSG
	XORL	CPHONE_ON
	BS	ACZ,LOCAL_PROOGM_PHONE	;免提

	LAC	MSG
	XORL	CSEG_END
	BS	ACZ,LOCAL_PROOGM_SEGEND	;SEG-end
	LAC	MSG
	XORL	CMSG_SER
	BS	ACZ,LOCAL_PROOGM_SER	;SEG-end
	
	LAC	PRO_VAR
	SFR	4
	ANDK	0X0F
	BS	ACZ,LOCAL_PROOGM_IDLE		;(0x0003) - idle
	SBHK	1
	BS	ACZ,LOCAL_PROOGM_PLYVOP		;(0x0013) - VOP before record
	SBHK	1
	BS	ACZ,LOCAL_PROOGM_RECOGM		;(0x0023) - record OGM
	SBHK	1
	BS	ACZ,LOCAL_PROOGM_PLYOGM		;(0x0033) - play OGM
	
LOCAL_PROOGM_END:
	RET
;---------------------------------------
LOCAL_PROOGM_SEGEND:
	CALL	GET_VP
	BS	ACZ,LOCAL_PROOGM_SEGEND0
	CALL	INT_BIOS_START
	
	RET
LOCAL_PROOGM_SEGEND0:
	CALL	INIT_DAM_FUNC
	LACL	CVP_STOP		;通知系统播放完毕
	CALL	STOR_MSG
	
	RET
;---------------------------------------
LOCAL_PROOGM_SER:
	CALL	GETR_DAT
	ANDL	0XFF
	SAH	MSG
;---------------------------------------	
	LAC	MSG
	SBHK	0X30
	BS	SGN,LOCAL_PROOGM_SER_END		;0x00<= x <0x30
	SBHK	0X10
	BS	SGN,LOCAL_PROOGM_SER_0X3040	;0x30<= x <0x40
	SBHK	0X10
	BS	SGN,LOCAL_PROOGM_SER_0X4050	;0x40<= x <0x50
	SBHK	0X10
	BS	SGN,LOCAL_PROOGM_SER_0X5060	;0x50<= x <0x60
	SBHK	0X10
	BS	SGN,LOCAL_PROOGM_SER_0X6070	;0x60<= x <0x70
	SBHK	0X10
	BS	SGN,LOCAL_PROOGM_SER_0X7080	;0x70<= x <0x80
	SBHK	0X10
	BS	SGN,LOCAL_PROOGM_SER_0X8090	;0x80<= x <0x90
	
LOCAL_PROOGM_SER_END:	

	RET
;---------------------------------------
LOCAL_PROOGM_SER_0X3040:
LOCAL_PROOGM_SER_0X4050:
	LAC	MSG
	SBHK	0X4A
	BS	ACZ,LOCAL_PROOGM_SETVOL		;(0x4A)SetVol
	SBHK	0X01
	BS	ACZ,LOCAL_PROOGM_SETHFVOL	;(0X4B)HF-vol

	RET
;-------------------
LOCAL_PROOGM_SETVOL:
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
;---------------------------------------
LOCAL_PROOGM_SETHFVOL:		;not in spkphone mode set Speakerphone volume (GTC demand;2009-6-30 20:42)
	LAC	VOI_ATT
	ANDL	0XFF0F
	SAH	VOI_ATT
	
	CALL	GETR_DAT
	SAH	SYSTMP0
	SFL	4
	ANDL	0X00F0
	OR	VOI_ATT
	SAH	VOI_ATT
	
	RET
	
;---------------------------------------
LOCAL_PROOGM_SER_0X5060:
	LAC	MSG
	SBHK	0X5A
	BS	ACZ,LOCAL_PROOGM_0X5A	;(0x5A)stop
	SBHK	0X01
	BS	ACZ,LOCAL_PROOGM_0X5B	;(0x5B)delete
	SBHK	0X03
	BS	ACZ,LOCAL_PROOGM_0X5E	;(0x5E)Spkphone

	RET
;-------------------
LOCAL_PROOGM_0X5A:	;(0x5A)stop
	LACL	CMSG_KEY6S
	CALL	STOR_MSG
	
	RET
;-------------------
LOCAL_PROOGM_0X5B:	;(0x5B)delete
	LACL	CPLY_ERAS
	CALL	STOR_MSG
	
	RET
;-------------------
LOCAL_PROOGM_0X5E:	
	CALL	GETR_DAT
	SBHK	1
	BS	ACZ,LOCAL_PROOGM_0X5E0X01
	RET
;-------------------
LOCAL_PROOGM_0X5E0X01:
	LACL	CPHONE_ON	;免提
	CALL	STOR_MSG

	RET
;---------------------------------------
LOCAL_PROOGM_SER_0X6070:
	LAC	MSG
	SBHK	0X60
	BS	ACZ,LOCAL_PROOGM_0X60	;(0x60)Handset
	SBHK	0X02
	BS	ACZ,LOCAL_PROOGM_PSADN	;(0x62)Slow-100% playspeed
	SBHK	0X01
	BS	ACZ,LOCAL_PROOGM_PSANORAMAL	;(0x63)normal playspeed

	RET
;-------------------
LOCAL_PROOGM_0X60:
	CALL	GETR_DAT
	ANDL	0X0FF
	SBHK	1
	BS	ACZ,LOCAL_PROOGM_0X600X01
	RET
LOCAL_PROOGM_0X600X01:
	LACL	CHOOK_OFF	;手柄提机
	CALL	STOR_MSG

	RET
;---------------------------------------
LOCAL_PROOGM_PSADN:
	LACK	20		;speed down 100%
	CALL	SET_PLYPSA

	RET
LOCAL_PROOGM_PSANORAMAL:
	LACK	10		;normal speed
	CALL	SET_PLYPSA

	RET
;---------------------------------------
LOCAL_PROOGM_SER_0X7080:
LOCAL_PROOGM_SER_0X8090:
	RET

;---------------------------------------
LOCAL_PROOGM_PHONE:
	LACL	CRING_IN
	CALL	STOR_MSG	;当来铃一样的处理
	LAC	MSG
	CALL	STOR_MSG	

	RET
;-------------------------------------------------------------------------------
LOCAL_PROOGM_IDLE:
	LAC	MSG
	XORL	CMSG_KEY5S		;play OGM
	BS	ACZ,LOCAL_PROOGM_IDLEPLY
	LAC	MSG
	XORL	CMSG_KEY5L		;record OGM
	BS	ACZ,LOCAL_PROOGM_IDLEREC
	
	RET
;---------------------------------------
LOCAL_PROOGM_IDLEPLY:		;准备播放OGM	
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	LACK	0X0033
	SAH	PRO_VAR		;进入播放OGM子功能
	CALL	CLR_TIMER
;---
	BIT	ANN_FG,9		;check help message or not
	BS	TB,LOCAL_PROHELP_IDLEPLY

	CALL	OGM_SELECT
	
	CALL	VP_YourAnnouncementIs
	LAC	MSG_ID
	ORL	0XFE00
	CALL	STOR_VP

	CALL	OGM_SELECT
	BZ	ACZ,LOCAL_PROOGM_IDLEPLY_1

	CALL	INIT_DAM_FUNC
	CALL	VP_YourAnnouncementIs
	CALL	VP_DefOGM
	LACL	0X0032		;pause 400ms
	CALL	STOR_VP
	CALL	VP_PressAndHoldAnnKeyToRecAnnouncement

LOCAL_PROOGM_IDLEPLY_1:
	RET
;---------------------------------------
LOCAL_PROHELP_IDLEPLY:
	CALL	HLP_STATUS
	SAH	MSG_ID
	
	LAC	MSG_ID
	ORL	0XFE00
	CALL	STOR_VP

	CALL	HLP_STATUS
	BS	ACZ,LOCAL_PROHELP_IDLEPLY_1
	
	RET

LOCAL_PROHELP_IDLEPLY_1:
	
	CALL	INIT_DAM_FUNC
	
	CALL	VP_DefHelp
	LACL	0X0032		;pause 400ms
	CALL	STOR_VP

	RET
;---------------------------------------
LOCAL_PROOGM_IDLEREC:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	SET_COMPS
	
	BIT	ANN_FG,9		;if record help message ?
	BS	TB,LOCAL_PROOGM_IDLEREC_0
	
	CALL	VP_RecAnnAfterTheTone	;record announcement after the tone
LOCAL_PROOGM_IDLEREC_0:
	CALL	LBEEP
;---delete the old OGM fisrt------------
.if	0	;Can`t delete OGM before record
LOCAL_PROOGM_IDLEREC_1:
	CALL	OGM_SELECT
	BS	ACZ,LOCAL_PROOGM_IDLEREC_2
	LAC	MSG_ID
	ORL	0X6000
	CALL	DAM_BIOSFUNC
	CALL	GC_CHK
	BS	B1,LOCAL_PROOGM_IDLEREC_1
.endif
;---deleted the old OGM ------------
LOCAL_PROOGM_IDLEREC_2:
	LACK	0X0013
	SAH	PRO_VAR
	
	CALL	MEMFUL_CHK	;check memoful(不查MEMO条目满)?
	BZ	ACZ,LOCAL_PRO0_RECOGM_MFUL

	RET
LOCAL_PRO0_RECOGM_MFUL:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	VP_MemoryIsFull	;End of playback requery VOP
	CALL	BEEP
	CALL	SEND_MFULL	;!!!		
	LACK	0X0023
	SAH	PRO_VAR

	RET
;-------------------------------------------------------------------------------
LOCAL_PROOGM_PLYVOP:
	LAC	MSG
	XORL	CMSG_KEY5S
	BS	ACZ,LOCAL_PROOGM_PLYVOP_STOP	;REC stop AND PLAY
	LAC	MSG
	XORL	CMSG_KEY6S
	BS	ACZ,LOCAL_PROOGM_PLYVOP_STOP	;REC stop
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,LOCAL_PROOGM_PLYVOP_RING	;RING
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROOGM_RECSTART	;end beep and start record
	
	RET
;---------------------------------------
LOCAL_PROOGM_PLYVOP_STOP:

	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	CALL	VP_DefOGM
;---PressAndHoldAnnounceKeyToRecordAnnouncement
	CALL	VP_PressAndHoldAnnKeyToRecAnnouncement

	LACK	0X0033
	SAH	PRO_VAR		;退出录制OGM,进入播放OGM

	CALL	CLR_TIMER

	RET
;---------------------------------------
LOCAL_PROOGM_PLYVOP_RING:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACK	0X005
	CALL	STOR_VP
	
	LACK	0X0
	SAH	PRO_VAR
	
	RET	
;---------------------------------------
LOCAL_PROOGM_RECSTART:
	CALL	INIT_DAM_FUNC
	CALL	DAA_REC
	LACK	0X0023
	SAH	PRO_VAR

	BIT	ANN_FG,9
	BS	TB,LOCAL_PROOGM_RECSTART_1

	CALL	OGM_SELECT
	BS	B1,LOCAL_PROOGM_RECSTART_2
LOCAL_PROOGM_RECSTART_1:
	
	CALL	HLP_STATUS
	
LOCAL_PROOGM_RECSTART_2:
;---set user index data0"OGM_ID"	
    	LAC	MSG_N
    	ORL	0X8D00
    	CALL	DAM_BIOSFUNC
;---delete the old OGM fisrt------------
	;LAC	MSG_ID
	;ORL	0X6000
	;CALL	DAM_BIOSFUNC
	;CALL	GC_CHK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	0		;OGM record start
	CALL	SEND_RECSTART
	
	LACK	30
	CALL	DELAY
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER
	
	LACL	CMODE9		;close ALC
	CALL	DAM_BIOSFUNC

	LACL	0xD700|CLVOX_LEVEL
	CALL	DAM_BIOSFUNC
	LACL	0x7700|CLSILENCE_LEVEL
	CALL	DAM_BIOSFUNC
		
	CALL	REC_START
	
	RET
;---------------------------------------
LOCAL_PROOGM_RECOGM:			;record OGM
	LAC	MSG
	XORL	CMSG_KEY6S		;OGM key released on/off stop record
	BS	ACZ,LOCAL_PROOGM_RECOGM_STOP
	LAC	MSG
	XORL	CRING_IN		;RING
	BS	ACZ,LOCAL_PROOGM_RECOGM_RING
LOCAL_PROOGM_REC1_1:
	LAC	MSG
	XORL	CMSG_TMR		;timer
	BS	ACZ,LOCAL_PROOGM_RECTMR
LOCAL_PROOGM_REC1_2:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROOGM_RECOGMSUCC_STOP	;end beep/memoryfull and start PLAY OGM
LOCAL_PROOGM_REC1_3:
	LAC	MSG
	XORL	CREC_FULL		;FULL
	BS	ACZ,LOCAL_PROOGM_RECTMR_FULL	;end beep and start PLAY OGM

	RET
;---------------------------------------
LOCAL_PROOGM_RECOGM_RING:
	LAC	PRO_VAR1
	SBHK	2		;2007-12-17特别要求Announcement Record最短录音2s
	BZ	SGN,LOCAL_PROOGM_RECOGM_RING1
	LAC	CONF
	ORL	1<<11
	CALL	DAM_BIOSFUNC
LOCAL_PROOGM_RECOGM_RING1:	
	CALL	INIT_DAM_FUNC
	LACK	0X005
	CALL	STOR_VP

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	VPMSG_CHK
	;CALL	MEMFUL_CHK
	LAC	ANN_FG
	SFR	13
	ANDK	0X01
	CALL	SEND_MFULL
	CALL	EXIT_TOIDLE
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	LACK	0
	SAH	PRO_VAR
	
	RET	
LOCAL_PROOGM_RECTMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	61		;---
	BZ	SGN,LOCAL_PROOGM_RECTMR_1_TMROVER
	
	RET
;---------------------------------------
LOCAL_PROOGM_RECTMR_FULL:
;-!!!
	CALL	SEND_MFULL
;-!!!
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	VP_MemoryIsFull	;End of playback requery VOP
	CALL	BEEP
	LACK	0X03F
	CALL	STOR_VP
	CALL	CLR_TIMER
	
	RET
LOCAL_PROOGM_RECTMR_1_TMROVER:		;计时或FULL
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	LACK	0X03F
	CALL	STOR_VP

	CALL	CLR_TIMER

	RET

;---------------------------------------
LOCAL_PROOGM_RECOGM_STOP:
	LAC	PRO_VAR1
	SBHK	2		;2007-12-17特别要求Announcement Record最短录音2s
	BZ	SGN,LOCAL_PROOGM_RECOGMSUCC_STOP

;LOCAL_PROOGM_RECOGMFAIL_STOP:	
	LAC	CONF
	ORL	1<<11
	CALL	DAM_BIOSFUNC
LOCAL_PROOGM_RECOGMSUCC_STOP:	;准备播放OGM
	
	CALL	DAA_SPK
	LACK	0X0033
	SAH	PRO_VAR		;退出录制OGM,进入播放OGM

	CALL	INIT_DAM_FUNC
	
	CALL	CLR_TIMER
	
	BIT	ANN_FG,9		;Help mode or not ?
	BS	TB,LOCAL_PROOGM_DELOLDHLP
	
LOCAL_PROOGM_DELOLDOGM:
	
	CALL	OGM_SELECT
	SBHK	2
	BS	SGN,LOCAL_PROOGM_DELOLDOGM_1	;少于2(只有1/0)条时就不删除
	LACL	0X6000|1	;删最旧的
	CALL	DAM_BIOSFUNC
	CALL	GC_CHK
	BS	B1,LOCAL_PROOGM_DELOLDOGM
	
LOCAL_PROOGM_DELOLDOGM_1:

	CALL	BEEP
	CALL	VP_YourAnnouncementIs
	LAC	MSG_ID
	ORL	0XFE00
	CALL	STOR_VP

	CALL	OGM_SELECT
	BZ	ACZ,MAIN_PRO0_PLAY_OGM1

	CALL	INIT_DAM_FUNC
	CALL	BEEP
	CALL	VP_YourAnnouncementIs
	CALL	VP_DefOGM

MAIN_PRO0_PLAY_OGM1:

	RET	
;-------
LOCAL_PROOGM_DELOLDHLP:
	CALL	HLP_STATUS
	SAH	MSG_ID
	SBHK	2
	BS	SGN,LOCAL_PROOGM_DELOLDHLP_1	;少于2(只有1/0)条时就不删除
	LACL	0X6000|1	;删最旧的
	CALL	DAM_BIOSFUNC
	CALL	GC_CHK
	BS	B1,LOCAL_PROOGM_DELOLDHLP
	
LOCAL_PROOGM_DELOLDHLP_1:
	
	CALL	BEEP
	LAC	MSG_ID
	ORL	0XFE00
	CALL	STOR_VP

	CALL	HLP_STATUS
	BZ	ACZ,MAIN_PRO0_PLAY_HELP1

	CALL	INIT_DAM_FUNC
	CALL	BEEP
	CALL	VP_DefHelp

MAIN_PRO0_PLAY_HELP1:

	RET
;---------------------------------------
LOCAL_PROOGM_PLYOGM:		;PLAY 
	LAC	MSG
	XORL	CMSG_KEY6S		;stop record(手动停止)
	BS	ACZ,LOCAL_PROOGM_PLYOGM_STOP
	LAC	MSG
	XORL	CRING_IN		;RING
	BS	ACZ,LOCAL_PROOGM_PLYOGM_RING
;LOCAL_PROOGM_PLYOGM0_1:	
	LAC	MSG
	XORL	CVP_STOP		;stop record(播完停止)
	BS	ACZ,LOCAL_PROOGM_PLYOGM_STOP
;LOCAL_PROOGM_PLYOGM0_2:	
	LAC	MSG
	XORL	CPLY_ERAS
	BS	ACZ,LOCAL_PROOGM_PLYOGM_REASE
;LOCAL_PROOGM_PLYOGM0_3:
	
	RET
;---------------------------------------
LOCAL_PROOGM_PLYOGM_RING:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACK	0X005
	CALL	STOR_VP
	
	LACK	10		;normal speed
	CALL	SET_PLYPSA	;Clear Fast play flag(no matter it has been set or not)

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	VPMSG_CHK
	;CALL	MEMFUL_CHK
	LAC	ANN_FG
	SFR	13
	ANDK	0X01
	CALL	SEND_MFULL
	CALL	EXIT_TOIDLE
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	0
	SAH	PRO_VAR
	
	RET
;---------------------------------------
LOCAL_PROOGM_PLYOGM_STOP:	;播放完后发BEEP声
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	CALL	BEEP
	
	LACK	10		;normal speed
	CALL	SET_PLYPSA	;Clear Fast play flag(no matter it has been set or not)

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	VPMSG_CHK
	;CALL	MEMFUL_CHK
	LAC	ANN_FG
	SFR	13
	ANDK	0X01
	CALL	SEND_MFULL
	CALL	EXIT_TOIDLE
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	0
	SAH	PRO_VAR
	
	RET
;---------------------------------------
LOCAL_PROOGM_PLYOGM_REASE:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	CALL	BEEP
	
	BIT	ANN_FG,9
	BS	TB,LOCAL_PROOGM_PLYOGM_REASE_1
	
	CALL	OGM_SELECT
	SAH	MSG_ID
	BS	B1,LOCAL_PROOGM_PLYOGM_REASE_2

LOCAL_PROOGM_PLYOGM_REASE_1:	
	CALL	HLP_STATUS
	SAH	MSG_ID
	;BS	B1,LOCAL_PROOGM_PLYOGM_REASE_2
	
LOCAL_PROOGM_PLYOGM_REASE_2:
	LAC	MSG_ID
	ORL	0X6000
	CALL	DAM_BIOSFUNC
	CALL	GC_CHK

	LACK	10		;normal speed
	CALL	SET_PLYPSA	;Clear Fast play flag(no matter it has been set or not)
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	VPMSG_CHK
	;CALL	MEMFUL_CHK
	LAC	ANN_FG
	SFR	13
	ANDK	0X01
	CALL	SEND_MFULL
	;CALL	EXIT_TOIDLE
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	LACK	0
	SAH	PRO_VAR

	RET
;-------------------------------------------------------------------------------
.INCLUDE	l_beep/l_beep.asm
.INCLUDE	l_beep/l_bbeep.asm
.INCLUDE	l_beep/l_bbbeep.asm
.INCLUDE	l_beep/l_lbeep.asm

.INCLUDE	l_CodecPath/l_allopen.asm
.INCLUDE	l_CodecPath/l_lply.asm
.INCLUDE	l_CodecPath/l_lrec.asm

.INCLUDE	l_rec/l_rec.asm
.INCLUDE	l_rec/l_compress.asm

.INCLUDE	l_iic/l_getrqueue.asm
.INCLUDE	l_iic/l_storsqueue.asm
.INCLUDE	l_iic/l_flashfull.asm
.INCLUDE	l_iic/l_exit.asm
.INCLUDE	l_iic/l_rec.asm


.INCLUDE	l_flashmsg/l_plyspeed.asm
.INCLUDE	l_flashmsg/l_biosfull.asm
.INCLUDE	l_flashmsg/l_flashmsg.asm
.INCLUDE	l_flashmsg/l_flashogm.asm

.INCLUDE	l_respond/l_lrec_resp.asm
.INCLUDE	l_respond/l_vpqueue.asm

.INCLUDE	l_port/l_hwalc.asm
.INCLUDE	l_port/l_spkctl.asm

.INCLUDE	l_table/l_voltable.asm

.INCLUDE	l_voice/l_recogm.asm
.INCLUDE	l_voice/l_plyogm.asm
.INCLUDE	l_voice/l_memfull.asm
.INCLUDE	l_voice/l_help.asm
;-------------------------------------------------------------------------------
.END
	