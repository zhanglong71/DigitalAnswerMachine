.NOLIST
;---------------------------------------
.INCLUDE	include.inc
;---------------------------------------
.GLOBAL	LOCAL_PROPHO
.GLOBAL	INT_KEYMUTE
;-------------------------------------------------------------------------------
.EXTERN	SetFlashStartAddress
.EXTERN	LoadHostCode
.EXTERN	GetOneConst

;-------------------------------------------------------------------------------
.LIST
;-------------------------------------------------------------------------------
.ORG	ADDR_SECOND
;-------------------------------------------------------------------------------
.LIST
;-------------------------------------------------------------------------------
LOCAL_PROPHO:
	CALL	GET_MSG
	BS	ACZ,LOCAL_PROPHO_END
	SAH	MSG
;-------------------------------------------------------------------------------
LOCAL_PROPHO_MSG:	
	LAC	MSG
	XORL	CMSG_SER
	BS	ACZ,LOCAL_PROPHO_SER	;SEG-end

	LAC	MSG
	XORL	CHS_WORK
	BS	ACZ,LOCAL_PROPHO0_HOOKOFF
	LAC	MSG
	XORL	CHF_IDLE
	BS	ACZ,LOCAL_PROPHO_STOP
;---------------------------------------	
	LAC	PRO_VAR
	SFR	4
	ANDK	0X0F
	BS	ACZ,LOCAL_PROPHO0	;wait from start
	SBHK	1
	BS	ACZ,LOCAL_PROPHO1	;Speakerphone
	SBHK	1
	BS	ACZ,LOCAL_PROPHO2	;Mute to recover vol
	
LOCAL_PROPHO_END:	
	RET
;-------------------------------------------------------------------------------
;	note:	HF state change must relate to mute
;-------------------------------------------------------------------------------
LOCAL_PROPHO_SER:
	CALL	GETR_DAT
	ANDL	0XFF
	SAH	MSG
;---------------
	LAC	MSG
	SBHK	0X4F
	BS	ACZ,LOCAL_PROPHO_SER0X4F
	SBHK	0X01
	BS	ACZ,LOCAL_PROPHO_SER0X50
	SBHK	0X01
	BS	ACZ,LOCAL_PROPHO_SER0X51

	RET
;---------------------------------------
LOCAL_PROPHO_SER0X4F:
	
	RET
;---------------------------------------
LOCAL_PROPHO_SER0X50:
	CALL	GETR_DAT
	SAH	SYSTMP0
	
	LAC	EVENT
	ORK	(1<<2)
	SAH	EVENT				;Set mute on first
	
	BIT	SYSTMP0,0
	BS	TB,LOCAL_PROPHO_SER0X50_1	;Check mute status
	
	LAC	EVENT
	ANDL	~(1<<2)
	SAH	EVENT
	
LOCAL_PROPHO_SER0X50_1:
	CALL	MUTEMIC_ACTION			;Do mute
	
	LACL	CHF_WORK
	
	BIT	SYSTMP0,0
	BS	TB,LOCAL_PROPHO_SER0X50_2	;Check Speaker status
	
	LACL	CHF_IDLE
	
LOCAL_PROPHO_SER0X50_2:
	CALL	STOR_MSG
	
	RET
;---------------------------------------
LOCAL_PROPHO_SER0X51:
	CALL	GETR_DAT
	ADHK	0
	BS	ACZ,LOCAL_PROPHO_SER0X510X00
	SBHK	1
	BS	ACZ,LOCAL_PROPHO_SER0X510X01
	
	RET
LOCAL_PROPHO_SER0X510X00:
	LACL	CHS_IDLE
	CALL	STOR_MSG
	RET
LOCAL_PROPHO_SER0X510X01:	
	LACL	CHS_WORK
	CALL	STOR_MSG
	RET
	
;-------------------------------------------------------------------------------
LOCAL_PROPHO0:
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PROPHO0_TMR
	LAC	MSG
	XORL	CHF_WORK
	BS	ACZ,LOCAL_PROPHO0_PHONE

	RET
;---------------------------------------
LOCAL_PROPHO0_TMR:
	CALL	CLR_TIMER
	LACK	0X016
	SAH	PRO_VAR
	
	CALL	SPK_L	;spk-enable
;---------------
.if	DebugPhone	
	LAC	ATT_PHONE2
.else
	LACL	CATT_PHONE2
.endif
	ANDK	0X001F	
	CALL	SET_SPKVOL
;---------------
	CALL	PHONE_START

	RET
;---------------------------------------
LOCAL_PROPHO0_PHONE:
	CALL	INIT_DAM_FUNC
;-------
.if	1
	LACL	FlashLoc_H_f_IdleComm
	ADLL	FlashLoc_L_f_IdleComm
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_IdleComm
	ADLL	CodeSize_f_IdleComm
	CALL	LoadHostCode
.endif
;-------
	CALL	TEL_GC_CHK
PHONE_ATTSET:	;!!!!!!!!!!!!!!!!!!!!!!!
.if	1
	LIPK	8
        IN      SYSTMP1,GPAD
        IN      SYSTMP2,GPBD
;---Set Mic-Gain  
        LAC	ATT_PHONE2
        ANDL	0XF0FF
        SAH	ATT_PHONE2
        
        LAC	SYSTMP1		;Get GPAD(15..12)
        SFR	4		;(15..12) ==> (11..8)
        ANDL	0X0F00
        OR	ATT_PHONE2
        SAH	ATT_PHONE2
;---Set Tx-Gain  
        LAC	ATT_PHONE3
        ANDL	0XFFE0
        SAH	ATT_PHONE3
        
        LAC	SYSTMP2		;Get GPBD(7..5)
        SFR	5		;(7..5) ==> (2..0)
        ANDK	0X07
        ADHL	LINDRV_TAB
        CALL	GetOneConst
        OR	ATT_PHONE3
        SAH	ATT_PHONE3
;---Set T/R-switch
	LAC	ATT_PHONE1
        ANDL	0XFFF0
        SAH	ATT_PHONE1
        
        LAC	SYSTMP1		;Get GPAD(11..10)
        SFR	9		;(11..10) ==> (2..1)
        ANDK	0X06
        SAH	SYSTMP1
        
        LAC	SYSTMP2		;Get GPBD.8
        SFR	8		;bit8 ==> bit0
        ANDK	0X01
        OR	SYSTMP1
	OR	ATT_PHONE1
	SAH	ATT_PHONE1
.endif
PHONE_ATTSET_END:	;!!!!!!!!!!!!!!!
;---!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	ALCPORT_H	;Disable
	LACK	0
	SAH	PHOLED_FG	;LED on
	
	CALL	DAA_SPKPHONE

	LACK	0X006
	SAH	PRO_VAR
;---close ALC
	LACL	0X9000
	CALL	DAM_BIOSFUNC
;---for wait
	LACK	0
	SAH	PRO_VAR1
	LACL	CTMR400MS
   	CALL	SET_TIMER
;---start free run
	CALL	SET_PHONERUN

	RET
;-------------------------------------------------------------------------------
LOCAL_PROPHO2:
	LAC	MSG
	XORL	CMSG_TMR	
	BS	ACZ,LOCAL_PROPHO_TMR	;Only for spk-vol	
;-----------------------------
LOCAL_PROPHO1:
	LAC	MSG
	XORL	CPHONE_VOL
	BS	ACZ,LOCAL_PROPHO0_VOLSET
;---Mute command
	LAC	MSG
	XORL	CHF_WORK
	BS	ACZ,LOCAL_PROPHO1_MUTE	
;---Mute port	
	LAC	MSG
	XORL	CMSG_MUTE
	BS	ACZ,LOCAL_PROPHO0_PORTMUTE	;mute MIC/SPK
	LAC	MSG
	XORL	CMSG_UNMUTE
	BS	ACZ,LOCAL_PROPHO0_PORTUNMUTE	;unmute MIC/spk

	RET
;-------------------------------------------------
LOCAL_PROPHO0_PORTMUTE:
	LACK	0X016
	SAH	PRO_VAR		;Can't recover SPK-vol
;---Mute mic	
	LACK	0
	CALL	SET_MICGAIN	;set mic-pre-gain
;---Set LINE _GAIN & SPK_GAIN
	LACK	0X1
	ADHL	PHOVOL_TAB
	CALL    GetOneConst
	SAH	SYSTMP0		;Save SPK_GAIN
.if	DebugPhone	
	LAC	ATT_PHONE1
.else
	LACL	CATT_PHONE1
.endif	;????????????????????????---for debug
	ANDL	0X00F0		;Set LINE _GAIN
	OR	SYSTMP0

	CALL	SET_PHOVOL		;0XC8XX(default Value = 0XC8xx)
	
	RET
;-------------------------------------------------
LOCAL_PROPHO0_PORTUNMUTE:
	LACK	0X026
	SAH	PRO_VAR
;---------------
.if	DebugPhone	
	LAC	ATT_PHONE2
.else
	LACL	CATT_PHONE2
.endif
	SFR	8
	ANDK	0X000F		;Unmute MIC
	CALL	SET_MICGAIN
	
	LACL	CTMR1S
	CALL	SET_TIMER
;---

	RET
;-------------------------------------------------
LOCAL_PROPHO0_MUTE:
LOCAL_PROPHO1_MUTE:
	CALL	MUTEMIC_ACTION

	RET
;---------------------------------------
LOCAL_PROPHO0_HOOKON:		;免提状态时挂机
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	CALL	TEL_GC_CHK

	LACK	1
	SAH	PHOLED_FG	;speakerphone LED off
	
	LACL	CMODE9
	CALL	DAM_BIOSFUNC	;---开ALC

   	LACK	0
   	SAH	PRO_VAR
	
	LACL	CMSG_INIT
	CALL	STOR_MSG

	RET
;---------------------------------------
LOCAL_PROPHO0_HOOKOFF:		;免提状态时摘机
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	CALL	TEL_GC_CHK

	LACK	1
	SAH	PHOLED_FG	;speakerphone LED off
			
	LACL	CMODE9
	CALL	DAM_BIOSFUNC	;---开ALC

   	LACK	0
   	SAH	PRO_VAR
	
	LACL	CMSG_INIT
	CALL	STOR_MSG
	
	RET
;---------------------------------------
;-------Exit SpeakerPhone mode
LOCAL_PROPHO_STOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	CALL	TEL_GC_CHK
	LACK	1
	SAH	PHOLED_FG	;LED off
	
	LACL	CMODE9
	CALL	DAM_BIOSFUNC	;---开ALC

   	LACK	0
   	SAH	PRO_VAR
	
	LACL	CMSG_INIT
	CALL	STOR_MSG
	
	RET
;---------------------------------------
LOCAL_PROPHO0_VOLSET:
	LAC	VOI_ATT		;Get phone volume index
	SFR	4
	ANDK	0X0F
	ADHL	PHOVOL_TAB
	CALL    GetOneConst
	SAH	SYSTMP0		;Save phone volume
	
.if	DebugPhone	
	LAC	ATT_PHONE1
.else
	LACL	CATT_PHONE1
.endif	;????????????????????????---for debug
	ANDL	0X00F0		;Set LINE _GAIN
	OR	SYSTMP0

	CALL	SET_PHOVOL		;0XC8XX(default Value = 0XC8AA)

	RET

;-------------------------------------------------------------------------------
LOCAL_PROPHO_TMR:
	LACK	0X16
	SAH	PRO_VAR
	
	CALL	CLR_TIMER
;---Set LINE _GAIN & SPK_GAIN
	LAC	VOI_ATT		;Get SPK_GAIN
	SFR	4
	ANDK	0X0F
	ADHL	PHOVOL_TAB
	CALL    GetOneConst
	SAH	SYSTMP0		;Save SPK_GAIN
	
.if	DebugPhone	
	LAC	ATT_PHONE1
.else
	LACL	CATT_PHONE1
.endif	;????????????????????????---for debug
	ANDL	0X00F0		;Set LINE _GAIN
	OR	SYSTMP0

	CALL	SET_PHOVOL		;0XC8XX(default Value = 0XC8AA)

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
.if	DebugPhone	
	LAC	ATT_PHONE1
.else
	LACL	CATT_PHONE1
.endif	;????????????????????????---for debug
	SFR	8
	ANDL	0X00FF
	ORL	0XC400
   	;LACL	0XC430		;default Value
   	CALL	DAM_BIOSFUNC
;---Set T/R & R/T ratio
	.if	DebugPhone	
	LAC	ATT_PHONE1
.else
	LACL	CATT_PHONE1
.endif	;????????????????????????---for debug
	ANDK	0X0007
	ORL	0XC600
	
	;LACL	0XC603
	;LACL	0XC601
   	CALL	DAM_BIOSFUNC
;---Set LINE _GAIN & SPK_GAIN
	LAC	VOI_ATT		;Get SPK_GAIN
	SFR	4
	ANDK	0X0F
	ADHL	PHOVOL_TAB
	CALL    GetOneConst
	SAH	SYSTMP0		;Save SPK_GAIN
	
.if	DebugPhone	
	LAC	ATT_PHONE1
.else
	LACL	CATT_PHONE1
.endif	;????????????????????????---for debug
	ANDL	0X00F0		;Set LINE _GAIN
	OR	SYSTMP0

	CALL	SET_PHOVOL		;0XC8XX(default Value = 0XC8AA)
;---Set Loop Attenuation
.if	DebugPhone	
	LAC	ATT_PHONE2
.else
	LACL	CATT_PHONE2
.endif		;????????????????????????---for debug
	SFR	12
	ANDK	0X000F
	ORL	0XC900
	
	;LACL	0XC905
	CALL	DAM_BIOSFUNC
;---Line mute
    	LACL    0xC040         		;wait line mute for 400 ms
    	CALL    DAM_BIOSFUNC
;---free run
;    	CALL	PHONE_START

	RET

;-------------------------------------------------------------------------------
;	Function : SET_PHOVOL
;	input : ACCH = VOL
;	output: ACCH = 
;-------------------------------------------------------------------------------
SET_PHOVOL:
	PSH	COMMAND
;---	
	ANDL	0X0FF
	ORL	0XC800		;// Set LINE _GAIN & SPK_GAIN
	CALL	DAM_BIOSFUNC
;---
	POP	COMMAND
	
	RET
;----------------------------------------------------------------------------
;	Function : PHONE_START
;	input : no
;	output: no
;----------------------------------------------------------------------------
PHONE_START:
	LAC	EVENT
	ANDL	0XFF07
	ORK	1<<3
	SAH	EVENT
	
	LACL	0XC000
	SAH	COMMAND
	
	RET

;-------------------------------------------------------------------------------
;	Function : SET_SPKVOL
;	input : ACCH(0..1F)
;	output: ACCH
;-------------------------------------------------------------------------------
SET_SPKVOL:
	PSH	COMMAND
;-------
	SAH	SYSTMP0
;---	
	LACL	0x5F20		;set SPK volume
	CALL	DAM_BIOSFUNC
	LAC	SYSTMP0		; --dB
	CALL	DAM_BIOSFUNC
;------
	POP	COMMAND
	
	RET
;-------------------------------------------------------------------------------
;	Function : SET_LINVOL
;	input : ACCH(0..1F)
;	output: ACCH
;-------------------------------------------------------------------------------
SET_LINVOL:
	PSH	COMMAND
;-------
	SAH	SYSTMP0
;---	
	LACL	0x5F21		;set LINE volume
	CALL	DAM_BIOSFUNC
	LAC	SYSTMP0		; --dB
	CALL	DAM_BIOSFUNC
;------
	POP	COMMAND
	
	RET

;-------------------------------------------------------------------------------
;	Function : SET_MICGAIN
;	input : ACCH(0..F)
;	output: ACCH
;-------------------------------------------------------------------------------
SET_MICGAIN:
	PSH	COMMAND
;-------
	SAH	SYSTMP0
;---	
	LACL	0x5F10		;set mic-pre-gain
	CALL	DAM_BIOSFUNC
	LAC	SYSTMP0		; --dB
	CALL	DAM_BIOSFUNC
;------
	POP	COMMAND
	
	RET

;-------------------------------------------------------------------------------
;	Function : SET_AD1PGA
;	input : ACCH(0..F)
;	output: ACCH
;-------------------------------------------------------------------------------
SET_AD1PGA:
	PSH	COMMAND
;-------
	SAH	SYSTMP0
;---	
	LACL	0x5F11		;set AD2PGA
	CALL	DAM_BIOSFUNC
	LAC	SYSTMP0		; --dB
	CALL	DAM_BIOSFUNC
;------
	POP	COMMAND
	
	RET
;-------------------------------------------------------------------------------
;	Function : SET_AD2PGA
;	input : ACCH(0..F)
;	output: ACCH
;-------------------------------------------------------------------------------
SET_AD2PGA:
	PSH	COMMAND
;-------
	SAH	SYSTMP0
;---	
	LACL	0x5F12		;set AD2PGA
	CALL	DAM_BIOSFUNC
	LAC	SYSTMP0		; --dB
	CALL	DAM_BIOSFUNC
;------
	POP	COMMAND
	
	RET
;-------------------------------------------------
;	MUTEMIC_ACTION
;-------------------------------------------------	
MUTEMIC_ACTION:
	
	LACK	0
	
	BIT	EVENT,2
	BS	TB,MUTE_ACTION_MUTE
;MUTE_ACTION_UNMUTE:
	LACK	PMIC_GAIN
MUTE_ACTION_MUTE:
	CALL	SET_MICGAIN

	RET
;-------------------------------------------------------------------------------
PHOVOL_TAB:
	;0	1	2	3	4	5	6	7	8

.DATA	0X01	0X03	0X04	0X05	0X07	0X09	0X0A	0X0C	0x0E	
;---------------------------------------
;PHOVOL_TAB:
	;0	1	2	3	4	5	6	7	8	9	10	11	12	13	14	15

;.DATA	0X00	0X01	0X02	0X03	0X04	0X05	0X06	0X07	0x08	0x09	0x0A	0x0B	0x0C	0x0D	0x0E	0x0F

;-------------------------------------------------------------------------------
LINDRV_TAB:	;TX-GAIN
	;0	1	2	3	4	5	6	7

;.DATA	0X10	0X11	0X12	0X13	0X14	0X15	0X16	0X17
;.DATA	0X17	0X18	0X19	0X1A	0X1B	0X1C	0X1D	0X1E
.DATA	0X15	0X16	0X17	0X18	0X19	0X1A	0X1B	0X1C	
;-------------------------------------------------------------------------------
.INCLUDE	l_CodecPath/l_spkphone.asm

.INCLUDE	l_iic/l_getrqueue.asm

.INCLUDE	l_phone/l_keymute.asm

.INCLUDE	l_port/l_amp.asm
.INCLUDE	l_port/l_hwalc.asm
;.INCLUDE	l_port/l_phoneled.asm
.INCLUDE	l_port/l_spkctl.asm

;.INCLUDE	l_tel/l_tel_gcchk.asm
;-------------------------------------------------------------------------------

.END
