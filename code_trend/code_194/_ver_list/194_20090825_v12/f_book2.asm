.NOLIST
;*******************************************************************************
;*This section use to add tel-data(number and name)
;*
;*The program can go to here by the reason as bellow:
;*
;*Add telephone-number,respone "CNUMB_BADD"
;*--------------------------------------
;*The program can exit by the reason as bellow:
;*
;*Exit-KEY detected then exit with "CBOOK_SLET"
;*or
;*Menu-KEY detected when edit name then exit with "CSTOR_TYPE"
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
.GLOBAL	LOCAL_PROBOOK2
;-------------------------------------------------------------------------------
.LIST
.ORG    ADDR_SECOND
;-------------------------------------------------------------------------------
;	Add TEL
;	NOTE : MSG_ID/MSG_T/MSG_N = current_TEL_ID/the total number of tel/the order of current tel
;-------------------------------------------------------------------------------
LOCAL_PROBOOK2:
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,MAIN_PROX_RINGIN
	LAC	MSG
	XORL	CVP_STOP		;PLAY END
	BS	ACZ,MAIN_PRO10_VPSTOP
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PROBOOK2_TMR
;---
	LAC	MSG
	XORL	CNUMB_BADD	;phone-book Add(add phone-number from empty TEL)
	BS	ACZ,LOCAL_PROBOOK2_NUMBADD
	;LAC	MSG
	;XORL	CNAME_ACID
	;BS	ACZ,LOCAL_PROBOOK2_CIDNAME
;---	
	LAC	PRO_VAR
	ANDK	0X0F
	BS	ACZ,LOCAL_PROBOOK2_0	;(0xyyy0)local-idle to display
	SBHK	1
	BS	ACZ,LOCAL_PROBOOK2_1	;(0xyyy1)TEL-number
	SBHK	1
	BS	ACZ,LOCAL_PROBOOK2_2	;(0xyyy2)TEL-name
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROBOOK2_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	30
	BZ	SGN,LOCAL_PROBOOK2_EXIT		;无操作超时退出

	RET
;---------------
LOCAL_PROBOOK2_EXIT:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BBEEP

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LAC	VOP_FG
	ANDL	~(1<<15)
	SAH	VOP_FG
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
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
;---------------------------------------
MAIN_PRO10_VPSTOP:
	LACK	0
	SAH	PRO_VAR1		;计数器清零(按键松开后BEEP结束)	
	CALL	DAA_OFF
	
	RET
;---------------------------------------
LOCAL_PROBOOK2_CIDNAME:
.if	0
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
;---先将Name数据区置全0xFFFF
	LACL	TEL_RAM+12
	SAH	ADDR_D		;Base address
	LACK	0
	SAH	OFFSET_D	;offset
	LACK	40
	SAH	COUNT		;length
	LACL	0XFF		;data
	CALL	RAM_STOR	;增加时默认的号码无效(16位)
;---Read the TEL specific with MSG_ID from CID-Group
	LACK	CGROUP_CID
	CALL	SET_TELGROUP	;

	LACL	TEL_RAM
	SAH	ADDR_D		;Address-Base
	LACK	0
	SAH	OFFSET_D	;Address-Offset		;保存地址
	LAC	MSG_ID		;条目号
	CALL	READ_TELNUM	;读当前条目数据
	CALL	STOPREADDAT
;---Display the TEL and copy the TEL to the Edit-RAM
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.if	1
	LACL	0X9F
	CALL	SEND_DAT
	LAC	MSG_ID
	CALL	SEND_DAT	;显示号码(在此只为将CID复制到编辑区,显示功能是次要的)
	LACL	0XFF
	CALL	SEND_DAT
.endif
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
;---Goto PhoneBook-Group	
	LACK	CGROUP_PBOOK
	CALL	SET_TELGROUP	;
;---Get TEL-flag	
	LACL	TEL_RAM
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	CALL	GETBYTE_DAT	;Get flag-num
	SAH	FILE_LEN
	CALL	GETBYTE_DAT	;Get flag-name
	SFL	8
	ANDL	0XFF00
	OR	FILE_LEN
	SAH	FILE_LEN	;先保存flag信息(Number/Name)
;---Move TEL-name data
	LAC	FILE_LEN
	ANDK	0X7F
	ADHK	1
	SFR	2		;号码压缩后的长度
	ADHK	2		;头部Flag(4bytes)
	ADHL	TEL_RAM
	SAH	ADDR_S		;存储姓名的开始基地址
	LACL	TEL_RAM+12
	SAH	ADDR_D		;转存姓名的目标基地址

	LAC	FILE_LEN
	ANDK	0X7F
	ADHK	1
	SFR	1
	ANDK	0X1
	SAH	OFFSET_S	;当号码的长度为4*L+1或4*L+2时
	
	LACK	0
	SAH	OFFSET_D

	BIT	FILE_LEN,15	;查有效位,如果没有姓名就不移动
	BZ	TB,LOCAL_PROBOOK2_CIDNAME_0
	LAC	FILE_LEN
	SFR	8
	ANDK	0X1F
	ADHK	1	;多移一个BYTE
	SAH	COUNT		;要求移动的长度(BYTE)
	CALL	MOVE_LTOH	;将姓名移动
LOCAL_PROBOOK2_CIDNAME_0:
;---以0XFF结束(Number)
	LACL	TEL_RAM+2
	SAH	ADDR_D
	LAC	FILE_LEN	;以0XFF结束(Number)
	ANDK	0X1F
	ADHK	1
	SFR	1
	SAH	OFFSET_D
	LACL	0XFF
	CALL	STORBYTE_DAT
;---以0XFF结束(Name)
	LACL	TEL_RAM+12
	SAH	ADDR_D
	LAC	FILE_LEN	;以0XFF结束(Name)
	SFR	8
	ANDK	0X1F
	SAH	OFFSET_D

	BIT	FILE_LEN,15	;查有效位,如果没有姓名就将初始位设为0XFF
	BS	TB,LOCAL_PROBOOK2_CIDNAME_1
	
	LACK	0		
	SAH	OFFSET_D
LOCAL_PROBOOK2_CIDNAME_1:
	LACL	0XFF
	CALL	STORBYTE_DAT
;---Get the data beening edit---------------------
	LACL	TEL_RAM+12
	SAH	ADDR_S		;BASE address
	BIT	FILE_LEN,15	;查有效位,没有姓名,就置姓名位,姓名长度清零
	BS	TB,LOCAL_PROBOOK2_CIDNAME_2
	LAC	FILE_LEN
	ANDL	0X00FF
	ORL	1<<15
	SAH	FILE_LEN
LOCAL_PROBOOK2_CIDNAME_2:
	LAC	FILE_LEN
	SFR	8
	ANDK	0X1F
	BS	ACZ,LOCAL_PROBOOK2_CIDNAME_3	;若没有姓名(长度为0),不用减1
	SBHK	1	;将长度转而换成姓名的最后一个字符的偏移
LOCAL_PROBOOK2_CIDNAME_3:
	ORL	0XB0	;!!!
	SAH	NEW_ID		;offset
	ANDK	0X0F
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	SAH	MSG_N

	LACK	0X02
	SAH	PRO_VAR		;开始编辑姓名
;---
	LAC	NEW_ID
	CALL	SEND_DAT	;第(NEW_ID)位
	LAC	MSG_N
	CALL	SEND_DAT	;值
	LACL	0XFF
	CALL	SEND_DAT	;指令结束
	;call	TEST_VOP	;???????????????????????????????????????????????
.endif	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROBOOK2_0:
	
	RET
;---------------------------------------
LOCAL_PROBOOK2_NUMBADD:

	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
	
	LACK	0X0001
	SAH	FILE_LEN	;添加电话本对应"号码(7..0)+姓名(15..8)"信息
				;添加电话本没有时间和OGM_ID,保存时直接为零可不予理会
;---先将数据区置全0xFFFF
	LACL	TEL_RAM
	SAH	ADDR_D		;Base address
	LACK	0
	SAH	OFFSET_D	;offset
	LACK	64
	SAH	COUNT		;length
	LACL	0XFF		;data
	CALL	RAM_STOR	;增加时默认的号码无效(16位)

	LACL	0XA0
	SAH	NEW_ID
	LACK	0X0F
	SAH	MSG_N

	LACK	0X01
	SAH	PRO_VAR		;进入增加状态
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LAC	NEW_ID		;SEND COMMAND 
	CALL	SEND_DAT
	LAC	MSG_N
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	RET
;-------------------------------------------------------------------------
LOCAL_PROBOOK2_1:		;Tel-Number

;MAIN_PRO10_2_0_0_1:
	LAC	MSG
	XORL	CMSG_KEY2S
	BS	ACZ,MAIN_PRO10_2_0_0_REW	;REW
;MAIN_PRO10_2_0_0_2:
	LAC	MSG
	XORL	CMSG_KEY1S
	BS	ACZ,MAIN_PRO10_2_0_0_FFW	;FFW
;MAIN_PRO10_2_0_0_3:
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,MAIN_PRO10_X_END	;EXIT no save
;MAIN_PRO10_2_0_0_4:
	;LAC	MSG
	;XORL	CMSG_TMR
	;BS	ACZ,LOCAL_PROBOOK2_TMR	;TMR
;MAIN_PRO10_2_0_0_5:
	LAC	MSG
	XORL	CMSG_KEY4S
	BS	ACZ,MAIN_PRO10_2_0_0_TIME	;PLAY
;MAIN_PRO10_2_0_0_6:
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO10_2_0_0_MENU	;MENU
;MAIN_PRO10_2_0_0_7:
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,MAIN_PRO10_2_0_0_ERASE 	;ERASE
;MAIN_PRO10_2_0_0_8:	
	LAC	MSG
	XORL	CMSG_KEY2P
	BS	ACZ,MAIN_PRO10_2_0_0_PREW	;REW
;MAIN_PRO10_2_0_0_9:
	LAC	MSG
	XORL	CMSG_KEY1P
	BS	ACZ,MAIN_PRO10_2_0_0_PFFW	;FFW

	RET
;---------------------------------------
MAIN_PRO10_2_0_0_REW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
MAIN_PRO10_2_0_0_PREW:
	LACK	0
	SAH	SYSTMP1
	LACK	9
	SAH	SYSTMP2
	
	LAC	MSG_N
	CALL	VALUE_ADD
	SAH	MSG_N
	
	BS	B1,MAIN_PRO10_X_SENDCOMM
;---------------------------------------
MAIN_PRO10_2_0_0_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
MAIN_PRO10_2_0_0_PFFW:	
	LACK	0
	SAH	SYSTMP1
	LACK	9
	SAH	SYSTMP2
	
	LAC	MSG_N
	CALL	VALUE_SUB
	SAH	MSG_N
	;BS	B1,MAIN_PRO10_X_SENDCOMM
MAIN_PRO10_X_SENDCOMM:
	LAC	NEW_ID
	CALL	SEND_DAT	;第(NEW_ID)位
	LAC	MSG_N
	CALL	SEND_DAT	;值
	LACL	0XFF
	CALL	SEND_DAT	;指令结束
	
	RET
;---------------------------------------			
MAIN_PRO10_2_0_0_TIME:		;调整下一位
	LAC	MSG_N		;如果当前值是无效数字(大于10 or 小于0)则不能进入到下一位调整
	BS	SGN,MAIN_PRO10_2_X_TIMEEND
	SBHK	10
	BZ	SGN,MAIN_PRO10_2_X_TIMEEND
;---	
	LAC	NEW_ID
	XORL	0XAF
	BS	ACZ,MAIN_PRO10_2_0_0_MENU	;最后一位(可避免FILE_LEN的溢出错误)
;---保存当前值
	LACL	TEL_RAM+2	;BASE address
	SAH	ADDR_D
	LAC	NEW_ID		;offset
	ANDK	0X0F
	SAH	OFFSET_D
	LAC	MSG_N		;值
	CALL	STORBYTE_DAT
;---长度加1
	LAC	FILE_LEN
	ADHK	0X0001
	ANDK	0X001F
	SAH	FILE_LEN	;号码位数加1(可用当前NEW_ID代替)
;---取下一个	
	LACL	0XA0
	SAH	SYSTMP1
	LACL	0XAF
	SAH	SYSTMP2
	LAC	NEW_ID
	CALL	VALUE_ADD
	SAH	NEW_ID		;get next command
;---取下一个的值
	LACL	TEL_RAM+2	;BASE address
	SAH	ADDR_S
	LAC	NEW_ID		;offset
	ANDK	0X0F
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	ANDK	0X7F
	SAH	MSG_N
MAIN_PRO10_2_0_TIME_END:
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
	
	BS	B1,MAIN_PRO10_X_SENDCOMM
;---------------------------------------
MAIN_PRO10_2_X_TIMEEND:		;非法数据
LOCAL_PROBOOK2_WORN:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BBBEEP		;BBB

	RET

;---------------------------------------
LOCAL_PROBOOK2_1_MENUEND:	;Press "Menu" when Edit TEL-Number ;but the length of Number is 0
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BBBEEP		;BBB

	LACK	1		
	SAH	FILE_LEN	;重置号码长度1

	RET
;---------------------------------------
LOCAL_PROBOOK2_2_MENUEND:	;Press "Menu" when Edit TEL-Name ;but the length of Name is 0
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BBBEEP		;BBB

	LAC	FILE_LEN
	ANDK	0X003F
	ORL	0X0100
	SAH	FILE_LEN	;重置姓名长度1

	RET
;---------------------------------------
MAIN_PRO10_2_0_0_MENU:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
;---保存当前值
	LACL	TEL_RAM+2	;BASE address
	SAH	ADDR_D
	LAC	NEW_ID		;偏移
	ANDK	0X0F
	SAH	OFFSET_D
	LAC	MSG_N		;值
	CALL	STORBYTE_DAT

	LAC	MSG_N		;如果当前值是无效数字(大于10 or 小于0)则长度减1
	BS	SGN,MAIN_PRO10_2_0_0_MENU_0
	SBHK	10
	BZ	SGN,MAIN_PRO10_2_0_0_MENU_0
	BS	B1,MAIN_PRO10_2_0_0_MENU_0_1	;有效字符
MAIN_PRO10_2_0_0_MENU_0:
	LAC	FILE_LEN
	SBHK	1
	SAH	FILE_LEN
	ANDK	0X1F
	BS	ACZ,LOCAL_PROBOOK2_1_MENUEND	;号码长度为0,不能进入姓名编辑
MAIN_PRO10_2_0_0_MENU_0_1:
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;---将号码就地压缩
	LACL	TEL_RAM+2
	SAH	ADDR_S
	SAH	ADDR_D
	LACK	0
	SAH	OFFSET_S
	SAH	OFFSET_D
	LAC	FILE_LEN
	ANDK	0X7F
	SAH	COUNT
	CALL	CONCEN_DAT
MAIN_PRO10_2_0_0_MENU_1:	;号码处理完毕,开始姓名的处理
	LAC	FILE_LEN
	ORL	0X0100
	SAH	FILE_LEN
	SAH	NEW_ID		;
;---开始比较Tel-num
	LACL	TEL_RAM
	SAH	ADDR_S
	SAH	ADDR_D

	CALL	COMP_ALLTELNUM
	BS	ACZ,MAIN_PRO10_2_0_MENU_1
	SAH	MSG_ID
;---比较==>由添加到编辑
;---找到有相同号码的条目,将进入编辑电话本的姓名修改字段	
	CALL	CLR_FUNC
	LACL	0X0
	SAH	PRO_VAR
	LACL	CNAME_EDIT	;
	CALL	STOR_MSG

	RET
;读出---发送---传为编辑姓名状态
MAIN_PRO10_2_0_MENU_1:
	LACL	0XB0
	SAH	NEW_ID
	LACK	0X7F
	SAH	MSG_N		;current value

	LACK	0X02
	SAH	PRO_VAR		;进入编辑姓名
	BS	B1,MAIN_PRO10_X_SENDCOMM
;---------------------------------------
MAIN_PRO10_2_0_0_ERASE:
	LAC	NEW_ID
	SBHL	0XA0
	BZ	ACZ,MAIN_PRO10_2_0_0_ERASE2
;---第一个
	LAC	MSG_N		;无效数字(大于10 or 小于0)则不能进入到下一位调整
	BS	SGN,MAIN_PRO10_2_0_0_ERASE1
	SBHK	10
	BZ	SGN,MAIN_PRO10_2_0_0_ERASE1
;---删除第一个有效字符
	LACK	0XF
	SAH	MSG_N
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
	BS	B1,MAIN_PRO10_X_SENDCOMM
MAIN_PRO10_2_0_0_ERASE1:
;---删除第一个无效字符
	LACK	0XF
	SAH	MSG_N
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BBBEEP
	BS	B1,MAIN_PRO10_X_SENDCOMM
MAIN_PRO10_2_0_0_ERASE2:	;不是第一位时
;---保存当前值0X0F
	LACL	TEL_RAM+2	;BASE address
	SAH	ADDR_D
	LAC	NEW_ID		;偏移
	ANDK	0X0F
	SAH	OFFSET_D
	LACK	0X0F		;值
	CALL	STORBYTE_DAT
;---取上一个
	LAC	FILE_LEN
	SBHK	0X01
	SAH	FILE_LEN
	
	LACL	0XA0
	SAH	SYSTMP1
	LACL	0XAF
	SAH	SYSTMP2
	LAC	NEW_ID
	CALL	VALUE_SUB
	SAH	NEW_ID		;get next command

	LACL	TEL_RAM+2	;BASE address
	SAH	ADDR_S
	LAC	NEW_ID		;offset
	ANDK	0X0F
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	ANDK	0X7F
	SAH	MSG_N
MAIN_PRO10_2_X_ERASE_SENDCOMM:	;删除操作之后马上显示下一位
	LAC	NEW_ID
	CALL	SEND_DAT	;第(NEW_ID)位
	LACL	0X80
	CALL	SEND_DAT	;值0X80
	LACL	0XFF
	CALL	SEND_DAT
	
	LAC	NEW_ID
	CALL	SEND_DAT	;第(NEW_ID)位
	LAC	MSG_N
	CALL	SEND_DAT	;值0X80
	LACL	0XFF
	CALL	SEND_DAT
;---BEEP
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP

	RET
MAIN_PRO10_2_0_1_SENDCOMM_DISP:
	LACL	0X9F
	CALL	SEND_DAT
	LAC	MSG_ID
	CALL	SEND_DAT	;显示号码
	LACL	0XFF
	CALL	SEND_DAT

	RET

;---------------------------------------------------------------------
LOCAL_PROBOOK2_2:		;Tel-Name
;MAIN_PRO10_2_1_1:
	;LAC	MSG
	;XORL	CVP_STOP		;PLAY END
	;BS	ACZ,MAIN_PRO10_VPSTOP
;MAIN_PRO10_2_1_2:	
	LAC	MSG
	XORL	CMSG_KEY2S
	BS	ACZ,MAIN_PRO10_2_1_REW	;REW
;MAIN_PRO10_2_1_3:
	LAC	MSG
	XORL	CMSG_KEY1S
	BS	ACZ,MAIN_PRO10_2_1_FFW	;FFW
;MAIN_PRO10_2_1_4:
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,MAIN_PRO10_X_END	;EXIT no save
;MAIN_PRO10_2_1_5:
	;LAC	MSG
	;XORL	CMSG_TMR
	;BS	ACZ,LOCAL_PROBOOK2_TMR	;(已作起时响应处理)
;MAIN_PRO10_2_1_6:
	LAC	MSG
	XORL	CMSG_KEY4S
	BS	ACZ,MAIN_PRO10_2_1_TIME	;PLAY
;MAIN_PRO10_2_1_7:
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO10_2_1_MENU	;MENU
;MAIN_PRO10_2_1_8:
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,MAIN_PRO10_2_1_ERASE	;ERASE
;MAIN_PRO10_2_1_9:	
	LAC	MSG
	XORL	CMSG_KEY2P
	BS	ACZ,MAIN_PRO10_2_1_PREW	;REW
;MAIN_PRO10_2_1_10:
	LAC	MSG
	XORL	CMSG_KEY1P
	BS	ACZ,MAIN_PRO10_2_1_PFFW	;FFW

	RET
;---------------------------------------
MAIN_PRO10_2_1_ERASE:
	LAC	NEW_ID
	SBHL	0XB0
	BZ	ACZ,MAIN_PRO10_2_1_ERASE2
;---第一个
	LAC	MSG_N		;无效数字(大于0X25 or 小于0)则不能进入到下一位调整
	BS	SGN,MAIN_PRO10_2_1_ERASE1
	SBHK	0X25
	BZ	SGN,MAIN_PRO10_2_1_ERASE1
;---删除第一个有效字符	
	LACK	0X7F
	SAH	MSG_N
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
	
	BS	B1,MAIN_PRO10_X_SENDCOMM
MAIN_PRO10_2_1_ERASE1:	
;---删除第一个无效字符
	LACK	0X7F
	SAH	MSG_N
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BBBEEP
	
	BS	B1,MAIN_PRO10_X_SENDCOMM
MAIN_PRO10_2_1_ERASE2:
;---保存当前值0X7F
	LACL	TEL_RAM+12	;BASE address
	SAH	ADDR_D
	LAC	NEW_ID		;偏移
	ANDK	0X0F
	SAH	COUNT
	LACK	0X7F		;值
	CALL	STORBYTE_DAT
;---取上一个
	LAC	FILE_LEN
	SBHL	0X0100
	SAH	FILE_LEN

	LACL	0XB0
	SAH	SYSTMP1
	LACL	0XBF
	SAH	SYSTMP2
	LAC	NEW_ID
	CALL	VALUE_SUB
	SAH	NEW_ID		;get next command
	
	LACL	TEL_RAM+12	;BASE address
	SAH	ADDR_S		;BASE address
	LAC	NEW_ID		;offset
	ANDK	0X0F
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	ANDK	0X7F
	SAH	MSG_N

	BS	B1,MAIN_PRO10_2_X_ERASE_SENDCOMM

;---------------------------------------
MAIN_PRO10_2_1_REW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
MAIN_PRO10_2_1_PREW:
	LACK	0
	SAH	SYSTMP1
	LACK	0X24
	SAH	SYSTMP2
	
	LAC	MSG_N
	CALL	VALUE_ADD
	SAH	MSG_N
	
	BS	B1,MAIN_PRO10_X_SENDCOMM
;---------------------------------------
MAIN_PRO10_2_1_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
MAIN_PRO10_2_1_PFFW:	
	LACK	0
	SAH	SYSTMP1
	LACK	0X24
	SAH	SYSTMP2
	
	LAC	MSG_N
	CALL	VALUE_SUB
	SAH	MSG_N
	
	BS	B1,MAIN_PRO10_X_SENDCOMM
;---------------------------------------
MAIN_PRO10_2_1_TIME:
	LAC	MSG_N		;如果当前值是无效数字(大于0X25 or 小于0)则不能进入到下一位调整
	BS	SGN,MAIN_PRO10_2_X_TIMEEND
	SBHK	0X25
	BZ	SGN,MAIN_PRO10_2_X_TIMEEND
;-以下是有效字符(0..0X24)值	
	LAC	NEW_ID
	XORL	0XB0
	BZ	ACZ,MAIN_PRO10_2_1_TIME1	;不是第一位跳转
	
	LAC	MSG_N
	XORL	0X24
	BS	ACZ,MAIN_PRO10_2_X_TIMEEND	;第一位为空格
MAIN_PRO10_2_1_TIME1:	
	LAC	NEW_ID
	XORL	0XBF
	BS	ACZ,MAIN_PRO10_2_1_MENU		;是最后一位保存退出
MAIN_PRO10_2_1_TIME2:
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
;---保存当前值
	LACL	TEL_RAM+12	;BASE address
	SAH	ADDR_D
	LAC	NEW_ID		;偏移
	ANDK	0X0F
	SAH	OFFSET_D
	LAC	MSG_N		;值
	CALL	STORBYTE_DAT
;---取下一个
	LAC	FILE_LEN
	ADHL	0X0100
	ANDL	0X1FFF
	SAH	FILE_LEN		;应取NEW_ID的低4位最大值加1

	LACL	0XB0
	SAH	SYSTMP1
	LACL	0XBF
	SAH	SYSTMP2
	LAC	NEW_ID
	CALL	VALUE_ADD
	SAH	NEW_ID		;get next command

	LACL	TEL_RAM+12	;BASE address
	SAH	ADDR_S
	LAC	NEW_ID		;offset
	ANDK	0X0F
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	ANDK	0X7F
	SAH	MSG_N

	BS	B1,MAIN_PRO10_X_SENDCOMM
;---------------------------------------
MAIN_PRO10_2_1_MENU:		;保存号码/姓名(写入FLASH)
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;---保存当前值
	LACL	TEL_RAM+12	;BASE address
	SAH	ADDR_D
	LAC	NEW_ID		;偏移
	ANDK	0X0F
	SAH	OFFSET_D
	LAC	MSG_N		;值
	CALL	STORBYTE_DAT
	LACL	0XFF		;以0XFF结束
	CALL	STORBYTE_DAT
	
	LAC	MSG_N		;如果当前值是无效数字(大于0X24 or 小于0)则长度减1
	BS	SGN,MAIN_PRO10_2_1_MENU_0
	SBHK	0X24
	BZ	SGN,MAIN_PRO10_2_1_MENU_0
	BS	B1,MAIN_PRO10_2_1_MENU_0_1
MAIN_PRO10_2_1_MENU_0:	
	LAC	FILE_LEN
	SBHL	0X0100
	SAH	FILE_LEN
	ANDL	0X1F00
	BS	ACZ,LOCAL_PROBOOK2_2_MENUEND	;有效字符长度为0
MAIN_PRO10_2_1_MENU_0_1:
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;---Set TEL-Group then write into flash	
	LACK	CGROUP_PBOOK
	CALL	SET_TELGROUP
	
	CALL	GET_TELT
	SBHK	5
	BZ	SGN,LOCAL_PROBOOK2_WORN	;Over the MAX. number
;---Set default index-0 before write
	LACL	0XE700|0X7F
	CALL	DAM_BIOSFUNC
;---写入数据---(TEL flag)
	LAC	FILE_LEN
	ANDL	0XFF
	ORL	0X80
	CALL	DAT_WRITE
	LAC	FILE_LEN
	SFR	8
	ORL	0X80
	CALL	DAT_WRITE
	LACK	0
	CALL	DAT_WRITE
	LACK	0
	CALL	DAT_WRITE	;写入数据(TEL flag)
;---写入数据(TEL-number)
	LACL	TEL_RAM+2	;BASE address
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	CALL	TELNUM_WRITE	;
;---写入数据(TEL-name)	
	LACL	TEL_RAM+12
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	CALL	TELNUM_WRITE
;---写入数据(TEL-time)
	;CALL	TELTIME_WRITE
	
	CALL	DAT_WRITE_STOP
	
	;CALL	GET_TELT	;取TEL_ID
	;CALL	SET_TELUSRDAT	;置usr-dat
;---------------------------------------
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF	

	CALL	CLR_FUNC	;Clean function first   	
     	LACK	0
     	SAH	PRO_VAR

     	LACL	CSTOR_TYPE	;
     	CALL	STOR_MSG

	RET
;---------------------------------------
MAIN_PRO10_X_END:		;no/save exit(exit,return to Edit/Search status)
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF	

	CALL	CLR_FUNC	;Clean function first   	
     	LACK	0
     	SAH	PRO_VAR
     	
     	LACL	CBOOK_SLET
     	CALL	STOR_MSG

	RET
;-------------------------------------------------------------------------------
MAIN_PROX_RINGIN:
	CALL	INIT_DAM_FUNC
	LACK	0
	SAH	PRO_VAR

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LAC	VOP_FG
	ANDL	~(1<<15)
	SAH	VOP_FG
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	BLED_ON
	LACL	CMSG_INIT
	CALL	STOR_MSG
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9E
	CALL	SEND_DAT
	LACK	6
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!	

	RET
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------	
.END

