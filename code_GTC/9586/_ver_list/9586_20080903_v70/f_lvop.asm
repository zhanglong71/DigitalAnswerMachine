.NOLIST
.INCLUDE	include/REG_D22.inc
.INCLUDE	include/MD22U.inc
.INCLUDE	include/CONST.inc

.GLOBAL	LOCAL_PROCIDVP
.GLOBAL	LOCAL_PROKEYVP
;-------------------------------------------------------------------------------
.EXTERN	SYS_MSG_ANS
.EXTERN	SYS_MSG_RMT
;---------------------------------------
.EXTERN	GetOneConst

.EXTERN	INIT_DAM_FUNC

.EXTERN	DAM_BIOSFUNC
.EXTERN	DAM_STOP
.EXTERN	DELAY

.EXTERN	GET_LANGUAGE
.EXTERN	GET_MSG

.EXTERN	REQ_START

.EXTERN	LOCAL_PRO

.EXTERN	SET_TIMER
.EXTERN	STOR_MSG

;---
.LIST
;-------------------------------------------------------------------------------
.ORG	ADDR_SECOND
;-------------------------------------------------------------------------------

LOCAL_PROKEYVP:
	CALL	GET_RESPOND
	
	CALL	GET_MSG
	BS	ACZ,LOCAL_PROKEYVP_END
	SAH	MSG
;-------------------------------------------------------------------------------	
	LAC	MSG
	XORL	CMSG_KEY6S		;stop
	BS	ACZ,LOCAL_PROKEYVP_KEYSTOP
	LAC	MSG
	XORL	CRING_IN		;ring
	BS	ACZ,LOCAL_PROKEYVP_RING

	LAC	MSG
	XORL	CHOOK_OFF
	BS	ACZ,LOCAL_PROKEYVP_PHONE	;摘机
	LAC	MSG
	XORL	CPHONE_ON
	BS	ACZ,LOCAL_PROKEYVP_PHONE	;免提
	
	LAC	MSG
	XORL	CSEG_END
	BS	ACZ,LOCAL_PROKEYVP_SEGEND	;SEG-end
	LAC	MSG
	XORL	CMSG_SER
	BS	ACZ,LOCAL_PROKEYVP_SER		;SER
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROKEYVP_VPSTOP	;VP stop

	LAC	MSG
	XORL	CCID_VOP
	BS	ACZ,LOCAL_PROKEYVP_CIDVP	;play CID data
	LAC	MSG
	XORL	CKEY_VOP
	BS	ACZ,LOCAL_PROKEYVP_KEYVOP	;play KEY value
	
LOCAL_PROKEYVP_END:
	RET
;---------------------------------------
LOCAL_PROKEYVP_VPSTOP:
LOCAL_PROKEYVP_KEYSTOP:
LOCAL_PROCIDVP_KEYSTOP:
LOCAL_PROKEYVP_RING:
LOCAL_PROCIDVP_RING:
	CALL	INIT_DAM_FUNC
	CALL	CIDTALK_L
	CALL	DAA_OFF

	LAC	PRO_VAR	
	SFR	8
	ANDK	0X0F
	BS	ACZ,LOCAL_PROLVOP_END	;(0x0010 - No command)
	SBHK	1
	BS	ACZ,LOCAL_PROLVOP_END1	;(0x0110 - must send exit command)
	SBHK	1
	BS	ACZ,LOCAL_PROLVOP_END2	;(0x0210 - must send flash-msg command)
	SBHK	1
	BS	ACZ,LOCAL_PROLVOP_END3	;(0x0310 - must send flash-msg and exit command)
	
	BS	B1,LOCAL_PROLVOP_END	;(0x0y10 - No command)

LOCAL_PROLVOP_END1:
	CALL	EXIT_TOIDLE
	;LACK	30
	;CALL	DELAY
	BS	B1,LOCAL_PROLVOP_END
LOCAL_PROLVOP_END2:
	
	CALL	VPMSG_CHK
	CALL	SEND_MSGNUM
	
	;LACK	30
	;CALL	DELAY
	BS	B1,LOCAL_PROLVOP_END
LOCAL_PROLVOP_END3:
	
	CALL	VPMSG_CHK
	CALL	SEND_MSGNUM
	CALL	EXIT_TOIDLE
	
	;LACK	30
	;CALL	DELAY
	BS	B1,LOCAL_PROLVOP_END
LOCAL_PROLVOP_END:	
	LACK	0
	SAH	PRO_VAR
	SAH	PRO_VAR1
	LACL	500
	CALL	SET_TIMER
	
	RET
;---------------------------------------
LOCAL_PROKEYVP_SEGEND:
LOCAL_PROCIDVP_SEGEND:

	CALL	GET_VP
	BS	ACZ,LOCAL_PROKEYVP_SEGEND0
	CALL	INT_BIOS_START
	
	RET
LOCAL_PROKEYVP_SEGEND0:
	CALL	INIT_DAM_FUNC
	LACL	CVP_STOP		;通知系统播放完毕
	CALL	STOR_MSG

	RET
;---------------------------------------
LOCAL_PROKEYVP_KEYVOP:
LOCAL_PROCIDVP_KEYVOP:
	CALL	INIT_DAM_FUNC

	LACK	0X010
	SAH	PRO_VAR
	
	LAC	DTMF_VAL
	BS	ACZ,LOCAL_PRO0_KEYVOP_0
	SBHK	10
	BZ	SGN,LOCAL_PRO0_KEYVOP_LANGVOP
;LOCAL_PRO0_KEYVOP_DIGIVOP:	;(1..9)	
LOCAL_PRO0_KEYVOP_EXE:	
	CALL	DAA_SPK
	LAC	DTMF_VAL
	CALL	LOAD_CIDVP
	
	RET
LOCAL_PRO0_KEYVOP_0:
	CALL	GET_LANGUAGE
	BS	ACZ,LOCAL_PRO0_KEYVOP_EXE	;English "0"
;---Spanish/French "0"
	LACK	0X025
	CALL	STOR_VP
	
	RET
;---------------------------------------
LOCAL_PRO0_KEYVOP_LANGVOP:
	CALL	DAA_SPK

	LAC	DTMF_VAL
	XORK	0X70
	BS	ACZ,LOCAL_PRO0_KEYVOP_LANGVOP_MEMOHELP	;0x70
	SBHK	1
	BS	ACZ,LOCAL_PRO0_KEYVOP_ANSWEROFF		;0x71
	SBHK	1
	BS	ACZ,LOCAL_PRO0_KEYVOP_ANSWERON		;0x72
	SBHK	1
	BS	ACZ,LOCAL_PRO0_KEYVOP_SETUPMENU		;0x73
	SBHK	1
	BS	ACZ,LOCAL_PRO0_KEYVOP_POWERON		;0x74

	;CALL	BBBEEP
	LACK	0X005
	CALL	STOR_VP
	LACL	0X0110
	SAH	PRO_VAR

	RET
LOCAL_PRO0_KEYVOP_LANGVOP_MEMOHELP:

	CALL	VP_MemoHelp	;!!!you should send DAM dat to MCU
	LACL	0X0110
	SAH	PRO_VAR
	
	RET
LOCAL_PRO0_KEYVOP_ANSWERON:
	CALL	VP_AnswerOn
	LACL	0X0110
	SAH	PRO_VAR
	
	RET
LOCAL_PRO0_KEYVOP_ANSWEROFF:
	CALL	VP_AnswerOff
	LACL	0X0110
	SAH	PRO_VAR
	
	RET
LOCAL_PRO0_KEYVOP_SETUPMENU:
	CALL	VP_SetUpMenu
	LACK	0X010
	SAH	PRO_VAR
	
	RET
LOCAL_PRO0_KEYVOP_POWERON:
	CALL	VP_ElectrifyOn
	LACK	0X010
	SAH	PRO_VAR
	
	RET
;---------------------------------------
LOCAL_PROKEYVP_SER:
LOCAL_PROCIDVP_SER:
	CALL	GETR_DAT
	SAH	MSG
;---------------------------------------	
	LAC	MSG
	SBHK	0X30
	BS	SGN,LOCAL_PROKEYVP_SER_END	;0x00<= x <0x30
	SBHK	0X10
	BS	SGN,LOCAL_PROKEYVP_SER_0X3040	;0x30<= x <0x40
	SBHK	0X10
	BS	SGN,LOCAL_PROKEYVP_SER_0X4050	;0x40<= x <0x50
	SBHK	0X10
	BS	SGN,LOCAL_PROKEYVP_SER_0X5060	;0x50<= x <0x60
	SBHK	0X10
	BS	SGN,LOCAL_PROKEYVP_SER_0X6070	;0x60<= x <0x70
	SBHK	0X10
	BS	SGN,LOCAL_PROKEYVP_SER_0X7080	;0x70<= x <0x80
	SBHK	0X10
	BS	SGN,LOCAL_PROKEYVP_SER_0X8090	;0x80<= x <0x90
	
LOCAL_PROKEYVP_SER_END:	

	RET
;---------------------------------------
LOCAL_PROKEYVP_SER_0X3040:
LOCAL_PROKEYVP_SER_0X4050:
	LAC	MSG
	SBHK	0X4A
	BS	ACZ,LOCAL_PROKEYVP_SETVOL	;(0x4A)SetVol
	SBHK	0X03
	BS	ACZ,LOCAL_PROKEYVP_0X4D		;(0x4D)Set-up-menu
	
	RET

;-------------------
LOCAL_PROKEYVP_SETVOL:
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
LOCAL_PROKEYVP_SER_0X5060:
	LAC	MSG
	SBHK	0X50
	BS	ACZ,LOCAL_PROKEYVP_0X50	;(0x50)Answer on/off
	SBHK	0X04
	BS	ACZ,LOCAL_PROKEYVP_0X54	;(0x54)play
	SBHK	0X04
	BS	ACZ,LOCAL_PROKEYVP_0X58	;(0x58)MemoHelp
	SBHK	0X02
	BS	ACZ,LOCAL_PROKEYVP_0X5A	;(0x5A)stop
	SBHK	0X04
	BS	ACZ,LOCAL_PROKEYVP_0X5E	;(0x5E)Spkphone

	RET
LOCAL_PROKEYVP_0X50:
	CALL	GETR_DAT
	ANDK	0X7F		;!!!
	BS	ACZ,LOCAL_PROKEYVP_0X500X00
	SBHK	1
	BS	ACZ,LOCAL_PROKEYVP_0X500X01
	
	RET
	
LOCAL_PROKEYVP_0X54:
	CALL	INIT_DAM_FUNC
	LACL	CMSG_PLY	;play message
	CALL	STOR_MSG
	LACK	0
	SAH	PRO_VAR
	
	RET
;---------------------------------------
LOCAL_PROKEYVP_0X5A:	;(0x5A)stop
	LACL	CMSG_KEY6S
	CALL	STOR_MSG
	
	RET
;-------------------
LOCAL_PROKEYVP_0X5E:	
	CALL	GETR_DAT
	SBHK	1
	BS	ACZ,LOCAL_PROKEYVP_0X5E0X01
	RET
	
;-------------------
LOCAL_PROKEYVP_0X5E0X01:
	LACL	CPHONE_ON	;免提
	CALL	STOR_MSG

	RET
;---------------------------------------
LOCAL_PROKEYVP_SER_0X6070:
	LAC	MSG
	SBHK	0X60
	BS	ACZ,LOCAL_PROKEYVP_0X60	;(0x60)Handset
	
	RET
;-------------------
LOCAL_PROKEYVP_0X60:
	CALL	GETR_DAT
	ANDL	0X0FF
	SBHK	1
	BS	ACZ,LOCAL_PROKEYVP_0X600X01
	RET
LOCAL_PROKEYVP_0X600X01:
	LACL	CHOOK_OFF	;手柄提机
	CALL	STOR_MSG

	RET
;---------------------------------------
LOCAL_PROKEYVP_SER_0X7080:
LOCAL_PROKEYVP_SER_0X8090:
	RET
;---------------------------------------
LOCAL_PROKEYVP_0X4D:		;(0x4D)Set-up-menu
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	VP_SetUpMenu
	
	LACK	0x010
	SAH	PRO_VAR
	
	RET
;---------------------------------------
LOCAL_PROKEYVP_0X500X00:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	
	LAC	EVENT
	ORL	1<<9
	SAH	EVENT
	
	bs	b1,LOCAL_PRO0_KEYVOP_ANSWEROFF
	
;---------------------------------------
LOCAL_PROKEYVP_0X500X01:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK

	LAC	EVENT
	ANDL	~(1<<9)
	SAH	EVENT
	
	bs	b1,LOCAL_PRO0_KEYVOP_ANSWERON
	
;---------------------------------------
LOCAL_PROKEYVP_0X58:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	
	CALL	VP_MemoHelp	;!!!you should send DAM dat to MCU

	LACL	0x0110
	SAH	PRO_VAR
	
	RET
;---------------------------------------
LOCAL_PROKEYVP_0X6A:
	
	CALL	GETR_DAT
	ANDK	0X0F
	CALL	LOAD_CIDVP

	RET
;---------------------------------------
LOCAL_PROKEYVP_PHONE:
LOCAL_PROCIDVP_PHONE:
	LACK	0
	SAH	PRO_VAR
	
	LAC	MSG
	CALL	STOR_MSG

	RET
;-------------------------------------------------------------------------------
LOCAL_PROCIDVP:		;0Xyyy1
	CALL	GET_RESPOND
	
	CALL	GET_MSG
	BS	ACZ,LOCAL_PROCIDVP_END
	SAH	MSG
;-------------------------------------------------------------------------------
	LAC	MSG
	XORL	CMSG_KEY6S		;stop
	BS	ACZ,LOCAL_PROCIDVP_KEYSTOP
	LAC	MSG
	XORL	CRING_IN		;ring
	BS	ACZ,LOCAL_PROCIDVP_RING

	LAC	MSG
	XORL	CHOOK_OFF
	BS	ACZ,LOCAL_PROCIDVP_PHONE	;摘机
	LAC	MSG
	XORL	CPHONE_ON
	BS	ACZ,LOCAL_PROCIDVP_PHONE	;免提

	
	LAC	MSG
	XORL	CSEG_END
	BS	ACZ,LOCAL_PROCIDVP_SEGEND	;SEG-end
	LAC	MSG
	XORL	CMSG_SER
	BS	ACZ,LOCAL_PROCIDVP_SER		;SER
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROCIDVP_VPSTOP	;VP stop

	LAC	MSG
	XORL	CCID_VOP
	BS	ACZ,LOCAL_PROCIDVP_CIDVP	;play CID data
	LAC	MSG
	XORL	CKEY_VOP
	BS	ACZ,LOCAL_PROCIDVP_KEYVOP	;play KEY value
	
LOCAL_PROCIDVP_END:	
	RET
;---------------------------------------
LOCAL_PROCIDVP_VPSTOP:
	LAC	MSG_ID
	SBHK	9
	BZ	SGN,LOCAL_PROCIDVP_KEYSTOP	;over the length limited

	LACK	NEW1		;set base address
	SAH	ADDR_S

	LAC	MSG_ID				;next message
	ADHK	1
	SAH	MSG_ID
	ADHK	1
	SAH	COUNT		;note!!!
	CALL	GETBYTE_DAT

	SAH	MSG_N
	XORL	0X0FF
	BS	ACZ,LOCAL_PROCIDVP_KEYSTOP	;no valid CID

	LAC	MSG_N
	SFR	4
	ANDK	0X0F
	CALL	LOAD_CIDVP
	LAC	MSG_N
	ANDK	0X0F
	CALL	LOAD_CIDVP
	
	RET
;---------------------------------------
LOCAL_PROKEYVP_CIDVP:
LOCAL_PROCIDVP_CIDVP:
	
	CALL	INIT_DAM_FUNC
	CALL	CIDTALK_H
	CALL	DAA_SPK
	LACK	0X005
	CALL	STOR_VP

	LACL	RECE_BUF1	;the source base address
	SAH	ADDR_S
	LACK	NEW1		;the destination base address
	SAH	ADDR_D
	LACK	6
	CALL	MOVE_DAT
	
	LACK	0X020
	SAH	PRO_VAR
	
	LACK	0
	SAH	MSG_ID
	
	RET
;-------------------------------------------------------------------------------
.INCLUDE	l_beep/l_bbbeep.asm

.INCLUDE	l_CodecPath/l_allopen.asm
.INCLUDE	l_CodecPath/l_lply.asm

.INCLUDE	l_iic/l_getrqueue.asm
.INCLUDE	l_iic/l_storsqueue.asm
.INCLUDE	l_iic/l_flashmsg.asm
.INCLUDE	l_iic/l_exit.asm
;.INCLUDE	l_iic/l_testrqueue.asm

.INCLUDE	l_flashmsg/l_flashmsg.asm
.INCLUDE	l_flashmsg/l_biosfull.asm

.INCLUDE	l_math/l_hexdgt.asm
.INCLUDE	l_move/l_move.asm
.INCLUDE	l_move/l_getdata.asm

.INCLUDE	l_port/l_spkctl.asm
.INCLUDE	l_port/l_cidtalk.asm

.INCLUDE	l_respond/l_lply_resp.asm
.INCLUDE	l_respond/l_vpqueue.asm

.INCLUDE	l_table/l_voltable.asm


.INCLUDE	l_voice/l_keyvop.asm
.INCLUDE	l_voice/l_answeroff.asm
.INCLUDE	l_voice/l_answeron.asm
.INCLUDE	l_voice/l_loadhex.asm
.INCLUDE	l_voice/l_num.asm
.INCLUDE	l_voice/l_poweron.asm
;-------------------------------------------------------------------------------
.END
	