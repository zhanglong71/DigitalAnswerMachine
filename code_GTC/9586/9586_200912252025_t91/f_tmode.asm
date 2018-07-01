;-------------------------------------------------------------------------------
.NOLIST
.INCLUDE	include/REG_D22.inc
.INCLUDE	include/MD22U.inc
.INCLUDE	include/CONST.inc
.INCLUDE	include/EXTERN.inc

.GLOBAL	LOCAL_PROTXT
;-------------------------------------------------------------------------------
.EXTERN	SetFlashStartAddress
.EXTERN	LoadHostCode
.EXTERN	GetOneConst

;-------------------------------------------------------------------------------
.LIST
;-------------------------------------------------------------------------------
.ORG	ADDR_SECOND
LOCAL_PROTXT:			;PRO_VAR = 0Xyyy7
	CALL	GET_RESPOND
	
	CALL	GET_MSG
	BS	ACZ,LOCAL_PROTXT_END
	SAH	MSG
;-------------------------------------------------------------------------------
	LAC	MSG
	XORL	CSEG_END
	BS	ACZ,LOCAL_PROTXT_SEGEND	;SEG-end
;---
	LAC	MSG
	XORL	CMSG_SER
	BS	ACZ,LOCAL_PROTXT_SER	;SEG-end

	LAC	PRO_VAR
	SFR	4
	ANDK	0X0F
	BS	ACZ,LOCAL_PROTEST0	;idle
	SBHK	1
	BS	ACZ,LOCAL_PROTEST1	;MIC Recording then play to line
	SBHK	1
	BS	ACZ,LOCAL_PROTEST2	;LINE Recording
	SBHK	1
	BS	ACZ,LOCAL_PROTEST3	;TONE(BEEP to line/spk)
	SBHK	2
	BS	ACZ,LOCAL_PROTEST5	;DTMF detect
	SBHK	1
	BS	ACZ,LOCAL_PROTEST6	;Play all voice prompt
	SBHK	1
	BS	ACZ,LOCAL_PROTEST7	;Exit
	SBHK	1
	BS	ACZ,LOCAL_PROTEST8	;VOX detect
	SBHK	1
	BS	ACZ,LOCAL_PROTEST9	;MIC Recording then play to SPK
	SBHK	2
	BS	ACZ,LOCAL_PROTESTB	;Icm record 10s -> Delay 2s -> Play the record message repeatly(OGM RECORD)
	SBHK	1
	BS	ACZ,LOCAL_PROTESTC	;Off-hook and record from line 10s -> 2s -> play it to SPK repeatly,stop and exit until STOP_TO_STANDBY
LOCAL_PROTXT_END:
	RET
;---------------------------------------
LOCAL_PROTXT_SEGEND:
	CALL	GET_VP
	BS	ACZ,LOCAL_PROTXT_SEGEND0
	CALL	INT_BIOS_START
	
	RET
LOCAL_PROTXT_SEGEND0:
	CALL	INIT_DAM_FUNC
	LACL	CVP_STOP		;通知系统播放完毕
	CALL	STOR_MSG
	
	RET
;---------------------------------------
LOCAL_PROTXT_SER:
	CALL	GETR_DAT
	SAH	MSG
;-------------------
	LAC	MSG
	SBHK	0X6B
	BS	ACZ,LOCAL_PROTXT_SER_0X6B	;(0X6B)stop
	SBHK	0X04
	BS	ACZ,LOCAL_PROTXT_SER_0X6F	;(0X6F)format

	RET
LOCAL_PROTXT_SER_0X6B:
	CALL	GETR_DAT
	SBHK	2
	BS	ACZ,LOCAL_PROTXT_SER_0X6B0X02
	SBHK	1
	BS	ACZ,LOCAL_PROTXT_SER_0X6B0X03
	SBHK	1
	BS	ACZ,LOCAL_PROTXT_SER_0X6B0X04
	SBHK	1
	BS	ACZ,LOCAL_PROTXT_SER_0X6B0X05
	SBHK	1
	BS	ACZ,LOCAL_PROTXT_SER_0X6B0X06
	SBHK	1
	BS	ACZ,LOCAL_PROTXT_SER_0X6B0X07
	SBHK	1
	BS	ACZ,LOCAL_PROTXT_SER_0X6B0X08
	SBHK	1
	BS	ACZ,LOCAL_PROTXT_SER_0X6B0X09
	SBHK	1
	BS	ACZ,LOCAL_PROTXT_SER_0X6B0X0A
	SBHK	1
	BS	ACZ,LOCAL_PROTXT_SER_0X6B0X0B
	SBHK	1
	BS	ACZ,LOCAL_PROTXT_SER_0X6B0X0C
	SBHK	1
	BS	ACZ,LOCAL_PROTXT_SER_0X6B0X0D
	SBHK	1
	BS	ACZ,LOCAL_PROTXT_SER_0X6B0X0E
	
	RET
SYS_SER_RUN_0X6B0X01:
	LACL	CTMODE_IN	;enter test mode
	CALL	STOR_MSG
	RET
LOCAL_PROTXT_SER_0X6B0X02:
	LACL	CTMSG_LREC	;DSP off hook and record from line
	CALL	STOR_MSG
	RET
LOCAL_PROTXT_SER_0X6B0X03:
	LACL	CTMSG_TONEL	;DSP off hook and generate 1KH tone to line
	CALL	STOR_MSG
	RET
LOCAL_PROTXT_SER_0X6B0X04:
	LACL	CTMSG_MEMS	;DSP count flash memory capability and send to MCU
	CALL	STOR_MSG
	RET
LOCAL_PROTXT_SER_0X6B0X05:		;Reserved
	;LACL	CTMSG_PVOP
	;CALL	STOR_MSG
	RET
LOCAL_PROTXT_SER_0X6B0X06:
	LACL	CTMSG_STOP	;cancel the current test item
	CALL	STOR_MSG
	RET
LOCAL_PROTXT_SER_0X6B0X07:		;Reserved
	;LACL	CTMSG_FMAT
	;CALL	STOR_MSG
	RET
LOCAL_PROTXT_SER_0X6B0X08:
	LACL	CTMSG_LICMS
	CALL	STOR_MSG	;Off-hook Play OGM to line repeatly,stop and exit until STOP_TO_STANDBY
	RET
LOCAL_PROTXT_SER_0X6B0X09:
	LACL	CTMSG_DTMFD
	CALL	STOR_MSG	;Off-hook,detect DTMF and digit through DTMF dialing
	RET
LOCAL_PROTXT_SER_0X6B0X0A:
	LACL	CTMSG_VOXD
	CALL	STOR_MSG	;VOX detect
	RET
LOCAL_PROTXT_SER_0X6B0X0B:
	LACL	CTMSG_MRECS
	CALL	STOR_MSG	;MEMO RECORD -> Delay 2s -> On-hook play it to SPK repeatly
	RET
LOCAL_PROTXT_SER_0X6B0X0C:
	LACL	CTMSG_TONES
	CALL	STOR_MSG	;On-hook,play beep tone to the SPK,stopuntil STOP-TO-STANDBY received
	RET
LOCAL_PROTXT_SER_0X6B0X0D:
	LACL	CTMSG_LICML
	CALL	STOR_MSG	;On-hook and record from MIC,Stop and exit until STOP_TO_STANDBY
	RET
LOCAL_PROTXT_SER_0X6B0X0E:
	LACL	CTMSG_MRECL
	CALL	STOR_MSG	;MEMO RECORD -> Delay 2s -> Off-hook play it to line repeatly
	RET
;-------------------------------------------------------------------------------
LOCAL_PROTEST0:		;Idle
;---
	LAC	MSG
	XORL	CTMODE_IN		;PLAY
	BS	ACZ,LOCAL_PROTEST0_ENTER
;---
	LAC	MSG
	XORL	CVP_STOP		;VP END
	BS	ACZ,LOCAL_PROTEST0_INIT
;---
	LAC	MSG
	XORL	CTMSG_STOP		;STOP
	BS	ACZ,LOCAL_PROTEST0_EXTMOD
;---
	LAC	MSG
	XORL	CTMSG_LREC	;DSP off hook and record from line
	BS	ACZ,LOCAL_PROTEST0_LINREC
	LAC	MSG
	XORL	CTMSG_MRECL	;MEMO RECORD
	BS	ACZ,LOCAL_PROTEST0_MICRECL
	LAC	MSG
	XORL	CTMSG_TONEL	;DSP off hook and generate 1KH tone to line
	BS	ACZ,LOCAL_PROTEST0_TONEL
	LAC	MSG
	XORL	CTMSG_MEMS	;DSP count flash memory capability and send to MCU
	BS	ACZ,LOCAL_PROTEST0_FMEM
	LAC	MSG
	XORL	CTMSG_DTMFD	;Off-hook,detect DTMF and digit through DTMF dialing
	BS	ACZ,LOCAL_PROTEST0_DTMFD
	LAC	MSG
	XORL	CTMSG_VOXD	;VOX detect
	BS	ACZ,LOCAL_PROTEST0_VOXDET
	LAC	MSG
	XORL	CTMSG_MRECS	;MEMO RECORD -> Delay 2s -> On-hook play it to SPK repeatly
	BS	ACZ,LOCAL_PROTEST0_MICRECS
	LAC	MSG
	XORL	CTMSG_TONES	;On-hook,play beep tone to the SPK,stop until STOP-TO-STANDBY received
	BS	ACZ,LOCAL_PROTEST0_TONES
	LAC	MSG
	XORL	CTMSG_LICML	;Off-hook and record from line 10s -> 2s -> play it to line repeatly,Stop and exit until STOP_TO_STANDBY
	BS	ACZ,LOCAL_PROTEST0_OGMREC
	LAC	MSG
	XORL	CTMSG_LICMS	;Off-hook and record from line 10s -> 2s -> play it to SPK repeatly,stop and exit until STOP_TO_STANDBY
	BS	ACZ,LOCAL_PROTEST0_OGMPLY
;-------
	LAC	MSG
	XORL	CTMSG_PVOP	;play all voice prompt to line and SPK
	BS	ACZ,LOCAL_PROTEST0_PVOP
	;LAC	MSG
	;XORL	CTMSG_FMAT	;format SPI flash
	;BS	ACZ,LOCAL_PROTEST0_FMAT

	RET
;-------------------------------------------------------------------------------
LOCAL_PROTEST0_ENTER:
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
	LACL	CMODE9|(1<<3)	;Line-on
	CALL	DAM_BIOSFUNC
	LACL	0xD700|CRVOX_LEVEL
	CALL	DAM_BIOSFUNC
	LACL	0x7700|CRSILENCE_LEVEL
	CALL	DAM_BIOSFUNC
	
	CALL	DAA_SPK
	CALL	BEEP
	
	RET
;---------------------------------------
LOCAL_PROTEST0_INIT:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	CALL	HOOK_IDLE
	CALL	VPMSG_CHK
	LACK	0X0007
	SAH	PRO_VAR

	RET
;---------------------------------------
LOCAL_PROTEST0_ERAALLVP:
	
    	RET
;---------------------------------------
LOCAL_PROTEST0_MICRECL:
	CALL	INIT_DAM_FUNC
	CALL	DAA_REC
	CALL	SET_COMPS

	CALL	VPMSG_CHK		;进入播放子功能
	LACK	0X0017
	SAH	PRO_VAR

	LACL	1000
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1

	CALL	REC_START

	RET
;---------------------------------------
LOCAL_PROTEST0_OGMREC:
	CALL	HOOK_OFF		;摘机
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_REC
	CALL	SET_TESTVOL

	CALL	SET_COMPS

	CALL	BCVOX_INIT
	CALL	VPMSG_CHK

	LACL	0X00B7
	SAH	PRO_VAR

	LACL	1000
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1

	CALL	REC_START
	
	RET
;---------------------------------------
LOCAL_PROTEST0_OGMPLY:
	CALL	HOOK_OFF		;摘机
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_REC
	CALL	SET_TESTVOL

	CALL	SET_COMPS

	CALL	BCVOX_INIT
	CALL	VPMSG_CHK

	LACL	0X00C7
	SAH	PRO_VAR

	LACL	1000
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1

	CALL	REC_START

	RET
;---------------------------------------
LOCAL_PROTEST0_MICRECS:
	CALL	INIT_DAM_FUNC
	CALL	DAA_REC
	CALL	SET_COMPS

	CALL	VPMSG_CHK		;进入播放子功能
	LACL	0X0097
	SAH	PRO_VAR

	LACL	1000
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1

	CALL	REC_START

	RET
;---------------------------------------
LOCAL_PROTEST0_LINREC:
	CALL	HOOK_OFF		;摘机
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_REC
	CALL	SET_TESTVOL

	CALL	SET_COMPS

	CALL	BCVOX_INIT
	CALL	VPMSG_CHK
	LACK	0X0027
	SAH	PRO_VAR

	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER	;为了查VOX

	CALL	REC_START
	
	RET
;---------------------------------------
LOCAL_PROTEST0_PLYMSG:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	LACK	0X005
	CALL	STOR_VP

	LACK	0X0037
	SAH	PRO_VAR

	CALL	VPMSG_CHK		;进入播放子功能

	LACK	0
	SAH	MSG_ID
	
	RET
;---------------------------------------

;---------------------------------------
LOCAL_PROTEST0_EXTMOD:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BBEEP

	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER
	
	RET
;---------------------------------------
LOCAL_PROTEST0_TONEL:
	CALL	HOOK_OFF		;摘机
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK
LOCAL_PROTEST0_TONESTART:
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	LACL	CBEEP_COMMAND		;ON
	CALL    DAM_BIOSFUNC
	
	LACL	0X2000
	CALL    DAM_BIOSFUNC
	LACK	0
	CALL    DAM_BIOSFUNC

	LACL	CBEEP_COMMAND		;
	SAH	CONF
	
	LAC	EVENT		;SET flag(bit5)
	ORK	0X020
	SAH	EVENT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X0037
	SAH	PRO_VAR
	
	RET
;---------------------------------------
LOCAL_PROTEST0_TONES:
	CALL	HOOK_IDLE		;挂机
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	SET_TESTVOL

	BS	B1,LOCAL_PROTEST0_TONESTART
;---------------------------------------
LOCAL_PROTEST0_FMEM:
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK
	CALL	HOOK_OFF

	;CALL	SET_COMPS
;---------------------------------------
;	(0XD107)	;0 - 3.6kbps
;	(0XD107)|(1<<3)	;1 - 4.8kbps
;	(0XD107)|(2<<3)	;2 - 6.0kbps
;	(0XD107)|(3<<3)	;3 - 7.2kbps
;	(0XD107)|(4<<3)	;4 - 8.4kbps
;	(0XD107)|(5<<3)	;5 - 9.6kbps
;---------------------------------------	
	LACL	(0XD107)|(2<<3)	;2 - 6.0kbps
	CALL	DAM_BIOSFUNC

	LACL    0X3003		;check if memory is full ?
	CALL	DAM_BIOSFUNC
	SAH	SYSTMP1		;Save memory-size(second)
	LACK	60
	SAH	SYSTMP2	
	CALL	DIVI		;Get memory-size(minute)

	LAC	SYSTMP1
	CALL	HEX_DGT
	SAH	MSG_N
;---delay 1s first
	LACL	1000
	CALL	DELAY
;---十位
	LAC	MSG_N
	SFR	4
	ANDK	0X0F
	CALL	DTMF_GENE
;---delay 150ms
	LACL	150
	CALL	DELAY
;---个位	
	LAC	MSG_N
	ANDK	0X0F
	CALL	DTMF_GENE
	
	LACL	1000
	CALL	DELAY
;---
	CALL	HOOK_IDLE
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	CALL	BEEP
	
	RET
;---------------------------------------
LOCAL_PROTEST0_DTMFD:
	CALL	HOOK_OFF	;摘机
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_REC

	CALL	BCVOX_INIT
	CALL	VPMSG_CHK		;进入播放子功能
	LACL	0X0057
	SAH	PRO_VAR

	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER

	CALL	LINE_START
	
	RET
	
;---------------------------------------
LOCAL_PROTEST0_VOXDET:
	CALL	HOOK_OFF	;摘机
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_REC

	CALL	BCVOX_INIT
	CALL	VPMSG_CHK		;进入播放子功能
	LACL	0X0087
	SAH	PRO_VAR

	LACK	0
	SAH	PRO_VAR1
	LACL	100
	CALL	SET_TIMER	;为了查VOX

	CALL	LINE_START
	
	RET
;---------------------------------------
LOCAL_PROTEST0_PVOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	LACK	0X005
	CALL	STOR_VP
	
	LACL	0X0067
	SAH	PRO_VAR
	
	LACK	0
	SAH	MSG_ID
	
	RET
;---------------------------------------
LOCAL_PROTXT_SER_0X6F:
	CALL	INIT_DAM_FUNC
	
	LACL	CMODE9|1
	CALL	DAM_BIOSFUNC	;清flash……

	LACK	0X2F
	CALL	SEND_DAT
	LACK	0X2F
	CALL	SEND_DAT

	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROTEST1:			;MIC Recording
	LAC	PRO_VAR
	SFR	8
	ANDK	0X0F
	BS	ACZ,LOCAL_PROTEST1_0	;---Record	
	SBHK	1
	BS	ACZ,LOCAL_PROTEST1_1	;---play
	
	RET
;---------------------------------------
LOCAL_PROTEST1_0:	;---Record	
	LAC	MSG
	XORL	CMSG_TMR		;Stop record
	BS	ACZ,LOCAL_PROTEST1_0_TMR	
	
	RET
;---------------------------------------
LOCAL_PROTEST1_0_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	5
	BZ	SGN,LOCAL_PROTEST1_0_EXIT
	
	RET
;---------------
LOCAL_PROTEST1_0_EXIT:
	CALL	HOOK_OFF		;摘机
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK
	CALL	VPMSG_CHK
	
	LACL	0X0117
	SAH	PRO_VAR

	CALL	BEEP
	LACK	0X007f
	CALL	STOR_VP
	LACK	0X007f
	CALL	STOR_VP
	LAC	MSG_T
	ORL	0XFE00
	CALL	STOR_VP

	RET
;---------------------------------------
LOCAL_PROTEST1_1:	;---Play
	LAC	MSG
	XORL	CVP_STOP		;Play end
	BS	ACZ,LOCAL_PROTEST1_1_VPSTOP	
	LAC	MSG
	XORL	CTMSG_STOP		;Stop record
	BS	ACZ,LOCAL_PROTEST1_1_EXIT	
	
	RET
;---------------------------------------
LOCAL_PROTEST1_1_EXIT:
	BS	B1,LOCAL_PROTESTX_EXIT
;---------------------------------------
LOCAL_PROTEST1_1_VPSTOP:	;退回到测试平台
	LAC	MSG_T
	ORL	0XFE00
	CALL	STOR_VP

	RET
;---------------------------------------
LOCAL_PROTESTX_EXIT:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BBEEP
	
	LACK	0X0007
	SAH	PRO_VAR
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROTEST2:			;LINE Recording
	LAC	MSG
	XORL	CTMSG_STOP		;Stop Record
	BS	ACZ,LOCAL_PROTEST2_0_EXIT
	
	LAC	MSG
	XORL	CMSG_TMR		;TMR
	BS	ACZ,LOCAL_PROTEST2_0_TMR	
	
	RET
;---------------------------------------
LOCAL_PROTEST2_0_EXIT:
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_SPK
	CALL	BBEEP
	CALL	VPMSG_CHK

	CALL	CLR_TIMER

	LACK	0X07
	SAH	PRO_VAR

	RET
;---------------------------------------
LOCAL_PROTEST2_0_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	
	LACK	1
	BIT	RESP,6
	BS	TB,LOCAL_PROTEST2_TMR_VOXON
	LACK	0

LOCAL_PROTEST2_TMR_VOXON:
	SAH	MSGLED_FG

	RET
;-------------------------------------------------------------------------------
LOCAL_PROTEST3:			;PlayBack BEEP TONE to line
	LAC	MSG
	XORL	CTMSG_STOP		;STOP
	BS	ACZ,LOCAL_PROTEST3_EXIT	

	RET
;---------------------------------------
LOCAL_PROTEST3_EXIT:
	CALL	HOOK_IDLE
	BS	B1,LOCAL_PROTESTX_EXIT
;-------------------------------------------------------------------------------
LOCAL_PROTEST4:			;QuiteMode(Line seize only)
	;LAC	MSG
	;XORL	CTMSG_STOP		;STOP
	;BS	ACZ,LOCAL_PROTEST4_EXIT	
	
	;RET
LOCAL_PROTEST4_EXIT:
	;BS	B1,LOCAL_PROTESTX_EXIT
;-------------------------------------------------------------------------------
LOCAL_PROTEST5:			;DTMF detect
	LAC	MSG
	XORL	CVP_STOP		;VPSTOP
	BS	ACZ,LOCAL_PROTEST5_TVPSTOP
	LAC	MSG
	XORL	CTMSG_STOP		;STOP
	BS	ACZ,LOCAL_PROTEST5_EXIT	
	LAC	MSG
	XORL	CREV_DTMF		;REV-DTMF
	BS	ACZ,LOCAL_PROTEST5_DTMF
	LAC	MSG
	XORL	CMSG_TMR		;REV-DTMF
	BS	ACZ,LOCAL_PROTEST5_TMR

	RET
;---------------------------------------
LOCAL_PROTEST5_EXIT:
	BS	ACZ,LOCAL_PROTESTX_EXIT
LOCAL_PROTEST5_TMR:
	CALL	BCVOX_INIT
	RET
LOCAL_PROTEST5_TVPSTOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_REC
	CALL	LINE_START

	RET
;---------------------------------------
LOCAL_PROTEST5_DTMF:
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK

	LAC	DTMF_VAL
	SAH	MSG_N

	LACL	200
	CALL	DELAY

	LAC	MSG_N
	ANDL	0X0F
	CALL	DTMF_GENE

	LACL	100
	CALL	DELAY

	CALL	DAA_SPK
	LAC	MSG_N
	ANDK	0X0F
	ADHK	1
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROTEST6:			;Del all messages(FormatFlash)
	LAC	MSG
	XORL	CTMSG_STOP		;STOP
	BS	ACZ,LOCAL_PROTEST6_EXIT	
	LAC	MSG
	XORL	CVP_STOP		;STOP
	BS	ACZ,LOCAL_PROTEST6_OVER	

	RET
LOCAL_PROTEST6_EXIT:
	BS	B1,LOCAL_PROTESTX_EXIT
LOCAL_PROTEST6_OVER:
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_SPK
	
	LAC	MSG_ID
	SBHL	TMAX_VOPID
	BZ	SGN,LOCAL_PROTESTX_EXIT
	
	LAC	MSG_ID
	ADHK	1
	SAH	MSG_ID
	
	CALL	BEEP
	LAC	MSG_ID
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROTEST7:
	LAC	MSG
	XORL	CMSG_TMR		;STOP
	BS	ACZ,LOCAL_PROTEST7_TMR
	LAC	MSG
	XORL	CVP_STOP		;STOP
	BS	ACZ,LOCAL_PROTEST7_EXIT
	
	
	RET
;---------------------------------------
LOCAL_PROTEST7_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	3
	BZ	SGN,LOCAL_PROTEST7_EXIT
	
	RET
;---------------------------------------
LOCAL_PROTEST7_EXIT:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BBEEP
	LACK	0X0
	SAH	PRO_VAR

	RET	
;-------------------------------------------------------------------------------
LOCAL_PROTEST8:		;VOX detect
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PROTEST8_TMR
	LAC	MSG
	XORL	CTMSG_STOP
	BS	ACZ,LOCAL_PROTEST8_EXIT
	
	RET
;---------------------------------------
LOCAL_PROTEST8_TMR:

	LACK	1
	BIT	RESP,6
	BS	TB,LOCAL_PROTEST8_TMR_VOXON
	LACK	0
LOCAL_PROTEST8_TMR_VOXON:
	SAH	MSGLED_FG

	RET
;---------------------------------------
LOCAL_PROTEST8_EXIT:	
	LACK	1
	SAH	MSGLED_FG
	LACL	1000
	CALL	SET_TIMER
	BS	B1,LOCAL_PROTESTX_EXIT
;-------------------------------------------------------------------------------
LOCAL_PROTEST9:
	LAC	PRO_VAR
	SFR	8
	ANDK	0X0F
	BS	ACZ,LOCAL_PROTEST9_0
	SBHK	1
	BS	ACZ,LOCAL_PROTEST9_1
	
	RET
;---------------------------------------
LOCAL_PROTEST9_0:	;---Record	
	LAC	MSG
	XORL	CMSG_TMR		;Stop record
	BS	ACZ,LOCAL_PROTEST9_0_TMR	
	
	RET
;---------------------------------------
LOCAL_PROTEST9_0_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	5
	BZ	SGN,LOCAL_PROTEST9_0_EXIT
	
	RET
;---------------
LOCAL_PROTEST9_0_EXIT:
	CALL	HOOK_IDLE		;摘机
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	SET_TESTVOL

	CALL	VPMSG_CHK
	
	LACL	0X0197
	SAH	PRO_VAR

	CALL	BEEP
	LACK	0X007f
	CALL	STOR_VP
	LACK	0X007f
	CALL	STOR_VP
	LAC	MSG_T
	ORL	0XFE00
	CALL	STOR_VP

	RET
;---------------------------------------
LOCAL_PROTEST9_1:	;---Play
	LAC	MSG
	XORL	CVP_STOP		;Play end
	BS	ACZ,LOCAL_PROTEST9_1_VPSTOP	
	LAC	MSG
	XORL	CTMSG_STOP		;Stop record
	BS	ACZ,LOCAL_PROTEST9_1_EXIT	
	
	RET
;---------------------------------------
LOCAL_PROTEST9_1_EXIT:
	BS	B1,LOCAL_PROTESTX_EXIT
;---------------------------------------
LOCAL_PROTEST9_1_VPSTOP:	;Play the VP again
	LAC	MSG_T
	ORL	0XFE00
	CALL	STOR_VP

	RET
;-------------------------------------------------------------------------------
LOCAL_PROTESTA:	
	
;-------------------------------------------------------------------------------
LOCAL_PROTESTB:	
	LAC	PRO_VAR
	SFR	8
	ANDK	0X0F
	BS	ACZ,LOCAL_PROTESTB_0	;idle
	SBHK	1
	BS	ACZ,LOCAL_PROTESTB_1
	
	RET
;---------------------------------------	
LOCAL_PROTESTB_0:
	LAC	MSG
	XORL	CMSG_TMR		;TMR
	BS	ACZ,LOCAL_PROTESTB_0_TMR	
	
	RET
;-------------------
LOCAL_PROTESTB_0_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	10
	BZ	SGN,LOCAL_PROTESTB_0_TMR_ENDREC
	
	RET
LOCAL_PROTESTB_0_TMR_ENDREC:	;Icm record time-out,then play the message to line
	CALL	HOOK_OFF		;摘机
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK
	CALL	VPMSG_CHK
	
	LACL	0X01B7
	SAH	PRO_VAR

	CALL	BEEP
	LACK	0X007f
	CALL	STOR_VP
	LACK	0X007f
	CALL	STOR_VP
	LAC	MSG_T
	ORL	0XFE00
	CALL	STOR_VP
	
	RET
;-----------------------------
LOCAL_PROTESTB_1:
	LAC	MSG
	XORL	CTMSG_STOP		;STOP
	BS	ACZ,LOCAL_PROTESTB_1_EXIT	
	LAC	MSG
	XORL	CVP_STOP		;VP end
	BS	ACZ,LOCAL_PROTESTB_1_VPSTOP	

	RET
;---------------------------------------
LOCAL_PROTESTB_1_VPSTOP:
	LAC	MSG_T
	ORL	0XFE00
	CALL	STOR_VP
	RET
;---------------------------------------
LOCAL_PROTESTB_1_EXIT:
	BS	B1,LOCAL_PROTESTX_EXIT	
;-------------------------------------------------------------------------------
LOCAL_PROTESTC:	
	LAC	PRO_VAR
	SFR	8
	ANDK	0X0F
	BS	ACZ,LOCAL_PROTESTC_0	;idle
	SBHK	1
	BS	ACZ,LOCAL_PROTESTC_1
	
	RET
LOCAL_PROTESTC_0:	
	LAC	MSG
	XORL	CMSG_TMR		;TMR
	BS	ACZ,LOCAL_PROTESTC_0_TMR	

	RET
LOCAL_PROTESTC_0_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	10
	BZ	SGN,LOCAL_PROTESTC_0_TMR_0_ENDREC
	
	RET
;-------------------
LOCAL_PROTESTC_0_TMR_0_ENDREC:

	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	SET_TESTVOL
	CALL	VPMSG_CHK
	
	LACL	0X01C7
	SAH	PRO_VAR

	CALL	BEEP
	LACK	0X007f
	CALL	STOR_VP
	LACK	0X007f
	CALL	STOR_VP
	LAC	MSG_T
	ORL	0XFE00
	CALL	STOR_VP
	
	RET
;---------------------------------------
LOCAL_PROTESTC_1:	
	LAC	MSG
	XORL	CTMSG_STOP		;STOP
	BS	ACZ,LOCAL_PROTESTC_EXIT	
	LAC	MSG
	XORL	CVP_STOP		;VP-STOP
	BS	ACZ,LOCAL_PROTESTC_1_VPSTOP	

	RET
LOCAL_PROTESTC_1_VPSTOP:
	LAC	MSG_T
	ORL	0XFE00
	CALL	STOR_VP
	RET
;---------------------------------------
LOCAL_PROTESTC_EXIT:
	BS	B1,LOCAL_PROTESTX_EXIT		
;---------------------------------------
;-------------------------------------------------------------------------------
SET_TESTVOL:		;Set SPK volume
	LAC	CODECREG2
	ANDL	0XFFE0
	SAH	CODECREG2
	
	LACK	CVOL_TEST
	ADHL	VOL_TAB		;Demand MAX.volum
	CALL    GetOneConst
        OR	CODECREG2
        SAH	CODECREG2

	LIPK    6
	OUT	CODECREG2,LOUTSPK
	ADHK	0

	
	RET
;-------------------------------------------------------------------------------
;       Function : HEX_DGT
;	Transform a binary value to a BCD value
;
;	Input  : SYSTMP1=dividend,SYSTMP2=divisor
;	Output : SYSTMP1=quotient,SYSTMP2=surplus
;	Variable : SYSTMP3
;-------------------------------------------------------------------------------
DIVI:
	PSH	SYSTMP3
	
	LACK	0
	SAH	SYSTMP3		;initial quotient
DIVI_LOOP:
	LAC	SYSTMP1
	SBH	SYSTMP2
	BS	SGN,DIVI_END
	SAH	SYSTMP1
	
	LAC	SYSTMP3
	ADHK	1
	SAH	SYSTMP3
	BS	B1,DIVI_LOOP
DIVI_END:
	LAC	SYSTMP1
	SAH	SYSTMP2		;surplus
	
	LAC	SYSTMP3
	SAH	SYSTMP1		;quotient

	POP	SYSTMP3
	
        RET
;-------------------------------------------------------------------------------
;	DTMF Generation
;	input : ACCH = 
;	output: no
;-------------------------------------------------------------------------------
DTMF_GENE:
	SAH	SYSTMP1
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	;LACL	CBEEP_COMMAND		;ON
	;LACL	0X4856		;-8dB/-8dB
	LACL	0X4846		;
	CALL    DAM_BIOSFUNC
	
	LAC	SYSTMP1
	ADHL	DTMFL_TAB
	CALL	GetOneConst
	CALL    DAM_BIOSFUNC
	LAC	SYSTMP1
	ADHL	DTMFH_TAB
	CALL	GetOneConst
	CALL    DAM_BIOSFUNC

	LACL	100
	CALL	DELAY
	
	LACL	0X4400
	CALL    DAM_BIOSFUNC
	
	RET
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;-------------------------------------------------------------------------------
DTMFL_TAB:	;F-low
;	0		1		2		3		4		5		6		7
.DATA	940*8192/1000	699*8192/1000	699*8192/1000	699*8192/1000	772*8192/1000	772*8192/1000	772*8192/1000	854*8192/1000
;	8		9		A		B		C		D		*		#
.DATA	854*8192/1000	854*8192/1000	699*8192/1000	772*8192/1000	854*8192/1000	940*8192/1000	940*8192/1000	940*8192/1000
;---------------------------------------
DTMFH_TAB:	;F-high
;	0		1		2		3		4		5		6		7
.DATA	1332*8192/1000	1203*8192/1000	1332*8192/1000	1472*8192/1000	1203*8192/1000	1332*8192/1000	1472*8192/1000	1203*8192/1000
;	8		9		A		B		C		D		*		#
.DATA	1332*8192/1000	1472*8192/1000	1645*8192/1000	1645*8192/1000	1645*8192/1000	1645*8192/1000	1203*8192/1000	1472*8192/1000
;-------------------------------------------------------------------------------

.INCLUDE	l_beep/l_beep.asm
.INCLUDE	l_beep/l_bbeep.asm
;.INCLUDE	l_beep/l_bbbeep.asm
;.INCLUDE	l_beep/l_lbeep.asm
;.INCLUDE	l_beep/l_wbeep.asm

.INCLUDE	l_CodecPath/l_allopen.asm
.INCLUDE	l_CodecPath/l_lply.asm
.INCLUDE	l_CodecPath/l_lrec.asm
.INCLUDE	l_CodecPath/l_ansply.asm
.INCLUDE	l_CodecPath/l_ansrec.asm
.INCLUDE	l_CodecPath/l_rmtply.asm
.INCLUDE	l_CodecPath/l_rmtrec.asm

.INCLUDE	l_flashmsg/l_biosfull.asm
.INCLUDE	l_flashmsg/l_flashmsg.asm

.INCLUDE	l_rec/l_compress.asm

.INCLUDE	l_iic/l_storsqueue.asm
.INCLUDE	l_iic/l_getrqueue.asm
;.INCLUDE	l_iic/l_exit.asm

;.INCLUDE	l_line.asm

.INCLUDE	l_math/l_hexdgt.asm

.INCLUDE	l_port/l_hookidle.asm
.INCLUDE	l_port/l_hookoff.asm
;.INCLUDE	l_port/l_hookon.asm
.INCLUDE	l_port/l_hwalc.asm
;.INCLUDE	l_port/l_msgled.asm
.INCLUDE	l_port/l_spkctl.asm

.INCLUDE	l_respond/l_btone.asm
.INCLUDE	l_respond/l_ctone.asm
.INCLUDE	l_respond/l_vox.asm
.INCLUDE	l_respond/l_dtmf.asm
.INCLUDE	l_respond/l_ansrmt_resp.asm
.INCLUDE	l_respond/l_vpqueue.asm

.INCLUDE	l_table/l_voltable.asm
.INCLUDE	l_table/l_dtmftable.asm

.INCLUDE	l_voice/l_defogm.asm
.INCLUDE	l_voice/l_num.asm
;-------------------------------------------------------------------------------
.END
