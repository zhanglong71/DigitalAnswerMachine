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
	CALL	GET_FLAG
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
	CALL	GET_FLAG
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
;//------------------------------------------------------------------------
;	FUNCTION : SELECT_VP
;	IF ANN_FG.3=0,LANGUAGE(7..4) = LANGUAGE(3..0)*2+1,ELSE
;		LANGUAGE(7..4) = LANGUAGE(3..0)*2+1 
;	INPUT : ANN_FG,3
;//------------------------------------------------------------------------	
SELECT_VP:
	LAC	LANGUAGE
	ANDK	0X07
	SAH	LANGUAGE
	
	LAC	LANGUAGE	;"LANGUAGE(7..4) = LANGUAGE(3..0)*2+1" FOR OGM1
	SFL	5
	ADHK	0X010
	OR	LANGUAGE
	SAH	LANGUAGE

	;BIT	EVENT,8
	;BZ	TB,SELECT_VP_RET
	BIT	ANN_FG,3
	BZ	TB,SELECT_VP_RET
	
	LAC	LANGUAGE	;"LANGUAGE(7..4) = LANGUAGE(3..0)*2+2" FOR OGM2
	ADHK	0X010
	SAH	LANGUAGE

SELECT_VP_RET:	
	RET
;//------------------------------------------------------------------------
;	FUNCTION : SELECT DEFAULT OGM
;	IF ACCH =3,LANGUAGE(7..4) = LANGUAGE(3..0)*2+1,ELSE
;		LANGUAGE(7..4) = LANGUAGE(3..0)*2+2 
;	INPUT : ACCH
;//------------------------------------------------------------------------	
SELECT_OGM:
	SAH	MSG_N
	
	LAC	LANGUAGE
	ANDK	0X07
	SAH	LANGUAGE
	
	LAC	LANGUAGE	;"LANGUAGE(7..4) = LANGUAGE(3..0)*2+1" FOR OGM1
	SFL	5
	ADHK	0X010
	OR	LANGUAGE
	SAH	LANGUAGE

	LAC	MSG_N
	SBHK	3
	BS	ACZ,SELECT_OGM_RET
	
	LAC	LANGUAGE	;"LANGUAGE(7..4) = LANGUAGE(3..0)*2+2" FOR OGM2
	ADHK	0X010
	SAH	LANGUAGE

SELECT_OGM_RET:	
	RET
;//------------------------------------------------------------------------
;	FUNCTION : SET_OGMFG
;	IF 
;	INPUT : ACCH
;//------------------------------------------------------------------------	
SET_OGMFG:
	SRAM	ANN_FG,3
	LACK	4
	SAH	MSG_N
	
	BIT	EVENT,9
	BS	TB,SET_OGMFG_1		;ANSWER OFF
	BIT	EVENT,8
	BS	TB,SET_OGMFG_1		;ANSWER ONLY
	BIT	ANN_FG,13
	BS	TB,SET_OGMFG_1		;MFULL
	
	CRAM	ANN_FG,3
	LACK	3
	SAH	MSG_N
SET_OGMFG_1:
	
	RET
;//------------------------------------------------------------------------
;	OGM_CHK
;	check weather the current OGMx exist?
;	input : EVENT.8		= 0/1---answer ICM/answer only
;	output: 
;		ANN_FG(bit2) 	= 0---not exist
;				  1---exist
;		MSG_ID		= index NO.in current MBOX in current MSG type(OGM)
;		MSG_N = 3/4	= the current OGM index(USR INDEX DATA0)
;//------------------------------------------------------------------------
OGM_CHK:
	SAH	MSG_N		;answer normal/only
	CALL	OGM_STATUS1
	
	RET
;//------------------------------------------------------------------------
;	OGM_STATUS
;	check weather the current OGMx exist?
;	input : EVENT.8		= 0/1---answer ICM/answer only
;	output: 
;		ANN_FG(bit2) 	= 0---not exist
;				  1---exist
;		MSG_ID		= index NO.in current MBOX in current MSG type(OGM)
;		MSG_N = 3/4	= the current OGM index(USR INDEX DATA0)
;//------------------------------------------------------------------------
OGM_STATUS:
	LACK	3
	SAH	MSG_N		;answer normal

	BIT	EVENT,8
	BZ	TB,OGM_STATUS1
	
	LACK	4
	SAH	MSG_N		;answer only
OGM_STATUS1:
	
	CRAM	ANN_FG,2
	
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
	BS	ACZ,OGM_STATUS4
	ADHK	1
	SAH	MSG_T
	
	LACK	1
	SAH	MSG_ID
OGM_STATUS2:	
	LAC	MSG_ID
	SBH	MSG_T
	BZ	SGN,OGM_STATUS4

	LAC	MSG_ID
	ORL	0XA900            	;//check if OGMx exists(GET USER INDEX DATA0)?
        SAH     CONF
        CALL    DAM_BIOS
        
        LAC     RESP			;//LOAD USER ID(MSG_N)
        SBH	MSG_N
        BS      ACZ,OGM_STATUS3		;//OGMx exist?
        
	LAC	MSG_ID
	ADHK	1
	SAH	MSG_ID
	BS	B1,OGM_STATUS2
OGM_STATUS3:
	
        SRAM	ANN_FG,2		;ANN_FG(bit2)=1
        
        LACK	0			;OGMx exist?
        RET
OGM_STATUS4:
	LACK	1			;no OGM
	RET
;-------------------------------------------------------------------------------
;	Function : BEEP
;
;       Generate a "BEEP"	---提示用
;-------------------------------------------------------------------------------	
BEEP:
	LACL	0X025
	CALL	STOR_VP
	LACL	0X3010
	CALL	STOR_VP		;B
	
	RET
;------------------------------------------------------------------------------
;	Function : LBEEP
;
;	Generate a "LONG BEEP"---提示用
;------------------------------------------------------------------------------	
LBEEP:
	LACL	0X3C50
	CALL	STOR_VP		;B___
	
	RET
;-------------------------------------------------------------------------------
;	Function : BBEEP
;
;	Generate two "BBEEP"	---结束用
;-------------------------------------------------------------------------------
BBEEP:
	LACL	0X3010
	CALL	STOR_VP
	LACL	0X005
	CALL	STOR_VP
	LACL	0X3010
	CALL	STOR_VP		;BB
	
	RET
;-------------------------------------------------------------------------------
;       Function : BBBEEP
;
;      Generate three "BBBEEP"	---警报用
;-------------------------------------------------------------------------------
BBBEEP:
	LACL	0X3C09
	CALL	STOR_VP
	LACL	0X005
	CALL	STOR_VP
	LACL	0X3C09
	CALL	STOR_VP
	LACL	0X005
	CALL	STOR_VP
	LACL	0X3C09
	CALL	STOR_VP		;BBB
	
	RET
;;;;;;;;
.IF	TEXT_VOP

;//----------------------------------------------------------------------------
;//       Function : MSG_WEEK
;//
;//       Generate a warning beep
;//----------------------------------------------------------------------------
MSG_WEEK:
	LAC	MSG_ID
	ANDL	0X0FF
	ORL	0XA300
	SAH	CONF
	CALL	DAM_BIOS
	LAC	RESP
	ADHK	28
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
;//----------------------------------------------------------------------------
;//       Function : MSG_HOUR
;//
;//       Generate a warning beep
;//----------------------------------------------------------------------------
MSG_HOUR:
	LAC	MSG_ID
	ANDL	0X0FF
	ORL	0XA200
	SAH	CONF
	CALL	DAM_BIOS
	LAC	RESP
	CALL	ANNOUNCE_NUM
	
	RET
;//----------------------------------------------------------------------------
;//       Function : MSG_MIN
;//
;//       Generate a warning beep
;//----------------------------------------------------------------------------
MSG_MIN:
	LAC	MSG_ID
	ANDL	0X0FF
	ORL	0XA100
	SAH	CONF
	CALL	DAM_BIOS
	LAC	RESP
	CALL	ANNOUNCE_NUM
	
	RET

;-------------------------------------------------------------------------
;	Function : ANNOUNCE_NUM --- 数字入播放队列
;	input : ACCH = 要播放的数字(1..99)
;
;-------------------------------------------------------------------------
ANNOUNCE_NUM:

	SAH	SYSTMP3
	SBHK	21
	BS	SGN,ANNOUNCE_NUM1
	;CALL	HEX_DGT
	
	LAC	SYSTMP3
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
	LAC	SYSTMP3
	ORL	0XFF00
	CALL	STOR_VP
ANNOUNCE_NUM_END:
	
	RET
.ENDIF
;//----------------------------------------------------------------------------
;//       Function : HEX_DGT
;//
;//       Transform a binary value to a BCD value

;//       Input  : ACCH = the binary value
;//       Output : ACCH = the BCD value
;//	  Variable : SYSTMP4,SYSTMP5
;//----------------------------------------------------------------------------
HEX_DGT:
	ANDL	0XFF
	SAH	SYSTMP4
	
	LACK	0
	SAH	SYSTMP5
HEX_DGT_LOOP:
	LAC	SYSTMP4
	SBHK	10
	BS	SGN,HEX_DGT_END
	SAH	SYSTMP4
	
	LAC	SYSTMP5
	ADHK	1
	SAH	SYSTMP5
	BS	B1,HEX_DGT_LOOP
HEX_DGT_END:
	LAC	SYSTMP5
	SFL	4
	ANDL	0X0F0
	OR	SYSTMP4
	
        RET

;//----------------------------------------------------------------------------
;//       Function : DGT_HEX
;//
;//       Transform a BCD value to binary value
;//       Input  : ACCH = the BCD value
;//       Output : ACCH = the binary value
;//	  Variable : SYSTMP4,SYSTMP5
;//----------------------------------------------------------------------------
DGT_HEX:
	SAH	SYSTMP4		;LOW(3..0)
	SFR	4
	ANDK	0XF
	SAH	SYSTMP5		;HIGH(7..4)

	LAC	SYSTMP4
	ANDK	0X0F
	SAH	SYSTMP4
DGT_HEX_LOOP:
	LAC	SYSTMP5
	BS	ACZ,DGT_HEX_END
	
	LAC	SYSTMP4
	ADHK	10
	SAH	SYSTMP4
	
	LAC	SYSTMP5
	SBHK	1
	SAH	SYSTMP5
	BS	B1,DGT_HEX_LOOP
DGT_HEX_END:
	LAC	SYSTMP4
	
        RET
;------------------------------------------------------------------------------
;	Function : clear all new flag of messages
;------------------------------------------------------------------------------
CLR_FLAG:
	LACK	0X07F
	SAH	NEW_ID
	
	LACK	0
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
;	根据MSG_ID设置相应的NEW标志
;	INPUT : ACCH = MSG_ID
;	OUTPUT: NO
;------------------------------------------------------------------------------
SET_FLAG:
	ANDK	0X07F
	SAH	SYSTMP		;STOR MSG_ID
	SAH	NEW_ID
	LACK	1
	SAH	NEW0
	
	LAC	SYSTMP
	SBHK	1
	ANDK	0X0F
	SAH	SYSTMP1		;save the bits you will move(col)
	OUT	SYSTMP1,SHFCR	
	LAC	NEW0
	SFL	0
	SAH	NEW0

	LAC	SYSTMP
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
	RET

;------------------------------------------------------------------------------
;	Function : get new flag of message
;	根据MSG_ID取得相应的NEW标志,并将标志取反作为返回值
;	INPUT : ACCH = MSG_ID(1..99)
;	OUTPUT: ACCH=0/1 ===>new message/not new
;------------------------------------------------------------------------------
GET_FLAG:
	ANDL	0X07F
	SAH	SYSTMP		;STOR MSG_ID
	CALL	MANAGE
	
	LAC	SYSTMP
	SBHK	1
	SFR	4
	ADHK	NEW1
	SAH	SYSTMP1		;the address you will load(ROW)
	
	MAR	+0,1
	LAR	SYSTMP1,1
	LAC	+0,1
	SAH	NEW0		;stor the flag
	
	LAC	SYSTMP
	SBHK	1
	ANDK	0X0F
	SAH	SYSTMP1
	OUT	SYSTMP1,SHFCR	;save the bits you will mov(COL)
	
	LAC	NEW0
	SFR	0
	ANDL	0X01
	SAH	NEW0		;直接将所得NEW0标志取反作返回值(ACCH)
	XORL	0X01
GET_FLAG_END:
	RET
;------------------------------------------------------------------------------
;	Function : set new flag of message
;	根据MSG_ID查找和设转置相应的NEW标志
;	INPUT : ACCH = MSG_ID
;	OUTPUT: NO
;------------------------------------------------------------------------------
MANAGE:
	ANDL	0X07F
	SAH	SYSTMP		;STOR MSG_ID
	
	LAC	NEW_ID
	SBH	SYSTMP		;查NEW标志设置过吗(减数与被减数的关系与播放顺序有关,此时是反序)?
	BS	SGN,CHK_NEWFLAG_END
	
	LAC	SYSTMP
	ORL	0XA800
	SAH	CONF
	CALL	DAM_BIOS
	LAC	RESP
	BZ	ACZ,CHK_NEWFLAG_END
	
	LAC	SYSTMP
	CALL	SET_FLAG
CHK_NEWFLAG_END:
		
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
;	根据MSG_ID取得相应的USE_DAT是否用过(0/1表示没用/用过)
;	INPUT : ACCH = MSG_ID(1..99)
;	OUTPUT: ACCH=0/1 ===>not used/been used
;------------------------------------------------------------------------------
GET_DATFLAG:
	ANDL	0X07F
	SAH	SYSTMP		;STOR MSG_ID

	LAC	SYSTMP
	SBHK	1
	SFR	4
	ADHK	NEW1
	SAH	SYSTMP1		;the address you will load(ROW)
	
	MAR	+0,1
	LAR	SYSTMP1,1
	LAC	+0,1
	SAH	NEW0		;stor the flag
	
	LAC	SYSTMP
	SBHK	1
	ANDK	0X0F
	SAH	SYSTMP1
	OUT	SYSTMP1,SHFCR	;save the bits you will mov(COL)
	
	LAC	NEW0
	SFR	0
	ANDL	0X01
	;SAH	NEW0		;直接将所得NEW0标志取反作返回值(ACCH)
	;XORL	0X01
GET_DATFLAG_END:
	RET
;-------------------------------------------------------------------------------
;	Function : SERACH_USEID
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
	
	CALL	GET_DATFLAG
	BZ	ACZ,SERACH_USEID_LOOP2	
	
	LAC	SYSTMP0
SERACH_USEID_END:
	RET
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
.END
	