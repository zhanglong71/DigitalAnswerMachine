;-------------------------------------------------------------------------------
.NOLIST
;---------------------------------------
.INCLUDE	include.inc
;---------------------------------------
.GLOBAL	LOCAL_PROPLY
;-------------------------------------------------------------------------------
.EXTERN	SYS_MSG_ANS
.EXTERN	SYS_MSG_RMT
;---------------------------------------
.EXTERN	GetOneConst	;(INPUT=ACCH(ProgramRamAddress),OUTPUT=ACCH(ReadData))
;---
.LIST
;-------------------------------------------------------------------------------
.ORG	ADDR_SECOND
;-------------------------------------------------------------------------------
LOCAL_PROPLY:			;0Xyyy1
	CALL	GET_MSG
	BS	ACZ,LOCAL_PROPLY_END
	SAH	MSG
LOCAL_PROPLY_MSG:
;-------------------------------------------------------------------------------
	LAC	MSG
	XORL	CRING_IN		;ring
	BS	ACZ,LOCAL_PROPLY_RING
	LAC	MSG
	XORL	CMSG_SER
	BS	ACZ,LOCAL_PROPLY_SER	;SEG-end

	LAC	MSG
	XORL	CPLY_PAUSE		;Pause
	BS	ACZ,LOCAL_PROPLY_PAUSE
	
	LAC	MSG
	XORL	CMSG_EXIT		;exit
	BS	ACZ,LOCAL_PROPLY_STOP
	
	LAC	PRO_VAR
	SFR	4
	ANDK	0X03
	BS	ACZ,LOCAL_PROPLY_0	;(0X0y01)idle before play
	SBHK	1
	BS	ACZ,LOCAL_PROPLY_1	;(0X0y11)playing
	SBHK	1
	BS	ACZ,LOCAL_PROPLY_2	;(0X0y21)pause
LOCAL_PROPLY_END:
	RET
;-------------------------------------------------------------------------------
;PRO_VAR	(bit3..0)
;		(bit5..4)	
;		(bit7..6)	- reserved
;		bit(9..8)
;		(bit11..10)	- reserved
;-------------------------------------------------------------------------------
LOCAL_PROPLY_0:	
	LAC	MSG
	XORL	CMSG_PLY		;Record message
	BS	ACZ,LOCAL_PROPLY_0_START
	
	RET
;---------------------------------------
LOCAL_PROPLY_0_START:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	SILENCE40MS_VP
	
	LACL	1000
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1
	LACK	0X0011
	SAH	PRO_VAR	

	LACK	0
	SAH	MSG_ID
	SAH	MSGLED_FG

	CALL	VPMSG_CHK		;进入播放子功能
	BIT	ANN_FG,12
	BS	TB,LOCAL_PRO0_PLAY_NEW
	BIT	ANN_FG,14
	BS	TB,LOCAL_PRO0_PLAY_OLD
LOCAL_PRO0_PLYMSG_NO:

	CALL	BBEEP
	LACL	0X0211
	SAH	PRO_VAR	
	
	RET
;-------play new messages
LOCAL_PRO0_PLAY_NEW:
	RET
;-------play old messages
LOCAL_PRO0_PLAY_OLD:	
	RET
;---------------------------------------
LOCAL_PROPLY_PAUSE:
	LAC	CONF
	SFR	12
	ANDK	0X0F
	SBHK	0X02
	BS	ACZ,LOCAL_PROPLY_PAUSE_0X2000
	SBHK	0X09
	BS	ACZ,LOCAL_PROPLY_PAUSE_0XB000
	
	LAC	MSG
	CALL	STOR_MSG
	RET
;---------------------------------------
LOCAL_PROPLY_PAUSE_0X2000:
LOCAL_PROPLY_PAUSE_0XB000:
	LAC	CONF
	ORL	1<<8
	SAH	CONF
	
	LAC	PRO_VAR
	ANDL	0XFF0F
	ORL	0X0020
	SAH	PRO_VAR
	
	LACL	CTMR1S
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROPLY_1:			;playing
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PROPLY_TMR

	LAC	PRO_VAR
	SFR	8
	ANDK	0X03
	BS	ACZ,LOCAL_PROPLY_1_0	;(0X0011)playing Vop
	SBHK	1
	BS	ACZ,LOCAL_PROPLY_1_1	;(0X0111)playing Message
	SBHK	1
	BS	ACZ,LOCAL_PROPLY_1_2	;(0X0211)End playing Message VOP/no message
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROPLY_1_0:
	LAC	MSG
	XORL	CVP_STOP		;PLAY END
	BS	ACZ,LOCAL_PROPLY_0_OVER
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROPLY_0_OVER:
	
	LACL	0X0111
	SAH	PRO_VAR
	BS	B1,LOCAL_PROPLY_OVER
;---------------------------------------
LOCAL_PROPLY_1_1:
	LAC	MSG
	XORL	CVP_STOP		;PLAY END
	BS	ACZ,LOCAL_PROPLY_OVER
	
	LAC	MSG
	XORL	CPLY_NEXT		;play next message
	BS	ACZ,LOCAL_PROPLY_NEXT
	LAC	MSG
	XORL	CPLY_REPT		;repeat message
	BS	ACZ,LOCAL_PROPLY_REPT
	
	LAC	MSG
	XORL	CPLY_PREV		;previous message
	BS	ACZ,LOCAL_PROPLY_PREV
	
	LAC	MSG
	XORL	CPLY_ERAS		;PLAY END
	BS	ACZ,LOCAL_PROPLY_ERAS

	RET
;-------------------------------------------------------------------------------
LOCAL_PROPLY_1_2:		;End of messages
	LAC	MSG
	XORL	CVP_STOP		;PLAY END
	BS	ACZ,LOCAL_PROPLY_1_2_VPSTOP

	RET
;---------------------------------------
LOCAL_PROPLY_1_2_VPSTOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	CALL	SILENCE40MS_VP

	CALL	CLR_TIMER
	
	LACK	0
	SAH	PRO_VAR

	LACK	10		;normal speed
	CALL	SET_PLYPSA	;Clear Fast play flag(no matter it has been set or not)

	LACL	CMSG_INIT
	CALL	STOR_MSG

	CALL	VPMSG_CHK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	SEND_MSGNUM
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	MSGLED_IDLE

	RET	
;-------------------------------------------------------------------------------
LOCAL_PROPLY_NEXT:
	BS	B1,LOCAL_PROPLY_OVER
;---------------------------------------
LOCAL_PROPLY_REPT:
	CALL	INIT_DAM_FUNC

	BS	B1,LOCAL_PROPLY_LOADVP
;---------------------------------------
LOCAL_PROPLY_PREV:
	LAC	MSG_ID
	BS	ACZ,LOCAL_PROPLY_REW_NOACTION	;start ?
	
	CALL	INIT_DAM_FUNC

	LAC	MSG_ID
	SBHK	1
	SAH	MSG_ID
	
	BS	B1,LOCAL_PROPLY_LOADVP

LOCAL_PROPLY_REW_NOACTION:
	RET
;---------------------------------------
LOCAL_PROPLY_PSADN:
	LACK	20		;speed down 100%
	CALL	SET_PLYPSA

	RET
;---------------------------------------
LOCAL_PROPLY_PSANORAMAL:
	LACK	10		;normal speed
	CALL	SET_PLYPSA

	RET
;---------------------------------------
LOCAL_PROPLY_ERAS:		;删除后放下一条
	CALL	INIT_DAM_FUNC
	
	BIT	ANN_FG,12
	BZ	TB,LOCAL_PROPLY_ERASE_RTOTAL
;LOCAL_PROPLY_ERASE_RNEW:	;the MSG_ID is related to new messages
	LAC	MSG_ID
	ORL	0X2480
	CALL	DAM_BIOSFUNC
	BS	B1,LOCAL_PROPLY_ERASEDONE
LOCAL_PROPLY_ERASE_RTOTAL:	;the MSG_ID is related to total messages
	LAC	MSG_ID
	ORL	0X2080
	CALL	DAM_BIOSFUNC
LOCAL_PROPLY_ERASEDONE:
	CALL	INIT_DAM_FUNC
	CALL	SILENCE40MS_VP
	
	LACL	0X0111
	SAH	PRO_VAR

	RET
;---------------------------------------
LOCAL_PROPLY_OVER:
	CALL	INIT_DAM_FUNC

	CALL	PLY_OVER_CHK		;Check if play over ?
	BS	ACZ,LOCAL_PROPLY_OVEREND

	LAC	MSG_ID			;next message
	ADHK	1
	SAH	MSG_ID
;---------------------------------------!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
LOCAL_PROPLY_LOADVP:
	CALL	SEND_MSGID	;send MSG_ID
	CALL	BEEP
	CALL	STOR_MESSAGE
	CALL	STOR_TIMETAG
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROPLY_2:			;Pause /-no need
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PROPLY_2_TMR

	LAC	MSG
	XORL	CMSG_PLY
	BS	ACZ,LOCAL_PROPLY_2_PLY
	
	RET
;---------------------------------------
LOCAL_PROPLY_2_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	8
	BZ	SGN,LOCAL_PROPLY_OVEREND
	
	RET
;---------------------------------------
LOCAL_PROPLY_2_PLY:	;Continue play from pause status

	LAC	CONF
	ANDL	~(1<<8)
	SAH	CONF
	
	LAC	PRO_VAR
	ANDL	0XFF0F
	ORL	0X0010
	SAH	PRO_VAR
	
	CALL	CLR_TIMER
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROPLY_STOP:		;强行退出Play-Mode,Exit (beep,but no VOP )
	CALL	INIT_DAM_FUNC
	LACL	0X6100
	CALL	DAM_BIOSFUNC
	CALL	GC_CHK

	BS	B1,LOCAL_PROPLY_STOP_2
;---------------
LOCAL_PROPLY_OVEREND:		;全播放完毕或Play-Mode,Exit (VOP,but no beep)	
	CALL	INIT_DAM_FUNC
	LACL	0X6100
	CALL	DAM_BIOSFUNC
	CALL	GC_CHK
	CALL	VPMSG_CHK	;check memfull
	
	BIT	ANN_FG,13
	BZ	TB,LOCAL_PROPLY_STOP_2
	CALL	VP_MemoryIsFull		;End of playback requery VOP
LOCAL_PROPLY_STOP_2:
	CALL	BBEEP
	CALL	CLR_TIMER
	LACL	0X0211
	SAH	PRO_VAR

	RET
;---------------------------------------
LOCAL_PROPLY_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	
	RET
;---------------------------------------
LOCAL_PROPLY_RING:		;Exit immediately(no beep,no VOP)
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	CALL	SILENCE40MS_VP
	
	CALL	CLR_TIMER	
	LACK	0
	SAH	PRO_VAR
;------	------
	LACK	10		;normal speed
	CALL	SET_PLYPSA	;Clear Fast play flag(no matter it has been set or not)
;------	------	
	LACL	0X6100
	CALL	DAM_BIOSFUNC
	CALL	GC_CHK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	CALL	VPMSG_CHK
	CALL	SEND_MSGNUM
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	100
	CALL	DELAY

	CALL	MSGLED_IDLE

	RET
;---------------------------------------
PROPLY_TAB:
.data	LOCAL_PROPLY_SER_0X41	;(0x41)Play
.data	LOCAL_PROPLY_SER_0X42	;(0x42)Pause
.data	LOCAL_PROPLY_SER_0X43	;(0x43)skip
.data	LOCAL_PROPLY_SER_0X44	;(0x44)repeat
.data	LOCAL_PROPLY_SER_0X45
.data	LOCAL_PROPLY_SER_0X46
.data	LOCAL_PROPLY_SER_0X47
.data	LOCAL_PROPLY_SER_0X48
.data	LOCAL_PROPLY_SER_0X49
.data	LOCAL_PROPLY_SER_0X4A
.data	LOCAL_PROPLY_SER_0X4B
.data	LOCAL_PROPLY_SER_0X4C	;(0x4C)Delete
.data	LOCAL_PROPLY_SER_0X4D
.data	LOCAL_PROPLY_SER_0X4E	;(0x4E)Set speed
.data	LOCAL_PROPLY_SER_0X4F	;(0x4F)SetVol
.data	LOCAL_PROPLY_SER_0X50	;(0x50)HF
.data	LOCAL_PROPLY_SER_0X51	;(0x51)HS
.data	LOCAL_PROPLY_SER_0X52
.data	LOCAL_PROPLY_SER_0X53
.data	LOCAL_PROPLY_SER_0X54	;(0x54)stop
;-------------------
LOCAL_PROPLY_SER:
	CALL	GETR_DAT
	SBHK	0X41
	SAH	MSG
	BS	SGN,LOCAL_PROPLY_SER_OVER		;0x00<= x <0x40
	SBHK	0X14
	BZ	SGN,LOCAL_PROPLY_SER_OVER		;0x06<= x --
;---Less than (0x42 < x <0x54)
	LAC	MSG
	ADHL	PROPLY_TAB
	CALL	GetOneConst
	ADHK	0
	BACC		;jump to ...	
;---------------------------------------
LOCAL_PROPLY_SER_0X46:
LOCAL_PROPLY_SER_0X47:
LOCAL_PROPLY_SER_0X48:
LOCAL_PROPLY_SER_0X49:
LOCAL_PROPLY_SER_0X4A:
LOCAL_PROPLY_SER_0X4B:
LOCAL_PROPLY_SER_0X4D:
	
LOCAL_PROPLY_SER_0X52:
LOCAL_PROPLY_SER_0X53:
	
LOCAL_PROPLY_SER_OVER:
	RET

;-------------------
LOCAL_PROPLY_SER_0X41:
	LACL	CMSG_PLY
	CALL	STOR_MSG
	
	RET
;-------------------
LOCAL_PROPLY_SER_0X42:
	LACL	CPLY_PAUSE
	CALL	STOR_MSG
	
	RET
;-------------------
LOCAL_PROPLY_SER_0X43:
	LACL	CPLY_NEXT
	CALL	STOR_MSG
	
	RET
;-------------------
LOCAL_PROPLY_SER_0X44:
	LACL	CPLY_PREV
	CALL	STOR_MSG
	
	RET
;-------------------
LOCAL_PROPLY_SER_0X45:
	LACL	CPLY_REPT
	CALL	STOR_MSG
	
	RET
;-------------------
LOCAL_PROPLY_SER_0X4C:	;(0x5B)delete
	LACL	CPLY_ERAS
	CALL	STOR_MSG
	
	RET
;-------------------
LOCAL_PROPLY_SER_0X4E:
	CALL	GETR_DAT
	ANDK	0X01f
	CALL	SET_PLYPSA

	RET
;-------------------
LOCAL_PROPLY_SER_0X4F:
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
LOCAL_PROPLY_SER_0X50:
	CALL	GETR_DAT
	ANDK	0X07
	SBHK	1
	BS	ACZ,LOCAL_PROPLY_0X500X01
	SBHK	1
	BS	ACZ,LOCAL_PROPLY_0X500X02
	
	RET
LOCAL_PROPLY_0X500X01:		;Speaker-on and mute-on
	LAC	EVENT
	ANDL	~(1<<2)
	SAH	EVENT	;Unmute
LOCAL_PROPLY_0X50PHONE:	

	LACL	CHF_WORK
	CALL	STOR_MSG
	
	LACL	CRING_IN
	SAH	MSG
	BS	B1,LOCAL_PROPLY_MSG
LOCAL_PROPLY_0X500X02:		;Speaker-on and mute-off

	LAC	EVENT
	ORL	(1<<2)
	SAH	EVENT	;Mute
	BS	B1,LOCAL_PROPLY_0X50PHONE
;-------------------
LOCAL_PROPLY_SER_0X51:
	CALL	GETR_DAT
	ANDK	0X07
	BS	ACZ,LOCAL_PROPLY_0X510X00
	SBHK	1
	BS	ACZ,LOCAL_PROPLY_0X510X01
	
	RET
LOCAL_PROPLY_0X510X00:		;hook-on
	LACL	CHS_IDLE
	CALL	STOR_MSG

	RET
LOCAL_PROPLY_0X510X01:		;hook-off
	LACL	CHS_WORK
	CALL	STOR_MSG

	LACL	CRING_IN
	SAH	MSG
	BS	B1,LOCAL_PROPLY_MSG
;-------------------
LOCAL_PROPLY_SER_0X54:	;(0x54)stop
	LACL	CMSG_EXIT
	CALL	STOR_MSG
	
	RET
;-------------------------------------------------------------------------------
;	function: PLY_OVER_CHK
;
;	input : no
;	output:	ACCH = 0/~0 - plau over/not
;-------------------------------------------------------------------------------
PLY_OVER_CHK:
	
	LAC	MSG_N
	BIT	ANN_FG,12
	BS	TB,PLY_OVER_CHK_NEW
	LAC	MSG_T
PLY_OVER_CHK_NEW:
	SBH	MSG_ID

	RET
;-------------------------------------------------------------------------------
;	function: STOR_MESSAGE
;
;	input : no
;	output:	no
;-------------------------------------------------------------------------------
STOR_MESSAGE:
	LAC	MSG_ID
	ANDK	0X7F
	SAH	SYSTMP1
	
	LACL	0XFD00
	BIT	ANN_FG,12
	BS	TB,STOR_MESSAGE_NEW
	LACL	0XFE00
STOR_MESSAGE_NEW:
	OR	SYSTMP1
	CALL	STOR_VP
	
	RET

;-------------------------------------------------------------------------------
.INCLUDE	l_iic/l_getrqueue.asm
.INCLUDE	l_iic/l_storsqueue.asm
.INCLUDE	l_iic/l_flashmsg.asm

.INCLUDE	l_flashmsg/l_plymsg.asm
.INCLUDE	l_flashmsg/l_plyspeed.asm

.INCLUDE	l_math/l_hexdgt.asm

.INCLUDE	l_port/l_spkctl.asm
.INCLUDE	l_port/l_msgled.asm

.INCLUDE	l_voice/l_endof.asm
.INCLUDE	l_voice/l_num.asm
.INCLUDE	l_voice/l_plymsg.asm
.INCLUDE	l_voice/l_memfull.asm


;-------------------------------------------------------------------------------
.END
	