.NOLIST
;---------------------------------------
.INCLUDE	include.inc
;---------------------------------------
.GLOBAL	RECEIVE_CID
.GLOBAL	CidRawData
;-------------------------------------------------------------------------------
.EXTERN	SYS_MSG_ANS
.EXTERN	SYS_MSG_RMT
;---------------------------------------
.EXTERN	GetOneConst
;---
.LIST
;-------------------------------------------------------------------------------
.ORG	ADDR_SECOND
;-------------------------------------------------------------------------------
;	RECEIVE_CID
;	input : 
;	output: ACCH
;
;-------------------------------------------------------------------------------
RECEIVE_CID:		;Receive CID from idle
	CALL	DAA_OFF
	
	LACL	CMODE9|(1<<3)	;Line-on/ALC-on
	CALL	DAM_BIOSFUNC
;---Clean the buffer
	LACL	CidBuffer	
	SAH	ADDR_D
	LACK	0
	SAH	OFFSET_D
	LACK	127
	SAH	COUNT
	CALL	RAM_CLR
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	CidRawData
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	CMODE9		;Line-off
	CALL	DAM_BIOSFUNC
	
	RET

;-------------------------------------------------------------------------------
;	ReceiveCidData
;	Input : CidNum
;	Output: 
;       Output: ACCH = 0  -  No detected
;               ACCH = 1  -  Cid data ready
;	 	ACCH = 2  -  Cid data error ready
;
;CidCheckSum	- For chksun only	
;CidLength	- Total length
;CidSubLength	- Subtype length
;CidFlag	- For some flag
;		bit(7..0) - SubType
;		bit8 - 1/0 - MDMF/not(SDMF)
;
;MDMF - 将收到的"相对完整"的CID存放到CidBuffer, 解码后存放到CidBuffer
;SDMF - 	
;规定号码数据串是以0x80开始(offset=0),存入Flash是从0x80之后的一位开始
;	Can't call INIT_DAM_FUNC
;-------------------------------------------------------------------------------
CidRawData:
	;ret	;???????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????
	PSH	COMMAND
;---
CidRawData_COUNT:
	LACL	4000			;Time out= 4000ms
	SAH	TMR_DELAY
;-------------------------------------------------------------------------------
CidRawData_01:
	BIT     RING_ID,10		;check if in ring off state ?
        BS      TB,CidRawData_COUNT
;---End off state
	LAC	TMR_DELAY
	BS	SGN,CidRawData_Error

	LACL	0x5000
	CALL	DAM_BIOSFUNC
	BIT	RESPONSE,14			;Check if detect Channel seizer ?
	BS	TB,CidRawData_Cs
	BIT	RESPONSE,13			;Check if detect Mark signal ?
	BS	TB,CidRawData_Ms
	BIT	RESPONSE,12
	BS	TB,CidRawData_Fsk
	
	CALL	DTMF_CHK
	BS	ACZ,CidRawData_DTMF	;DTMF detected ok
	SBHK	2
	BS	ACZ,CidRawData_CAS

	BS	B1,CidRawData_01
;---------------------------------------
CidRawData_CAS:				;CAS-tone detected
	CALL	Ack_DtmfD		;Send ACK DTMF
	BS	B1,CidRawData_01
;---------
CidRawData_DTMF:
	LAC	DTMF_VAL	;Get the last DTMF value
	SBHL	0X0FA
	BS	ACZ,CidRawData_000_DTMFS_1	;'A'
	SBHK	0x001
	BS	ACZ,CidRawData_000_DTMFS_1	;'B'
	SBHK	0x001	
	BS	ACZ,CidRawData_000_DTMFS_0_TTT	;'C'	!!!!!!!!!!!!!!!!!!!!!!!!
	SBHK	0x001	
	BS	ACZ,CidRawData_000_DTMFS_1	;'D'

	BS	B1,CidRawData_01
;---------
CidRawData_Cs:
	LACL	0x5002

	BS	B1,CidRawData_Com
CidRawData_Ms:
	LACL	0x5003
CidRawData_Com:
	CALL	DAM_BIOSFUNC
	BIT	RESPONSE,12			;FSK data ready ?
	BZ	TB,CidRawData_01
CidRawData_Fsk:
	LACL	0x5004
	CALL	DAM_BIOSFUNC
CidRawData_Fsk_01:
	LACK	0
	SAH	CidFlag
	
	LAC     RESPONSE
	ANDL    0X00ff			;CHECK data ready?
	SAH     RESPONSE

        SBHK    0X04
        BS      ACZ,VaildType_SDMF  ;header=04 single message data format
        SBHK    0x02
        BS      ACZ,VaildType_SDMF  ;header=06
        SBHK    0x7a
        BS      ACZ,VaildType_MDMF  ;header=80 multi-message data format
        SBHK    0x02
        BS      ACZ,VaildType_MDMF  ;header=82
        BS      B1,CidRawData_01
VaildType_MDMF:
	LACL	1<<8
	SAH	CidFlag			;Used to check MDMF or not
VaildType_SDMF:
	
	LACK	0
	SAH	CidCheckSum
	SAH	CidLength
	SAH	CidSubLength

	LACL	CidBuffer
	SAH	ADDR_D
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_D
;---
	LAC     RESPONSE
	CALL	SaveCidData
	
	LACL	2000
	SAH	TMR_DELAY		;time out 2sec
CidRawDataLen:				;Length
	LAC	TMR_DELAY
	BS	SGN,CidRawData_Error
		
	LACL	0x5000
	CALL	DAM_BIOSFUNC
	BIT	RESPONSE,12
	BZ	TB,CidRawDataLen
	LACL	0x5004
	CALL	DAM_BIOSFUNC
	
	CALL	SaveCidData
	
	LAC	RESPONSE
	ANDL	0xFF
	ADHK	1
	SAH	CidLength
	SAH	CidSubLength	;!!!this use to 04-type
	
	LAC	CidLength
	SBHL	0xFF
	BZ	SGN,CidRawData_Error
CidRawData_Loop:
	LACL	2000
	SAH	TMR_DELAY		; time out 2sec

	LACL	CidBuffer
	SAH	ADDR_D			;the address of CidRawData
	LACK	2
	SAH	OFFSET_D
		
	BIT	CidFlag,8
	BZ	TB,CidRawDataSubData	;Check MDMF or not

CidRawDataSubType:			;SubType
	LAC	TMR_DELAY
	BS	SGN,CidRawData_Error
		
	LACL	0x5000
	CALL	DAM_BIOSFUNC
	BIT	RESPONSE,12
	BZ	TB,CidRawDataSubType
	LACL	0x5004
	CALL	DAM_BIOSFUNC
	ANDL	0X0FF
	ORL	1<<8
	SAH	CidFlag
	CALL	SaveCidData

	LAC	CidLength
	SBHK	1
	SAH	CidLength
	BS	ACZ,CidRawData_Over	;收完了吗?(在MDMF时可能收最后一个Byte-CheckSum Byte时执行到此处)
	
CidRawDataSubLen:
	LAC	TMR_DELAY
	BS	SGN,CidRawData_Error
		
	LACL	0x5000
	CALL	DAM_BIOSFUNC
	BIT	RESPONSE,12
	BZ	TB,CidRawDataSubLen
	LACL	0x5004
	CALL	DAM_BIOSFUNC
	ANDL	0X0FF
	SAH	CidSubLength
	CALL	SaveCidData

	LAC	CidLength
	SBHK	1
	SAH	CidLength
	BS	ACZ,CidRawData_Over	;收完了吗?
	
CidRawDataSubData:
	LAC	TMR_DELAY
	BS	SGN,CidRawData_Error
	
	LAC	CidLength
	BS	ACZ,CidRawData_Over	;收完了吗?(在SDMF时可能收最后一个Byte-CheckSum Byte时执行到此处)
	
	LACL	0x5000
	CALL	DAM_BIOSFUNC
	BIT	RESPONSE,12
	BZ	TB,CidRawDataSubData
	LACL	0x5004
	CALL	DAM_BIOSFUNC
	ANDL	0X0FF
	CALL	SaveCidData
	
	LAC	CidLength
	SBHK	1
	SAH	CidLength
	
	LAC	CidSubLength
	SBHK	1
	SAH	CidSubLength
	BZ	ACZ,CidRawDataSubData
	
	BIT	CidFlag,8
	BZ	TB,CidRawData_Loop	;Check MDMF or not
;CidRawDataSubData_Decode:
	CALL	DECODE_MDMF		;MDMF边收边解码
	
	BS	B1,CidRawData_Loop	;收完了吗?
;-----------------------------------------------------------
CidRawData_Over:

	LAC	CidCheckSum
	ANDL	0X0FF
	BS	ACZ,CidRawData_FSK_OK
CidRawData_Error:
	
	LACL	0x5001		; Stop line monitor mode
	CALL	DAM_BIOSFUNC
;---
	POP	COMMAND

	LACK	1	
	
	RET
;---------------------------------------
CidRawData_FSK_OK:
	LACL	0x5001		; Stop line monitor mode
	CALL	DAM_BIOSFUNC

	BIT	CidFlag,8
	BS	TB,CidRawData_OK	;Check MDMF or not	

	CALL	DECODE_SDMF		;SDMF收完后解码
CidRawData_OK:

	LACL	CidData
	SAH	ADDR_S
	SAH	ADDR_D
;---
	LACK	5		;the offset of Num-Len Byte
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	SAH	CidLength	;for CID
	SBHK	16
	BZ	SGN,CidRawData_Irregularity	;

;---the length is less than 16
	LACK	6		;the offset of first Num
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	SAH	SYSTMP0
	SFL	12
	ANDL	0XF000
	SAH	LOCODE_TMP
	
	LAC	SYSTMP0
	SBHK	0X4F
	BS	ACZ,CidRawData_Private	;unavailable
	SBHK	0X01
	BS	ACZ,CidRawData_Private	;private	
;-----------------------------	

;-------------------------------------------------LocalCode detect end
CidRawData_CompBook:		;---Decode CID and LocalCode det over,compare the data in phonebook(TEL-num only)
	LACK	0
	SAH	PRO_VAR1
	LACL	CTMR1S
	CALL	SET_TIMER
;---	
	CALL	INIT_DAM_FUNC
	LACK	CGROUP_PBOOK
	CALL	SET_TELGROUP	;Set phonebook Group
;---
	LACL	CidData
	SAH	ADDR_S
	SAH	ADDR_D
	LACK	56
	SAH	OFFSET_S
	SAH	OFFSET_D
	LACK	0
	CALL	STORBYTE_DAT	;the default Repeat-Byte=0

	LACL	CidData
	SAH	ADDR_S
	CALL	COMP_ALLTELNUM			;从电话本中找到有相同号码的条目
	BS	ACZ,CidRawData_NoBook	;电话本里没有找到相同号码的条目,直接开始比较CID
	SAH	SYSTMP1
;---读出比较得到的条目,将收到的CID覆盖
	LACL	CidData
	SAH	ADDR_D
	LACK	0
	SAH	OFFSET_D

	LAC	SYSTMP1
	CALL	DAT_READ
	
	BS	B1,LOCAL_PROCID_COMPCID
CidRawData_Irregularity:	;irregularity CID
	LACK	5		;the offset of Num-Len Byte = 0
	SAH	OFFSET_D
	LACK	16
	CALL	STORBYTE_DAT
	BS	B1,CidRawData_SaveCid
CidRawData_Private:
	LACK	5		;the offset of Num-Len Byte
	SAH	OFFSET_D

	LAC	SYSTMP0
	CALL	STORBYTE_DAT

	BS	B1,CidRawData_SaveCid
CidRawData_NoBook:		;没有在PBOOK中找到相同号码时
;---------------------------------------
LOCAL_PROCID_COMPCID:		;compare the data in CID group
	
	LACK	CGROUP_CID
	CALL	SET_TELGROUP	;Set CID Group

	CALL	COMP_ALLTEL	;find the same tel-number in old CID
	BS	ACZ,CidRawData_SaveCid	;以前的CID中没有找到相同号码的条目,直接写入flash保存
	SAH	SYSTMP1
;---先清空目标区,不要亦可
	LACL	CidData
	SAH	ADDR_D
	LACK	0
	SAH	OFFSET_D
	LACK	64
	SAH	COUNT
	CALL	RAM_CLR	
;---Read TEL data with specific TEL-ID,over write the CID
	LACL	CidData
	SAH	ADDR_D
	LACK	0
	SAH	OFFSET_D
	LAC	SYSTMP1
	CALL	DAT_READ
;---!!!!!!!!!!!!!
	LAC	SYSTMP1
	CALL	DEL_ONETEL	;删除找到的号码
	CALL	TEL_GC_CHK
;---!!!!!!!!!!!!!
;---Repeat increase 1
	LACL	CidData
	SAH	ADDR_S
	SAH	ADDR_D
	LACK	56		;the offset of Repeat-Byte
	SAH	OFFSET_S
	SAH	OFFSET_D

	CALL	GETBYTE_DAT
	ADHK	1
	CALL	STORBYTE_DAT

CidRawData_SaveCid:		;Now CID cooked ok
;---Received CID ok, then write into flash
	LACK	CGROUP_CID
	CALL	SET_TELGROUP
	
	CALL	GET_TELT
	SBHK	CMAX_CID	;The MAX. number off miss-CID
	BS	SGN,LOCAL_PROCID_SAVECID_EXE
;---99 TEL exist,delete oldest one
	LACK	1
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK
LOCAL_PROCID_SAVECID_EXE:
;---Write data into flash
	LACL	CidData
	SAH	ADDR_S		;BASE address
	LACK	0
	SAH	OFFSET_S	;offset
	LACK	57
	SAH	COUNT		;counter
	CALL	TELNUM_WRITE
	;CALL	DAT_WRITE_STOP
;---Write index-0 into the specified new TEL(set NEW-BIT flag).
	CALL	GET_TELT
	ORL	(0x80<<8)		;Set index-1 = CFLAG(new flag,固定写入CFLAG)
	CALL	SET_TELUSR1ID
;---!!!!!!!!!!!!!!!!!!!!!!!!!!
.IF	1
;---total cid
	LACK	CGROUP_CID
	CALL	SET_TELGROUP		;Set CID Group
	CALL	GET_TELT
	CALL	SEND_TOTALCID
;---new cid
	CALL	GET_TELN
	CALL	SEND_NEWCID

	LACK	5
	CALL	DELAY
.ENDIF
;---!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	CidData
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	LACK	58
	SAH	COUNT
	CALL	SEND_TEL

	LACK	20
	CALL	DELAY	

	LACK	0		;CID ok
	CALL	SEND_TELOK
;---------
	POP	COMMAND
	
	LACK	0
	
	RET
;---------------------------------------------------------------------
CidRawData_000_DTMFS_0_TTT:	;DTMF vaild
	lacl	0xfd
	sah	DTMF_VAL
CidRawData_000_DTMFS_1:	
	
	LACL	CidBuffer
	SAH	ADDR_D
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_D
	SAH	COUNT			;the DTMF-cid length(except A/B/C/D/#)

	LAC	DTMF_VAL
	ANDK	0X0F
	CALL	STORBYTE_DAT
CidRawData_DTMF_START:			;如果中间收到A/B/D等字符就重新开始
	LACL	300			;time out= 300ms
	SAH	TMR_DELAY
;------
CidRawData_DTMFLOOP:
	LAC	TMR_DELAY
	BS	SGN,CidRawData_DTMF_TimeOver
	
	LACL	0X5000
	CALL	DAM_BIOSFUNC
	
	CALL	DTMF_CHK
	BZ	ACZ,CidRawData_DTMFLOOP
;-Received DTMF data ok
	LAC	DTMF_VAL		;Get the last DTMF value
	SBHL	0x0FA
	BS	ACZ,CidRawData_000_DTMFS_1	;'A'
	SBHK	0x001
	BS	ACZ,CidRawData_000_DTMFS_1	;'B'
	SBHK	0x001	
	BS	ACZ,CidRawData_DTMF_END		;'C'
	SBHK	0x001	
	BS	ACZ,CidRawData_000_DTMFS_1	;'D'
	SBHK	0x002
	BS	ACZ,CidRawData_DTMF_END		;'#'
	
	LAC     DTMF_VAL		;save the DTMF value in DTMF_VAL
	ANDK	0X0F
	CALL	SaveCidData

	LAC	COUNT
	ADHK	1
	SAH	COUNT
	BS	B1,CidRawData_DTMF_START
CidRawData_DTMF_TimeOver:
CidRawData_DTMF_END:
	LACL	0x5001			;Stop line monitor mode
	CALL	DAM_BIOSFUNC
;---------------------------------------

	LACL	CidData
	SAH	ADDR_D
	LACK	5
	SAH	OFFSET_D
	LAC	COUNT
	CALL	STORBYTE_DAT	;store length first

	CALL	DECODE_DTMF
	
	BS	B1,CidRawData_OK
;---------------------------------------------------------------------
CidRawData_LenError:
	LACL	0x5001		; Stop line monitor mode
	CALL	DAM_BIOSFUNC
;---
	POP	COMMAND

	LACK	3	;error
	
	RET


;-------------------------------------------------------------------------------
;	Save receiving data into RAM buffer
;	Input : ACCH = DATA
;		ADDR_D, OFFSET_D
;		CidCheckSum
;
;	Output: CidCheckSum

;	Effect: 1, 
;-------------------------------------------------------------------------------
SaveCidData:
	CALL	STORBYTE_DAT

        LAC     RESPONSE
        ADH     CidCheckSum
        SAH     CidCheckSum

        RET
;===============================================================================
;	Generate ACK DTMF_D to line
;	Input :
;	
;===============================================================================
Ack_DtmfD:
	PSH	COMMAND
;---------
	LACK    80           ; Delay 80 ms
        SAH     TMR_BEEP
Ack_DtmfD_1:
	
	LACL 	1633*8192/1000	; Freq 1, 1633Hz
	SAH	COMMAND1
	LACL 	941*8192/1000	; Freq 2, 941Hz
	SAH	COMMAND2
        LACL	0x48BA		; start tone
	CALL	DAM_BIOSFUNC

Ack_DtmfD_2:
        LAC     TMR_BEEP
        BZ	ACZ,Ack_DtmfD_2

        LACL    0X4400            ; stop tone
        CALL    DAM_BIOSFUNC
;---------
	POP	COMMAND
	RET
;-------------------------------------------------------------------------------
DECODE_DTMF:
	LACL	CidBuffer
	SAH	ADDR_S
	LACL	CidData
	SAH	ADDR_D
	
	LACK	1
	SAH	OFFSET_S
	LACK	6
	SAH	OFFSET_D
DECODE_DTMF_LOOP:
	CALL	GETBYTE_DAT
	ANDK	0X7F
	ORK	0X30
	CALL	STORBYTE_DAT

	LAC	COUNT
	SBHK	1
	SAH	COUNT
	BZ	ACZ,DECODE_DTMF_LOOP
	
	RET
;-------------------------------------------------------------------------------
DECODE_SDMF:
;---Time
	LACL	CidBuffer
	SAH	ADDR_S
	LACL	CidData
	SAH	ADDR_D

	LACK	2
	SAH	OFFSET_S
	LACK	1
	SAH	OFFSET_D
	CALL	DECODE_TIME
;---	
	LACK	1
	SAH	OFFSET_S
	LACK	5
	SAH	OFFSET_D
	CALL	GETBYTE_DAT
	SBHK	8	;减去时间长度得到数据长度
	SAH	COUNT
	CALL	STORBYTE_DAT
;-
	LACK	10
	SAH	OFFSET_S

DECODE_SDMF_LOOP:
	CALL	GETBYTE_DAT
	ANDK	0X7F
	ORK	0X30
	CALL	STORBYTE_DAT

	LAC	COUNT
	SBHK	1
	SAH	COUNT
	BZ	ACZ,DECODE_SDMF_LOOP
			
DECODE_SDMF_END:	
	RET
;-------------------------------------------------------------------------------
TAB_DECODE_MDMF:	;!!!Note no type 0
.data	MDMF_1SUB
.data	MDMF_2SUB
.data	MDMF_3SUB
.data	MDMF_4SUB
.data	MDMF_5SUB
.data	MDMF_6SUB
.data	MDMF_7SUB
.data	MDMF_8SUB
;-------------------
;TAB_DECODE_DESTADDR:	;!!!Note no type 0
;.data	1	;start of time/date
;.data	5	;start of num(length)
;.data	5	;start of num(length)
;.data	5	;start of num(length)
;.data	5	;start of num(length)
;.data	5	;start of num(length)
;.data	38	;start of name(length)
;.data	38	;start of name(length)
;---------------------------------------
;	Decode the MDMF-subtype
;	Must set address first
;---------------------------------------		
DECODE_MDMF:
	LACL	CidData
	SAH	ADDR_D		;the address of CidCookedData
;-Get type
	LACK	2
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	SBHK	1	;!!!Note no type 0
	SAH	SYSTMP0
	BS	SGN,DECODE_MDMF_END	;<1
	SBHK	7
	BZ	SGN,DECODE_MDMF_END	;>=8
;---Pass the legal check
	;LAC	SYSTMP0
	;ANDK	0X07
	;ADHL	TAB_DECODE_DESTADDR
	;CALL	GetOneConst
	;SAH	OFFSET_D

	LAC	SYSTMP0
	ANDK	0X07
	ADHL	TAB_DECODE_MDMF
	CALL	GetOneConst
	BACC
;---------------------------------------
MDMF_1SUB:		;time/date
	LACK	4
	SAH	OFFSET_S
	LACK	1
	SAH	OFFSET_D
	CALL	DECODE_TIME
	
	BS	B1,DECODE_MDMF_END
;---------------------------------------
MDMF_2SUB:		;Number
	LACK	3
	SAH	OFFSET_S
	LACK	5
	SAH	OFFSET_D
	
	CALL	GETBYTE_DAT
	SAH	COUNT		;The length
	CALL	STORBYTE_DAT
;-Now the offset-address of source is 4
MDMF_2SUB_LOOP:	
	CALL	GETBYTE_DAT
	ANDK	0X7F
	ORK	0X30
	CALL	STORBYTE_DAT
	
	LAC	COUNT
	SBHK	1
	SAH	COUNT
	BZ	ACZ,MDMF_2SUB_LOOP
	BS	B1,DECODE_MDMF_END
;---------------------------------------
MDMF_3SUB:
MDMF_4SUB:
MDMF_5SUB:
MDMF_6SUB:
;---------------------------------------
MDMF_7SUB:
	LACK	3
	SAH	OFFSET_S
	LACK	38
	SAH	OFFSET_D	;0x26
	
	CALL	GETBYTE_DAT
	SAH	COUNT		;The length
	CALL	STORBYTE_DAT
;-Now the offset-address of source is 4
MDMF_7SUB_LOOP:	
	CALL	GETBYTE_DAT
	CALL	STORBYTE_DAT
	
	LAC	COUNT
	SBHK	1
	SAH	COUNT
	BZ	ACZ,MDMF_7SUB_LOOP
		
	BS	B1,DECODE_MDMF_END
;---------------------------------------
MDMF_8SUB:
	
DECODE_MDMF_END:
	
	RET
;-------------------------------------------------------------------------------
;---将(OFFSET_S/OFFSET_S+1),(OFFSET_S+2/OFFSET_S+3),OFFSET_S+4/OFFSET_S+5),(OFFSET_S+6/OFFSET_S+7)
;---位置处的数据处理后存放在
;---(OFFSET_D/OFFSET_D+1/OFFSET_D+2/OFFSET_D+3)处
;
;Note: No length
;-------------------------------------------------------------------------------
DECODE_TIME:
;---------Month
	CALL	GETBYTE_DAT
	ANDK	0X0F
	SFL	4
	SAH	SYSTMP0
;---	
	CALL	GETBYTE_DAT
	ANDK	0X0F
	OR	SYSTMP0
	SAH	SYSTMP0	
	;ORL	0X7500
	;CALL	DAM_BIOSFUNC
;-	
	LAC	SYSTMP0
	CALL	DGT_HEX
	SAH	SYSTMP0
	CALL	STORBYTE_DAT
;---------Day
	CALL	GETBYTE_DAT
	ANDK	0X0F
	SFL	4
	SAH	SYSTMP0
;---	
	CALL	GETBYTE_DAT
	ANDK	0X0F
	OR	SYSTMP0
	SAH	SYSTMP0
	;ORL	0X7400
	;CALL	DAM_BIOSFUNC
;-	
	LAC	SYSTMP0
	CALL	DGT_HEX
	SAH	SYSTMP0
	CALL	STORBYTE_DAT
;---------Hour
	CALL	GETBYTE_DAT
	ANDK	0X0F
	SFL	4
	SAH	SYSTMP0
;---	
	CALL	GETBYTE_DAT
	ANDK	0X0F
	OR	SYSTMP0
	SAH	SYSTMP0
	;ORL	0X7200
	;CALL	DAM_BIOSFUNC
;-	
	LAC	SYSTMP0
	CALL	DGT_HEX
	SAH	SYSTMP0
	CALL	STORBYTE_DAT
;---------Minute
	CALL	GETBYTE_DAT
	ANDK	0X0F
	SFL	4
	SAH	SYSTMP0
;---	
	CALL	GETBYTE_DAT
	ANDK	0X0F
	OR	SYSTMP0
	SAH	SYSTMP0	
	;ORL	0X7100
	;CALL	DAM_BIOSFUNC
;-	
	LAC	SYSTMP0
	CALL	DGT_HEX
	SAH	SYSTMP0
	CALL	STORBYTE_DAT
;---------
DECODE_TIME_END:
	
	RET
;-------------------------------------------------------------------------------
DECODE_NUM:
	
	RET
;-------------------------------------------------------------------------------
.INCLUDE	l_iic/l_storsqueue.asm
.INCLUDE	l_iic/l_dspstatus.asm
.INCLUDE	l_iic/l_cid.asm
.INCLUDE	l_iic/l_telok.asm

.INCLUDE	l_math/l_dgthex.asm

.INCLUDE	l_move/l_getdata.asm
.INCLUDE	l_move/l_ramstor.asm
.INCLUDE	l_move/l_stordata.asm
.INCLUDE	l_move/l_dumpiic_tel.asm

.INCLUDE	l_respond/l_dtmf.asm

.INCLUDE	l_tel/l_alltel.asm
.INCLUDE	l_tel/l_compare.asm
.INCLUDE	l_tel/l_del.asm
.INCLUDE	l_tel/l_group.asm
.INCLUDE	l_tel/l_newtel.asm
.INCLUDE	l_tel/l_read.asm
;.INCLUDE	l_tel/l_tel_read.asm
.INCLUDE	l_tel/l_tel_tag.asm
.INCLUDE	l_tel/l_tel_write.asm
.INCLUDE	l_tel/l_write.asm

;-------------------------------------------------------------------------------
.END
	