
/*****************寄存器定义*********************/
intbuf_acc	==	0x10	;acc
intbuf_status	==	0x11	;r3(Status)
intbuf_rsr	==	0x12	;r4(RAM Select Register)
intbuf_ppsr	==	0x13	;r5(Program Page Select Register)

int_temp0	==	0x14
int_temp1	==	0x15

temp0		==	0x16
temp1		==	0x17
temp2		==	0x18
temp3		==	0x19

old_ram		==	0x1a

offset_s	==	0X1b
offset_d	==	0X1c
base_s		==	0X1d
base_d		==	0X1e                            
count		==	0X1f

temp4	==	0X1f	;???????????????????????????????????????????????????????
;-------------------------------------------------------------------------------
/*****************BANK 0 *********************/
msg_queue	==	0X20
msg_queue_start	==	0X21	;0x21..0x28
pro_stack	==	0X29	;0x2A..0x2D	;
msg		==	0X2E	;current system message
pro_var		==	0X2F	;for system status
pro_var1	==	0X30	;for timer counter
event		==	0X31	;action flag for system
tone_queue_head	==	0X32	;队列头指针
tone_queue_tail	==	0X33	;队列尾指针
LCD_CONTRAST	==	0X34	;

/*****************BANK 1 *********************/
intbuf_cidaddr	==	0x20
intbuf_cidbank	==	0x21

tmr_timer	==	0X20
tmr_timer_bak	==	0X21

SEC_REG		==	0X22
MIN_REG		==	0X23
HOUR_REG	==	0X24
DAY_REG		==	0X25
MON_REG		==	0X26
YEAR_REG	==	0X27
WEEK_REG	==	0X28

tmr_flash	==	0X29
tmr_tone	==	0X2A

/*****************BANK 2 *********************/

/*****************BANK 3 *********************/


/*****************常数定义***********************/
tone_queue_start	==	0
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
