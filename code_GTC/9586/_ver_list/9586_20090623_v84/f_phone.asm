.NOLIST
.INCLUDE	include/REG_D22.inc
.INCLUDE	include/MD22U.inc
.INCLUDE	include/CONST.inc
.INCLUDE	include/EXTERN.inc

.GLOBAL	LOCAL_PROPHO

.GLOBAL	INT_KEYMUTE
;-------------------------------------------------------------------------------
.EXTERN	GetOneConst	;(INPUT=ACCH(ProgramRamAddress),OUTPUT=ACCH(ReadData))

;-------------------------------------------------------------------------------
.LIST
;-------------------------------------------------------------------------------
.ORG	ADDR_SECOND
;-------------------------------------------------------------------------------
.LIST
;-------------------------------------------------------------------------------
LOCAL_PROPHO:
;-------------------------------------------------------------------------------
	CALL	GET_RESPOND
	
	CALL	GET_MSG
	BS	ACZ,LOCAL_PROPHO_END
	SAH	MSG
	
	LAC	MSG
	XORL	CMSG_SER
	BS	ACZ,LOCAL_PROPHO_SER	;SEG-end
;---------------------------------------	
	LAC	PRO_VAR
	SFR	4
	ANDK	0X0F
	BS	ACZ,LOCAL_PROPHO0	;wait from start
	SBHK	1
	BS	ACZ,LOCAL_PROPHO1	;Speakerphone
	SBHK	1
	BS	ACZ,LOCAL_PROPHO2	;for unmute
	
LOCAL_PROPHO_END:	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROPHO_SER:
	CALL	GETR_DAT
	ANDL	0XFF
	SAH	MSG
;---------------	
	LAC	MSG
	SBHK	0X30
	BS	SGN,LOCAL_PROPHO_SER_END		;0x00<= x <0x30
	SBHK	0X10
	BS	SGN,LOCAL_PROPHO_SER_0X3040	;0x30<= x <0x40
	SBHK	0X10
	BS	SGN,LOCAL_PROPHO_SER_0X4050	;0x40<= x <0x50
	SBHK	0X10
	BS	SGN,LOCAL_PROPHO_SER_0X5060	;0x50<= x <0x60
	SBHK	0X10
	BS	SGN,LOCAL_PROPHO_SER_0X6070	;0x60<= x <0x70
	SBHK	0X10
	BS	SGN,LOCAL_PROPHO_SER_0X7080	;0x70<= x <0x80
	SBHK	0X10
	BS	SGN,LOCAL_PROPHO_SER_0X8090	;0x80<= x <0x90

LOCAL_PROPHO_SER_END:	
	RET
;---------------------------------------
LOCAL_PROPHO_SER_0X3040:
	RET
;---------------------------------------
LOCAL_PROPHO_SER_0X4050:
	LAC	MSG
	SBHK	0X4B
	BS	ACZ,LOCAL_PROPHO_SER_0X4B
	
	RET
;---------------------------------------
LOCAL_PROPHO_SER_0X4B:
	LAC	VOI_ATT
	ANDL	0XFF0F
	SAH	VOI_ATT
	
	CALL	GETR_DAT
	SAH	SYSTMP0
	SFL	4
	ANDL	0X00F0
	OR	VOI_ATT
	SAH	VOI_ATT
	
	LAC	SYSTMP0
	SFR	4
	ANDK	0X0F
	BS	ACZ,LOCAL_PROPHO_SER_0X4B_0
;LOCAL_PROPHO_SER_0X4B_1:
	CALL	AMP_ON
	BS	B1,LOCAL_PROPHO_SER_0X4B_DONE
LOCAL_PROPHO_SER_0X4B_0:
	CALL	AMP_OFF
LOCAL_PROPHO_SER_0X4B_DONE:
		
	LACL	CPHONE_VOL
	CALL	STOR_MSG
	
	RET
;---------------------------------------
LOCAL_PROPHO_SER_0X5060:
	LAC	MSG
	SBHK	0X5E
	BS	ACZ,LOCAL_PROPHO_SER_0X5E
	SBHK	0X01
	BS	ACZ,LOCAL_PROPHO_SER_0X5F
	
	
	RET
;---------------------------------------
LOCAL_PROPHO_SER_0X5E:	
	CALL	GETR_DAT
	SBHK	0
	BS	ACZ,LOCAL_PROPHO_SER_0X5E0X00
	RET
LOCAL_PROPHO_SER_0X5E0X00:
	LACL	CPHONE_OFF
	CALL	STOR_MSG
	
	RET
;---------------------------------------
LOCAL_PROPHO_SER_0X5F:
	CALL	GETR_DAT
	SBHK	0
	BS	ACZ,LOCAL_PROPHO_SER_0X5F0X00
	SBHK	1
	BS	ACZ,LOCAL_PROPHO_SER_0X5F0X01

	RET
LOCAL_PROPHO_SER_0X5F0X00:
	LACL	CMUTE_OFF
	CALL	STOR_MSG
	
	RET
LOCAL_PROPHO_SER_0X5F0X01:
	LACL	CMUTE_ON
	CALL	STOR_MSG
	
	RET	
;---------------------------------------
LOCAL_PROPHO_SER_0X6070:
	LAC	MSG
	SBHK	0X60
	BS	ACZ,LOCAL_PROPHO_SER_0X60
	
	RET
LOCAL_PROPHO_SER_0X60:
	CALL	GETR_DAT
	SBHK	0
	BS	ACZ,LOCAL_PROPLY_0X600X00
	SBHK	1
	BS	ACZ,LOCAL_PROPLY_0X600X01
	
	RET
LOCAL_PROPLY_0X600X00:
	LACL	CHOOK_ON
	CALL	STOR_MSG
	RET
LOCAL_PROPLY_0X600X01:	
	LACL	CHOOK_OFF
	CALL	STOR_MSG
	RET
;---------------------------------------
LOCAL_PROPHO_SER_0X7080:
LOCAL_PROPHO_SER_0X8090:
	RET
;-------------------------------------------------------------------------------
LOCAL_PROPHO0:
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PROPHO0_TMR
	LAC	MSG
	XORL	CPHONE_ON
	BS	ACZ,LOCAL_PROPHO0_PHONE
	
	RET
;---------------------------------------
LOCAL_PROPHO0_TMR:
	LACL	1000
	CALL	SET_TIMER
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
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
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
	CALL	INIT_DAM_FUNC
	
	CALL	ALCPORT_H	;Disable
	;CALL	PHOLED_L	;LED on
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
	LACL	400
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
	XORL	CMUTE_ON
	BS	ACZ,LOCAL_PROPHO0_MUTE		;mute MIC
	LAC	MSG
	XORL	CMUTE_OFF
	BS	ACZ,LOCAL_PROPHO0_UNMUTE	;unmute MIC
;---Mute port	
	LAC	MSG
	XORL	CMSG_MUTE
	BS	ACZ,LOCAL_PROPHO0_PORTMUTE	;mute MIC/SPK
	LAC	MSG
	XORL	CMSG_UNMUTE
	BS	ACZ,LOCAL_PROPHO0_PORTUNMUTE	;unmute MIC/spk
;---	
	LAC	MSG
	XORL	CHOOK_ON
	BS	ACZ,LOCAL_PROPHO0_HOOKON
	LAC	MSG
	XORL	CHOOK_OFF
	BS	ACZ,LOCAL_PROPHO0_HOOKOFF
;---	
	LAC	MSG
	XORL	CSPK_ENABLE
	BS	ACZ,LOCAL_PROPHO0_ENSPK
	LAC	MSG
	XORL	CSPK_DISABLE
	BS	ACZ,LOCAL_PROPHO0_DISSPK
;---	
	LAC	MSG
	XORL	CPHONE_OFF
	BS	ACZ,LOCAL_PROPHO_STOP
	
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
	
	LACL	400
	CALL	SET_TIMER
;---
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.if	0
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
.endif
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	RET
;-------------------------------------------------
LOCAL_PROPHO0_MUTE:
.if	DebugMuteMic
	LACK	0
	CALL	SET_MICGAIN
.else
;---Line mute
	;LACL    0xC040         		;wait line mute for 400 ms
	;CALL    DAM_BIOSFUNC
	LACK	0
	CALL	SET_LINVOL
.endif
	RET
;---------------------------------------
LOCAL_PROPHO0_UNMUTE:	;set mic-pre-gain
.if	DebugMuteMic
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.if	DebugPhone	
	LAC	ATT_PHONE2
.else
	LACL	CATT_PHONE2
.endif

	SFR	8
	ANDK	0X000F
	CALL	SET_MICGAIN
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.else
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;---set LINE volume
.if	DebugPhone	
	LAC	ATT_PHONE3
.else
	LACL	CATT_PHONE3
.endif	
	ANDK	0X001F
	CALL	SET_LINVOL	; set Lout volume
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.endif	
	RET
;---------------------------------------
LOCAL_PROPHO0_HOOKON:		;免提状态时挂机
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF

	;CALL	PHOLED_H	;speakerphone LED off
	LACK	1
	SAH	PHOLED_FG	;LED off
	
	LACL	CMODE9
	CALL	DAM_BIOSFUNC	;---开ALC

   	LACK	0
   	SAH	PRO_VAR

	RET
;---------------------------------------
LOCAL_PROPHO0_HOOKOFF:		;免提状态时摘机
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF

	;CALL	PHOLED_H	;speakerphone LED off
	LACK	1
	SAH	PHOLED_FG	;LED off
			
	LACL	CMODE9
	CALL	DAM_BIOSFUNC	;---开ALC

   	LACK	0
   	SAH	PRO_VAR
	
	RET
;---------------------------------------
LOCAL_PROPHO0_ENSPK:
	LIPK    6
	IN	SYSTMP0,SWITCH
	LAC	SYSTMP0
	ORL	1<<7
	SAH	SYSTMP0
	OUT	SYSTMP0,SWITCH
	ADHK	0
	RET
;---------------------------------------
LOCAL_PROPHO0_DISSPK:
	LIPK    6
	IN	SYSTMP0,SWITCH
	LAC	SYSTMP0
	ANDL	~(1<<7)
	SAH	SYSTMP0
	OUT	SYSTMP0,SWITCH
	ADHK	0
	RET
;-------Exit SpeakerPhone mode
LOCAL_PROPHO_STOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF

	;CALL	PHOLED_H	;LED off
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

	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER	

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
	PSH	CONF
;---	
	ANDL	0X0FF
	ORL	0XC800		;// Set LINE _GAIN & SPK_GAIN
	CALL	DAM_BIOSFUNC
;---
	POP	CONF
	
	RET
;----------------------------------------------------------------------------
;	Function : PHONE_START
;	input : no
;	output: no
;----------------------------------------------------------------------------
PHONE_START:
	LAC	EVENT
	ANDL	0XFF00
	;ORK	0X08
	ORK	1<<3
	SAH	EVENT
	
	LACL	0XC000
	SAH	CONF
	
	RET

;-------------------------------------------------------------------------------
;	Function : SET_SPKVOL
;	input : ACCH(0..1F)
;	output: ACCH
;-------------------------------------------------------------------------------
SET_SPKVOL:
	PSH	CONF
;-------
	SAH	SYSTMP0
;---	
	LACL	0x5F20		;set SPK volume
	CALL	DAM_BIOSFUNC
	LAC	SYSTMP0		; --dB
	CALL	DAM_BIOSFUNC
;------
	POP	CONF
	
	RET
;-------------------------------------------------------------------------------
;	Function : SET_LINVOL
;	input : ACCH(0..1F)
;	output: ACCH
;-------------------------------------------------------------------------------
SET_LINVOL:
	PSH	CONF
;-------
	SAH	SYSTMP0
;---	
	LACL	0x5F21		;set LINE volume
	CALL	DAM_BIOSFUNC
	LAC	SYSTMP0		; --dB
	CALL	DAM_BIOSFUNC
;------
	POP	CONF
	
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
;	Function : SET_AD1PGA
;	input : ACCH(0..F)
;	output: ACCH
;-------------------------------------------------------------------------------
SET_AD1PGA:
	PSH	CONF
;-------
	SAH	SYSTMP0
;---	
	LACL	0x5F11		;set AD2PGA
	CALL	DAM_BIOSFUNC
	LAC	SYSTMP0		; --dB
	CALL	DAM_BIOSFUNC
;------
	POP	CONF
	
	RET
;-------------------------------------------------------------------------------
;	Function : SET_AD2PGA
;	input : ACCH(0..F)
;	output: ACCH
;-------------------------------------------------------------------------------
SET_AD2PGA:
	PSH	CONF
;-------
	SAH	SYSTMP0
;---	
	LACL	0x5F12		;set AD2PGA
	CALL	DAM_BIOSFUNC
	LAC	SYSTMP0		; --dB
	CALL	DAM_BIOSFUNC
;------
	POP	CONF
	
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
.INCLUDE	l_CodecPath/l_allopen.asm
.INCLUDE	l_CodecPath/l_spkphone.asm

.INCLUDE	l_iic/l_getrqueue.asm
.INCLUDE	l_respond/l_spkphone.asm

.INCLUDE	l_phone/l_keymute.asm

.INCLUDE	l_port/l_amp.asm
.INCLUDE	l_port/l_hwalc.asm
.INCLUDE	l_port/l_phoneled.asm
.INCLUDE	l_port/l_spkctl.asm
;-------------------------------------------------------------------------------

.END
