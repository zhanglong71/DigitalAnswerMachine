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

	;CALL	TEL_GC_CHK
	LAC	SYSTMP1
	SBHK	1
	SAH	SYSTMP1

	BS	B1,DEL_ALLTEL_LOOP
DEL_ALLTEL_END:	
	
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
	CALL	DAM_BIOSFUNC
	
	RET
;############################################################################
;       Function : SET_TELUSRDAT
;	为新来电项目写入USR-DAT
;
;	input  : ACCH = usr-dat
;
;	OUTPUT : ACCH
;
;############################################################################
SET_TELUSRDAT:
	ANDK	0X7F
	ORL	0XE700
	CALL	DAM_BIOSFUNC
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
;---Month	
	lipk    9
	IN	SYSTMP0,RTCMD	; month=01, day=01
	LAC	SYSTMP0
	SFR	8
	ANDK	0X03F
	CALL	DGT_HEX		;!!!!!!
	CALL	DAT_WRITE
	BZ	ACZ,TELTIME_WRITE_END	;没问题继续/有问题结束
;---Day
	LAC	SYSTMP0
	ANDK	0X03F
	CALL	DGT_HEX		;!!!!!!
	CALL	DAT_WRITE
	BZ	ACZ,TELTIME_WRITE_END	;没问题继续/有问题结束
;---Hour
	lipk    9
	IN	SYSTMP0,RTCWH	; week=0, hour=00
	LAC	SYSTMP0
	ANDK	0X3F
	CALL	DGT_HEX		;!!!!!!
	CALL	DAT_WRITE
	BZ	ACZ,TELTIME_WRITE_END	;没问题继续/有问题结束
;---Minute
	lipk    9
	IN	SYSTMP0,RTCMS	; min=00, sec=00
	LAC	SYSTMP0
	SFR	8
	ANDK	0X07F
	CALL	DGT_HEX		;!!!!!!
	CALL	DAT_WRITE
	BZ	ACZ,TELTIME_WRITE_END	;没问题继续/有问题结束

TELTIME_WRITE_END:	
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
       	CALL    DAM_BIOSFUNC

	RET
;############################################################################
;
;	Function : TELNUM_WRITE
;	save the telephone number in working group
;
;	将以ADDR_S为起始地址以的数据写入FLASH(以BYTE为单位)
;	input  : OFFSET_S = the offset addr of the TEL_NUM
;		 ADDR_S = the base addr of the TEL_NUM
;	output : ACCH = error-code(0/!0---success/error)
;	variable : SYSTMP6
;
;############################################################################
TELNUM_WRITE:
	CALL	GETBYTE_DAT
	SAH	SYSTMP1
	XORL	0XFF
	BS	ACZ,TELNUM_WRITE_EXIT	;如果是0XFF就结束
	
	LAC	SYSTMP1
	CALL	DAT_WRITE
	BS	ACZ,TELNUM_WRITE	;没问题继续/有问题结束
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
       	CALL    DAM_BIOSFUNC
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
;###############################################################################
;
;       Function : READ_BYTEDAT
;	根据得到的TEL_ID从当前Group读出电话号码的第OFFSET_D(从零开始)个字节
;
;	input  : ACCH = TEL_ID
;		 OFFSET_D = 要读的数据导序号
;	OUTPUT : ACCH = 1/0---读出的结果是/否有效
;		 SYSTEMP1 = 读出的结果 
;
;###############################################################################
READ_BYTEDAT:
	PSH	SYSTMP2
	PSH	OFFSET_D
	
	ANDK	0X7F
	BS	ACZ,READ_BYTEDAT_END
	SAH	SYSTMP2
READ_BYTEDAT_LOOP:	
	LAC	SYSTMP2
	CALL	READ_ONETELNUM
	BS	ACZ,READ_BYTEDAT_END

	LAC	OFFSET_D
	SBHK	1
	SAH	OFFSET_D
	BZ	SGN,READ_BYTEDAT_LOOP
	
	CALL	STOPREADDAT
	
	POP	OFFSET_D
	POP	SYSTMP2
	LACK	1		;得到预期的DATA
	RET
READ_BYTEDAT_END:
	POP	OFFSET_D
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
       	CALL    DAM_BIOSFUNC

	RET
;############################################################################
;       Function : READ_TELNUM
;	根据TEL_ID从当前Group读出电话号码(此条目的全部)
;
;	input  : ACCH = TEL_ID
;		 ADDR_D = the base address
;		 OFFSET_D = the offset address
;	OUTPUT : ACCH = 
;
;	variable:SYSTMP1,SYSTMP2,COUMT
;############################################################################
READ_TELNUM:
	SAH	SYSTMP2
	
	MAR	+0,1
	LAR	ADDR_D,1

READ_TELNUM_LOOP:	
	LAC	SYSTMP2
	CALL	READ_ONETELNUM
	BS	ACZ,READ_TELNUM_END
	LAC	SYSTMP1
	CALL	STORBYTE_DAT
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
;		 COUNT = 比较数据的长度(BYTE)
;		 OFFSET_S = 参与比较号码,保存所在地址的起始偏移(从0开始)
;		 OFFSET_D = 参与比较号码,从Flash中读取的起始序号(从0开始)
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

COMP_ONETELNUM_LOOP:
	LAC	SYSTMP2
	CALL	READ_BYTEDAT
	BS	ACZ,COMP_ONETELNUM_ENDNO	;无效数据,退出
	
	CALL	GETBYTE_DAT
	SBH	SYSTMP1
	BZ	ACZ,COMP_ONETELNUM_ENDNO	;有一个不相等,退出
;---相等,比较下一个

	LAC	OFFSET_D
	ADHK	1
	SAH	OFFSET_D
	
	LAC	COUNT
	SBHK	1
	SAH	COUNT
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
	SAH	OFFSET_D			;offset
	
	LAC	SYSTMP2
	SBHK	1
	SAH	SYSTMP2				;TEL_ID
	BS	ACZ,COMP_ALLTELNUM_END		;没找到
	CALL	READ_BYTEDAT
	BS	ACZ,COMP_ALLTELNUM_LOOP_1	;无效数据

	LAC	FILE_LEN
	XOR	SYSTMP1
	ANDK	0X7F

	BZ	ACZ,COMP_ALLTELNUM_LOOP_1	;第SYSTMP2条的第OFFSET_D字节与FILE_LEN低字节相同
;---找到号码长度相同的项
	CALL	STOPREADDAT
;COMP_ALLTELNUM_LOOP_2:	
	;LAC	+0,1
	LAC	FILE_LEN
	ANDK	0X7F
	ADHK	1
	SFR	1
	SAH	COUNT			;号码占用字节长度(byte)

	LACK	4
	SAH	OFFSET_D	;比较号码,从第4个开始
	SAH	OFFSET_S	;比较号码,从第4个开始

	LAC	SYSTMP2
	BS	ACZ,COMP_ALLTELNUM_END	;没找到
	CALL	COMP_ONETELNUM
	BZ	ACZ,COMP_ALLTELNUM_END
	
	CALL	STOPREADDAT

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
	CALL	DAM_BIOSFUNC
	SFR	8
	BZ	ACZ,TELNUMALL_DEL_EXIT
	LAC	RESP
	SAH	MSG_N		;

	CALL	GET_MSGID
	BZ	ACZ,TELNUMALL_DEL_LOOP_1
;---找到相应Tag
	LAC	SYSTMP1
	CALL	DEL_ONETEL		;没有相应的录音就删除之
	CALL	TEL_GC_CHK
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
;	在当前Group中根据only-id找MSG_ID
;		从MSG_T个message中找only-id = MSG_N的message 
;		input : MSG_T = the total message in current mailbox
;			MSG_N=the specific only-id
;		output: ACCH = the MSG_ID you find(零表示没找到)
;############################################################################
GET_MSGID:
	LAC	MSG_T
	SAH	MSG_ID
GET_MSGID_1:
	LAC	MSG_ID
	BS	ACZ,GET_MSGID_END		;not find
	ORL	0XA600
        CALL    DAM_BIOSFUNC		;GET only-id
	SBH	MSG_N
	BS	ACZ,GET_MSGID_END		;find
	
	LAC	MSG_ID
	SBHK	1
	SAH	MSG_ID
	BS	B1,GET_MSGID_1		;next
GET_MSGID_END:
	LAC	MSG_ID
	
	RET
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
.if	0
	ANDL	0XFF
	ORL	0XE900
	CALL	DAM_BIOSFUNC
.else	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	SAH	SYSTMP0
	
	LACL	0XE401
	CALL	DAM_BIOSFUNC
	ADHK	1
	SAH	SYSTMP1

GET_TELID_LOOP:
	LAC	SYSTMP1
	SBHK	1
	SAH	SYSTMP1
	BS	ACZ,GET_TELID_END
	
	LAC	SYSTMP1
	ORL	0XEA00
	CALL	DAM_BIOSFUNC
	SBH	SYSTMP0
	BZ	ACZ,GET_TELID_LOOP

	LAC	SYSTMP1
.endif
GET_TELID_END:

	RET
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
	
.END
