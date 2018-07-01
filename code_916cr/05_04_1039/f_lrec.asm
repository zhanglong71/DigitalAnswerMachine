.NOLIST
;---------------------------------------
.INCLUDE	include.inc
;---------------------------------------
.GLOBAL	LOCAL_PROREC
;-------------------------------------------------------------------------------
.EXTERN	SYS_MSG_ANS
.EXTERN	SYS_MSG_RMT
;---------------------------------------
.EXTERN	GetOneConst
;---
.LIST
;-------------------------------------------------------------------------------
.ORG	ADDR_SECOND
;-------------------------------------------------------------------------------
;MEMO/2-WAY/EraseAll
;-------------------------------------------------------------------------------
LOCAL_PROREC:			;0Xyyy2 = record MEMO
	
	CALL	GET_MSG
	BS	ACZ,LOCAL_PROREC_END
	SAH	MSG
;-------------------------------------------------------------------------------
LOCAL_PROREC_MSG:
	LAC	MSG
	XORL	CHS_WORK
	BS	ACZ,LOCAL_PROREC_PHONE	;摘机
	LAC	MSG
	XORL	CHF_WORK
	BS	ACZ,LOCAL_PROREC_PHONE	;免提
	LAC	MSG
	XORL	CMSG_SER
	BS	ACZ,LOCAL_PROREC_SER	;SEG-end
	
	LAC	PRO_VAR
	SFR	4
	ANDK	0X0F
	BS	ACZ,LOCAL_PROREC0	;(0x0002)
	SBHK	1
	BS	ACZ,LOCAL_PROREC1	;(0x0012)prompt
	SBHK	1
	BS	ACZ,LOCAL_PROREC2	;(0x0022)record
	SBHK	1
	BS	ACZ,LOCAL_PROREC3	;(0x0032)for end VOP(end beep)
	SBHK	1
	BS	ACZ,LOCAL_PROREC4	;(0x0042)for VOP-memoryfull(memfull)
	SBHK	1
	BS	ACZ,LOCAL_PROREC5	;(0x0052)2-way record
LOCAL_PROREC_END:	
	RET
;---------------------------------------
LOCAL_PROREC_SER:
	CALL	GETR_DAT
	ANDL	0XFF
	SAH	MSG
;---------------------------------------	
	LAC	MSG
	SBHK	0X50
	BS	ACZ,LOCAL_PROREC_0X50	;(0x50)HF
	SBHK	0X01
	BS	ACZ,LOCAL_PROREC_0X51	;(0x51)HS
	SBHK	0X03
	BS	ACZ,LOCAL_PROREC_0X54	;(0x54)stop

	RET
;-------------------
LOCAL_PROREC_0X50:
	CALL	GETR_DAT
	ANDK	0X07
	SBHK	1
	BS	ACZ,LOCAL_PROREC_0X500X01
	SBHK	1
	BS	ACZ,LOCAL_PROREC_0X500X01
	
	RET
LOCAL_PROREC_0X500X01:		;Speaker-on and mute-on
	LAC	EVENT
	ANDL	~(1<<2)
	SAH	EVENT	;Unmute
LOCAL_PROREC_0X50PHONE:	

	LACL	CHF_WORK
	CALL	STOR_MSG
	
	LACL	CRING_IN
	SAH	MSG
	BS	B1,LOCAL_PROREC_MSG
LOCAL_PROREC_0X500X02:		;Speaker-on and mute-off

	LAC	EVENT
	ORL	(1<<2)
	SAH	EVENT	;Mute
	BS	B1,LOCAL_PROREC_0X50PHONE
;-------------------
LOCAL_PROREC_0X51:
	CALL	GETR_DAT
	ANDK	0X07
	BS	ACZ,LOCAL_PROREC_0X510X00
	SBHK	1
	BS	ACZ,LOCAL_PROREC_0X510X01
	
	RET
LOCAL_PROREC_0X510X00:		;hook-on
	LACL	CHS_IDLE
	CALL	STOR_MSG

	RET
LOCAL_PROREC_0X510X01:		;hook-off
	LACL	CHS_WORK
	CALL	STOR_MSG

	LACL	CRING_IN
	SAH	MSG
	BS	B1,LOCAL_PROREC_MSG
;-------------------
LOCAL_PROREC_0X54:	;(0x54)stop
	LACL	CMSG_EXIT
	CALL	STOR_MSG
	
	RET
;---------------------------------------
LOCAL_PROREC_PHONE:
	LACL	CRING_IN
	CALL	STOR_MSG	;当来铃一样的处理
	LAC	MSG
	CALL	STOR_MSG	

	RET
;---------------------------------------
LOCAL_PROREC0:
	LAC	MSG
	XORL	CREC_MEMO		;Record message
	BS	ACZ,LOCAL_PROREC0_RECMSG
	
	LAC	MSG
	XORL	COLD_ERAS
	BS	ACZ,LOCAL_PROERA_ERAALL
	
	LAC	MSG
	XORL	CREC_2WAY
	BS	ACZ,LOCAL_PROREC0_2WAY
	RET
;---------------------------------------
LOCAL_PROREC0_RECMSG:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	VPMSG_CHK

	BIT	ANN_FG,13	;check memoful?
	BS	TB,LOCAL_PRO0_RECMSG_MFUL

	CALL	VP_RecMsgAfterTheTone	;Now recording
	CALL	LBEEP
	
	CALL	SET_COMPS
	LACK	0X0012
	SAH	PRO_VAR

	RET
;---------------------------------------
LOCAL_PROREC0_2WAY:
	CALL	INIT_DAM_FUNC
	CALL	VPMSG_CHK

	BIT	ANN_FG,13	;check memoful?
	BS	TB,LOCAL_PRO0_RECMSG_MFUL

	CALL	DAA_REC
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!		
	LACK	1		;MEMO record start
	CALL	SEND_RECSTART
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	CTMR1S
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1

	LACK	0X052
	SAH	PRO_VAR
	
	LACL	CMODE9		;close ALC
	CALL	DAM_BIOSFUNC

	CALL	REC_START
	
	RET
;---------------------------------------
LOCAL_PROERA_ERAALL:	
	CALL	INIT_DAM_FUNC
	CALL	VPMSG_CHK
	LACK	0X32
	SAH	PRO_VAR
;---	
	LAC	MSG_T
	BS	ACZ,LOCAL_PRO0_REAALL_0
	
	LAC	MSG_T
	SBH	MSG_N
	BS	ACZ,LOCAL_PRO0_REAALL_1
;------del old only
	CALL	VPMSG_DELOLD
	CALL	GC_CHK
;---
	CALL	DAA_SPK
	CALL	BEEP
	RET
;-------------------
LOCAL_PRO0_REAALL_0:		;No messages
	CALL	DAA_SPK
	CALL	BBBEEP
	RET
;-------------------
LOCAL_PRO0_REAALL_1:		;No old messages
	CALL	VPMSG_DELOLD
	CALL	GC_CHK
;---
	CALL	DAA_SPK
	CALL	BEEP	

	RET
;---------------------------------------
LOCAL_PRO0_RECMSG_MFUL:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	VP_MemoryIsFull	;End of playback requery VOP
	CALL	BEEP
;-!!!
	CALL	EXIT_TOIDLE
	CALL	SEND_MFULL	;!!!
;-!!!	
	LACK	0X042
	SAH	PRO_VAR

	RET
;-------------------------------------------------------------------------------
LOCAL_PROREC1:
	LAC	MSG
	XORL	CMSG_EXIT		;MEMO key released worn and stop
	BS	ACZ,LOCAL_PROWORN
;LOCAL_PROREC1_1:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROREC1_START	;end beep and start record
;LOCAL_PROREC1_2:	
	LAC	MSG
	XORL	CRING_IN		;RING
	BS	ACZ,LOCAL_PROREC0_RING
	
	RET
;---------------------------------------
LOCAL_PROWORN:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BBBEEP
	
	LACK	0X032
	SAH	PRO_VAR
	
	RET
;---------------------------------------
LOCAL_PROREC0_RING:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACK	0X005
	CALL	STOR_VP
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	EXIT_TOIDLE
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	0X0
	SAH	PRO_VAR
	
	RET	
;---------------------------------------
LOCAL_PROREC1_START:
	CALL	INIT_DAM_FUNC
	CALL	DAA_REC
	
	LAC	TMR_YEAR
	CALL	SET_USR1ID	;Use to save year

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!		
	LACK	1		;MEMO record start
	CALL	SEND_RECSTART
	
	LACK	30
	CALL	DELAY
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	1000
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1

	LACK	0X022
	SAH	PRO_VAR
	
	LACL	CMODE9		;close ALC
	CALL	DAM_BIOSFUNC

	LACL	0xD700|CLVOX_LEVEL
	CALL	DAM_BIOSFUNC
	LACL	0x7700|CLSILENCE_LEVEL
	CALL	DAM_BIOSFUNC	
	
	CALL	REC_START
	
	RET	
;-------------------------------------------------------------------------------
LOCAL_PROREC2:
	LAC	MSG
	XORL	CMSG_EXIT		;stop record
	BS	ACZ,LOCAL_PROREC2_STOP
;LOCAL_PROREC2_1:
	LAC	MSG
	XORL	CREC_FULL		;full
	BS	ACZ,LOCAL_PROREC2_MFUL
;LOCAL_PROREC2_2:
	LAC	MSG
	XORL	CMSG_TMR		;timer
	BS	ACZ,LOCAL_PROREC2_TMR
;LOCAL_PROREC2_3:
	LAC	MSG
	XORL	CRING_IN		;Ring
	BS	ACZ,LOCAL_PROREC2_RING
	RET
;---------------------------------------
LOCAL_PROREC2_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1

	RET

;---------------------------------------
LOCAL_PROREC2_MFUL:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	CALL	VP_MemoryIsFull	;End of playback requery VOP
;-!!!
	CALL	EXIT_TOIDLE
	CALL	SEND_MFULL
;-!!!
	LACK	0X0042
	SAH	PRO_VAR

	RET
;--------------------------------------	
LOCAL_PROREC2_STOP:
	LAC	PRO_VAR1
	SBHK	3
	BS	SGN,LOCAL_PRORECFAIL_STOP

	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP

	LACK	0X032
	SAH	PRO_VAR
	
	RET
;-------
LOCAL_PRORECFAIL_STOP:		;录音失败(非正常)退出
	LAC	CONF
	ORL	0X0800
	CALL	DAM_BIOSFUNC

	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BBBEEP

	LACK	0X032
	SAH	PRO_VAR
	
	RET
;---------------------------------------
LOCAL_PROREC2_RING:
	LAC	PRO_VAR1
	SBHK	3
	BZ	SGN,LOCAL_PROREC2_RING_1

	LAC	CONF
	ORL	1<<11
	CALL	DAM_BIOSFUNC
LOCAL_PROREC2_RING_1:	
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACK	0X005
	CALL	STOR_VP

	LACK	0X0
	SAH	PRO_VAR
	
	CALL	VPMSG_CHK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	SEND_MSGNUM
	CALL	EXIT_TOIDLE
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	RET

;-------------------------------------------------------------------------------
LOCAL_PROREC3:			;End BEEP|full
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROREC3_STOP
;LOCAL_PROREC3_1:
	LAC	MSG
	XORL	CMSG_EXIT
	BS	ACZ,LOCAL_PROREC3_STOP	;
;LOCAL_PROREC3_2:	
	LAC	MSG
	XORL	CRING_IN		;RING
	BS	ACZ,LOCAL_PROREC3_STOP
	RET
;---------------------------------------
LOCAL_PROREC3_STOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACK	0X005
	CALL	STOR_VP

	CALL	VPMSG_CHK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	SEND_MSGNUM
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	MSGLED_IDLE

	LACK	0X0
	SAH	PRO_VAR
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROREC4:		;for memoryfull only when recording
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROREC4_STOP
;LOCAL_PROREC4_1:
	LAC	MSG
	XORL	CMSG_EXIT
	BS	ACZ,LOCAL_PROREC4_STOP	;
;LOCAL_PROREC4_2:	
	LAC	MSG
	XORL	CRING_IN		;RING
	BS	ACZ,LOCAL_PROREC4_STOP
	RET
;---------------
LOCAL_PROREC4_STOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACK	0X005
	CALL	STOR_VP

	CALL	VPMSG_CHK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	SEND_MSGNUM	;No update,no nessary 
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	MSGLED_IDLE

	LACK	0X0
	SAH	PRO_VAR
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROREC5:
	LAC	MSG
	XORL	CMSG_EXIT		;stop record
	BS	ACZ,LOCAL_PROREC5_STOP
;LOCAL_PROREC2_1:
	LAC	MSG
	XORL	CREC_FULL		;full
	BS	ACZ,LOCAL_PROREC5_MFUL
;LOCAL_PROREC2_2:
	LAC	MSG
	XORL	CMSG_TMR		;timer
	BS	ACZ,LOCAL_PROREC5_TMR
;LOCAL_PROREC2_3:
	
	RET
;---------------------------------------
LOCAL_PROREC5_MFUL:
LOCAL_PROREC5_STOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF

	CALL	VPMSG_CHK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	SEND_MSGNUM	;No update,no nessary 
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	MSGLED_IDLE

	LACK	0X0
	SAH	PRO_VAR
	
	RET
;---------------------------------------
LOCAL_PROREC5_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	
	RET
;-------------------------------------------------------------------------------
.INCLUDE	l_beep/l_bbbeep.asm
.INCLUDE	l_beep/l_lbeep.asm

.INCLUDE	l_CodecPath/l_lrec.asm

;.INCLUDE	l_flashmsg/l_flashmsg.asm
;.INCLUDE	l_flashmsg/l_biosfull.asm
.INCLUDE	l_flashmsg/l_biosdelold.asm

.INCLUDE	l_iic/l_storsqueue.asm
.INCLUDE	l_iic/l_getrqueue.asm
.INCLUDE	l_iic/l_flashmsg.asm
.INCLUDE	l_iic/l_flashfull.asm
;.INCLUDE	l_iic/l_exit.asm
.INCLUDE	l_iic/l_rec.asm

.INCLUDE	l_port/l_spkctl.asm
.INCLUDE	l_port/l_hwalc.asm
.INCLUDE	l_port/l_msgled.asm

;.INCLUDE	l_table/l_voltable.asm

.INCLUDE	l_rec/l_rec.asm
.INCLUDE	l_rec/l_compress.asm

;.INCLUDE	l_respond/l_lrec_resp.asm
;.INCLUDE	l_respond/l_vpqueue.asm

.INCLUDE	l_voice/l_plymsg.asm
;.INCLUDE	l_voice/l_alldel.asm
.INCLUDE	l_voice/l_recmemo.asm
.INCLUDE	l_voice/l_memfull.asm
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
.END
	