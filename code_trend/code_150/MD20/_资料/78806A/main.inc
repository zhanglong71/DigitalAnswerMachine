
/*****************寄存器定义*********************/

int_temp0	==	0x10
int_temp1	==	0x11
int_temp2	==	0x12
int_temp3	==	0x13
int_temp4	==	0x14
int_temp5	==	0x15
temp0		==	0x16
temp1		==	0x17
temp2		==	0x18
temp3		==	0x19
temp4		==	0x1a
TEMP5		==	0X1b
FSK_FG		==	0X1c
STAMP_FG	==	0X1d			; 印花标志寄存器
SYS_FG		==	0X1e
EVENT		==	0X1F

;BANK 0
BANK0_TEMP0	==	0X20
BANK0_TEMP1	==	0X21
BANK0_TEMP2	==	0X22
BANK0_TEMP3	==	0X23
YEAR_REG	==	0X24
MONTH_REG	==	0X25
DAY_REG		==	0X26
WEEK_REG	==	0X27
HOUR_REG	==	0X28
MIN_REG		==	0X29
SEC_REG		==	0X2A

TOTAL_CALL	==	0X2B
NEW_CALL	==	0X2C
TOTAL_MSG	==	0X2D
NEW_MSG		==	0X2E
TOTAL_BOOK	==	0X2F

;LCD_CONTRAST	==	0X30			; 低4位为对比度
;CODE1		==	0X30			; 高4位为密码1
;CODE23		==	0X31

LCALL12		==	0X30
LCALL34		==	0X31
LCALL5		==	0X32

TMR		==	0X34
TMR_DELAY	==	0X35
TMR_FLASH	==	0X36
TMR_SER		==	0X37
TMR_NAME	==	0X38
MENU_STATE	==	0X39

CONT		==	0X3A
STR_REG		==	0X3B
;SER_FLAG	==	0X3C
;SER_FLAG	==	0X3D
;SER_FLAG	==	0X3E
;SER_DATA	==	0X3F


;BANK 1
BANK1_TEMP0	==	0X20
BANK1_TEMP1	==	0X21
BANK1_TEMP2	==	0X22
BANK1_TEMP3	==	0X23
FSK_BYTE	==	0X24
FSK_SUM		==	0X25
FSK_LENGTH	==	0X26
FSK_COUNT	==	0X27
FSK_TMP		==	0X28
FSK_ADR		==	0X29
DTMF_ADR	==	0X2A

TIME_MS		==	0X2B
TIME_SEC	==	0X2C
TIME_MIN	==	0X2D
TIME_HOUR	==	0X2E
TMR_LINEDET	==	0X2F

TMR_PROTOCOL	==	0X30

R1_TEST_L111	==	0X31

R1_SYS_FG	==	0X32

R1_CD		==	0X33
R1_TMR_DTMF	==	0X34

R1_LCD_CONTRAST	==	0X35
R1_CODE1	==	0X35
R1_CODE23	==	0X36




/*****************常数定义***********************/

LCD_CTRL	==	128
VGA_ADDR	==	172

FSK_ADDR	==	0
DTMF_ADDR	==	0
CID_ADDR	==	60
EDIT_ADDR	==	94

DIAL_ADDR	==	132

TCP_ADDR	==	153

/*****************标志位定义*********************/

; SYS_FG
LANGUAGE	==	0			; 语言标志
NEWCALL		==	1			; 
STAMP		==	2			; 印花被改变
SYS_CLOCK	==	3			; 第一行数字被改变
LEEP_YEAR	==	4
LOCK_TOPLINE	==	5
LOCK_STR	==	6
TIME		==	7			; 计时

; R1_SYS_FG
TIMEFORMAT	==	0			; 时间制式
HOOKSTATUS	==	1			; hook状态


; EVENT
TEST		==	7
; STAMP_FG
;.0		REPEAT
;.1		NEW
;.2		battery
;.3		MEMO
;.4		second
;.5		/
;.6		spk
;.7		CALL
STAMP_REPEAT	==	0
STAMP_NEW	==	1
STAMP_BAT	==	2
STAMP_MEMO	==	3
STAMP_SEC	==	4
STAMP_SLASH	==	5
STAMP_SPK	==	6
STAMP_CALL	==	7

; FSK_FG
;TCC_400U	==	0
FSK_VALID	==	0
FSK_SUC		==	1			; FSK接收完毕
FSK_ERR		==	2			; FSK接收错误
DTMF_START	==	3
DTMF_SUC	==	4			; DTMF接收完毕
ERR_NUM		==	5			; 号码错误
ERR_NAME	==	6			; 姓名错误
CALLIN		==	7			; 有来电


/***************************************
CID BANK 规划

BANK0:
0~127	LCD RAM映射
LCD_CTRL == 128
0	显示控制
1	印花寄存器
2~11	第一行数字寄存器
12~27	第二行数字寄存器
28~43	第三行字符寄存器
VGA_ADDR == 172
0	印花控制器			; 暂时不用
1	显示数据印花缓冲器		; 不用
2	第一行控制器			; 不用
3~12	显示数据第一行数字缓冲器	; 不用
13	第二行控制器
14~45	显示数据第二行数字缓冲器	缓冲器大小设为32个，但显示前16个
46	第三行控制器
47~78	显示数据第三行字符缓冲器	缓冲器大小设为32个，但显示前16个
; ------------------------------------------------
BANK1:
FSK_ADDR == 0
0~59	FSK 接收数据区。（消息类型-消息长度-消息字/消息类型-消息长度-参数类型-参数长度-参数字）
DTMF_ADDR == 0
0~19	DTMF 接收数据区。

CID_ADDR == 60
从交换机接收到的信息解码之后得到的信息：
从93L111接收到的号码信息：
预发送给93L111的号码信息：
0	CID_CTRL
	.7	是否要屏蔽第一行
	.6~.5	显示模式
1	信息标志位
	.7	备用（0）
	.1	是否新来电
	.0	是否REPEAT
2	号码长度 1~16;0x00未解码/没有号码;0x43('C')投币电话呼叫;0x49('I')不带号码的国际呼叫;0x4F('O')不带号码;0x50('P')私密;0xFF解码错误;其它保留。
3~10	电话号码，一个字节存放两位，不够部分为F。
11	姓名长度 1~16;0x00未解码/没有号码;0x4F('O')不带姓名;0x50('P')私密;0xFF解码错误;其它保留。
12~27	姓名，不够部分为FF。
28	时间长度 4;0X00/0XFF没有时间信息。
29~32	时间信息（月日时分）
33	OGM号/序号。

COMMAND_ADDR == 94
0	控制器
1~20	提供20个接收处理命令区。

EDIT_ADDR == 94
编辑区
0	印花
1~5	第一行
6~21	第二行
22~37	第三行

DIAL_ADDR == 132
0	拨号控制器
.7	1
.6	0/1	START/CONTINUE
.5	0/1	PAUSE/DIAL
.4~.0	->
1~20	号码缓冲区

TCP_ADDR == 153
0	TCP控制器
.7	0

1~70
153由发送 和接收 共用缓冲区。

224~255	通讯使用
****************************************/
