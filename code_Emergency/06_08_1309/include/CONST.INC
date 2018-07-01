.NOLIST
;-----------------------------// Constant key defines,全部以C开头。--------------------------------
	CMSG_SER	.EQU	0X80	;received command
	CMSG_ATT	.EQU	0X81	;attribute set_end
	CRMOT_OK	.EQU	0X82	;ENTER REMOTE stat
	CRING_OK	.EQU	0X83	;ENTER ANSWER stat
	CRING_IN	.EQU	0X84
	CRING_FAIL	.EQU	0X85
	CMSG_CPC	.EQU	0X86
	
	CMSG_PLY	.EQU	0X87	;play record MEMO/ICM
	CPLY_NEXT	.EQU	0X88	;play the next VP
	CPLY_PREV	.EQU	0X89	;play the last VP
	CPLY_REPT	.EQU	0X8A	
	CPLY_ERAS	.EQU	0X8B	;delete the playing VP
	CPLY_PAUSE	.EQU	0X8C	;pause play memo/icm

	CPSA_NOMAL	.EQU	0X8D	;normal play speed
	CPSA_UP		.EQU	0X8E	;play speed up 100%
	CPSA_DN		.EQU	0X8F	;play speed down 100%
;-------------------------------------------------------------------------------
	CERAE_ALLVP	.EQU	0X90	;Erase all VP(Memo/Ogm/Icm)
	CSPK_ENABLE	.EQU	0X91	;Speaker on
	CSPK_DISABLE	.EQU	0X92	;Speaker off
	CRDY_CID	.EQU	0X93	;
	CREC_OGM	.EQU	0X94	;Record OGM
	CPLY_OGM	.EQU	0X95	;play OGM



	COLD_ERAS	.EQU	0X9B	;All old message Delete
	CREC_2WAY	.EQU	0X9C	;2WAY record
	CKEY_VOP	.EQU	0X9D	;digit voice prompt DTMF_VAL
	CREC_MEMO	.EQU	0X9E	
	CMSG_EXIT	.EQU	0X9F	;exit the current status
;-------------------------------------------------------------------------------
	CHF_WORK	.EQU	0XA3	;go to speaker phone mode
	CHF_IDLE	.EQU	0XA4	;exist speaker phone mode
	CMUTE_ON	.EQU	0XA5	;mute MIC at SPK mode to microphone
	CMUTE_OFF	.EQU	0XA6	;release mute MIC at MIC mute and release MIC mute
	
	CHS_WORK	.EQU	0XA7	;pickup the handset to off hook in handset mode
	CHS_IDLE	.EQU	0XA8	;put down the handset to on hook for end a call

	CPHONE_VOL	.EQU	0XA9	;Set phone volum
	CMSG_MUTE	.EQU	0XAA	;mute MIC at SPK mode to microphone
	CMSG_UNMUTE	.EQU	0XAB	;release mute MIC at MIC mute and release MIC mute
	
;---外部事件消息完	
;---messages for function	
	CMSG_TVOP	.EQU	0XB0	;play all VOP
	CMSG_INIT	.EQU	0XB1
	CMSG_CTONE	.EQU	0XB2
	CMSG_BTONE	.EQU	0XB3
	CREV_DTMF	.EQU	0XB4	;DTMF end
	CREV_DTMFS	.EQU	0XB5	;DTMF start
	CCAS_TONE	.EQU	0XB6	;Cas-Tone end
	CMSG_VOX	.EQU	0XB7
	CSEG_STOP	.EQU	0XB8
	;CMSG_TMR2	.EQU	0XB9	;
	CMSG_2TMR	.EQU	0XB9	;
	CMSG_TMR	.EQU	0XBA	;MSG OF BASE TIME
	CMSG_VOLA	.EQU	0XBB
	CMSG_VOLS	.EQU	0XBC
	CVP_STOP	.EQU	0XBE	;End of vp
	CREC_FULL	.EQU	0XBF	;FLASH FULL；
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
	CTMODE_IN	.EQU	0XD0	;enter test mode
	CTMODE_OUT	.EQU	0XD1	;exit test mode
	CTMSG_LREC	.EQU	0XD2	;DSP off hook and record from line,open SPK
	CTMSG_MRECL	.EQU	0XD3	;MEMO RECORD -> Delay 2s -> Off-hook play it to line repeatly
	CTMSG_TONEL	.EQU	0XD4	;Off-hook,play beep tone to the line,stop until STOP-TO-STANDBY received
	CTMSG_DTMFD	.EQU	0XD5	;Off-hook,detect DTMF and digit through DTMF dialing
	CTMSG_STOP	.EQU	0XD6	;cancel the current test item
	CTMSG_VOXD	.EQU	0XD7	;VOX detect
	CTMSG_MRECS	.EQU	0XD8	;MEMO RECORD -> Delay 2s -> On-hook play it to SPK repeatly
	CTMSG_TONES	.EQU	0XD9	;On-hook,play beep tone to the SPK,stopuntil STOP-TO-STANDBY received
	CTMSG_LICML	.EQU	0XDA	;Off-hook and record from line 10s -> 2s -> play it to line repeatly,Stop and exit until STOP_TO_STANDBY
	CTMSG_LICMS	.EQU	0XDB	;Off-hook and record from line 10s -> 2s -> play it to SPK repeatly,stop and exit until STOP_TO_STANDBY	
	CTMSG_MEMS	.EQU	0XDC	;Show memory-size though DTMF dialing
	CTMSG_PVOP	.EQU	0XDD	;play all voice prompt to line and SPK
	;CTMSG_FMAT	.EQU	0XDF	;format SPI flash
;----
;-------------------------------------------------------------------------------
CTEL_BASE	.EQU	0X2600	;the address of Mode14 buffer
CBEEP_COMMAND	.EQU	0X48FB	;BEEP START
CBEEP_STOP	.EQU	0X4400	;BEEP STOP
CMODE9		.EQU	0X9040	;disable ALC
;CMODE9		.EQU	0X9240	;enable S/W-ALC
;CTEL_MNUM	.EQU	7	;TEL-block-number
;-------------------------------------------------------------------------------
CTMR2S		.EQU	2048
CTMR1S		.EQU	1024
CTMR500MS	.EQU	512
CTMR400MS	.EQU	409
;-------------------------------------------------------------------------------
COGM1_ID	.EQU	101
COGM2_ID	.EQU	102
;-------------------------------------------------------------------------------
CVOI_ATT	.EQU	0X2C53	;RING_CNT(15..12)/CallScreening(bit11)/CompressRate(bit10)/Language(bit9,8)/SPK_Gain(7..4)/SPK_VOL(3..0)
;-------------------------------------------------------------------------------

PMIC_GAIN	.EQU	0x05	;mic-pre-gain			(speakerphone)
PAD0_GAIN	.EQU	0x03	;AD0-pre-gain(0X5F11)		(speakerphone)
PAD1_GAIN	.EQU	0x07	;AD1-pre-gain(0X5F12)		(speakerphone)
PLIN_VOL	.EQU	0x13	;Lout-VOL-gain(0X5F21)		(speakerphone)
PSPK_VOL	.EQU	0X11	;set SPK volume(0X5F20)		(speakerphone)
;---
PDIAL_VOL	.EQU	0X3	;set SPK volume(0X5F20)		(speakerphone)
;----------------
PGAIN_TONE	.EQU	0X31	;0xC1xx(GainOfTone2/GainOfTone1)(speakerphone)
PREL_ALEC	.EQU	0X00	;0xC4xx(ERL_AEC/ERL_LEC)	(speakerphone)defaul=02
PTR_RATIO	.EQU	0X01	;0xC60x(T/R ratio)		(speakerphone)defaul=02

PLINE_GAIN	.EQU	0X08	;0xC8xy(Line_Gain)		(speakerphone)
PSPK_GAIN	.EQU	0X0A	;0xC8xy(Spk_Gain)		(speakerphone)
PLOOP_ATTE	.EQU	0X05	;0xC90x(Loop-Attenuation)	(speakerphone)defaul=05


CATT_PHONE1	.EQU	(PREL_ALEC<<8)|(PLINE_GAIN<<4)|(PTR_RATIO)
CATT_PHONE2	.EQU	(PLOOP_ATTE<<12)|(PMIC_GAIN<<8)|(PSPK_VOL)
CATT_PHONE3	.EQU	(PAD0_GAIN<<12)|(PAD1_GAIN<<8)|(PLIN_VOL)

;---
;CATT_PHONE1	.EQU	0X0051	;ERL_AEC(15..12)/ERL_LEC(11,8)/LINE_GAIN(7..4)/T/R & R/T ratio(3..0)
;CATT_PHONE2	.EQU	0X5511	;Loop Attenuation(15..12)/CMIC_GAIN(11,8)/reserved(7..5)/CSPK_DRV(4..0)
;CATT_PHONE3	.EQU	0X3713	;AD1PGA(15..12)/AD2PGA(bit11,8)/reserved(7..5)/LINE_DRV(4..0)
;---------------for answer/remote
CVOL_CALLSCREEN	.EQU	4	;Default CallScreen Volume(for answer only)
CLINE_DRV	.EQU	0X10	;for answer/remote LINE_DRV
CAD0_GAIN	.EQU	0X0A	;for answer/remote AD0-GAIN
;---
CRVOX_LEVEL	.EQU	3	;for answer/remote VOX-detect(0xD700)
CRSILENCE_LEVEL	.EQU	7	;for answer/remote silence-level detect(0x7700)

;---------------for local-operation
CLVOX_LEVEL	.EQU	2	;for LOCAL VOX-detect(0xD700)	;!!!!!!!!!!!!!!!!!!!!!!!!!!
CLSILENCE_LEVEL	.EQU	10	;for LOCAL silence-level detect(0x7700) ;!!!!!!!!!!!!!!!!!!!!!!!

CLMIC_GAIN	.EQU	0X03	;for LOCAL-Record(OGM/MEMO) MIC-GAIN	;!!!!!!!!!!!!!!!!!!!!!!!!!!
CLAD1_GAIN	.EQU	0X0B	;for LOCAL-Record(OGM/MEMO) AD1-GAIN 	;!!!!!!!!!!!!!!!!!!!!!!!

;---
CICM_LEN	.EQU	300	;the time length of ICM(seconds)
TMAX_VOPID	.EQU	252
;---
CTMR_CTONE	.EQU	7000
CTMR_CVOX	.EQU	7000
;---
CVOL_FLASH	.EQU	1	;Specific Volume when flash
CVOL_TEST	.EQU	7	;the volum to SPK in test-mode
;-------------------------------------------------------------------------------
CbSPK		.EQU	1	;SPK port(GPAD,1)
CbMUTE_RING	.EQU	2	;MUTE-RING port(GPAD,2)
CbHOOK		.EQU	3	;HOOK port(GPAD,3)
CbBOOST		.EQU	4	;BOOST port(GPAD,4)
;CbMUTE_RING	.EQU	5	;MUTE-RING port(GPAD,5)
CbMUT_HS	.EQU	6	;MUT_HS port(GPAD,6)
CbMSGLED	.EQU	8	;MSG_LED port(GPAD,8)
CbPHOLED	.EQU	9	;PHO_LED port(GPAD,9)
;---------

;CbHFAMP	.EQU	0x10	;HFAMP port(GPAD,3)
;---------------------------------------
CbPin2		.EQU	10	;port(GPAD,10)
CbPin1		.EQU	11	;port(GPAD,11)
;-------------------
CbCPC		.EQU	0	;CPC port(GPBD,0)
CbLIN		.EQU	1	;Line port(GPBD,1)
CbRING_DET	.EQU	2	;RING_DET port(GPBD,2)
CbBLIGHT	.EQU	3	;BLIGHT port(GPBD,3)
CbALC		.EQU	4	;ALC port(GPBD,4)
CbPin3		.EQU	8	;ALC port(GPBD,8)
CbIICREQ	.EQU	9	;ALC port(GPBD,9)
CbMUTE		.EQU	12	;MUTE port(GPBD,12)
;-------------------------------------------------------------------------------
CDTMF_DETP	.EQU	2	;
CDTMF_DETR	.EQU	3	;
;-------------------------------------------------------------------------------
CPC_TLEN	.EQU		80	;for CPC pluse
CPC_DELAY	.EQU   		1000	;HOOK_ON之后与开始CPC检测时间间隔
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;MAXR_LEN	.EQU   		16	;接收缓冲区最多容纳的数据Byte
;MAXS_LEN	.EQU   		16	;发送缓冲区最多容纳的数据Byte

CMASKCODER	.EQU		0X3F
CMASKCODES	.EQU		0X3F
REQ		.EQU   		9

;-------------------------------------------------------------------------------
ADDR_FIRST	.EQU	0X4400
ADDR_SECOND	.EQU	0X5000
ADDR_THIRD	.EQU	0X5C00
;-------------------------------------------------------------------------------
CGROUP_CID	.EQU	0	;CID
;CMAX_MISSCID	.EQU	59	;最大未接来电Miss-CID条目数
CMAX_CID	.EQU	59	;最大未接来电Miss-CID条目数
;---
CGROUP_MCID	.EQU	1	;CID for VP-msg
;---
CGROUP_DIAL	.EQU	2	;Dial-CID
CMAX_DIALCID	.EQU	10	;最大去电DIAL-CID条目数
;---
CGROUP_ANSWCID	.EQU	3	;Answered-CID
CMAX_ANSWCID	.EQU	40	;最大已接来电Answered-CID条目数
;---
CGROUP_PBOOK	.EQU	4	;Phone-book
CMAX_PBOOK	.EQU	99	;最大电话本Phone-book条目数
;---
CMAX_MSGID	.EQU	99	;最大录音条目数(99)
CMIN_LEN	.EQU	3	;最少可录音长度
;---
CGROUP_DATT	.EQU	5	;DAM attribute


CGROUP_M1	.EQU	0x7	;紧急号码M1
CGROUP_M2	.EQU	0x8	;紧急号码M2
CGROUP_M3	.EQU	0x9	;紧急号码M3
;-------------------------------------------------------------------------------
CDAM_ATT	.EQU	(6<<12)|(1<<11)|(4<<4)|(5)		;0X2845
CDAM_ATT0	.EQU	((3<<12)|(1<<8)|(1<<4)|5)		;0x3115
CDAM_ATT1	.EQU	(1<<4)|2				;0x0012
CPASSWORD	.EQU	0X0123
CLOCACODE	.EQU	0XFFFF
;-------------------------------------------------------------------------------
CMDT_NewMessage		.EQU	0X01
CMDT_TotalMessage	.EQU	0X02
CMDT_PhoneBook		.EQU	0X03

CMDT_TotalCall		.EQU	0X05
CMDT_DialedCall		.EQU	0X06
CMDT_NewCall		.EQU	0X07
CMDT_SoftVersion	.EQU	0X0f
CMDT_StartPlay		.EQU	0X10
CMDT_MessageType	.EQU	0X11
CMDT_StartOGM		.EQU	0X12
CMDT_ExitToIdle		.EQU	0X13
CMDT_EnterRemote	.EQU	0X14
CMDT_LineSeize		.EQU	0X15
CMDT_DSPBusy		.EQU	0X16
CMDT_StartAnswer	.EQU	0X17	;Answer and play OGM
CMDT_Memoryfull		.EQU	0X18
CMDT_RingIn		.EQU	0X19
CMDT_TELSendOK		.EQU	0X1A	;0 - income call/1,2,3 - M1,M2,M3/MCU serched
CMDT_Volume		.EQU	0X1B
CMDT_DSPStatus		.EQU	0X1C
CMDT_1LCDDisp		.EQU	0X1D
CMDT_2LCDDisp		.EQU	0X1E
CMDT_DspExitToIdle	.EQU	0X1F
CMDT_MessageWaiting	.EQU	0X20
CMDT_Reset		.EQU	0X3f
CMDT_DateTime		.EQU	0X40
;---

CMDR_PlayMessage	.EQU	0X41
CMDR_PauseMessage	.EQU	0X42
CMDR_SkipMessage	.EQU	0X43
CMDR_PrevMessage	.EQU	0X44
CMDR_PlayMessageHelp	.EQU	0X45
CMDR_MemoRecord		.EQU	0X46
CMDR_2WayRecord		.EQU	0X47
CMDR_AnswerOnOff	.EQU	0X48
CMDR_SelOGM		.EQU	0X49
CMDR_PlayOGM		.EQU	0X4A
CMDR_RecordOGM		.EQU	0X4B
CMDR_DelPlaying		.EQU	0X4C
CMDR_DelAll		.EQU	0X4D
CMDR_PlaySpeed		.EQU	0X4E
CMDR_VolumeAdjust	.EQU	0X4F
CMDR_Speakerphone	.EQU	0X50
CMDR_HandSet		.EQU	0X51
CMDR_NewPhonebook	.EQU	0X52
CMDR_MusicPlay		.EQU	0X53
CMDR_Stop		.EQU	0X54	;(play/record/remote/music)
CMDR_TestCommand	.EQU	0X55
CMDR_FindMissedCall	.EQU	0X56
CMDR_FindAnsweredCall	.EQU	0X57
CMDR_FindDialedCall	.EQU	0X58
CMDR_FindPhoneBook	.EQU	0X59
CMDR_FindName		.EQU	0X5A	;find name by number(phone book,cid package)
CMDR_NewdialedCall	.EQU	0X5B
CMDR_DelNewCall		.EQU	0X5C
CMDR_DelTotalCall	.EQU	0X5D
CMDR_DelDialedCall	.EQU	0X5E
CMDR_DelPhoneBook	.EQU	0X5F
CMDR_GenerateBEEP	.EQU	0X60
CMDR_FlashFormat	.EQU	0X61
CMDR_KeyPress		.EQU	0X63
CMDR_KeyRelease		.EQU	0X64
CMDR_MusicVolume	.EQU	0X65	;(+volume)
CMDR_DelAllCall		.EQU	0X66


CMDR_TestMode		.EQU	0X6B

CMDR_SetPackage		.EQU	0X7f
CMDR_CIDPackage		.EQU	0X80
;-------------------------------------------------------------------------------
EnableWatchDog	.EQU	0	;WatchDog
;-------------------------------------------------------------------------------
DebugPhone	.EQU	1
DebugMuteMic	.EQU	0	;speakerphone use mic-mute or Line-mute(0xC040)

DebugCtoneDet	.EQU	0	;CTONE test only
DebugVoxDet	.EQU	0	;
;-------------------------------------------------------------------------------
.END
