.LIST
;############################################################################

;       Function : TELNUM_READ
;	根据得到的TEL_ID读出电话号码
;
;	input  : ACCH   = TEL_ID
;	OUTPUT : SYSTMP=the length of telephone data
;	
;	将出数据放在缓冲区 
;
;	variable:SYSTMP1 
;############################################################################
TELNUM_READ:
	SAH	SYSTMP1			;save the TEL_ID
	BZ	ACZ,TELNUM_READ1
	RET
TELNUM_READ1:	
	LACL    0XE600          ; set TEL working group 0
       	SAH     CONF
       	CALL    DAM_BIOS
       	
.IF	TEXT_OUTTELNUM	       	
;??????????????????????????
	LACL	0X018F
	SAH	RECE_BUF1
	SAH	RECE_BUF
	LACL	0X0302
	SAH	RECE_BUF2
	LACL	0X0504
	SAH	RECE_BUF3
	LACL	0X0F06
	SAH	RECE_BUF4
	LACL	0X3839
	SAH	RECE_BUF5
	LACL	0X3637
	SAH	RECE_BUF6
	LACL	0X3435
	SAH	RECE_BUF7
	LACL	0X3233
	SAH	RECE_BUF8
	LACL	0X3031
	SAH	RECE_BUF9
	LACL	0X3839
	SAH	RECE_BUF10
	LACL	0X3637
	SAH	RECE_BUF11
	LACL	0XFF35
	adh	CLK_CN
	SAH	RECE_BUF12
	
	lac	CLK_CN	;??????????????
	adhk	1		;??????
	andk	0x1f		;??????
	sah	CLK_CN	;??????????????
	
	LAC	RECE_BUF4
	SFR	8
	ADHK	8
	SAH	RECE_QUEUE
;?????????????????????????? 
.ELSE      	
       	
TELNUM_READ_LOOP:
;---byte 1---second
       	LACL	0XE200		;byte 1
	OR	SYSTMP1
       	SAH     CONF
       	CALL    DAM_BIOS
       	LAC    	RESP
       	SFR     8
       	BZ      ACZ,TELNUM_READ_EXIT
       	LAC     RESP
       	SFL	8
       	ORL	0X8F
       	SAH	RECE_BUF 
       	SAH	RECE_BUF1
	;SAH	+,1
;---byte 2---minute
	LACL	0XE200		;byte 2
	OR	SYSTMP1
       	SAH	CONF
       	CALL    DAM_BIOS
       	LAC    	RESP
       	SFR     8
       	BZ      ACZ,TELNUM_READ_EXIT
       	LAC     RESP
       	ANDL    0X0FF
       	SAH	RECE_BUF2
	;SAH	+,1
;---byte 3---hour	
	LACL	0XE200		;byte 3
	OR	SYSTMP1
       	SAH     CONF
       	CALL    DAM_BIOS
       	LAC    	RESP
       	SFR     8
       	BZ      ACZ,TELNUM_READ_EXIT
       	LAC     RESP
       	SFL	8
       	ANDL    0XFF00
       	OR	RECE_BUF2
	SAH	RECE_BUF2
	;SAH	+,1
;---byte 4---day	
	LACL	0XE200		;byte 4
	OR	SYSTMP1
       	SAH     CONF
       	CALL    DAM_BIOS
       	LAC    	RESP
       	SFR     8
       	BZ      ACZ,TELNUM_READ_EXIT
       	LAC     RESP
       	ANDL    0X0FF
       	SAH	RECE_BUF3
	;SAH	+,1
;---byte 5---month
	LACL	0XE200		;byte 5
	OR	SYSTMP1
       	SAH     CONF
       	CALL    DAM_BIOS
       	LAC    	RESP
       	SFR     8
       	BZ      ACZ,TELNUM_READ_EXIT
       	LAC     RESP
       	SFL	8
       	ANDL    0XFF00
	OR	RECE_BUF3
	SAH	RECE_BUF3
	;SAH	+,1
;---byte 6---year	
	LACL	0XE200		;byte 6
	OR	SYSTMP1
       	SAH     CONF
       	CALL    DAM_BIOS
       	LAC    	RESP
       	SFR     8
       	BZ      ACZ,TELNUM_READ_EXIT
       	LAC     RESP
       	ANDL    0X0FF
       	SAH	RECE_BUF4
	;SAH	+,1
;---byte 7---length
	LACL	0XE200		;byte 7
	OR	SYSTMP1
       	SAH     CONF
       	CALL    DAM_BIOS
       	LAC    	RESP
       	SFR     8
	BZ      ACZ,TELNUM_READ_EXIT
       	LAC     RESP
       	SFL	8
       	ANDL    0XFF00
       	OR	RECE_BUF4
	SAH	RECE_BUF4
	
	LAC	RESP
	ADHK	8
	SAH	RECE_QUEUE	;发送长度
       	;SAH	+,1
;---byte 8---TEL NUM 1	
	LACL	0XE200
	OR	SYSTMP1
       	SAH     CONF
       	CALL    DAM_BIOS
       	LAC    	RESP
       	SFR     8
       	BZ      ACZ,TELNUM_READ_EXIT
       	LAC     RESP
       	ANDL    0X0FF
       	SAH	RECE_BUF5
	;SAH	+,1
;---byte 9---TEL NUM 2
	LACL	0XE200
	OR	SYSTMP1
       	SAH     CONF
       	CALL    DAM_BIOS
       	LAC    	RESP
       	SFR     8
	BZ      ACZ,TELNUM_READ_EXIT
       	LAC     RESP
       	SFL	8
       	ANDL    0XFF00
       	OR	RECE_BUF5
	SAH	RECE_BUF5
       	;SAH	+,1
;---byte 10---TEL NUM 3
	LACL	0XE200
	OR	SYSTMP1
       	SAH     CONF
       	CALL    DAM_BIOS
       	LAC    	RESP
       	SFR     8
       	BZ      ACZ,TELNUM_READ_EXIT
       	LAC     RESP
       	ANDL    0X0FF
       	SAH	RECE_BUF6
	;SAH	+,1
;---byte 11---TEL NUM 4
	LACL	0XE200
	OR	SYSTMP1
       	SAH     CONF
       	CALL    DAM_BIOS
       	LAC    	RESP
       	SFR     8
	BZ      ACZ,TELNUM_READ_EXIT
       	LAC     RESP
       	SFL	8
       	ANDL    0XFF00
       	OR	RECE_BUF6
	SAH	RECE_BUF6
       	;SAH	+,1
;---byte 12---TEL NUM 5
	LACL	0XE200
	OR	SYSTMP1
       	SAH     CONF
       	CALL    DAM_BIOS
       	LAC    	RESP
       	SFR     8
       	BZ      ACZ,TELNUM_READ_EXIT
       	LAC     RESP
       	ANDL    0X0FF
       	SAH	RECE_BUF7
	;SAH	+,1
;---byte 13---TEL NUM 6
	LACL	0XE200
	OR	SYSTMP1
       	SAH     CONF
       	CALL    DAM_BIOS
       	LAC    	RESP
       	SFR     8
	BZ      ACZ,TELNUM_READ_EXIT
       	LAC     RESP
       	SFL	8
       	ANDL    0XFF00
       	OR	RECE_BUF7
	SAH	RECE_BUF7
       	;SAH	+,1
;---byte 14---TEL NUM 7
	LACL	0XE200
	OR	SYSTMP1
       	SAH     CONF
       	CALL    DAM_BIOS
       	LAC    	RESP
       	SFR     8
       	BZ      ACZ,TELNUM_READ_EXIT
       	LAC     RESP
       	ANDL    0X0FF
       	SAH	RECE_BUF8
	;SAH	+,1
;---byte 15---TEL NUM 8
	LACL	0XE200
	OR	SYSTMP1
       	SAH     CONF
       	CALL    DAM_BIOS
       	LAC    	RESP
       	SFR     8
	BZ      ACZ,TELNUM_READ_EXIT
       	LAC     RESP
       	SFL	8
       	ANDL    0XFF00
       	OR	RECE_BUF8
	SAH	RECE_BUF8
       	;SAH	+,1
;---byte 16---TEL NUM 9
	LACL	0XE200
	OR	SYSTMP1
       	SAH     CONF
       	CALL    DAM_BIOS
       	LAC    	RESP
       	SFR     8
       	BZ      ACZ,TELNUM_READ_EXIT
       	LAC     RESP
       	ANDL    0X0FF
       	SAH	RECE_BUF9
	;SAH	+,1
;---byte 17---TEL NUM 10
	LACL	0XE200
	OR	SYSTMP1
       	SAH     CONF
       	CALL    DAM_BIOS
       	LAC    	RESP
       	SFR     8
	BZ      ACZ,TELNUM_READ_EXIT
       	LAC     RESP
       	SFL	8
       	ANDL    0XFF00
       	OR	RECE_BUF9
	SAH	RECE_BUF9
       	;SAH	+,1
;---byte 18---TEL NUM 11
	LACL	0XE200
	OR	SYSTMP1
       	SAH     CONF
       	CALL    DAM_BIOS
       	LAC    	RESP
       	SFR     8
       	BZ      ACZ,TELNUM_READ_EXIT
       	LAC     RESP
       	ANDL    0X0FF
       	SAH	RECE_BUF10
	;SAH	+,1
;---byte 19---TEL NUM 12
	LACL	0XE200
	OR	SYSTMP1
       	SAH     CONF
       	CALL    DAM_BIOS
       	LAC    	RESP
       	SFR     8
	BZ      ACZ,TELNUM_READ_EXIT
       	LAC     RESP
       	SFL	8
       	ANDL    0XFF00
       	OR	RECE_BUF10
	SAH	RECE_BUF10
       	;SAH	+,1
;---byte 20---TEL NUM 13
	LACL	0XE200
	OR	SYSTMP1
       	SAH     CONF
       	CALL    DAM_BIOS
       	LAC    	RESP
       	SFR     8
       	BZ      ACZ,TELNUM_READ_EXIT
       	LAC     RESP
       	ANDL    0X0FF
       	SAH	RECE_BUF11
	;SAH	+,1
;---byte 21---TEL NUM 14
	LACL	0XE200
	OR	SYSTMP1
       	SAH     CONF
       	CALL    DAM_BIOS
       	LAC    	RESP
       	SFR     8
	BZ      ACZ,TELNUM_READ_EXIT
       	LAC     RESP
       	SFL	8
       	ANDL    0XFF00
       	OR	RECE_BUF11
	SAH	RECE_BUF11
	;SAH	+,1
;---byte 22---TEL NUM 15
	LACL	0XE200
	OR	SYSTMP1
       	SAH     CONF
       	CALL    DAM_BIOS
       	LAC    	RESP
       	SFR     8
       	BZ      ACZ,TELNUM_READ_EXIT
       	LAC     RESP
       	ANDL    0X0FF
       	SAH	RECE_BUF12
	;SAH	+,1
;---byte 23---TEL NUM 16
	LACL	0XE200
	OR	SYSTMP1
       	SAH     CONF
       	CALL    DAM_BIOS
       	LAC    	RESP
       	SFR     8
	BZ      ACZ,TELNUM_READ_EXIT
       	LAC     RESP
       	SFL	8
       	ANDL    0XFF00
       	OR	RECE_BUF12
	SAH	RECE_BUF12
	;SAH	+,1
TELNUM_READ_EXIT:
	LACL	0XE300
       	SAH     CONF
       	CALL    DAM_BIOS 

.ENDIF       	
       	LACK	1
;-----------------------------------------
	
	RET

;############################################################################
;
;       Function : TELNUM_DEL
;	delete the specific telehone number
;
;	INPUT  : ACCH	= TEL_ID you will delete
;	OUTPUT :	 
;############################################################################
TELNUM_DEL:
	ANDL	0XFF
	BS	ACZ,TELNUM_DEL_EXIT
	ORL	0XE500
	SAH	CONF
	CALL	DAM_BIOS
	
	CALL	TEL_GC_CHK
TELNUM_DEL_EXIT:		
	RET
;############################################################################
;
;       Function : TELNUMALL_DEL
;	delete the all telehone number that mapping messages
;
;	INPUT  : no
;	OUTPUT : no
;	variable: SYSTMP
;		 
;############################################################################
TELNUMALL_DEL:
	
	LACL	0XE600		;set the TEL working group
	SAH	CONF
	CALL	DAM_BIOS
	
	LACL	0XE401		;Get the total TEL in working group
	SAH	CONF
	CALL	DAM_BIOS
	LAC	RESP
	ANDL	0X0F00
	BZ	ACZ,TELNUMALL_DEL_EXIT	;no tel-number?
	
	LAC	RESP
	SAH	SYSTMP
	BS	ACZ,TELNUMALL_DEL_EXIT	;no tel-number?
	
	;LACL	0XD000
	;SAH	CONF
	;CALL	DAM_BIOS
	
	;LACL    0X3000
        ;SAH     CONF
        ;CALL    DAM_BIOS
        ;LAC     RESP
        ;SAH     MSG_T		;save the number of TOTAL messages
	CALL	MSG_CHK
TELNUMALL_DEL_LOOP:
	LAC	SYSTMP
	BS	ACZ,TELNUMALL_DEL_EXIT
	
	LACL	0XEA00
	OR	SYSTMP
	SAH	CONF
	CALL	DAM_BIOS
	LAC	RESP
	SFR	8
	BZ	ACZ,TELNUMALL_DEL_EXIT
	LAC	RESP
	SAH	FILE_ID
	
	CALL	FIND_ICM
	BZ	ACZ,TELNUMALL_DEL_LOOP_1
		
	LACL	0XE500
	OR	SYSTMP
	SAH	CONF
	CALL	DAM_BIOS
	
	CALL	TEL_GC_CHK
	CALL	GC_CHK
TELNUMALL_DEL_LOOP_1:	
	LAC	SYSTMP
	SBHK	1
	SAH	SYSTMP
	BS	B1,TELNUMALL_DEL_LOOP
TELNUMALL_DEL_EXIT:		
	RET
;############################################################################
;	Fumction : FIND_ICM
;		从MSG_T个message中找usr data0=ICM的message 
;		input : MSG_T = the total message in current mailbox
;			FILE_ID=the specific usr data0
;		output: ACCH = the message you find(零表示没找到)
;############################################################################
FIND_ICM:
	LAC	MSG_T
	SAH	MSG_ID
	
FIND_ICM_1:
	LAC	MSG_ID
	BS	ACZ,FIND_ICM_2		;not find
		
	LACL	0XA900 			;GET USER INDEX DATA0
	OR	MSG_ID
        SAH     CONF
        CALL    DAM_BIOS		
	LAC     RESP
	SBH	FILE_ID
	BS	ACZ,FIND_ICM_2
	
	LAC	MSG_ID
	SBHK	1
	SAH	MSG_ID
	BS	B1,FIND_ICM_1
FIND_ICM_2:
	LAC	MSG_ID
	
	RET
;############################################################################
;
;	Function : GET_MSGMSG
;	save the VP message number in working group
;
;	将相应MSG_ID数据(暂存)写入临时RAM存贮区
;	input  : ACCH = MSG_ID
;	output :  SYSTMP0,SYSTMP1,SYSTMP2,SYSTMP3
;	variable :SYSTMP
;
;############################################################################
GET_MSGMSG:
	SAH	SYSTMP
	BZ	ACZ,GET_MSGMSG1
	RET
GET_MSGMSG1:
	LAC	SYSTMP
	ANDK	0X7F
	ORL	0XA000
	SAH	CONF
	CALL	DAM_BIOS
	LAC	RESP
	ANDK	0X7F
	SAH	SYSTMP0		;second
	
	LAC	SYSTMP
	ANDK	0X7F
	ORL	0XA100
	SAH	CONF
	CALL	DAM_BIOS
	LAC	RESP
	SFL	8
	ANDL	0XFF00
	OR	SYSTMP0
	SAH	SYSTMP0		;minute
;---	
	LAC	SYSTMP
	ANDK	0X7F
	ORL	0XA200
	SAH	CONF
	CALL	DAM_BIOS
	LAC	RESP
	ANDK	0X7F
	SAH	SYSTMP1		;hour
	
	LAC	SYSTMP
	ANDK	0X7F
	ORL	0XAE00
	SAH	CONF
	CALL	DAM_BIOS
	LAC	RESP
	SFL	8
	ANDL	0XFF00
	OR	SYSTMP1
	SAH	SYSTMP1		;day
;---	
	LAC	SYSTMP
	ANDK	0X7F
	ORL	0XAD00
	SAH	CONF
	CALL	DAM_BIOS
	LAC	RESP
	ANDK	0X7F
	SAH	SYSTMP2		;month
	
	LAC	SYSTMP
	ANDK	0X7F
	ORL	0XAC00
	SAH	CONF
	CALL	DAM_BIOS
	LAC	RESP
	SFL	8
	ANDL	0XFF00
	OR	SYSTMP2
	SAH	SYSTMP2		;year
;---	

	RET
;############################################################################
;
;	Function : WRITE_MEMOMSG
;	save the VP message number in working group
;
;	将相应MSG_ID数据(暂存RAM中)写入临时FLASH存贮区
;	input  : SYSTMP0,SYSTMP1,SYSTMP2,SYSTMP3,SYSTMP4,SYSTMP5
;	output :  
;	
;############################################################################
WRITE_MEMOMSG:
	LACL	0XE605
	SAH	CONF
	CALL	DAM_BIOS
;---	
	LAC	SYSTMP0
	ANDK	0X7F
	CALL	HEX_DGT	;!!!!!!!!!
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS	;second
	
	LAC	SYSTMP0
	SFR	8
	ANDK	0X7F
	CALL	HEX_DGT	;!!!!!!!!!
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS	;minute
;---	
	LAC	SYSTMP1
	ANDK	0X7F
	CALL	HEX_DGT	;!!!!!!!!!
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS	;hour
	
	LAC	SYSTMP1
	SFR	8
	ANDK	0X7F
	CALL	HEX_DGT	;!!!!!!!!!
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS	;day
;---	
	LAC	SYSTMP2
	ANDK	0X7F
	CALL	HEX_DGT	;!!!!!!!!!
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS	;month
	
	LAC	SYSTMP2
	SFR	8
	ANDK	0X7F
	CALL	HEX_DGT	;!!!!!!!!!
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS	;year
;---
	LACL	0XE004
	SAH	CONF
	CALL	DAM_BIOS	;length
	
	LACL	0XE04D
	SAH	CONF
	CALL	DAM_BIOS	;M
	
	LACL	0XE045
	SAH	CONF
	CALL	DAM_BIOS	;E
	
	LACL	0XE04D
	SAH	CONF
	CALL	DAM_BIOS	;M
	
	LACL	0XE04F
	SAH	CONF
	CALL	DAM_BIOS	;O
	
	LACL	0XE100
	SAH	CONF
	CALL	DAM_BIOS	;end write
	
	CALL	TEL_GC_CHK
WRITE_MEMOMSG_END:	
	RET
;############################################################################
;
;	Function : WRITE_ICMMSG
;	save the VP message number in working group
;
;	将相应MSG_ID数据(暂存RAM中)写入临时FLASH存贮区
;	input  : SYSTMP0,SYSTMP1,SYSTMP2,SYSTMP3,SYSTMP4,SYSTMP5
;	output : ACCH = 0/1 ==>NO/have TEL NUM 
;	
;############################################################################
WRITE_ICMMSG:
	LACL	0XE605
	SAH	CONF
	CALL	DAM_BIOS
	
	CALL	GET_TELT
	BS	ACZ,WRITE_ICMMSG1
	
	RET
WRITE_ICMMSG1:
;---	
	LAC	SYSTMP0
	ANDK	0X7F
	CALL	HEX_DGT	;!!!!!!!!!
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS	;second
	
	LAC	SYSTMP0
	SFR	8
	ANDK	0X7F
	CALL	HEX_DGT	;!!!!!!!!!
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS	;minute
;---	
	LAC	SYSTMP1
	ANDK	0X7F
	CALL	HEX_DGT	;!!!!!!!!!
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS	;hour
	
	LAC	SYSTMP1
	SFR	8
	ANDK	0X7F
	CALL	HEX_DGT	;!!!!!!!!!
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS	;day
;---	
	LAC	SYSTMP2
	ANDK	0X7F
	CALL	HEX_DGT	;!!!!!!!!!
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS	;month
	
	LAC	SYSTMP2
	SFR	8
	ANDK	0X7F
	CALL	HEX_DGT	;!!!!!!!!!
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS	;year
;---
	LACL	0XE001
	SAH	CONF
	CALL	DAM_BIOS	;length
	
	LACL	0XE020
	SAH	CONF
	CALL	DAM_BIOS	;SPACE

	LACL	0XE100
	SAH	CONF
	CALL	DAM_BIOS	;end write
	
	CALL	TEL_GC_CHK
WRITE_ICMMSG_END:	
	LACK	0
	
	RET
;############################################################################
;
;	Function : TELNUM_WRITE
;	save the telephone number in working group
;
;	将刚接收到的数据(暂存)写入FLASH
;	input  : RECE_BUF1 = the first addr of the TEL_NUM
;	output : ACCH = no
;	variable : SYSTMP
;
;############################################################################
TELNUM_WRITE:
	LACL	0XE605
	SAH	CONF
	CALL	DAM_BIOS

TELNUM_WRITE_LOOP:
.if	TEXT_WTELNUM
	LACL	0X018F
	SAH	RECE_BUF1
	LACL	0X0302
	SAH	RECE_BUF2
	LACL	0X0504
	SAH	RECE_BUF3
	LACL	0X0806
	SAH	RECE_BUF4
	LACL	0X3839
	SAH	RECE_BUF5
	LACL	0X3637
	SAH	RECE_BUF6
	LACL	0X3435
	SAH	RECE_BUF7
	LACL	0X3233
	adh	CLK_CN
	SAH	RECE_BUF8
	
	lac	CLK_CN	;??????????????
	adhl	0x0101		;??????
	andl	0x0707		;??????
	sah	CLK_CN	;??????????????
.endif	
;---byte 1---second
	LAC	RECE_BUF1
	SFR	8
	ANDL	0X0FF
	CALL	DGT_HEX
	SAH	TMR_SEC		;秒

	LAC	RECE_BUF1
	SFR	8
	ANDL	0X0FF
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS
;---byte 2---minute	----------
	LAC	RECE_BUF2
	ANDL	0X0FF
	CALL	DGT_HEX
	SAH	TMR_MIN		;分
	
	LAC	RECE_BUF2
	ANDL	0X0FF
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS
;---byte 3---hour
	LAC	RECE_BUF2
	SFR	8
	ANDL	0X0FF
	CALL	DGT_HEX
	SAH	TMR_HOUR	;时
	
	LAC	RECE_BUF2
	SFR	8
	ANDL	0X0FF
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS
;---byte 4---day	----------
	LAC	RECE_BUF3
	ANDL	0X0FF
	CALL	DGT_HEX
	SAH	TMR_DAY		;日

	LAC	RECE_BUF3
	ANDL	0X0FF
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS
;---byte 5---month
	LAC	RECE_BUF3
	SFR	8
	ANDL	0X0FF
	CALL	DGT_HEX
	SAH	TMR_MONTH	;月
	
	LAC	RECE_BUF3
	SFR	8
	ANDL	0X0FF
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS
;---byte 6---year-----------------
	LAC	RECE_BUF4
	ANDL	0X0FF
	CALL	DGT_HEX
	SAH	TMR_YEAR	;年

	LAC	RECE_BUF4
	ANDL	0X0FF
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS
;---byte 7---length	
	LAC	RECE_BUF4
	SFR	8
	ANDL	0X0FF
	SAH	RECE_QUEUE		;保存长度用于后于后续判断
	ADHK	3		;???????????????
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS
;---byte 8---TEL NUM 1	----------
	LAC	RECE_QUEUE
	BS	ACZ,TELNUM_WRITE_EXIT
	
	
	LACL	0XE043		;C?????????????
	SAH	CONF
	CALL	DAM_BIOS
	LACL	0XE049		;I?????????????
	SAH	CONF
	CALL	DAM_BIOS
	LACL	0XE044		;D?????????????
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	RECE_BUF5
	ANDL	0X0FF
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	RECE_QUEUE
	SBHK	1
	SAH	RECE_QUEUE
;---byte 9---TEL NUM 2
	LAC	RECE_QUEUE
	BS	ACZ,TELNUM_WRITE_EXIT
	LAC	RECE_BUF5
	SFR	8
	ANDL	0X0FF
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	RECE_QUEUE
	SBHK	1
	SAH	RECE_QUEUE
;---byte 10---TEL NUM 3
	LAC	RECE_QUEUE
	BS	ACZ,TELNUM_WRITE_EXIT
	LAC	RECE_BUF6
	ANDL	0X0FF
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	RECE_QUEUE
	SBHK	1
	SAH	RECE_QUEUE
;---byte 11---TEL NUM 4
	LAC	RECE_QUEUE
	BS	ACZ,TELNUM_WRITE_EXIT
	LAC	RECE_BUF6
	SFR	8
	ANDL	0X0FF
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	RECE_QUEUE
	SBHK	1
	SAH	RECE_QUEUE
;---byte 12---TEL NUM 5
	LAC	RECE_QUEUE
	BS	ACZ,TELNUM_WRITE_EXIT
	LAC	RECE_BUF7
	ANDL	0X0FF
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	RECE_QUEUE
	SBHK	1
	SAH	RECE_QUEUE
;---byte 13---TEL NUM 6
	LAC	RECE_QUEUE
	BS	ACZ,TELNUM_WRITE_EXIT
	LAC	RECE_BUF7
	SFR	8
	ANDL	0X0FF
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	RECE_QUEUE
	SBHK	1
	SAH	RECE_QUEUE
;---byte 14---TEL NUM 7
	LAC	RECE_QUEUE
	BS	ACZ,TELNUM_WRITE_EXIT
	LAC	RECE_BUF8
	ANDL	0X0FF
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	RECE_QUEUE
	SBHK	1
	SAH	RECE_QUEUE
;---byte 15---TEL NUM 8
	LAC	RECE_QUEUE
	BS	ACZ,TELNUM_WRITE_EXIT
	LAC	RECE_BUF8
	SFR	8
	ANDL	0X0FF
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	RECE_QUEUE
	SBHK	1
	SAH	RECE_QUEUE
;---byte 16---TEL NUM 9
	LAC	RECE_QUEUE
	BS	ACZ,TELNUM_WRITE_EXIT
	LAC	RECE_BUF9
	ANDL	0X0FF
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	RECE_QUEUE
	SBHK	1
	SAH	RECE_QUEUE
;---byte 17---TEL NUM 10
	LAC	RECE_QUEUE
	BS	ACZ,TELNUM_WRITE_EXIT
	LAC	RECE_BUF9
	SFR	8
	ANDL	0X0FF
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	RECE_QUEUE
	SBHK	1
	SAH	RECE_QUEUE
;---byte 18---TEL NUM 11
	LAC	RECE_QUEUE
	BS	ACZ,TELNUM_WRITE_EXIT
	LAC	RECE_BUF10
	ANDL	0X0FF
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	RECE_QUEUE
	SBHK	1
	SAH	RECE_QUEUE
;---byte 19---TEL NUM 12
	LAC	RECE_QUEUE
	BS	ACZ,TELNUM_WRITE_EXIT
	LAC	RECE_BUF10
	SFR	8
	ANDL	0X0FF
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	RECE_QUEUE
	SBHK	1
	SAH	RECE_QUEUE
;---byte 20---TEL NUM 13
	LAC	RECE_QUEUE
	BS	ACZ,TELNUM_WRITE_EXIT
	LAC	RECE_BUF11
	ANDL	0X0FF
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	RECE_QUEUE
	SBHK	1
	SAH	RECE_QUEUE
;---byte 21---TEL NUM 14
	LAC	RECE_QUEUE
	BS	ACZ,TELNUM_WRITE_EXIT
	LAC	RECE_BUF11
	SFR	8
	ANDL	0X0FF
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	RECE_QUEUE
	SBHK	1
	SAH	RECE_QUEUE
;---byte 22---TEL NUM 15
	LAC	RECE_QUEUE
	BS	ACZ,TELNUM_WRITE_EXIT
	LAC	RECE_BUF12
	ANDL	0X0FF
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	RECE_QUEUE
	SBHK	1
	SAH	RECE_QUEUE
;---byte 23---TEL NUM 16
	LAC	RECE_QUEUE
	BS	ACZ,TELNUM_WRITE_EXIT
	LAC	RECE_BUF12
	SFR	8
	ANDL	0X0FF
	ORL	0XE000
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	RECE_QUEUE
	SBHK	1
	SAH	RECE_QUEUE

TELNUM_WRITE_EXIT:
	LACL	0XE100
	SAH	CONF
	CALL	DAM_BIOS
	
	CALL	TEL_GC_CHK
	
	LACK	0
	
	RET
;############################################################################
;
;	Function : TMPNUM_DEL
;	delete the telephone number in tempe working group
;
;	删除临时号码(退出ICM状态,或本地播放前)
;	input  : RECE_BUF1 = the first addr of the TEL_NUM
;	output : ACCH = no
;	variable : SYSTMP
;
;############################################################################
TMPNUM_DEL:
	LACL	0XE605		;set the TEL working group 0
	SAH	CONF
	CALL	DAM_BIOS
	
	LACL	0XE401		;set the TEL working group 0
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	RESP
	BS	ACZ,TMPNUM_DEL_END
	ADHK	1
	SAH	SYSTMP
TMPNUM_DEL_LOOP:
	LAC	SYSTMP
	SBHK	1
	SAH	SYSTMP
	BS	ACZ,TMPNUM_DEL_END	
	
	LACL	0XE500
	OR	SYSTMP
	SAH	CONF
	CALL	DAM_BIOS
	
	CALL	TEL_GC_CHK
	BS	B1,TMPNUM_DEL_LOOP
TMPNUM_DEL_END:
		
	RET
;############################################################################
;
;	Function : COL_ICMTEL
;	delete the telephone number in tempe working group
;
;	建立ICM录音与来电号码的关联(ICM录音成功后)
;	input  : ACCH = USER DATA0
;	output : no
;	variable : SYSTMP
;
;############################################################################
COL_ICMTEL:
	SAH	SYSTMP
	
	LACL	0XE605		;置当前GROUP = 5
	SAH	CONF
	CALL	DAM_BIOS
	
	LACK	0		;以下将group(5)中的最新号码,复制到group(0)
	SAH	BUF1		
	
	CALL	GET_TELT
	BS	ACZ,COL_ICMTEL_END	;无临时号码退出
	ORL	0XED00
	SAH	CONF
	CALL	DAM_BIOS
	
	LACL	0XE600		;置当前GROUP = 0
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	SYSTMP		;以下将group(0)中的最新号码置index-0 = SYSTMP
	SAH	BUF1
	
	CALL	GET_TELT
	BS	ACZ,COL_ICMTEL_END
	ORL	0XE700
	SAH	CONF
	CALL	DAM_BIOS
	
	CALL	TEL_GC_CHK
	
COL_ICMTEL_END:
		
	RET
	
;############################################################################
;	FUNCTION : GET_TELID
;	根据index-0找TEL_ID
;	INPUT : ACCH = index-0
;	OUTPUT: ACCH = MSG_ID(0表示没找到)
;	
;	variable : SYSTMP0
;		   SYSTMP1
;############################################################################
.IF	TEXT_0XE900
GET_TELID:
	SAH	SYSTMP0
	
	LACL	0XE600
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	SYSTMP0
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
.ELSE
GET_TELID:
	SAH	SYSTMP0
	
	LACL	0XE600
	SAH	CONF
	CALL	DAM_BIOS
	
	CALL	GET_TELT
	SAH	SYSTMP1
GET_TELID1:
	LAC	SYSTMP1
	BS	ACZ,GET_TELID_END
	ANDL	0XFF
	ORL	0XEA00
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	RESP
	SBH	SYSTMP0
	BS	ACZ,GET_TELID2
	LAC	SYSTMP1
	SBHK	1
	SAH	SYSTMP1
	BS	B1,GET_TELID1
GET_TELID2:
	LAC	SYSTMP1
GET_TELID_END:
	RET
.ENDIF

;---------------上面是AXC用到的,下面是m48要用的??????????????????????????????
;############################################################################
;	FUNCTION : GET_TELT
;	INPUT : NO
;	OUTPUT: ACCH
;############################################################################
GET_TELT:
	LACL	0XE401
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	RESP
	ANDK	0X7F
	
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
;	FUNCTION : SET_USRDAT
;	INPUT : ACCH = USER INDEX DATA0
;	OUTPUT: NO
;############################################################################
SET_USRDAT:
	ANDL	0XFF
	ORL	0X7500
	SAH	CONF
	CALL	DAM_BIOS
	
	RET
;############################################################################
;	FUNCTION : GET_USRDAT
;	INPUT : ACCH = MSG_ID
;	OUTPUT: ACCH = USER INDEX DATA0
;############################################################################
GET_USRDAT:
	ANDL	0XFF
	ORL	0XA900
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	RESP
	
	RET
;############################################################################
;	FUNCTION : GET_VPLEN
;	将与MSG_ID的USER-DATA0相同的VP全部找出,以FILE_ID(MSG_ID)为基址,以FILE_LEN为长度返回
;	INPUT : ACCH = MSG_ID(输入的MSG_ID是USER-DATA0相同所有值的最大值)
;	OUTPUT: MSG_ID = FILE_ID(由相同的USR-DATA0最大值变成相同的USR-DATA0的MSG_ID最小的值)
;		FILE_LEN(本次相同USE_DAT的VP条目数-1)
;############################################################################
GET_VPLEN:
	SAH	MSG_ID
	CALL	GET_USRDAT
	SAH	FILE_ID
	
	LACK	0
	SAH	FILE_LEN
GET_VPLEN_LOOP:
	LAC	FILE_LEN
	ADHK	1
	SAH	FILE_LEN
	
	LAC	MSG_ID
	SBHK	1
	SAH	MSG_ID
	BS	ACZ,GET_VPLEN_1
	CALL	GET_USRDAT
	SBH	FILE_ID
	BS	ACZ,GET_VPLEN_LOOP
GET_VPLEN_1:
	LAC	MSG_ID
	ADHK	1
	SAH	MSG_ID
	SAH	FILE_ID
	
	LAC	FILE_LEN
	SBHK	1
	SAH	FILE_LEN
GET_VPLEN_END:
	RET
;############################################################################
;	FUNCTION : GET_RVPLEN
;	将与MSG_ID的USER-DATA0相同的VP全部找出,以FILE_ID(MSG_ID)为基址,以FILE_LEN为长度返回
;	INPUT : ACCH = MSG_ID(输入的MSG_ID是USER-DATA0相同所有值的最小值)
;	OUTPUT: MSG_ID = FILE_ID(MSG_ID保持为USER-DATA0相同最小的值)
;		FILE_LEN(本次相同USE_DAT的VP条目数-1)
;############################################################################
GET_RVPLEN:
	SAH	MSG_ID
	CALL	GET_USRDAT
	SAH	FILE_ID
	
	LACK	0
	SAH	FILE_LEN
GET_RVPLEN_LOOP:
	LAC	FILE_LEN
	ADHK	1
	SAH	FILE_LEN
	
	LAC	MSG_ID
	ADH	FILE_LEN
	CALL	GET_USRDAT
	SBH	FILE_ID
	BS	ACZ,GET_RVPLEN_LOOP

	LAC	MSG_ID
	SAH	FILE_ID
	
	LAC	FILE_LEN
	SBHK	1
	SAH	FILE_LEN
GET_RVPLEN_END:
	RET
;############################################################################
;	FUNCTION : GET_VPMSG
;	将与MSG_ID的USER-DATA0相同的录音按id号由小到大(MSG_ID..MSG_ID+FILE_LEN)的顺序入队列
;	INPUT : FLIE_LEN
;		FILE_ID(first VP)     
;	OUTPUT: NO
;############################################################################
GET_VPMSG:
	LACK	0
	SAH	MSG_N		;已入队列的条数
GET_VPMSG_1:
	LAC	FILE_LEN
	SBH	MSG_N
	BS	SGN,GET_VPMSG_END

	LAC	FILE_ID		;message(record)
	ADH	MSG_N
	ORL	0XFE00
	CALL	STOR_VP
	
	LAC	MSG_N
	ADHK	1
	SAH	MSG_N
	BS	B1,GET_VPMSG_1
GET_VPMSG_END:
	RET
;############################################################################
;	FUNCTION : DEL_VPMSG
;	将与MSG_ID的USER-DATA0相同的录音按id号由小到大(MSG_ID..MSG_ID+FILE_LEN)的顺序置删除标志
;	INPUT : FLIE_LEN
;		FILE_ID(first MSG_ID of VP)     
;	OUTPUT: NO
;############################################################################
DEL_VPMSG:
	LACK	0
	SAH	MSG_N		;已处理的条数
DEL_VPMSG_1:
	LAC	FILE_LEN
	SBH	MSG_N
	BS	SGN,DEL_VPMSG_END
	
	LAC	FILE_ID		;message(record)
	ADH	MSG_N
	ANDK	0X7F
	ORL	0X2080
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	MSG_N
	ADHK	1
	SAH	MSG_N
	BS	B1,DEL_VPMSG_1
DEL_VPMSG_END:
	RET
;############################################################################
;	FUNCTION : SETOLD_VPMSG
;	将与MSG_ID的USER-DATA0相同的录音按id号由小到大(MSG_ID..MSG_ID+FILE_LEN)的播放后停止
;	INPUT : FLIE_LEN
;		FILE_ID(first MSG_ID of VP)     
;	OUTPUT: NO
;############################################################################
SETOLD_VPMSG:
	LACK	0
	SAH	MSG_N		;已处理的条数
SETOLD_VPMSG_1:
	LAC	FILE_LEN
	SBH	MSG_N
	BS	SGN,SETOLD_VPMSG_END
	
	LAC	FILE_ID		;message(record)
	ADH	MSG_N
	ANDL	0X7F
	ORL	0X2000
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	FILE_ID		;message(record)
	ADH	MSG_N
	ANDL	0X7F
	ORL	0X2200
	SAH	CONF
	CALL	DAM_BIOS
	
	LAC	MSG_N
	ADHK	1
	SAH	MSG_N
	BS	B1,SETOLD_VPMSG_1
SETOLD_VPMSG_END:
	RET	
.END
