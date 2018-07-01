
;自定义常数
;---KEY---
;Bit(7..4)/Bit(3..0) = row/col --- (B2_KEY1_VAL..B2_KEY4_VAL)/bit7..0
;----一共28个键
	CKEY_PLY	EQU	0X10	;Play/Pause
	CKEY_OGM	EQU	0X11	;OGM
	CKEY_MMO	EQU	0X12	;MEMO
	CKEY_STP	EQU	0X13	;Stop
	CKEY_PBK	EQU	0X14	;Phonebook
	CKEY_1M		EQU	0X15	;M1
	CKEY_2M		EQU	0X16	;M2
	CKEY_3M		EQU	0X17	;M3
	
	CKEY_MNU	EQU	0X20	;Menu
	CKEY_UP		EQU	0X21	;Up
	CKEY_DWN	EQU	0X22	;Down
	CKEY_DEL	EQU	0X23	;Delete
	CKEY_MTE	EQU	0X24	;MUTE
	CKEY_FLS	EQU	0X25	;Flash
	CKEY_RP		EQU	0X26	;Pause/Redial
	CKEY_SPK	EQU	0X27	;SPK

	CKEY_3		EQU	0X30	;'3'
	CKEY_6		EQU	0X31	;'6'
	CKEY_9		EQU	0X32	;'9'
	CKEY_F		EQU	0X33	;'#'
	CKEY_2		EQU	0X34	;'2'
	CKEY_5		EQU	0X35	;'5'
	CKEY_8		EQU	0X36	;'8'
	CKEY_0		EQU	0X37	;'0'
	
	CKEY_1		EQU	0X40	;'1'
	CKEY_4		EQU	0X41	;'4'
	CKEY_7		EQU	0X42	;'7'
	CKEY_E		EQU	0X43	;'*'
;---------------------------------------
	CMSG_MKEY	EQU	0X80
	CMSG_BKEY	EQU	0X81
	CMSG_CKEY	EQU	0X82
	CSEG_END	EQU	0X83
	CBEEP_END	EQU	0X84
	CVP_END		EQU	0X85	;All VP in VP-queue have been play
	CREC_FULL	EQU	0X86	
	
	CMSG_VOX	EQU	0X87
	CMSG_BTONE	EQU	0X88	
	CMSG_CTONE	EQU	0X89	
	CREV_DTMF	EQU	0X8A	
	CMSG_CPC	EQU	0X8B	
	CMSG_RTC	EQU	0X8F	;Time/Date display update
	
	CMSG_INIT	EQU	0X90	;初始化
	CMSG_EXIT	EQU	0X91
	CHOOK_ON	EQU	0X92	;手柄挂机
	CHOOK_OFF	EQU	0X93	;手柄提机
	CPHONE_ON	EQU	0X94	;免提开
	CPHONE_OFF	EQU	0X95	;免提关
	
	CKEY_NUM	EQU	0X96	;idle时有数字键按下

	CMSG_TMR2	EQU	0X97	;定时器
	CMSG_TMR	EQU	0X98	;定时器
	CMSG_BLINK	EQU	0X99	;时钟闪烁
	CRING_ON	EQU	0X9A	;Ring on
	CRING_OFF	EQU	0X9B	;Ring off
	CRING_OK	EQU	0X9C	;时钟闪烁
	CRING_FAIL	EQU	0X9D	;有未接来铃
	
                                  
	CMSG_DTMF	EQU	0XA1	;Received dtmf消息
	CTMR_DTMF	EQU	0XA2	;
	CMSG_FSK	EQU	0XA3
	
	CCID_EDIT	EQU	0XA4	;Edit CID
	CDIAL_OUT	EQU	0XA5	;Dial the displayed tel-num 
	
	CLOOK_DIAL	EQU	0XA6	;Lookup dialled num
	CUPDT_MENU	EQU	0XA7	;Exit Menu,DAM-on/off,OGM-sel
	CPOWER_ON	EQU	0XA8	;Power on
;-------------------------------------------------------------------------------
	CREC_OGM	EQU	0XC0
	CPLY_OGM	EQU	0XC1
	CREC_MMO	EQU	0XC2
	CPLY_MSG	EQU	0XC3
	CDEL_ALL	EQU	0XC4
	CSTOR_NUM	EQU	0XC5
	CLOOK_NUM	EQU	0XC6
	CSEL_OGM	EQU	0XC7	;select OGM
	CSEL_ONOFF	EQU	0XC8	;select on/off
	CMSG_ANS	EQU	0XC9	;answer start
	CRMT_OK		EQU	0XCA
	
	CMSG_MENU	EQU	0XCB
	CMSG_BOOK	EQU	0XCC
	
	CRDY_CID	EQU	0XCD	;极性反转(准备收CID)
	CLOOK_CID	EQU	0XCE	;lookup CID
	CMSG_CID	EQU	0XCF	;new CID receive and cooked

	
;-------------------------------------------------------------------------------
;---VP识别码(Note: this identify code is related to the table of VP_START)
ID_IDLE		EQU	0X0	;Rreserved
ID_DELAY	EQU	0X1	;delay
ID_BEEP		EQU	0X2	;BEEP
ID_DTMF		EQU	0X3	;DTMF
ID_VOP		EQU	0X4	;VOP
ID_PLYN		EQU	0X5	;play new message(MSG_ID is related to new messages)
ID_PLYA		EQU	0X6	;play all message(MSG_ID is related to total messages)
ID_PLYO		EQU	0X7	;play old message(...)
;-------------------------------------------------------------------------------
;显示
NUM_0	==	0X10
NUM_1	==	0X11
NUM_2	==	0X12
NUM_3	==	0X13
NUM_4	==	0X14
NUM_5	==	0X15
NUM_6	==	0X16
NUM_7	==	0X17
NUM_8	==	0X18
NUM_9	==	0X19
NUM_A	==	0X21
NUM_B	==	0X22
NUM_C	==	0X23
NUM_D	==	0X24
NUM_E	==	0X25
NUM_F	==	0X26
NUM_P		==	0X60
NUM_BLANK	==	0
NUM_XIN	==	0X0A
NUM_JIN	==	0X03
NUM_AMPERE	==	0X0D	;-
NUM__	==	0X3F		;_
NUM_END	==	0XFF	; 结束标志符

CH_0	==	NUM_0
CH_1	==	NUM_1
CH_2	==	NUM_2
CH_3	==	NUM_3
CH_4	==	NUM_4
CH_5	==	NUM_5
CH_6	==	NUM_6
CH_7	==	NUM_7
CH_8	==	NUM_8
CH_9	==	NUM_9

CH_A	==	NUM_A
CH_B	==	NUM_B
CH_C	==	NUM_C
CH_D	==	NUM_D
CH_E	==	0X25
CH_F	==	0X26
CH_G	==	0X27
CH_H	==	0X28
CH_I	==	0X29
CH_J	==	0X2A
CH_K	==	0X2B
CH_L	==	0X2C
CH_M	==	0X2D
CH_N	==	0X2E
CH_O	==	0X2F
CH_P	==	0X30
CH_Q	==	0X31
CH_R	==	0X32
CH_S	==	0X33
CH_T	==	0X34
CH_U	==	0X35
CH_V	==	0X36
CH_W	==	0X37
CH_X	==	0X38
CH_Y	==	0X39
CH_Z	==	0X3A

CH_BLANK	==	0X0
CH_EXC		==	0X01	; !
CH_JIN		==	0X03	; #
CH_LEFTB 	==	0X08	; (	left-bracket
CH_RIGHTB 	==	0X09	; )	right-bracket
CH_XIN		==	0X0A	; *	
CH_COMMA	==	0X0C	; ,
CH_AMPERE	==	0X0D	; -
CH_DOT	==		0X0E	; .
CH_SCH1		==	0X0F	; /

CH_COLON	==	0X1A	; :
CH_INTE		==	0X1F	; ?

CH__		==	0X3F	; _
CH_UP		==	0X61	;向上
CH_DOWN		==	0X62	;向下

CH_END	==	NUM_END	; 结束标志符

CNumDelta ==	0x10	;数值与机内码之差
CASCDelta ==	0x20	;机内码与ASCII码之差
;-------------------------------------------------------------------------------
ID_BLANK	==	200
;-------------------------------------------------------------------------------
