.LIST
;//-----------------------------------------------------------------------------
;//       Function : BEEP
;//
;//       Generate a "BEEP"	---提示用
;//-----------------------------------------------------------------------------	
BEEP:
	LACL	0X005
	CALL	STOR_VP
	LACL	0X3010
	CALL	STOR_VP		;B
	
	RET
;//-----------------------------------------------------------------------------
;//       Function : LBEEP
;//
;//       Generate a "LONG BEEP"---提示用
;//-----------------------------------------------------------------------------	
LBEEP:
	LACL	0X005
	CALL	STOR_VP
	LACL	0X3050
	CALL	STOR_VP		;B___
	
	RET
;//-----------------------------------------------------------------------------
;//       Function : BBEEP
;//
;//       Generate two "BEEP"	---结束用
;//-----------------------------------------------------------------------------	
BBEEP:
	LACL	0X3010
	CALL	STOR_VP
	LACL	0X005
	CALL	STOR_VP
	LACL	0X3010
	CALL	STOR_VP		;BB
	
	RET
;//-----------------------------------------------------------------------------
;//       Function : BBBEEP
;//
;//       Generate three "BEEP"	---报错用
;//-----------------------------------------------------------------------------
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
;-------------------------------------------------------------------------------
;	INPUT : no
;	OUTPUT: no
;-------------------------------------------------------------------------------
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
;	Function : SET_BIT
;	将相应位置1,以ACCH(15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0)返回
;	INPUT : ACCH = NO.(0..15)
;	OUTPUT: ACCH = 
;------------------------------------------------------------------------------
SET_BIT:
	PSH	SYSTMP0
	PSH	SYSTMP1
	
	ANDK	0X0F
	SAH	SYSTMP1		;STOR bit NO.
	LACK	1
	SAH	SYSTMP0
	
	LAC	SYSTMP1
	BS	ACZ,SET_BIT_END
	lipk	0
	OUT	SYSTMP1,SHFCR
	ADHK	0
	LAC	SYSTMP0
	SFL	0
	SAH	SYSTMP0

SET_BIT_END:
	LAC	SYSTMP0

	POP	SYSTMP1
	POP	SYSTMP0

	ADHK	0
		
	RET
;-------
CLR_BIT:
	CALL	SET_BIT
	XORL	0XFFFF
	RET
;------------------------------------------------------------
;	manage message when a FFW_key pressed during playing
;	NEW1,NEW2,NEW3,NEW4,NEW5,NEW6,NEW7(new message exist)
;	to check which message you should play
;	input : MSG_ID(mapping the message you play just)
;		MSG_T(MSG_N)---the number of total message
;	output: ACCH=0---MSG_ID(mapping the message you will play next)
;		ACCH=1---fail
;	variable : no
;	subroutine : GET_FLAG
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
;	variable : no
;	subroutine : GET_FLAG
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
;------------------------------------------------------------------------------
;	Function : get new flag of message
;	根据MSG_ID取得相应的NEW标志,并将标志取反作为返回值
;	INPUT : ACCH = MSG_ID(1..99)
;	OUTPUT: ACCH=0/1 ===>new message/not new
;	variable : SYSTMP0,SYSTMP1,SYSTMP2
;	subroutine : MANAGE
;------------------------------------------------------------------------------
GET_FLAG:
	ANDL	0X07F
	SAH	SYSTMP1		;STOR MSG_ID
	CALL	MANAGE
	
	LAC	SYSTMP1
	SBHK	1
	SFR	4
	ADHK	NEW1
	SAH	SYSTMP2		;the address you will load(ROW)
	
	MAR	+0,1
	LAR	SYSTMP2,1
	LAC	+0,1
	SAH	SYSTMP0		;stor the flag
	
	LAC	SYSTMP1
	SBHK	1
	ANDK	0X0F
	SAH	SYSTMP2
	LIPK	0
	OUT	SYSTMP2,SHFCR	;save the bits you will mov(COL)
	ADHK	0
	
	LAC	SYSTMP0
	SFR	0
	ANDL	0X01
	SAH	SYSTMP0		;直接将所得NEW0标志取反作返回值(ACCH)
	XORL	0X01
GET_FLAG_END:
	RET
;------------------------------------------------------------------------------
;	Function : set new flag of message
;	根据MSG_ID设置相应的NEW标志
;	INPUT : ACCH = MSG_ID
;	OUTPUT: NO
;------------------------------------------------------------------------------
SET_FLAG:
	PSH	SYSTMP0
	PSH	SYSTMP1
	PSH	SYSTMP2
	
	ANDK	0X07F
	SAH	SYSTMP1		;STOR MSG_ID
	SAH	NEW_ID
	LACK	1
	SAH	SYSTMP0
	
	LAC	SYSTMP1
	SBHK	1
	ANDK	0X0F
	SAH	SYSTMP2		;save the bits you will move(col)
	LIPK	0
	OUT	SYSTMP2,SHFCR
	ADHK	0
	LAC	SYSTMP0
	SFL	0
	SAH	SYSTMP0

	LAC	SYSTMP1
	SBHK	1
	SFR	4
	ADHK	NEW1
	SAH	SYSTMP2		;the address you will load(row)
	
	MAR	+0,1
	LAR	SYSTMP2,1
	LAC	SYSTMP0
	OR	+0,1
	SAH	+0,1
SET_FLAG_END:
	POP	SYSTMP2
	POP	SYSTMP1
	POP	SYSTMP0
	ADHK	0
		
	RET

;------------------------------------------------------------------------------
;	Function : set new flag of message
;	根据MSG_ID查找和设转置相应的NEW标志
;	INPUT : ACCH = MSG_ID
;	OUTPUT: NO
;	variable : SYSTMP1
;	subroutine : SET_FLAG
;------------------------------------------------------------------------------
MANAGE:
	ANDL	0X07F
	SAH	SYSTMP1		;STOR MSG_ID
	
	LAC	SYSTMP1
	SBH	NEW_ID		;查NEW标志设置过吗(减数与被减数的关系与播放顺序有关,此时是序)?
	BS	SGN,CHK_NEWFLAG_END
	
	LAC	SYSTMP1
	ORL	0XA800
	SAH	CONF
	CALL	DAM_BIOS
	LAC	RESP
	BZ	ACZ,CHK_NEWFLAG_END
	
	LAC	SYSTMP1
	CALL	SET_FLAG
CHK_NEWFLAG_END:
		
	RET
;############################################################################
;	FUNCTION : SET_DELMARK
;	INPUT : ACCH = MSG_ID     
;	OUTPUT: NO
;############################################################################
SET_DELMARK:
	ANDK	0X7F
	ORL	0X2080
	SAH	CONF
	CALL	DAM_BIOS

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
;	FUNCTION : MSG_DEL
;	INPUT : NO
;	OUTPUT: NO
;############################################################################
;------------------------------------------------------------------------------
;	delete message with specific MSG_ID
;	input : ACCH = MSG_ID
;	output: no
;------------------------------------------------------------------------------
VPMSG_DEL:
	ANDK	0X7F
	ORL	0X6000	; delete
	SAH	CONF    
	CALL	DAM_BIOS
	
	RET
;############################################################################
;	FUNCTION : REAL_DEL
;	INPUT : NO
;	OUTPUT: NO
;############################################################################
VPMSG_DELALL:
	LACL	0X6080
	SAH	CONF
	CALL	DAM_BIOS
	
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
;	FUNCTION : GET_FILEID
;	找一个可用的FILE_ID,用于录音前设usr_dat0
;	INPUT : no
;	OUTPUT: ACCH/FILE_ID
;############################################################################
GET_FILEID:
	CALL	SET_FGTABLE
	
	CALL	SERACH_USEID
	
	RET
;------------------------------------------------------------------------------
;	Function : SET_FGTABLE
;	Set flag of message
;	依message id从大到小设置相应的标志图表NEW1..NEW7
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
	CALL	GET_USRID
	CALL	SET_FLAG
		
	LAC	MSG_ID
	SBHK	1
	SAH	MSG_ID
	BS	B1,SET_FGTABLE_LOOP
SET_FGTABLE_END:		
	RET
;-------------------------------------------------------------------------------
;	Function : SERACH_USEID
;	根据标志位图()查可用的message index
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
;------------------------------------------------------------------------------
;	Function : get new flag of message
;	根据MSG_ID取得相应的USE_DAT是否用过(0/1表示没用/用过)
;	INPUT : ACCH = MSG_ID(1..99)
;	OUTPUT: ACCH=0/1 ===>not used/been used
;	variable : SYSTMP0,SYSTMP1,SYSTMP2
;	subroutine : GET_FLAG
;------------------------------------------------------------------------------
GET_DATFLAG:
	PSH	SYSTMP0
	PSH	SYSTMP1
	PSH	SYSTMP2

	ANDL	0X07F
	SAH	SYSTMP1		;STOR MSG_ID

	LAC	SYSTMP1
	SBHK	1
	SFR	4
	ADHK	NEW1
	SAH	SYSTMP2		;the address you will load(ROW)
	
	MAR	+0,1
	LAR	SYSTMP2,1
	LAC	+0,1
	SAH	SYSTMP0		;stor the flag
	
	LAC	SYSTMP1
	SBHK	1
	ANDK	0X0F
	SAH	SYSTMP2
	LIPK	0
	OUT	SYSTMP2,SHFCR	;save the bits you will mov(COL)
	ADHK	0
	LAC	SYSTMP0
	SFR	0
	ANDL	0X01
	;SAH	SYSTMP0		;直接将所得NEW0标志取反作返回值(ACCH)
	;XORL	0X01
GET_DATFLAG_END:
	POP	SYSTMP2
	POP	SYSTMP1
	POP	SYSTMP0
	ADHK	0
	
	RET
;############################################################################
;	FUNCTION : GET_USRID
;	Get message index-0 information
;	INPUT : ACCH = MSG_ID
;	OUTPUT: ACCH = USER INDEX DATA0
;############################################################################
GET_USRID:
	ANDL	0XFF
	ORL	0XA900
	CALL	DAM_BIOSFUNC
	
	RET
;-------------------------------------------------------------------------------
.END
