

/************************寄存器定义*************************/
; 公共
int_acc		==	0x10
int_status	==	0x11
int_rsr		==	0x12

ax		==	0x13
exa		==	0x14
cnt		==	0x15
bx		==	0x16
exb		==	0x17

program		==	0x18

cursor		==	0x19
tmr_cursor	==	0x1a

sys_msg		==	0x1b
sys_data	==	0x1c
sys_flag	==	0x1d
sys_flagext	==	0x1e
hardware	==	0x1f

r_ax		==	0x20
r_exa		==	0x21
r_cnt		==	0x22
r_bx		==	0x23
r_exb		==	0x24
; 独立
; bank 0
r0_ax		==	0x20
r0_exa		==	0x21
r0_cnt		==	0x22
r0_bx		==	0x23
r0_exb		==	0x24

r0_int_ppsr	==	0x25
r0_int_addr	==	0x26
r0_int_block	==	0x27

r0_key1		==	0x28
r0_key2		==	0x29
r0_key3		==	0x2a
r0_key4		==	0x2b
r0_key1_get	==	0x2c
r0_key2_get	==	0x2d
r0_key3_get	==	0x2e
r0_key4_get	==	0x2f
r0_key1_bak	==	0x30
r0_key2_bak	==	0x31
r0_key3_bak	==	0x32
r0_key4_bak	==	0x33
r0_key1_dealed	==	0x34
r0_key2_dealed	==	0x35
r0_key3_dealed	==	0x36
r0_key4_dealed	==	0x37
r0_tmr_key	==	0x38

r0_tmr_timer	==	0x39
r0_tmr_unit	==	0x3a

r0_tmr		==	0x3b
r0_tmr_idle	==	0x3c

r0_int_ax	==	0x3d

; bank 1
r1_ax		==	0x20
r1_exa		==	0x21
r1_cnt		==	0x22
r1_bx		==	0x23
r1_exb		==	0x24

r1_rtc_tmr	==	0x25
r1_rtc_second	==	0x26
r1_rtc_minute	==	0x27
r1_rtc_hour	==	0x28
r1_rtc_week	==	0x29
r1_rtc_day	==	0x2a
r1_rtc_month	==	0x2b
r1_rtc_year	==	0x2c
r1_rtc_century	==	0x2d
r1_rtc_flag	==	0x2e		; 0 -- second update, 用作最小显示秒的时间更新标志, 设置时间时更新秒
					; 1 -- minute update, 用作最小显示分的时间更新标志, 时钟的显示
					; 2 -- hour update
					; 3 -- day update, 每过一天，同步时钟。
					; 4 -- month update
					; 5 -- year update
					; 7 -- 中断更新
r1_time_flag	==	0x2f		; 0 -- second update
					; 1 -- minute update
					; 2 -- hour update
					; 3 -- day update
					; 4 -- month update
					; 5 -- year update
r1_msecond	==	0x30
r1_second	==	0x31
r1_minute	==	0x32
r1_hour		==	0x33
r1_week		==	0x34
r1_day		==	0x35
r1_month	==	0x36
r1_year		==	0x37
r1_century	==	0x38
r1_int_second	==	0x39
r1_rtc_temp	==	0x3a

r1_id		==	0x3e
r1_flag		==	0x3f


; bank 2
r2_ax		==	0x20
r2_exa		==	0x21
r2_cnt		==	0x22
r2_bx		==	0x23
r2_exb		==	0x24

r2_tmr_blight	==	0x28
r2_tmr_blight1	==	0x29
r2_tmr_dial	==	0x2a		; unit: 4ms
r2_tmr_dial1	==	0x2b		; unit: 1s

r2_msec		==	0x2c		; 拨号计时
r2_second	==	0x2d
r2_minute	==	0x2e
r2_hour		==	0x2f

r2_msec_bak	==	0x30
r2_second_bak	==	0x31
r2_minute_bak	==	0x32
r2_hour_bak	==	0x33

r2_stamp1	==	0x34
r2_stamp2	==	0x35
r2_stamp3	==	0x36

r2_tmr_newcall	==	0x37
r2_led_newcall	==	0x38

r2_id		==	0x3e
r2_flag		==	0x3f

; bank 3
r3_ax		==	0x20
r3_exa		==	0x21
r3_cnt		==	0x22
r3_bx		==	0x23
r3_exb		==	0x24

r3_display	==	0x25			; 待机时的更新要求
						; 0 -- stamp1
						; 1 -- stamp2
						; 2 -- stamp3
						; 3 -- number1
						; 4 -- number2
						; 5 -- char

r3_newmsg	==	0x26
r3_totalmsg	==	0x27

r3_newcall	==	0x28
r3_totalcall	==	0x29
r3_dialedcall	==	0x2a
r3_book		==	0x2b

r3_remotecode1	==	0x30
r3_remotecode2	==	0x31
r3_areacode1	==	0x32
r3_areacode2	==	0x33
r3_contrast	==	0x34
r3_language	==	0x35
r3_ringmelody	==	0x36
r3_ringvolume	==	0x37
r3_ringdelay	==	0x38
r3_rate		==	0x39
r3_flashtime	==	0x3a
r3_pausetime	==	0x3b
r3_ogm		==	0x3c


r3_callmenu	==	0x3d			
						; 0 -- erase current
						; 1 -- erase all
r3_id		==	0x3e
r3_flag		==	0x3f

; bit

; sys_flag
LCDFLASHSTATUS	==	0		; Lcd flash状态位 0-on; 1-off
TIMEFORMAT	==	1		; 时间制式 0-12小时; 1-24小时
HOOKSTATUS	==	2		; HOOK状态位 0-on; 1-off
PROGRAMINIT	==	3		; 程序第一次初始化
PROGRAMREIN	==	4		; 程序重新进入
DIALTYPE	==	5		; 拨号类型，0-tone, 1-pulse
SPKPHONE	==	6		; spkphone, 0-off, 1-on
STAMP		==	7		; 印花更新

; sys_flagext
DSPSTATUS	==	0

;hardware
DTAMPOWER	==	0		; DTAM状态，0-off,1-on
SYNCCLOCK	==	1		; 同步时钟
SYNCSETTING	==	2		; 同步设置
POWERSTATUS	==	6		; power状态，0-down, 1-on
HANDSET		==	7		; 手柄状态， 0-摘机，1-挂机

VALUE_IOCA	==	0x40
TIME_UNIT	==	10

STYLE_NORMAL	==	(0x00+0x80)
STYLE_LEFT	==	(0x01+0x80)	; 靠左
STYLE_RIGHT	==	(0x02+0x80)	; 靠右
STYLE_CENTER	==	(0x03+0x80)	; 居中
/*
CAPS_NORMAL	==	0x00
CAPS_ALL	==	0x10		; 全部大写
CAPS_WORD	==	0x20		; 每个单词的首字母大写，空格之后的第一个字符大写
CAPS_CHAR	==	0x30		; 短语的第一个字符大写
CAPS_LETTER	==	0x40		; 短语的第一个字母大写
CAPS_LOWER	==	0x50		; 短语的第一个小写字母大写
*/

CAPS_OFF	==	0x00
CAPS_ON		==	0x40

INITIAL_OFF	==	0x00
INITIAL_ON	==	0x20

CH_END		==	0

; message

WM_NONE		==	0x00
WM_KEYPRESS	==	0x01
WM_KEYREPRESS	==	0x02
WM_KEYRELEASE	==	0x03
WM_TIME		==	0x04
WM_POWER	==	0x05
WM_HANDSET	==	0x06
WM_COMMAND	==	0x07

KEY_1		==	0x00
KEY_2		==	0x04
KEY_3		==	0x10
KEY_4		==	0x01
KEY_5		==	0x05
KEY_6		==	0x11
KEY_7		==	0x02
KEY_8		==	0x06
KEY_9		==	0x12
KEY_STAR	==	0x03
KEY_0		==	0x07
KEY_HASH	==	0x13
KEY_PLAY	==	0x20
KEY_OGM		==	0x21
KEY_MEMO	==	0x22
KEY_ONOFF	==	0x23
KEY_VOLA	==	0x24
KEY_VOLS	==	0x25
KEY_STOP	==	0x16
KEY_MENU	==	0x30
KEY_SPK		==	0x17
KEY_LEFT	==	0x26
KEY_REDIAL	==	0x15
KEY_FLASH	==	0x14
KEY_RIGHT	==	0x27

KEY_PAUSE	==	KEY_PLAY
KEY_DIAL	==	KEY_PLAY
KEY_ERASE	==	KEY_ONOFF
KEY_MUTE	==	KEY_ONOFF
KEY_M1		==	KEY_FLASH
KEY_BACK	==	KEY_FLASH
KEY_M2		==	KEY_REDIAL
KEY_M3		==	KEY_STOP
KEY_EXIT	==	KEY_STOP
KEY_UP		==	KEY_VOLA
KEY_DOWN	==	KEY_VOLS
KEY_PBOOK	==	KEY_LEFT
KEY_CID		==	KEY_RIGHT
KEY_OK		==	KEY_MENU
KEY_ENTER	==	KEY_MENU
KEY_LCD		==	KEY_VOLS
KEY_PROGRAM	==	KEY_VOLA

POWER_ON	==	0x00
POWER_DOWN	==	0x01
HANDSET_ON	==	0x00			; (手柄挂机)
HANDSET_OFF	==	0x01			; (手柄摘机)


/*************************************************
光标说明：
cursor	.7~.4 = y坐标; .3~.0 = x坐标
tmr_cursor	光标的计时器

*************************************************/




/*************************************************
DATA RAM

BLOCK 0:
本区专供LCD driver
0~127		LCD 显示映射区
30~3f		temp
70~7f		空

0x70		闪烁更新标志位
0x71~0x73	印花闪烁标志位
0x74~0x75	第一行数字闪烁标志位
0x76~0x77	第二行数字闪烁标志位
0x78~0x79	第三行字符闪烁标志位
0x7a		字符串的ID
0x7b		字符串的计数器。

128		LCD 显示控制
128+1~3		3个印花				; 印花直接输入到这里
128+4~13	第一行10个数字
128+14~29	第二行16个数字
128+30~45	第三行16个字符

128+48		第一行控制器
128+49		第一行计数器
128+50~59	第一行数字缓冲区
128+60		第二行控制器
128+61		第二行计数器
128+62~93	第二行数字缓冲区
128+94		第三行控制器
128+95		第三行计数器
128+96~127	第三行字符缓冲区


BLOCK 1:
本区专供FSK接受区
0~7		clock package
8~71		cid package

128		M1	=1(=0表示没有)
129~144		M1 number(16位号码)
145~160		M1 name(16位人名)
161		M1 ring(1位铃声编号)

162		M2	=2(=0表示没有)
163~178		M2 number
179~194		M2 name
195		M2 ring

196		M3	=3(=0表示没有)
197~212		M3 number
213~228		M3 name
229		M3 ring


BLOCK 2:
本区专供FSK解码显示区

BLOCK 3:
本区专供拨号区。
0		当前拨号状态寄存器
		.7	=0 没有拨过任何号码，=1 拨过号码
		.6	=1 当前按键持续中，并且等于最后一次存入的号码键。
		.5	=0 tone, =1 pulse
		.4	=1 mute, =0 normal
		.3~.0	拨号的状态
			0 -- idle和delay
			1 -- 拨号前的mute(20ms)
			2 -- 拨一个号码(100ms)
			3 -- 拨号后的mute(20ms)
			4 -- flash前的mute(20ms)
			5 -- flash(100ms~900ms)
			6 -- flash后的mute(20ms)
			r2_tmr_dial, r2_tmr_dial1拨号时的计时器，单位:10ms,s，只要计时器未到0，拨号状态不会改变。
			拨号之间delay同idle
		
		。
1		当前拨号缓冲区指针
2~65		共64个号码缓冲区，号码为ASCII码。

66		最后一次拨号可用于重拨的号码长度，
67~98		32个号码缓冲区，本号码可用于重拨。

99~130		32个重拨号码区，固定长度，0之前的为有效号码

131		号码编辑区的有效长度，1~32。
132~163		32个号码编辑区，本区可以编辑。
164		人名编辑区的有效长度，1~32
165~196		32个人名编辑区，本区可以编辑。
197		铃声编辑。
198		编辑区属性
		0- phonebook; 1~3- M1~M3;

200		来电的长度
201~232		来电号码，最大32位。
233~236		遥控密码设置时临时存储位置
BLOCK 4:
本区专供IIC发送接收区
0		从机地址
1		IIC状态
		.7	=0 idle; =1 sending/receiving
		.6	=0 idle; =1 slave busy (cannot send)
2		发送指针
3~62		send data (60bytes)

63~122		one command (60bytes)

128		接收指针
129~255		接收区，最大127个
*************************************************/


