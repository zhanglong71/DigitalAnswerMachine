.LIST
;############################################################################
;       Function : SET_TELGROUP
;	得到来电项目总数
;
;	input  : ACCH = 
;	OUTPUT : ACCH = 来电项目总数
;
;############################################################################
SET_TELGROUP:
	ANDK	0X1F
	ORL	0XE600
	CALL	DAM_BIOSFUNC

	RET
;############################################################################
;	FUNCTION : GET_TELT
;	得到当前Group项目总数
;	INPUT : NO
;	OUTPUT: ACCH = 当前Group项目总数
;############################################################################
GET_TELT:
	LACL	0XE401
	CALL	DAM_BIOSFUNC

	RET
;############################################################################
;
;       Function : DEL_ONETEL
;	delete the specific telehone number
;
;	INPUT  : ACCH	= TEL_ID you will delete
;	OUTPUT :	 
;############################################################################
DEL_ONETEL:
	ANDL	0XFF
	BS	ACZ,DEL_ONETEL_END
	ORL	0XE500
	CALL	DAM_BIOSFUNC

DEL_ONETEL_END:	
	RET

;############################################################################
;
;	Function : DEFATT_WRITE
;	save the DAM ATT in flash of working group
;	input  : no
;	output : ACCH = 0/!0 ==>SUCCESS/ERROR
;############################################################################
DEFATT_WRITE:
	LACK	0
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;ps1(offset=0)没问题继续/有问题结束
	LACK	0
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;ps2(offset=1)没问题继续/有问题结束
	LACK	0
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;ps3(offset=2)没问题继续/有问题结束
	LACK	0
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;ps4(offset=3)没问题继续/有问题结束
	LACK	0
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;language(offset=4)
	LACK	0
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;reerved
	LACK	0
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;reerved
	LACK	0
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;reerved
	LACK	0
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;reerved
	LACK	0
	CALL	DAT_WRITE
	BZ	ACZ,DEFATT_WRITE_END	;reerved

	CALL	DAT_WRITE_STOP
DEFATT_WRITE_END:	
	RET

;############################################################################
;
;	Function : DAT_WRITE
;	save the DAT in working group
;	input  : ACCH = the dat write
;	output : ACCH = error code
;############################################################################	
DAT_WRITE:
	ANDL	0XFF
	ORL	0XE000
	CALL	DAM_BIOSFUNC

	RET
;############################################################################

;       Function : DAT_WRITE_STOP
;	停止从当前Group写入数据
;
;	input  : no
;	OUTPUT : ACCH
;############################################################################
DAT_WRITE_STOP:
       	LACL	0XE100
	CALL	DAM_BIOSFUNC
	
	RET

;############################################################################
;
;	Function : TELNUM_WRITE
;	save the telephone number in working group
;
;	将以(ADDR_S,OFFSET_S)为起始地址的COUNT个数据写入FLASH(以BYTE为单位)
;	input  : OFFSET_S = offset of first data
;		 ADDR_S = the base addr of the data
;	output : no
;	variable :
;
;############################################################################
TELNUM_WRITE:
	LAC	COUNT
	SBHK	1
	SAH	COUNT
	BS	SGN,TELNUM_WRITE_EXIT
	
	CALL	GETBYTE_DAT
	CALL	DAT_WRITE
	BS	ACZ,TELNUM_WRITE	;没问题继续/有问题结束
TELNUM_WRITE_EXIT:

	RET

;############################################################################

;       Function : DAT_READ_STOP
;	根据得到的TEL_ID从当前Group读出电话号码(一个字节BYTE)
;
;	input  : ACCH = TEL_ID
;	OUTPUT : ACCH = 1/0---读出的结果是/否有效
;		 SYSTEMP1 = 读出的结果 
;
;############################################################################
READ_ONETELNUM:
	ANDK	0X7F
	BS	ACZ,READ_ONETELNUM_END

	ORL	0XE200		;1 byte
       	CALL    DAM_BIOSFUNC
       	SAH	SYSTMP1
       	SFR     8
       	BZ      ACZ,READ_ONETELNUM_END

	LACK	1	;读出结果有效
	RET
READ_ONETELNUM_END:
	CALL	DAT_READ_STOP
       	LACK	0	;读出结果无效
;-----------------------------------------	
	RET
;############################################################################

;       Function : DAT_READ_STOP
;	停止从当前Group读出电话号码
;
;	input  : no
;	OUTPUT : no
;############################################################################
DAT_READ_STOP:
	LACL	0XE300
       	CALL    DAM_BIOSFUNC

	RET
;############################################################################
;       Function : TELNUM_READ
;	根据TEL_ID从当前Group读出电话号码(此条目的全部)
;
;	input  : ACCH = TEL_ID
;		 (ADDR_D,OFFSET_D) = 保存地址的起始地址
;	OUTPUT : COUNT = the number of read data(byte)
;
;	variable:SYSTMP1,COUMT
;############################################################################
TELNUM_READ:
	SAH	SYSTMP1
	
	MAR	+0,1
	LAR	ADDR_D,1
	
	LACK	0
	SAH	COUNT
TELNUM_READ_LOOP:	
	LAC	SYSTMP1
	ORL	0XE200		;1 byte
       	CALL    DAM_BIOSFUNC
       	SAH	SYSTMP0
	SFR     8
       	BZ      ACZ,TELNUM_READ_END

	LAC	SYSTMP0
	CALL	STORBYTE_DAT
	LAC	COUNT
	ADHK	1
	SAH	COUNT
	BS	B1,TELNUM_READ_LOOP
TELNUM_READ_END:
	CALL	DAT_READ_STOP

	RET

;-------------------------------------------------------------------------------
	
.END
