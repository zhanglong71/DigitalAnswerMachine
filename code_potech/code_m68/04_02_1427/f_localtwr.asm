.NOLIST
.INCLUDE	include/REG_D22.inc
.INCLUDE	include/MD22U.inc
.INCLUDE	include/CONST.inc

.GLOBAL	LOCAL_PROTWR
;-------------------------------------------------------------------------------
.EXTERN	GetOneConst
;.EXTERN	ANNOUNCE_NUM

.EXTERN	INIT_DAM_FUNC

.EXTERN	BCVOX_INIT
.EXTERN	BBBEEP
.EXTERN	BBEEP
.EXTERN	BEEP

.EXTERN	CLR_FUNC
.EXTERN	CLR_TIMER

.EXTERN	DAA_LIN_REC
.EXTERN	DAA_LIN_SPK
.EXTERN	DAA_SPK
.EXTERN	DAA_REC
.EXTERN	DAA_OFF

.EXTERN	DAM_BIOSFUNC
.EXTERN	DGT_TAB

.EXTERN	GC_CHK

.EXTERN	LBEEP

.EXTERN	LINE_START
.EXTERN	LOCAL_PRO

.EXTERN	OGM_TEMP

.EXTERN	PUSH_FUNC

;.EXTERN	REAL_DEL
.EXTERN	REC_START

.EXTERN	SET_PLYPSA
.EXTERN	SET_TIMER

.EXTERN	SEND_DAT
;.EXTERN	SEND_MFULL
.EXTERN	SEND_MSGNUM
;.EXTERN	SEND_RECSTART
.EXTERN	STOR_MSG
.EXTERN	STOR_VP

.EXTERN	VPMSG_CHK
.EXTERN	VPMSG_DEL

;---
.EXTERN	VP_DefOGM

;---
.LIST
;-------------------------------------------------------------------------------
.ORG	ADDR_SECOND
;-------------------------------------------------------------------------------
LOCAL_PROTWR:			;0Xyyy2 = record MEMO
	LAC	MSG
	XORL	CPARA_MINE
	;BS	ACZ,LOCAL_PROREC_PMINE
		
	LAC	MSG
	XORL	CHOOK_OFF
	BS	ACZ,LOCAL_PROTWR_PHONE	;摘机
	LAC	MSG
	XORL	CPHONE_ON
	BS	ACZ,LOCAL_PROTWR_PHONE	;免提

	LAC	PRO_VAR
	SFR	4
	ANDK	0X0F
	BS	ACZ,LOCAL_PROTWR0	;prompt
	SBHK	1
	BS	ACZ,LOCAL_PROTWR1	;record
	SBHK	1
	BS	ACZ,LOCAL_PROTWR2	;VOP/BEEP
	
	RET
LOCAL_PROTWR_PHONE:
	LAC	MSG
	CALL	STOR_MSG
	
	LACL	CRING_IN
	SAH	MSG
	
	BS	B1,LOCAL_PROTWR
;---------------
;LOCAL_PROREC_PMINE:
	LACL	CRING_IN
	CALL	STOR_MSG	;当来铃一样的处理
	
	RET
;---------------
LOCAL_PROTWR0:
	LAC	MSG
	XORL	CMSG_STOP		;MEMO key released worn and stop
	BS	ACZ,LOCAL_PROWORN
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROTWR0_RECSTART	;end beep and start record
	LAC	MSG
	XORL	CRING_IN		;RING
	BS	ACZ,LOCAL_PROTWR0_RING
	
	RET
;---------------
LOCAL_PROWORN:
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK
	CALL	BBBEEP
	
	LACK	0X0
	SAH	PRO_VAR
	
	CALL	VPMSG_CHK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	SEND_MSGNUM
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	RET
LOCAL_PROTWR0_RING:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACK	0X005
	CALL	STOR_VP
	
	LACK	0X0
	SAH	PRO_VAR
	
	CALL	VPMSG_CHK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	SEND_MSGNUM
;!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	RET
;---------------------------------------
LOCAL_PROTWR0_RECSTART:
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_REC

	LACL	CMODE9|(1<<9)	;demand ALC-on
	CALL	DAM_BIOSFUNC
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	1
	CALL	SEND_RECSTART		;(tell MCU)record start
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	REC_START
	LACL	1000
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1

	LACK	0X012
	SAH	PRO_VAR
	
	RET
;-------------------------------------------------------------------------------	
LOCAL_PROTWR1:
	LAC	MSG
	XORL	CMSG_STOP		;stop record
	BS	ACZ,LOCAL_PROTWR1_STOP
	LAC	MSG
	XORL	CREC_FULL		;full
	BS	ACZ,LOCAL_PROTWR1_MFUL
	LAC	MSG
	XORL	CMSG_TMR		;timer
	BS	ACZ,LOCAL_PROTWR1_TMR
	LAC	MSG
	XORL	CRING_IN		;RING
	BS	ACZ,LOCAL_PROTWR1_RING

	RET
;---------------
LOCAL_PROTWR1_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1

	RET
;---------------------------------------
LOCAL_PROTWR1_MFUL:
	CALL	SEND_MFULL	;Tell MCU memful
LOCAL_PROTWR1_STOP:
	LAC	PRO_VAR1
	SBHK	2
	BS	SGN,LOCAL_PROTWR1_FAILSTOP
				;录音成功(正常)退出
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK
	CALL	BBEEP
	
	LACL	CMODE9		;demand ALC-off
	CALL	DAM_BIOSFUNC
	
	CALL	VPMSG_CHK

	LACK	0X25
	SAH	PRO_VAR

	RET
LOCAL_PROTWR1_FAILSTOP:		;录音失败(非正常)退出
	LAC	CONF
	ORL	1<<11
	CALL	DAM_BIOSFUNC
	CALL	INIT_DAM_FUNC
	
	CALL	DAA_LIN_SPK
	CALL	BBBEEP
	
	LACL	CMODE9		;demand ALC-off
	CALL	DAM_BIOSFUNC
		
	LACK	0X025
	SAH	PRO_VAR
	
	RET
;---------------------------------------
;---------------------------------------
LOCAL_PROTWR1_RING:
	LAC	PRO_VAR1
	SBHK	3
	BS	SGN,LOCAL_PROTWR1_FAILRING
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACK	0X005
	CALL	STOR_VP
	
	LACL	CMODE9		;demand ALC-off
	CALL	DAM_BIOSFUNC

	LACK	0X0
	SAH	PRO_VAR
	
	CALL	VPMSG_CHK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	SEND_MSGNUM
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	RET
;---------------------------------------
LOCAL_PROTWR1_FAILRING:
	LAC	CONF
	ORL	1<<11
	CALL	DAM_BIOSFUNC
	CALL	INIT_DAM_FUNC
	
	CALL	DAA_OFF
	LACK	0X005
	CALL	STOR_VP
	
	LACK	0
	SAH	PRO_VAR
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	SEND_MSGNUM
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	RET
;---------------------------------------
LOCAL_PROTWR2:			;VOP/BBEEP
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROTWR2_VPSTOP
;LOCAL_PROREC2_1:
	LAC	MSG
	XORL	CMSG_STOP
	BS	ACZ,LOCAL_PROTWR2_VPSTOP	;
;LOCAL_PROREC2_2:
	LAC	MSG
	XORL	CRING_IN		;RING
	BS	ACZ,LOCAL_PROTWR2_STOP

	RET
;---------------------------------------
LOCAL_PROTWR2_VPSTOP:		;end play back
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACK	0X005
	CALL	STOR_VP

	LACK	0X0
	SAH	PRO_VAR

	CALL	VPMSG_CHK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	SEND_MSGNUM
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	RET
;---------------------------------------
LOCAL_PROTWR2_STOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACK	0X005
	CALL	STOR_VP

	CALL	VPMSG_CHK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	SEND_MSGNUM
;!!!!!!!!!!!!!!!!!!!!!!!!!!!		
	LACK	0X0
	SAH	PRO_VAR
	
	RET
;-------------------------------------------------------------------------------
.INCLUDE	block/l_plycomm.ASM
.INCLUDE	block/l_reccomm.ASM
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
.END
	