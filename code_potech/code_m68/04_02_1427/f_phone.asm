.NOLIST
.INCLUDE	include/REG_D22.inc
.INCLUDE	include/MD22U.inc
.INCLUDE	include/CONST.inc

.GLOBAL	LOCAL_PROPHO
.GLOBAL	SET_PHONERUN
;-------------------------------------------------------------------------------
.EXTERN	GetOneConst
.EXTERN	DspPly
.EXTERN	INIT_DAM_FUNC

.EXTERN	BCVOX_INIT
.EXTERN	BBBEEP
.EXTERN	BBEEP
.EXTERN	BEEP

;.EXTERN	CLR_BUSY_FG
.EXTERN	CLR_FUNC
.EXTERN	CLR_TIMER

.EXTERN	DAA_SPK
.EXTERN	DAA_REC
.EXTERN	DAA_OFF
.EXTERN	DAM_BIOSFUNC
;.EXTERN	DAT_WRITE
;.EXTERN	DAT_WRITE_STOP
;.EXTERN	DEL_ALLTEL
.EXTERN	DGT_TAB

.EXTERN	GC_CHK

.EXTERN	HOOK_ON
.EXTERN	HOOK_OFF	;!!!(无实际的端口控制)

.EXTERN	LBEEP
;.EXTERN	LED_HLDISP
.EXTERN	LINE_START
.EXTERN	LOCAL_PRO
.EXTERN	MIDI_STOP
.EXTERN	OGM_SELECT

.EXTERN	PUSH_FUNC
.EXTERN	PHONE_START

;.EXTERN	REAL_DEL
.EXTERN	REC_START
;.EXTERN	SET_MICGAIN
;.EXTERN	SET_SPKVOL
;.EXTERN	SET_TELGROUP

.EXTERN	SET_TIMER

.EXTERN	SEND_DAT
;.EXTERN	SEND_MFULL
.EXTERN	SEND_MSGNUM
;.EXTERN	SEND_RECSTART

.EXTERN	STORBYTE_DAT
.EXTERN	STOR_MSG
.EXTERN	STOR_VP

;.EXTERN	TELNUM_WRITE

.EXTERN	TEL_GC_CHK

.EXTERN	VPMSG_CHK
.EXTERN	VPMSG_DEL
;-------------------------------------------------------------------------------
.ORG	ADDR_SECOND
;-------------------------------------------------------------------------------
.LIST
;-------------------------------------------------------------------------------
LOCAL_PROPHO:
;---	
	LAC	MSG
	XORL	CHOOK_ON
	BS	ACZ,LOCAL_PROPHO0_HOOKON
	LAC	MSG
	XORL	CHOOK_OFF
	BS	ACZ,LOCAL_PROPHO0_HOOKOFF
	
	LAC	MSG
	XORL	CPHONE_ON
	BS	ACZ,LOCAL_PROPHO0_PHONE
	LAC	MSG
	XORL	CPHONE_OFF
	BS	ACZ,LOCAL_PROPHO_STOP

;---------------------------------------	
	LAC	PRO_VAR
	SFR	4
	ANDK	0X0F
	BS	ACZ,LOCAL_PROPHO0	;wait from start
	SBHK	1
	BS	ACZ,LOCAL_PROPHO1	;Speakerphone
	SBHK	1
	;BS	ACZ,LOCAL_PROPHO2	;pressed KEY(Dial)
	SBHK	1
	;BS	ACZ,LOCAL_PROPHO3	;released KEY(End Dial)
	SBHK	1
	BS	ACZ,LOCAL_PROPHO4	;Flash
	SBHK	1
	BS	ACZ,LOCAL_PROPHO5	;Pause

	RET
;-------------------------------------------------------------------------------
LOCAL_PROPHO0:
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PROPHO0_TMR

	RET
;---------------------------------------
LOCAL_PROPHO0_TMR:
	
	LACL	1000
	CALL	SET_TIMER
	LACK	0X016
	SAH	PRO_VAR
	
	CALL	PHOLED_L	;speakerphone LED on
.if	0
	LACK	CSPK_GAIN
	CALL	SET_SPKVOL
	
	;LACL	0x5F20		;set SPK volume
	;CALL	DAM_BIOSFUNC
	;LACK	CSPK_GAIN	;+6dB
	;CALL	DAM_BIOSFUNC
.else
	LIPK    6

	IN	CODECREG2,LOUTSPK
	LAC	CODECREG2
	ANDL	0XFFE0
	ORK	CSPK_GAIN
	SAH	CODECREG2	
	OUT	CODECREG2,LOUTSPK
	ADHK	0
.endif	
	CALL	PHONE_START

	RET
;---------------------------------------
LOCAL_PROPHO0_PHONE:
	CALL	INIT_DAM_FUNC
	CALL	MIDI_STOP
	CALL	SET_ANSEDCID
	CALL	DAA_SPKPHONE
	CALL	HOOK_ON		;Same as idle mode
	LACK	0X006
	SAH	PRO_VAR
;---close ALC
	LACL	CMODE9		;demand ALC-off
	CALL	DAM_BIOSFUNC
;---for wait
	LACK	0
	SAH	PRO_VAR1
	LACL	400
   	CALL	SET_TIMER
;---start free run----------------------
	CALL	SET_PHONERUN
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROPHO1:
	LAC	MSG
	XORL	CMSG_TMR		;TMR
	BS	ACZ,LOCAL_PROPHO_TMR
LOCAL_PROPHO1_0_1:			;按下数字拔号键	
	LAC	MSG
	;XORL	CMSG_KEY1S
	BS	ACZ,LOCAL_PROPHO1_FLASH
;---	
	LAC	MSG
	XORL	CVOL_INC
	BS	ACZ,LOCAL_PROPHO0_VOLADD	;VOL+++
	LAC	MSG
	XORL	CVOL_DEC
	BS	ACZ,LOCAL_PROPHO0_VOLSUB	;VOL---
;---	
	LAC	MSG
	XORL	CMUTE_ON
	BS	ACZ,LOCAL_PROPHO0_MUTE		;mute MIC
	LAC	MSG
	XORL	CMUTE_OFF
	BS	ACZ,LOCAL_PROPHO0_UNMUTE	;unmute MIC
	
	LAC	MSG
	XORL	CMSG_MUTE
	BS	ACZ,LOCAL_PROPHO0_PORTMUTE	;(When mcu dial out)
	LAC	MSG
	XORL	CMSG_UNMUTE
	BS	ACZ,LOCAL_PROPHO0_PORTUNMUTE	;(When mcu dial out end)
;---
	
	RET
;-----------------------------------------------------------
LOCAL_PROPHO0_MUTE:
	LACK	0
	CALL	SET_MICGAIN	;set mic-pre-gain

	RET
LOCAL_PROPHO0_UNMUTE:
	LACK	CMIC_GAIN
	CALL	SET_MICGAIN
	
	RET
;---------------------------------------
LOCAL_PROPHO0_PORTMUTE:
	LACK	0
	CALL	SET_MICGAIN	;set mic-pre-gain
;---
	LIPK    6

	IN	CODECREG2,LOUTSPK
	LAC	CODECREG2
	ANDL	0XFFE0
	ORK	0x0001
	SAH	CODECREG2	
	OUT	CODECREG2,LOUTSPK
	ADHK	0
	
	RET
LOCAL_PROPHO0_PORTUNMUTE:
	LACK	CMIC_GAIN
	CALL	SET_MICGAIN	;set mic-pre-gain
;---
	LIPK    6

	IN	CODECREG2,LOUTSPK
	LAC	CODECREG2
	ANDL	0XFFE0
	ORK	CSPK_GAIN
	SAH	CODECREG2	
	OUT	CODECREG2,LOUTSPK
	ADHK	0
	
	RET
;---------------------------------------
LOCAL_PROPHO0_HOOKOFF:
LOCAL_PROPHO0_HOOKON:
	CALL	INIT_DAM_FUNC
	CALL	HOOK_ON		;Same as idle mode
	CALL	SET_ANSEDCID

	LACL	CMODE9
	CALL	DAM_BIOSFUNC	;---开ALC

   	LACK	0
   	SAH	PRO_VAR
	CALL	LINE_START

	RET
;---------------------------------------
LOCAL_PROPHO0_DIALEND:		;松开数字拔号键
	LACK	0X036
	SAH	PRO_VAR

	LACK	0
	SAH	PRO_VAR1
	LACL	1000
   	CALL	SET_TIMER

	LACK	CMIC_GAIN
	CALL	SET_MICGAIN
	;LACL	0x5F10		
	;CALL	DAM_BIOSFUNC
	;LACK	CMIC_GAIN	; --dB
	;CALL	DAM_BIOSFUNC
	
	LACL	0XC000
	CALL	DAM_BIOSFUNC

	RET

;-------Exit SpeakerPhone mode
LOCAL_PROPHO_STOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	CALL	HOOK_ON

	CALL	PHOLED_H	;speakerphone LED off

	LACL	CMODE9
	CALL	DAM_BIOSFUNC	;---开ALC

   	LACK	0
   	SAH	PRO_VAR
	
	LACL	CMSG_INIT
	CALL	STOR_MSG

	RET
LOCAL_PROPHO0_VOLADD:
	LAC	DAM_ATT
	SFR	4
        ANDK	0X07
        SBHK	7		;上限
        BZ	SGN,LOCAL_PROPHO0_VOLSET
        LAC	DAM_ATT
        ADHK	0X010
        SAH	DAM_ATT
	BS	B1,LOCAL_PROPHO0_VOLSET
;---	
LOCAL_PROPHO0_VOLSUB:
	LAC	DAM_ATT
	SFR	4
        ANDK	0X07
        SBHK	0		;下限
        BS	ACZ,LOCAL_PROPHO0_VOLSET
        BS	SGN,LOCAL_PROPHO0_VOLSET
        LAC	DAM_ATT
	SBHK	0X010
        SAH	DAM_ATT
LOCAL_PROPHO0_VOLSET:
		
	LACK	0X1B
	CALL	SEND_DAT
	LAC	DAM_ATT			;Set SPK_GAIN
	SFR	4
	ANDK	0X07
	CALL	SEND_DAT	;tell MCU volume
;---	
	LAC	DAM_ATT			;Set SPK_GAIN
	SFR	4
	ANDK	0X07
	ADHL	PHOVOL_TAB
	CALL    GetOneConst	;Get SPK_GAIN
	ORL	0X0A0		;Get LINE _GAIN
	CALL	SET_PHOVOL	;Set speakerphone vol	

	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER	

	RET
;---------------
LOCAL_PROPHO1_FLASH:
	LACL	0X0046
	SAH	PRO_VAR
	
;先关SPK---50ms	
	LIPK    6

	IN	CODECREG2,LOUTSPK
	LAC	CODECREG2
	ANDL	0XFFE0
	ORK	1
	SAH	CODECREG2	
	OUT	CODECREG2,LOUTSPK
	ADHK	0
	
	LACK	0
	SAH	PRO_VAR1
	LACL	50
	CALL	SET_TIMER	;
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROPHO2:			;Do nothing until time over

	RET
;-------------------------------------------------------------------------------
LOCAL_PROPHO3:			;Key released(for timer display)

	RET
;-------------------------------------------------------------------------------
LOCAL_PROPHO4:			;Flash
	LAC	MSG
	XORL	CMSG_TMR		;TMR
	BS	ACZ,LOCAL_PROPHO4_TMR
	
	RET

LOCAL_PROPHO4_TMR:
	LAC	PRO_VAR
	SFR	8
	ANDK	0X0F
	BS	ACZ,LOCAL_PROPHO4_0_TMR	;Spk_off --- HOOK_ON
	SBHK	1
	BS	ACZ,LOCAL_PROPHO4_1_TMR
	SBHK	1
	BS	ACZ,LOCAL_PROPHO4_2_TMR
	
	RET
LOCAL_PROPHO4_0_TMR:
		
	LACL	0X0146
	SAH	PRO_VAR
	
	CALL	HOOK_ON
	
	LACK	0
	SAH	PRO_VAR1
	LACL	105
	CALL	SET_TIMER
	
	RET
LOCAL_PROPHO4_1_TMR:
		
	LACL	0X0246
	SAH	PRO_VAR
	
	LACK	0
	SAH	PRO_VAR1
	LACL	50
	CALL	SET_TIMER
	
	
	RET
LOCAL_PROPHO4_2_TMR:
	LACK	0X0016
	SAH	PRO_VAR
;---
	LIPK    6

	IN	CODECREG2,LOUTSPK
	LAC	CODECREG2
	ANDL	0XFFE0
	ORK	CSPK_GAIN
	SAH	CODECREG2	
	OUT	CODECREG2,LOUTSPK
	ADHK	0

	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER

	RET
;-------------------------------------------------------------------------------
LOCAL_PROPHO5:
	
	RET
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
LOCAL_PROPHO_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1

	RET
;###############################################################################
;	Function : SET_PHONERUN
;
;###############################################################################
SET_PHONERUN:
;---start free run--------------------------------------------------------------
   	CALL	PHONE_START
;---Line mute
   	LACL  	0XC040
   	CALL  	DAM_BIOSFUNC
;---DTMF GIAN  BIT0-3 HI BIT4-7 LO
   	LACL   	0XC121
   	CALL    DAM_BIOSFUNC
;---Set ERL_AEC & ERL_LEC
   	LACL	0XC430		;default Value
   	CALL	DAM_BIOSFUNC
;---Set T/R & R/T ratio
	LACL	0XC602
   	CALL	DAM_BIOSFUNC
;---Set LINE _GAIN & SPK_GAIN
	LAC	DAM_ATT			;Get SPK_GAIN
	SFR	4
	ANDK	0X07
	ADHL	PHOVOL_TAB
	CALL    GetOneConst	;Get SPK_GAIN
	ORL	0X0A0		;Get LINE _GAIN
	CALL	SET_PHOVOL		;0XC8XX(default Value = 0XC8AA)
;---Set Loop Attenuation
	LACL	0XC904
	CALL	DAM_BIOSFUNC
;---Line mute
    	LACL    0xC040         		;wait line mute for 400 ms
    	CALL    DAM_BIOSFUNC
;---free run
;    	CALL	PHONE_START

	RET
;---------------------------------------
DAA_SPKPHONE:
	PSH	CONF
;---	
	LACL	0x5E11		;set Codec path
	CALL	DAM_BIOSFUNC
;-	
	LACL	0x5F10		;set mic-pre-gain
	CALL	DAM_BIOSFUNC
	LACK	CMIC_GAIN	; default Demo=7(+18dB)
	CALL	DAM_BIOSFUNC
;-	
	LACL	0x5F11		; set AD0-pga
	CALL	DAM_BIOSFUNC	
	LACK	0xD		; +15dB
	CALL	DAM_BIOSFUNC
;-	
	LACL	0x5F12		; set lin-pga
	CALL	DAM_BIOSFUNC
	LACK	9		; +9dB
	CALL	DAM_BIOSFUNC
;-	
	LACL	0x5F20		; set SPK volume
	CALL	DAM_BIOSFUNC
	LACK	0x0		; CSPK_GAIN/Demo=0xE	
	CALL	DAM_BIOSFUNC
;-	
	LACL	0x5F21		; set Lout volume
	CALL	DAM_BIOSFUNC
	LACK	0x13		; -6dB
	CALL	DAM_BIOSFUNC
;---
	POP	CONF

	RET
;-------------------------------------------------------------------------------
;	Function : SET_PHOVOL
;	input : ACCH = VOL
;	output: ACCH = 
;-------------------------------------------------------------------------------
SET_PHOVOL:
	PSH	CONF
;---	
	ANDL	0X0FF
	ORL	0XC800		;// Set LINE _GAIN & SPK_GAIN
	CALL	DAM_BIOSFUNC
;---
	POP	CONF
	
	RET
;-------------------------------------------------------------------------------
;	Function : PHOLED_H/PHOLED_L
;-------------------------------------------------------------------------------
PHOLED_H:
	LIPK	8

	IN	SYSTMP1,GPAD	;GPAD.CbPHOLED = 1
	LAC	SYSTMP1
	ORL	1<<CbPHOLED
	SAH	SYSTMP1
	OUT	SYSTMP1,GPAD
	ADHK	0
	
	RET
;---------------
PHOLED_L:
	LIPK	8

	IN	SYSTMP1,GPAD	;GPAD.CbPHOLED = 0
	LAC	SYSTMP1
	ANDL	~(1<<CbPHOLED)
	SAH	SYSTMP1
	OUT	SYSTMP1,GPAD
	ADHK	0
	
	RET
;-------------------------------------------------------------------------------
;	Function : SET_MICGAIN
;	input : ACCH(0..F)
;	output: ACCH
;-------------------------------------------------------------------------------
SET_MICGAIN:
	PSH	CONF
;-------
	SAH	SYSTMP0
;---	
	LACL	0x5F10		;set mic-pre-gain
	CALL	DAM_BIOSFUNC
	LAC	SYSTMP0		; --dB
	CALL	DAM_BIOSFUNC
;------
	POP	CONF
	
	RET
;-------------------------------------------------------------------------------
;       Function : SET_ANSEDCID
;
;       load new message number,total message number and DAM status into sendbuffer
;       Input  : no
;       Output : no
;-------------------------------------------------------------------------------
SET_ANSEDCID:
	BIT	ANN_FG,2
	BZ	TB,SET_ANSEDCID_END
	
	LAC	ANN_FG
	ANDL	~(1<<2)
	SAH	ANN_FG
;---the MAX. Number of Answered CID = CMAX_ANSWCID
	LACK	CGROUP_ANSWCID
	CALL	SET_TELGROUP	;Set MISS-CID Group
	CALL	GET_TELT
	SBHK	CMAX_ANSWCID	;The MAX. number of answered-CID
	BS	SGN,SET_ANSEDCID_1
	LACL	0XE501
	CALL	DAM_BIOSFUNC
	CALL	TEL_GC_CHK
SET_ANSEDCID_1:
;---Copy CID to Answered TEL-Group
	LACK	CGROUP_MISSCID
	CALL	SET_TELGROUP
	CALL	GET_TELT
	SAH	MSG_T
	ORL	(CGROUP_ANSWCID<<8)
	SAH	CONF1
	LACL	0XE70C
	CALL	DAM_BIOSFUNC
;---DEL	
	LAC	MSG_T
	ORL	0XE500
	CALL	DAM_BIOSFUNC
	CALL	TEL_GC_CHK
;---total miss-cid
	LACK	CGROUP_MISSCID
	CALL	SET_TELGROUP
	CALL	GET_TELT
	CALL	SEND_MISSCID
;---new cid
	CALL	GET_TELN
	CALL	SEND_NEWCID
	
;---total Answered cid
	LACK	CGROUP_ANSWCID
	CALL	SET_TELGROUP
	CALL	GET_TELT
	CALL	SEND_ANSWCID
SET_ANSEDCID_END:	
	RET
;-------------------------------------------------------------------------------
PHOVOL_TAB:
	;0	1	2	3	4	5	6	7
.DATA	0X00	0X03	0X06	0X08	0X0A	0X0C	0X0E	0X0F
;-------------------------------------------------------------------------------
.INCLUDE	block/l_telcomm.asm
.INCLUDE	block/tel_init.asm
;-------------------------------------------------------------------------------
.END
