.LIST
;---------------------------------------空闲状态要考虑的消息
LOCAL_PRO:
	LAC	PRO_VAR
	ANDL	0X0F
	BS	ACZ,LOCAL_PRO_0	;(0Xyyy0)idle
	SBHK	1
	BS	ACZ,LOCAL_PRO_1	;(0Xyyy1)reserved
	
	RET
LOCAL_PRO_0:
	LAC	MSG
	XORL	CMSG_INIT		;INITIAL
	BS	ACZ,MAIN_PRO0_INIT
;---
;LOCAL_PRO_0_1:
	LAC	MSG
	XORL	CMSG_KEY1S
	BS	ACZ,MAIN_PRO0_NEWVP_BVOP
	LAC	MSG
	XORL	CMSG_KEY1L
	BS	ACZ,MAIN_PRO0_RECO_MSG
;---
;LOCAL_PRO_0_2:
	LAC	MSG
	XORL	CMSG_KEY2S
	BS	ACZ,MAIN_PRO0_OGM
	LAC	MSG
	XORL	CMSG_KEY2L
	BS	ACZ,MAIN_PRO0_OGM
;---
;LOCAL_PRO_0_3:
	;LAC	MSG
	;XORL	CMSG_KEY3S
	;BS	ACZ,MAIN_PRO0_TIME
;---
;LOCAL_PRO_0_4:
	LAC	MSG
	XORL	CMSG_KEY4S
	BS	ACZ,MAIN_PRO0_PLAY	;play
	LAC	MSG
	XORL	CMSG_KEY4L
	BS	ACZ,MAIN_PRO0_2WAY	;TWO_WAY record(1160 has no 2-way record )
;---
;LOCAL_PRO_0_5:
;---
;LOCAL_PRO_0_6:
	;LAC	MSG
	;XORL	CMSG_KEY6L
	;BS	ACZ,MAIN_PRO0_MBOX
	;LAC	MSG
	;XORL	CMSG_KEY6S
	;BS	ACZ,MAIN_PRO0_MBOX
;---
;LOCAL_PRO_0_7:
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,MAIN_PRO0_ONOFF_EXIT
	LAC	MSG
	XORL	CMSG_KEY7L
	BS	ACZ,MAIN_PRO0_FORMAT
;---
;LOCAL_PRO_0_8:
	LAC	MSG
	XORL	CMSG_KEY8L
	BS	ACZ,MAIN_PRO0_ERAS_MSG
;---
;LOCAL_PRO_0_9:
;---
;LOCAL_PRO_0_10:
	LAC	MSG
	XORL	CMSG_KEYAS
	BS	ACZ,MAIN_PRO0_INCOMECALL
	LAC	MSG
	XORL	CMSG_CID
	BS	ACZ,MAIN_PRO0_INCOMECALL	;Received new CID
;---
;LOCAL_PRO_0_11:
	LAC	MSG
	XORL	CMSG_KEYBD
	BS	ACZ,MAIN_PRO0_VOL
	;LAC	MSG
	;XORL	CMSG_KEYBP
	;BS	ACZ,MAIN_PRO0_VOL
;---
;LOCAL_PRO_0_12:
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO0_SMENU
	LAC	MSG
	XORL	CMSG_KEYCL
	BS	ACZ,MAIN_PRO0_LMENU
;---
;LOCAL_PRO_0_13:
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,MAIN_PRO0_TMR
;---
;LOCAL_PRO_0_14:	
	LAC	MSG
	XORL	CVP_STOP		;PLAY END
	BS	ACZ,MAIN_PRO0_INIT
;-----------------------------
;LOCAL_PRO_0_15:
	LAC	MSG
	XORL	CMENU_TIME		;Set menu time
	BS	ACZ,MAIN_PRO0_MTIME
;LOCAL_PRO_0_15:
	LAC	MSG
	XORL	CMENU_CTRT		;Set menu contrast
	BS	ACZ,MAIN_PRO0_MCTRT
;LOCAL_PRO_0_15:
	LAC	MSG
	XORL	CMENU_PSWD		;Set menu PSWORD
	BS	ACZ,MAIN_PRO0_MPSWD
;LOCAL_PRO_0_15:
	LAC	MSG
	XORL	CMENU_LCOD		;Set menu local-code
	BS	ACZ,MAIN_PRO0_MLCOD
;LOCAL_PRO_0_15:
	LAC	MSG
	XORL	CMENU_RCNT		;Set menu ring-count
	BS	ACZ,MAIN_PRO0_MRCNT
;LOCAL_PRO_0_15:
	LAC	MSG
	XORL	CMENU_OGMC		;Set menu OGM
	BS	ACZ,MAIN_PRO0_MOGMC

	LAC	MSG
	XORL	CMSG_KEY3L
	BS	ACZ,MAIN_PRO0_PHONEBOOK	;Phonebook(It's the filter book)
;-----------------------------
;LOCAL_PRO_0_15:
	LAC	MSG
	XORL	CBOOK_FLT
	BS	ACZ,MAIN_PRO0_SELECTBOOK
	LAC	MSG
	XORL	CBOOK_SLET
	BS	ACZ,MAIN_PRO0_SELECTBOOK
	LAC	MSG
	XORL	CSTOR_TYPE	;Going to select TEL type(Normal/VIP/Filter)
	BS	ACZ,MAIN_PRO0_SELECTTYPE
;LOCAL_PRO_0_15:
	LAC	MSG
	XORL	CNUMB_EDIT	;phone-book edit(edit number)Lookup phone-number and edit it
	BS	ACZ,MAIN_PRO0_EDITBOOKNUMB	;(f_book1 ==> f_book3)
;LOCAL_PRO_0_15:
	LAC	MSG
	XORL	CNAME_EDIT	;phone-book edit(edit name)Add phone-number end and find same number as current number
	BS	ACZ,MAIN_PRO0_EDITBOOKNAME	;(F_book2 ==> f_book3)
;LOCAL_PRO_0_15:
	LAC	MSG
	XORL	CNUMB_BADD	;phone-book Add(add phone-number)
	BS	ACZ,MAIN_PRO0_BADDBOOKNUMB	;(f_book1 ==> f_book2)
;LOCAL_PRO_0_15:
	LAC	MSG
	XORL	CNUMB_ECID
	BS	ACZ,MAIN_PRO0_EDITCIDNUMB	;(f_cid ==> f_book4)
;-----------------------------
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,MAIN_PRO0_BLEDON
	LAC	MSG
	XORL	CMSG_KEY1S
	BS	ACZ,MAIN_PRO0_BLEDON
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,MAIN_PRO0_BLEDON
	
	RET

;-------------------------------;消息处理
LOCAL_PRO_1:

	RET
;---------------------------------------
MAIN_PRO0_INIT:
	CALL	INIT_DAM_FUNC
	CALL	HOOK_OFF
	CALL	DAA_OFF		;要考虑加入的功能(11.18)

	LACK	0
	SAH	PRO_VAR1
	LACL	CTMR1S
	CALL	SET_TIMER	;进入待机计时

	CALL	VPMSG_CHK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	SEND_MSGNUM	;录音数量同步(4bytes)
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X0FF
	CALL	SEND_DAT

	RET
;---------------------------------------
MAIN_PRO0_PLAY:	
	CALL	INIT_DAM_FUNC

	CALL	CLR_FUNC	;先空
    	LACL	LOCAL_PROPLY
     	CALL	PUSH_FUNC     	
     	LACK	0
     	SAH	PRO_VAR
     	
     	LAC	MSG
     	CALL	STOR_MSG
;-------
	LACL	FlashLoc_H_f_play
	ADLL	FlashLoc_L_f_play
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_play
	ADLL	CodeSize_f_play
	CALL	LoadHostCode
;-------
	RET

;---------------------------------------
MAIN_PRO0_2WAY:
.if	1
	CALL	INIT_DAM_FUNC
	
	CALL	CLR_FUNC	;先空
    	LACL	TWAY_STATE
     	CALL	PUSH_FUNC     	
     	LACK	0
     	SAH	PRO_VAR
     	
     	LAC	MSG
     	CALL	STOR_MSG
;-------
	LACL	FlashLoc_H_f_2way
	ADLL	FlashLoc_L_f_2way
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_2way
	ADLL	CodeSize_f_2way
	CALL	LoadHostCode
;-------
.endif
	RET
;---------------------------------------
MAIN_PRO0_OGM:
	CALL	INIT_DAM_FUNC

	CALL	CLR_FUNC	;先空
    	LACL	LOCAL_PROOGM
     	CALL	PUSH_FUNC     	
     	LACK	0
     	SAH	PRO_VAR
     	
     	LAC	MSG
     	CALL	STOR_MSG
;-------
	LACL	FlashLoc_H_f_ogm
	ADLL	FlashLoc_L_f_ogm
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_ogm
	ADLL	CodeSize_f_ogm
	CALL	LoadHostCode
;-------
	RET
;---------------------------------------
MAIN_PRO0_NEWVP_BVOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BLED_ON
	
	LAC	VOI_ATT
	XORL	0X8000
	SAH	VOI_ATT
	
	BIT	VOI_ATT,15
	BS	TB,MAIN_PRO0_NEWVP_LBVOP
	
	CALL	BEEP

	RET
MAIN_PRO0_NEWVP_LBVOP:
	CALL	LBEEP

	RET	
;---------------------------------------	
MAIN_PRO0_RECO_MSG:
	CALL	INIT_DAM_FUNC

	CALL	CLR_FUNC	;先空
    	LACL	LOCAL_PROMEM
     	CALL	PUSH_FUNC     	
     	LACK	0
     	SAH	PRO_VAR
     	
     	LAC	MSG
     	CALL	STOR_MSG
;-------
	LACL	FlashLoc_H_f_memo
	ADLL	FlashLoc_L_f_memo
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_memo
	ADLL	CodeSize_f_memo
	CALL	LoadHostCode
;-------	
	RET
;---------------------------------------
MAIN_PRO0_ERAS_MSG:
MAIN_PRO0_FORMAT:
MAIN_PRO0_ONOFF:
MAIN_PRO0_MBOX:
MAIN_PRO0_VOL:
MAIN_PRO0_TIME:
	CALL	INIT_DAM_FUNC

	CALL	CLR_FUNC	;先空
    	LACL	LOCAL_PROFIXF
     	CALL	PUSH_FUNC     	
     	LACK	0
     	SAH	PRO_VAR
     	
     	LAC	MSG
     	CALL	STOR_MSG
;-------
	LACL	FlashLoc_H_f_fixf
	ADLL	FlashLoc_L_f_fixf
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_fixf
	ADLL	CodeSize_f_fixf
	CALL	LoadHostCode
;-------	
	RET
;---------------------------------------
MAIN_PRO0_ONOFF_EXIT:
	CALL	BLED_ON
	LAC	MBOX_ID
	SBHK	1
	BZ	ACZ,MAIN_PRO0_EXIT
	
	BS	B1,MAIN_PRO0_ONOFF
	
MAIN_PRO0_EXIT:		;在私人信箱里工作后退回,若没有回到公共信箱则按下ON/OFF键时先回到公共信箱

	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP		;BEEP
	
	LACK	1
	SAH	MBOX_ID
	
	RET
;-------

;---------------------------------------
MAIN_PRO0_PHONEBOOK:
     	LACL	CMSG_KEY3L
     	SAH	MSG
	;BS	B1,MAIN_PRO0_LOOKBOOK
;---------------------------------------
MAIN_PRO0_SELECTBOOK:
MAIN_PRO0_SELECTTYPE:
MAIN_PRO0_LOOKBOOK:
	CALL	INIT_DAM_FUNC

	CALL	CLR_FUNC	;先空
    	LACL	LOCAL_PROBOOK1
     	CALL	PUSH_FUNC     	
     	LACK	0
     	SAH	PRO_VAR
     	
     	LAC	MSG
     	CALL	STOR_MSG
;-------
	LACL	FlashLoc_H_f_book1
	ADLL	FlashLoc_L_f_book1
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_book1
	ADLL	CodeSize_f_book1
	CALL	LoadHostCode
;-------
	RET
;---------------------------------------
MAIN_PRO0_EDITBOOKNAME:
MAIN_PRO0_EDITBOOKNUMB:
	CALL	INIT_DAM_FUNC

	CALL	CLR_FUNC	;先空
    	LACL	LOCAL_PROBOOK3
     	CALL	PUSH_FUNC     	
     	LACK	0
     	SAH	PRO_VAR
     	
	LAC	MSG
     	CALL	STOR_MSG
;-------
	LACL	FlashLoc_H_f_book3
	ADLL	FlashLoc_L_f_book3
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_book3
	ADLL	CodeSize_f_book3
	CALL	LoadHostCode
;-------	
	RET
;---------------------------------------
MAIN_PRO0_BADDBOOKNUMB:
.if	1
	CALL	INIT_DAM_FUNC

	CALL	CLR_FUNC	;先空
    	LACL	LOCAL_PROBOOK2
     	CALL	PUSH_FUNC     	
     	LACK	0
     	SAH	PRO_VAR
     	
     	LAC	MSG
     	CALL	STOR_MSG
;-------
	LACL	FlashLoc_H_f_book2
	ADLL	FlashLoc_L_f_book2
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_book2
	ADLL	CodeSize_f_book2
	CALL	LoadHostCode
;-------	
.else
	CALL	INIT_DAM_FUNC
	call	DAA_SPK
	CALL	LBEEP
	CALL	BEEP
.endif
	RET
;---------------------------------------
MAIN_PRO0_EDITCIDNUMB:
	CALL	INIT_DAM_FUNC

	CALL	CLR_FUNC	;先空
    	LACL	LOCAL_PROBOOK4
     	CALL	PUSH_FUNC     	
     	LACK	0
     	SAH	PRO_VAR
     	
     	LAC	MSG
     	CALL	STOR_MSG
;-------
	LACL	FlashLoc_H_f_book4
	ADLL	FlashLoc_L_f_book4
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_book4
	ADLL	CodeSize_f_book4
	CALL	LoadHostCode
;-------
	RET
;---------------------------------------
MAIN_PRO0_SMENU:
	BIT	VOP_FG,15		;Adjust Menu ?
	BS	TB,MAIN_PRO0_SMENU_END
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BLED_ON	
	
	LAC	VOI_ATT
	XORL	1<<14
	;ORL	1<<14
	SAH	VOI_ATT
	
	BIT	VOI_ATT,14
	BS	TB,MAIN_PRO0_SMENU_BEEP
	
	CALL	BEEP
MAIN_PRO0_SMENU_END:	
	RET
MAIN_PRO0_SMENU_BEEP:
	
	CALL	LBEEP
	BS	B1,MAIN_PRO0_SMENU_END
;---------------------------------------

MAIN_PRO0_LMENU:		;INITIAL(PRO_VAR=0X0009)
	CALL	INIT_DAM_FUNC

	CALL	CLR_FUNC	;先空
    	LACL	LOCAL_PROMENU1
     	CALL	PUSH_FUNC     	
     	LACK	0
     	SAH	PRO_VAR
     	
     	LACL	CMENU_LGGE
     	CALL	STOR_MSG
;-------
	LACL	FlashLoc_H_f_menu1
	ADLL	FlashLoc_L_f_menu1
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_menu1
	ADLL	CodeSize_f_menu1
	CALL	LoadHostCode
;-------	
	RET
;---------------------------------------
MAIN_PRO0_MTIME:
	CALL	INIT_DAM_FUNC

	CALL	CLR_FUNC	;先空
    	LACL	LOCAL_PROMENU2
     	CALL	PUSH_FUNC     	
     	LACK	0
     	SAH	PRO_VAR
     	
     	LAC	MSG
     	CALL	STOR_MSG
;-------
	LACL	FlashLoc_H_f_menu2
	ADLL	FlashLoc_L_f_menu2
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_menu2
	ADLL	CodeSize_f_menu2
	CALL	LoadHostCode
;-------	
	RET
;---------------------------------------
MAIN_PRO0_MCTRT:
	CALL	INIT_DAM_FUNC

	CALL	CLR_FUNC	;先空
    	LACL	LOCAL_PROMENU3
     	CALL	PUSH_FUNC     	
     	LACK	0
     	SAH	PRO_VAR
     	
     	LAC	MSG
     	CALL	STOR_MSG
;-------
	LACL	FlashLoc_H_f_menu3
	ADLL	FlashLoc_L_f_menu3
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_menu3
	ADLL	CodeSize_f_menu3
	CALL	LoadHostCode
;-------	
	RET
;---------------------------------------
MAIN_PRO0_MPSWD:
	CALL	INIT_DAM_FUNC

	CALL	CLR_FUNC	;先空
    	LACL	LOCAL_PROMENU4
     	CALL	PUSH_FUNC     	
     	LACK	0
     	SAH	PRO_VAR
     	
     	LAC	MSG
     	CALL	STOR_MSG
;-------
	LACL	FlashLoc_H_f_menu4
	ADLL	FlashLoc_L_f_menu4
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_menu4
	ADLL	CodeSize_f_menu4
	CALL	LoadHostCode
;-------	
	RET
;---------------------------------------
MAIN_PRO0_MLCOD:
	CALL	INIT_DAM_FUNC

	CALL	CLR_FUNC	;先空
    	LACL	LOCAL_PROMENU5
     	CALL	PUSH_FUNC     	
     	LACK	0
     	SAH	PRO_VAR
     	
     	LAC	MSG
     	CALL	STOR_MSG
;-------
	LACL	FlashLoc_H_f_menu5
	ADLL	FlashLoc_L_f_menu5
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_menu5
	ADLL	CodeSize_f_menu5
	CALL	LoadHostCode
;-------	
	RET
;---------------------------------------
MAIN_PRO0_MRCNT:
	CALL	INIT_DAM_FUNC

	CALL	CLR_FUNC	;先空
    	LACL	LOCAL_PROMENU6
     	CALL	PUSH_FUNC     	
     	LACK	0
     	SAH	PRO_VAR
     	
     	LAC	MSG
     	CALL	STOR_MSG
;-------
	LACL	FlashLoc_H_f_menu6
	ADLL	FlashLoc_L_f_menu6
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_menu6
	ADLL	CodeSize_f_menu6
	CALL	LoadHostCode
;-------	
	RET
;---------------------------------------
MAIN_PRO0_MOGMC:
	CALL	INIT_DAM_FUNC

	CALL	CLR_FUNC	;先空
    	LACL	LOCAL_PROMENU7
     	CALL	PUSH_FUNC     	
     	LACK	0
     	SAH	PRO_VAR
     	
     	LAC	MSG
     	CALL	STOR_MSG
;-------
	LACL	FlashLoc_H_f_menu7
	ADLL	FlashLoc_L_f_menu7
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_menu7
	ADLL	CodeSize_f_menu7
	CALL	LoadHostCode
;-------	
	RET
;-------------------------------------------------------------------------------
MAIN_PRO0_TMR:
	
	LAC	EVENT			;Check if in 0x1000/0x2000/0x4800/0xb000 mode or not
	ANDL	0XF0
	BZ	ACZ,MAIN_PRO0_TMR_0
	
	CALL	DATETIME_CHK
MAIN_PRO0_TMR_0:
		
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	3
	BS	ACZ,MAIN_PRO0_TMR_3s
	SBHK	7
	BS	ACZ,MAIN_PRO0_TMR_10s
	SBHK	50
	BS	ACZ,MAIN_PRO0_TMR_60s
	
MAIN_PRO0_TMR_END:	
	RET
;---------------
MAIN_PRO0_TMR_3s:
	;CRAM	ANN_FG,2	;防止收CID出错而屏蔽按键而导致死机
	
	RET
;---------------
MAIN_PRO0_TMR_10s:
	;CALL	CLR_TIMER
	CALL	BLED_OFF
	
;	LAC	MBOX_ID
;	SBHK	1
;	BS	ACZ,MAIN_PRO0_TMR_END
;	
;	LACK	1
;	SAH	MBOX_ID
;
;	LACL	CMSG_KEY6S
;	CALL	STOR_MSG
;	
	RET

;---------------
MAIN_PRO0_TMR_60s:
	LAC	ANN_FG
	ANDL	0X00E0
	BZ	ACZ,MAIN_PRO0_TMR_BEEPVP
	
	BIT	VOP_FG,14	;Check New VIP-CID exist
	BZ	TB,MAIN_PRO0_TMR_END
	
MAIN_PRO0_TMR_BEEPVP:
;---New ICM VP exist

	BIT	VOI_ATT,15	;Check BeepPrompt-bitflag	
	BZ	TB,MAIN_PRO0_TMR_END
	
	CALL	DAA_SPK	
	CALL	BEEP		;New message exist Beep every 1 minute
	
	RET
;-------------------------------------------------------------------------------
MAIN_PRO0_BLEDON:
	CALL	BLED_ON
	
	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER	;重进入待机计时

	RET
;-------------------------------------------------------------------------------
MAIN_PRO0_INCOMECALL:
	CALL	INIT_DAM_FUNC

	CALL	CLR_FUNC	;先空
    	LACL	LOCAL_PROCID
     	CALL	PUSH_FUNC     	
     	LACK	0
     	SAH	PRO_VAR
     	
     	LAC	MSG
     	CALL	STOR_MSG
;-------
	LACL	FlashLoc_H_f_cid
	ADLL	FlashLoc_L_f_cid
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_cid
	ADLL	CodeSize_f_cid
	CALL	LoadHostCode
;-------	
	RET

;=========================================================================
	
.END

