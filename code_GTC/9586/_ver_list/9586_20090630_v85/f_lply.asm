;-------------------------------------------------------------------------------
.NOLIST
.INCLUDE	include/REG_D22.inc
.INCLUDE	include/MD22U.inc
.INCLUDE	include/CONST.inc
.INCLUDE	include/EXTERN.inc

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

	CALL	GET_RESPOND
	
	CALL	GET_MSG
	BS	ACZ,LOCAL_PROPLY_END
	SAH	MSG
;-------------------------------------------------------------------------------
	LAC	MSG
	XORL	CRING_IN		;ring
	BS	ACZ,LOCAL_PROPLY_RING

	LAC	MSG
	XORL	CSEG_END
	BS	ACZ,LOCAL_PROPLY_SEGEND	;SEG-end
	LAC	MSG
	XORL	CMSG_SER
	BS	ACZ,LOCAL_PROPLY_SER	;SEG-end

	LAC	PRO_VAR
	SFR	4
	ANDK	0X0F
	BS	ACZ,LOCAL_PROPLY_0	;(0X0y01)idle before play
	SBHK	1
	BS	ACZ,LOCAL_PROPLY_1	;(0X0y11)playing
LOCAL_PROPLY_END:
	RET
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
	CALL	VP_YouHave
	;LACK	0X005
	;CALL	STOR_VP
	;CALL	SET_MSGLEDFG	;

	
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
	;CALL	INIT_DAM_FUNC
	;CALL	DAA_SPK
	;CALL	VP_YouHave
	CALL	VP_No
	CALL	VP_Messages
	
	LACL	0X0211
	SAH	PRO_VAR	
	
	CALL	GET_LANGUAGE
	SBHK	1
	BS	ACZ,LOCAL_PRO0_PLYMSG_NO_French	;French
	
	RET
;-------French-VOP "you have no message"
LOCAL_PRO0_PLYMSG_NO_French:
	CALL	INIT_DAM_FUNC
	CALL	VP_Youhavenomessage
	
	RET
;-------play new messages
LOCAL_PRO0_PLAY_NEW:
	LAC	MSG_N
	SBHK	1
	BS	ACZ,LOCAL_PRO0_PLAY_ONENEW
	
	LAC	MSG_N
	CALL	ANNOUNCE_NUM
	CALL	VP_NewMessages
	
	RET
LOCAL_PRO0_PLAY_ONENEW:
	LAC	MSG_N
	CALL	ANNOUNCE_NUM
	CALL	VP_NewMessage		;VP_New

	RET

;-------play old messages
LOCAL_PRO0_PLAY_OLD:
	LAC	MSG_T
	SBHK	1
	BS	ACZ,LOCAL_PRO0_PLAY_ONEALL

	LAC	MSG_T
	CALL	ANNOUNCE_NUM
	CALL	VP_Messages
	
	RET
LOCAL_PRO0_PLAY_ONEALL:
	LAC	MSG_T
	CALL	ANNOUNCE_NUM
	CALL	VP_Message

	RET
;-------------------------------------------------------------------------------
LOCAL_PROPLY_1:			;playing
;LOCAL_PROPLY_2:			;Pause /-no need
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PROPLY_TMR

	LAC	PRO_VAR
	SFR	8
	ANDK	0X0F
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
	LAC	ERR_FG
	ANDL	~(1)
	SAH	ERR_FG
	
	LACL	0X0111
	SAH	PRO_VAR
	BS	B1,LOCAL_PROPLY_OVER
;---------------------------------------
LOCAL_PROPLY_1_1:
	LAC	MSG
	XORL	CVP_STOP		;PLAY END
	BS	ACZ,LOCAL_PROPLY_OVER

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
	LACK	0X005
	CALL	STOR_VP

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
	BIT	ERR_FG,1
	BS	TB,LOCAL_PROPLY_0_2_ERROR	;Error exist, Don`t send exit command
	CALL	EXIT_TOIDLE
LOCAL_PROPLY_0_2_ERROR:
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	MSGLED_IDLE

	RET	

;-------------------------------------------------------------------------------
;---------------------------------------
LOCAL_PROPLY_FFW:

	LAC	MSG_ID
	BS	ACZ,LOCAL_PROPLY_REW_NOACTION	;start ?
	
	CALL	PLY_FFWREW_CHK			;Check play error data
	
	BS	B1,LOCAL_PROPLY_OVER
;---------------------------------------
LOCAL_PROPLY_REW:

	LAC	MSG_ID
	BS	ACZ,LOCAL_PROPLY_REW_NOACTION	;start ?
	
	CALL	PLY_FFWREW_CHK	;Check play error data
	CALL	INIT_DAM_FUNC
	
	;LAC	PRO_VAR
	;ANDL	0XFF0F
	;SAH	PRO_VAR		;?????????

	LACL	1000
	CALL	SET_TIMER

	LAC	MSG_ID
	BS	ACZ,LOCAL_PROPLY_REWEXE_2	;start ?
	SBHK	1
	BS	ACZ,LOCAL_PROPLY_REWEXE_2	;The first one ?

	LAC	PRO_VAR1
	SBHK	2
	BZ	SGN,LOCAL_PROPLY_REWEXE_2	;two tap in two second
				;don`t clear timer counter if less 2 seconds
	LAC	MSG_ID
	SBHK	1
	SAH	MSG_ID
LOCAL_PROPLY_REWEXE_1:		;
	BIT	ANN_FG,12
	BZ	TB,LOCAL_PROPLY_LOADVP
	BS	B1,LOCAL_PROPLY_LOADNEWVP
LOCAL_PROPLY_REWEXE_2:	
	LACK	0		;clear timer counter if over 2 seconds
	SAH	PRO_VAR1
	BS	B1,LOCAL_PROPLY_REWEXE_1
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
	CALL	DAA_SPK
	CALL	VP_Message
	CALL	VP_Erased
	LACK	0X005
	CALL	STOR_VP
	
	LACL	0X0111
	SAH	PRO_VAR

	RET
;---------------------------------------
LOCAL_PROPLY_OVER:
	
	BIT	ANN_FG,12
	BS	TB,LOCAL_PROPLY_OVERNEW

	CALL	INIT_DAM_FUNC

	LAC	MSG_ID
	SBH	MSG_T
	BZ	SGN,LOCAL_PROPLY_OVEREND

	LAC	MSG_ID			;next message
	ADHK	1
	SAH	MSG_ID
;---------------------------------------!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
LOCAL_PROPLY_LOADVP:

	CALL	VP_Message
	LAC	MSG_ID
	CALL	ANNOUNCE_NUM
	
	CALL	SEND_MSGID	;send MSG_ID
	;CALL	SEND_MSGATT	;sedn year-month-day-hour-minute
	
	CALL	MSG_WEEK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	GET_LANGUAGE
	SBHK	1
	BZ	ACZ,LOCAL_PROPLY_LOADVP_1	;Not French
;---French(24-hour format)
	LAC	MSG_ID
	ORL	0XA200
	CALL	DAM_BIOSFUNC
	CALL	VP_HourFre
	
	LAC	MSG_ID
	ORL	0XA100
	CALL	DAM_BIOSFUNC
	CALL	VP_MinutFre
	
	BS	B1,LOCAL_PROPLY_LOADVP_2
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
LOCAL_PROPLY_LOADVP_1:	
	CALL	MSG_HOUR
	CALL	MSG_MIN
	CALL	MSG_AMPM
LOCAL_PROPLY_LOADVP_2:
	LAC	MSG_ID
	ORL	0XFE00
	CALL	STOR_VP
	
	RET

;---------------------------------------
LOCAL_PROPLY_OVERNEW:
	CALL	INIT_DAM_FUNC
	
	LAC	MSG_ID
	SBH	MSG_N
	BZ	SGN,LOCAL_PROPLYNEW_STOP

	LAC	MSG_ID			;next message
	ADHK	1
	SAH	MSG_ID

;---------------------------------------!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
LOCAL_PROPLY_LOADNEWVP:
	;LAC	MSG_ID
	;CALL	LED_HLDISP
	
	CALL	VP_Message
	LAC	MSG_ID
	CALL	ANNOUNCE_NUM

	CALL	SEND_MSGID	;send MSG_ID
	;CALL	SEND_MSGATTNEW	;sedn year-month-day-hour-minute
	
	CALL	MSG_WEEKNEW
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	GET_LANGUAGE
	SBHK	1
	BZ	ACZ,LOCAL_PROPLY_LOADNEWVP_1	;Not French
;---French(24-hour format)
	LAC	MSG_ID
	ORL	0XA280
	CALL	DAM_BIOSFUNC
	CALL	VP_HourFre
	
	LAC	MSG_ID
	ORL	0XA180
	CALL	DAM_BIOSFUNC
	CALL	VP_MinutFre
	
	BS	B1,LOCAL_PROPLY_LOADNEWVP_2
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
LOCAL_PROPLY_LOADNEWVP_1:
	CALL	MSG_HOURNEW
	CALL	MSG_MINNEW
	CALL	MSG_AMPMNEW
LOCAL_PROPLY_LOADNEWVP_2:
	LAC	MSG_ID
	ORL	0XFD00
	CALL	STOR_VP
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROPLY_STOP:		;强行退出Play-Mode,Exit (beep,but no VOP )
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP

	LACL	0X6100
	CALL	DAM_BIOSFUNC

	CALL	GC_CHK

	BS	B1,LOCAL_PROPLY_STOP_2
;---------------
LOCAL_PROPLY_OVEREND:		;全播放完毕或Play-Mode,Exit (VOP,but no beep)
	BIT	ANN_FG,12
	BS	TB,LOCAL_PROPLYNEW_STOP
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	VP_EndOf
	CALL	VP_Messages
	BS	B1,LOCAL_PROPLY_STOP_1
LOCAL_PROPLYNEW_STOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	VP_EndOf
	CALL	VP_NewMessages
	;BS	B1,LOCAL_PROPLY_STOP_1
LOCAL_PROPLY_STOP_1:	
	LACL	0X6100
	CALL	DAM_BIOSFUNC
	CALL	GC_CHK
	CALL	PLYERR_CHK	;Must called before "VPMSG_CHK"
	
	CALL	VPMSG_CHK	;check memfull
	
	BIT	ANN_FG,13
	BZ	TB,LOCAL_PROPLY_STOP_2
	CALL	VP_MemoryIsFull		;End of playback requery VOP
LOCAL_PROPLY_STOP_2:
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
	LACK	0X005
	CALL	STOR_VP

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
	
	CALL	VPMSG_CHK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	SEND_MSGNUM
	CALL	EXIT_TOIDLE
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	MSGLED_IDLE

	RET
;---------------------------------------
LOCAL_PROPLY_SEGEND:	
	CALL	GET_VP
	BS	ACZ,LOCAL_PROPLY_SEGEND0
	CALL	INT_BIOS_START
	
	RET
LOCAL_PROPLY_SEGEND0:
	CALL	INIT_DAM_FUNC
	LACL	CVP_STOP		;通知系统播放完毕
	CALL	STOR_MSG
	
	RET
;---------------------------------------
LOCAL_PROPLY_SER:
	CALL	GETR_DAT
	ANDL	0XFF
	SAH	MSG
;---------------------------------------	
	LAC	MSG
	SBHK	0X30
	BS	SGN,LOCAL_PROPLY_SER_END		;0x00<= x <0x30
	SBHK	0X10
	BS	SGN,LOCAL_PROPLY_SER_0X3040	;0x30<= x <0x40
	SBHK	0X10
	BS	SGN,LOCAL_PROPLY_SER_0X4050	;0x40<= x <0x50
	SBHK	0X10
	BS	SGN,LOCAL_PROPLY_SER_0X5060	;0x50<= x <0x60
	SBHK	0X10
	BS	SGN,LOCAL_PROPLY_SER_0X6070	;0x60<= x <0x70
	SBHK	0X10
	BS	SGN,LOCAL_PROPLY_SER_0X7080	;0x70<= x <0x80
	SBHK	0X10
	BS	SGN,LOCAL_PROPLY_SER_0X8090	;0x80<= x <0x90
	
LOCAL_PROPLY_SER_END:	
	RET
;---------------------------------------
LOCAL_PROPLY_SER_0X3040:
LOCAL_PROPLY_SER_0X4050:
	LAC	MSG
	SBHK	0X4A
	BS	ACZ,LOCAL_PROPLY_SETVOL		;(0x4A)SetVol
	SBHK	0X01
	BS	ACZ,LOCAL_PROPLY_SETHFVOL	;(0X4B)HF-vol
	
	RET
;-------------------
LOCAL_PROPLY_SETHFVOL:		;not in spkphone mode set Speakerphone volume (GTC demand;2009-6-30 20:42)
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
;-------------------
LOCAL_PROPLY_SETVOL:
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
LOCAL_PROPLY_SER_0X5060:
	LAC	MSG
	SBHK	0X56
	BS	ACZ,LOCAL_PROPLY_FFW	;(0x56)skip to next message
	SBHK	0X01
	BS	ACZ,LOCAL_PROPLY_REW	;(0x57)repeat/previous
	SBHK	0X03
	BS	ACZ,LOCAL_PROPLY_STOP	;(0x5A)stop
	SBHK	0X01
	BS	ACZ,LOCAL_PROPLY_ERAS	;(0x5B)message delete
	SBHK	0X03
	BS	ACZ,LOCAL_PROPLY_0X5E	;(0x5E)message delete

	RET
;-------------------
LOCAL_PROPLY_0X5E:	
	CALL	GETR_DAT
	ANDL	0X0FF
	SBHK	1
	BS	ACZ,LOCAL_PROPLY_0X5E0X01
	RET
;-------------------
LOCAL_PROPLY_0X5E0X01:
	LACL	CPHONE_ON	;免提
	CALL	STOR_MSG

	BS	B1,LOCAL_PROPLY_RING
;---------------------------------------
LOCAL_PROPLY_SER_0X6070:
	LAC	MSG
	SBHK	0X60
	BS	ACZ,LOCAL_PROPLY_0X60	;(0x60)Handset
	SBHK	0X02
	BS	ACZ,LOCAL_PROPLY_PSADN	;(0x62)Slow-100% playspeed
	SBHK	0X01
	BS	ACZ,LOCAL_PROPLY_PSANORAMAL	;(0x63)normal playspeed
	
	RET
;-------------------
LOCAL_PROPLY_0X60:
	CALL	GETR_DAT
	ANDL	0X0FF
	SBHK	1
	BS	ACZ,LOCAL_PROPLY_0X600X01
	RET
LOCAL_PROPLY_0X600X01:
	LACL	CHOOK_OFF	;手柄提机
	CALL	STOR_MSG

	BS	B1,LOCAL_PROPLY_RING
;---------------------------------------
LOCAL_PROPLY_SER_0X7080:
LOCAL_PROPLY_SER_0X8090:
	RET

;-------------------------------------------------------------------------------
PLY_FFWREW_CHK:		;Check skip/repeat
	LAC	ERR_FG
	ORK	1
	SAH	ERR_FG

	RET
;-------------------------------------------------------------------------------
;	Input : MSG_N
;	Used before VPMSG_CHK
;-------------------------------------------------------------------------------
PLYERR_CHK:		;Check new message played or not
	
	BIT	ANN_FG,12
	BZ	TB,PLYERR_CHK_END	;No new-message
	BIT	ERR_FG,0
	BS	TB,PLYERR_CHK_END	;skip/repeat KEY  pressed
;---	
	LACL	0X3001
	CALL	DAM_BIOSFUNC
	BS	ACZ,PLYERR_CHK_END	;No new message
	SBH	MSG_N
	BZ	ACZ,PLYERR_CHK_END
;---The number of New message 没减少
	LAC	ERR_FG
	ORK	1<<1
	SAH	ERR_FG
	
	LACL	0X27
	CALL	SEND_DAT
	LACL	0X27
	CALL	SEND_DAT
PLYERR_CHK_END:

	RET

;-------------------------------------------------------------------------------

.INCLUDE	l_beep/l_beep.asm
.INCLUDE	l_beep/l_bbeep.asm
;.INCLUDE	l_beep/l_bbbeep.asm
;.INCLUDE	l_beep/l_lbeep.asm
;.INCLUDE	l_beep/l_errbeep.asm

.INCLUDE	l_CodecPath/l_allopen.asm
.INCLUDE	l_CodecPath/l_lply.asm

.INCLUDE	l_iic/l_getrqueue.asm
.INCLUDE	l_iic/l_storsqueue.asm
.INCLUDE	l_iic/l_flashmsg.asm
.INCLUDE	l_iic/l_exit.asm

.INCLUDE	l_flashmsg/l_plymsg.asm
.INCLUDE	l_flashmsg/l_flashmsg.asm
.INCLUDE	l_flashmsg/l_biosfull.asm
.INCLUDE	l_flashmsg/l_plyspeed.asm

.INCLUDE	l_math/l_hexdgt.asm

.INCLUDE	l_port/l_spkctl.asm
.INCLUDE	l_port/l_msgled.asm

.INCLUDE	l_respond/l_lply_resp.asm
.INCLUDE	l_respond/l_vpqueue.asm

.INCLUDE	l_table/l_voltable.asm

.INCLUDE	l_voice/l_endof.asm
.INCLUDE	l_voice/l_num.asm
.INCLUDE	l_voice/l_plymsg.asm
.INCLUDE	l_voice/l_memfull.asm


;-------------------------------------------------------------------------------
.END
	