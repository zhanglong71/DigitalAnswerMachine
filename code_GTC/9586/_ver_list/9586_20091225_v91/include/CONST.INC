.NOLIST
;-----------------------------// Constant key defines,全部以C开头。--------------------------------
;---SYS MSG CONST------------------
	CMSG_KEY1S	.EQU	0X01	;messages for key released(松开按键UP)
	CMSG_KEY2S	.EQU	0X02
	CMSG_KEY3S	.EQU	0X03
	CMSG_KEY4S	.EQU	0X04
	CMSG_KEY5S	.EQU	0X05
	CMSG_KEY6S	.EQU	0X06
	CMSG_KEY7S	.EQU	0X07
	CMSG_KEY8S	.EQU	0X08
	CMSG_KEY9S	.EQU	0X09
	CMSG_KEYAS	.EQU	0X0A
	CMSG_KEYBS	.EQU	0X0B
	CMSG_KEYCS	.EQU	0X0C
	CMSG_KEYDS	.EQU	0X0D
	CMSG_KEYES	.EQU	0X0E
	CMSG_KEYFS	.EQU	0X0F
	CMSG_KEYGS	.EQU	0X10
;---	
	CMSG_KEY1L	.EQU	0X11	;messages for key beening pressed 2s
	CMSG_KEY2L	.EQU	0X12
	CMSG_KEY3L	.EQU	0X13
	CMSG_KEY4L	.EQU	0X14
	CMSG_KEY5L	.EQU	0X15
	CMSG_KEY6L	.EQU	0X16
	CMSG_KEY7L	.EQU	0X17
	CMSG_KEY8L	.EQU	0X18
	CMSG_KEY9L	.EQU	0X19
	CMSG_KEYAL	.EQU	0X1A
	CMSG_KEYBL	.EQU	0X1B
	CMSG_KEYCL	.EQU	0X1C
	CMSG_KEYDL	.EQU	0X1D
	CMSG_KEYEL	.EQU	0X1E
	CMSG_KEYFL	.EQU	0X1F
	CMSG_KEYGL	.EQU	0X20
;---	
	CMSG_KEY1P	.EQU	0X21	;messages for key beening pressed every 512ms
	CMSG_KEY2P	.EQU	0X22
	CMSG_KEY3P	.EQU	0X23
	CMSG_KEY4P	.EQU	0X24
	CMSG_KEY5P	.EQU	0X25
	CMSG_KEY6P	.EQU	0X26
	CMSG_KEY7P	.EQU	0X27
	CMSG_KEY8P	.EQU	0X28
	CMSG_KEY9P	.EQU	0X29
	CMSG_KEYAP	.EQU	0X2A
	CMSG_KEYBP	.EQU	0X2B
	CMSG_KEYCP	.EQU	0X2C
	CMSG_KEYDP	.EQU	0X2D
	CMSG_KEYEP	.EQU	0X2E
	CMSG_KEYFP	.EQU	0X2F
	CMSG_KEYGP	.EQU	0X30
	
	CMSG_KEY1D	.EQU	0X31	;messages for key beening pressed DOWN(48ms later)
	CMSG_KEY2D	.EQU	0X32
	CMSG_KEY3D	.EQU	0X33
	CMSG_KEY4D	.EQU	0X34
	CMSG_KEY5D	.EQU	0X35
	CMSG_KEY6D	.EQU	0X36
	CMSG_KEY7D	.EQU	0X37
	CMSG_KEY8D	.EQU	0X38
	CMSG_KEY9D	.EQU	0X39
	CMSG_KEYAD	.EQU	0X3A
	CMSG_KEYBD	.EQU	0X3B
	CMSG_KEYCD	.EQU	0X3C
	CMSG_KEYDD	.EQU	0X3D
	CMSG_KEYED	.EQU	0X3E
	CMSG_KEYFD	.EQU	0X3F
	CMSG_KEYGD	.EQU	0X40
;-------
	CMSG_SER	.EQU	0X80	;received command
	
	CMSG_ATT	.EQU	0X81	;attribute set_end
	
	CRMOT_OK	.EQU	0X82	;ENTER REMOTE stat
	CRING_OK	.EQU	0X83	;ENTER ANSWER stat
	CRING_IN	.EQU	0X84
	CRING_FAIL	.EQU	0X85
	
	CMSG_PLY	.EQU	0X86	;play record MEMO/ICM
	CPLY_NEXT	.EQU	0X87	;play the next VP
	CPLY_PREV	.EQU	0X88	;play the last VP
	CPLY_ERAS	.EQU	0X89	;delete the playing VP
	CPLY_PAUSE	.EQU	0X8A	;pause play memo/icm
	COLD_ERAS	.EQU	0X8B	;All old message Delete
	CREC_2WAY	.EQU	0X8C	;2WAY record
	CMSG_EXIT	.EQU	0X8D	;exit the current status
	
	CMSG_CPC	.EQU	0X8E
	CREC_MEMO	.EQU	0X8F	

;-------
	CPSA_NOMAL	.EQU	0X90	;normal play speed
	CPSA_UP		.EQU	0X91	;play speed up 100%
	CPSA_DN		.EQU	0X92	;play speed down 100%

	CPHONE_ON	.EQU	0X93	;go to speaker phone mode
	CPHONE_OFF	.EQU	0X94	;exist speaker phone mode and go to idle mode

	CMUTE_ON	.EQU	0X95	;mute MIC at SPK mode to microphone
	CMUTE_OFF	.EQU	0X96	;release mute MIC at MIC mute and release MIC mute

	CHOOK_OFF	.EQU	0X97	;pickup the handset to off hook in handset mode
	CHOOK_ON	.EQU	0X98	;put down the handset to on hook for end a call
	
	CKEY_VOP	.EQU	0X99	;digit voice prompt DTMF_VAL
	CCID_VOP	.EQU	0X9A	;digit voice prompt CID
	
	CPHONE_VOL	.EQU	0X9B	;Set phone volum
;---------------------------------------
	CMSG_RION	.EQU	0X9C	;ring on
	CMSG_RIOFF	.EQU	0X9D	;ring off
	
	CMSG_MUTE	.EQU	0X9E	;mute MIC at SPK mode to microphone
	CMSG_UNMUTE	.EQU	0X9F	;release mute MIC at MIC mute and release MIC mute
;---外部事件消息完(按键之外的)	
;---messages for function	
	CMSG_TVOP	.EQU	0XA0	;play all VOP
	CMSG_INIT	.EQU	0XA1
	CMSG_CTONE	.EQU	0XA2
	CMSG_BTONE	.EQU	0XA3
	CREV_DTMF	.EQU	0XA4	;DTMF end
	CREV_DTMFS	.EQU	0XA5	;DTMF start
	CCAS_TONE	.EQU	0XA6	;Cas-Tone end
	CMSG_VOX	.EQU	0XA7

	CSEG_STOP	.EQU	0XA8
	CMSG_TMR2	.EQU	0XA9	;MSG OF BASE TIME
	CMSG_TMR	.EQU	0XAA	;MSG OF BASE TIME
	CMSG_VOLA	.EQU	0XAB
	CMSG_VOLS	.EQU	0XAC
;---	
	CSEG_END	.EQU	0XAD	;播放等到一段尾
	CVP_STOP	.EQU	0XAE	;End of vp
;---
	CREC_FULL	.EQU	0XAF	;FLASH FULL；
;-------------------------------------------------------------------------------

	CTMODE_IN	.EQU	0XB0	;enter test mode
	CTMODE_OUT	.EQU	0XB1	;exit test mode
	CTMSG_LREC	.EQU	0XB2	;DSP off hook and record from line,open SPK
	CTMSG_MRECL	.EQU	0XB3	;MEMO RECORD -> Delay 2s -> Off-hook play it to line repeatly
	CTMSG_TONEL	.EQU	0XB4	;Off-hook,play beep tone to the line,stop until STOP-TO-STANDBY received
	CTMSG_DTMFD	.EQU	0XB5	;Off-hook,detect DTMF and digit through DTMF dialing
	CTMSG_STOP	.EQU	0XB6	;cancel the current test item
	CTMSG_VOXD	.EQU	0XB7	;VOX detect
	CTMSG_MRECS	.EQU	0XB8	;MEMO RECORD -> Delay 2s -> On-hook play it to SPK repeatly
	CTMSG_TONES	.EQU	0XB9	;On-hook,play beep tone to the SPK,stopuntil STOP-TO-STANDBY received
;	CTMSG_OGMR	.EQU	0XBA	;On-hook and record from MIC,Stop and exit until STOP_TO_STANDBY
;	CTMSG_OGML	.EQU	0XBB	;Off-hook Play OGM to line repeatly,stop and exit until STOP_TO_STANDBY
	CTMSG_MEMS	.EQU	0XBC	;Show memory-size though DTMF dialing

	CTMSG_PVOP	.EQU	0XBD	;play all voice prompt to line and SPK
	;CTMSG_FMAT	.EQU	0XBF	;format SPI flash
;----
	CTMSG_LICML	.EQU	0XC0	;Off-hook and record from line 10s -> 2s -> play it to line repeatly,Stop and exit until STOP_TO_STANDBY
	CTMSG_LICMS	.EQU	0XC1	;Off-hook and record from line 10s -> 2s -> play it to SPK repeatly,stop and exit until STOP_TO_STANDBY
;-------------------------------------------------------------------------------
	CERAE_ALLVP	.EQU	0XD0	;Erase all VP(Memo/Ogm/Icm)
;-------------------------------------------------------------------------------
	CSPK_ENABLE	.EQU	0XD1	;Speaker on
	CSPK_DISABLE	.EQU	0XD2	;Speaker off
;-------------------------------------------------------------------------------
	CPLY_HELP	.EQU	0XD3	;play help message
	CREC_HELP	.EQU	0XD4	;Record help message
	CHMOD_OK	.EQU	0XD5	;Goto help mode(play help message 3 times)
;-------------------------------------------------------------------------------
CBEEP_COMMAND	.EQU	0X48FB	;BEEP START
CBEEP_STOP	.EQU	0X4400	;BEEP STOP
CMODE9		.EQU	0X9040	;disable ALC
;CMODE9		.EQU	0X9240	;enable S/W-ALC
COGM1_ID	.EQU	101
COGM2_ID	.EQU	102
;-------------------------------------------------------------------------------
;CVersion	.EQU	0x79	;2008-10-20 10:35
;-------------------------------------------------------------------------------
CVOI_ATT	.EQU	0X2C55	;RING_CNT(15..12)/CallScreening(bit11)/CompressRate(bit10)/Language(bit9,8)/SPK_Gain(7..4)/SPK_VOL(3..0)
;-------------------------------------------------------------------------------

;---
CATT_PHONE1	.EQU	0X0051	;ERL_AEC(15..12)/ERL_LEC(11,8)/LINE_GAIN(7..4)/T/R & R/T ratio(3..0)
CATT_PHONE2	.EQU	0X5511	;Loop Attenuation(15..12)/CMIC_GAIN(11,8)/reserved(7..5)/CSPK_DRV(4..0)
CATT_PHONE3	.EQU	0X3713	;AD1PGA(15..12)/AD2PGA(bit11,8)/reserved(7..5)/LINE_DRV(4..0)
;---------------for answer/remote
CVOL_CALLSCREEN	.EQU	4	;Default CallScreen Volume(for answer only)
CLINE_DRV	.EQU	0X10	;for answer/remote LINE_DRV
CADCML_PGA	.EQU	0X0A	;for answer/remote AD-PGA
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
CbHOOK		.EQU	0	;HOOK port(GPAD,0)
CbSPK		.EQU	1	;SPK port(GPAD,1)
CbCIDMUTE	.EQU	2	;CIDMUTE port(GPAD,2)
CbHFAMP		.EQU	3	;HFAMP port(GPAD,3)
CbMSGLED	.EQU	8	;MSG_LED port(GPAD,8)
CbPHOLED	.EQU	9	;PHO_LED port(GPAD,9)
;-------------
CbCPC		.EQU	0	;CPC port(GPBD,0)
CbLIN		.EQU	1	;Line port(GPBD,1)
CbPower		.EQU	3	;Power port(GPBD,3)
CbALC		.EQU	4	;ALC port(GPBD,4)
CbMUTE		.EQU	12	;MUTE port(GPBD,12)
;-------------------------------------------------------------------------------
CDTMF_DETP	.EQU	2	;
CDTMF_DETR	.EQU	3	;
;-------------------------------------------------------------------------------
CPC_TLEN	.EQU		80		;for CPC pluse
OSI_TLEN	.EQU		700-CPC_TLEN	;for OSI pluse	2009-6-2 17:46
CPC_DELAY	.EQU   		1000		;HOOK_ON之后与开始CPC检测时间间隔
;-------------------------------------------------------------------------------
HLP_DELAY	.EQU   		5		;Line seize之后与开始play help message时间间隔
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
EnableWatchDog	.EQU	1	;WatchDog (Set 1 in normal)
;-------------------------------------------------------------------------------
DebugPhone	.EQU	1
DebugMuteMic	.EQU	0	;speakerphone use mic-mute or Line-mute(0xC040)

DebugCtoneDet	.EQU	0	;CTONE test only
DebugVoxDet	.EQU	0	;
;-------------------------------------------------------------------------------
.END
