.NOLIST
;*******************************************************************************
;*This section use to lookup tel-data(number and name)
;*
;*The program can go to here by the reason as bellow:
;*
;*Press TIME-KEY 2s in idle,respone "CMSG_KEY3L"(Display select option)
;*or
;*No save exit from edit/add TEL-data,respone "CBOOK_SLET"(Display select option)
;*or
;*Save exit from edit/add TEL-data,respone "CSTOR_TYPE"(Display the newest TEL-data)
;*--------------------------------------
;*The program can exit by the reason as bellow:
;*
;*Exit-KEY detected then exit to idle at "phone-idle" status				-Goto idle
;*or
;*Time-KEY detected then exit to idle at "phone-idle-edit" status with "CNUMB_BADD"	-Goto add TEL-data
;*or
;*Time-KEY detected then exit to idle at "TEL-lookup" status with "CNUMB_EDIT"		-Goto edit TEL-data 
;*******************************************************************************
.INCLUDE MD20U.INC
.INCLUDE REG_D20.inc
.INCLUDE CONST.INC
.INCLUDE EXTERN.INC
;-------------------------------------------------------------------------------
.EXTERN	SetFlashStartAddress
.EXTERN	LoadHostCode
.EXTERN	GetOneConst	;(INPUT=ACCH(ProgramRamAddress),OUTPUT=ACCH(ReadData))
.EXTERN	GetMoreConst	;(INPUT=ACCH(ProgramRamStartingAddress)ACCL(ReadWordNumber)AR1(StoreDataRamAddress),OUTPUT=)
;-------------------------------------------------------------------------------
.GLOBAL	LOCAL_PROBOOK1
;-------------------------------------------------------------------------------
.LIST
.ORG    ADDR_SECOND
;-------------------------------------------------------------------------------
;	翻查/编辑电话本
;	NOTE : MSG_ID/MSG_T/MSG_N = current_TEL_ID/the total number of tel/the order of current tel
;-------------------------------------------------------------------------------
LOCAL_PROBOOK1:
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,LOCAL_PROBOOK_RING
	LAC	MSG
	XORL	CVP_STOP		;PLAY END
	BS	ACZ,LOCAL_PRO1BOOK_VPSTOP

	LAC	PRO_VAR
	ANDK	0X0F
	BS	ACZ,LOCAL_PRO1BOOK_0	;local-idle to display
	SBHK	1
	BS	ACZ,LOCAL_PRO1BOOK_1	;Display(adjust edit/search)
	SBHK	1
	BS	ACZ,LOCAL_PRO1BOOK_2	;lookup phone only
	SBHK	1
	BS	ACZ,LOCAL_PRO1BOOK_3	;Dial
	SBHK	1
	BS	ACZ,LOCAL_PRO1BOOK_4	;Select which type the TEL Stor 

	RET
;---------------------------------------
LOCAL_PROBOOK_RING:
	CALL	INIT_DAM_FUNC
	CALL	CLR_FUNC
	LACK	0
	SAH	PRO_VAR
	CALL	BLED_ON
	LACL	CMSG_INIT
	CALL	STOR_MSG
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9E
	CALL	SEND_DAT
	LACL	6
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	
	RET
;---------------------------------------
LOCAL_PRO1BOOK_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	30
	BZ	SGN,LOCAL_PRO1BOOK_EXIT

	RET
;---------------------------------------
LOCAL_PRO1BOOK_VPSTOP:
	LACK	0
	SAH	PRO_VAR1		;计数器清零(按键松开后BEEP结束)	
	CALL	DAA_OFF
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PRO1BOOK_0:
	LAC	MSG
	XORL	CMSG_KEY2S
	BS	ACZ,LOCAL_PRO1BOOK_0_SADJ	;REW
	LAC	MSG
	XORL	CMSG_KEY1S
	BS	ACZ,LOCAL_PRO1BOOK_0_SADJ	;FFW
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,LOCAL_PRO1BOOK_EXIT	;EXIT
	
	LAC	MSG
	XORL	CMSG_KEY3L
	BS	ACZ,LOCAL_PRO1BOOK_0_PHONEBOOK		;电话本
	LAC	MSG
	XORL	CMSG_KEY3S
	BS	ACZ,LOCAL_PRO1BOOK_0_TIME		;release"TIME"key
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PRO1BOOK_TMR
	LAC	MSG
	XORL	CBOOK_SLET
	BS	ACZ,MAIN_PRO0_PHONEBOOK_SLCT		;Goto option select(search)

	LAC	MSG
	XORL	CSTOR_TYPE	;Going to select TEL type(Normal/VIP/Filter)
	BS	ACZ,LOCAL_PRO1BOOK_0_SELECTTYPE	

	RET
;---------------------------------------
LOCAL_PRO1BOOK_0_PHONEBOOK:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
	CALL	BLED_ON
	LACK	CGROUP_PBOOK
	CALL	SET_TELGROUP	;set group 4

	CALL	GET_TELT
	SAH	MSG_T		;取总数
	
	LACK	0
	SAH	MSG_N
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	LACL	0X9E		;SEND COMMAND(Enter edit menu)
	CALL	SEND_DAT
	LACK	0
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	RET
;---------------------------------------
LOCAL_PRO1BOOK_0_TIME:
	LACK	0X01
	SAH	PRO_VAR
	
	RET
;---------------------------------------
MAIN_PRO0_PHONEBOOK_SLCT:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP

	LACK	CGROUP_PBOOK
	CALL	SET_TELGROUP	;set group 4

	CALL	GET_TELT
	SAH	MSG_T		;取总数

	LACK	0X01
	SAH	PRO_VAR
	
	LACK	0
	SAH	MSG_N
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	LACL	0X9E		;SEND COMMAND(Enter edit menu)
	CALL	SEND_DAT
	LACK	0
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
	RET
;---------------------------------------
LOCAL_PRO1BOOK_0_SELECTTYPE:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP

	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER

	LACK	0X04
	SAH	PRO_VAR
	
	LACK	3	;Normal Number first
	SAH	MSG_N
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	LACL	0XD2		;SEND COMMAND(TEL type)
	CALL	SEND_DAT
	LAC	MSG_N
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	RET
;-------------------------------------------------------------------------------
LOCAL_PRO1BOOK_1:	
	LAC	PRO_VAR
	SFR	4
	ANDK	0X0F
	BS	ACZ,LOCAL_PRO1BOOK_1_0	;Select(Edit/search) 	;长按TIME再抬起之后进入的最初始状态(Display Edit/Search)
	SBHK	1
	BS	ACZ,LOCAL_PRO1BOOK_1_1	;Select(normal/VIP/Filter/all)
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PRO1BOOK_1_0:	;选择添加或查找
;MAIN_PRO10_0_1_1:	
	LAC	MSG
	XORL	CMSG_KEY2S
	BS	ACZ,LOCAL_PRO1BOOK_1_0_SADJ	;REW
;MAIN_PRO10_0_1_2:
	LAC	MSG
	XORL	CMSG_KEY1S
	BS	ACZ,LOCAL_PRO1BOOK_1_0_SADJ	;FFW
;MAIN_PRO10_0_1_3:
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,LOCAL_PRO1BOOK_EXIT		;EXIT
;MAIN_PRO10_0_1_4:
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,LOCAL_PRO1BOOK_1_0_MENU	;MENU
;MAIN_PRO10_0_1_5:	
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PRO1BOOK_TMR
		
	RET
;---------------------------------------
LOCAL_PRO1BOOK_1_0_SADJ:
LOCAL_PRO1BOOK_0_SADJ:
	LAC	MSG_N
	BS	ACZ,LOCAL_PRO1BOOK_SADJ_SEARCH
;MAIN_PRO10_0_1_SADJ_EDIT:	
	LACK	0
	SAH	MSG_N

	BS	B1,LOCAL_PRO1BOOK_SADJ_END
LOCAL_PRO1BOOK_SADJ_SEARCH:
	LACK	1
	SAH	MSG_N
LOCAL_PRO1BOOK_SADJ_END:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9E
	CALL	SEND_DAT
	LAC	MSG_N
	ANDK	1		;0 or 1
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	RET

;---------------------------------------
LOCAL_PRO1BOOK_1_0_MENU:

	LAC	MSG_N
	BS	ACZ,LOCAL_PRO1BOOK_1_0_EDIT
	;BS	B1,LOCAL_PRO1BOOK_1_0_SEARCH

LOCAL_PRO1BOOK_1_0_SEARCH:		;从号码条目序号最小的开始(翻查)
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
	
	CALL	GET_TELT
	SAH	MSG_T

	LAC	MSG_T
	BS	ACZ,LOCAL_PRO1BOOK_WORN
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XD1		;lookup phonebook
	CALL	SEND_DAT
	LACK	0		;All list first
	SAH	MSG_N
	CALL	SEND_DAT	;Select pbook-list(normal/VIP/Filter/All)
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	0X11
	SAH	PRO_VAR		;Goto select normal/VIP/Filter
	
	RET
;---------------------------------------
LOCAL_PRO1BOOK_1_0_EDIT:			;新增条目

	CALL	GET_TELT
	SBHK	99
	BZ	SGN,LOCAL_PRO1BOOK_WORN	;条目数达到99以上,不能再增加
.if	0
.else
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
;---
	CALL	CLR_FUNC	;先空
     	LACK	0
     	SAH	PRO_VAR
     	LACL	CNUMB_BADD
     	CALL	STOR_MSG
.endif
	RET
;---------------------------------------
LOCAL_PRO1BOOK_WORN:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK	
	CALL	BBBEEP

	RET
;---------------------------------------
LOCAL_PRO1BOOK_EXIT:

	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BBEEP
	
	CALL	CLR_FUNC
	LACK	0
	SAH	PRO_VAR1
	SAH	PRO_VAR
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9E		;exit COMMAND
	CALL	SEND_DAT
	LACK	6
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	RET
;-------------------------------------------------------------------------------
LOCAL_PRO1BOOK_1_1:		;选择查找的类型(0/1/2 = all/VIP/Filter)
	LAC	MSG
	XORL	CMSG_KEY2S
	BS	ACZ,LOCAL_PRO1BOOK_1_1_REW	;REW
;LOCAL_PRO1BOOK_1_1_2:
	LAC	MSG
	XORL	CMSG_KEY1S
	BS	ACZ,LOCAL_PRO1BOOK_1_1_FFW	;FFW
;LOCAL_PRO1BOOK_1_1_3:
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,LOCAL_PRO1BOOK_2_END	;EXIT
;LOCAL_PRO1BOOK_1_1_4:
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,LOCAL_PRO1BOOK_1_1_MENU	;MENU
;LOCAL_PRO1BOOK_1_1_5:	
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PRO1BOOK_TMR
		
	RET
;---------------------------------------
LOCAL_PRO1BOOK_1_1_REW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
LOCAL_PRO1BOOK_1_1_PREW:	
	LACK	0
	SAH	SYSTMP1
	LACK	2
	SAH	SYSTMP2
	
	LAC	MSG_N
	CALL	VALUE_SUB
	SAH	MSG_N
LOCAL_PRO1BOOK_1_1_REWFFW:
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XD1		;lookup phonebook type
	CALL	SEND_DAT
	LAC	MSG_N
	CALL	SEND_DAT
	LACL	0X0FF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
	RET
;---------------------------------------
LOCAL_PRO1BOOK_1_1_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
LOCAL_PRO1BOOK_1_1_PFFW:
	LACK	0
	SAH	SYSTMP1
	LACK	2
	SAH	SYSTMP2
	
	LAC	MSG_N
	CALL	VALUE_ADD
	SAH	MSG_N
	BS	B1,LOCAL_PRO1BOOK_1_1_REWFFW
;---------------------------------------
LOCAL_PRO1BOOK_1_1_MENU:
	CALL	GET_TELT
	SAH	MSG_T
	LACK	0
	SAH	MSG_ID
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X84
	CALL	SEND_DAT
	LAC	MSG_T
	CALL	SEND_DAT	;MSG_T条号码
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LAC	MSG_T
	BS	ACZ,LOCAL_PRO1BOOK_WORN

	LAC	VOP_FG
	ANDL	0XCFFF
	SAH	VOP_FG
	
	LAC	MSG_N
	SFL	12
	ANDL	0X3000
	SAH	SYSTMP0
	
	LAC	VOP_FG
	OR	SYSTMP0
	SAH	VOP_FG

	LACK	0X02
	SAH	PRO_VAR		;Goto select normal/VIP/Filter

	LACL	CMSG_KEY1S
	CALL	STOR_MSG
	
	RET
;-------------------------------------------------------------------------
LOCAL_PRO1BOOK_2:			;翻查电话本
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PRO1BOOK_TMR
;LOCAL_PROBOOK1_2_0_2:	
	LAC	MSG
	XORL	CMSG_KEY2S
	BS	ACZ,LOCAL_PRO1BOOK_2_REW	;REW(last one)
;LOCAL_PROBOOK1_2_0_3:
	LAC	MSG
	XORL	CMSG_KEY1S
	BS	ACZ,LOCAL_PRO1BOOK_2_FFW	;FFW(next one)
;LOCAL_PROBOOK1_2_0_4:
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,LOCAL_PRO1BOOK_2_END	;EXIT(exit to serach/add)
;LOCAL_PROBOOK1_2_0_5:
	LAC	MSG
	XORL	CMSG_KEY3S
	BS	ACZ,LOCAL_PRO1BOOK_2_TIME	;TIME(Goto edit)
;LOCAL_PROBOOK1_2_0_6:
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,LOCAL_PRO1BOOK_2_ERASE	;ERASE
;LOCAL_PROBOOK1_2_0_7:	
	LAC	MSG
	XORL	CMSG_KEY2P
	BS	ACZ,LOCAL_PRO1BOOK_2_PREW	;REW
;LOCAL_PROBOOK1_2_0_8:	
	LAC	MSG
	XORL	CMSG_KEY1P
	BS	ACZ,LOCAL_PRO1BOOK_2_PFFW	;FFW
;LOCAL_PROBOOK1_2_0_9:
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,LOCAL_PRO1BOOK_2_MENU	;MENU(回拔)

	RET
;---------------------------------------
LOCAL_PRO1BOOK_2_MENU:
	LAC	MSG_ID
	BS	ACZ,LOCAL_PRO1BOOK_2_WARNVP	;条目号为零,不能回拔
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
	
	LACK	0X03
	SAH	PRO_VAR
	
	LACK	0
	SAH	PRO_VAR1	;重新开始计时,用作回拔命令区分
	LACL	1000
	CALL	SET_TIMER

	RET
;---------------------------------------	
LOCAL_PRO1BOOK_2_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
LOCAL_PRO1BOOK_2_PFFW:
	LACK	0
	SAH	SYSTMP1
	LAC	MSG_T
	SAH	SYSTMP2

	LAC	MSG_ID
	CALL	VALUE_ADD
	SAH	MSG_ID
	
	LAC	MSG_ID
	BS	ACZ,LOCAL_PRO1BOOK_2_ENDLIST	;翻查到第0条
;---查类型是否符合
	LAC	VOP_FG
	SFR	12
	ANDK	0X03
	SAH	SYSTMP0
	BS	ACZ,LOCAL_PRO1BOOK_2_PFFW_1	;Lookup all list ?
;---Get the type of the current TEL
	LAC	MSG_ID
	ORL	0XEA00
	CALL	DAM_BIOSFUNC
	ANDL	0XFF03
	XOR	SYSTMP0
	BZ	ACZ,LOCAL_PRO1BOOK_2_PFFW	;类型不符找下一条
LOCAL_PRO1BOOK_2_PFFW_1:
;---找到相应类型的号码 
	BS	B1,LOCAL_PRO1BOOK_2_REWFFWEXE
;---------------------------------------
LOCAL_PRO1BOOK_2_REW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
LOCAL_PRO1BOOK_2_PREW:
	LACK	0
	SAH	SYSTMP1
	LAC	MSG_T
	SAH	SYSTMP2

	LAC	MSG_ID
	CALL	VALUE_SUB
	SAH	MSG_ID
	
	LAC	MSG_ID
	BS	ACZ,LOCAL_PRO1BOOK_2_ENDLIST	;翻查到第0条
;---查类型是否符合	
	LAC	VOP_FG
	SFR	12
	ANDK	0X03
	SAH	SYSTMP0
	BS	ACZ,LOCAL_PROBOOK1_2_PREW_1	;Lookup all list ?
;---Get the type of the current TEL	
	LAC	MSG_ID
	ORL	0XEA00
	CALL	DAM_BIOSFUNC
	ANDL	0XFF03
	XOR	SYSTMP0
	BZ	ACZ,LOCAL_PRO1BOOK_2_PREW	;类型不符找下一条
LOCAL_PROBOOK1_2_PREW_1:
;---找到相应类型的号码 	
LOCAL_PRO1BOOK_2_REWFFWEXE:
	LACL	0X02
	SAH	PRO_VAR		;
	
	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER	;
;---Set Pbook-group
	LACK	CGROUP_PBOOK
	CALL	SET_TELGROUP
;---读出下一串(MSG_ID)号码条目
	LACL	TEL_RAM	;(TEL_RAM..)
	SAH	ADDR_D		;基地址(base)
	LACK	0
	SAH	OFFSET_D	;偏移地址(offset)

	LAC	MSG_ID		;条目号
	CALL	READ_TELNUM	;读当前条目数据
	CALL	STOPREADDAT
;---发号码/姓名/时间(如果有)
	LACL	TEL_RAM		;(TEL_RAM..)
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	CALL	TEL_SENDCOMM
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9F
	CALL	SEND_DAT
	LAC	MSG_ID
	CALL	SEND_DAT	;显示号码
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	RET
;---------------------------------------
LOCAL_PRO1BOOK_2_ENDLIST:		;第0条
	LAC	MSG_T
	BS	ACZ,LOCAL_PRO1BOOK_2_NOLIST	;总条目数为0
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X84
	CALL	SEND_DAT
	LAC	MSG_T
	CALL	SEND_DAT	;MSG_T条号码(电话本同步)
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9F
	CALL	SEND_DAT
	LACK	0		;End of list/empty
	CALL	SEND_DAT
	LACL	0X0FF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	RET
LOCAL_PRO1BOOK_2_NOLIST:	;no list(在翻查/编辑号码时退出.翻查过程中删除到没有了,才会执行到此)
.if	1
	LACK	0X02
	SAH	PRO_VAR		;电话本状态
	LACL	CMSG_KEY7S
	CALL	STOR_MSG

	RET
.else
	BS	B1,LOCAL_PRO1BOOK_2_END
.endif
;---------------------------------------
LOCAL_PRO1BOOK_2_END:		;no save exit
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
	
	LACL	0X01
	SAH	PRO_VAR		;电话本状态
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	LACL	0X9E
	CALL	SEND_DAT
	LACK	0
	SAH	MSG_N
	CALL	SEND_DAT
	LACL	0X0FF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	RET
;---------------------------------------
LOCAL_PRO1BOOK_2_TIME:		;翻查电话本时进入编辑状态
	LAC	MSG_ID
	BS	ACZ,LOCAL_PRO1BOOK_2_WARNVP	;编辑第0条报警
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
;---
	CALL	CLR_FUNC	;先空
     	LACK	0
     	SAH	PRO_VAR
     	LACL	CNUMB_EDIT
     	CALL	STOR_MSG	
	
	RET
;---------------------------------------
LOCAL_PRO1BOOK_2_WARNVP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BBBEEP
	
	RET
;---------------------------------------
LOCAL_PRO1BOOK_2_ERASE:	
	LAC	MSG_ID
	BS	ACZ,LOCAL_PRO1BOOK_2_WARNVP	;删除第0条报警
;---正式删除后进入前一条,不用此处BEEP
LOCAL_PRO1BOOK_2_ERASE_EXE:
;---删除本号码条目(MSG_ID)
	LAC	MSG_ID
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK
	CALL	GC_CHK

	CALL	GET_TELT
	SBH	MSG_T
	BS	ACZ,LOCAL_PRO1BOOK_2_ERASE_EXE	;删除不成功，重来一次

	CALL	GET_TELT
	SAH	MSG_T

	;LACK	0
	;SAH	MSG_ID
	;LACL	0X10A
	;CALL	PRO_VAR
;!!!!!!!!!!!!!!!
	LACL	0XCC
	CALL	SEND_DAT
	LACK	1
	CALL	SEND_DAT	;第(MSG_ID)条号码
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!
	LAC	MSG_ID
	SBHK	1
	SAH	MSG_ID		;准备显示下一条;先准备条目号
	
	BS	B1,LOCAL_PRO1BOOK_2_FFW

;-------------------------------------------------------------------------------
LOCAL_PRO1BOOK_3:
	LAC	PRO_VAR
	SFR	4
	ANDK	0XF
	BS	ACZ,LOCAL_PRO1BOOK_3_0	;等待(拔号方式)
	SBHK	1
	BS	ACZ,LOCAL_PRO1BOOK_3_1	;正式拔号
	
	RET
;---------------------------------------
LOCAL_PRO1BOOK_3_0:
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,LOCAL_PRO1BOOK_3_0_MENU	;MENU
;LOCAL_PRO1BOOK_3_0_1:
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PRO1BOOK_3_0_TMR	;TMR
	
	RET
;---------------------------------------
LOCAL_PRO1BOOK_3_0_MENU:	;加0拔号
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP

	LACK	0X13
	SAH	PRO_VAR
	
	CALL	HOOK_ON
;!!!!!!!!!!!!!!! !!!!!!!!!!!!!  	
     	LACL	0XD0		;告诉MCU摘机了
	CALL	SEND_DAT
	LACK	0
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!		
	LACL	0X9E		;告诉MCU拔号
	CALL	SEND_DAT
	LACK	4
	CALL	SEND_DAT
	LACL	0xFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	;LACL	1000
	;CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1
	
	RET
;---------------------------------------
LOCAL_PRO1BOOK_3_0_TMR:		;拔号
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	2
	BS	SGN,LOCAL_PRO1BOOK_3_0_TMR_END
	
	LACK	0X13
	SAH	PRO_VAR

	LACK	0
	SAH	PRO_VAR1
	CALL	HOOK_ON
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
     	LACL	0XD0		;告诉MCU摘机了
	CALL	SEND_DAT
	LACK	0
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	LACL	0X9E		;告诉MCU拔号
	CALL	SEND_DAT
	LACK	3
	CALL	SEND_DAT
	LACL	0xFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
LOCAL_PRO1BOOK_3_0_TMR_END:

	RET
;-------------------------------------------------------------------------------
LOCAL_PRO1BOOK_3_1:
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PRO1BOOK_3_1_TMR	;TMR
	
	RET
;---------------------------------------
LOCAL_PRO1BOOK_3_1_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	8
	BS	SGN,LOCAL_PRO1BOOK_3_0_TMR_END	;发出拔号命令后8sec退出

	CALL	CLR_FUNC
	LACK	0
	SAH	PRO_VAR
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XD0		;告诉MCU挂机了
	CALL	SEND_DAT
	LACK	1
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!		
	LACL	0X9E
	CALL	SEND_DAT
	LACK	6
	CALL	SEND_DAT
	LACL	0xFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	CALL	HOOK_OFF

	RET
;-------------------------------------------------------------------------------
LOCAL_PRO1BOOK_4:	;(1/2/3 = VIP/Filter/Normal)
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PRO1BOOK_TMR
;LOCAL_PROBOOK1_4_0_2:	
	LAC	MSG
	XORL	CMSG_KEY2S
	BS	ACZ,LOCAL_PRO1BOOK_4_REW	;REW(last one)
;LOCAL_PROBOOK1_4_0_3:
	LAC	MSG
	XORL	CMSG_KEY1S
	BS	ACZ,LOCAL_PRO1BOOK_4_FFW	;FFW(next one)
;LOCAL_PROBOOK1_4_0_4:
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,LOCAL_PRO1BOOK_4_END	;EXIT(exit to serach/add)
;LOCAL_PROBOOK1_4_0_5:
	LAC	MSG
	XORL	CMSG_KEY2P
	BS	ACZ,LOCAL_PRO1BOOK_4_PREW	;REW
;LOCAL_PROBOOK1_4_0_8:	
	LAC	MSG
	XORL	CMSG_KEY1P
	BS	ACZ,LOCAL_PRO1BOOK_4_PFFW	;FFW
;LOCAL_PROBOOK1_4_0_9:
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,LOCAL_PRO1BOOK_4_MENU	;MENU(comform)

	RET
;---------------------------------------
LOCAL_PRO1BOOK_4_REW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
LOCAL_PRO1BOOK_4_PREW:	
	LACK	1
	SAH	SYSTMP1
	LACK	3
	SAH	SYSTMP2
	
	LAC	MSG_N
	CALL	VALUE_SUB
	SAH	MSG_N
LOCAL_PRO1BOOK_4_REWFFW:
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XD2
	CALL	SEND_DAT
	LAC	MSG_N
	CALL	SEND_DAT
	LACL	0X0FF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
	RET
;---------------------------------------
LOCAL_PRO1BOOK_4_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
LOCAL_PRO1BOOK_4_PFFW:
	LACK	1
	SAH	SYSTMP1
	LACK	3
	SAH	SYSTMP2
	
	LAC	MSG_N
	CALL	VALUE_ADD
	SAH	MSG_N
	BS	B1,LOCAL_PRO1BOOK_4_REWFFW
;---------------------------------------
LOCAL_PRO1BOOK_4_END:
	LACK	0
	SAH	MSG_N	;Normal
;---------------------------------------
LOCAL_PRO1BOOK_4_MENU:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
;---set pbook-group
	LACK	CGROUP_PBOOK
	CALL	SET_TELGROUP
;---get total number of pbook
	CALL	GET_TELT
	SAH	MSG_T		;Get the number of total message
;---get the index-0 of TEL-message,clear the type value and save
	LAC	MSG_T
	ORL	0XEA00
	CALL	DAM_BIOSFUNC
	ANDK	0X7C
	OR	MSG_N
	SAH	MSG_N
;---Set the index-0
	LAC	MSG_N
	SFL	8
	ANDL	0XFF00
	OR	MSG_T
	CALL	SET_TEL0ID	;
;?????????????????????????????
TTT:
;	BS	B1,TTT
;?????????????????????????????
.if	0
	LACL	CBOOK_SLET
	CALL	STOR_MSG
	
	LACK	0
	SAH	PRO_VAR
.else
	BS	B1,MAIN_PRO0_PHONEBOOK_SLCT
.endif	
	RET
;-------------------------------------------------------------------------------
.INCLUDE l_tel.asm
;-------------------------------------------------------------------------------	
.END

