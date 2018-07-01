.NOLIST
;-----------------------------// Constant key defines,全部以C开头。--------------------------------
;---SYS MSG CONST------------------
;	CMSG_KEY1S	.EQU	0X01	;messages for key released(松开按键UP)
;	CMSG_KEY2S	.EQU	0X02
;	CMSG_KEY3S	.EQU	0X03
;	CMSG_KEY4S	.EQU	0X04
;	CMSG_KEY5S	.EQU	0X05
;	CMSG_KEY6S	.EQU	0X06
;	CMSG_KEY7S	.EQU	0X07
;	CMSG_KEY8S	.EQU	0X08
;	CMSG_KEY9S	.EQU	0X09
;	CMSG_KEYAS	.EQU	0X0A
;	CMSG_KEYBS	.EQU	0X0B
;	CMSG_KEYCS	.EQU	0X0C
;	CMSG_KEYDS	.EQU	0X0D
;	CMSG_KEYES	.EQU	0X0E
;	CMSG_KEYFS	.EQU	0X0F
;	CMSG_KEYGS	.EQU	0X10
;---	
;	CMSG_KEY1L	.EQU	0X11	;messages for key beening pressed 2s
;	CMSG_KEY2L	.EQU	0X12
;	CMSG_KEY3L	.EQU	0X13
;	CMSG_KEY4L	.EQU	0X14
;	CMSG_KEY5L	.EQU	0X15
;	CMSG_KEY6L	.EQU	0X16
;	CMSG_KEY7L	.EQU	0X17
;	CMSG_KEY8L	.EQU	0X18
;	CMSG_KEY9L	.EQU	0X19
;	CMSG_KEYAL	.EQU	0X1A
;	CMSG_KEYBL	.EQU	0X1B
;	CMSG_KEYCL	.EQU	0X1C
;	CMSG_KEYDL	.EQU	0X1D
;	CMSG_KEYEL	.EQU	0X1E
;	CMSG_KEYFL	.EQU	0X1F
;	CMSG_KEYGL	.EQU	0X20

;	CMSG_KEY1D	.EQU	0X21	;messages for key beening pressed DOWN(48ms later)
;	CMSG_KEY2D	.EQU	0X22
;	CMSG_KEY3D	.EQU	0X23
;	CMSG_KEY4D	.EQU	0X24
;	CMSG_KEY5D	.EQU	0X25
;	CMSG_KEY6D	.EQU	0X26
;	CMSG_KEY7D	.EQU	0X27
;	CMSG_KEY8D	.EQU	0X28
;	CMSG_KEY9D	.EQU	0X29
;	CMSG_KEYAD	.EQU	0X2A
;	CMSG_KEYBD	.EQU	0X2B
;	CMSG_KEYCD	.EQU	0X2C
;	CMSG_KEYDD	.EQU	0X2D
;	CMSG_KEYED	.EQU	0X2E
;	CMSG_KEYFD	.EQU	0X2F
;	CMSG_KEYGD	.EQU	0X30
;-------------------------------------------------------------------------------
	CMSG_SER	.EQU	0X80	;received command
;---
	CREC_MEMO	.EQU	0X81	;record MEMO
	CRMOT_OK	.EQU	0X82	;ENTER REMOTE stat
	CRING_OK	.EQU	0X83	;ENTER ANSWER stat
	CRING_IN	.EQU	0X84
	CRING_FAIL	.EQU	0X85
;---
	CMSG_PLY	.EQU	0X86	;play record MEMO/ICM
	CPLY_NEXT	.EQU	0X87	;play the next VP
	CPLY_PREV	.EQU	0X88	;play the last VP
	CPLY_ERAS	.EQU	0X89	;delete the playing VP
	CPLY_PAUSE	.EQU	0X8A	;pause play memo/icm
	COLD_ERAS	.EQU	0X8B	;All old message Delete	
	CMSG_STOP	.EQU	0X8C	;STOP the current status
;---
	CPARA_MINE	.EQU	0X8D	;the parallel telephone hook off
	CMSG_CPC	.EQU	0X8E	
	CMSG_FMAT	.EQU	0X8F	;format flash
;-------------------------------------------------------------------------------
	CMSG_PSA	.EQU	0X90	;play speed
	
	CPLY_OGM	.EQU	0X91	;play speed up 100%
	CREC_OGM	.EQU	0X92	;play speed down 100%

	CPHONE_ON	.EQU	0X93	;go to speaker phone mode
	CPHONE_OFF	.EQU	0X94	;exist speaker phone mode and go to idle mode

	CMUTE_ON	.EQU	0X95	;mute MIC at SPK mode to microphone
	CMUTE_OFF	.EQU	0X96	;release mute MIC at MIC mute and release MIC mute

	CHOOK_OFF	.EQU	0X97	;pickup the handset to off hook in handset mode
	CHOOK_ON	.EQU	0X98	;put down the handset to on hook for end a call
	
	CMIDI_VOP	.EQU	0X99	;midi play
	CMIDI_VOL	.EQU	0X9A	;midi VOL
	CVOP_VOP	.EQU	0X9B	;digit voice prompt DTMF_VAL
	CCID_VOP	.EQU	0X9C	;digit voice prompt CID
	CREC_2WAY	.EQU	0X9D

	CFSK_CID	.EQU	0X9E	;vaild FSK-CID ready
	CDTMF_CID	.EQU	0X9F	;vaild DTMF-CID ready
;---外部事件消息完(按键之外的)	
;---messages for function	
	CMSG_TVOP	.EQU	0XA0	;play all VOP
	CMSG_INIT	.EQU	0XA1
	CMSG_CTONE	.EQU	0XA2
	CMSG_BTONE	.EQU	0XA3
	CREV_DTMF	.EQU	0XA4	;DTMF end
	CREV_DTMFS	.EQU	0XA5	;DTMF start
	CMSG_VOX	.EQU	0XA6
;---
	CVOL_INC	.EQU	0XA7	;VOL increase
	CVOL_DEC	.EQU	0XA8	;VOL decrease
;---	
	CMSG_TMR0	.EQU	0XA9	;MSG .. TIME
	CMSG_TMR	.EQU	0XAA	;MSG OF BASE TIME
	CMSG_VOLA	.EQU	0XAB	;
	CMSG_VOLS	.EQU	0XAC
;---	
	CSEG_END	.EQU	0XAD	;播放等到一段尾
	CVP_STOP	.EQU	0XAE	;End of vp
;---
	CREC_FULL	.EQU	0XAF	;Record FLASH full
;-------------------------------------------------------------------------------
;---CFIND_CID
	CFIND_MISSCID	.EQU	0XB1	;find missed cid
	CFIND_ANSWCID	.EQU	0XB2	;find answered cid
	CFIND_DTEL	.EQU	0XB3	;find dialed tel-num
	CFIND_PBOOK	.EQU	0XB4	;find phonebook
;---CDEL_CID
	CDEL_MISSCID	.EQU	0XB6	;del cid
	CDEL_ANSWCID	.EQU	0XB7	;del cid
	CDEL_DTEL	.EQU	0XB8	;del dialed tel-num
	CDEL_PBOOK	.EQU	0XB9	;del phonebook

	CFIND_NUM	.EQU	0XBA	;find TEL with specific num
	CSAVE_PBOOK	.EQU	0XBB	;Save the tel-num into phonebook
	CSAVE_DTEL	.EQU	0XBC	;Save the tel-num into dialed tel-num

	CMSG_BEEP	.EQU	0XBD	;Generate BEEP
	CMSG_BBEEP	.EQU	0XBE	;Generate BBEEP
	CMSG_LBEEP	.EQU	0XBF	;Generate LBEEP
;-------------------------------------------------------------------------------
	CMSG_MUTE	.EQU	0XC0	;mute MIC at SPK mode to microphone
	CMSG_UNMUTE	.EQU	0XC1	;release mute MIC at MIC mute and release MIC mute
;-------------------------------------------------------------------------------
	CDAM_UPDATE	.EQU	0XD0	;Update the dam attribute(The data in flash)
;-------------------------------------------------------------------------------
	CTMODE_IN	.EQU	0XD1	;enter test mode
	CTMODE_OUT	.EQU	0XD2	;exit test mode
	CTMODE_LREC	.EQU	0XD3	;DSP off hook and record from line
	CTMODE_TONE	.EQU	0XD4	;DSP off hook and generate 1KH tone to line and SPK
	CTMODE_MEMS	.EQU	0XD5	;DSP count flash memory capability and send to MCU
	CTMODE_PBEEP	.EQU	0XD6	;play all voice prompt to line and SPK
	CTMODE_PVOP	.EQU	0XD7	;play all voice prompt to line and SPK
	CTMODE_STOP	.EQU	0XD8	;cancel the current test item
	CTMODE_FMAT	.EQU	0XD9	;format SPI flash
	CTMODE_MPLY	.EQU	0XDA	;play all message
	CTMODE_VOX	.EQU	0XDB	;Vox test
	CTMODE_DTMF	.EQU	0XDC	;DTMF test
	CTMODE_MEMR	.EQU	0XDD	;Memory test
	CTMODE_DFAT	.EQU	0XDE	;Factory  test	
	CTMODE_RESVED	.EQU	0XDF	;reserved command	
;-------------------------------------------------------------------------------
CBEEP_COMMAND	.EQU	0X48F9	;BEEP CON
CMODE9		.EQU	0X9040	;disable ALC
;CMODE9		.EQU	0X9240	;enable S/W-ALC
COGM1_ID	.EQU	101
COGM2_ID	.EQU	102
;-------------------------------------------------------------------------------
CMIC_GAIN	.EQU	0x07	;mic-pre-gain(speakerphone)
CSPK_GAIN	.EQU	0X12	;set SPK volume(speakerphone)
;---
CICM_LEN	.EQU	120	;the time length of ICM(seconds)
TMAX_VOPID	.EQU	60
;---
CTEL_MNUM	.EQU	32	;Declare TEL-Message Number in FLASH

CVersion	.EQU	0x02	;???(BCD code)2008-3-18 9:55
;-----------------------------------------------------------
CGROUP_MISSCID	.EQU	0	;Miss-CID
CMAX_MISSCID	.EQU	60	;最大未接来电Miss-CID条目数
;---
CGROUP_MCID	.EQU	1	;CID for VP-msg
;---
CGROUP_DIAL	.EQU	2	;Dial-CID
CMAX_DIALCID	.EQU	10	;最大去电DIAL-CID条目数
;---
CGROUP_ANSWCID	.EQU	3	;Answered-CID
CMAX_ANSWCID	.EQU	60	;最大已接来电Answered-CID条目数
;---
CGROUP_PBOOK	.EQU	4	;Phone-book
CMAX_PBOOK	.EQU	60	;最大电话本Phone-book条目数
;---
CGROUP_DATT	.EQU	5	;DAM attribute

CGROUP_M1	.EQU	0x7	;紧急号码M1
CGROUP_M2	.EQU	0x8	;紧急号码M2
CGROUP_M3	.EQU	0x9	;紧急号码M3
;----------------
CDAM_ATT	.EQU	(6<<12)|(1<<11)|(4<<4)|(5)		;0X2845
CDAM_ATT0	.EQU	((3<<12)|(1<<8)|(1<<4)|5)		;0x3115
CDAM_ATT1	.EQU	(1<<4)|2				;0x0012
CPASSWORD	.EQU	0X0123
CLOCACODE	.EQU	0XFFFF
;----------------
;---
CTMR_CTONE	.EQU	7000
CTMR_CVOX	.EQU	7000
;-------------------------------------------------------------------------------
;CbHOOK		.EQU	0	;HOOK port(GPAD,0)
;CbSPK		.EQU	1	;SPK port(GPAD,1)
;CbCIDMUTE	.EQU	2	;SPK port(GPAD,2)
;CbHFAMP	.EQU	3	;SPK port(GPAD,3) 
CbMSGLED	.EQU	8	;MSG_LED port(GPAD,8)
CbPHOLED	.EQU	9	;PHO_LED port(GPAD,9)
;---------------
CbMIDID		.EQU	4	;MIDI data port(GPBD,4)
;---------------
CFLAG		.EQU	0x80	;for CID new flag 
;-------------------------------------------------------------------------------
;SER_FG	(change only in interrupt)
CbRx		.EQU   	4	;bit4 = receive
CbTx		.EQU   	5	;bit5 = send

CbBUSY		.EQU   	6	;bi6 = IIC busy can`t receive command
CbLINE		.EQU   	8	;bi8 = ring or Torev on line
;-------------------------------------------------------------------------------
CbPAUSE		.EQU	8	;Mode 0x2000/0xB000
;-------------------------------------------------------------------------------
ADDR_FIRST	.EQU	0X4800
ADDR_SECOND	.EQU	0X5B00
;-------------------------------------------------------------------------------
.END
