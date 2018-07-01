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
;	Function : LOAD_SYSF_TEL
;-------------------------------------------------------------------------------
LOAD_SYSF_TEL:
;-------
	LACL	FlashLoc_H_f_reccid
	ADLL	FlashLoc_L_f_reccid
	CALL	SetFlashStartAddress
	nop	
	LACL	RamLoc_f_reccid
	ADLL	CodeSize_f_reccid
	CALL	LoadHostCode
;-------
	RET
;-------------------------------------------------------------------------------
;	Function : BEEP
;	
;	Generate a "BEEP"	---提示用(100mSec Duration @Frequency=1KHz)
;-------------------------------------------------------------------------------	
BEEP:
	LACL	0X005
	CALL	STOR_VP
	LACL	0X200C
	CALL	STOR_VP		;B
	
	RET

;-------------------------------------------------------------------------------
;	Function : LBEEP
;	
;	Generate a "LONG BEEP"---录音提示用(250mSec Duration @Frequency=1KHz)
;-------------------------------------------------------------------------------	
LBEEP:
	LACL	0X005
	CALL	STOR_VP
	LACL	0X2020
	CALL	STOR_VP		;B___
	
	RET
;-------------------------------------------------------------------------------
;	Function : BBEEP
;	
;	Generate two "BEEP"	;BB
;-------------------------------------------------------------------------------	
BBEEP:
	LACL	0X200C
	CALL	STOR_VP
	LACL	0X0005
	CALL	STOR_VP
	LACL	0X200C
	CALL	STOR_VP	
	
	RET
;-------------------------------------------------------------------------------
;	Function : BBBEEP
;	
;	Generate three "BEEP"	---BBB
;-------------------------------------------------------------------------------
BBBEEP:
	CALL	BEEP
	CALL	BEEP
	CALL	BEEP
	
	RET
;-------------------------------------------------------------------------------
;	Function : ERRBEEP
;	
;	Generate three "BEEP"	---报错用
;-------------------------------------------------------------------------------
ERRBEEP:
	CALL	BEEP
	CALL	BEEP
	CALL	BEEP
	CALL	BEEP
	CALL	BEEP		;BBBBB
	
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
;	FUNCTION : VPMSG_DELOLD
;	INPUT : NO
;	OUTPUT: NO
;############################################################################
VPMSG_DELOLD:
	LACL	0X6080
	CALL	DAM_BIOSFUNC
	
	RET

;############################################################################
;	delete message with specific MSG_ID
;	input : ACCH = MSG_ID
;	output: no
;############################################################################
VPMSG_DEL:
	ANDK	0X7F
	ORL	0X6000	; delete
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

;-------------------------------------------------------------------------------
;       Function : SEND_MSGNUM
;
;       load new message number,total message number and DAM status into sendbuffer
;       Input  : no
;       Output : no
;-------------------------------------------------------------------------------
SEND_MSGNUM:
;-new message number
	LACK	0X01
	CALL	SEND_DAT
	LAC	MSG_N
	CALL	SEND_DAT
;-total message number
	LACK	0X02
	CALL	SEND_DAT
	LAC	MSG_T
	CALL	SEND_DAT
;-DAM status
	LACK	0X07
	SAH	SYSTMP0
;-(ANN_FG.13)与(SYSTMP0.0)是正逻辑关系
	BIT	ANN_FG,13
	BS	TB,SEND_MSGNUM_3_1
	LAC	SYSTMP0
	ANDL	~(1)
	SAH	SYSTMP0
SEND_MSGNUM_3_1:
;-(EVENT.9)与(SYSTMP0.1)是反逻辑关系
	BIT	EVENT,9
	BZ	TB,SEND_MSGNUM_3_2
	LAC	SYSTMP0
	ANDL	~(1<<1)
	SAH	SYSTMP0
SEND_MSGNUM_3_2:
;-(EVENT.8)与(SYSTMP0.2)是反逻辑关系
	BIT	EVENT,8
	BZ	TB,SEND_MSGNUM_3_3
	LAC	SYSTMP0
	ANDL	~(1<<2)
	SAH	SYSTMP0
SEND_MSGNUM_3_3:	
	LACK	0X13
	CALL	SEND_DAT
	LAC	SYSTMP0
	CALL	SEND_DAT
;-
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


;-------------------------------------------------------------------------------
;	Function : SET_PLYPSA
;	Set PSA duing playing
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
SET_PLYPSA:
	PSH	CONF
;-------	
	SAH	SYSTMP0
;---
	LACL	0X5F45
	CALL	DAM_BIOSFUNC
	LAC	SYSTMP0
	CALL	DAM_BIOSFUNC
;-------
	POP	CONF

	RET
;-------------------------------------------------------------------------------
.END
