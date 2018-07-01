;-------------------------------------------------------------------------------
.LIST
;-------------------------------------------------------------------------------
;	Function : INITMCU
;	send data to initial mcu
;-------------------------------------------------------------------------------
INITMCU:
	LACK	CGROUP_DATT
	CALL	SET_TELGROUP
	CALL	GET_TELT
	BS	ACZ,INITMCU_1
	SAH	MSG_ID		;只一个,也是最后一个
	BS	B1,INITMCU_2
INITMCU_1:
	CALL	DEFATT_WRITE
	
	LACK	1
	SAH	MSG_ID	
INITMCU_2:
;---Get attribute from flash
	LACL	TEL_RAM
	SAH	ADDR_D		;保存地址
	SAH	ADDR_S		;提取地址
	LACK	0
	SAH	OFFSET_D	;保存偏移
	LAC	MSG_ID		;条目号
	CALL	READ_TELNUM	;读当前条目数据
	CALL	STOPREADDAT
;---load attribute----------------------
;---load password
	LACK	0		;PS1
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	ANDK	0XF
	SAH	PASSWORD
	SFL	4
	SAH	PASSWORD
	
	LACK	1		;PS2
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	OR	PASSWORD
	SFL	4
	SAH	PASSWORD

	LACK	2		;PS3
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	OR	PASSWORD
	SFL	4
	SAH	PASSWORD

	LACK	3		;PS4
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	OR	PASSWORD
	SAH	PASSWORD
;---load localcode
	LACK	4		;local code2
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	OR	LOCACODE
	SFL	4
	SAH	LOCACODE
;-
	LACK	5		;local code3
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	OR	LOCACODE
	SFL	4
	SAH	LOCACODE
;-
	LACK	6		;local code4
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	OR	LOCACODE
	SAH	LOCACODE
;-	
	LAC	LOCACODE1
	ANDL	0xFFF0
	SAH	LOCACODE1

	LACK	7		;local code5
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	ANDK	0x0F
	OR	LOCACODE1
	SAH	LOCACODE1
;---load RingCount	
	LAC	VOI_ATT
	ANDL	0XFF0F
	SAH	VOI_ATT
	
	LACK	8		;Rnt
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	ANDK	0X0F
	SFL	4
	OR	VOI_ATT
	SAH	VOI_ATT
;---load LCDContrast
	LAC	LOCACODE1
	ANDL	0xFF0F
	SAH	LOCACODE1
	
	LACK	9		;LCD contrast
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	SFL	4
	ANDL	0X0F0
	OR	LOCACODE1
	SAH	LOCACODE1
;---load Language
	LAC	VOI_ATT
	ANDL	0XCFFF
	SAH	VOI_ATT
	
	LACK	10		;Language
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	ANDK	0X03
	SFL	12
	OR	VOI_ATT
	SAH	VOI_ATT
;-------------------------------------------------------------------------------
INITMCU_3:	
;---Send All\New message number
	CALL	VPMSG_CHK
	CALL	SEND_MSGNUM	;录音数量同步(4bytes)
	
	LACL	0XFF
	CALL	SEND_DAT
;----Send CID number	
	LACK	CGROUP_CID
	CALL	SET_TELGROUP
	CALL	GET_TELT
	SAH	MSG_T

	LACL	0X82
	CALL	SEND_DAT
	LACK	0	;!!!!!!!!!!!!!!!
	CALL	SEND_DAT
	LAC	MSG_T
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT		
;---Send LCD contrast(Default = 3)
	LACL	0X87
	CALL	SEND_DAT
	LAC	LOCACODE1
	SFR	4
	ANDK	0x0F
	CALL	SEND_DAT
	
	LACL	0X0FF
	CALL	SEND_DAT	;(1byte)
;---Send LocalCode
	;CALL	SENDLOCACODE	;(5byte)
	;LACL	0X0FF
	;CALL	SEND_DAT	;(1byte)

;---------end common power on

INITMCU_RET:
        RET
;-------------------------------------------------------------------------------
;	Function : GETDATETIME
;	send data to initial mcu
;-------------------------------------------------------------------------------
GETDATETIME:
	LACK	CGROUP_DATETIME
	CALL	SET_TELGROUP
	CALL	GET_TELT
	BS	ACZ,GETDATETIME_END
	SAH	MSG_ID		;只一个,也是最后一个
	BS	B1,GETDATETIME_2
GETDATETIME_1:
.if	0
	LAC	TMR_MINUTE	;Default week(If it is the first PowerOn then write 0,else write the last week value --- adjust week or real time) use to format flash
	CALL	DAT_WRITE
	CALL	DAT_WRITE_STOP
	
	LACK	1
	SAH	MSG_ID
.endif	
GETDATETIME_2:
;---Get Date/time from flash
	LACL	TEL_RAM
	SAH	ADDR_D		;保存地址
	SAH	ADDR_S		;提取地址
	LACK	0
	SAH	OFFSET_D	;保存偏移
	LAC	MSG_ID		;条目号
	CALL	READ_TELNUM	;读当前条目数据
	CALL	STOPREADDAT
;-------------------------------------------------
;---load month		(Offset_S=0)
	LACK	0
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	;ANDK	0X0F
	;ORL	0X7500
	;CALL	DAM_BIOSFUNC	;Set month end
;---load day		(Offset_S=1)
	CALL	GETBYTE_DAT
	;ANDK	0X1F
	;ORL	0X7400
	;CALL	DAM_BIOSFUNC	;Set day end
;---load hour		(Offset_S=2)
	CALL	GETBYTE_DAT
	;ANDK	0X1F
	;ORL	0X7200
	;CALL	DAM_BIOSFUNC	;Set hour end
;---load minute		(Offset_S=3)
	CALL	GETBYTE_DAT
	;ANDK	0X3F
	;ORL	0X7100
	;CALL	DAM_BIOSFUNC	;Set minute end
;---load week		(Offset_S=4)
	CALL	GETBYTE_DAT
	ANDK	0X07
	ORL	0X7300
	SAH	TMR_WEEK
	CALL	DAM_BIOSFUNC	;Set week end
	
;---load month/day/hour/minute/week
GETDATETIME_END:
	;BS	B1,GETDATETIME_END
	RET

;-------------------------------------------------------------------------------
;	Function : INITBEEP
;	
;	Generate a warning beep
;-------------------------------------------------------------------------------
INITBEEP:
	CALL    BEEP_START
        
	LACL	0X2063
	CALL    DAM_BIOSFUNC
	LACK	0
	CALL    DAM_BIOSFUNC
	
	LACL	1000
	CALL	DELAY

	CALL    BEEP_STOP	;// beep stop

        RET

;-------------------------------------------------------------------------------
.END
