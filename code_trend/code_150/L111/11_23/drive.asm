;------------------------------------------------------------
;	manage message when a FFW_key pressed during playing
;	NEW1,NEW2,NEW3,NEW4,NEW5,NEW6,NEW7(new message exist)
;	to check which message you should play
;	input : MSG_ID(mapping the message you play just)
;		MSG_T(MSG_N)---the number of total message
;	output: ACCH=0---MSG_ID(mapping the message you will play next)
;		ACCH=1---fail
;------------------------------------------------------------
FFW_MANAGE:
	LAC	MSG_ID
	SAH	MSG_N
		
FFW_MANAGE1:		
	CALL	GET_NEWFLAG
	BZ	ACZ,FFW_MANAGE2
	LACK	0
	RET
FFW_MANAGE2:
	LAC	MSG_ID
	ADHK	1
	SAH	MSG_ID
	ANDL	0X0FF
	SBH	MSG_T
	BS	ACZ,FFW_MANAGE
	BS	SGN,FFW_MANAGE
FFW_MANAGE3:
	LAC	MSG_N
	ANDL	0X0FF
	SBH	MSG_T
	BS	ACZ,FFW_MANAGE4
	
	LAC	MSG_N
	SBHK	1
	SAH	MSG_ID
	BS	B1,FFW_MANAGE5
FFW_MANAGE4:		
	LAC	MSG_N
	SAH	MSG_ID
FFW_MANAGE5:		
	LACK	1
	RET
	
;------------------------------------------------------------
;	manage message when a REW_key pressed during playing
;	NEW1,NEW2,NEW3,NEW4,NEW5,NEW6,NEW7(new message exist)
;	to check which message you should play
;	input : MSG_ID(mapping the message you play just)
;
;	output: ACCH=0---MSG_ID(mapping the message you will play next)
;		ACCH=1---fail
;------------------------------------------------------------
REW_MANAGE:
	
	LAC	MSG_ID
	SAH	MSG_N
REW_MANAGE1:
	CALL	GET_NEWFLAG
	BS	ACZ,REW_MANAGE4

	LAC	MSG_ID
	SBHK	1
	SAH	MSG_ID
	ANDL	0X0FF
	BZ	ACZ,REW_MANAGE1
;-------
	LAC	MSG_N
	ANDL	0X0FF
	SBHK	1
	BZ	ACZ,REW_MANAGE2
	LAC	MSG_N
	ANDL	0XFF00
	ORK	1
	BS	B1,REW_MANAGE3
REW_MANAGE2:
	LAC	MSG_N
	ADHK	1
REW_MANAGE3:
	SAH	MSG_ID	
	LACK	1
	BS	B1,REW_MANAGE_END
REW_MANAGE4:
	LACK	0
REW_MANAGE_END:
	
	RET
;-------------------------------------------------------------------------------
;	DEFOGM_LOCALPLY
;	check weather the current OGM_ID
;	input : ACCH = 	OGMx
;			EVENT.8
;	output: ACCH = 	OGMx
;
;-------------------------------------------------------------------------------
DEFOGM_LOCALPLY:
	CALL	GET_OGMID
	SBHK	5
	BS	ACZ,DEFOGM_LOCALPLY2
DEFOGM_LOCALPLY1:
	CALL	VP_DEFAULTOGM
	RET
DEFOGM_LOCALPLY2:
	CALL	VP_DEFOGM5		
	RET
;-------------------------------------------------------------------------------
;	GET_OGMID
;	check weather the current OGM_ID
;	input : ACCH = 	OGMx
;			EVENT.8
;	output: ACCH = 	OGMx
;
;-------------------------------------------------------------------------------
GET_OGMID:
	SAH	SYSTMP1
	
	BIT	EVENT,8		;answer only?
	BZ	TB,GET_OGMID_END
	
	LACK	5
	SAH	SYSTMP1
GET_OGMID_END:
	LAC	SYSTMP1

	RET
;-------------------------------------------------------------------------------
;	OGM_SELECT
;	check weather the current OGMx exist?
;	input : ACCH = (OGMx)&(EVENT.8)
;	output: ACCH = 1/0 --- no OGM/the OGM exist
;
;		MSG_ID		= index NO.in current MBOX in current MSG type(OGM)
;		MSG_N = 1/2	= the current OGM index(USR INDEX DATA0)
;
;-------------------------------------------------------------------------------
OGM_SELECT:			;用于录音/放音时确定OGM_ID(非接线时用)

	CALL	GET_OGMID
	SAH	MSG_N
	CALL	OGM_STATUS1
	
	RET
;-------------------------------------------------------------------------------
;	OGM_STATUS
;	check weather the current OGMx exist?
;	input : EVENT.8		= 0/1---answer ICM/answer only
;		EVENT.9		= 0/1---answer on/off
;		ANN_FG.13	= 0/1---not/memoful
;		VOI_ATT(11..8)
;	output: ACCH = 1/0 --- no OGM/the OGM exist
;
;		MSG_ID		= index NO.in current MBOX in current MSG type(OGM)
;		MSG_N = 1+100/2+100/3+100/4+100/5+100 = the current OGM index(USR INDEX DATA0)
;-------------------------------------------------------------------------------
OGM_STATUS:			;接线时用
	LAC	VOI_ATT
	SFR	8
	ANDK	0X0F
	SAH	MSG_N
	
	LAC	VOI_ATT		;answer only?
	SFR	8
	ANDK	0X0F
	SBHK	5
	BS	ACZ,OGM_STATUS0
	BIT	EVENT,8		;answer only?
	BS	TB,OGM_STATUS0
	BIT	EVENT,9		;answer off?
	BS	TB,OGM_STATUS0
	BIT	ANN_FG,13	;memoful?
	BS	TB,OGM_STATUS0
	BS	B1,OGM_STATUS1
OGM_STATUS0:	
	LACK	5
	SAH	MSG_N		;answer only(OGM5)
OGM_STATUS1:
	LACL	0XD000
	SAH	CONF
	CALL	DAM_BIOS
	LACL	0XD202
	SAH	CONF
	CALL	DAM_BIOS
	
	LACL	0X3000
	SAH	CONF
	CALL	DAM_BIOS
	LAC	RESP
	SAH	MSG_ID
OGM_STATUS2:	
	LAC	MSG_ID
	BS	ACZ,OGM_STATUS4
	ORL	0XA900            	;check if OGMx exists(GET USER INDEX DATA0)?
        SAH     CONF
        CALL    DAM_BIOS
        LAC     RESP			;LOAD USER ID(MSG_N)
        SBH	MSG_N
        SBHK	100
        BS      ACZ,OGM_STATUS3		;OGMx exist?
        
	LAC	MSG_ID
	SBHK	1
	SAH	MSG_ID
	BS	B1,OGM_STATUS2
OGM_STATUS3:
        LACK	0			;OGMx exist
        RET
OGM_STATUS4:
	LACK	1			;no OGM
	RET
;----------------------------------------------------------------------------
;       Function : PSWORD_CHK
;       Password check
;	Input  : ACCH = VALUE(DTMF_VAL)
;       Output : ACCH = 0 - password in ok
;                       1 - password for mailbox 1
;                       2 - password for mailbox 2
;                       3 - password for mailbox 3
;                       0XFF - password fail
;-------------------------------------------------------------------------------
PSWORD_CHK:
        SAH	SYSTMP0
PSWORD_CHK1:
        LAC     PSWORD_TMP
        SFL     4
	OR	SYSTMP0
        SAH     PSWORD_TMP        ; PSWORD_TMP keep the new input digit string
;-------------------------------------------------------------------------------
        LAC     PSWORD_TMP
        ANDL    0X0FFF
        SBH     PASSWORD
        BS      ACZ,PSWORD_IN_OK
;---
        LAC     PSWORD_TMP
        XORL	0XF1F
        ANDL	0X0FFF
        BS      ACZ,PSWORD_MBOX1_OK
;---
        LAC     PSWORD_TMP
        XORL	0XF2F
        ANDL	0X0FFF
        BS      ACZ,PSWORD_MBOX2_OK
;---
        LAC     PSWORD_TMP
        XORL	0XF3F
        ANDL	0X0FFF
        BS      ACZ,PSWORD_MBOX3_OK

PSWORD_NOT_IN:		;the intput not digital or wrong remote access code
        LACL    0XFF
        RET	
PSWORD_IN_OK:
	LACK	0
        RET
PSWORD_MBOX1_OK:
	LACK	1
	RET
PSWORD_MBOX2_OK:
	LACK	2
	RET
PSWORD_MBOX3_OK:
	LACK	3
	RET
;------------------------------------------------------------------------------
;	Function : GET_LANGUAGE attribute
;	input : no
;	output: ACCH = 当前语言值
;------------------------------------------------------------------------------
GET_LANGUAGE:
	LAC	VOI_ATT
	SFR	12
	ANDK	0X03
	
	RET
;------------------------------------------------------------------------------
;	Function : GET_TIMEFAT attribute
;	input : no
;	output: ACCH = 时间格式
;------------------------------------------------------------------------------
GET_TIMEFAT:
	LAC	EVENT
	SFR	11
	ANDK	0X1
	
	RET
;//----------------------------------------------------------------------------
;//       Function : MSG_WEEK/MSG_GWEEK
;//
;//       Generate a VP
;//----------------------------------------------------------------------------
MSG_WEEK:	;for English
	LAC	MSG_ID
	ANDL	0X0FF
	ORL	0XA300
	SAH	CONF
	CALL	DAM_BIOS

	CALL	GET_LANGUAGE
	BZ	ACZ,MSG_GWEEK
	
	LAC	RESP
	ADHK	28
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
;---------------
MSG_GWEEK:	;for German
	LAC	RESP
	ADHK	92			;92 = 28+64
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
;//----------------------------------------------------------------------------
;//       Function : MSG_HOUR/MSG_GHOUR
;//
;//       Generate a VP
;//----------------------------------------------------------------------------
MSG_HOUR:	;for English/German
	LAC	MSG_ID
	CALL	GET_MSGHOUR
	SAH	SYSTMP1
MSG_HOUR_VPCHK:	
	
	CALL	GET_LANGUAGE
	BZ	ACZ,MSG_GHOUR	
	
	BIT	EVENT,11
	BS	TB,MSG_HOUR_12
	
	LAC	SYSTMP1
	CALL	ANNOUNCE_NUM
	RET
MSG_GHOUR:
	LAC	SYSTMP1
	BS	ACZ,MSG_GHOUR_NULL
	SBHK	1
	BS	ACZ,MSG_GHOUR_EIN
	
	LAC	SYSTMP1
	CALL	ANNOUNCE_NUM
	BS	B1,MSG_GHOUR_HUR
MSG_GHOUR_NULL:	
	LACK	102		;null(64+38)
	ORL	0XFF00
	CALL	STOR_VP
	BS	B1,MSG_GHOUR_HUR
MSG_GHOUR_EIN:
	LACK	99		;ein(64+35)
	ORL	0XFF00
	CALL	STOR_VP
MSG_GHOUR_HUR:	
	LACK	110		;Uhr(64+46)
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
;-------	
MSG_HOUR_12:
	LAC	SYSTMP1
	BS	ACZ,MSG_HOUR_12_0
	SBHK	12
	BS	ACZ,MSG_HOUR_12_12
	BS	SGN,MSG_HOUR_12_AM
	
	CALL	ANNOUNCE_NUM	;13..23
	
	RET
MSG_HOUR_12_0:			;0,12
MSG_HOUR_12_12:
	LACK	12
	CALL	ANNOUNCE_NUM

	RET

MSG_HOUR_12_AM:			;1..11
	LAC	SYSTMP1
	CALL	ANNOUNCE_NUM

	RET
;//----------------------------------------------------------------------------
;//       Function : MSG_MIN/MSG_GMIN
;//
;//       Generate a VP
;//----------------------------------------------------------------------------
MSG_MIN:
	LAC	MSG_ID
	CALL	GET_MSGMINUTE
	SAH	SYSTMP1
	
	CALL	GET_LANGUAGE
	BZ	ACZ,MSG_GMIN

	LAC	SYSTMP1
	CALL	ANNOUNCE_NUM
	
	BIT	EVENT,11
	BS	TB,MSG_MIN_12_CHK
	
	RET
MSG_GMIN:		;德语规则不报零分
	LAC	SYSTMP1
	BS	ACZ,MSG_GMIN_RET
	CALL	ANNOUNCE_NUM
MSG_GMIN_RET:	
	RET	

MSG_MIN_12_CHK:		;英语12小时制用以判断AM/PM
	LAC	MSG_ID
	CALL	GET_MSGHOUR
	SAH	SYSTMP1
MSG_MIN_12:		;通过小时值(SYSTMP1)判断AM/PM
	LAC	SYSTMP1
	BS	ACZ,MSG_MIN_AM
	SBHK	12
	BZ	SGN,MSG_MIN_PM
MSG_MIN_AM:
	LACK	35	;AM
	ORL	0XFF00
	CALL	STOR_VP
	RET
MSG_MIN_PM:
	LACK	36	;PM
	ORL	0XFF00
	CALL	STOR_VP
	RET

;//----------------------------------------------------------------------------
;//       Function : CURR_WEEK/CURR_GWEEK
;//
;//       Generate a VP
;//----------------------------------------------------------------------------
CURR_WEEK:
	LACL	0X8300
	SAH	CONF
	CALL	DAM_BIOS
	
	CALL	GET_LANGUAGE
	BS	ACZ,CURR_GWEEK
	LAC	RESP
	ADHK	64
	SAH	RESP
CURR_GWEEK:
	LAC	RESP
	ADHK	28
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
;//----------------------------------------------------------------------------
;//       Function : CURR_HOUR
;//
;//       Generate a VP
;//----------------------------------------------------------------------------
CURR_HOUR:
	LACL	0X8200
	SAH	CONF
	CALL	DAM_BIOS
	LAC	RESP
	SAH	SYSTMP1
	
	BS	B1,MSG_HOUR_VPCHK
	
	
;//----------------------------------------------------------------------------
;//       Function : MSG_MIN
;//
;//       Generate a VP
;//----------------------------------------------------------------------------
CURR_MIN:
	LACL	0X8100
	SAH	CONF
	CALL	DAM_BIOS
	LAC	RESP
	SAH	SYSTMP1

	CALL	GET_LANGUAGE
	BZ	ACZ,MSG_GMIN
	
	LAC	SYSTMP1
	CALL	ANNOUNCE_NUM

	BIT	EVENT,11
	BS	TB,CURR_MIN_12_CHK
	
	RET

CURR_MIN_12_CHK:	
	LACL	0X8200
	SAH	CONF
	CALL	DAM_BIOS
	LAC	RESP
	SAH	SYSTMP1

	BS	B1,MSG_MIN_12
;------------------------------------------------------------------------------
;	Function : B_VOP
;	BEEP prompt
;	Generate a "BEEP or not"	---提示用
;//----------------------------------------------------------------------------	
B_VOP:
	BIT	VOI_ATT,14
	BS	TB,BEEP
NOB_VOP:
	LACK	0X015
	CALL	STOR_VP		;B

	RET
;------------------------------------------------------------------------------
;	Function : BB_VOP
;	BBEEP prompt
;	Generate a "BBEEP or not"	---提示用
;//----------------------------------------------------------------------------	
BB_VOP:
	BIT	VOI_ATT,14
	BS	TB,BBEEP
	BS	B1,NOB_VOP
;//----------------------------------------------------------------------------
;//       Function : BEEP
;//
;//       Generate a "BEEP"	---提示用
;//----------------------------------------------------------------------------	
BEEP:
	LACL	0X005
	CALL	STOR_VP
	LACL	0X3010
	CALL	STOR_VP		;B
	
	RET
;//----------------------------------------------------------------------------
;//       Function : LBEEP
;//
;//       Generate a "LONG BEEP"---提示用
;//----------------------------------------------------------------------------	
LBEEP:
	LACL	0X3050
	CALL	STOR_VP		;B___
	
	RET
;//----------------------------------------------------------------------------
;//       Function : BBEEP
;//
;//       Generate two "BEEP"	---结束用
;//----------------------------------------------------------------------------	
BBEEP:
	LACL	0X3010
	CALL	STOR_VP
	LACL	0X005
	CALL	STOR_VP
	LACL	0X3010
	CALL	STOR_VP		;BB
	
	RET
;//----------------------------------------------------------------------------
;//       Function : BBBEEP
;//
;//       Generate three "BEEP"	---报错用
;//----------------------------------------------------------------------------	
BBBEEP:
	LACL	0X3008
	CALL	STOR_VP
	LACL	0X005
	CALL	STOR_VP
	LACL	0X3008
	CALL	STOR_VP
	LACL	0X005
	CALL	STOR_VP
	LACL	0X3008
	CALL	STOR_VP		;BBB
	
	RET
;//----------------------------------------------------------------------------
;//       Function : VP_MESSAGE
;//
;//       Generate a VP "message"
;//----------------------------------------------------------------------------
VP_MESSAGE:
	
	CALL	GET_LANGUAGE
	BZ	ACZ,VP_GMESSAGE

	LACK	41
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
VP_GMESSAGE:
	LACK	105		;105=41+64
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
;//----------------------------------------------------------------------------
;//       Function : VP_MESSAGES
;//
;//       Generate a VP "messages"
;//----------------------------------------------------------------------------
VP_MESSAGES:
	
	CALL	GET_LANGUAGE
	BZ	ACZ,VP_GMESSAGES

	LACK	42
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
VP_GMESSAGES:
	LACK	106		;105=42+64
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
;//----------------------------------------------------------------------------
;//       Function : VP_ENDOF
;//
;//       Generate a VP "end of"
;//----------------------------------------------------------------------------
VP_ENDOF:
	
	CALL	GET_LANGUAGE
	BZ	ACZ,VP_GENDOF

	LACK	43
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
VP_GENDOF:
	LACK	107		;107=43+64
	ORL	0XFF00
	CALL	STOR_VP
	
	LACK	117		;117=53+64
	ORL	0XFF00
	CALL	STOR_VP
	
	RET

;-------------------------------------------------------------------------------
;	Function : VP_DEFAULTOGM
;	
;	Generate a VP "DEFAULTOGM"
;-------------------------------------------------------------------------------
VP_DEFAULTOGM:
	
	CALL	GET_LANGUAGE
	BZ	ACZ,VP_GDEFAULTOGM

	LACK	45
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
VP_GDEFAULTOGM:
	LACK	109		;109=45+64
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
;-------------------------------------------------------------------------------
;	Function : VP_DEFOGM5
;	
;	Generate a VP "DEFAULTOGM"
;-------------------------------------------------------------------------------
VP_DEFOGM5:
	
	CALL	GET_LANGUAGE
	BZ	ACZ,VP_GDEFOGM5

	LACK	39		;NO
	ORL	0XFF00
	CALL	STOR_VP
	LACK	42		;Messages
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
VP_GDEFOGM5:
	LACK	103		;109=39+64
	ORL	0XFF00
	CALL	STOR_VP
	LACK	120		;109=56+64
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
;//----------------------------------------------------------------------------
;//       Function : VP_NO
;//
;//       Generate a VP "no"
;//----------------------------------------------------------------------------
VP_NO:
	
	CALL	GET_LANGUAGE
	BZ	ACZ,VP_GNO

	LACK	39
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
VP_GNO:
	LACK	103		;109=39+64
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
;//----------------------------------------------------------------------------
;//       Function : VP_NEW
;//
;//       Generate a VP "new"
;//----------------------------------------------------------------------------
VP_NEW:
	
	CALL	GET_LANGUAGE
	BZ	ACZ,VP_GNEW

	LACK	40
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
VP_GNEW:
	LACK	104		;104=40+64
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
;//----------------------------------------------------------------------------
;//       Function : VP_MAILBOX
;//
;//       Generate a VP "mail box"
;//----------------------------------------------------------------------------
VP_MAILBOX:
	
	CALL	GET_LANGUAGE
	BZ	ACZ,VP_GMAILBOX

	LACK	62
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
VP_GMAILBOX:
	LACK	126		;126=62+64
	ORL	0XFF00
	CALL	STOR_VP
	
	RET

;//----------------------------------------------------------------------------
;//       Function : VP_MEMFUL
;//
;//       Generate a VP "memory is full"
;//----------------------------------------------------------------------------
VP_MEMFUL:
	
	CALL	GET_LANGUAGE
	BZ	ACZ,VP_GMEMFUL

	LACK	44
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
VP_GMEMFUL:
	LACK	108		;109=44+64
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
;-------------------------------------------------------------------------
;	Function : VP_EINE
;	input :  no
;	output : no
;-------------------------------------------------------------------------
VP_ONE:
	
	CALL	GET_LANGUAGE
	BZ	ACZ,VP_GONE

	LACK	1	;one
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
VP_GONE:
	
	LACK	100	;eine(36+64)
	ORL	0XFF00
	CALL	STOR_VP
	
	RET

;-------------------------------------------------------------------------
;	Function : ANNOUNCE_NUM/ANNOUNCE_GNUM --- 数字入播放队列
;	input : ACCH = 要播放的数字(0..99)
;	output : no
;-------------------------------------------------------------------------
ANNOUNCE_NUM:
	SAH	SYSTMP3
	
	CALL	GET_LANGUAGE
	BZ	ACZ,ANNOUNCE_GNUM
	
	LAC	SYSTMP3
	BS	ACZ,ANNOUNCE_NUM1
	SBHK	21
	BS	SGN,ANNOUNCE_NUM2
	
	LAC	SYSTMP3
	CALL	HEX_DGT
	SAH	SYSTMP3
	
	SFR	4
	ADHK	18
	ORL	0XFF00
	CALL	STOR_VP
	
	LAC	SYSTMP3
	ANDL	0X0F
	BS	ACZ,ANNOUNCE_NUM_END
	ORL	0XFF00
	CALL	STOR_VP
	BS	B1,ANNOUNCE_NUM_END
ANNOUNCE_NUM1:
	LACK	38
	ORL	0XFF00
	CALL	STOR_VP
	BS	B1,ANNOUNCE_NUM_END
ANNOUNCE_NUM2:
	LAC	SYSTMP3
	ORL	0XFF00
	CALL	STOR_VP
ANNOUNCE_NUM_END:
	
	RET
;---------------
ANNOUNCE_GNUM:		;for German

	LAC	SYSTMP3
	BS	ACZ,ANNOUNCE_GNUM_0	;0
	SBHK	13
	BS	SGN,ANNOUNCE_GNUM_1_12	;1..12
	SBHK	7
	BS	SGN,ANNOUNCE_GNUM_13_19	;13..19
	BS	ACZ,ANNOUNCE_GNUM_20	;20
	SBHK	1
	BS	ACZ,ANNOUNCE_GNUM_21	;21
	SBHK	9
	BS	SGN,ANNOUNCE_GNUM_22_29	;22..29
	BS	ACZ,ANNOUNCE_GNUM_30	;30
	SBHK	1
	BS	ACZ,ANNOUNCE_GNUM_31	;31
	SBHK	9
	BS	SGN,ANNOUNCE_GNUM_32_39	;31..39
;---40..99	
	LAC	SYSTMP3
	CALL	HEX_DGT
	SAH	SYSTMP3

	LAC	SYSTMP3
	ANDL	0X0F
	BS	ACZ,ANNOUNCE_GNUM0_0	;
	SBHK	1
	BS	ACZ,ANNOUNCE_GNUM0_0_1
	BS	B1,ANNOUNCE_GNUM0_X2_X9
ANNOUNCE_GNUM0_0_1:
	LACK	99		;1(64+35)
	ORL	0XFF00
	CALL	STOR_VP
	BS	B1,ANNOUNCE_GNUM0_UND
ANNOUNCE_GNUM0_X2_X9:	
	LAC	SYSTMP3
	ANDL	0X0F	
	ADHK	64		;(个位2..9)
	ORL	0XFF00
	CALL	STOR_VP
ANNOUNCE_GNUM0_UND:	
	LACK	101		;und
	ORL	0XFF00
	CALL	STOR_VP
		
ANNOUNCE_GNUM0_0:
	LAC	SYSTMP3
	SFR	4
	ADHK	74		;(64+10)
	ORL	0XFF00
	CALL	STOR_VP

	LACK	86		;(64+22)
	ORL	0XFF00
	CALL	STOR_VP
	BS	B1,ANNOUNCE_GNUM_END
ANNOUNCE_GNUM_0:
	LACK	102
	ORL	0XFF00
	CALL	STOR_VP
	BS	B1,ANNOUNCE_GNUM_END
ANNOUNCE_GNUM_1_12:
ANNOUNCE_GNUM_20:
	LAC	SYSTMP3
	ADHK	64
	ORL	0XFF00
	CALL	STOR_VP
	BS	B1,ANNOUNCE_GNUM_END
ANNOUNCE_GNUM_13_19:
	LAC	SYSTMP3
	ADHK	64
	ORL	0XFF00
	CALL	STOR_VP
	LACK	74		;64+10
	ORL	0XFF00
	CALL	STOR_VP
	BS	B1,ANNOUNCE_GNUM_END
ANNOUNCE_GNUM_22_29:
ANNOUNCE_GNUM_32_39:
	LAC	SYSTMP3
	CALL	HEX_DGT
	SAH	SYSTMP3
	
	LAC	SYSTMP3
	ANDL	0X0F
	ADHK	64		;???(2006-9-27)
	ORL	0XFF00
	CALL	STOR_VP
	
	LACK	101		;und(64+37)
	ORL	0XFF00
	CALL	STOR_VP
	
	LAC	SYSTMP3
	SFR	4
	ADHK	82		;64+18+()
	ORL	0XFF00
	CALL	STOR_VP
	BS	B1,ANNOUNCE_GNUM_END
ANNOUNCE_GNUM_31_39_0:	
	LAC	SYSTMP3
	SFR	4
	ADHK	74
	ORL	0XFF00
	CALL	STOR_VP	
ANNOUNCE_GNUM_30:
	LACK	85
	ORL	0XFF00
	CALL	STOR_VP
	BS	B1,ANNOUNCE_GNUM_END
ANNOUNCE_GNUM_21:
ANNOUNCE_GNUM_31:
	LAC	SYSTMP3
	CALL	HEX_DGT
	SAH	SYSTMP3
	
	
	LACK	99		;1(35+64)
	ORL	0XFF00
	CALL	STOR_VP
	
	LACK	101		;und(64+37)
	ORL	0XFF00
	CALL	STOR_VP
	
	LAC	SYSTMP3
	SFR	4
	ADHK	82		;(64+18)
	ORL	0XFF00
	CALL	STOR_VP
	BS	B1,ANNOUNCE_GNUM_END

ANNOUNCE_GNUM_END:
	
	RET
;//----------------------------------------------------------------------------
;//       Function : HEX_DGT
;//
;//       Transform a binary value to a BCD value

;//       Input  : ACCH = the binary value
;//       Output : ACCH = the BCD value
;//	  Variable : SYSTMP1,SYSTMP2
;//----------------------------------------------------------------------------
HEX_DGT:
	PSH	SYSTMP1
	PSH	SYSTMP2
	
	ANDL	0XFF
	SAH	SYSTMP1
	
	LACK	0
	SAH	SYSTMP2
HEX_DGT_LOOP:
	LAC	SYSTMP1
	SBHK	10
	BS	SGN,HEX_DGT_END
	SAH	SYSTMP1
	
	LAC	SYSTMP2
	ADHK	1
	SAH	SYSTMP2
	BS	B1,HEX_DGT_LOOP
HEX_DGT_END:
	LAC	SYSTMP2
	SFL	4
	ANDL	0X0F0
	OR	SYSTMP1
	
	POP	SYSTMP2
	POP	SYSTMP1
	
        RET

;//----------------------------------------------------------------------------
;//       Function : DGT_HEX
;//
;//       Transform a BCD value to binary value
;//       Input  : ACCH = the BCD value
;//       Output : ACCH = the binary value
;//	  Variable : SYSTMP1,SYSTMP2
;//----------------------------------------------------------------------------
DGT_HEX:
	PSH	SYSTMP1
	PSH	SYSTMP2
	
	SAH	SYSTMP1		;LOW(3..0)
	SFR	4
	ANDK	0XF
	SAH	SYSTMP2		;HIGH(7..4)

	LAC	SYSTMP1
	ANDK	0X0F
	SAH	SYSTMP1
DGT_HEX_LOOP:
	LAC	SYSTMP2
	BS	ACZ,DGT_HEX_END
	
	LAC	SYSTMP1
	ADHK	10
	SAH	SYSTMP1
	
	LAC	SYSTMP2
	SBHK	1
	SAH	SYSTMP2
	BS	B1,DGT_HEX_LOOP
DGT_HEX_END:
	LAC	SYSTMP1
	
	POP	SYSTMP2
	POP	SYSTMP1
	
        RET
;------------------------------------------------------------------------------
;	Function : clear all new flag of messages
;------------------------------------------------------------------------------
CLR_FLAG:
	LACK	0
	SAH	NEW_ID
	SAH	NEW1
	SAH	NEW2
	SAH	NEW3
	SAH	NEW4
	SAH	NEW5
	SAH	NEW6
	SAH	NEW7
	
	RET
;------------------------------------------------------------------------------
;	Function : set new flag of message
;	根据MSG_ID设置相应的标志
;	INPUT : ACCH = MSG_ID
;	OUTPUT: NO
;
;	variable : SYSTMP0,SYSTMP1
;-------------------------------------------------------------------------------
SET_FLAG:
	DINT	;???????????????????????????
	ANDK	0X07F
	SAH	SYSTMP0		;STOR MSG_ID
	SAH	NEW_ID
	LACK	1
	SAH	NEW0
	
	LAC	SYSTMP0
	SBHK	1
	ANDK	0X0F
	SAH	SYSTMP1		;save the bits you will move(col)
	OUT	SYSTMP1,SHFCR	
	LAC	NEW0
	SFL	0
	SAH	NEW0

	LAC	SYSTMP0
	SBHK	1
	SFR	4
	ADHK	NEW1
	SAH	SYSTMP1		;the address you will load(row)
	
	MAR	+0,1
	LAR	SYSTMP1,1
	LAC	NEW0
	OR	+0,1
	SAH	+0,1
SET_FLAG_END:	
	EINT	;????????????????????????????????	
	RET
;------------------------------------------------------------------------------
;	Function : get new flag of message
;	根据MSG_ID取得相应的NEW标志
;	INPUT : ACCH = MSG_ID
;	OUTPUT: ACCH=0/1 ===>not new/new message
;
;	varibale : SYSTMP2
;			MANAGE[SYSTMP0,SET_FLAG(SYSTMP0,SYSTMP1)]
;------------------------------------------------------------------------------
GET_NEWFLAG:
	ANDL	0X07F
	SAH	SYSTMP2		;STOR MSG_ID
	CALL	MANAGE
	
	LAC	SYSTMP2
	SBHK	1
	SFR	4
	ADHK	NEW1
	SAH	SYSTMP1		;the address you will load(ROW)
	
	DINT
	MAR	+0,1
	LAR	SYSTMP1,1
	LAC	+0,1
	SAH	NEW0		;stor the flag
	EINT
	
	LAC	SYSTMP2
	SBHK	1
	ANDK	0X0F
	SAH	SYSTMP1
	OUT	SYSTMP1,SHFCR	;save the bits you will mov(COL)
	
	LAC	NEW0
	SFR	0
	ANDL	0X01
	SAH	NEW0		;直接将所得NEW0标志取反作返回值(ACCH)
	XORL	0X01
GET_NEWFLAG_END:			
	RET
;------------------------------------------------------------------------------
;	Function : set new flag of message
;	根据MSG_ID查找和设转置相应的NEW标志
;	INPUT : ACCH = MSG_ID
;	OUTPUT: NO
;
;	varibale : SYSTMP0,SET_FLAG(SYSTMP0,SYSTMP1)
;			
;------------------------------------------------------------------------------
MANAGE:
	ANDL	0X07F
	SAH	SYSTMP0		;STOR MSG_ID
	
	LAC	NEW_ID
	SBH	SYSTMP0		;查NEW标志设置过吗(减数与被减数的关系与播放顺序有关,此时是反序)?
	BZ	SGN,CHK_NEWFLAG_END
	
	LAC	SYSTMP0
	ORL	0XA800
	SAH	CONF
	CALL	DAM_BIOS
	LAC	RESP
	BZ	ACZ,CHK_NEWFLAG_END
	
	LAC	SYSTMP0
	CALL	SET_FLAG	;设置NEW标志
CHK_NEWFLAG_END:
		
	RET
;-------------------------------------------------------------------------------


;---------------------------------------------------------------------
;	Function : VALUE_ADD	(ACCH+1==>ACCH)
;	input : 	ACCH ==>SYSTMP0
;	output: 	ACCH
;	minvalue:	SYSTMP1
;	maxvalue:	SYSTMP2
;---------------------------------------------------------------------
VALUE_ADD:
	SAH	SYSTMP0
VALUE_ADD1:
        LAC     SYSTMP0
        SBH	SYSTMP2
        BZ	SGN,VALUE_ADD3	;比最大的还大
        LAC	SYSTMP0
        SBH	SYSTMP1
        BS	SGN,VALUE_ADD3	;比最小的还小
        LAC	SYSTMP0
	ADHK    1
VALUE_ADD2:      
        RET
VALUE_ADD3:
	LAC	SYSTMP1
	RET
;-------------------------------------------------------------------
;	Function : VALUE_SUB(ACCH-1==>ACCH)
;	
;	input : ACCH ==>SYSTMP0
;	output: ACCH
;	maxvalue: SYSTMP2
;	minvalue: SYSTMP1
;		
;-------------------------------------------------------------------        
VALUE_SUB:
	SAH	SYSTMP0
VALUE_SUB1:
        LAC     SYSTMP1
        SBH	SYSTMP0
        BZ	SGN,VALUE_SUB3	;比最小的还小
        LAC	SYSTMP2
        SBH	SYSTMP0
        BS	SGN,VALUE_SUB3	;比最大的还大
        
        LAC	SYSTMP0
	SBHK	1
       
        RET
VALUE_SUB3:
	LAC	SYSTMP2

	RET
;------------------------------------------------------------------------------
;	Function : SET_FGTABLE
;	set new flag of message
;	设置相应的标志图表NEW1..NEW7
;	INPUT : MSG_T
;	OUTPUT: NO
;------------------------------------------------------------------------------
SET_FGTABLE:
	CALL	CLR_FLAG
	
	LAC	MSG_T
	SAH	MSG_ID
SET_FGTABLE_LOOP:
	LAC	MSG_ID
	BS	ACZ,SET_FGTABLE_END
	CALL	GET_USRDAT
	CALL	SET_FLAG
		
	LAC	MSG_ID
	SBHK	1
	SAH	MSG_ID
	BS	B1,SET_FGTABLE_LOOP
SET_FGTABLE_END:
	RET
;------------------------------------------------------------------------------
;	Function : get new flag of message
;	根据MSG_ID取得相应的标志
;	INPUT : ACCH = MSG_ID(1..99)
;	OUTPUT: ACCH=0/1 ===>not used/been used
;------------------------------------------------------------------------------
GET_FLAG:
	PSH	SYSTMP0
	PSH	SYSTMP1
	
	ANDL	0X07F
	SAH	SYSTMP0		;STOR MSG_ID

	LAC	SYSTMP0
	SBHK	1
	SFR	4
	ADHK	NEW1
	SAH	SYSTMP1		;the address you will load(ROW)
	
	MAR	+0,1
	LAR	SYSTMP1,1
	LAC	+0,1
	SAH	NEW0		;stor the flag
	
	LAC	SYSTMP0
	SBHK	1
	ANDK	0X0F
	SAH	SYSTMP1
	OUT	SYSTMP1,SHFCR	;save the bits you will mov(COL)
	
	LAC	NEW0
	SFR	0
	ANDK	0X01
	;SAH	NEW0		;直接将所得NEW0标志取反作返回值(ACCH)
	;XORL	0X01
GET_DATFLAG_END:
	POP	SYSTMP1
	POP	SYSTMP0
	
	RET
;-------------------------------------------------------------------------------
;	Function : SERACH_USEID
;	input : no
;	output: ACCH = 
;	根据标志位图()查可用的USE_DAT
;-------------------------------------------------------------------------------
SERACH_USEID:
	LACK	0
	SAH	SYSTMP1		;循环计数
	
	MAR	+0,1
	LARK	NEW1,1
SERACH_USEID_LOOP1:	
	LAC	SYSTMP1
	ADHK	1
	SAH	SYSTMP1		;最多7次(7*16=112)

	LAC	+,1
	SAH	SYSTMP0		;stor flag
	XORL	0XFFFF
	BS	ACZ,SERACH_USEID_LOOP1

	LAC	SYSTMP1
	SBHK	1
	SFL	4
	SAH	SYSTMP0		;查找位图标志的开始序号(前面为全0XFFFF表示已用过)
SERACH_USEID_LOOP2:
	LAC	SYSTMP0
	ADHK	1
	SAH	SYSTMP0
	
	CALL	GET_FLAG
	BZ	ACZ,SERACH_USEID_LOOP2	
	
	LAC	SYSTMP0
SERACH_USEID_END:
	RET
;############################################################################
;	FUNCTION : GET_FILEID
;	找一个可用的FILE_ID,用于录音前设usr_dat0
;	INPUT : no
;	OUTPUT: ACCH/FILE-ID
;############################################################################
GET_FILEID:

	CALL	SET_FGTABLE
	
	CALL	SERACH_USEID
GET_FILEID_END:			;1..MSG_T全用到,则返回(MSG_T)+1

	RET
	
	
;############################################################################
;	FUNCTION : REAL_DEL
;	INPUT : NO
;	OUTPUT: NO
;############################################################################
REAL_DEL:
	LACL	0X6100
	SAH	CONF
	CALL	DAM_BIOS
	
	RET
;############################################################################
;	FUNCTION : SET_USRDAT
;	INPUT : ACCH = USER INDEX DATA0
;	OUTPUT: NO
;############################################################################
SET_USRDAT:
	ANDL	0XFF
	ORL	0X7500
	SAH	CONF
	CALL	DAM_BIOS
	
	RET
;############################################################################
;	FUNCTION : GET_USRDAT
;	INPUT : ACCH = MSG_ID
;	OUTPUT: ACCH = USER INDEX DATA0
;############################################################################
GET_USRDAT:
	ANDK	0X7F
	ORL	0XA900
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	RESP
	
	RET
;############################################################################
;	FUNCTION : SET_USRDAT1
;	INPUT : ACCH = USER INDEX DATA1
;	OUTPUT: NO
;############################################################################
SET_USRDAT1:
	ANDL	0XFF
	ORL	0X8E00
	SAH	CONF
	CALL	DAM_BIOS
	
	RET
;############################################################################
;	FUNCTION : GET_USRDAT1
;	INPUT : ACCH = MSG_ID
;	OUTPUT: ACCH = USER INDEX DATA1
;############################################################################
GET_USRDAT1:
	ANDL	0XFF
	ORL	0XAA00
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	RESP
	
	RET
;############################################################################
;	FUNCTION : NEWICM_CHK
;	上电时调用之,播放完了和ICM录完了调用之
;	INPUT : 
;	OUTPUT: 
;############################################################################
NEWICM_CHK:
	CALL	GET_NEWMSGNUM	;The number of new message in working group
	ADHK	1
	SAH	SYSTMP0
	
	CRAM	ANN_FG,8
NEW_ICMCHK1:
	LAC	SYSTMP0
	SBHK	1
	SAH	SYSTMP0
	BS	ACZ,NEW_ICMCHK2
	ORL	0X080			;new flag
	CALL	GET_USRDAT1
	SBHK	CTAG_ICM		;ICM DATA ?
	BZ	ACZ,NEW_ICMCHK1
	
	SRAM	ANN_FG,8	;Set the bit once the new message exist
;-------------------------------------------------------------------------------
NEW_ICMCHK2:
	LAC	MBOX_ID
	SBHK	1
	BS	ACZ,NEW_ICMCHK2_1_1
	SBHK	1
	BS	ACZ,NEW_ICMCHK2_2_1
	SBHK	1
	BS	ACZ,NEW_ICMCHK2_3_1
NEW_ICMCHK2_1_1:		;---MBOX 1
	SRAM	ANN_FG,5
	BIT	ANN_FG,8
	BS	TB,NEW_ICMCHK_END
	CRAM	ANN_FG,5
	BS	B1,NEW_ICMCHK_END
NEW_ICMCHK2_2_1:
	SRAM	ANN_FG,6
	BIT	ANN_FG,8
	BS	TB,NEW_ICMCHK_END
	CRAM	ANN_FG,6
	BS	B1,NEW_ICMCHK_END
NEW_ICMCHK2_3_1:
	SRAM	ANN_FG,7
	BIT	ANN_FG,8
	BS	TB,NEW_ICMCHK_END
	CRAM	ANN_FG,7
	;BS	B1,NEW_ICMCHK_END
NEW_ICMCHK_END:
	RET
;############################################################################
;	FUNCTION : GET_VPMSG_NSTATUS
;	INPUT : ACCH = MSG_ID
;	OUTPUT: ACCH = 1/0 ==>
;############################################################################
GET_VPMSG_NSTATUS:
	ANDK	0X7F
	ORL	0XA800
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	RESP
	
	RET
;############################################################################
;	FUNCTION : GET_VPTLEN
;	INPUT : ACCH = MSG_ID
;	OUTPUT: ACCH = RECORD LENGTH
;############################################################################
GET_VPTLEN:
	ANDK	0X7F
	ORL	0XA400
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	RESP
	
	RET

;############################################################################
;	FUNCTION : SET_DELMARK
;	INPUT : MSG_ID     
;	OUTPUT: NO
;############################################################################
SET_DELMARK:
	ANDK	0X7F
	ORL	0X2080
	SAH	CONF
	CALL	DAM_BIOS

	RET
;------------------------------------------------------------------------------
;	delete message with specific MSG_ID
;	input : ACCH = MSG_ID
;	output: no
;------------------------------------------------------------------------------
MSG_DEL:
	ANDK	0X7F
	ORL	0X6000	; delete
	SAH	CONF    
	CALL	DAM_BIOS
	
	RET
;############################################################################
;	FUNCTION : GET_VPLEN
;	将与MSG_ID的USER-DATA0相同的VP全部找出,以MSG_ID为基址,以FILE_LEN为长度返回
;	INPUT : ACCH = MSG_ID(输入的MSG_ID是USER-DATA0相同所有值的最小值)
;	OUTPUT: MSG_ID(MSG_ID保持为USER-DATA0相同最小的值)
;		FILE_LEN(本次相同USE_DAT的VP条目数-1)
;############################################################################
GET_VPLEN:
	SAH	MSG_ID
	CALL	GET_USRDAT
	SAH	MSG_N
	
	LACK	0
	SAH	FILE_LEN
GET_VPLEN_LOOP:
	LAC	FILE_LEN
	ADHK	1
	SAH	FILE_LEN
	ADH	MSG_ID

	CALL	GET_USRDAT
	SBH	MSG_N
	BS	ACZ,GET_VPLEN_LOOP
GET_VPLEN_1:
	LAC	FILE_LEN
	SBHK	1
	SAH	FILE_LEN
GET_VPLEN_END:
	RET
;############################################################################
;	FUNCTION : GET_RVPLEN
;	将与MSG_ID的USER-DATA0相同的VP全部找出,以MSG_ID为基址,以FILE_LEN为长度返回
;	INPUT : ACCH = MSG_ID(输入的MSG_ID是USER-DATA0相同所有值的最大值)
;	OUTPUT: MSG_ID(由相同的USR-DATA0最大值变成相同的USR-DATA0的MSG_ID最小的值)
;		FILE_LEN(本次相同USE_DAT的VP条目数-1)
;############################################################################
GET_RVPLEN:
	SAH	MSG_ID
	CALL	GET_USRDAT
	SAH	MSG_N
	
	LACK	0
	SAH	FILE_LEN
GET_RVPLEN_LOOP:
	LAC	FILE_LEN
	ADHK	1
	SAH	FILE_LEN
	
	LAC	MSG_ID
	SBH	FILE_LEN

	CALL	GET_USRDAT
	SBH	MSG_N
	BS	ACZ,GET_RVPLEN_LOOP
;---
	LAC	FILE_LEN
	SBHK	1
	SAH	FILE_LEN
	
	LAC	MSG_ID
	SBH	FILE_LEN
	SAH	MSG_ID
GET_RVPLEN_END:
	RET
;############################################################################
;	FUNCTION : GET_VPMSG
;	将与MSG_ID的USER-DATA0相同的录音按id号由小到大(MSG_ID..MSG_ID+FILE_LEN)的顺序入队列
;	MSG_ID由相同的USR-DATA0最小值变成相同的USR-DATA0的MSG_ID最大的值
;	INPUT : FLIE_LEN
;		MSG_ID(first VP)     
;	OUTPUT: NO
;############################################################################
GET_VPMSG:
	LACK	0
	SAH	MSG_N		;已处理的条数
GET_VPMSG_LOOP:
	LAC	FILE_LEN
	SBH	MSG_N
	BS	SGN,GET_VPMSG_END
	
	LAC	MSG_ID		;message(record)
	ORL	0XFE00
	CALL	STOR_VP

	LAC	MSG_ID
	ADHK	1
	SAH	MSG_ID

	LAC	MSG_N
	ADHK	1
	SAH	MSG_N
	BS	B1,GET_VPMSG_LOOP
GET_VPMSG_END:
	
	LAC	MSG_ID
	SBHK	1
	SAH	MSG_ID
	
	RET
;############################################################################
;	FUNCTION : DEL_VPMSG
;	将与MSG_ID的USER-DATA0相同的录音按id号由小到大(MSG_ID..MSG_ID+FILE_LEN)的顺序置删除标志
;	执行前后MSG_ID,FILE_LEN的值不变
;	INPUT : FLIE_LEN
;		MSG_ID(last MSG_ID of VP)     
;	OUTPUT: NO
;############################################################################
DEL_VPMSG:
	LACK	0
	SAH	MSG_N		;已处理的条数

DEL_VPMSG_LOOP:
	
	LAC	MSG_ID		;message(record)
	SBH	MSG_N
	ANDK	0X7F
	ORL	0X2080
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	MSG_N
	ADHK	1
	SAH	MSG_N
	
	LAC	FILE_LEN
	SBH	MSG_N
	BZ	SGN,DEL_VPMSG_LOOP

DEL_VPMSG_END:
	RET
;############################################################################
;	FUNCTION : SETOLD_VPMSG
;	将与MSG_ID的USER-DATA0相同的录音按id号由小到大(MSG_ID..MSG_ID+FILE_LEN)的播放后停止
;	执行前后MSG_ID,FILE_LEN的值不变
;	INPUT : FLIE_LEN
;		MSG_ID(last MSG_ID of VP)     
;	OUTPUT: NO
;############################################################################
SETOLD_VPMSG:
	LACK	0
	SAH	MSG_N		;已处理的条数
SETOLD_VPMSG_LOOP:
	
	LAC	MSG_ID		;message(record)
	SBH	MSG_N
	ANDL	0X7F
	ORL	0X2000
	SAH	CONF
	CALL	DAM_BIOS

	SRAM	CONF,9
	CALL	DAM_BIOS
	
	LAC	MSG_N
	ADHK	1
	SAH	MSG_N
	
	LAC	FILE_LEN
	SBH	MSG_N
	BZ	SGN,SETOLD_VPMSG_LOOP

SETOLD_VPMSG_END:
	RET	
;############################################################################
;	get MONTH message with specific MSG_ID
;	FUNCTION : GET_MSGMONTH
;
;	input : ACCH = MSG_ID
;	output: ACCH = MONTH
;############################################################################
GET_MSGMONTH:
	ANDK	0X7F
	ORL	0XAD00
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	RESP
	
	RET

;############################################################################
;	get DAY message with specific MSG_ID
;	FUNCTION : GET_MSGDAY
;
;	input : ACCH = MSG_ID
;	output: ACCH = DAY
;############################################################################
GET_MSGDAY:
	ANDK	0X7F
	ORL	0XAE00
	SAH	CONF    
	CALL	DAM_BIOS
	LAC	RESP
	
	RET
;############################################################################
;	get HOUR message with specific MSG_ID
;	FUNCTION : GET_MSGHOUR
;
;	input : ACCH = MSG_ID
;	output: ACCH = HOUR
;############################################################################
GET_MSGHOUR:
	ANDK	0X7F
	ORL	0XA200
	SAH	CONF    
	CALL	DAM_BIOS
	LAC	RESP
	
	RET
;############################################################################
;	get MINUTE message with specific MSG_ID
;	FUNCTION : GET_MSGMINUTE
;
;	input : ACCH = MSG_ID
;	output: ACCH = MINUTE
;############################################################################
GET_MSGMINUTE:
	ANDK	0X7F
	ORL	0XA100
	SAH	CONF    
	CALL	DAM_BIOS
	LAC	RESP
	
	RET

;############################################################################
;       Function : SENDLANGUAGE
;	语言同步(2byte)
;
;	input  : no
;	output : no
;
;############################################################################
SENDLANGUAGE:
	LACL	0X89		;语言同步(2byte)
	CALL	STOR_DAT
	
	CALL	GET_LANGUAGE
	CALL	STOR_DAT
	
	RET
;############################################################################
;       Function : SENDTIME
;	时间同步(6byte)
;
;	input  : no
;	output : no
;
;############################################################################
SENDTIME:
	LACK	0
	SAH	TMR1
	SAH	TMR_SEC
SENDTIME_SEND:
	LACL	0X81		;时间同步(6byte)
	CALL	STOR_DAT
	LAC	TMR_MONTH
	CALL	STOR_DAT
	LAC	TMR_DAY
	CALL	STOR_DAT
	LAC	TMR_HOUR
	CALL	STOR_DAT
	LAC	TMR_MIN
	CALL	STOR_DAT
	LAC	TMR_WEEK
	CALL	STOR_DAT

	RET

;############################################################################
;       Function : SENDLOCACODE
;	区域码同步(5byte)
;
;	input  : no
;	output : no
;
;############################################################################
SENDLOCACODE:
	LACL	0X86
	CALL	STOR_DAT
;-
	LAC	LOCACODE
	SFR	12
	ANDK	0X0F
	CALL	STOR_DAT	;local code 1
;-
	LAC	LOCACODE
	SFR	8
	ANDK	0X0F
	CALL	STOR_DAT	;local code 2
;-
	LAC	LOCACODE
	SFR	4
	ANDK	0X0F
	CALL	STOR_DAT	;local code 3
;-
	LAC	LOCACODE
	ANDK	0X0F
	CALL	STOR_DAT	;local code 4
;-
	LAC	LOCACODE1
	ANDK	0X0F
	CALL	STOR_DAT	;local code 5
	
	RET
;############################################################################
;       Function : SENDPSWORD
;	PSWORD码同步(4byte)
;
;	input  : no
;	output : no
;
;############################################################################
SENDPSWORD:
	LACL	0X85		;PSWORD码同步(4byte)
	CALL	STOR_DAT
	LAC	PASSWORD
	SFR	8
	ANDK	0X0F
	CALL	STOR_DAT	;PS1
	LAC	PASSWORD
	SFR	4
	ANDK	0X0F
	CALL	STOR_DAT	;PS2
	LAC	PASSWORD
	ANDK	0X0F
	CALL	STOR_DAT	;PS3
	
	RET
;############################################################################
;       Function : TOSENDBUF
;	将以ADDR_S为基址以COUNT为变址以ACCH为长度(byte)的数据送到发送缓冲区
;	input  : ACCH = length
;		 ADDR_S = BASE address
;	OUTPUT : ACCH = no
;
;	variable:SYSTMP2
;############################################################################
TOSENDBUF:
	SBHK	1		;为方便后面的判断
	ANDK	0X1F
	SAH	SYSTMP2
TOSENDBUF_LOOP:	
	LAC	SYSTMP2
	BS	SGN,TOSENDBUF_END
	CALL	GETBYTE_DAT
	CALL	STOR_DAT
	
	LAC	SYSTMP2
	SBHK	1
	SAH	SYSTMP2
		
	LAC	COUNT
	ADHK	1
	SAH	COUNT
	BS	B1,TOSENDBUF_LOOP
TOSENDBUF_END:
	
	RET
;############################################################################
;       Function : TELNUM_TOBUF
;	将以ADDR_S为基址的号码数据送到发送缓冲区
;	input  : 
;		 ADDR_S = BASE address
;	OUTPUT : ACCH = no
;
;	variable:SYSTMP2
;############################################################################
TELNUM_TOBUF:
	DINT	;????????????????????????????????
	MAR	+0,1
	LAR	ADDR_S,1
	
	LAC	+0,1
	ANDL	0X80
	BS	ACZ,TELNUM_TOBUF_END	;有号码吗?
	LAC	+0,1
	ANDK	0X7F
	ADHK	1
	SFR	1
	SAH	SYSTMP1		;the length
	
	LACL	0X80
	CALL	STOR_DAT
	LAC	SYSTMP1
	CALL	STOR_DAT
	
	LACK	4
	SAH	COUNT		;add the flag length
	
	LAC	SYSTMP1
	CALL	TOSENDBUF
	
	LACK	1
TELNUM_TOBUF_END:
	EINT	;??????????????????????????????	
	RET
;############################################################################
;       Function : TELNAME_TOBUF
;	将以ADDR_S为基址姓名数据送到发送缓冲区
;	input  : 
;		 ADDR_S = BASE address
;	OUTPUT : ACCH = no
;
;	variable:SYSTMP2
;############################################################################
TELNAME_TOBUF:
	DINT	;??????????????????????????????????
	MAR	+0,1
	LAR	ADDR_S,1
	LACK	0
	SAH	COUNT

	LAC	+0,1
	ANDL	0X8000
	BS	ACZ,TELNAME_TOBUF_END	;有姓名吗?
	LAC	+0,1
	SFR	8
	ANDK	0X7F
	SAH	SYSTMP1		;the length

	LAC	+0,1
	ANDL	0X80
	BS	ACZ,TELNAME_TOBUF_1
	LAC	+0,1
	ANDK	0X7F
	ADHK	1
	SFR	1
	SAH	COUNT		;add the NUM length
TELNAME_TOBUF_1:
	LAC	COUNT
	ADHK	4
	SAH	COUNT		;add the flag length
	
	LACL	0X80
	CALL	STOR_DAT
	LACK	0X20
	OR	SYSTMP1
	CALL	STOR_DAT
	
	LAC	SYSTMP1
	CALL	TOSENDBUF
	
	LACK	1
TELNAME_TOBUF_END:
	EINT	;????????????????????????
	RET
;############################################################################
;       Function : TELTIME_TOBUF
;	将以ADDR_S为基址时间数据送到发送缓冲区
;	input  : 
;		 ADDR_S = BASE address(以word为单位)
;	OUTPUT : ACCH = no
;
;	variable:SYSTMP2
;############################################################################
TELTIME_TOBUF:
	DINT	;??????????????????????????????
	MAR	+0,1
	LAR	ADDR_S,1
	LACK	0
	SAH	COUNT

	LAC	+,1
	LAC	-,1
	ANDL	0X80
	BS	ACZ,TELTIME_TOBUF_END	;有时间吗?
	
	LAC	+0,1
	ANDL	0X80
	BS	ACZ,TELTIME_TOBUF_1
	LAC	+0,1
	ANDK	0X7F
	ADHK	1
	SFR	1
	SAH	COUNT		;add NUM length
TELTIME_TOBUF_1:
	LAC	+0,1
	ANDL	0X8000
	BS	ACZ,TELTIME_TOBUF_2
	LAC	+0,1
	SFR	8
	ANDK	0X7F
	ADH	COUNT		
	SAH	COUNT		;add NAME length
TELTIME_TOBUF_2:	
	LAC	COUNT
	ADHK	4
	SAH	COUNT		;add flag length
	
	LACL	0X80
	CALL	STOR_DAT
	LACK	0X44
	CALL	STOR_DAT
	
	LACK	4
	CALL	TOSENDBUF
	LACK	1
TELTIME_TOBUF_END:
	EINT	;?????????????????????????????????	
	RET
;-------------------------------------------------------------------------
;	Function : SET_WAITFG	
;	从以ADDR_S为起始地址以COUNT为offset的队列取数据,根据数据设等待状态
;	INPUT : COUNT = the offset you will get data from
;		ADDR_S = the BASE you will get data from
;	output: ACCH = the data you got
;-------------------------------------------------------------------------
SET_WAITFG:
	DINT	;??????????????????????
	LAC	EVENT
	ANDL	0XFFF0
	SAH	EVENT
	
	MAR	+0,1
	LAR	ADDR_S,1
SET_WAITFG_1:			;号码
	LAC	+0,1
	ANDL	0X080
	BS	ACZ,SET_WAITFG_2
	
	SRAM	EVENT,0
SET_WAITFG_2:			;姓名
	LAC	+,1
	ANDL	0X8000
	BS	ACZ,SET_WAITFG_3
	
	SRAM	EVENT,1
SET_WAITFG_3:			;时间
	
	LAC	+0,1
	ANDL	0X080
	BS	ACZ,SET_WAITFG_4
	
	SRAM	EVENT,2
SET_WAITFG_4:			;OGM_ID
	LAC	+0,1
	ANDL	0X8000
	BS	ACZ,SET_WAITFG_END
	
	;SRAM	EVENT,3		;???暂时不用
SET_WAITFG_END:	
	EINT	;???????????????????????????
	RET
;-------------------------------------------------------------------------
;	Function : GETBYTE_DAT	
;	从以ADDR_S为起始地址以COUNT为offset的队列取数据(一个字节)
;	INPUT : COUNT = the offset you will get data from
;		ADDR_S = the BASE you will get data from
;	output: ACCH = the data you got
;-------------------------------------------------------------------------
GETBYTE_DAT:
	DINT	;?????????????????????????????????????
	PSH	SYSTMP1
	PSH	SYSTMP2	
GETBYTEDAT_GET:
	LAC	COUNT
	SFR	1
	ADH	ADDR_S
	SAH	SYSTMP1		;GET ADDR(row)
	
	MAR	+0,1
	LAR	SYSTMP1,1
	
	LAC	COUNT
	ANDK	0X01			;GET ADDR(col)
	BS	ACZ,GETBYTEDAT_GET2
	LAC	+0,1			;奇地址
	SFR	8
	ANDL	0X0FF
	BS	B1,GETBYTEDAT_END
GETBYTEDAT_GET2:			;偶地址
	LAC	+0,1
	ANDL	0X0FF
GETBYTEDAT_END:
	POP	SYSTMP2
	POP	SYSTMP1	
	EINT	;????????????????????????????????
	RET
;-------------------------------------------------------------------------
;	Function : STORBYTE_DAT	
;	将数据存在以ADDR_D为起始地址以COUNT为offset的空间(一个字节)
;	INPUT : ACCH = the data you will stor
;		COUNT = the offset you will stor data
;		ADDR_D = the BASE you will stor data
;	output: ACCH = no
;-------------------------------------------------------------------------
STORBYTE_DAT:
	DINT	;????????????????????????????
	PSH	SYSTMP1
	PSH	SYSTMP2
	
	ANDL	0XFF
	SAH	SYSTMP2		;stor DAT
STORBYTEDAT_STOR:
	LAC	COUNT
	SFR	1
	ADH	ADDR_D
	SAH	SYSTMP1		;GET ADDR(row)
	
	MAR	+0,1
	LAR	SYSTMP1,1

	LAC	COUNT
	ANDK	0X01			;GET ADDR(col)
	BS	ACZ,STORBYTEDAT_STOR2
	LAC	+0,1		;奇地址
	ANDL	0XFF
	SAH	+0,1
	
	LAC	SYSTMP2
	SFL	8
	ANDL	0XFF00
	OR	+0,1
	SAH	+0,1
	BS	B1,STORBYTEDAT_END	
STORBYTEDAT_STOR2:		;偶地址
	LAC	+0,1
	ANDL	0XFF00
	OR	SYSTMP2
	SAH	+0,1
STORBYTEDAT_END:
	POP	SYSTMP2
	POP	SYSTMP1	
	EINT	;????????????????????????
	RET
;-------------------------------------------------------------------------
;	Function : MOVE_DAT	
;	将以ADDR_S为起始地址的数据放到以ADDR_D为起始地址的区域(多个word)
;	INPUT : ACCH = the length you will move(word)
;	output: no
;-------------------------------------------------------------------------
.if	0
MOVE_DAT:		;由于地址增长方向的原因(先低地址),适合高地址处数据向低地址处移动
	ANDK	0XF
	SAH	SYSTMP1		;length
	
	LACK	0
	SAH	SYSTMP3		;first offset
	
	LAR	ADDR_S,1
	LAR	ADDR_D,2
	MAR	+0,1
MOVE_DAT_LOOP:
	LAC	SYSTMP1
	SBH	SYSTMP3
	BS	SGN,MOVE_DAT_END

	LAC	+,2
	SAH	+,1

	LAC	SYSTMP3
	ADHK	1
	SAH	SYSTMP3
	BS	B1,MOVE_DAT_LOOP
MOVE_DAT_END:	
	RET
.else
;-------------------------------------------------------------------------------
MOVE_DAT:		;由于地址增长方向的原因(先高地址),适合低地址处数据向高地址处移动
	SBHK	1
	SAH	SYSTMP1		;length

	LAC	ADDR_S
	ADH	SYSTMP1
	SAH	ADDR_S
	
	LAC	ADDR_D
	ADH	SYSTMP1
	SAH	ADDR_D

	LAR	ADDR_S,1
	LAR	ADDR_D,2
	MAR	+0,1
MOVE_DAT_LOOP:
	LAC	SYSTMP1
	BS	SGN,MOVE_DAT_END

	LAC	-,2
	SAH	-,1

	LAC	SYSTMP1
	SBHK	1
	SAH	SYSTMP1
	BS	B1,MOVE_DAT_LOOP
MOVE_DAT_END:	
	RET
.endif
;-------------------------------------------------------------------------------
;	Function : CONCEN_DAT
;	将以 ADDR_S为基址,长度为ACCH的数据进行压缩
;	INPUT : ACCH = 待压缩数据的长度(byte)
;		ADDR_S = 待压缩数据的基址
;		ADDR_D = 压缩后数据的存放基址
;	OUTPUT: no
;-------------------------------------------------------------------------------
CONCEN_DAT:
	SAH	SYSTMP1	
	
	LACK	0
	SAH	SYSTMP2		;已处理的长度
CONCEN_DAT_LOOP:
	LAC	SYSTMP2
	SBH	SYSTMP1
	BZ	SGN,CONCEN_DAT_END

	LAC	SYSTMP2
	SAH	COUNT
	CALL	GETBYTE_DAT		;get first
	SAH	COUNT

	BIT	SYSTMP2,0
	BS	TB,CONCEN_DAT_LOW
;CONCEN_DAT_HIGH:	
	LAC	COUNT
	SFL	4
	ANDL	0XF0
	ORK	0X0F
	SAH	SYSTMP3
	
	BS	B1,CONCEN_DAT_LOOP_1
CONCEN_DAT_LOW:
	LAC	SYSTMP3
	ANDL	0XF0
	SAH	SYSTMP3
	
	LAC	COUNT
	ANDK	0X0F
	OR	SYSTMP3
	SAH	SYSTMP3
CONCEN_DAT_LOOP_1:
	LAC	SYSTMP2
	SFR	1
	SAH	COUNT

	LAC	SYSTMP3		;get dat
	CALL	STORBYTE_DAT	;stor
	
	LAC	SYSTMP2
	ADHK	1
	SAH	SYSTMP2
	BS	B1,CONCEN_DAT_LOOP

CONCEN_DAT_END:	
	LAC	SYSTMP2
	ADHK	1
	SFR	1
	SAH	COUNT

	LACL	0XFF
	CALL	STORBYTE_DAT	;以0XFF结束
	
	RET
;-------------------------------------------------------------------------------
;	Function : DECONCEN_DAT
;	将以 ADDR_S为基址,长度为ACCH的数据进行解压缩(适合高地址向低地址展开)
;	将数据存在以 ADDR_D为基址的地区
;	INPUT : ACCH = 待解压缩数据的实际长度(解压后的长度byte)
;		ADDR_S = 待解压缩数据的基址
;		ADDR_D = 解压缩后的数据存放的基址
;	OUTPUT: no
;-------------------------------------------------------------------------------
DECONCEN_DAT:
	SBHK	1
	SAH	SYSTMP1		;长度转换成==>处理后存放数据的偏移地址
DECONCEN_DAT_LOOP:
	LAC	SYSTMP1
	BS	SGN,DECONCEN_DAT_END

	LAC	SYSTMP1
	SFR	1
	SAH	COUNT
	CALL	GETBYTE_DAT	;get dat
	SAH	SYSTMP2

	BIT	SYSTMP1,0
	BS	TB,DECONCEN_DAT_LOW
;DECONCEN_DAT_HIGH:	
	LAC	SYSTMP2
	SFR	4
	SAH	SYSTMP2
DECONCEN_DAT_LOW:
	LAC	SYSTMP2
	ANDK	0XF
	SAH	SYSTMP2
	
	LAC	SYSTMP1
	SAH	COUNT
	LAC	SYSTMP2	
	CALL	STORBYTE_DAT	;stor dat
	
	LAC	SYSTMP1
	SBHK	1
	SAH	SYSTMP1
	BS	B1,DECONCEN_DAT_LOOP
DECONCEN_DAT_END:	
	RET
;-------------------------------------------------------------------------------
;	Function : MOVE_BYTEDAT
;	将以ADDR_S为基址COUNT为偏移长度为ACCH的数据移动到以ADDR_D为基址的地方
;	INPUT : ACCH = 要移动的数据的长度byte
;		COUNT = the offset
;		ADDR_S = BASE address
;		ADDR_D = BASE address
;	OUTPUT: no
;NOTE : move high address data first
;-------------------------------------------------------------------------------
MOVE_BYTEDAT:
	SBHK	1
	ANDK	0X01F
	SAH	SYSTMP1		;see as distation 

	LAC	COUNT
	ADH	SYSTMP1
	SAH	COUNT
MOVE_BYTEDAT_LOOP:
	LAC	SYSTMP1
	BS	SGN,MOVE_BYTEDAT_END

	CALL	GETBYTE_DAT	;get offset
	SAH	SYSTMP2
	
	LAC	COUNT
	SAH	SYSTMP3		;save source offset
	
	LAC	SYSTMP1
	SAH	COUNT
	LAC	SYSTMP2		;get dat
	CALL	STORBYTE_DAT	;stor

	LAC	SYSTMP3
	SBHK	1
	SAH	COUNT
	
	LAC	SYSTMP1
	SBHK	1
	SAH	SYSTMP1
	BS	B1,MOVE_BYTEDAT_LOOP
MOVE_BYTEDAT_END:
	
	RET
;-------------------------------------------------------------------------------
;	Function : SFL_BYTEDAT
;	高地址数据移到低一个byte的地址处
;	
;	INPUT : ACCH = 将要移动的长度(byte),即循环次数
;		COUNT = offset(第一个要移动的数据)
;		ADDR_S = BASE address
;	OUTPUT: no
;-------------------------------------------------------------------------------
SFL_BYTEDAT:
	SBHK	1
	SAH	SYSTMP2
SFL_BYTEDAT_LOOP:
	LAC	SYSTMP2
	BS	SGN,SFL_BYTEDAT2

	CALL	GETBYTE_DAT
	SAH	SYSTMP1
	
	LAC	COUNT
	SBHK	1
	SAH	COUNT

	LAC	SYSTMP1		;get dat
	CALL	STORBYTE_DAT	;stor
	
	LAC	COUNT
	ADHK	2
	SAH	COUNT
	
	LAC	SYSTMP2
	SBHK	1
	SAH	SYSTMP2
	BS	B1,SFL_BYTEDAT_LOOP
SFL_BYTEDAT2:
	LACK	0X07F
	CALL	STORBYTE_DAT	;最后移入空白字符
	
	RET
;-------------------------------------------------------------------------------
;	Function : TEL_SENDCOMM
;	INPUT : EVENT(10,2,1,0)
;	
;	OUTPUT: ACCH =  0 - 发送了一部分
;			1 - 所有发送工作完毕()
;			2 - 号码相关数据发送完毕,下一步进行后续操作
;-------------------------------------------------------------------------------
TEL_SENDCOMM:

	BIT	EVENT,0
	BS	TB,TEL_SENDCOMM_1	;号码
	
	BIT	EVENT,1
	BS	TB,TEL_SENDCOMM_2	;姓名
	
	BIT	EVENT,2
	BS	TB,TEL_SENDCOMM_3	;时间
	
	;BIT	EVENT,3
	;BS	TB,TEL_SENDCOMM_4	;OGM_ID
	
	BIT	EVENT,10
	BS	TB,TEL_SENDCOMM_DISP
	BS	B1,TEL_SENDCOMM_OVEREND	
TEL_SENDCOMM_1:
	CRAM	EVENT,0
	CALL	TELNUM_TOBUF
	BS	ACZ,TEL_SENDCOMM_END

	LACL	0XFF
	CALL	STOR_DAT
	BS	B1,TEL_SENDCOMM_END
TEL_SENDCOMM_2:
	CRAM	EVENT,1
	CALL	TELNAME_TOBUF
	BS	ACZ,TEL_SENDCOMM_END

	LACL	0XFF
	CALL	STOR_DAT
	
	BS	B1,TEL_SENDCOMM_END
TEL_SENDCOMM_3:
	CRAM	EVENT,2
	CALL	TELTIME_TOBUF
	BS	ACZ,TEL_SENDCOMM_END	;没有时间直接退出
	
	LACL	0XFF
	CALL	STOR_DAT

	BS	B1,TEL_SENDCOMM_END
TEL_SENDCOMM_DISP:
	CRAM	EVENT,10	;显示号码	
	LACK	2
	
	RET
TEL_SENDCOMM_OVEREND:
	LACK	1
	RET
TEL_SENDCOMM_END:
	LACK	0
	RET
;-------------------------------------------------------------------------------
.if	TEXT_TEST
TEST_BEEP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK	
	
	LACL	0X3CC9
	SAH	BUF1
	
	LACL	CBEEP_COMMAND		;ON
	SAH	CONF
	CALL    DAM_BIOS
TEST_BEEP_END:
	BS	B1,TEST_BEEP_END
;-------------------------------------------------------------------------------
TEST_VOP:

	SAH	MSG_ID
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK	
	
	LAC	MSG_ID
	SAH	SYSTMP1
TEST_VOP1:	
	LAC	SYSTMP1
	SFR	4
	ANDK	0XF
	ADHK	1
	ORL	0XB000
	SAH	CONF
TEST_VOP_1:
	CALL    DAM_BIOS
	BIT	RESP,6
	BZ	TB,TEST_VOP_1
	
	LAC	SYSTMP1
	ANDK	0XF
	ADHK	1
	ORL	0XB000
	SAH	CONF
TEST_VOP_2:	
	CALL    DAM_BIOS
	BIT	RESP,6
	BZ	TB,TEST_VOP_2
TEST_VOP_3:
	LACL	1000
	SAH	TMR
TEST_VOP_END:
	LAC	TMR
	SBHK	100
	BS	ACZ,TEST_VOP1

	BS	B1,TEST_VOP_END
.endif
;-------------------------------------------------------------------------------

.END
	