.LIST
;-------------------------------------------------------------------------------
;	Function : LOAD_LOCF_VP
;-------------------------------------------------------------------------------
LOAD_LOCF_VP:
;-------
	LACL	FlashLoc_H_f_localplay
	ADLL	FlashLoc_L_f_localplay
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_localplay
	ADLL	CodeSize_f_localplay
	CALL	LoadHostCode
;-------
	RET

;-------------------------------------------------------------------------------
;	Function : LOAD_MNUF_VP
;-------------------------------------------------------------------------------
LOAD_MNUF_VP:
;-------
	LACL	FlashLoc_H_f_menu
	ADLL	FlashLoc_L_f_menu
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_menu
	ADLL	CodeSize_f_menu
	CALL	LoadHostCode
;-------
	RET
;-------------------------------------------------------------------------------
;	Function : LOAD_TETF_VP
;-------------------------------------------------------------------------------
LOAD_TETF_VP:
;-------
	LACL	FlashLoc_H_f_tmode
	ADLL	FlashLoc_L_f_tmode
	CALL	SetFlashStartAddress
	nop	
	LACL	RamLoc_f_tmode
	ADLL	CodeSize_f_tmode
	CALL	LoadHostCode
;-------
	RET
;-------------------------------------------------------------------------------
;	Function : BEEP
;	
;	Generate a "BEEP"	---提示用
;-------------------------------------------------------------------------------	
BEEP:
	LACL	0X005
	CALL	STOR_VP
	LACL	0X2020
	CALL	STOR_VP		;B
	
	RET
;-------------------------------------------------------------------------------
;	Function : RBEEP
;	
;	Generate a "RBEEP"	---提示用
;-------------------------------------------------------------------------------	
RBEEP:
	LACL	0X1308
	CALL	STOR_VP		;B
	LACL	0X0C08
	CALL	STOR_VP		;B
	
	RET
;-------------------------------------------------------------------------------
;	Function : LLBEEP
;	
;	Generate a "LLONG BEEP"---提示用
;-------------------------------------------------------------------------------	
LLBEEP:
	LACL	0X005
	CALL	STOR_VP
	LACL	0X20FF
	CALL	STOR_VP

	RET
;-------------------------------------------------------------------------------
;	Function : LBEEP
;	
;	Generate a "LONG BEEP"---提示用
;-------------------------------------------------------------------------------	
LBEEP:
	LACL	0X005
	CALL	STOR_VP
	LACL	0X2050
	CALL	STOR_VP		;B___
	
	RET
;-------------------------------------------------------------------------------
;	Function : BBEEP
;	
;	Generate two "BEEP"	---结束用
;-------------------------------------------------------------------------------	
BBEEP:
	LACL	0X2020
	CALL	STOR_VP
	LACL	0X005
	CALL	STOR_VP
	LACL	0X2020
	CALL	STOR_VP		;BB
	
	RET
;-------------------------------------------------------------------------------
;	Function : BBBEEP
;	
;	Generate three "BEEP"	---报错用
;-------------------------------------------------------------------------------
BBBEEP:
	LACL	0X230B
	CALL	STOR_VP
	LACL	0X1C0B
	CALL	STOR_VP
	LACL	0X200B
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
;	subroutine : GET_NEWFLAG
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
;	output: MSG_ID (mapping the message you will play next)
;
;	variable : no
;	subroutine : GET_FLAG
;------------------------------------------------------------
REW_MANAGE:
	
	LAC	MSG_ID
	SAH	MSG_N
REW_MANAGE1:
	CALL	GET_FLAG
	BZ	ACZ,REW_MANAGE_END

	LAC	MSG_ID
	SBHK	1
	SAH	MSG_ID
	ANDL	0X0FF
	BZ	ACZ,REW_MANAGE1
;-------查找失败
	LAC	MSG_N
	ADHK	1
	SAH	MSG_ID	
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
GET_NEWFLAG:
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
;	根据MSG_ID设置相应的NEW标志(NEW1开始的连续7个RAM区)
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
	;LACK	1
	;SAH	SYSTMP0
	
	LAC	SYSTMP1
	SBHK	1
	ANDK	0X0F
	SAH	SYSTMP2		;save the bits you will move(col)
	LIPK	0
	OUT	SYSTMP2,SHFCR
	ADHK	0
	LACK	0X01
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
	BS	ACZ,CHK_NEWFLAG_END
	
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
	CALL	DAM_BIOSFUNC

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
	CALL	DAM_BIOSFUNC
	
	RET
;############################################################################
;	FUNCTION : REAL_DEL
;	INPUT : NO
;	OUTPUT: NO
;############################################################################
VPMSG_DELALL:
	LACL	0X6080
	CALL	DAM_BIOSFUNC
	
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
;############################################################################
;	FUNCTION : SET_FILEID
;	找一个可用的FILE_ID,用于录音前设usr_dat0
;	INPUT : ACCH = FILE_ID
;	OUTPUT: NO
;############################################################################
SET_FILEID:
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
	CALL	GET_USR0ID
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
	
	CALL	GET_FLAG
	BZ	ACZ,SERACH_USEID_LOOP2	
	
	LAC	SYSTMP0
SERACH_USEID_END:
	RET
;------------------------------------------------------------------------------
;	Function : get flag of message
;	根据MSG_ID取得相应的USE_DAT是否为1(0/1表示没用/用过)
;	INPUT : ACCH = MSG_ID(1..99)
;	OUTPUT: ACCH=0/1 ===>not used/been used
;	variable : SYSTMP0,SYSTMP1,SYSTMP2
;------------------------------------------------------------------------------
GET_FLAG:
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
	ANDL	0X01	;直接将所得NEW0标志取反作返回值(ACCH)

GET_DATFLAG_END:
	POP	SYSTMP2
	POP	SYSTMP1
	POP	SYSTMP0
	ADHK	0
	
	RET
;############################################################################
;	FUNCTION : GET_USR0ID
;	Get message index-0 information
;	INPUT : ACCH = MSG_ID
;	OUTPUT: ACCH = USER INDEX DATA0
;############################################################################
GET_USR0ID:
	ANDL	0XFF
	ORL	0XA900
	CALL	DAM_BIOSFUNC
	
	RET
;############################################################################
;	FUNCTION : GET_USR1ID
;	Get message index-1 information
;	INPUT : ACCH = MSG_ID
;	OUTPUT: ACCH = USER INDEX DATA1
;############################################################################
GET_USR1ID:
	ANDL	0XFF
	ORL	0XAA00
	CALL	DAM_BIOSFUNC
	
	RET
;-------------------------------------------------------------------------------
ANNOUNCE_NUM:
	RET
;//----------------------------------------------------------------------------
;//       Function : CURR_WEEK/CURR_GWEEK
;//
;//       Generate a VP
;//----------------------------------------------------------------------------
CURR_WEEK:
	LACL	0X8300
	CALL	DAM_BIOSFUNC

	RET
;//----------------------------------------------------------------------------
;//       Function : CURR_HOUR/CURR_GHOUR
;//
;//       Generate a VP
;//----------------------------------------------------------------------------
CURR_HOUR:
	LACL	0X8200
	CALL	DAM_BIOSFUNC
	
	RET
	
;//----------------------------------------------------------------------------
;//       Function : MSG_MIN/CURR_GMIN
;//
;//       Generate a VP
;//----------------------------------------------------------------------------
CURR_MIN:
	LACL	0X8100
	CALL	DAM_BIOSFUNC
	RET
;-------------------------------------------------------------------------------
;	Function : CWEEK_GET
;	input : no
;	output: ACCH
;-------------------------------------------------------------------------------
CWEEK_GET:
	LACL	0X8300
	CALL	DAM_BIOSFUNC

	RET
;-------------------------------------------------------------------------------
;	Function : CHOUR_GET
;	input : no
;	output: ACCH
;-------------------------------------------------------------------------------
CHOUR_GET:
	LACL	0X8200
	CALL	DAM_BIOSFUNC
	
	RET

;------------------------------------------------------------------------------
;	Function : CMIN_GET
;	input : no
;	output: ACCH
;------------------------------------------------------------------------------
CMIN_GET:
	LACL	0X8100
	CALL	DAM_BIOSFUNC
	RET
;===============================================================================
;	Function : WEEK_SET
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
WEEK_SET:
	ORL	0X7300
	CALL	DAM_BIOSFUNC
	RET
;-------------------------------------------------------------------------------
;	Function : HOUR_SET
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
HOUR_SET:
	ORL	0X7200
	CALL	DAM_BIOSFUNC
	RET
;-------------------------------------------------------------------------------
;	Function : MIN_SET
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
MIN_SET:
	ORL	0X7100
	CALL	DAM_BIOSFUNC
	RET
;-------------------------------------------------------------------------------
;	Function : SEC_SET
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
SEC_SET:
	ORL	0X7000
	CALL	DAM_BIOSFUNC
	RET

;-------------------------------------------------------------------------------
;       Function : LED_HLDISP
;
;       Transfer a two-digit value to LED_H & LED_L for display
;       Input  : ACCH = the display data
;       Output : LED_L
;-------------------------------------------------------------------------------
LED_HLDISP:
        CALL    HEX_DGT		; transform the binary value to the BCD value
        SAH	SYSTMP1
                       		; SYSTMP1=the BCD value
        LAC     SYSTMP1
        ANDK    0X0F
	CALL	GET_SEGCODE
        CALL	SET_LED4
;---
        LAC     SYSTMP1
        SFR     4
        CALL	GET_SEGCODE
	CALL	SET_LED3

        RET
;-------------------------------------------------------------------------------
;	Function : SET_LED1
;	store data into LED_H(15..8)
;
;       Input  : ACCH = the display data
;       Output : LED_H(15..8)
;-------------------------------------------------------------------------------
.if	0
SET_LED1:
	PSH	SYSTMP1
	
	SFL	8
	ANDL	0XFF00
	SAH	SYSTMP1
	
	LAC	LED_H
        ANDL	0X00FF
        OR	SYSTMP1
        SAH	LED_H		;LED_H

	POP	SYSTMP1
	
	RET
.endif
;-------------------------------------------------------------------------------
;	Function : SET_LED2
;	store data into LED_H(7..0)
;
;       Input  : ACCH = the display data
;       Output : LED_H(7..0)
;-------------------------------------------------------------------------------
.if	0
SET_LED2:
	PSH	SYSTMP1

	ANDL	0X00FF
	SAH	SYSTMP1
	
	LAC	LED_H
        ANDL	0XFF00
        OR	SYSTMP1
        SAH	LED_H		;LED_H

	POP	SYSTMP1
	RET
.endif
;-------------------------------------------------------------------------------
;	Function : SET_LED3
;	store data into LED_L(15..8)
;
;       Input  : ACCH = the display data
;       Output : LED_L(15..8)
;-------------------------------------------------------------------------------
SET_LED3:
	PSH	SYSTMP1
	
	SFL	8
	ANDL	0XFF00
	SAH	SYSTMP1
	
	LAC	LED_L
        ANDL	0X00FF
        OR	SYSTMP1
        SAH	LED_L		;LED_H

	POP	SYSTMP1
	
	RET
;-------------------------------------------------------------------------------
;	Function : SET_LED4
;	store data into LED_L(7..0)
;
;       Input  : ACCH = the display data
;       Output : LED_L(7..0)
;-------------------------------------------------------------------------------
SET_LED4:
	PSH	SYSTMP1

	ANDL	0X00FF
	SAH	SYSTMP1
	
	LAC	LED_L
        ANDL	0XFF00
        OR	SYSTMP1
        SAH	LED_L		;LED_H

	POP	SYSTMP1
	RET
;-------------------------------------------------------------------------------
;       Function : HEX_DGT
;	Transform a binary value to a BCD value
;
;	Input  : ACCH = the binary value
;	Output : ACCH = the BCD value
;	Variable : SYSTMP1,SYSTMP2
;-------------------------------------------------------------------------------
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
;-------------------------------------------------------------------------------
;	Function : GET_7SEGCODE
;	store data into LED_HL(15..8)
;
;       Input  : ACCH = the binary data
;       Output : ACCH = 7Seg code
;-------------------------------------------------------------------------------
GET_SEGCODE:
	PSH	SYSTMP1
	
	ANDK	0X0F
        ADHL	DGT_TAB
	CALL    GetOneConst
	SAH	SYSTMP1
        
	LAC	SYSTMP1
	
	POP	SYSTMP1
	RET
;-------------------------------------------------------------------------
;	Function : GETBYTE_DAT	
;	从以ADDR_S为起始地址以COUNT为offset的队列取数据(一个字节)
;	INPUT : COUNT = the offset you will get data from
;		ADDR_S = the BASE you will get data from
;	output: ACCH = the data you got
;	variable:SYSTMP1
;-------------------------------------------------------------------------
GETBYTE_DAT:
	DINT
	PSH	SYSTMP1
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
	POP	SYSTMP1	
	EINT
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
	DINT
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
	EINT
	RET
;-------------------------------------------------------------------------------
;	ReceiveCidData
;	Input : CidNum
;	Output: Cid data ready
;	Effect: 1
;-------------------------------------------------------------------------------
.IF	NoUse
CidRawData:
;---- clear CidBuffer for 32 bytes ----
	LARL	CidBuffer,1		; CidBuffer=0x40 ~ 0x4F (32bytes)
	SAR	CidTmpReg,1
	MAR	+0,1
        LACK    0              		 
        LUPK    31,0
        SAH     +,1
	
	LACK	0
	SAH	CID_CHKSUM
	SAH	CidCnt
	
	LAC	CidNum			; inc CidNum
	ADHK	1
	SAH	CidNum	
	
	LACL	4000/4			; time out= 4000ms
	SAH	CidTimer
CidRawData_01:
	LAC	CidTimer
	BS	SGN,CidRawData_Stop
	
	LACL	0x5000
	SAH	CONF
	CALL	DAM_BIOS
	BIT	RESP,8			; Check if detect CAS
	BZ	TB,CidRawData_02
	LAC	RESP
	ANDL	0xFF
	BZ	ACZ,CidRawData_02
CidRawData_Cas:
	LACL	0x5000
	SAH	CONF
	CALL	DAM_BIOS
	BIT	RESP,8
	BS	TB,CidRawData_Cas	; CAS end ?
	
	CALL	MuteLineIn
	CALL	Ack_DtmfD		; send ACK DTMF
	CALL	UnMuteLineIn
CidRawData_02:
	BIT	RESP,14			; Check if detect Channel seizer ?
	BS	TB,CidRawData_Cs
	BIT	RESP,13			; Check if detect Mark signal ?
	BS	TB,CidRawData_Ms
	BIT	RESP,12
	BS	TB,CidRawData_Fsk
	BS	B1,CidRawData_01
CidRawData_Cs:
	LACL	0x5002
	BS	B1,CidRawData_Com
CidRawData_Ms:
	LACL	0x5003
CidRawData_Com:
	SAH	CONF
	CALL	DAM_BIOS
	BS	B1,CidRawData_01
CidRawData_Fsk:
	LAC     RESP
        ANDL    0X00ff          ;CHECK data ready?
        SAH     RESP

        SBHK    0X04
        BS      ACZ,VaildType  ;header=04 single message data format
        SBHK    0x02
        BS      ACZ,VaildType  ;header=06
        SBHK    0x7a
        BS      ACZ,VaildType  ;header=80 multi-message data format
        SBHK    0x02
        BS      ACZ,VaildType  ;header=82
        BS      B1,CidRawData_01
VaildType:
	CALL	SaveCidData
	
	LACL	2000/4
	SAH	CidTimer		; time out 2sec
CidRawData_03:
	LAC	CidTimer
	BS	SGN,CidRawData_Stop
		
	LACL	0x5000
	SAH	CONF
	CALL	DAM_BIOS
	BIT	RESP,12
	BZ	TB,CidRawData_03
	LACL	0x5004
	SAH	CONF
	CALL	DAM_BIOS
	
	CALL	SaveCidData
	
	LAC	RESP
	ANDL	0xFF
	ADHK	1
	SAH	CidLength
	
	LAC	CidLength
	SBHK	0x40
	BZ	SGN,CidRawData_Error
CidRawData_Loop:
	LACL	2000/4
	SAH	CidTimer		; time out 2sec
CidRawData_04:
	LAC	CidTimer
	BS	SGN,CidRawData_Stop
		
	LACL	0x5000
	SAH	CONF
	CALL	DAM_BIOS
	BIT	RESP,12
	BZ	TB,CidRawData_04
	LACL	0x5004
	SAH	CONF
	CALL	DAM_BIOS
	
	CALL	SaveCidData
	
	LAC	CidLength
	SBHK	1
	SAH	CidLength
	BZ	ACZ,CidRawData_Loop
	
	LAC	CID_CHKSUM
	BS	ACZ,CidRawData_OK
CidRawData_Error:
	LAC	flag
	ANDL	0xFFDF		; flag.5=0, Cid data not ready
	SAH	flag
	BS	B1,CidRawData_Stop
CidRawData_OK:	
	LAC	flag
	ORK	0x20		; flag.5=1, Cid data ready
	SAH	flag
CidRawData_Stop:
	LACL	0x5001		; Stop line monitor mode
	SAH	CONF
	CALL	DAM_BIOS	
	RET
.ENDIF

;-------------------------------------------------------------------------------
;	Save receiving data into RAM buffer
;	Input : ACCH = DATA, ADDR_D, CID_CHKSUM
;	Output: 
;	Effect: 1, 
;-------------------------------------------------------------------------------
.IF	NoUse
SaveCidData:
	CALL	STORBYTE_DAT
	
	LAC	COUNT
	ADHK	1
	SAH	COUNT
SaveCid_End:
        LAC     RESP
        ADH     CID_CHKSUM
        SAH     CID_CHKSUM

        RET
.ENDIF
;-------------------------------------------------------------------------------
.END
