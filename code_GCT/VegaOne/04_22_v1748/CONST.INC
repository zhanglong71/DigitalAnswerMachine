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
	CRMOT_OK	.EQU	0X82	;ENTER REMOTE stat
	CRING_OK	.EQU	0X83	;ENTER ANSWER stat
	CRING_IN	.EQU	0X84
	CRING_FAIL	.EQU	0X85
	
	CPLY_NEXT	.EQU	0X86	;play the next VP
	CPLY_PREV	.EQU	0X87	;play the last VP
	CPLY_ERAS	.EQU	0X88	;delete the playing VP
	CPLY_PAUSE	.EQU	0X89	;pause play memo/icm
	COLD_ERAS	.EQU	0X8A	;All old message Delete
	
	CMSG_EXIT	.EQU	0X8C	;exit the current status

	CMSG_CPC	.EQU	0X8E	
	CPARA_MINE	.EQU	0X8F	;the parallel telephone hook off
;---------------------------------------
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
	CVOP_VOP	.EQU	0X9A	;digit voice prompt DTMF_VAL(VOP only)
	CCID_VOP	.EQU	0X9B	;digit voice prompt CID
;-------	
	CREC_OGM	.EQU	0X9C	;录音0GM
	CPLY_OGM	.EQU	0X9D	;放音0GM

;---外部事件消息完(按键之外的)----------
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
;-------	
	CSEG_END	.EQU	0XAD	;播放等到一段尾
	CVP_STOP	.EQU	0XAE	;End of vp
;-------
	CREC_FULL	.EQU	0XAF	;FLASH FULL；
;-------
	;CMSG_TMODE	.EQU	0XB1
	CTMODE_IN	.EQU	0XB1	;enter test mode
	CTMODE_OUT	.EQU	0XB2	;exit test mode
	CTMODE_LREC	.EQU	0XB3	;DSP off hook and record from line
	CTMODE_TONE	.EQU	0XB4	;DSP off hook and generate 1KH tone to line and SPK
	CTMODE_MEMS	.EQU	0XB5	;DSP count flash memory capability and send to MCU
	CTMODE_PVOP	.EQU	0XB6	;play all voice prompt to line and SPK
	CTMODE_STOP	.EQU	0XB7	;cancel the current test item
	;CTMODE_FMAT	.EQU	0XB8	;format SPI flash
	CTMODE_MPLY	.EQU	0XB9	;play all message
	CTMODE_VOX	.EQU	0XBA	;Vox test
	CTMODE_DTMF	.EQU	0XBB	;DTMF test
	CTMODE_MEMR	.EQU	0XBC	;Memory test
	CTMODE_DFAT	.EQU	0XBD	;Factory  test	
;-------
	CMSG_PLY	.EQU	0XC0	;play VP(new VP or all VP)
	CMSG_PNEW	.EQU	0XC1	;play new VP
	CMSG_PALL	.EQU	0XC2	;play all VP
	CMSG_PCTU	.EQU	0XC3	;continue current play(from pause status)

;-------------------------------------------------------------------------------
CBEEP_COMMAND	.EQU	0X48F9	;BEEP CON
;CMODE9		.EQU	0X9040	;disable ALC
CMODE9		.EQU	0X9240	;enable S/W-ALC
;CMODE9		.EQU	0X9250	;enable S/W-ALC;VOX-on
COGM1_ID	.EQU	101
COGM2_ID	.EQU	102
CPSC		.EQU	9	;the max count of DTMF input when answering
;-------------------------------------------------------------------------------
CROUT_DRV	.EQU	0X1A	;for answer/remoteplay line-out DRV	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!
CRAD1_GAIN	.EQU	0X08	;for answer/remote AD1-PGA	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;---
CRVOX_LEVEL	.EQU	26	;for answer/remote VOX-detect(0xD700)
CRSILENCE_LEVEL	.EQU	8	;for answer/remote silence-level detect(0x7700)
;---------------------------------------
;CLMIC_GAIN	.EQU	0X05	;for LOCAL-Record(OGM/MEMO) MIC-GAIN 	;nouse
CLAD1_GAIN	.EQU	0X04	;for LOCAL-Record(OGM/MEMO) AD1-GAIN	;!!!!!!!!!!!!!!!!!!!!!!!!!!!
CLOUT_DRV	.EQU	0X19	;for local line-out DRV	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;---
CLVOX_LEVEL	.EQU	40	;for local VOX-detect(0xD700)
CLSILENCE_LEVEL	.EQU	9	;for local silence-level detect(0x7700)
;---
CALCGAIN	.EQU	6	;(0x5F40)-22
CALCMAL		.EQU	18000	;(0x5F41)-18000
;-------------------------------------------------------------------------------
CICM_LEN	.EQU	180+5	;the time length of ICM(seconds)注意误差5
CMEM_LEN	.EQU	180+5	;the time length of MEMO(seconds)注意误差5
COGM_LEN	.EQU	120+3	;the time length of OGM(seconds)注意误差3
TMAX_VOPID	.EQU	60
;---
CTMR_CTONE	.EQU	7000
CTMR_CVOX	.EQU	7000
;-------------------------------------------------------------------------------
CbHOOK		.EQU	0	;HOOK port(GPAD,0)
CbSPK		.EQU	1	;SPK port(GPAD,1)
CbCIDMUTE	.EQU	2	;SPK port(GPAD,2)
CbHFAMP		.EQU	3	;SPK port(GPAD,3)
CbMSGLED	.EQU	8	;MSG_LED port(GPAD,8)
CbPHOLED	.EQU	9	;PHO_LED port(GPAD,9)
;-------------------------------------------------------------------------------
CMEMFUL		.EQU	20	;the MAX.time length of memory-full
ADDR_FIRST	.EQU	0X4400
ADDR_SECOND	.EQU	0x5900
;-------------------------------------------------------------------------------
DebugSpkOn	.EQU	0	;SPK on at local-play
DebugDisCTone	.EQU	0	;Disable CTone detect
;-------------------------------------------------------------------------------
.END
