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
	LACL	0X2B08
	;LACL	(1333*8192/1000+127)
	;ANDL	0XFF00
	;ORK	8
	CALL	STOR_VP		;B
	LACL	0X1A08
	;LACL	(800*8192/1000+127)
	;ANDL	0XFF00
	;ORK	8
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
;-------------------------------------------------------------------------------
;	Function : MSG_WEEK/MSG_HOUR/MSG_MIN
;	
;-------------------------------------------------------------------------------
MSG_WEEKNEW:
	LAC	MSG_ID
	ORL	0XA380
	CALL	DAM_BIOSFUNC
	BS	B1,MSG_WEEK_STOR
MSG_WEEK:
	LAC	MSG_ID
	ORL	0XA300
	CALL	DAM_BIOSFUNC
MSG_WEEK_STOR:
	ADHK	34
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
;---
MSG_HOURNEW:
	LAC	MSG_ID
	ORL	0XA280
	CALL	DAM_BIOSFUNC
	BS	B1,MSG_HOUR_STOR
MSG_HOUR:
	LAC	MSG_ID
	ORL	0XA200
	CALL	DAM_BIOSFUNC
MSG_HOUR_STOR:
	CALL	ANNOUNCE_NUM
	
	RET
;---
MSG_MINNEW:
	LAC	MSG_ID
	ORL	0XA180
	CALL	DAM_BIOSFUNC
	BS	B1,MSG_MIN_STOR
MSG_MIN:
	LAC	MSG_ID
	ORL	0XA100
	CALL	DAM_BIOSFUNC
MSG_MIN_STOR:
	CALL	ANNOUNCE_NUM
	
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

;-------------------------------------------------------------------------------
;       Function : LED_HLDISP
;
;       Transfer a digit value to LED_L for display
;       Input  : ACCH = the display data
;       Output : LED_L
;-------------------------------------------------------------------------------
LED_HLDISP:
        CALL    HEX_DGT		; transform the binary value to the BCD value
        ANDK    0X0F
        ADHL	DGT_TAB
	CALL    GetOneConst
	SAH	LED_L

        RET
;-----------------------------
;	make sure less than 9
;-----------------------------
NUM_ADJ:
	SAH	SYSTMP1
	SBHK	10
	BS	SGN,NUM_ADJ_1
	LACK	9
	SAH	SYSTMP1
NUM_ADJ_1:
	LAC	SYSTMP1
	
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
;-------------------------------------------------------------------------------
;	Function : DGT_HEX
;	
;	Transform a BCD value to binary value
;	Input  : ACCH = the BCD value
;	Output : ACCH = the binary value
;	Variable : SYSTMP1,SYSTMP2
;-------------------------------------------------------------------------------
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
.END
