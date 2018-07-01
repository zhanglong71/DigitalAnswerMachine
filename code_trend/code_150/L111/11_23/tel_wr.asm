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
	SAH	CONF
	CALL	DAM_BIOS

	RET
;############################################################################
;	FUNCTION : GET_TELT
;	得到当前Group项目总数
;	INPUT : NO
;	OUTPUT: ACCH = 当前Group项目总数
;############################################################################
GET_TELT:
	LACL	0XE401
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	RESP
	ANDK	0X7F
	
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
	SAH	CONF
	CALL	DAM_BIOS
	LAC	RESP
	SFR	8
DEL_ONETEL_END:	
	RET
;############################################################################
;
;       Function : DEL_ALLTEL
;	delete the ALL telehone number in current group
;
;	INPUT  : ACCH = the total number you will delete
;	OUTPUT :	 
;############################################################################
DEL_ALLTEL:
	SAH	SYSTMP1
DEL_ALLTEL_LOOP:	
	LAC	SYSTMP1
	ANDL	0XFF
	BS	ACZ,DEL_ALLTEL_END
	CALL	DEL_ONETEL

	CALL	TEL_GC_CHK
	CALL	GC_CHK
	LAC	SYSTMP1
	SBHK	1
	SAH	SYSTMP1

	BS	B1,DEL_ALLTEL_LOOP
DEL_ALLTEL_END:	
	
	RET
	
;############################################################################
;       Function : GET_NOUSETELUSRDAT
;	为新到来电条目找一没用到的USR-DAT(当前Group中没有用到的就行)
;
;	input  : no
;	OUTPUT : ACCH = USR-DAT
;
;############################################################################
GET_NOUSETELUSRDAT:
	CALL	GET_TELT
	SAH	SYSTMP1		;STOR the number of total tel(要查询的总数)

	LACK	1
	SAH	SYSTMP2		;当前查询的序号
GET_NOUSETELUSRDAT_LOOP:
	LAC	SYSTMP1
	SBH	SYSTMP2
	BS	SGN,GET_NOUSETELUSRDAT_END	;找到一个没用到的index-0(搜索完取TEL_T+1)
	
	LAC	SYSTMP2
	CALL	GET_TELID
	BS	ACZ,GET_NOUSETELUSRDAT_END	;找到一个没用到的index-0(没搜索完取SYSTMP2)
	
	LAC	SYSTMP2
	ADHK	1
	SAH	SYSTMP2
	BS	B1,GET_NOUSETELUSRDAT_LOOP
GET_NOUSETELUSRDAT_END:
	LAC	SYSTMP2
	
	RET
;############################################################################
;       Function : GET_TELUSRDAT
;	根据TEL_ID取得USR-DAT(当前Group中)
;
;	input  : ACCH = TEL_ID
;	OUTPUT : USR-DAT
;
;############################################################################
GET_TELUSRDAT:
	ANDK	0X7F
	ORL	0XEA00
	SAH	CONF
	CALL	DAM_BIOS
	LAC	RESP

	RET
;############################################################################
;       Function : SET_TELUSRDAT
;	为新来电项目写入USR-DAT(当前Group中没有用到的)
;
;	input  : ACCH = TEL_ID
;		 BUF1 = usr-dat
;	OUTPUT : ACCH
;
;############################################################################
SET_TELUSRDAT:
	ANDK	0X7F
	ORL	0XE700
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	RESP
	SFR	8
	
	RET

;############################################################################
;
;	Function : TELTIME_WRITE
;	save the time of income call in working group
;	input  : no
;	output : ACCH = 0/!0 ==>SUCCESS/ERROR
;############################################################################
TELTIME_WRITE:
	LAC	TMR_MONTH
	CALL	DAT_WRITE
	BZ	ACZ,TELTIME_WRITE_END	;没问题继续/有问题结束
	LAC	TMR_DAY
	CALL	DAT_WRITE
	BZ	ACZ,TELTIME_WRITE_END	;没问题继续/有问题结束
	LAC	TMR_HOUR
	CALL	DAT_WRITE
	BZ	ACZ,TELTIME_WRITE_END	;没问题继续/有问题结束
	LAC	TMR_MIN
	CALL	DAT_WRITE
	BZ	ACZ,TELTIME_WRITE_END	;没问题继续/有问题结束

TELTIME_WRITE_END:	
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
	SAH	CONF
	CALL	DAM_BIOS
	LAC	RESP
	SFR	8
	
	RET
;############################################################################

;       Function : DAT_WRITE_STOP
;	停止从当前Group写入数据
;
;	input  : no
;	OUTPUT : no
;############################################################################
DAT_WRITE_STOP:
       	LACL	0XE100
       	SAH     CONF
       	CALL    DAM_BIOS

	RET
;############################################################################
;
;	Function : TELNUM_WRITE
;	save the telephone number in working group
;
;	将以ADDR_S为起始地址以的数据写入FLASH(以BYTE为单位)
;	input  : COUNT = offset
;		 ADDR_S = the base addr of the TEL_NUM
;	output : ACCH = 0/!0---success/error
;	variable : SYSTMP6
;
;############################################################################
TELNUM_WRITE:
	LACK	0
	SAH	SYSTMP2		;取数的开始地址
TELNUM_WRITE_LOOP:
	LAC	SYSTMP2
	SAH	COUNT
	CALL	GETBYTE_DAT
	SAH	SYSTMP1
	XORL	0XFF
	BS	ACZ,TELNUM_WRITE_EXIT	;如果是0XFF就结束
	
	LAC	SYSTMP2
	ADHK	1
	SAH	SYSTMP2
	
	LAC	SYSTMP1
	CALL	DAT_WRITE
	BS	ACZ,TELNUM_WRITE_LOOP	;没问题继续/有问题结束
TELNUM_WRITE_EXIT:
	;CALL	STOPWRITETELNUM

	RET

;############################################################################

;       Function : READ_ONETELNUM
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
       	SAH     CONF
       	CALL    DAM_BIOS
       	LAC    	RESP
       	SAH	SYSTMP1
       	SFR     8
       	BZ      ACZ,READ_ONETELNUM_END

	LACK	1		;读出结果有效
	RET
READ_ONETELNUM_END:
	CALL	STOPREADDAT

       	LACK	0	;读出结果无效
;-----------------------------------------	
	RET
;############################################################################

;       Function : READ_BYTEDAT
;	根据得到的TEL_ID从当前Group读出电话号码的第COUNT(从零开始)个字节
;
;	input  : ACCH = TEL_ID
;		 COUNT = 要读的数据的序号
;	OUTPUT : ACCH = 1/0---读出的结果是/否有效
;		 SYSTEMP1 = 读出的结果 
;
;############################################################################
READ_BYTEDAT:
	PSH	SYSTMP2
	PSH	COUNT
	
	ANDK	0X7F
	BS	ACZ,READ_BYTEDAT_END
	SAH	SYSTMP2
READ_BYTEDAT_LOOP:	
	LAC	SYSTMP2
	CALL	READ_ONETELNUM
	BS	ACZ,READ_BYTEDAT_END
	
	LAC	COUNT
	SBHK	1
	SAH	COUNT
	BZ	SGN,READ_BYTEDAT_LOOP
	
	CALL	STOPREADDAT
	
	POP	COUNT
	POP	SYSTMP2
	LACK	1		;得到预期的DATA
	RET
READ_BYTEDAT_END:
	POP	COUNT
	POP	SYSTMP2
       	LACK	0		;读出结果无效
;-----------------------------------------	
	RET

;############################################################################

;       Function : STOPTELNUM_READ
;	停止从当前Group读出电话号码
;
;	input  : no
;	OUTPUT : no
;############################################################################
STOPREADDAT:
       	LACL	0XE300
       	SAH     CONF
       	CALL    DAM_BIOS

	RET
;############################################################################
;       Function : READ_TELNUM
;	根据TEL_ID从当前Group读出电话号码(此条目的全部)
;
;	input  : ACCH = TEL_ID
;		 ADDR_D = 保存地址的基地址
;	OUTPUT : ACCH = 
;
;	variable:SYSTMP1,SYSTMP2,COUMT
;############################################################################
READ_TELNUM:
	SAH	SYSTMP2
	
	MAR	+0,1
	LAR	ADDR_D,1
	
	LACK	0
	SAH	COUNT
READ_TELNUM_LOOP:	
	LAC	SYSTMP2
	CALL	READ_ONETELNUM
	BS	ACZ,READ_TELNUM_END
	LAC	SYSTMP1
	CALL	STORBYTE_DAT
	LAC	COUNT
	ADHK	1
	SAH	COUNT
	BS	B1,READ_TELNUM_LOOP
READ_TELNUM_END:
	;CALL	STOPREADDAT
	
	RET
;############################################################################
;       Function : COMP_ONETELNUM
;	根据TEL_ID从当前Group读出电话号码并与已有号码比较.读出的第4(从0开始)
;		个数据与offset = 4,长度 = COUNT 的数据比较
;
;	input  : ACCH = TEL_ID
;		 COUNT = 比较数据的长度
;		 ADDR_S = 参与比较号码,保存地址的基地址
;	OUTPUT : ACCH = 0/1 ---不相等/相等
;
;	variable:,SYSTMP1,SYSTMP2,SYSTMP3,COUNT
;############################################################################
COMP_ONETELNUM:
	PSH	SYSTMP1
	PSH	SYSTMP2
	
	SAH	SYSTMP2		;save TEL_ID
	
	MAR	+0,1
	LAR	ADDR_S,1
	
	LAC	COUNT
	SAH	SYSTMP3
	
	LACK	4
	SAH	COUNT		;比较号码,从第4个开始
COMP_ONETELNUM_LOOP:
	LAC	SYSTMP2
	CALL	READ_BYTEDAT
	BS	ACZ,COMP_ONETELNUM_ENDNO	;无效数据,退出
	
	CALL	GETBYTE_DAT
	SBH	SYSTMP1
	BZ	ACZ,COMP_ONETELNUM_ENDNO	;有一个不相等,退出

	LAC	COUNT
	ADHK	1
	SAH	COUNT
	
	LAC	SYSTMP3
	SBHK	1
	SAH	SYSTMP3
	BZ	ACZ,COMP_ONETELNUM_LOOP	

COMP_ONETELNUM_ENDYES:				;比较完毕,找到(SYSTMP3 = 0)
	POP	SYSTMP2
	POP	SYSTMP1
	
	LACK	1
	
	RET
COMP_ONETELNUM_ENDNO:
	POP	SYSTMP2
	POP	SYSTMP1
	
	LACK	0	;
	RET

;############################################################################
;       Function : COMP_ALLTELNUM
;	从当前Group读出电话号码并与已有号码比较.若相同就返回ACCH = TEL_ID/0
;
;	input  : ADDR_S = 参与比较号码的所在地址的基地址
;		 FILE_LEN = 已有号码的长度信息所在地
;	OUTPUT : ACCH = 0/!0 --没找到/找到的号码的序号
;
;	variable:,SYSTMP1,SYSTMP2,SYSTMP3,COUNT
;############################################################################
COMP_ALLTELNUM:
	CALL	GET_TELT
	ADHK	1
	SAH	SYSTMP2

	MAR	+0,1
	LAR	ADDR_S,1
COMP_ALLTELNUM_LOOP_1:
	LACK	0
	SAH	COUNT				;offset
	
	LAC	SYSTMP2
	SBHK	1
	SAH	SYSTMP2				;TEL_ID
	BS	ACZ,COMP_ALLTELNUM_END		;没找到
	CALL	READ_BYTEDAT
	BS	ACZ,COMP_ALLTELNUM_LOOP_1	;无效数据

	LAC	FILE_LEN
	XOR	SYSTMP1
	ANDK	0X7F

	BZ	ACZ,COMP_ALLTELNUM_LOOP_1	;第SYSTMP2条的第COUNT字节与FILE_LEN低字节相同
	CALL	STOPREADDAT
;COMP_ALLTELNUM_LOOP_2:	
	;LAC	+0,1
	LAC	FILE_LEN
	ANDK	0X7F
	ADHK	1
	SFR	1
	SAH	COUNT			;号码占用字节长度(byte)

	LAC	SYSTMP2
	BS	ACZ,COMP_ALLTELNUM_END	;没找到

	LAC	SYSTMP2
	CALL	COMP_ONETELNUM
	BZ	ACZ,COMP_ALLTELNUM_END
	
	CALL	STOPREADDAT
	
	;LAC	SYSTMP2
	;SBHK	1
	;SAH	SYSTMP2
	BS	B1,COMP_ALLTELNUM_LOOP_1
COMP_ALLTELNUM_END:

	LAC	SYSTMP2

	RET

;############################################################################
;
;       Function : TELNUMALL_DEL
;	delete the all telehone number that not mapping messages
;
;	INPUT  : no
;	OUTPUT : no
;	variable: SYSTMP1
;		 
;############################################################################
.if	1
TELNUMALL_DEL:
	LAC	MBOX_ID		;set the TEL working group
	CALL	SET_TELGROUP

	CALL	GET_TELT
	SAH	SYSTMP1
	BS	ACZ,TELNUMALL_DEL_EXIT	;no tel-number?
	
	CALL	MSG_CHK		;get the number of TOTAL messages
TELNUMALL_DEL_LOOP:
	LAC	SYSTMP1
	BS	ACZ,TELNUMALL_DEL_EXIT
	
	LACL	0XEA00
	OR	SYSTMP1
	SAH	CONF
	CALL	DAM_BIOS
	LAC	RESP
	SFR	8
	BZ	ACZ,TELNUMALL_DEL_EXIT
	LAC	RESP
	SAH	MSG_N
	
	CALL	GET_MSGID
	BZ	ACZ,TELNUMALL_DEL_LOOP_1

	LAC	SYSTMP1
	CALL	DEL_ONETEL		;没有相应的录音就删除之
	
	CALL	TEL_GC_CHK
	CALL	GC_CHK
TELNUMALL_DEL_LOOP_1:	
	LAC	SYSTMP1
	SBHK	1
	SAH	SYSTMP1
	BS	B1,TELNUMALL_DEL_LOOP
TELNUMALL_DEL_EXIT:		
	RET
.endif
;############################################################################
;	Fumction : GET_MSGID
;	在当前Group中根据USER-DAT0找MSG_ID
;		从MSG_T个message中找usr data0=MSG_N的message 
;		input : MSG_T = the total message in current mailbox
;			MSG_N=the specific usr data0
;		output: ACCH = the MSG_ID you find(零表示没找到)
;############################################################################
.if	1
GET_MSGID:
	LAC	MSG_T
	SAH	MSG_ID
GET_MSGID_1:
	LAC	MSG_ID
	BS	ACZ,GET_MSGID_2		;not find
		
	LACL	0XA900 			;GET USER INDEX DATA0
	OR	MSG_ID
        SAH     CONF
        CALL    DAM_BIOS		
	LAC     RESP
	SBH	MSG_N
	BS	ACZ,GET_MSGID_2		;find
	
	LAC	MSG_ID
	SBHK	1
	SAH	MSG_ID
	BS	B1,GET_MSGID_1		;next
GET_MSGID_2:
	LAC	MSG_ID
	
	RET
.endif

;############################################################################
;	FUNCTION : GET_TELID
;	在当前Group中根据index-0找TEL_ID
;	INPUT : ACCH = index-0
;	OUTPUT: ACCH = 返回的MSG_ID(0表示没找到)
;	
;	variable : SYSTMP0
;		   SYSTMP1
;############################################################################
GET_TELID:
	ANDL	0XFF
	ORL	0XE900
	SAH	CONF
	CALL	DAM_BIOS
	LAC	RESP
	SFR	8
	BZ	ACZ,GET_TELID1
	LAC	RESP
	RET
GET_TELID1:
	LACK	0
	RET
;-------------------------------------------------------------------------------
	
.END
