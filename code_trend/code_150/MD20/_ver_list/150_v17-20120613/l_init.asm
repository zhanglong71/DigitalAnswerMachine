;-------------------------------------------------------------------------------
.LIST
;-------------------------------------------------------------------------------
;	Function : INITMCU
;	send data to initial mcu
;-------------------------------------------------------------------------------
INITMCU:
.if	1
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
;---load attribute
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
	SAH	PASSWORD
;---
	LACK	3		;local code1
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	SAH	LOCACODE
	SFL	4
	SAH	LOCACODE
;-
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
;-	
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
;-
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
;-
	;LAC	VOI_ATT
	;ANDL	0XCFFF
	;SAH	VOI_ATT
	
	;LACK	10		;Language
	;SAH	OFFSET_S
	;CALL	GETBYTE_DAT
	;ANDK	0X03
	;SFL	12
	;OR	VOI_ATT
	;SAH	VOI_ATT
;-------------------------------------------------------------------------------
INITMCU_3:	

	LACK	30		;delay 30ms
	CALL	DELAY
INITMCU_4:		
;---	
	LACL	0X87		;(2bytes)LCD 亮度
	CALL	SEND_DAT
	LAC	LOCACODE1
	SFR	4
	ANDK	0x0F
	;LACK	3
	CALL	SEND_DAT
	
	LACL	0X0FF
	CALL	SEND_DAT	;(1byte)

	LACK	30		;delay 30ms
	CALL	DELAY
;---
INITMCU_5:	
	CALL	SENDLOCACODE	;(5byte)

;---
	LACL	60	;delay 60ms
	CALL	DELAY

	LACK	0		;清空消息队列
	SAH	MSG_QUEUE

	LACL	CMSG_INIT
	CALL	STOR_MSG
INITMCU_RET:
.endif
	
        RET
;############################################################################
;
;	Function : DEFATT_WRITE
;	save the DAM ATT in working group
;	input  : no
;	output : ACCH = 0/!0 ==>SUCCESS/ERROR
;############################################################################
DEFATT_WRITE:
	LACK	0
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;ps1没问题继续/有问题结束
	LACK	0
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;ps2没问题继续/有问题结束
	LACK	0
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;ps3没问题继续/有问题结束

	LACK	0XA
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;lc1没问题继续/有问题结束
	LACK	0XA
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;lc2没问题继续/有问题结束	
	LACK	0XA
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;lc3没问题继续/有问题结束
	LACK	0XA
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;lc4没问题继续/有问题结束
	LACK	0XA
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;lc5没问题继续/有问题结束
	
	LACK	0X2
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;Rnt没问题继续/有问题结束
	
	LACK	0X3
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;Contrast没问题继续/有问题结束
	
	LACK	0X0
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;Language没问题继续/有问题结束

	CALL	DAT_WRITE_STOP
DEFATT_WRITE_END:	
	RET
;-------------------------------------------------------------------------------
;	Function : INITFDATETIME
;	send data to initial mcu
;-------------------------------------------------------------------------------
INITFDATETIME:
	LACK	CGROUP_DATETIME
	CALL	SET_TELGROUP
	CALL	GET_TELT
	BS	ACZ,INITDATETIME_END
	SAH	MSG_ID		;只一个,也是最后一个
	BS	B1,INITDATETIME_2
INITDATETIME_1:
.if	0
	LAC	TMR_MINUTE	;Default week(If it is the first PowerOn then write 0,else write the last week value --- adjust week or real time) use to format flash
	CALL	DAT_WRITE
	CALL	DAT_WRITE_STOP
	
	LACK	1
	SAH	MSG_ID
.endif	
INITDATETIME_2:
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
	;LACK	0
	;SAH	OFFSET_S
	;CALL	GETBYTE_DAT
	;ANDK	0X0F
	;ORL	0X7500
	;CALL	DAM_BIOSFUNC	;Set month end
;---load day		(Offset_S=1)
	;CALL	GETBYTE_DAT
	;ANDK	0X1F
	;ORL	0X7400
	;CALL	DAM_BIOSFUNC	;Set day end
;---load hour		(Offset_S=2)
	;CALL	GETBYTE_DAT
	;ANDK	0X1F
	;ORL	0X7200
	;CALL	DAM_BIOSFUNC	;Set hour end
;---load minute		(Offset_S=3)
	;CALL	GETBYTE_DAT
	;ANDK	0X3F
	;SAH	TMR_MINUTE
	;ORL	0X7100
	;CALL	DAM_BIOSFUNC	;Set minute end
;---load week		(Offset_S=4)
	LACK	4
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	ANDK	0X07
	ORL	0X7300
	CALL	DAM_BIOSFUNC	;Set week end
	
;---load month/day/hour/minute/week
INITDATETIME_END:
	;BS	B1,INITDATETIME_END
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
