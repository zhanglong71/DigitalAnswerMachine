.LIST
;---------------------------
SYS_MSG:
	LAC	MSG
	XORL	CSEG_END		;SEG_END
	BS	ACZ,SYS_SEG_END
;SYS_MSG0:
	;LAC	MSG
	;XORL	CSEG_STOP		;SEG_STOP
	;BS	ACZ,SYS_SEG_STOP
;---------------------------------------传递消息区
;SYS_MSG2:
;SYS_MSG3:
	LAC	MSG
	XORL	CMSG_VOLA
	BS	ACZ,SYS_VOL_ADD		;VOL+
;SYS_MSG4:	
	LAC	MSG
	XORL	CMSG_VOLS
	BS	ACZ,SYS_VOL_SUB		;VOL-
;SYS_MSG5:
	LAC	MSG
	XORL	CRING_OK
	BS	ACZ,SYS_MSG_RUN_ANS
;SYS_MSG6:
	LAC	MSG
	XORL	CRMOT_OK
	BS	ACZ,SYS_MSG_RUN_RMT
;SYS_MSG7:
	LAC	MSG
	XORL	CMSG_TMR0	;receiving CID time over
	BS	ACZ,SYS_CID_TMR
;SYS_MSG8:	
	LAC	MSG
	XORL	CMSG_SER
	BS	ACZ,SYS_SER_RUN
;============================================================功能区
SYS_MSG_NO:
	LACK	1
	
	RET				;NO

SYS_MSG_YES:				;ACK
	LACK	0
	RET

;---------------
SYS_SEG_END:
	CALL	GET_VP
	BS	ACZ,SYS_SEG_END0
	CALL	INT_BIOS_START
	BS	B1,SYS_MSG_YES
SYS_SEG_END0:
	CALL	INIT_DAM_FUNC
	LACL	CVP_STOP		;通知系统播放完毕
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
;---
SYS_SEG_STOP:

	BS	B1,SYS_SEG_END0	
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
SYS_VOL_ADD:
	LAC	CODECREG2
	ANDL	0XFFE0
	SAH	CODECREG2
	
        LAC	DAM_ATT
        ANDL	0X07
        SBHK	7		;上限
        BS	ACZ,SYS_VOL_ADD1
        LAC	DAM_ATT
        ADHK	1
        SAH	DAM_ATT
SYS_VOL_ADD1:
SYS_VOL_SET:
	
	LACK	0X1B
	CALL	SEND_DAT
	LAC	DAM_ATT
	ANDL	0X07
	CALL	SEND_DAT	;tell MCU volume
;---
	LAC	DAM_ATT
	ANDL	0X07
	ADHL	VOL_TAB
	CALL    GetOneConst
        OR	CODECREG2
        SAH	CODECREG2
	
	call    SetCodecReg
	BS	B1,SYS_MSG_YES
SYS_VOL_SUB:
	LAC	CODECREG2
	ANDL	0XFFE0
	SAH	CODECREG2
	
	LAC	DAM_ATT
        ANDL	0X07
        SBHK	0		;下限
        BS	ACZ,SYS_VOL_SUB1
        BS	SGN,SYS_VOL_SUB1
        LAC	DAM_ATT
	SBHK	1
        SAH	DAM_ATT
SYS_VOL_SUB1:
	BS	B1,SYS_VOL_SET

SYS_CID_TMR:
	;LACL	0X5001
	;CALL	DAM_BIOSFUNC
	
	CALL	CLR_TIMER0
	
	LAC	CID_FG
	ANDL	0XFFF0
	SAH	CID_FG

	BS	B1,SYS_MSG_YES
SYS_MSG_RUN_ANS:
	;BS	B1,SYS_MSG_YES	;???????????????????????????????????????????????
	CALL	INIT_DAM_FUNC
	CALL	MIDI_STOP
	CALL	DAA_OFF

	CALL	HOOK_OFF	;摘机
	CALL	SET_COMPS
	LACL	CMODE9|(1<<9)|(1<<3)	;demand ALC-on(bit9) and LINE-on(bit3)
	CALL	DAM_BIOSFUNC
;-------
	LACL	FlashLoc_H_f_answer
	ADLL	FlashLoc_L_f_answer
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_answer
	ADLL	CodeSize_f_answer
	CALL	LoadHostCode
;-------
	LACL	CMSG_INIT
	CALL	STOR_MSG

	LACK	0
	SAH	PRO_VAR
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER

	CALL	CLR_FUNC	;先空
	LACL	ANS_STATE	;答录状态
	CALL	PUSH_FUNC

  	BS	B1,SYS_MSG_YES
SYS_MSG_RUN_RMT:
	;LACL	0XC7AB	;"Ln"
	;SAH	LED_L
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_REC

	CALL	CLR_FUNC	;先空
	LACL	REMOTE_PRO	;进入遥控
	CALL	PUSH_FUNC

	LACL	CMSG_INIT
	CALL	STOR_MSG
;-------
	LACL	FlashLoc_H_f_remote
	ADLL	FlashLoc_L_f_remote
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_remote
	ADLL	CodeSize_f_remote
	CALL	LoadHostCode
;-------
	LACK	0
	SAH	PRO_VAR		;程序步骤
	SAH	PRO_VAR1	;计时清零
	SAH	PSWORD_TMP	;功能字符清零
	CALL	BCVOX_INIT

	BS	B1,SYS_MSG_YES
;-------检查收到的命令----------------------------------------------------------
SYS_SER_RUN:
	CALL	CLR_BUSY_FG	;

	;CALL	CLR_BUSY_FG	;!!!!!!!!!!!!!一种妥协做法。因为提手柄后会发生IIC-REQ一直不能回到High的状态，原因不明
		
	CALL	GETR_DAT
	ANDL	0XFF
	SAH	MSG
;---------------------------------------	
	LAC	MSG
	SBHK	0X40
	BS	SGN,SYS_MSG_YES		;less 0x40
	SBHK	0X10
	BS	SGN,SYS_SER_RUN_0X4050	;0x40<= x <0X50
	SBHK	0X10
	BS	SGN,SYS_SER_RUN_0X5060	;0x50<= x <0X60
	SBHK	0X10
	BS	SGN,SYS_SER_RUN_0X6070	;0x60<= x <0x70
	SBHK	0X10
	BS	SGN,SYS_SER_RUN_0X7080	;0x70<= x <0x80
	SBHK	0X10
	BS	SGN,SYS_SER_RUN_0X8090	;0x80<= x <0x90
	
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X4050:
	LAC	MSG
	SBHK	0X40
	BS	ACZ,SYS_SER_RUN_0X40
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X41	;play message
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X42	;pause message
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X43	;skip message
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X44	;repeat/previous message
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X45	;play memo help
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X46	;record memo
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X47	;play record memo
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X48	;ANS on/off(0/1 = on/off)
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X49	;ogm select
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X4A	;play ogm
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X4B	;record ogm
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X4C	;erase current playing message
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X4D	;all message erase
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X4E	;slow/fast play speed(0-normal)
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X4F	;slow/fast play speed(0-normal)
	
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X5060:
;-------
	LAC	MSG
	SBHK	0X50
	BS	ACZ,SYS_SER_RUN_0X50	;spk-off/spk-on&mute-off/spk-on&mute-on
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X51	;handset
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X52	;new phonebook(save,cid package)
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X53	;music play(midi)
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X54	;stop(play/record/remote/music)
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X55	;test command
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X56	;find missed CID
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X57	;find answered CID
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X58	;dialed call
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X59	;find phonebook
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X5A	;find name by number(phonebook,cidpackage)
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X5B	;new dialed call(save,cid package)
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X5C	;dialed missed call(save,cid package)
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X5D	;dialed answered call
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X5E	;delete dialed call
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X5F	;delete 
;-------
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X6070:
	LAC	MSG
	SBHK	0X60
	BS	ACZ,SYS_SER_RUN_0X60
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X61
	SBHK	0X04
	BS	ACZ,SYS_SER_RUN_0X65
	SBHK	0X05
	BS	ACZ,SYS_SER_RUN_0X6A
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X6B
	
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X7080:
	LAC	MSG
	SBHK	0X7F
	BS	ACZ,SYS_SER_RUN_0X7F
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X8090:
	LAC	MSG
	SBHL	0X80
	BS	ACZ,SYS_SER_RUN_0X80
	
	BS	B1,SYS_MSG_YES
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
SYS_SER_RUN_0X40:
	CALL	GETR_DAT
	ANDK	0X007		;centry
	
	CALL	GETR_DAT	;byte2 - year
	CALL	YEAR_SET
	
	CALL	GETR_DAT	;byte3 - month
	CALL	MON_SET
;-	
	CALL	GETR_DAT	;byte4 - day
	CALL	DAY_SET
;-	
	CALL	GETR_DAT	;byte5 - hour
	CALL	HOUR_SET
;-	
	CALL	GETR_DAT	;byte6 - minute
	CALL	MIN_SET
	
	CALL	GETR_DAT	;byte7 - minute
	CALL	SEC_SET	
	
	CALL	GETR_DAT	;byte8 - week
	CALL	WEEK_SET
	
	
	
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X41:
	LACL	CMSG_PLY	;play message(ACK)
	SAH	MSG

	BS	B1,SYS_MSG_NO	;excute immediately
;---------------------------------------
SYS_SER_RUN_0X42:
	LACL	CPLY_PAUSE	;pause playing
	SAH	MSG

	BS	B1,SYS_MSG_NO	;excute immediately
;---------------------------------------
SYS_SER_RUN_0X43:
	LACL	CPLY_NEXT	;next message
	SAH	MSG

	BS	B1,SYS_MSG_NO	;excute immediately
;---------------------------------------
SYS_SER_RUN_0X44:
	LACL	CPLY_PREV	;previous/repeat message
	SAH	MSG

	BS	B1,SYS_MSG_NO	;excute immediately
;---------------------------------------
SYS_SER_RUN_0X45:
	
	BS	B1,SYS_MSG_YES
;---------------------------------------
SYS_SER_RUN_0X46:
	LACL	CREC_MEMO	;record MEMO
	SAH	MSG
	
	BS	B1,SYS_MSG_NO	;excute immediately
;---------------------------------------
SYS_SER_RUN_0X47:
	LACL	CREC_2WAY
	SAH	MSG
	BS	B1,SYS_MSG_NO	;excute immediately
;---------------------------------------
SYS_SER_RUN_0X48:
	CALL	GETR_DAT
	ANDL	0X0FF
	BS	ACZ,SYS_SER_RUN_0X480X00
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X480X01
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X480X00:		;ANS-on
	LAC	EVENT
	ANDL	~(1<<9)
	SAH	EVENT

	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X480X01:		;ANS-off
	
	LAC	EVENT
	ORL	1<<9
	SAH	EVENT

	BS	B1,SYS_MSG_YES
;---------------------------------------
SYS_SER_RUN_0X49:
	CALL	GETR_DAT
	ANDL	0X0FF
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X490X01
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X490X02
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X490X01:		;select OGM1
	LAC	EVENT
	ANDL	~(1<<8)
	SAH	EVENT
	BS	B1,SYS_MSG_YES
	
SYS_SER_RUN_0X490X02:		;select OGM2
	LAC	EVENT
	ORL	1<<8
	SAH	EVENT
	
	BS	B1,SYS_MSG_YES
;---------------------------------------
SYS_SER_RUN_0X4A:		;play OGM
	LAC	ANN_FG
	ANDL	~(1<<8)
	SAH	ANN_FG
	
	CALL	GETR_DAT
	ANDK	0X007
	;SAH	OGM_ID
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X4A_DONE
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X4A_2
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X4A_2:
	LAC	ANN_FG
	ORL	1<<8
	SAH	ANN_FG
SYS_SER_RUN_0X4A_DONE:
	LACL	CPLY_OGM
	SAH	MSG
	BS	B1,SYS_MSG_NO	;excute immediately
;---------------------------------------
SYS_SER_RUN_0X4B:		;record OGM
	LAC	ANN_FG
	ANDL	~(1<<8)
	SAH	ANN_FG
	
	CALL	GETR_DAT
	ANDK	0X007
	;SAH	OGM_ID
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X4B_DONE
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X4B_2
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X4B_2:

	LAC	ANN_FG
	ORL	1<<8
	SAH	ANN_FG
SYS_SER_RUN_0X4B_DONE:
	LACL	CREC_OGM
	SAH	MSG
	BS	B1,SYS_MSG_NO	;excute immediately
;---------------------------------------
SYS_SER_RUN_0X4C:
	LACL	CPLY_ERAS	;erase playing message
	SAH	MSG
	BS	B1,SYS_MSG_NO	;excute immediately
;---------------------------------------
SYS_SER_RUN_0X4D:
	LACL	COLD_ERAS	;erase all old messages
	SAH	MSG

	BS	B1,SYS_MSG_NO	;excute immediately
;---------------------------------------
SYS_SER_RUN_0X4E:
	CALL	GETR_DAT
	ANDK	0X01F
	SAH	MSG
	SBHK	5
	BS	SGN,SYS_SER_RUN_0X4EDONE_1	; <5
	SBHK	16
	BZ	SGN,SYS_SER_RUN_0X4EDONE_1	; >20
	
	LAC	MSG
	SAH	OGM_ID
SYS_SER_RUN_0X4EDONE:
	LACL	CMSG_PSA
	SAH	MSG

	BS	B1,SYS_MSG_NO	;excute immediately
SYS_SER_RUN_0X4EDONE_1:	
	LACK	10
	SAH	OGM_ID
	BS	B1,SYS_SER_RUN_0X4EDONE
;---------------------------------------
SYS_SER_RUN_0X4F:
	CALL	GETR_DAT
	ANDK	0X03
	SAH	MSG
	BS	ACZ,SYS_SER_RUN_0X4E0X00
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X4E0X01
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X4E0X00:
	LACL	CVOL_DEC
	SAH	MSG
	BS	B1,SYS_MSG_NO	;excute immediately
SYS_SER_RUN_0X4E0X01:	
	LACL	CVOL_INC
	SAH	MSG
	BS	B1,SYS_MSG_NO	;excute immediately
;---------------------------------------
SYS_SER_RUN_0X50:
	CALL	GETR_DAT
	ANDK	0X07
	BS	ACZ,SYS_SER_RUN_0X500X00
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X500X01
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X500X02
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X500X00:		;Speaker-off
	LACL	CPHONE_OFF
	SAH	MSG
	BS	B1,SYS_MSG_NO	;excute immediately
SYS_SER_RUN_0X500X01:		;Speaker-on and mute-on
	LACL	CMUTE_ON
	CALL	STOR_MSG
	
	LACL	CPHONE_ON
	SAH	MSG
	BS	B1,SYS_MSG_NO	;excute immediately
	
SYS_SER_RUN_0X500X02:		;Speaker-on and mute-off
	LACL	CMUTE_OFF
	CALL	STOR_MSG
	
	LACL	CPHONE_ON
	SAH	MSG
	BS	B1,SYS_MSG_NO	;excute immediately
;---------------------------------------
SYS_SER_RUN_0X51:
	CALL	GETR_DAT
	ANDK	0X07
	BS	ACZ,SYS_SER_RUN_0X510X00
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X510X01
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X510X00:		;hook-on
	LACL	CHOOK_ON
	SAH	MSG
	BS	B1,SYS_MSG_NO	;excute immediately
SYS_SER_RUN_0X510X01:		;hook-off
	LACL	CHOOK_OFF
	SAH	MSG
	BS	B1,SYS_MSG_NO	;excute immediately
;---------------------------------------
SYS_SER_RUN_0X52:
	CALL	GETR_DAT
	ANDK	0X0F
	SAH	OGM_ID		;book-ID

	LACL	CSAVE_PBOOK
	SAH	MSG
	BS	B1,SYS_MSG_NO	;excute immediately
;---------------------------------------
SYS_SER_RUN_0X53:
	CALL	GETR_DAT
	ANDK	0X0F
	SAH	MIDI_ID		;Midi-ID
	
	LACL	CMIDI_VOP
	SAH	MSG
	BS	B1,SYS_MSG_NO	;excute immediately
;---------------------------------------
SYS_SER_RUN_0X54:
	LACL	CMSG_STOP	;stop
	SAH	MSG
	BS	B1,SYS_MSG_NO	;excute immediately
;---------------------------------------
SYS_SER_RUN_0X55:
	LACL	CTMODE_IN
	SAH	MSG

	BS	B1,SYS_MSG_YES	;excute immediately
;---------------------------------------
SYS_SER_RUN_0X56:
	CALL	GETR_DAT
	ANDK	0X7F
	SAH	OGM_ID		;book-ID

	
	LACL	CFIND_MISSCID
	SAH	MSG
	
	BS	B1,SYS_MSG_NO	;excute immediately
;---------------------------------------
SYS_SER_RUN_0X57:
	CALL	GETR_DAT
	ANDK	0X7F
	SAH	OGM_ID		;book-ID

	LACL	CFIND_ANSWCID
	SAH	MSG
	
	BS	B1,SYS_MSG_NO	;excute immediately
;---------------------------------------
SYS_SER_RUN_0X58:
	CALL	GETR_DAT
	ANDK	0X7F
	SAH	OGM_ID		;Dialed-call-ID
	
	LACL	CFIND_DTEL
	SAH	MSG
	
	BS	B1,SYS_MSG_NO	;excute immediately
;---------------------------------------
SYS_SER_RUN_0X59:
	CALL	GETR_DAT
	ANDK	0X7F
	SAH	OGM_ID		;book-ID
	
	LACL	CFIND_PBOOK
	SAH	MSG

	BS	B1,SYS_MSG_NO	;excute immediately
;---------------------------------------
SYS_SER_RUN_0X5A:
	LACL	CFIND_NUM
	SAH	MSG
	
	BS	B1,SYS_MSG_NO	;excute immediately
;---------------------------------------
SYS_SER_RUN_0X5B:
	LACL	CSAVE_DTEL
	SAH	MSG
	
	BS	B1,SYS_MSG_NO	;excute immediately
;---------------------------------------
SYS_SER_RUN_0X5C:
	CALL	GETR_DAT
	ANDK	0X07F
	SAH	OGM_ID
	
	LACL	CDEL_MISSCID
	SAH	MSG
	
	BS	B1,SYS_MSG_NO	;excute immediately
;---------------------------------------
SYS_SER_RUN_0X5D:
	CALL	GETR_DAT
	ANDK	0X07F
	SAH	OGM_ID
	
	LACL	CDEL_ANSWCID
	SAH	MSG
	
	BS	B1,SYS_MSG_NO	;excute immediately
;---------------
SYS_SER_RUN_0X5E:
	CALL	GETR_DAT
	ANDK	0X07F
	SAH	OGM_ID
	
	LACL	CDEL_DTEL
	SAH	MSG
	
	BS	B1,SYS_MSG_NO	;excute immediately
;---------------
SYS_SER_RUN_0X5F:
	CALL	GETR_DAT
	ANDK	0X07F
	SAH	OGM_ID
	
	LACL	CDEL_PBOOK
	SAH	MSG
	
	BS	B1,SYS_MSG_NO	;excute immediately
;---------------
SYS_SER_RUN_0X60:
	CALL	GETR_DAT
	ANDK	0X07F
	BS	ACZ,SYS_SER_RUN_0X600X00
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X600X01
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X600X02
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X600X00:
	LACL	CMSG_BEEP	;Generate BEEP
	SAH	MSG
	
	BS	B1,SYS_MSG_NO	;excute immediately
SYS_SER_RUN_0X600X01:
	LACL	CMSG_BBEEP	;Generate BBEEP
	SAH	MSG
	
	BS	B1,SYS_MSG_NO	;excute immediately
SYS_SER_RUN_0X600X02:
	LACL	CMSG_LBEEP	;Generate LBEEP
	SAH	MSG
	
	BS	B1,SYS_MSG_NO	;excute immediately
;---------------
SYS_SER_RUN_0X61:
	LACL	CMSG_FMAT
	SAH	MSG
	
	BS	B1,SYS_MSG_NO	;excute immediately
;---------------
SYS_SER_RUN_0X65:
	CALL	GETR_DAT
	ANDK	0X0F
	SAH	MIDI_ID
	
	LACL	CMIDI_VOL
	SAH	MSG
	BS	B1,SYS_MSG_NO	;excute immediately
;---------------
SYS_SER_RUN_0X6A:

	BS	B1,SYS_MSG_YES
;---------------
SYS_SER_RUN_0X6B:
	CALL	GETR_DAT
	ANDK	0X0F
	SAH	MSG
	
	LAC	MSG
	BS	ACZ,SYS_SER_RUN_0X6B0X00
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X6B0X01
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X6B0X02
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X6B0X03
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X6B0X04
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X6B0X05
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X6B0X06
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X6B0X07
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X6B0X08
	SBHK	0X01
	BS	ACZ,SYS_SER_RUN_0X6B0X09
	
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_0X6B0X00:
	LACL	CTMODE_IN	;goto test mode
	SAH	MSG
	BS	B1,SYS_MSG_NO		;excute immediately
SYS_SER_RUN_0X6B0X01:
	
	LACL	CTMODE_STOP	;stop current test
	SAH	MSG
	BS	B1,SYS_MSG_NO		;excute immediately
SYS_SER_RUN_0X6B0X02:
	
	LACL	CTMODE_LREC	;line record
	SAH	MSG
	BS	B1,SYS_MSG_NO		;excute immediately
SYS_SER_RUN_0X6B0X03:
	
	LACL	CTMODE_MPLY	;play all message
	SAH	MSG
	BS	B1,SYS_MSG_NO		;excute immediately
SYS_SER_RUN_0X6B0X04:
	
	LACL	CTMODE_PBEEP	;Play BEEP
	SAH	MSG
	BS	B1,SYS_MSG_NO		;excute immediately
SYS_SER_RUN_0X6B0X05:
	
	LACL	CTMODE_VOX	;VOX test
	SAH	MSG
	BS	B1,SYS_MSG_NO		;excute immediately
SYS_SER_RUN_0X6B0X06:
	
	LACL	CTMODE_DTMF	;DTMF test
	SAH	MSG
	BS	B1,SYS_MSG_NO		;excute immediately
SYS_SER_RUN_0X6B0X07:
	
	LACL	CTMODE_MEMR	;Memory test
	SAH	MSG
	BS	B1,SYS_MSG_NO		;excute immediately
SYS_SER_RUN_0X6B0X08:
SYS_SER_RUN_0X6B0X09:	
	LACL	CTMODE_RESVED	;reserved command
	SAH	MSG
	BS	B1,SYS_MSG_NO		;excute immediately
;---------------
SYS_SER_RUN_0X7F:
;-----------------------byte1
	CALL	GETR_DAT	;byte1 - ps1,2
	SFL	8
	ANDL	0XFF00
	SAH	PASSWORD
;-----------------------byte2
	CALL	GETR_DAT	;byte2 - ps3,4
	OR	PASSWORD
	SAH	PASSWORD
;-----------------------byte3
	CALL	GETR_DAT	;byte3 - Local code1,2
	SFL	8
	ANDL	0XFF00
	SAH	LOCACODE
;-----------------------byte4
	CALL	GETR_DAT	;byte4 - Local code3,4
	OR	LOCACODE
	SAH	LOCACODE
;-----------------------byte5
	LAC	DAM_ATT0
	ANDL	0XFFF0
	SAH	DAM_ATT0

	CALL	GETR_DAT	;byte5 - LCD constrast
	ANDK	0X0F
	OR	DAM_ATT0
	SAH	DAM_ATT0
;-----------------------byte6
	LAC	DAM_ATT
	ANDL	0XFCFF
	SAH	DAM_ATT		;clear bit(9,8) first

	CALL	GETR_DAT	;byte6 - language
	SFL	8
	ANDL	0X0300
	OR	DAM_ATT
	SAH	DAM_ATT
;-----------------------byte7
	LAC	DAM_ATT0
	ANDL	0XFF0F
	SAH	DAM_ATT0	;clear bit(7..4) first

	CALL	GETR_DAT	;byte7 - ring melody
	SFL	4
	ANDL	0X00F0
	OR	DAM_ATT0
	SAH	DAM_ATT0
;-----------------------byte8
	LAC	DAM_ATT1
	ANDL	0XFFF0
	SAH	DAM_ATT1	;bit(3..0) first

	CALL	GETR_DAT	;byte8 - ring volume
	ANDK	0X0F
	OR	DAM_ATT1
	SAH	DAM_ATT1
;-----------------------byte9
	LAC	DAM_ATT
	ANDL	0X0FFF
	SAH	DAM_ATT

	CALL	GETR_DAT	;byte9 - ring delay
	ANDK	0X0F
	SFL	12
	OR	DAM_ATT
	SAH	DAM_ATT
;-----------------------byte10
	LAC	DAM_ATT1
	ANDL	0XFF0F
	SAH	DAM_ATT1	;clear bit(7..4) first

	CALL	GETR_DAT	;byte10 -compression rate
	ANDK	0X0F
	SFL	4
	OR	DAM_ATT1
	SAH	DAM_ATT1
;-----------------------byte11
	LAC	DAM_ATT0
	ANDL	0XF0FF
	SAH	DAM_ATT0	;clear bit(11..8) first
	
	CALL	GETR_DAT	;byte11 -flash time
	SFL	8
	ANDL	0X0F00
	OR	DAM_ATT0
	SAH	DAM_ATT0
;-----------------------byte12
	LAC	DAM_ATT0
	ANDL	0X0FFF
	SAH	DAM_ATT0	;clear bit(15..12) first

	CALL	GETR_DAT	;byte12 -pause time
	SFL	12
	ANDL	0XF000
	OR	DAM_ATT0
	SAH	DAM_ATT0
;-----------------------byte13
	LAC	EVENT
	ANDL	~((1<<9)|(1<<8))
	SAH	EVENT

	CALL	GETR_DAT	;byte13 -status
	SAH	SYSTMP0
	BIT	SYSTMP0,7
	BZ	TB,SYS_SER_RUN_0X7F_ANSON
	
	LAC	EVENT
	ORL	1<<9
	SAH	EVENT
	;BS	B1,SYS_SER_RUN_0X7F_SELOGM
SYS_SER_RUN_0X7F_ANSON:
SYS_SER_RUN_0X7F_SELOGM:
	SAH	SYSTMP0
	ANDK	0X0F
	SBHK	1
	BS	ACZ,SYS_SER_RUN_0X7F_END

	LAC	EVENT
	ORL	1<<8
	SAH	EVENT
SYS_SER_RUN_0X7F_END:
	LACL	CDAM_UPDATE
	SAH	MSG
	
	BS	B1,SYS_MSG_NO	;excute immediately
;-
	;BS	B1,SYS_MSG_YES
;---------------------------------------
SYS_SER_RUN_0X80:
;---
	LACL	CidData
	SAH	ADDR_D
	LACK	0		;the offset of Repeat-Byte
	SAH	OFFSET_D
	
	LACL	0X80
	CALL	STORBYTE_DAT
	
	LACK	1
	SAH	OFFSET_D
	LACK	57
	SAH	COUNT		;Save 57+1 Bytes
SYS_SER_RUN_0X80_MOVE:	
	CALL	GETR_DAT
	CALL	STORBYTE_DAT
	
	LAC	OFFSET_D
	ADHK	1
	SAH	OFFSET_D
	
	LAC	COUNT
	SBHK	1
	SAH	COUNT		;the counter of remain
	BZ	ACZ,SYS_SER_RUN_0X80_MOVE
;-------
	BS	B1,SYS_MSG_YES
;-------------------------------------------------------------------------------
;DAM_BIOS的软中断程序:record/play/beep/line/VoicePrompt/speakerphone
;-------------------------------------------------------------------------------
INT_BIOS:
	BIT	EVENT,7
	BS	TB,INT_BIOS_REC		;RECORD
	BIT	EVENT,6
	BS	TB,INT_BIOS_PLAY	;PLAY
	BIT	EVENT,5
	BS	TB,INT_BIOS_END		;BEEP不作处理
	BIT	EVENT,4
	BS	TB,INT_BIOS_LINE	;LINE
	BIT	EVENT,3
	BS	TB,INT_BIOS_PHONE	;speakerphone
	CALL	GET_VP
	BZ	ACZ,INT_BIOS_START

	RET
;---
INT_BIOS_PHONE:
	
	CALL	DAM_BIOS
	BS	B1,INT_BIOS_END
;---------------------------------------
INT_BIOS_LINE:				;line mode
	LACL	0X5000
	CALL	DAM_BIOSFUNC

	;bs	b1,INT_BIOS_RESP	;???????????????????????????????

	BIT	EVENT,10
	BS	TB,INT_BIOS_LINE_NOCHKCID	;don`t detect CID when line seize
		
	BIT	SER_FG,CbLINE		
	BS	TB,INT_BIOS_LINE_NOCHKCID	;don`t detect CID when ring or Torev on line
	
	CALL	CidRawData
	BS	ACZ,INT_BIOS_RESP		;no
	SBHK	1
	BS	ACZ,INT_BIOS_LINE_FSKCID	;FSK-CID vaild
	SBHK	1
	BS	ACZ,INT_BIOS_LINE_DTMFCID	;DTMF-CID vaild
	BS	B1,INT_BIOS_RESP		;error
INT_BIOS_LINE_NOCHKCID:		;
	LAC	CID_FG
	ANDL	0XFFF0
	SAH	CID_FG
	
	CALL	CLR_TIMER0
	BS	B1,INT_BIOS_RESP
INT_BIOS_LINE_FSKCID:
	LACL	CFSK_CID
	CALL	STOR_MSG
	
	BS	B1,INT_BIOS_RESP
INT_BIOS_LINE_DTMFCID:	
	LACL	CDTMF_CID
	CALL	STOR_MSG
	
	BS	B1,INT_BIOS_RESP
;---------------------------------------
INT_BIOS_REC:				;record mode
	CALL	DAM_BIOS
	BIT	RESP,7
	BZ	TB,INT_BIOS_RESP
	
	LACL	CREC_FULL		;产生memfull消息
	CALL	STOR_MSG
	BS	B1,INT_BIOS_RESP
;---------------------------------------
INT_BIOS_PLAY:				;play(voice prompt) mode
	CALL	DAM_BIOS
	BIT	RESP,6
	BZ	TB,INT_BIOS_RESP
	
	LACL	CSEG_END
	CALL	STOR_MSG		;产生结束消息
	BS	B1,INT_BIOS_RESP
;---------------------------------------
;*********
INT_BIOS_RESP:
	BIT	EVENT,10
	BZ	TB,INT_BIOS_RESP_LOCAL		;本地工作,不查VOX/BTONE/CTONE/DTMF
	BIT	EVENT,6
	BS	TB,INT_BIOS_RESP_BTONEDTMF	;play mode,不查VOX/CTONE
;*********
;---LINE---LINE---LINE---LINE---LINE---LINE---LINE---LINE
INT_BIOS_RESP_VOX:			;for record/line mode 
	CALL	VOX_CHK
	BS	ACZ,INT_BIOS_RESP_VOX_END
	LACL	CMSG_VOX
	CALL	STOR_MSG
INT_BIOS_RESP_VOX_END:	
;---------
;---------
INT_BIOS_RESP_CTONE:			;for record/line mode 
	CALL	CTONE_CHK
	BS	ACZ,INT_BIOS_RESP_CTONE_END
	LACL	CMSG_CTONE
	CALL	STOR_MSG
INT_BIOS_RESP_CTONE_END:
;---------
;---------
INT_BIOS_RESP_BTONEDTMF:
	
;---------
;---------
INT_BIOS_RESP_BTONE:			;for record/play/line/voice_prompt mode 
	CALL	BTONE_CHK
	BS	ACZ,INT_BIOS_RESP_BTONE_END
	LACL	CMSG_BTONE
	CALL	STOR_MSG
INT_BIOS_RESP_BTONE_END:
;---------
;---------	
INT_BIOS_RESP_DTMF:			;for record/play/line/voice_prompt mode 
	CALL	DTMF_CHK
	BS	ACZ,INT_BIOS_RESP_DTMF_END
	SBHK	1
	BS	ACZ,INT_BIOS_RESP_DTMFSTART
	SBHK	1
	BS	ACZ,INT_BIOS_RESP_EDTMF
	BS	B1,INT_BIOS_RESP_DTMF_END
INT_BIOS_RESP_DTMFSTART:
;---return 1
	LACL	CREV_DTMFS
	CALL	STOR_MSG
	BS	B1,INT_BIOS_RESP_DTMF_END
INT_BIOS_RESP_EDTMF:
;---return 2
	LACL	CREV_DTMF
	CALL	STOR_MSG
	
INT_BIOS_RESP_DTMF_END:
;---------
	BS	B1,INT_BIOS_END
;---LOCAL---LOCAL---LOCAL---LOCAL---LOCAL---LOCAL---LOCAL---LOCAL
INT_BIOS_RESP_LOCAL:			;开始查CID
;---------

INT_BIOS_END:
	
	RET
;----
;---------------------------------------
INT_BIOS_START:
	SAH	SYSTMP2
	CALL	DAM_STOP
	
	LAC	SYSTMP2
	ANDL	0XFF
	SAH	SYSTMP0
	
	LAC	SYSTMP2
	SFR	8
	SAH	SYSTMP1
	
	SBHL	0XFF
	BS	ACZ,INT_BIOS_START_VOP
	LAC	SYSTMP1
	SBHL	0XFE
	BS	ACZ,INT_BIOS_START_PLAY_TOTAL
	LAC	SYSTMP1
	SBHL	0XFD
	BS	ACZ,INT_BIOS_START_PLAY_NEW
INT_BIOS_START_BEEP:
	LAC	SYSTMP0
	SFL	3
	SAH	TMR_BEEP		;length of time
	LAC	SYSTMP1
	SFL	8
	BS	ACZ,INT_BIOS_START_BEEP0	;frequency = 0(发声间隙)
	SAH	BUF1			;frequency
	
	LACL	CBEEP_COMMAND		;ON
	SAH	CONF
	CALL    DAM_BIOS
	
	LAC	BUF1
	SAH	CONF
	CALL    DAM_BIOS
	LACK	0
	SAH	CONF
	CALL    DAM_BIOS
INT_BIOS_START_BEEP0:	
	LACL	CBEEP_COMMAND		;
	SAH	CONF

INT_BIOS_START_BEEP_END:	
	LAC	EVENT		;SET flag(bit5)
	ORK	0X020
	SAH	EVENT


	RET
;---
INT_BIOS_START_PLAY_TOTAL:
	LAC	SYSTMP0
	ORL	0X2000
	SAH	CONF
	BS	B1,INT_BIOS_START_VP_FLAG
;---
INT_BIOS_START_PLAY_NEW:
	LAC	SYSTMP0
	ORL	0X2400
	SAH	CONF
	BS	B1,INT_BIOS_START_VP_FLAG
;---
INT_BIOS_START_VOP:
	LAC	SYSTMP0
	ORL	0XB000
	SAH	CONF
INT_BIOS_START_VP:
	
INT_BIOS_START_VP_FLAG:
	LAC	EVENT		;SET flag(bit6)
	ORK	0X040
	SAH	EVENT

	RET
;---
INIT_DAM_FUNC:
	CALL	DAM_STOP	;停止DAM_BIOS
	LACK	0
	SAH	VP_QUEUE	;发声队列清空
	RET
;---

DAM_STOP:			;关闭前面操作和标志位并设成IDLE模式
	LACK	0
	SAH	TMR_BEEP	;BEEP TMR清
	LAC	EVENT
	ANDL	0XFF00
	SAH	EVENT		;标志清空
	
	LAC	CONF
	BS	ACZ,DAM_STOP_IDLE
	SFR	12
	SBHK	1
	BS      ACZ,DAM_STOP_REC	;// 0X1000
	SBHK	1
	BS      ACZ,DAM_STOP_PLAY	;// 0X2000
	SBHK	2
	BS      ACZ,DAM_STOP_BEEP	;// 0X4000
	SBHK	1
	BS      ACZ,DAM_STOP_LINE	;// 0X5000
	SBHK	6
	BS      ACZ,DAM_STOP_PLAY	;// 0XB000
	SBHK	1
	BS      ACZ,DAM_STOP_PHONE	;// 0XC000
	BS	B1,DAM_STOP_IDLE
DAM_STOP_REC:
	LAC	CONF
	ORK	0X40
	CALL	DAM_BIOSFUNC
	BS	B1,DAM_STOP_IDLE
DAM_STOP_PHONE:
	LACL    0XC080
	CALL    DAM_BIOSFUNC
	BS	B1,DAM_STOP_IDLE
DAM_STOP_LINE:
	LACL    0X5001
	CALL    DAM_BIOSFUNC
	BS	B1,DAM_STOP_IDLE
DAM_STOP_PLAY:
	LAC	CONF
	ORL     0X0200
	CALL	DAM_BIOSFUNC
	BS	B1,DAM_STOP_IDLE
DAM_STOP_BEEP:
	LACL	0X4400
	CALL	DAM_BIOSFUNC
DAM_STOP_IDLE:				;// IDLE MODE
	LACK	0
	SAH     CONF
	
	RET
;----------------------------------------------------------------------------
;	Function : REC_START
;	input : no
;	output: no
;----------------------------------------------------------------------------
REC_START:
	LAC	EVENT		;SET flag(bit7)
	ANDL	0XFF00
	;ORL	0X080
	ORL	1<<7
	SAH	EVENT

	LACL	0X1000
	SAH	CONF
	
	RET
;----------------------------------------------------------------------------
;	Function : LINE_START
;	input : no
;	output: no
;----------------------------------------------------------------------------
LINE_START:
	LAC	EVENT		;SET flag(bit4)
	ANDL	0XFF00
	;ORK	0X010
	ORK	1<<4
	SAH	EVENT
	
	LACL	0X5000
	SAH	CONF
	
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
;----------------------------------------------------------------------------
;       Function : DTMF_CHK
;
;       The general routine used in remote line operation. It checks DTMF
;       Input  : CONF (Record Mode, Play Mode, Line Mode or Voice Prompt Mode)
;       Output : ACCH = 0  -  No detected
;                ACCH = 1  -  DTMF start detected
;	 	 ACCH = 2  -  DTMF end detected

;		 DTMF_VAL  =  DTMF value
;       Parameters:
;               8. EVEVT.11 - store the detected DTMF flag
;----------------------------------------------------------------------------
DTMF_CHK:
	LAC     RESP            ;check the DTMF value 'D'?
        ANDL    0X010F
        XORL	0X010F
        BZ	ACZ,DTMF_CHK0
;---check 'D'
        LACK	0X010
        BS	B1,DTMF_CHK0_1
;---check "0..9","ABCD",'*','#'
DTMF_CHK0:	
        LAC     RESP            ;check the DTMF value ?
        ANDK    0X0F
        BS      ACZ,DTMF_CHK1
DTMF_CHK0_1:
	ADHL	DTMF_TABLE
	CALL	GetOneConst
        SAH     DTMF_VAL	;save the DTMF value in DTMF_VAL
DTMF_CHK0_2:
	BIT     EVENT,11
        BS      TB,DTMF_CHK_END
;---DTMF从无到有
        LAC     EVENT
        ORL	1<<11
        SAH     EVENT

	LACK	1		;DTMF start detected, return ACCH = 1

        RET
DTMF_CHK1:
	BIT     EVENT,11
        BZ      TB,DTMF_CHK_END

        LAC     EVENT
        ANDL	~(1<<11)
        SAH     EVENT

        LACK    2		;DTMF end detected, return ACCH = 2
        RET
DTMF_CHK_END:
	LACK	0
	
	RET
;----------------------------------------------------------------------------
;       Function : CASTONE_CHK
;
;       The general routine used in remote line operation. It checks Cas-tone
;       Input  : CONF (Record Mode, Play Mode, Line Mode or Voice Prompt Mode)
;       Output : ACCH = 0  -  No detected
;                ACCH = 1  -  Cas-tone start detected
;	 	 ACCH = 2  -  Cas-tone end detected
;
;       Parameters:
;               8. EVEVT.12 - store the detected Cas-tone flag
;----------------------------------------------------------------------------
.if	0
CASTONE_CHK:
	BIT	RESP,8
	BZ	TB,CASTONEE_CHK
;---有
	LAC	RESP
        ANDK	0X0F
        BZ	ACZ,CASTONE_CHK_END

	BIT	EVENT,12
	BS	TB,CASTONE_CHK_END
;---无 ==> 有
	LAC     EVENT
        ORL	1<<12
        SAH     EVENT
	
	LACK    1		;Cas-Tone start detected, return ACCH=3
	
	RET
CASTONE_CHK_END:		;(有-有)||(无-无)
	LACK	0
	
	RET
CASTONEE_CHK:
;---无
	BIT	EVENT,12
	BZ	TB,CASTONE_CHK_END
;---有 ==> 无
	LAC     EVENT
        ANDL	~(1<<12)
        SAH     EVENT
	
	LACK    2		;Cas-Tone end detected, return ACCH=4
	
	RET
.endif
;----------------------------------------------------------------------------
;       Function : CTONE_CHK
;
;       The general routine used in remote line operation. It checks CONT TONE
;       Input  : CONF (Record Mode, Line Mode)
;       Output : ACCH = 1  -  continuous tone period found
;                ACCH = 0  -  no continuous tone period found
;       Parameters:
;               1. TMR_CTONE     - for continuous tone detection
;----------------------------------------------------------------------------
CTONE_CHK:
	
        BIT     RESP,4            	; check if continuous tone happens ?
        BS      TB,CTONE_CHK_ON
        LACL    CTMR_CTONE              	; continuous tone off
        SAH     TMR_CTONE
CTONE_CHK_ON:
        LAC     TMR_CTONE
        BZ      SGN,CTONE_CHK_ON_2
        
CTONE_CHK_ON_1:	
        LACK    1                 	; continuous tone period found, return ACCH=1
        RET
CTONE_CHK_ON_2:
	LACK    0
        RET
;----------------------------------------------------------------------------
;       Function : VOX_CHK
;
;       The general routine used in remote line operation. It checks VOX
;       Input  : CONF (Record Mode)
;       Output : ACCH = 1  -  VOX found over 10.0 sec
;                ACCH = 0  -  no VOX found over 10.0 sec
;               
;       Parameters:
;               1. TMR_VOX - for VOX detection(initial TMR_VOX=VOX time)
;----------------------------------------------------------------------------
VOX_CHK:				; check the VOX
        BIT     RESP,6
        BZ      TB,VOX_CHK_OFF
VOX_CHK_ON:                     ; VOX on
        LAC     TMR_VOX
        BZ      SGN,VOX_CHK_END
       
VOX_CHK_ON_1:
        LACK    1                 ; VOX found over 7.0 sec, return ACCH=1
        RET
VOX_CHK_OFF:                     ; VOX off
        LACL    CTMR_CVOX              ; restore 7.0 sec in TMR_VOX
        SAH     TMR_VOX
VOX_CHK_END:
	LACK    0
	RET
;----------------------------------------------------------------------------
;       Function : BTONE_CHK
;
;       The general routine used in remote line operation. It checks BUSY TONE
;       Input  : CONF (Record Mode, Play Mode, Line Mode or Voice Prompt Mode)
;       Output : ACCH = 1  -  Busy tone
;                ACCH = 0  -  NO Busy tone
;
;       Parameters:
;               3. TMR_BTONE     - for busy tone detection
;               4. BTONE_BUF    - store the total time of busy tone
;               5. BUF1     - store the last on time of busy tone
;               6. BUF2     - store the last off time of busy tone
;               7. BUF3     - store some flags for busy tone detection
;                  (see BUF3.DOC)
;
;		BUF3.4 = BTONE-on
;		BUF3.5 = BTONE-off
;		BUF3.6 = 1/0 ==>first busy tone on to off happend/not
;		BUF3.7 = 1/0 ==>first busy tone off to on happend/not
;----------------------------------------------------------------------------
BTONE_CHK:
        BIT     RESP,5
        BZ      TB,BTONE_CHK_OFF
BTONE_CHK_ON:                    	; busy tone on
        BIT     BUF3,5            	; check if transition from busy tone off ?
        BZ      TB,BTONE_CHK_ON_ONTON
;---off to on
        LAC     TMR_BTONE              	; if busy tone off time < 200 ms, fails
        SBHK    50		;change1 2006/11/04(busy tone off time < 200 ms, fails)
        BS      SGN,BTONE_CHK_ON_FAIL

        LAC     BUF3
        ANDL    0XCF
        ORK     0X10              	; set 'in busy tone on' bit to 1
        SAH     BUF3

        BIT     BUF3,7            	; check if the first busy tone off to on
        BS      TB,BTONE_CHK_ON1_1 	; has happened ?
                                  	; from busy tone off to on first time
        LAC     BUF3
        ORL     0X80
        SAH     BUF3
        BS      B1,BTONE_CHK_ON1_2
BTONE_CHK_ON1_1:
        SOVM
        LAC     TMR_BTONE              	; TMR_BTONE=the current busy tone off time
        SBH     BUF2              	; BUF2=the last busy tone off time
        ABS                       	; the difference between TMR_BTONE and BUF2
        ROVM                      	;   must be < 64 ms
        SBHK    0X10
        BZ      SGN,BTONE_CHK_ON_FAIL
        
        LAC     TMR_BTONE	;change2 2006/11/04(the 400ms<TONEon + TONEoff<1400ms)
        ADH	BUF1
        SBHL	100
        BS      SGN,BTONE_CHK_ON_FAIL
        SBHL	250
        BZ      SGN,BTONE_CHK_ON_FAIL
BTONE_CHK_ON1_2:
        LAC     BTONE_BUF             	; BTONE_BUF store the total busy tone time
        ADH     BUF1              	; add the last busy tone on time to BTONE_BUF
        SAH     BTONE_BUF
.IF	1
	LAC     BUF3
	ADHK    1                 	; increase the 'tone on/off count' by 1
	SAH     BUF3
        ANDK    0X0F
        SBHK    5                 	; if the 'tone on/off count' >= 5, busy tone
        BS      SGN,BTONE_CHK_ON1_5 	; period found
.ELSE
	LAC     BUF3
	ANDK    0X0F
	SBHK	5
	BZ      SGN,BTONE_CHK_ON1_2_1
	
        LAC     BUF3
	ADHK    1
	SAH     BUF3	;计数个数大于5个就不增加了
	BS      B1,BTONE_CHK_ON1_5
BTONE_CHK_ON1_2_1:		;---计数个数为大于5个，且时长满足要求
        LAC     BTONE_BUF            	;BUSY TONE >= 7.0(=1750*4) SEC CHECK
        ;SBHL	1750 		;1750 --- 7s
	SBHL	1500            	;6s
	;SBHL	1250            	;5s
	;SBHL	1000            	;4s
	;SBHL	750	            	;3s
	;SBHL	500       	     	;2s
        BS      SGN,BTONE_CHK_ON1_5
.ENDIF
BTONE_CHK_ON1_3:          		; busy tone period found
	LAC	CONF
	SFR	12
	SBHK	1
	BZ	ACZ,BTONE_CHK_ON1_4	;record mode or not?
	
	LAC     BTONE_BUF
	ADH     TMR_BTONE
	SFR     6                 	; tail cut base 400 ms
	ANDK    0X3F              	; cut units ~= (SFR 6 + SFR 7) / 2
	SAH     BTONE_BUF
	SFR     1
	ADH     BTONE_BUF
	SFR     1
	SAH     BTONE_BUF

	LAC     CONF
	OR      BTONE_BUF
	SAH     CONF
BTONE_CHK_ON1_4:        
        LACK    1                 	; busy tone period found, return ACCH=0
        RET

BTONE_CHK_ON1_5:
        LAC     TMR_BTONE
        SAH     BUF2              	; save the current busy tone off time in BUF2

        LACK    0
        SAH     TMR_BTONE
        BS      B1,BTONE_CHK_END
BTONE_CHK_ON_FAIL:                    	; busy tone fails
        LAC     TMR_BTONE
        SAH     BUF2
        SAH     BTONE_BUF

        LACK    0
        SAH     TMR_BTONE
        SAH     BUF1

        LACL    0X90              	; set first busy tone off to on happened
        SAH     BUF3              	; set 'in busy tone on' bit to 1
        BS      B1,BTONE_CHK_END
BTONE_CHK_ON_ONTON:		;first on or on-to-on
        LAC     BUF3
        ANDL    0XCF
        ORK     0X10
        SAH     BUF3

        LAC     TMR_BTONE            	; FOR FIRST BUSY TONE > 7.0 SEC CHECK
        SBHL    1750            	; BUSY TONE 7.0 SEC
        BS      SGN,BTONE_CHK_END

        LAC     TMR_BTONE            	; OVER 7.0 SECOND BUSY TONE CONTINOUS
        SAH     BTONE_BUF
        LACK    0
        SAH     TMR_BTONE
        BS      B1,BTONE_CHK_ON1_3  	; JUMP TO TAIL CUT
BTONE_CHK_OFF:                   	; busy tone off
        BIT     BUF3,4            	; check if transition from busy tone on ?
        BZ      TB,BTONE_CHK_OFF_OFFTOFF

        LAC     TMR_BTONE              	; if busy tone on time < 60 ms, fails
        SBHK    50		;change3 2006/11/04(busy tone on time < 200 ms, fails)
        BS      SGN,BTONE_CHK_OFF_FAIL
        SBHK	125		;change4 2006/11/04(busy tone on time > 700 ms, fails)
	BZ      SGN,BTONE_CHK_OFF_FAIL

        LAC     BUF3
        ANDL    0XCF
        ORK     0X20              	; set 'in busy tone off' bit to 1
        SAH     BUF3

        BIT     BUF3,6             	; check if the first busy tone on to off
        BS      TB,BTONE_CHK_OFF1_1 	;   has happened ?
                                   	; from busy tone on to off first time
        LAC     TMR_BTONE
        SAH     BUF1

        LAC     BUF3
        ORK     0X40
        SAH     BUF3
        BS      B1,BTONE_CHK_OFF1_2
BTONE_CHK_OFF1_1:
        SOVM
        LAC     TMR_BTONE		; TMR_BTONE=the current busy tone on time
        SBH     BUF1              	; BUF2=the last busy tone on time
        ABS                       	; the difference between TMR_BTONE and BUF1
        ROVM                      	;   must be < 64 ms
        SBHK    0X10
        BZ      SGN,BTONE_CHK_OFF_FAIL

        LAC     BTONE_BUF             	; BTONE_BUF store the total busy tone time
        ADH     BUF2              	; add the last busy tone off time to BTONE_BUF
        SAH     BTONE_BUF

        ;LAC     BUF3
        ;ADHK    1                 	; increase the 'tone on/off count' by 1
        ;SAH     BUF3		;change5 2006/11/04(increase the tone on/off only in "off to on")
        
        LAC     TMR_BTONE
        SAH     BUF1              	; save the current busy tone on time in BUF1
BTONE_CHK_OFF1_2:
        LACK    0                 	; reset TMR_BTONE for restart
        SAH     TMR_BTONE
        BS      B1,BTONE_CHK_END
BTONE_CHK_OFF_FAIL:                   	; busy tone fails
        LAC     TMR_BTONE
        SAH     BUF1

        LACK    0
        SAH     TMR_BTONE
        SAH     BTONE_BUF
        SAH     BUF2

        LACK    0X60              	; set first busy tone on to off happened
        SAH     BUF3              	; set 'in busy tone off' bit to 1
        BS      B1,BTONE_CHK_END
BTONE_CHK_OFF_OFFTOFF:
        BIT     BUF3,6
        BS      TB,BTONE_CHK_END
        BIT     BUF3,7
        BS      TB,BTONE_CHK_END
        LACK    0
        SAH     TMR_BTONE
BTONE_CHK_END:
	LACK	0
	RET
;----------------------------------------------------------------------------
;       Function : BCVOX_INIT
;	input : no
;	output: no
;	variable : no
;-------------------------------------------------------------------------------
BCVOX_INIT:
	LACL	CTMR_CTONE
	SAH	TMR_VOX
	SAH	TMR_CTONE
	
	LACK	0
	SAH	BUF1
	SAH	BUF2
	SAH	BUF3
	SAH	TMR_BTONE
	SAH	BTONE_BUF
	
	RET
;-------------------------------------------------------------------------------
;	ReceiveCidData
;	Input : CidNum
;	Output: 
;       Output: ACCH = 0  -  No detected
;                ACCH = 1  -  Cid data ready
;	 	 ACCH = 2  -  Cid data error ready
;	CID_FG : 
;-------------------------------------------------------------------------------
.IF	1
CidRawData:

	LAC	CID_FG
	ANDK	0X07
	BS	ACZ,CidRawData_000	;0 - detect DTMF|FSK format
	SBHK	1
	BS	ACZ,CidRawData_100	;1 - detect FSK length
	SBHK	1
	BS	ACZ,CidRawData_200	;2 - receive FSK data
	SBHK	1
	BS	ACZ,CidRawData_300	;3 - receive DTMF data

;---Cann`t goto here	
	;BS	B1,CidRawData_End
;---------------------------------------------------------------------
CidRawData_000:
	
	LAC	CID_FG
	ANDL	0XFFF0
	SAH	CID_FG
	
	BIT	RESP,14			; Check if detect Channel seizer ?
	BS	TB,CidRawData_000_Cs
	BIT	RESP,13			; Check if detect Mark signal ?
	BS	TB,CidRawData_000_Ms
	BIT	RESP,12
	BS	TB,CidRawData_000_Fsk
;---
	;BIT	RESP,8
	;BS	TB,CidRawData_000_Cas	; CAS tone?
;CidRawData_000_1:
	CALL	DTMF_CHK
	BS	ACZ,CidRawData_End	;no DTMF singal
	SBHK	1
	BS	ACZ,CidRawData_End	;detect DTMF singal start
	SBHK	1
	BS	ACZ,CidRawData_000_DTMFS_0	;detect DTMF singal end
	BS	B1,CidRawData_End
;CidRawData_000_Cas:
	;LAC	RESP
	;ANDK	0X0F
	;BS	ACZ,CidRawData_End
	;BS	B1,CidRawData_000_1	;F'D'
;---------------------------------------
;---DTMF arrive
CidRawData_000_DTMFS_0:
	
	LAC	DTMF_VAL	;Get the last DTMF value
	SBHL	0X0FA
	BS	ACZ,CidRawData_000_DTMFS_1	;'A'
	SBHK	0x001
	BS	ACZ,CidRawData_000_DTMFS_1	;'B'
	SBHK	0x001	
	BS	ACZ,CidRawData_000_DTMFS_0_TTT	;'C'	!!!!!!!!!!!!!!!!!!!!!!!!
	SBHK	0x001	
	BS	ACZ,CidRawData_000_DTMFS_1	;'D'

	BS	B1,CidRawData_End
CidRawData_000_DTMFS_0_TTT:
	lacl	0xfd
	sah	DTMF_VAL
CidRawData_000_DTMFS_1:	
	
	LAC	CID_FG
	ANDL	0XFFF0
	ORK	0X0003		;receive DTMF start character
	SAH	CID_FG
;---- clear CidBuffer for 32 bytes ----for DTMF cid
	LACL	CidBuffer
	SAH	ADDR_D		;the base address that CID data will be store

	LARL	CidBuffer,1
	MAR	+0,1
        LACK    0
        LUPK    31,0
        SAH     +,1
;---clear checksum
	LACK	0
	SAH	CID_CHKSUM
	SAH	OFFSET_D

	LAC	DTMF_VAL
	ANDK	0X0F
	CALL	SaveCidData	;stor the format data
	
	LACL	2000
	CALL	SET_TIMER0
	
	BS	B1,CidRawData_End
;---------------------------------------
CidRawData_000_Cs:
	LACL	0x5002
	CALL	DAM_BIOSFUNC
	BS	B1,CidRawData_End
CidRawData_000_Ms:
	LACL	0x5003
	CALL	DAM_BIOSFUNC
	BS	B1,CidRawData_End
CidRawData_000_Fsk:
	
	LACL	0x5004
	CALL	DAM_BIOSFUNC
	;LAC     RESP
	ANDL    0X00ff          ;CHECK data ready?
	SAH     RESP

	SBHK    0X04
	BS      ACZ,CidRawData_000_VaildType  ;header=04 single message data format
	SBHK    0x02
	BS      ACZ,CidRawData_000_VaildType  ;header=06
	SBHK    0x7a
	BS      ACZ,CidRawData_000_VaildType  ;header=80 multi-message data format
	SBHK    0x02
	BS      ACZ,CidRawData_000_VaildType  ;header=82
;---invaild data	
	BS	B1,CidRawData_End
CidRawData_000_VaildType:
;---- clear CidBuffer for 32 bytes ----for FSK cid
	LACL	CidBuffer
	SAH	ADDR_D		;the base address that CID data will be store

	LARL	CidBuffer,1
	MAR	+0,1
        LACK    0
        LUPK    31,0
        SAH     +,1
	LACK	0
	SAH	CID_CHKSUM
	SAH	OFFSET_D
	
	LAC	RESP
	CALL	SaveCidData	;stor the format data
	
	LAC	CID_FG
	ANDL	0XFFF0
	ORK	0X0001		;receive FSK length
	SAH	CID_FG	
	
	LACL	2000
	CALL	SET_TIMER0
	
	BS	B1,CidRawData_End
;---------------------------------------------------------------------
CidRawData_100:
	BIT	RESP,12
	BZ	TB,CidRawData_End

	LACL	0x5004
	CALL	DAM_BIOSFUNC

	CALL	SaveCidData	;stor the CID length data
	
	LAC	RESP
	ANDL	0xFF
	ADHK	1
	SAH	CidLength
;---	
	LAC	CID_FG
	ANDL	0XFFF0		;clear first
	SAH	CID_FG
	
	LAC	CidLength
	SBHK	0x40
	BZ	SGN,CidRawData_LenError	;length 
	
	LAC	CID_FG
	ORK	0X0002		;
	SAH	CID_FG	
	
	LACL	2000
	CALL	SET_TIMER0
	
	BS	B1,CidRawData_End
;---------------------------------------------------------------------
CidRawData_200:
	BIT	RESP,12
	BZ	TB,CidRawData_End

	LACL	0x5004
	CALL	DAM_BIOSFUNC
	
	CALL	SaveCidData	;stor the common CID data(include chksum)
	
	LAC	CidLength
	SBHK	1
	SAH	CidLength
	BZ	ACZ,CidRawData_End
;---
	LAC	CID_CHKSUM
	ANDL	0X0FF
	BS	ACZ,CidRawData_OK
	
	BS	B1,CidRawData_Error
;---------------------------------------------------------------------
CidRawData_300:			;DTMF vaild
	
	CALL	DTMF_CHK
	BS	ACZ,CidRawData_End
	SBHK	1
	BS	ACZ,CidRawData_End
	
	LACL	300
	CALL	SET_TIMER0
	
	LAC     DTMF_VAL	;save the DTMF value in DTMF_VAL
	ANDK	0X0F
	CALL	SaveCidData

	LAC	DTMF_VAL	;Get the last DTMF value
	SBHL	0x0FA
	BS	ACZ,CidRawData_000_DTMFS_1	;'A'
	SBHK	0x001
	BS	ACZ,CidRawData_000_DTMFS_1	;'B'
	SBHK	0x001	
	BS	ACZ,CidRawData_302	;'C'
	SBHK	0x001	
	BS	ACZ,CidRawData_000_DTMFS_1	;'D'
	SBHK	0x002
	BS	ACZ,CidRawData_302	;'#'
	BS	B1,CidRawData_End	
CidRawData_302:
	LAC	CID_FG
	ANDL	0XFFF0
	SAH	CID_FG

	CALL	CLR_TIMER0
	
	LACK	2	;DTMF-CID
	
	RET

;---------------------------------------------------------------------
CidRawData_LenError:
CidRawData_Error:
	LAC	CID_FG
	ANDL	0XFFF0
	SAH	CID_FG
	
	CALL	CLR_TIMER0

	LACK	3	;error
	
	RET

;---------------------------------------------------------------------
CidRawData_OK:	
	LAC	CID_FG
	ANDL	0XFFF0
	SAH	CID_FG

	CALL	CLR_TIMER0
	
	LACK	1	;FSK-CID
	
	RET
CidRawData_End:		;no invaild cid/no error
	LACK	0	
	
	RET
;---------------------------------------------------------------------
.ENDIF

;-------------------------------------------------------------------------------
;	Save receiving data into RAM buffer
;	Input : ACCH = DATA, ADDR_D, CID_CHKSUM
;	Output: 
;	Effect: 1, 
;-------------------------------------------------------------------------------
.IF	1
SaveCidData:
	CALL	STORBYTE_DAT
	
	LAC	OFFSET_D
	ADHK	1
	SAH	OFFSET_D
SaveCid_End:
        LAC     RESP
        ADH     CID_CHKSUM
        SAH     CID_CHKSUM

        RET
.ENDIF

;==============================================================================
;	Generate ACK DTMF_D to line
;	Input :
;	
;===============================================================================
.IF	0
Ack_DtmfD:
	LACL	0x48BA		; start tone
	CALL	DAM_BIOSFUNC

	LACL 	1633*8192/1000	; Freq 1, 1633Hz
	CALL	DAM_BIOSFUNC
	LACL 	941*8192/1000	; Freq 2, 941Hz
	CALL	DAM_BIOSFUNC

	LACK	80
	CALL	DELAY

	LACL    0X4400            ; stop tone
	CALL    DAM_BIOSFUNC

	RET
.ENDIF
;-------------------------------------------------------------------------------
;
;-------------------------------------------------------------------------------
.IF	1
MuteLineIn:
	
	RET
.ENDIF
;-------------------------------------------------------------------------------
;
;-------------------------------------------------------------------------------
.IF	1
UnMuteLineIn:
	
	RET
.ENDIF
;-------------------------------------------------------------------------------

.END
	