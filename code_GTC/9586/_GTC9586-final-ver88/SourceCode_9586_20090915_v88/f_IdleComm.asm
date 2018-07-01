.NOLIST
.INCLUDE	include/REG_D22.inc
.INCLUDE	include/MD22U.inc
.INCLUDE	include/CONST.inc
.INCLUDE	include/EXTERN.inc

.GLOBAL	SER_COMMAND
;-------------------------------------------------------------------------------
.EXTERN	GetOneConst	;(INPUT=ACCH(ProgramRamAddress),OUTPUT=ACCH(ReadData))
.EXTERN	GetMoreConst	;(INPUT=ACCH(ProgramRamStartingAddress)ACCL(ReadWordNumber)AR1(StoreDataRamAddress),OUTPUT=)

;---
.LIST
;-------------------------------------------------------------------------------
.ORG	ADDR_SECOND
;-------------------------------------------------------------------------------
SER_COMMAND:
	CALL	GETR_DAT
	ANDL	0XFF
	SAH	MSG
;---------------------------------------	
	LAC	MSG
	SBHK	0X30
	BS	SGN,SYS_MSG_YES		;0x00<= x <0x30
	SBHK	0X10
	BS	SGN,SYS_SER_RUN_0X3040	;0x30<= x <0x40
	SBHK	0X10
	BS	SGN,SYS_SER_RUN_0X4050	;0x40<= x <0x50
	SBHK	0X10
	BS	SGN,SYS_SER_RUN_0X5060	;0x50<= x <0x60
	SBHK	0X10
	BS	SGN,SYS_SER_RUN_0X6070	;0x60<= x <0x70
	SBHK	0X10
	BS	SGN,SYS_SER_RUN_0X7080	;0x70<= x <0x80
	SBHK	0X10
	BS	SGN,SYS_SER_RUN_0X8090	;0x80<= x <0x90
SYS_MSG_YES:
SYS_MSG_NO:
	RET
;---------------------------------------
SYS_SER_RUN_0X3040:
	;LAC	MSG
	;SBHK	0X31
	;BS	ACZ,SYS_SER_RUN_0X31	;record 2-WAY
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X4050:
	LAC	MSG
	SBHK	0X40
	BS	ACZ,SYS_SER_RUN_SetLanguage	;0x40-set_language
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_SetRing		;0x41-Set RING_NUM_TO_ANS
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_12SetPassWord	;0x42-set PASSWORD(11..8)
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_34SetPassWord	;0x43-Sset PASSWORD(7..0)
	SBHK	0X02
	BS	ACZ,SYS_SER_RUN_SetCompressRate	;0x45-Set CompressRate
	SBHK	0X05
	BS	ACZ,LOCAL_PROKEYVP_SETVOL	;0x4A-SetVol
	SBHK	0X01
	BS	ACZ,LOCAL_PROKEYVP_SETHFVOL	;0x4B-SetHFVol
	SBHK	0X02
	BS	ACZ,SYS_SER_RUN_SetMenuVOP	;0x4D-Talk_setup_menu
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_SetWeek		;0x4E-set_ITAD_clock(week)
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_SetMDHM		;set_ITAD_clock
;-------
	BS	B1,SYS_MSG_YES

SYS_SER_RUN_0X5060:
;-------
	LAC	MSG
	SBHK	0X50
	BS	ACZ,SYS_SER_RUN_0X50	;on/off
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X51	;OGM Select
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X52	;play OGM
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X53	;record OGM
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X54	;play message
	SBHK	0X01
	;BS	ACZ,SYS_SER_RUN_0X55	;pause playing
	SBHK	0X01
	;BS	ACZ,SYS_SER_RUN_0X56	;skip to next message
	SBHK	0X01
	;BS	ACZ,SYS_SER_RUN_0X57	;repeat/previous
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X58	;play memo help
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X59	;record memo/2WAY
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X5A	;stop
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X5B	;message delete
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X5C	;all old message delete
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X5D	;fast play
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X5E	;speakerphone
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X5F	;mute
;-------
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X6070:
	LAC	MSG
	SBHK	0X60
	BS	ACZ,SYS_SER_RUN_0X60	;Handset on/off HOOK
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X61	;CID
	SBHK	0X01
	;BS	ACZ,SYS_SER_RUN_0X62	;slow play
	SBHK	0X01
	;BS	ACZ,SYS_SER_RUN_0X63	;normal play
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X64	;SPK on/off
	SBHK	0X06
	BS	ACZ,SYS_SER_RUN_0X6A
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X6B	;TestMode
	SBHK	0X04
	BS	ACZ,SYS_SER_RUN_0X6F	;
	
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X7080:
	LAC	MSG
	SBHK	0X70
	BS	ACZ,SYS_SER_RUN_0X70	;MCU925 receive error message information and give back decision(delete all or not)
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X71	;LEC
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X72	;T/R Ratio
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X73	;LINE_GAIN
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X74	;Loop Attenuation
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X75	;MIC-PRE-PGA
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X76	;LIN-DRV
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X77	;AD1-PGA
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X78	;AD2-PGA
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X79	;SPK-DRV
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X8090:
	LAC	MSG
	SBHL	0X80
	BS	ACZ,SYS_SER_RUN_0X80
	
	BS	B1,SYS_MSG_YES
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
SYS_SER_RUN_0X31:
	;LACL	CREC_2WAY
	;SAH	MSG
	BS	B1,SYS_MSG_YES
;---------------------------------------
SYS_SER_RUN_SetLanguage:	;set language
	LAC	VOI_ATT
	ANDL	0XFCFF
	SAH	VOI_ATT
	
	CALL	GETR_DAT
	ANDK	0X0003
	SFL	8
	OR	VOI_ATT
	SAH	VOI_ATT
	
	BS	B1,SYS_MSG_YES	
;---------------------------------------
SYS_SER_RUN_SetRing:	;Set RING_NUM_TO_ANS
	LAC	VOI_ATT
	ANDL	0X0FFF
	SAH	VOI_ATT
	
	CALL	GETR_DAT
	ANDK	0X0F
	SFL	12
	OR	VOI_ATT
	SAH	VOI_ATT
	BS	B1,SYS_MSG_YES
;---------------------------------------
SYS_SER_RUN_12SetPassWord:
	LAC	PASSWORD
	ANDL	0XF0FF
	SAH	PASSWORD
	
	CALL	GETR_DAT
	ANDK	0X0F
	SFL	8
	OR	PASSWORD
	SAH	PASSWORD

	BS	B1,SYS_MSG_YES
SYS_SER_RUN_34SetPassWord:		;second and third remote code
	LAC	PASSWORD
	ANDL	0XFF00
	SAH	PASSWORD
	
	CALL	GETR_DAT
	OR	PASSWORD
	SAH	PASSWORD

	BS	B1,SYS_MSG_YES
;---------------------------------------
SYS_SER_RUN_SetCompressRate:	;Set CompressRate
	LAC	VOI_ATT
	ANDL	~(1<<10)
	SAH	VOI_ATT

	CALL	GETR_DAT
	ANDK	0X0001
	SFL	10
	OR	VOI_ATT
	SAH	VOI_ATT
	
	BS	B1,SYS_MSG_YES
;---------------------------------------
LOCAL_PROKEYVP_SETVOL:
	LAC	VOI_ATT
	ANDL	0XFFF0
	SAH	VOI_ATT
	
	CALL	GETR_DAT
	ANDK	0X000F
	OR	VOI_ATT
	SAH	VOI_ATT

	LACK	0X7F
	SAH	DTMF_VAL
	LACL	CKEY_VOP
	CALL	STOR_MSG

	BS	B1,SYS_MSG_YES
;---------------------------------------
LOCAL_PROKEYVP_SETHFVOL:	;not in spkphone mode set Speakerphone volume (GTC demand;2009-6-30 20:42)
	LAC	VOI_ATT
	ANDL	0XFF0F
	SAH	VOI_ATT
	
	CALL	GETR_DAT
	SAH	SYSTMP0
	SFL	4
	ANDL	0X00F0
	OR	VOI_ATT
	SAH	VOI_ATT
	
	BS	B1,SYS_MSG_YES
;---------------------------------------
SYS_SER_RUN_SetMenuVOP:
	LACL	CKEY_VOP	;Setup_menu
	CALL	STOR_MSG
	
	LACK	0X73		;Setup_menu ...
	SAH	DTMF_VAL
	
	BS	B1,SYS_MSG_YES
;---------------------------------------
SYS_SER_RUN_SetWeek:
	LAC	PRO_VAR
	BZ	ACZ,SYS_MSG_YES		;Playing
;---------------------------------------idle	
	CALL	INIT_DAM_FUNC
	
	CALL	GETR_DAT
	CALL	WEEK_SET
	
	BS	B1,SYS_MSG_YES
;---------------------------------------
SYS_SER_RUN_SetMDHM:
	LAC	PRO_VAR
	BZ	ACZ,SYS_MSG_YES		;Playing
	
;---------------------------------------idle
	CALL	INIT_DAM_FUNC

	LACK	0	;clear timer-second first
	CALL	SEC_SET		;second

	CALL	GETR_DAT
	CALL	DGT_HEX
	CALL	MON_SET		;month
	
	CALL	GETR_DAT
	CALL	DGT_HEX
	CALL	DAY_SET		;day
	
	CALL	GETR_DAT
	CALL	HOUR_CONV
	CALL	DGT_HEX
	CALL	HOUR_SET	;hour
	
	CALL	GETR_DAT
	CALL	DGT_HEX
	CALL	MIN_SET		;minute

;-------

;---------------------------------------

	BS	B1,SYS_MSG_YES
;---------------------------------------
SYS_SER_RUN_0X50:
	CALL	GETR_DAT
	ANDK	0X7F
	BS	ACZ,SYS_SER_RUN_0X500X00
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X500X01
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X500X00:		;ANS-off
	LAC	EVENT
	ORL	1<<9
	SAH	EVENT
	
	LACL	CKEY_VOP	;按键音
	CALL	STOR_MSG
	
	LACK	0X71		;VP_AnswerOn
	SAH	DTMF_VAL
	
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X500X01:		;ANS-on
	
	LAC	EVENT
	ANDL	~(1<<9)
	SAH	EVENT
	
	LACL	CKEY_VOP	;按键音
	CALL	STOR_MSG
	
	LACK	0X72		;VP_AnswerOff
	SAH	DTMF_VAL
	
	BS	B1,SYS_MSG_YES
;---------------
SYS_SER_RUN_0X51:
	CALL	GETR_DAT
	ANDL	0X0FF
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X510X01
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X510X02
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X510X01:		;select OGM1
	LAC	EVENT
	ANDL	~(1<<8)
	SAH	EVENT
	BS	B1,SYS_MSG_YES
	
SYS_SER_RUN_0X510X02:		;select OGM2
	LAC	EVENT
	ORL	1<<8
	SAH	EVENT
	BS	B1,SYS_MSG_YES
;---------------
SYS_SER_RUN_0X52:		;play current OGM
	LACL	CMSG_KEY5S
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X53:		;record current OGM
	LACL	CMSG_KEY5L
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
;---------------
SYS_SER_RUN_0X54:
	LACL	CMSG_PLY	;play message
	CALL	STOR_MSG

	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X55:
	;LACL	CPLY_PAUSE	;pause playing
	;CALL	STOR_MSG

	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X56:
	;LACL	CPLY_NEXT	;next message
	;CALL	STOR_MSG

	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X57:
	LACL	CPLY_PREV	;previous/repeat message
	CALL	STOR_MSG

	BS	B1,SYS_MSG_YES
;---------------
SYS_SER_RUN_0X58:
	LACL	CKEY_VOP	;按键音
	CALL	STOR_MSG
	
	LACK	0X70		;按键音ID
	SAH	DTMF_VAL

	BS	B1,SYS_MSG_YES
;---------------
SYS_SER_RUN_0X59:
	LACL	CREC_MEMO	;record MEMO
	CALL	STOR_MSG

	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X5A:
	LACL	CMSG_KEY6S	;stop
	CALL	STOR_MSG

	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X5B:		;erase playing message
	LACL	CPLY_ERAS
	CALL	STOR_MSG

	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X5C:
	LACL	COLD_ERAS	;erase all old messages
	CALL	STOR_MSG

	BS	B1,SYS_MSG_YES
;---------------
SYS_SER_RUN_0X5D:
	CALL	GETR_DAT
	ANDL	0X0FF
	BS	ACZ,SYS_SER_RUN_0X5D0X00
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X5D0X01
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X5D0X02
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X5D0X00:	;normal play speed
SYS_SER_RUN_0X5D0X01:	;play speed up 100%
SYS_SER_RUN_0X5D0X02:	;play speed down 100%
	BS	B1,SYS_MSG_YES
;---------------
SYS_SER_RUN_0X5E:
	CALL	GETR_DAT
	ANDL	0X0FF
	BS	ACZ,SYS_SER_RUN_0X5E0X00
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X5E0X01
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X5E0X00:
	LACL	CPHONE_OFF	;speaker phone mode
	CALL	STOR_MSG

	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X5E0X01:
	LACL	CPHONE_ON	;exist speaker phone mode
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
;---------------
SYS_SER_RUN_0X5F:
	CALL	GETR_DAT
	ANDL	0X0FF
	BS	ACZ,SYS_SER_RUN_0X5F0X00
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X5F0X01
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X5F0X00:
	LACL	CMUTE_OFF	;release mute MIC at MIC mute and release MIC mute
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X5F0X01:
	LACL	CMUTE_ON	;mute MIC at SPK mode to microphone
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
;---------------
SYS_SER_RUN_0X60:
	CALL	GETR_DAT
	ANDL	0X0FF
	BS	ACZ,SYS_SER_RUN_0X600X00
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X600X01
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X600X00:
	LACL	CHOOK_ON	;put down the handset to on hook for end a call
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X600X01:
	LACL	CHOOK_OFF	;pickup the handset to off hook in handset mode
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
;---------------
SYS_SER_RUN_0X61:
	LACL	CCID_VOP
	CALL	STOR_MSG	;CID receive
	BS	B1,SYS_MSG_YES
;---------------
SYS_SER_RUN_0X62:
SYS_SER_RUN_0X63:

	BS	B1,SYS_MSG_YES
;---------------
SYS_SER_RUN_0X64:
	CALL	GETR_DAT
	ANDK	0X0F
	BS	ACZ,SYS_SER_RUN_0X640X00
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X640X01
	
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X640X00:
	
	LACL	CSPK_ENABLE	;EnableSpeaker 
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X640X01:
	
	LACL	CSPK_DISABLE	;DisableSpeaker
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
;---------------
SYS_SER_RUN_0X6A:

	CALL	GETR_DAT
	ANDK	0X0F
	SAH	DTMF_VAL

	LACL	CKEY_VOP
	CALL	STOR_MSG

	BS	B1,SYS_MSG_YES
;---------------
SYS_SER_RUN_0X6B:
	CALL	GETR_DAT
	ANDK	0X7F
	BS	ACZ,SYS_SER_RUN_0X6B0X00
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X6B0X01
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X6B0X02	;DSP off hook and record from line
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X6B0X03
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X6B0X04
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X6B0X05
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X6B0X06
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X6B0X07
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X6B0X08
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X6B0X09	;Off-hook,detect DTMF and digit through DTMF dialing
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X6B0X0A	;VOX detect
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X6B0X0B
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X6B0X0C
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X6B0X0D
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X6B0X0E
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X6B0X0F

	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X6B0X00:		;reserved
	;LACL	CTMSG_OUT
	;CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X6B0X01:
	LACL	CTMODE_IN	;enter test mode
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X6B0X02:
	LACL	CTMSG_LREC	;DSP off hook and record from line
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X6B0X03:
	LACL	CTMSG_TONEL	;DSP off hook and generate 1KH tone to line
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X6B0X04:
	LACL	CTMSG_MEMS	;DSP count flash memory capability and send to MCU
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X6B0X05:		;Reserved
	;LACL	CTMSG_PVOP
	;CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X6B0X06:
	LACL	CTMSG_STOP	;cancel the current test item
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X6B0X07:		;Reserved
	;LACL	CTMSG_FMAT
	;CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X6B0X08:
	LACL	CTMSG_LICMS
	CALL	STOR_MSG	;Off-hook Play OGM to line repeatly,stop and exit until STOP_TO_STANDBY
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X6B0X09:
	LACL	CTMSG_DTMFD
	CALL	STOR_MSG	;Off-hook,detect DTMF and digit through DTMF dialing
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X6B0X0A:
	LACL	CTMSG_VOXD
	CALL	STOR_MSG	;VOX detect
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X6B0X0B:
	LACL	CTMSG_MRECS
	CALL	STOR_MSG	;MEMO RECORD -> Delay 2s -> On-hook play it to SPK repeatly
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X6B0X0C:
	LACL	CTMSG_TONES
	CALL	STOR_MSG	;On-hook,play beep tone to the SPK,stopuntil STOP-TO-STANDBY received
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X6B0X0D:
	LACL	CTMSG_LICML
	CALL	STOR_MSG	;On-hook and record from MIC,Stop and exit until STOP_TO_STANDBY
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X6B0X0E:
	LACL	CTMSG_MRECL
	CALL	STOR_MSG	;MEMO RECORD -> Delay 2s -> Off-hook play it to line repeatly
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X6B0X0F:
	BS	B1,SYS_MSG_YES
;---------------------------------------
SYS_SER_RUN_0X6F:
	;LACL	CERAE_ALLVP
	;SAH	MSG
	
	CALL	INIT_DAM_FUNC

	LACL    CMODE9|1
    	CALL    DAM_BIOSFUNC
;-!!!
	LACK	0X2F
	CALL	SEND_DAT
	LACK	0X2F
	CALL	SEND_DAT
;-!!!
	BS	B1,SYS_MSG_YES	;Erase all VP(Memo/Ogm/Icm)
;---------------------------------------
SYS_SER_RUN_0X70:	;Message Error
	CALL	GETR_DAT
	BS	ACZ,SYS_SER_RUN_0X700X00
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X700X01
SYS_SER_RUN_0X700X00:
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X700X01:
	CALL	INIT_DAM_FUNC
	
	LACL    CMODE9|1
    	CALL    DAM_BIOSFUNC

	LAC	ERR_FG
	ANDL	~((1<<1)|(1))
	SAH	ERR_FG

    	LACK	0X005
    	CALL	STOR_VP

	BS	B1,SYS_MSG_YES
;---------------------------------------
SYS_SER_RUN_0X71:	;LEC

	BS	B1,SYS_MSG_YES
;---------------
SYS_SER_RUN_0X72:	;T/R Ratio

	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X73:	;LINE_GAIN

	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X74:	;Loop Attenuation

	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X75:	;MIC-PRE-PGA

	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X76:	;LIN-DRV

	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X77:	;AD1-PGA

	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X78:	;AD2-PGA

	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X79:	;SPK-DRV

	BS	B1,SYS_MSG_YES
;---------------------------------------
SYS_SER_RUN_0X80:

	LACK	0	;clear timer-second first
	CALL	SEC_SET
;------	
	CALL	GETR_DAT	;byte1 - year ==> week
	CALL	DGT_HEX
	;CALL	YEAR_SET
	CALL	WEEK_SET	;2008-2-27 14:35
	
	CALL	GETR_DAT	;byte2 - month
	CALL	DGT_HEX
	CALL	MON_SET
;-	
	CALL	GETR_DAT	;byte3 - day
	CALL	DGT_HEX
	CALL	DAY_SET
;-	
	CALL	GETR_DAT	;byte4 - hour
	CALL	HOUR_CONV
	CALL	DGT_HEX
	CALL	HOUR_SET
;-	
	CALL	GETR_DAT	;byte5 - minute
	CALL	DGT_HEX
	CALL	MIN_SET
;---
	CALL	GETR_DAT	;byte6 - ps1
	SFL	8
	ANDL	0X0F00
	SAH	PASSWORD
	CALL	GETR_DAT	;byte7 - ps2,3
	OR	PASSWORD
	SAH	PASSWORD
;---
	LAC	VOI_ATT
	ANDL	0X0FF0
	SAH	VOI_ATT		;clean ringcnt and vol

	CALL	GETR_DAT	;byte8 - Ring-VOL
	SAH	MSG
	ANDK	0X0F
	OR	VOI_ATT
	SAH	VOI_ATT		;Stor Vol
	
	LAC	MSG
	SFL	8
	ANDL	0XF000
	OR	VOI_ATT
	SAH	VOI_ATT		;Stor ringcnt
	
	;LAC	VOI_ATT
	;ANDL	0X0FF0
	;OR	MSG
	;SAH	VOI_ATT	
;---
	CALL	GETR_DAT	;byte9 - bMap
	CALL	SET_DAMATT
;-------
	;CALL	GET_WEEK
	;CALL	WEEK_SET
;---------------------------------------
	BIT	ANN_FG,0
	BZ	TB,SYS_MSG_YES
	;BS	b1,SYS_MSG_YES		;?????????????????????????????
	LAC	ANN_FG
	ANDL	~(1)
	SAH	ANN_FG		;clear initial bit

	CALL	CLR_TIMER
	
	CALL	INIT_DAM_FUNC

	LACL	300	
	CALL	DELAY	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!make sure the MCU receive the number of message
	
	LACL	CKEY_VOP
	CALL	STOR_MSG
	LACK	0X74		;VP_ElectrifyOn
	SAH	DTMF_VAL

	;LACL	CMSG_ATT	; for power-on VoicePrompt
	;CALL	STOR_MSG
	
	BS	B1,SYS_MSG_YES	
;-------------------------------------------------------------------------------

;===============================================================================
;	Function : YEAR_SET
;将大于4的部分保存在 TMR_YEAR 中,小于4的部分保存在机器的指定区域
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
YEAR_SET:
	SAH	SYSTMP0
	LACK	0
	SAH	TMR_YEAR
YEAR_SET_LOOP:
	LAC	SYSTMP0
	SBHK	4
	BS	SGN,YEAR_SET_1

	LAC	SYSTMP0
	SBHK	4
	SAH	SYSTMP0
	
	LAC	TMR_YEAR
	ADHK	4
	SAH	TMR_YEAR
	BS	B1,YEAR_SET_LOOP
YEAR_SET_1:
	LAC	SYSTMP0
	ORL	0X7600
	CALL	DAM_BIOSFUNC
	RET
;-------------------------------------------------------------------------------
;	Function : MON_SET
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
MON_SET:
	ORL	0X7500
	CALL	DAM_BIOSFUNC
	RET
;-------------------------------------------------------------------------------
;	Function : DAY_SET
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
DAY_SET:
	ORL	0X7400
	CALL	DAM_BIOSFUNC
	RET
;===============================================================================
;	Function : WEEK_SET
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
WEEK_SET:
	ORL	0X7300
	CALL	DAM_BIOSFUNC
	RET
;-------------------------------------------------------------------------------
;	Function : HOUR_CONV
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
HOUR_CONV:
	SAH	SYSTMP0
	SBHK	0X12
	BS	SGN,HOUR_COMP_0111	;<12 = 0x01/0x02/0x03/0x04/0x05/0x06/0x07/0x08/0x09/0x10/0x11
	BS	ACZ,HOUR_COMP_0		;=12 = 0x12 
;-
	LAC	SYSTMP0
	SBHL	0X92		
	BS	ACZ,HOUR_COMP_12	;12PM = 0x92
;---13..23(0x81/0x82/0x83/0x84/0x85/0x86/0x87/0x88/0x89/0x90/0x91/)
	LAC	SYSTMP0	
	ADHK	0X12
	ANDK	0X7F
	SAH	SYSTMP0			;More than 13
HOUR_COMP_0111:	
	LAC	SYSTMP0			;Less than 12
	RET
HOUR_COMP_0:
	LACK	0
	RET
HOUR_COMP_12:
	LACK	0X12
	RET
;-------------------------------------------------------------------------------
;	Function : HOUR_SET
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------

HOUR_SET:
	ORL	0X7200
	CALL	DAM_BIOSFUNC

	RET
;-------------------------------------------------------------------------------
;	Function : MIN_SET
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
MIN_SET:
	ORL	0X7100
	CALL	DAM_BIOSFUNC
	RET
;-------------------------------------------------------------------------------
;	Function : SEC_SET
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
SEC_SET:
	ORL	0X7000
	CALL	DAM_BIOSFUNC
	RET
;-------------------------------------------------------------------------------
;	Set DAM attribute
;-------------------------------------------------------------------------------
SET_DAMATT:
	SAH	SYSTMP0
	
	LAC	EVENT
	ANDL	~((1<<8)|(1<<9))
	SAH	EVENT

	LAC	VOI_ATT
	ANDL	~((1<<8)|(1<<9)|(1<<10))
	SAH	VOI_ATT
;SET_DAMATT_0:	
;---CallScreening(正逻辑)
	;BIT	SYSTMP0,7
	;BZ	TB,SET_DAMATT_1
	
	;LAC	VOI_ATT
	;ORL	(1<<11)
	;SAH	VOI_ATT
;SET_DAMATT_0:	
;---CompressRate(正逻辑)
	BIT	SYSTMP0,7
	BZ	TB,SET_DAMATT_1
	
	LAC	VOI_ATT
	ORL	(1<<10)
	SAH	VOI_ATT
SET_DAMATT_1:
;---Language(正逻辑)
	LAC	SYSTMP0
	ANDK	0X0003
	SFL	8
	OR	VOI_ATT
	SAH	VOI_ATT
SET_DAMATT_2:
;---DAM on/off(反逻辑)
	BIT	SYSTMP0,6
	BS	TB,SET_DAMATT_3
	
	LAC	EVENT
	ORL	(1<<9)
	SAH	EVENT
SET_DAMATT_3:
;---DAM OGM select(反逻辑)
	BIT	SYSTMP0,5
	BS	TB,SET_DAMATT_4
	
	LAC	EVENT
	ORL	(1<<8)
	SAH	EVENT
SET_DAMATT_4:
	
	RET	
;-------------------------------------------------------------------------------

.INCLUDE	l_beep/l_beep.asm
.INCLUDE	l_beep/l_bbeep.asm
.INCLUDE	l_beep/l_bbbeep.asm
.INCLUDE	l_beep/l_lbeep.asm
.INCLUDE	l_beep/l_errbeep.asm

;.INCLUDE	l_flashmsg/l_flashfull.asm

.INCLUDE	l_iic/l_getrqueue.asm
.INCLUDE	l_iic/l_storsqueue.asm

.INCLUDE	l_math/l_dgthex.asm
.INCLUDE	l_math/l_hexdgt.asm

.INCLUDE	l_respond/l_vpqueue.asm

.INCLUDE	l_table/l_voltable.asm

;-------------------------------------------------------------------------------
.END
	