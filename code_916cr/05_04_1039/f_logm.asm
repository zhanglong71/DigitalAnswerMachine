.NOLIST
;---------------------------------------
.INCLUDE	include.inc
;---------------------------------------

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
	
	CALL	GET_MSG
	BS	ACZ,LOCAL_PROOGM_END
	SAH	MSG
;-------------------------------------------------------------------------------
LOCAL_PROOGM_MSG:
	LAC	MSG
	XORL	CHS_WORK
	BS	ACZ,LOCAL_PROOGM_PHONE	;摘机
	LAC	MSG
	XORL	CHF_WORK
	BS	ACZ,LOCAL_PROOGM_PHONE	;免提
	
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
LOCAL_PROOGM_SER:
	CALL	GETR_DAT
	ANDL	0XFF
	SAH	MSG
;---------------------------------------	
	LAC	MSG
	SBHK	0X50
	BS	SGN,LOCAL_PROOGM_SER_0X0050	;0x00<= x <0x50
	SBHK	0X10
	BS	SGN,LOCAL_PROOGM_SER_0X5060	;0x50<= x <0x60
	
LOCAL_PROOGM_SER_END:	

	RET
;---------------------------------------
LOCAL_PROOGM_SER_0X0050:
	LAC	MSG
	SBHK	0X4C
	BS	ACZ,LOCAL_PROOGM_SER_0X4C	;(0x4C)Delete
	SBHK	0X02
	BS	ACZ,LOCAL_PROOGM_SER_0X4E	;(0x4F)SetVolSBHK	0X03
	SBHK	0X01
	BS	ACZ,LOCAL_PROOGM_SER_0X4F	;(0x4F)SetVol

	RET

;-------------------
LOCAL_PROOGM_SER_0X4C:	;(0x5B)delete
	LACL	CPLY_ERAS
	CALL	STOR_MSG
	
	RET
;-------------------
LOCAL_PROOGM_SER_0X4E:
	CALL	GETR_DAT
	ANDK	0X01f
	
	RET
;-------------------
LOCAL_PROOGM_SER_0X4F:
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
;---------------------------------------
LOCAL_PROOGM_SER_0X5060:
	LAC	MSG
	SBHK	0X50
	BS	ACZ,LOCAL_PROOGM_0X50	;(0x50)HF
	SBHK	0X01
	BS	ACZ,LOCAL_PROOGM_0X51	;(0x51)HS
	SBHK	0X03
	BS	ACZ,LOCAL_PROOGM_0X54	;(0x54)stop

	RET
;-------------------
LOCAL_PROOGM_0X50:
	CALL	GETR_DAT
	ANDK	0X07
	SBHK	1
	BS	ACZ,LOCAL_PROOGM_0X500X01
	SBHK	1
	BS	ACZ,LOCAL_PROOGM_0X500X01
	
	RET
LOCAL_PROOGM_0X500X01:		;Speaker-on and mute-on
	LAC	EVENT
	ANDL	~(1<<2)
	SAH	EVENT	;Unmute
LOCAL_PROOGM_0X50PHONE:	

	LACL	CHF_WORK
	CALL	STOR_MSG
	
	LACL	CRING_IN
	SAH	MSG
	BS	B1,LOCAL_PROOGM_MSG
LOCAL_PROOGM_0X500X02:		;Speaker-on and mute-off

	LAC	EVENT
	ORL	(1<<2)
	SAH	EVENT	;Mute
	BS	B1,LOCAL_PROOGM_0X50PHONE
;-------------------
LOCAL_PROOGM_0X51:
	CALL	GETR_DAT
	ANDK	0X07
	BS	ACZ,LOCAL_PROOGM_0X510X00
	SBHK	1
	BS	ACZ,LOCAL_PROOGM_0X510X01
	
	RET
LOCAL_PROOGM_0X510X00:		;hook-on
	LACL	CHS_IDLE
	CALL	STOR_MSG

	RET
LOCAL_PROOGM_0X510X01:		;hook-off
	LACL	CHS_WORK
	CALL	STOR_MSG

	LACL	CRING_IN
	SAH	MSG
	BS	B1,LOCAL_PROOGM_MSG
;-------------------
LOCAL_PROOGM_0X54:	;(0x54)stop
	LACL	CMSG_EXIT
	CALL	STOR_MSG
	
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
	XORL	CPLY_OGM		;play OGM
	BS	ACZ,LOCAL_PROOGM_IDLEPLY
	LAC	MSG
	XORL	CREC_OGM		;record OGM
	BS	ACZ,LOCAL_PROOGM_IDLEREC
	
	RET
;---------------------------------------
LOCAL_PROOGM_IDLEPLY:		;准备播放OGM	
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	LACK	0X0033
	SAH	PRO_VAR		;进入播放OGM子功能
	CALL	CLR_TIMER

	CALL	OGM_SELECT
	
	LAC	MSG_ID
	ORL	0XFE00
	CALL	STOR_VP

	CALL	OGM_SELECT
	BZ	ACZ,LOCAL_PROOGM_IDLEPLY_1

	CALL	INIT_DAM_FUNC
	CALL	VP_DefOGM
	LACL	0X0032		;pause 400ms
	CALL	STOR_VP
	
LOCAL_PROOGM_IDLEPLY_1:
	RET
;---------------------------------------
LOCAL_PROOGM_IDLEREC:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	VP_RecAnnAfterTheTone	;record announcement after the tone
	CALL	LBEEP

	CALL	SET_COMPS
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
	CALL	BEEP
	
	CALL	SEND_MFULL	;!!!
		
	LACK	0X0023
	SAH	PRO_VAR

	RET
;-------------------------------------------------------------------------------
LOCAL_PROOGM_PLYVOP:
	LAC	MSG
	XORL	CMSG_EXIT
	BS	ACZ,LOCAL_PROOGM_PLYVOP_STOP	;REC stop AND PLAY
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
	
	LACK	0X0033
	SAH	PRO_VAR		;退出录制OGM,进入播放OGM

	CALL	CLR_TIMER

	RET
;---------------------------------------
LOCAL_PROOGM_PLYVOP_RING:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	CALL	SILENCE40MS_VP
	
	LACK	0X0
	SAH	PRO_VAR
	
	RET	
;---------------------------------------
LOCAL_PROOGM_RECSTART:
	CALL	INIT_DAM_FUNC
	CALL	DAA_REC
	LACK	0X0023
	SAH	PRO_VAR

	CALL	OGM_SELECT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	;LACK	0		;OGM record start
	;CALL	SEND_RECSTART
	
	;LACK	30
	;CALL	DELAY
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	0
	SAH	PRO_VAR1
	LACL	CTMR1S
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
	XORL	CMSG_EXIT		;OGM key released on/off stop record
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
	CALL	SILENCE40MS_VP

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	VPMSG_CHK
	
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	LACK	0
	SAH	PRO_VAR
	
	RET	
LOCAL_PROOGM_RECTMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	60		;---
	BZ	SGN,LOCAL_PROOGM_RECTMR_1_TMROVER
	
	RET
;---------------------------------------
LOCAL_PROOGM_RECTMR_FULL:
;-!!!
	CALL	SEND_MFULL	;!!!
;-!!!
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	CALL	CLR_TIMER
	
	RET
LOCAL_PROOGM_RECTMR_1_TMROVER:		;计时或FULL
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	
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
	LAC	MSG_ID
	ORL	0XFE00
	CALL	STOR_VP

	CALL	OGM_SELECT
	BZ	ACZ,MAIN_PRO0_PLAY_OGM1

	CALL	INIT_DAM_FUNC
	CALL	BEEP
	CALL	VP_DefOGM

MAIN_PRO0_PLAY_OGM1:

	RET
;---------------------------------------
LOCAL_PROOGM_PLYOGM:		;PLAY 
	LAC	MSG
	XORL	CMSG_EXIT		;stop record(手动停止)
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
	CALL	SILENCE40MS_VP
	
	CALL	VPMSG_CHK
	
	LACK	0
	SAH	PRO_VAR
	
	RET
;---------------------------------------
LOCAL_PROOGM_PLYOGM_STOP:	;播放完后发BEEP声
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	
	LACL	CMSG_INIT
	CALL	STOR_MSG
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	VPMSG_CHK
	CALL	SEND_MSGNUM
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	0
	SAH	PRO_VAR
	
	RET
;---------------------------------------
LOCAL_PROOGM_PLYOGM_REASE:
	CALL	INIT_DAM_FUNC
	CALL	BEEP
	CALL	OGM_SELECT
	LAC	MSG_ID
	ORL	0X6000
	CALL	DAM_BIOSFUNC
	CALL	GC_CHK
	
	LACK	0X023
	SAH	PRO_VAR

	RET
;-------------------------------------------------------------------------------
;.INCLUDE	l_beep/l_bbbeep.asm
.INCLUDE	l_beep/l_lbeep.asm

.INCLUDE	l_CodecPath/l_lrec.asm

.INCLUDE	l_rec/l_rec.asm
.INCLUDE	l_rec/l_compress.asm

.INCLUDE	l_iic/l_getrqueue.asm
.INCLUDE	l_iic/l_storsqueue.asm
.INCLUDE	l_iic/l_flashfull.asm
.INCLUDE	l_iic/l_flashmsg.asm
.INCLUDE	l_iic/l_exit.asm
.INCLUDE	l_iic/l_rec.asm


.INCLUDE	l_flashmsg/l_plyspeed.asm
;.INCLUDE	l_flashmsg/l_biosfull.asm
.INCLUDE	l_flashmsg/l_flashogm.asm

.INCLUDE	l_port/l_hwalc.asm
.INCLUDE	l_port/l_spkctl.asm

;.INCLUDE	l_table/l_voltable.asm

.INCLUDE	l_voice/l_recogm.asm
.INCLUDE	l_voice/l_plyogm.asm
.INCLUDE	l_voice/l_memfull.asm
;-------------------------------------------------------------------------------
.END
	