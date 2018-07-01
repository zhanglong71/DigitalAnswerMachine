.LIST
;-------------------------------------------------------------------------------
;	Function : LOAD_LOCF_VP
;-------------------------------------------------------------------------------
;LOAD_LOCF_VP:
;-------
	;LACL	FlashLoc_H_f_localplay
	;ADLL	FlashLoc_L_f_localplay
	;CALL	SetFlashStartAddress
	;NOP	
	;LACL	RamLoc_f_localplay
	;ADLL	CodeSize_f_localplay
	;CALL	LoadHostCode
;-------
	;RET
;-------------------------------------------------------------------------------
;	Function : LOAD_LOCF_VPN
;-------------------------------------------------------------------------------
LOAD_LOCF_VPN:
;-------
	LACL	FlashLoc_H_f_plynew
	ADLL	FlashLoc_L_f_plynew
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_plynew
	ADLL	CodeSize_f_plynew
	CALL	LoadHostCode
;-------
	RET
;-------------------------------------------------------------------------------
;	Function : LOAD_LOCF_VPA
;-------------------------------------------------------------------------------
LOAD_LOCF_VPA:
;-------
	LACL	FlashLoc_H_f_plyall
	ADLL	FlashLoc_L_f_plyall
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_plyall
	ADLL	CodeSize_f_plyall
	CALL	LoadHostCode
;-------
	RET
;-------------------------------------------------------------------------------
;	Function : LOAD_LOCF_VR
;-------------------------------------------------------------------------------
LOAD_LOCF_VR:
;-------
	LACL	FlashLoc_H_f_localrec
	ADLL	FlashLoc_L_f_localrec
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_localrec
	ADLL	CodeSize_f_localrec
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

;############################################################################
;	FUNCTION : REAL_DEL
;	INPUT : NO
;	OUTPUT: NO
;############################################################################
REAL_DEL:
	LACL	0X6100
	CALL	DAM_BIOSFUNC
	
	RET
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
	CALL	DAM_BIOSFUNC

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
;	Function : CWEEK_GET
;	input : no
;	output: ACCH
;-------------------------------------------------------------------------------
CWEEK_GET:
CURR_WEEK:
	LACL	0X8300
	CALL	DAM_BIOSFUNC

	RET
	
;-------------------------------------------------------------------------------
;	Function : CHOUR_GET
;	input : no
;	output: ACCH
;-------------------------------------------------------------------------------
CHOUR_GET:
CURR_HOUR:
	LACL	0X8200
	CALL	DAM_BIOSFUNC
	
	RET

;------------------------------------------------------------------------------
;	Function : CMIN_GET
;	input : no
;	output: ACCH
;------------------------------------------------------------------------------
CMIN_GET:
CURR_MIN:
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
;===============================================================================
;	Function : YEAR_SET
;将大于4的部分保存在 TMR_YEAR 中,小于4的部分保存在机器的指定区域
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
YEAR_SET:
	SAH	SYSTMP0
	LACK	0
	SAH	TMR_YEAR
YEAR_SET_LOOP:
	LAC	SYSTMP0
	SBHK	4
	BS	SGN,YEAR_SET_1

	LAC	SYSTMP0
	SBHK	4
	SAH	SYSTMP0
	
	LAC	TMR_YEAR
	ADHK	4
	SAH	TMR_YEAR
	BS	B1,YEAR_SET_LOOP
YEAR_SET_1:
	LAC	SYSTMP0
	ORL	0X7600
	CALL	DAM_BIOSFUNC
	RET
;-------------------------------------------------------------------------------
;	Function : MON_SET
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
MON_SET:
	ORL	0X7500
	CALL	DAM_BIOSFUNC
	RET
;-------------------------------------------------------------------------------
;	Function : DAY_SET
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
DAY_SET:
	ORL	0X7400
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
;       Function : EXIT_TOIDLE
;
;       Input  : no
;       Output : no
;-------------------------------------------------------------------------------
EXIT_TOIDLE:
	LACK	0X2D
	CALL	SEND_DAT
	LACK	0X2D
	CALL	SEND_DAT
	
	RET
;-------------------------------------------------------------------------------
;       Function : SEND_MSGNUM
;
;       load new message number,total message number and DAM status into sendbuffer
;       Input  : no
;       Output : no
;-------------------------------------------------------------------------------
SEND_MSGNUM:
;-new message number
	LACK	0X20
	CALL	SEND_DAT
	LAC	MSG_N
	CALL	SEND_DAT
;-total message number
	LACK	0X21
	CALL	SEND_DAT
	LAC	MSG_T
	CALL	SEND_DAT
;-DAM status
	LACK	0X0
	SAH	SYSTMP0
;-(ANN_FG.13)与(SYSTMP0.0)是正逻辑关系
	BIT	ANN_FG,13
	BZ	TB,SEND_MSGNUM_3_1
	LAC	SYSTMP0
	ORK	1
	SAH	SYSTMP0
SEND_MSGNUM_3_1:
;-(EVENT.9)与(SYSTMP0.1)是反逻辑关系
	BIT	EVENT,9
	BS	TB,SEND_MSGNUM_3_2
	LAC	SYSTMP0
	ORK	(1<<1)
	SAH	SYSTMP0
SEND_MSGNUM_3_2:
;-(EVENT.8)与(SYSTMP0.2)是反逻辑关系
	BIT	EVENT,8
	BS	TB,SEND_MSGNUM_3_3
	LAC	SYSTMP0
	ORK	(1<<2)
	SAH	SYSTMP0
SEND_MSGNUM_3_3:	
	LACK	0X24
	CALL	SEND_DAT
	LAC	SYSTMP0
	CALL	SEND_DAT
;-
	RET
;-------------------------------------------------------------------------------
SET_DAMATT:
	SAH	SYSTMP0
	
	LAC	EVENT
	ANDL	~((1<<8)|(1<<9))
	SAH	EVENT

	LAC	VOI_ATT
	ANDL	~((1<<8)|(1<<9))
	SAH	VOI_ATT
;SET_DAMATT_0:	
;---CallScreening(正逻辑)
	BIT	SYSTMP0,7
	BZ	TB,SET_DAMATT_1
	
	LAC	VOI_ATT
	ORL	(1<<9)
	SAH	VOI_ATT
SET_DAMATT_1:
;---Language(正逻辑)
	BIT	SYSTMP0,0
	BZ	TB,SET_DAMATT_2
	
	LAC	VOI_ATT
	ORL	(1<<8)
	SAH	VOI_ATT
SET_DAMATT_2:
;---DAM on/off(反逻辑)
	BIT	SYSTMP0,6
	BS	TB,SET_DAMATT_3
	
	LAC	EVENT
	ORL	(1<<9)
	SAH	EVENT
SET_DAMATT_3:
;---DAM OGM select(反逻辑)
	BIT	SYSTMP0,5
	BS	TB,SET_DAMATT_4
	
	LAC	EVENT
	ORL	(1<<8)
	SAH	EVENT
SET_DAMATT_4:
	
	RET
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
.END
