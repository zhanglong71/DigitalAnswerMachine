LOAD_LOCF_FIXF:
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
;	input : ACCH = 	OGMx(1/2/3/4/5)
;			EVENT.8
;	output: ACCH = 	OGMx(1/2/3/4/5)
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
;	input : ACCH = (OGMx = 1/2/3/4/5)&(EVENT.8)
;	output: ACCH = MSG_ID --- 0/~0 --- no OGM/the OGMx
;
;		MSG_ID		= index NO.in current MBOX in current MSG type(OGM)
;		MSG_N = 0x70||OGM_ID = the current OGM index(USR INDEX DATA0)
;-------------------------------------------------------------------------------
OGM_SELECT:			;用于录音/放音时确定OGM_ID(非接线时用)

	CALL	GET_OGMID
	ORK	0X70
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
;	output: ACCH = MSG_ID --- 0/~0 --- no OGM/the OGMx
;
;		MSG_ID		= index NO.in current MBOX in current MSG type(OGM)
;		MSG_N = 0x70||OGM_ID = the current OGM index(USR INDEX DATA0)
;-------------------------------------------------------------------------------
OGM_STATUS:			;接线时用
	LAC	VOI_ATT
	SFR	8
	ANDK	0X0F
	ORK	0X70
	SAH	MSG_N

	SBHK	COGM5_ID
	BS	ACZ,OGM_STATUS0
	BIT	EVENT,8		;answer only?
	BS	TB,OGM_STATUS0
	BIT	EVENT,9		;answer off?
	BS	TB,OGM_STATUS0
	BIT	ANN_FG,13	;memoful?
	BS	TB,OGM_STATUS0
	BS	B1,OGM_STATUS1
OGM_STATUS0:	
	LACK	COGM5_ID
	SAH	MSG_N		;answer only(OGM5)
OGM_STATUS1:
	LACL	0XD000
	CALL	DAM_BIOSFUNC
	LACL	0XD202
	CALL	DAM_BIOSFUNC
	LACL	0X3000
	CALL	DAM_BIOSFUNC
	SAH	MSG_ID
OGM_STATUS2:	
	LAC	MSG_ID
	BS	ACZ,OGM_STATUS3
	ORL	0XA900            	;check if OGMx exists(GET USER INDEX DATA0)?
        CALL    DAM_BIOSFUNC
        SBH	MSG_N			;LOAD USER ID(MSG_N)
        BS      ACZ,OGM_STATUS3		;OGMx exist?
        
	LAC	MSG_ID
	SBHK	1
	SAH	MSG_ID
	BS	B1,OGM_STATUS2
OGM_STATUS3:
        LAC	MSG_ID

	RET

;------------------------------------------------------------------------------
;	Function : GET_LANGUAGE attribute
;	input : no
;	output: ACCH = 当前语言值
;------------------------------------------------------------------------------
GET_LANGUAGE:
.if	0	2012-4-19 19:48 VOP has been changed base v13. spanish take place of english, and removed the germany
	LAC	VOI_ATT
	SFR	12
	ANDK	0X03
.else
	LACK	0
.endif
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
;------------------------------------------------------------------------------
;	Function : B_VOP
;	BEEP prompt
;	Generate a "BEEP or not"	---提示用
;------------------------------------------------------------------------------	
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
;------------------------------------------------------------------------------	
BB_VOP:
	BIT	VOI_ATT,14
	BS	TB,BBEEP
	BS	B1,NOB_VOP
;------------------------------------------------------------------------------
;	Function : BEEP
;	
;	Generate a "BEEP"	---提示用
;------------------------------------------------------------------------------	
BEEP:
	LACL	0X005
	CALL	STOR_VP
	LACL	0X2010
	CALL	STOR_VP		;B
	
	RET
;------------------------------------------------------------------------------
;	Function : LBEEP
;	
;	Generate a "LONG BEEP"---提示用
;------------------------------------------------------------------------------	
LBEEP:
	LACL	0X2050
	CALL	STOR_VP		;B___
	
	RET
;------------------------------------------------------------------------------
;	Function : BBEEP
;	
;	Generate two "BEEP"	---结束用
;------------------------------------------------------------------------------	
BBEEP:
	LACL	0X2010
	CALL	STOR_VP
	LACL	0X005
	CALL	STOR_VP
	LACL	0X2010
	CALL	STOR_VP		;BB
	
	RET
;------------------------------------------------------------------------------
;	Function : BBBEEP
;	
;	Generate three "BEEP"	---报错用
;------------------------------------------------------------------------------	
BBBEEP:
	LACL	0X230B
	CALL	STOR_VP
	LACL	0X1C0B
	CALL	STOR_VP
	LACL	0X200B
	CALL	STOR_VP		;BBB
	
	RET

;------------------------------------------------------------------------------
;	Function : VP_MESSAGE
;	
;	Generate a VP "message"
;------------------------------------------------------------------------------
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
;------------------------------------------------------------------------------
;	Function : VP_MESSAGES
;	
;	Generate a VP "messages"
;------------------------------------------------------------------------------
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
;------------------------------------------------------------------------------
;	Function : VP_ENDOF
;	
;	Generate a VP "end of"
;------------------------------------------------------------------------------
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
;------------------------------------------------------------------------------
;	Function : VP_NO
;	
;	Generate a VP "no"
;------------------------------------------------------------------------------
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
;------------------------------------------------------------------------------
;	Function : VP_NEW
;	
;	Generate a VP "new"
;------------------------------------------------------------------------------
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
;------------------------------------------------------------------------------
;	Function : VP_MAILBOX
;	
;	Generate a VP "mail box"
;------------------------------------------------------------------------------
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

;------------------------------------------------------------------------------
;	Function : VP_MEMFUL
;	
;	Generate a VP "memory is full"
;------------------------------------------------------------------------------
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
;------------------------------------------------------------------------------
;	Function : HEX_DGT
;	
;	Transform a binary value to a BCD value

;	Input  : ACCH = the binary value
;	Output : ACCH = the BCD value
;	Variable : SYSTMP1,SYSTMP2
;------------------------------------------------------------------------------
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

;------------------------------------------------------------------------------
;	Function : DGT_HEX
;
;	Transform a BCD value to binary value
;	Input  : ACCH = the BCD value
;	Output : ACCH = the binary value
;	Variable : SYSTMP1,SYSTMP2
;------------------------------------------------------------------------------
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
;-------------------------------------------------------------------------------
;	HEXDIV
;	input : SYSTMP1 = 被除数
;	      : SYSTMP2 = 除数
;	output: SYSTMP1 = 余数
;	      : SYSTMP2 = 商
;-------------------------------------------------------------------------------
HEXDIV:
	PSH	SYSTMP3

	LACK	0
	SAH	SYSTMP3
HEXDIV_LOOP:
	LAC	SYSTMP1
	SBH	SYSTMP2
	BS	SGN,HEXDIV_END
	SAH	SYSTMP1
	
	LAC	SYSTMP3
	ADHK	1
	SAH	SYSTMP3
	BS	B1,HEXDIV_LOOP
HEXDIV_END:
	LAC	SYSTMP3
	SAH	SYSTMP2

	POP	SYSTMP3
	
        RET
;-------------------------------------------------------------------------------
;	SEND_HHMMSS
;	input : ACCH = second
;	output: no
;-------------------------------------------------------------------------------
SEND_HHMMSS:
	SAH	SYSTMP0
	SAH	SYSTMP1
	LACL	3600
	SAH	SYSTMP2
	CALL	HEXDIV	;SYSTMP2=hh,SYSTMP1=ss

	LAC	SYSTMP2
	SAH	SYSTMP3	;Save hour

	LACK	60
	SAH	SYSTMP2
	CALL	HEXDIV
;---
	LACL	0XD3
	CALL	SEND_DAT	;(hh:mm:ss)
	LAC	SYSTMP3		;时
	CALL	SEND_DAT
	LAC	SYSTMP2		;分
	CALL	SEND_DAT
	LAC	SYSTMP1		;秒
	CALL	SEND_DAT
	
        RET
;-------------------------------------------------------------------------------
;	Function : VALUE_ADD	(ACCH+1==>ACCH)
;	input : 	ACCH ==>SYSTMP0
;	output: 	ACCH
;	minvalue:	SYSTMP1
;	maxvalue:	SYSTMP2
;-------------------------------------------------------------------------------
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

;############################################################################
;	FUNCTION : REAL_DEL
;	INPUT : NO
;	OUTPUT: NO
;############################################################################
REAL_DEL:
	LACL	0X6100
	CALL	DAM_BIOSFUNC
	
	RET
;############################################################################
;	FUNCTION : SET_USRDAT
;	INPUT : ACCH = USER INDEX DATA0
;	OUTPUT: NO
;############################################################################
SET_USRDAT:
	ANDL	0XFF
	ORL	0X8D00
	CALL	DAM_BIOSFUNC
	
	RET
;############################################################################
;	FUNCTION : GET_USRDAT
;	INPUT : ACCH = MSG_ID
;	OUTPUT: ACCH = USER INDEX DATA0
;############################################################################
GET_USRDAT:
	ANDK	0X7F
	ORL	0XA900
	CALL	DAM_BIOSFUNC
	
	RET

;############################################################################
;	FUNCTION : GET_USRDATNEW
;	INPUT : ACCH = MSG_ID
;	OUTPUT: ACCH = USER INDEX DATA0
;############################################################################
GET_USRDATNEW:
	ANDK	0X7F
	ORL	0XA980
	CALL	DAM_BIOSFUNC
	
	RET
;############################################################################
;	FUNCTION : GET_ONLYID
;	INPUT : ACCH = MSG_ID
;	OUTPUT: ACCH = only id
;############################################################################
GET_ONLYID:
	ANDK	0X7F
	ORL	0XA600
	CALL	DAM_BIOSFUNC
	
	RET
;############################################################################
;	FUNCTION : GET_ONLYID
;	INPUT : ACCH = MSG_ID
;	OUTPUT: ACCH = only id
;############################################################################
GET_ONLYIDNEW:
	ANDK	0X7F
	ORL	0XA680
	CALL	DAM_BIOSFUNC
	
	RET
;############################################################################
;	FUNCTION : SET_USRDAT1
;	INPUT : ACCH = USER INDEX DATA1
;	OUTPUT: NO
;############################################################################
SET_USRDAT1:
	ANDL	0XFF
	ORL	0X8E00
	CALL	DAM_BIOSFUNC
	
	RET
;############################################################################
;	FUNCTION : GET_USRDAT1
;	INPUT : ACCH = MSG_ID
;	OUTPUT: ACCH = USER INDEX DATA1
;############################################################################
GET_USRDAT1:
	ANDL	0XFF
	ORL	0XAA00
	CALL	DAM_BIOSFUNC

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
	
	LAC	ANN_FG
	ANDL	~(1<<8)
	SAH	ANN_FG
NEW_ICMCHK1:
	LAC	SYSTMP0
	SBHK	1
	SAH	SYSTMP0
	BS	ACZ,NEW_ICMCHK2
	ORL	0X080			;new flag
	CALL	GET_USRDAT1
	SBHK	CTAG_ICM		;ICM DATA ?
	BZ	ACZ,NEW_ICMCHK1
	
	LAC	ANN_FG
	ORL	(1<<8)
	SAH	ANN_FG	;Set the bit once the new message exist
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
	LAC	ANN_FG
	ORK	1<<5
	SAH	ANN_FG

	BIT	ANN_FG,8
	BS	TB,NEW_ICMCHK_END
	
	LAC	ANN_FG
	ANDL	~(1<<5)
	SAH	ANN_FG

	BS	B1,NEW_ICMCHK_END
NEW_ICMCHK2_2_1:
	LAC	ANN_FG
	ORK	1<<6
	SAH	ANN_FG
	BIT	ANN_FG,8
	BS	TB,NEW_ICMCHK_END
	LAC	ANN_FG
	ANDL	~(1<<6)
	SAH	ANN_FG
	BS	B1,NEW_ICMCHK_END
NEW_ICMCHK2_3_1:
	LAC	ANN_FG
	ORL	1<<7
	SAH	ANN_FG
	BIT	ANN_FG,8
	BS	TB,NEW_ICMCHK_END
	LAC	ANN_FG
	ANDL	~(1<<7)
	SAH	ANN_FG
	;BS	B1,NEW_ICMCHK_END
NEW_ICMCHK_END:
	RET

;############################################################################
;	FUNCTION : GET_VPTLEN
;	INPUT : ACCH = MSG_ID
;	OUTPUT: ACCH = RECORD LENGTH
;############################################################################
GET_VPTLEN:
	ANDK	0X7F
	ORL	0XA400
	CALL	DAM_BIOSFUNC

	RET

;############################################################################
;	FUNCTION : SET_DELMARK
;	INPUT : MSG_ID     
;	OUTPUT: NO
;############################################################################
SET_DELMARK:
	ANDK	0X7F
	ORL	0X2080
	CALL	DAM_BIOSFUNC

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
	CALL	SEND_DAT
	
	CALL	GET_LANGUAGE
	CALL	SEND_DAT
	
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
	CALL	SEND_DAT
;-
	LAC	LOCACODE
	SFR	12
	ANDK	0X0F
	CALL	SEND_DAT	;local code 1
;-
	LAC	LOCACODE
	SFR	8
	ANDK	0X0F
	CALL	SEND_DAT	;local code 2
;-
	LAC	LOCACODE
	SFR	4
	ANDK	0X0F
	CALL	SEND_DAT	;local code 3
;-
	LAC	LOCACODE
	ANDK	0X0F
	CALL	SEND_DAT	;local code 4
;-
	LAC	LOCACODE1
	ANDK	0X0F
	CALL	SEND_DAT	;local code 5
	
	RET
;############################################################################
;       Function : TOSENDBUF
;	将以ADDR_S为基址以为OFFSET_S变址以COUNT为长度(byte)的数据送到发送缓冲区
;	input  : COUNT = length of data
;		 OFFSET_S = offset address
;		 ADDR_S = base address
;	OUTPUT : ACCH = no
;
;	variable:SYSTMP2
;############################################################################
TOSENDBUF:
	LAC	COUNT
	SBHK	1
	SAH	COUNT
	BS	SGN,TOSENDBUF_END
	CALL	GETBYTE_DAT
	CALL	SEND_DAT
	BS	B1,TOSENDBUF
TOSENDBUF_END:

	RET
;############################################################################
;       Function : TELNUM_TOBUF
;	将以ADDR_S为基址的标志数据送到发送缓冲区
;	input  : 
;		 ADDR_S = BASE address
;	OUTPUT : ACCH = no
;
;	variable:SYSTMP2
;############################################################################
TELFLAG_TOBUF:
	LACL	0X80
	CALL	SEND_DAT
	LACL	0X80
	CALL	SEND_DAT
	LACK	4		;length = 4(NEW_ID+1,NEW_ID+2)
	SAH	COUNT
	CALL	TOSENDBUF

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
	MAR	+0,1
	LAR	ADDR_S,1
	
	LAC	+0,1
	ANDL	0X80
	BS	ACZ,TELNUM_TOBUF_END	;有号码吗?
	LAC	+0,1
	ANDK	0X7F
	ADHK	1
	SFR	1
	SAH	COUNT		;the length
	
	LACL	0X80
	CALL	SEND_DAT
	LAC	COUNT
	CALL	SEND_DAT

	LACK	4		;add the flag length
	SAH	OFFSET_S
	CALL	TOSENDBUF
	
	LACK	1
TELNUM_TOBUF_END:
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
	SAH	COUNT		;the length

	LACK	0
	SAH	OFFSET_S	;add the NUM length

	LAC	+0,1
	ANDL	0X80
	BS	ACZ,TELNAME_TOBUF_1
	LAC	+0,1
	ANDK	0X7F
	ADHK	1
	SFR	1
	SAH	OFFSET_S	;add the NUM length
TELNAME_TOBUF_1:
	LAC	OFFSET_S
	ADHK	4
	SAH	OFFSET_S	;add the flag length
	
	LACL	0X80
	CALL	SEND_DAT
	LACK	0X20
	OR	COUNT
	CALL	SEND_DAT
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
	
	LACK	0
	SAH	OFFSET_S
	
	LAC	+0,1
	ANDL	0X80
	BS	ACZ,TELTIME_TOBUF_1
	LAC	+0,1
	ANDK	0X7F
	ADHK	1
	SFR	1
	SAH	OFFSET_S	;add NUM length
TELTIME_TOBUF_1:
	LAC	+0,1
	ANDL	0X8000
	BS	ACZ,TELTIME_TOBUF_2
	LAC	+0,1
	SFR	8
	ANDK	0X7F
	ADH	OFFSET_S		
	SAH	OFFSET_S	;add NAME length
TELTIME_TOBUF_2:	
	LAC	OFFSET_S
	ADHK	4
	SAH	OFFSET_S	;add flag length
	
	LACL	0X80
	CALL	SEND_DAT
	LACK	0X44
	CALL	SEND_DAT

	LACK	4
	SAH	COUNT
	CALL	TOSENDBUF	;stor data into send-buffer
	
	LACK	1
TELTIME_TOBUF_END:
	EINT	;?????????????????????????????????	
	RET
;-------------------------------------------------------------------------
;	Function : SET_WAITFG	
;	从以ADDR_S为起始地址以OFFSET_S为offset的队列取数据,根据数据设等待状态
;	INPUT : 
;		ADDR_S = the BASE you will get data from
;	output: EVENT(3..0)
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

	LAC	EVENT
	ORK	1
	SAH	EVENT
SET_WAITFG_2:			;姓名
	LAC	+,1
	ANDL	0X8000
	BS	ACZ,SET_WAITFG_3

	LAC	EVENT
	ORK	1<<1
	SAH	EVENT
SET_WAITFG_3:			;时间
	
	LAC	+0,1
	ANDL	0X080
	BS	ACZ,SET_WAITFG_4
	
	LAC	EVENT
	ORK	1<<2
	SAH	EVENT
SET_WAITFG_4:			;OGM_ID
	LAC	+0,1
	ANDL	0X8000
	BS	ACZ,SET_WAITFG_END
	
	;LAC	EVENT
	;ORK	1<<3
	;SAH	EVENT		;???暂时不用
SET_WAITFG_END:	
	EINT	;???????????????????????????
	RET
;-------------------------------------------------------------------------
;	Function : GETBYTE_DAT	
;	从以ADDR_S为起始地址以COUNT为offset的队列取数据(一个字节)
;	INPUT : OFFSET_S = the offset you will get data from
;		ADDR_S = the BASE you will get data from
;	output: ACCH = the data you got
;-------------------------------------------------------------------------
GETBYTE_DAT:
	DINT	;?????????????????????????????????????
	PSH	SYSTMP1
	PSH	SYSTMP2	
GETBYTEDAT_GET:
	LAC	OFFSET_S
	SFR	1
	ADH	ADDR_S
	SAH	SYSTMP1		;GET ADDR(row)
	
	LAC	OFFSET_S
	ADHK	1
	SAH	OFFSET_S	;!!!Update for next Byte(offset_s对应下一个地址，所以下面的判断要注意)
	
	MAR	+0,1
	LAR	SYSTMP1,1
	
	LAC	OFFSET_S
	ANDK	0X01			;GET ADDR(col)
	BS	ACZ,GETBYTEDAT_GET2	;!!!OFFSET_S	;Updated for next Byte

	LAC	+0,1			;奇地址
	ANDL	0X0FF
	BS	B1,GETBYTEDAT_END
GETBYTEDAT_GET2:			;偶地址
	LAC	+0,1
	SFR	8
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
;		OFFSET_D = the offset you will stor data
;		ADDR_D = the BASE you will stor data
;	output: no
;-------------------------------------------------------------------------
STORBYTE_DAT:
	DINT	;????????????????????????????
	PSH	SYSTMP1
	PSH	SYSTMP2
	
	ANDL	0XFF
	SAH	SYSTMP2		;stor DAT
STORBYTEDAT_STOR:
	LAC	OFFSET_D
	SFR	1
	ADH	ADDR_D
	SAH	SYSTMP1		;GET ADDR(row)
	
	LAC	OFFSET_D
	ADHK	1
	SAH	OFFSET_D	;!!!Update for next Byte(offset_d对应下一个地址，所以下面的判断要注意)

	MAR	+0,1
	LAR	SYSTMP1,1

	LAC	OFFSET_D
	ANDK	0X01			;GET ADDR(col)
	BS	ACZ,STORBYTEDAT_STOR2
	
	LAC	+0,1		;奇地址
	ANDL	0XFF00
	OR	SYSTMP2
	SAH	+0,1
	BS	B1,STORBYTEDAT_END	
STORBYTEDAT_STOR2:		;偶地址
	LAC	+0,1	
	ANDL	0XFF
	SAH	+0,1
	
	LAC	SYSTMP2
	SFL	8
	ANDL	0XFF00
	OR	+0,1
	SAH	+0,1
STORBYTEDAT_END:
	POP	SYSTMP2
	POP	SYSTMP1	
	EINT	;????????????????????????
	RET

;-------------------------------------------------------------------------------
;	Function : CONCEN_DAT
;	将以ADDR_S为基址,OFFSET_S为起始偏移,长度为COUNT的数据进行压缩并存放在
;	将以ADDR_D为基址,OFFSET_D为起始偏移的RAM区域
;	INPUT : ACCH = 待压缩数据的长度(byte)
;		OFFSET_S = 待压缩数据的起始偏移
;		OFFSET_D = 压缩后数据的起始偏移
;		ADDR_S = 待压缩数据的基地址
;		ADDR_D = 压缩后数据的基地址
;	OUTPUT: no
;Note:地址生长方向:由低到高
;Example : 1,2,3,4,5 ==> 0x12,0x34,0x5F
;-------------------------------------------------------------------------------
CONCEN_DAT:
	LAC	COUNT
	SAH	SYSTMP1		;要处理的长度
	
	LACK	0
	SAH	SYSTMP2		;已处理的长度
CONCEN_DAT_LOOP:
	LAC	SYSTMP2
	SBH	SYSTMP1
	BZ	SGN,CONCEN_DAT_END

	CALL	GETBYTE_DAT		;get first
	SAH	SYSTMP4

	BIT	SYSTMP2,0
	BS	TB,CONCEN_DAT_LOW
;CONCEN_DAT_HIGH:	;偏移地址为偶数的放在高位	
	LAC	SYSTMP4
	SFL	4
	ANDL	0XF0
	ORK	0X0F		;下一位直接设为0xF
	SAH	SYSTMP3
	
	BS	B1,CONCEN_DAT_LOOP_1
CONCEN_DAT_LOW:		;偏移地址为奇数的放在低位
	LAC	SYSTMP3
	ANDL	0XF0
	SAH	SYSTMP3
	
	LAC	SYSTMP4
	ANDK	0X0F
	OR	SYSTMP3
	SAH	SYSTMP3
	
	LAC	OFFSET_D
	SBHK	1
	SAH	OFFSET_D	;Note:last byte 
CONCEN_DAT_LOOP_1:
	LAC	SYSTMP3		;get dat
	CALL	STORBYTE_DAT	;store

	LAC	SYSTMP2
	ADHK	1
	SAH	SYSTMP2		;Next Byte
	BS	B1,CONCEN_DAT_LOOP
CONCEN_DAT_END:	
	LACL	0XFF
	CALL	STORBYTE_DAT	;以0XFF结束
	
	RET
;-------------------------------------------------------------------------------
;	Function : DECONCEN_DAT
;	将以 ADDR_S为基址,长度为COUNT的数据进行解压缩(适合地址由高向低展开)
;	将数据存在以 ADDR_D为基址的地区
;	INPUT : COUNT = 待解压缩数据的实际长度(解压后的长度byte)
;		OFFSET_S = 待解压缩数据的起始偏移
;		OFFSET_D = 解压缩后的数据存放的起始偏移
;		ADDR_S = 待解压缩数据的基址
;		ADDR_D = 解压缩后的数据存放的基址
;	OUTPUT: no
;Example : 1,2,3,4,5 ==> 0x12,0x34,0x5F
;-------------------------------------------------------------------------------
DECONCEN_DAT:
	LAC	COUNT
	SBHK	1
	SAH	COUNT
	ADH	OFFSET_D
	SAH	OFFSET_D	;长度转换成==>处理后存放数据的偏移地址
DECONCEN_DAT_LOOP:
	LAC	COUNT
	BS	SGN,DECONCEN_DAT_END

	LAC	OFFSET_D
	SFR	1
	SAH	OFFSET_S
	CALL	GETBYTE_DAT	;get dat
	SAH	SYSTMP2

	BIT	OFFSET_D,0
	BS	TB,DECONCEN_DAT_LOW
;DECONCEN_DAT_HIGH:	
	LAC	SYSTMP2
	SFR	4
	SAH	SYSTMP2
DECONCEN_DAT_LOW:
	LAC	SYSTMP2
	ANDK	0XF
	SAH	SYSTMP2

	LAC	SYSTMP2	
	CALL	STORBYTE_DAT	;stor dat
	
	LAC	OFFSET_D
	SBHK	2		;Note:offset_d increase one in STORBYTE_DAT
	SAH	OFFSET_D
	
	LAC	COUNT
	SBHK	1
	SAH	COUNT
	BS	B1,DECONCEN_DAT_LOOP	;循环次数
DECONCEN_DAT_END:	
	RET
;-------------------------------------------------------------------------------
;	Function : MOVE_LTOH
;	从以ADDR_S为基址,OFFSET_S为起始偏移,长度为COUNT的数据移动
;	到以ADDR_D为基址,OFFSET_D为起始偏移的地方
;	INPUT : COUNT = 要移动的数据的长度byte
;		OFFSET_S = the offset
;		OFFSET_D = the offset
;		ADDR_S = BASE address
;		ADDR_D = BASE address
;	OUTPUT: no
;NOTE : move high address data first(ADDR_S+OFFSET_S/2 < ADDR_D+OFFSET_D/2)
;-------------------------------------------------------------------------------
MOVE_LTOH:
	LAC	OFFSET_S
	ADH	COUNT
	SBHK	1
	SAH	OFFSET_S	;先移到最大偏移处
	
	LAC	OFFSET_D
	ADH	COUNT
	SBHK	1
	SAH	OFFSET_D	;先移到最大偏移处
MOVE_LTOH_LOOP:
	LAC	COUNT
	SBHK	1
	SAH	COUNT
	BS	SGN,MOVE_LTOH_END

	CALL	GETBYTE_DAT	;get offset
	CALL	STORBYTE_DAT	;stor

	LAC	OFFSET_S
	SBHK	2
	SAH	OFFSET_S
	
	LAC	OFFSET_D
	SBHK	2
	SAH	OFFSET_D
	BS	B1,MOVE_LTOH_LOOP
MOVE_LTOH_END:	
	RET
;-------------------------------------------------------------------------------
;	Function : MOVE_HTOL
;	从以ADDR_S为基址,OFFSET_S为起始偏移,长度为COUNT的数据移动
;	到以ADDR_D为基址,OFFSET_D为起始偏移的地方
;	INPUT : COUNT = 要移动的数据的长度byte
;		OFFSET_S = the offset
;		OFFSET_D = the offset
;		ADDR_S = BASE address
;		ADDR_D = BASE address
;	OUTPUT: no
;NOTE : move low address data first(ADDR_S+OFFSET_S/2 > ADDR_D+OFFSET_D/2)
;-------------------------------------------------------------------------------
MOVE_HTOL:
	LAC	COUNT
	SBHK	1
	SAH	COUNT
	BS	SGN,MOVE_HTOL_END

	CALL	GETBYTE_DAT
	CALL	STORBYTE_DAT
	BS	B1,MOVE_HTOL
MOVE_HTOL_END:
	
	RET
;-------------------------------------------------------------------------------
;	Function : RAM_STOR
;	将ADDR_D为基址,OFFSET_D为起始偏移,长度为COUNT的地方,填充数据
;	INPUT : ACCH = 要填充的数据
;		COUNT = 要填充的数据的长度byte
;		OFFSET_D = the offset
;		ADDR_D = BASE address
;	OUTPUT: no
;NOTE : move low address data first(ADDR_S+OFFSET_S/2 > ADDR_D+OFFSET_D/2)
;-------------------------------------------------------------------------------
RAM_STOR:
	SAH	SYSTMP1
RAM_STOR_LOOP:	
	LAC	COUNT
	SBHK	1
	SAH	COUNT
	BS	SGN,RAM_STOR_END

	LAC	SYSTMP1
	CALL	STORBYTE_DAT
	BS	B1,RAM_STOR_LOOP
RAM_STOR_END:
	
	RET
;-------------------------------------------------------------------------------
;	Function : TEL_SENDCOMM
;	INPUT : EVENT(2,1,0)/ADDR_S
;	
;	OUTPUT: ACCH =  0 - 发送了一部分
;			1 - 所有发送工作完毕()
;			2 - 号码相关数据发送完毕,下一步进行后续操作
;-------------------------------------------------------------------------------
TEL_SENDCOMM:
	CALL	TELFLAG_TOBUF	;Flag
	LACL	0XFF
	CALL	SEND_DAT

	CALL	TELNUM_TOBUF	;号码
	LACL	0XFF
	CALL	SEND_DAT

	CALL	TELNAME_TOBUF	;姓名
	LACL	0XFF
	CALL	SEND_DAT

	CALL	TELTIME_TOBUF	;Time
	LACL	0XFF
	CALL	SEND_DAT

	LACK	0
	RET

;-------------------------------------------------------------------------------
;	DATETIME_CHK
;	use to check week and update it in idle mode 
;-------------------------------------------------------------------------------	
DATETIME_CHK:
	lipk	9

	;IN	SYSTMP0,RTCMS		;Get Minute
	
	IN	SYSTMP0,RTCWH		;Get Week
	LAC	SYSTMP0
	SFR	8
	ANDK	0X7F
	CALL	DGT_HEX
	SBH	TMR_WEEK
	BS	ACZ,DATETIME_CHK_END	;如果一样，就不必重新写入
;---有更新
	LACK	CGROUP_DATETIME
	CALL	SET_TELGROUP
	
	LACK	1
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK
	CALL	GC_CHK
	
	CALL	DATETIME_WRITE
	
DATETIME_CHK_END:	
	RET
;############################################################################
;
;	Function : DATETIME_WRITE
;	save the DAM date/time in working group
;	input  : no
;	output : ACCH = 0/!0 ==>SUCCESS/ERROR
;---取时钟时间并保存(!!!BCD -> DGT)
;############################################################################
DATETIME_WRITE:
	LACK	CGROUP_DATETIME
	CALL	SET_TELGROUP

	lipk    9
	IN	SYSTMP0,RTCMD	;Month/Day
	IN	SYSTMP1,RTCWH	;Week/Hour
	IN	SYSTMP2,RTCMS	;Minute/Second
;---month	
	LAC	SYSTMP0
	SFR	8
	ANDK	0X1F
	CALL	DGT_HEX
	CALL	DAT_WRITE
	BZ	ACZ,DATETIME_WRITE_END	;month没问题继续/有问题结束
;---day
	LAC	SYSTMP0
	ANDK	0X3F
	CALL	DGT_HEX
	CALL	DAT_WRITE
	BZ	ACZ,DATETIME_WRITE_END	;day没问题继续/有问题结束
;---hour
	LAC	SYSTMP1
	ANDK	0X3F
	CALL	DGT_HEX
	CALL	DAT_WRITE
	BZ	ACZ,DATETIME_WRITE_END	;hour没问题继续/有问题结束
;---minute

	LAC	SYSTMP2
	SFR	8
	ANDK	0X7F
	CALL	DGT_HEX
	;SAH	TMR_MINUTE
	CALL	DAT_WRITE
	BZ	ACZ,DATETIME_WRITE_END	;minute没问题继续/有问题结束
;---week
	LAC	SYSTMP1
	SFR	8
	ANDK	0X7
	SAH	TMR_WEEK
	CALL	DAT_WRITE
	BZ	ACZ,DATETIME_WRITE_END	;week没问题继续/有问题结束

DATETIME_WRITE_END:	
	CALL	DAT_WRITE_STOP

	RET
;-------------------------------------------------------------------------------
.END
	