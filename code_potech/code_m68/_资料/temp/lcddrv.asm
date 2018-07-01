ORG	0x0800

/*************************************************
光标
cursor
.7	光标的状态
.4~.5	光标的y坐标
.0~.3	光标的x坐标
tmr_cursor	光标的计时器，中断中每4ms减1至0为止

SerCursor
	光标的服务程序，依赖中断中光标计时。
	判断光标，当光标有效时并且光标状态发生改变时，对相应LCD区发出显示请求
	光标状态cursor.7=0/1光标亮/灭。
*************************************************/

SerCursor:
	MOV	A,tmr_cursor
	JPNZ	SerCursor_ret
	BLOCK	0
	XOR	cursor,@(1<<7)
	JPB	cursor,7,SerCursor_off
SerCursor_on:
	MOV	A,@(600/4)
	JMP	$+2
SerCursor_off:
	MOV	A,@(400/4)
	MOV	tmr_cursor,A
	SWAPA	cursor
	AND	A,@(0x03)
	JPNZ	LcdDraw
SerCursor_ret:
	RET



/*************************************************
LCD驱动程序。只能显示ASCII中的字符
block 0中.128的内容为驱动控制。
.7	stamp显示请求
.6	number1显示请求
.5	number2显示请求
.4	char显示请求
.1~.0	显示循环计数。
只有调用本程序才能让LcdDriver显示内容
输入：ACC	0	印花更新请求
		1	第一行数字更新请求
		2	第二行数字更新请求
		3	第三行字符更新请求
*************************************************/

LcdDraw:
	MOV	ax,A
	BLOCK	0
	MOV	_RC,@(128)
	ANDA	ax,@(0x03)
	TBL
	JMP	LcdDraw_stamp
	JMP	LcdDraw_number1
	JMP	LcdDraw_number2
	JMP	LcdDraw_char
LcdDraw_stamp:
	BS	_RD,7
	JMP	LcdDraw_ret
LcdDraw_number1:
	BS	_RD,6
	JMP	LcdDraw_ret
LcdDraw_number2:
	BS	_RD,5
	JMP	LcdDraw_ret
LcdDraw_char:
	BS	_RD,4
LcdDraw_ret:
	RET


/*************************************************
LCD驱动程序。只能显示ASCII中的字符
block 0中.128的内容为驱动控制。
.7	stamp显示请求
.6	number1显示请求
.5	number2显示请求
.4	char显示请求
.1~.0	显示循环计数。
轮寻方式显示。将存在存储区的ASCII值显示出来
*************************************************/

LcdDriver:
	BLOCK	0
	BANK	0
	MOV	_RC,@(0x70)
	MOV	ax,_RD
	MOV	_RC,@(128)
	JPNB	_RD,3,LcdDriver_1
	BC	_RD,3
	OR	_RD,ax
	XOR	sys_flag,@(1<<LCDFLASHSTATUS)
LcdDriver_1:
	MOV	A,_RD
	JPZ	LcdDriver_ret
	MOV	ax,A
	ADD	A,@(0x01)
	AND	A,@(0xf3)
	MOV	_RD,A
	
	ANDA	ax,@(0x03)
	TBL
	JMP	LcdDriver_stamp
	JMP	LcdDriver_number1
	JMP	LcdDriver_number2
	JMP	LcdDriver_char
LcdDriver_stamp:
	JPNB	_RD,7,LcdDriver_1
	BC	_RD,7
	JMP	LcdUpdateStamp
LcdDriver_number1:
	JPNB	_RD,6,LcdDriver_1
	BC	_RD,6
	JMP	LcdUpdateNumber1
LcdDriver_number2:
	JPNB	_RD,5,LcdDriver_1
	BC	_RD,5
	JMP	LcdUpdateNumber2
LcdDriver_char:
	JPNB	_RD,4,LcdDriver_1
	BC	_RD,4
	JMP	LcdUpdateChar
LcdDriver_ret:
	RET

/***************************************
显示第一行的8个印花
.7	handset
.6	spk
.5	AM
.4	PM
.3	second
.2	/
.1	CALLS
.0	NEW
***************************************/
LcdUpdateStamp:
LcdUpdateStamp1:
	MOV	_RC,@(128+1)
	CALL	LcdGetData
	
	WR_STAMP	ax,7,@(7+0x40),2,exa
	WR_STAMP	ax,6,@(6+0x40),2,exa
	WR_STAMP	ax,5,@(7+0x40),1,exa
	WR_STAMP	ax,4,@(6+0x40),1,exa
	WR_STAMP	ax,3,@(4+0x00),4,exa
	WR_STAMP	ax,2,@(0+0x00),5,exa
	WR_STAMP	ax,1,@(1+0x00),5,exa
	WR_STAMP	ax,0,@(2+0x00),5,exa
	;RET

/***************************************
显示第二行的前8个印花
.7	tape
.6	FULL
.5	REC
.4	pause
.3	play
.2	ringoff
.1	mute
.0	book
***************************************/
LcdUpdateStamp2:
	MOV	_RC,@(128+2)
	CALL	LcdGetData
	
	WR_STAMP	ax,7,@(6+0x40),3,exa
	WR_STAMP	ax,6,@(5+0x40),2,exa
	WR_STAMP	ax,5,@(5+0x40),1,exa
	WR_STAMP	ax,4,@(4+0x40),2,exa
	WR_STAMP	ax,3,@(4+0x40),1,exa
	WR_STAMP	ax,2,@(4+0x00),6,exa
	WR_STAMP	ax,1,@(4+0x00),2,exa
	WR_STAMP	ax,0,@(4+0x00),0,exa
	;RET

/***************************************
显示第二行的后8个印花
.7	RPT
.6	VIP
.5	CFWD
.4	FILTER
.3	message
.2	0
.1	0
.0	0
***************************************/
LcdUpdateStamp3:
	MOV	_RC,@(128+3)
	CALL	LcdGetData
	
	WR_STAMP	ax,7,@(3+0x00),1,exa
	WR_STAMP	ax,6,@(3+0x00),3,exa
	WR_STAMP	ax,5,@(3+0x00),5,exa
	WR_STAMP	ax,4,@(3+0x40),0,exa
	WR_STAMP	ax,3,@(3+0x40),2,exa
	RET

WR_STAMP	MACRO	STAMP_REG,STAMP_BIT,@LCD_ADDR,LCD_BIT,STAMP_TEMP
	MOV	_RC,@(LCD_ADDR)
	IOW	_IOCB
	MOV	STAMP_TEMP,_RD
	BC	STAMP_TEMP,LCD_BIT
	JPNB	STAMP_REG,STAMP_BIT,$+2
	BS	STAMP_TEMP,LCD_BIT
	IOW	_IOCC,STAMP_TEMP
	MOV	_RD,A
	ENDM



/*************************************************
显示第一行的数字
数字按ASCII编码按顺序排列在data ram中。
*************************************************/
LcdUpdateNumber1:
	MOV	r0_ax,@(0x10)
	
	MOV	_RC,@(128+4)
	MOV	A,@(0x86)
	CALL	LcdMatrixType1
	
	MOV	_RC,@(128+5)
	MOV	A,@(0x54)
	CALL	LcdMatrixType1
	
	MOV	_RC,@(128+6)
	MOV	A,@(0x32)
	CALL	LcdMatrixType1
	
	MOV	_RC,@(128+7)
	MOV	A,@(0x10)
	CALL	LcdMatrixType1
	
	MOV	_RC,@(128+8)
	CALL	LcdMatrixType2
	
	MOV	r0_ax,@(0x00)
	
	MOV	_RC,@(128+9)
	MOV	A,@(0x07)
	CALL	LcdMatrixType1
	
	MOV	_RC,@(128+10)
	MOV	A,@(0x21)
	CALL	LcdMatrixType1
	
	MOV	_RC,@(128+11)
	MOV	A,@(0x43)
	CALL	LcdMatrixType1
	
	MOV	r0_ax,@(0x08)
	
	MOV	_RC,@(128+12)
	MOV	A,@(0x86)
	CALL	LcdMatrixType1
	
	MOV	_RC,@(128+13)
	MOV	A,@(0xa9)
	CALL	LcdMatrixType1
	
	RET


/*************************************************
显示第二行的数字
数字按ASCII编码按顺序排列在data ram中。
*************************************************/
LcdUpdateNumber2:
	MOV	r0_ax,@(0x08)
	MOV	_RC,@(128+14)
	MOV	A,@(0x76)
	CALL	LcdMatrixType3
	
	MOV	_RC,@(128+15)
	MOV	A,@(0x54)
	CALL	LcdMatrixType3
	
	MOV	_RC,@(128+16)
	MOV	A,@(0x00)
	CALL	LcdMatrixType5
	
	MOV	r0_ax,@(0x00)
	MOV	_RC,@(128+17)
	MOV	A,@(10)
	CALL	LcdMatrixType4
	
	MOV	_RC,@(128+19)
	MOV	A,@(17)
	CALL	LcdMatrixType4
	
	MOV	_RC,@(128+21)
	MOV	A,@(24)
	CALL	LcdMatrixType4
	
	MOV	_RC,@(128+23)
	MOV	A,@(31)
	CALL	LcdMatrixType4
	
	MOV	_RC,@(128+25)
	MOV	A,@(38)
	CALL	LcdMatrixType4
	
	MOV	r0_ax,@(0x08)
	MOV	_RC,@(128+18)
	MOV	A,@(14)
	CALL	LcdMatrixType4
	
	MOV	_RC,@(128+20)
	MOV	A,@(21)
	CALL	LcdMatrixType4
	
	MOV	_RC,@(128+22)
	MOV	A,@(28)
	CALL	LcdMatrixType4
	
	MOV	_RC,@(128+24)
	MOV	A,@(35)
	CALL	LcdMatrixType4
	
	MOV	_RC,@(128+26)
	MOV	A,@(42)
	CALL	LcdMatrixType4
	
	MOV	_RC,@(128+27)
	MOV	A,@(0x0e)
	CALL	LcdMatrixType5
	
	MOV	r0_ax,@(0x00)
	MOV	_RC,@(128+28)
	MOV	A,@(0x32)
	CALL	LcdMatrixType3
	
	MOV	_RC,@(128+29)
	MOV	A,@(0x10)
	CALL	LcdMatrixType3
	
	RET

/*************************************************
显示第三行的字符
字符按ASCII编码按顺序排列在data ram中。
*************************************************/
LcdUpdateChar:
	CLR	cnt				; 显示的位数
LcdUpdateChar_loop:
	RRCA	cnt
	AND	A,@(0x7f)
	MOV	bx,A
	ADD	A,bx
	ADD	A,bx
	ADD	A,bx
	ADD	A,bx
	ADD	A,@(8)
	MOV	bx,A				; 显示地址
	JPB	cnt,0,LcdUpdateChar_loop_even
LcdUpdateChar_loop_odd:
	ADD	bx,@(0x40)			; 奇数位在高位，要加上偏移
LcdUpdateChar_loop_even:
LcdUpdateChar_digit:				; 开始显示一个位
	ADDA	cnt,@(128+30)
	MOV	_RC,A
	CALL	LcdGetData
	CLR	exb				; 显示的列
LcdUpdateChar_digit_loop:
	MOV	A,exb
	TBL
	JMP	LcdUpdateChar_digit_loop1
	JMP	LcdUpdateChar_digit_loop2
	JMP	LcdUpdateChar_digit_loop3
	JMP	LcdUpdateChar_digit_loop4
	JMP	LcdUpdateChar_digit_loop5
LcdUpdateChar_digit_loop1:
	MOV	A,ax
	LCALL	TabChar1
;	MOV	exa,A
;	ADDA	cnt,@(128+30)
;	MOV	_RC,A
;	CALL	LcdGetCursor
;	ADD	A,@(0)
;	JPZ	LcdUpdateChar_digit_loop1_1
;	XOR	exa,@(0x7f)
;LcdUpdateChar_digit_loop1_1:
;	MOV	A,exa
	JMP	LcdUpdateChar_digit_loop_1
LcdUpdateChar_digit_loop2:
	MOV	A,ax
	LCALL	TabChar2
	JMP	LcdUpdateChar_digit_loop_1
LcdUpdateChar_digit_loop3:
	MOV	A,ax
	LCALL	TabChar3
	JMP	LcdUpdateChar_digit_loop_1
LcdUpdateChar_digit_loop4:
	MOV	A,ax
	LCALL	TabChar4
	JMP	LcdUpdateChar_digit_loop_1
LcdUpdateChar_digit_loop5:
	MOV	A,ax
	LCALL	TabChar5
LcdUpdateChar_digit_loop_1:
	MOV	exa,A
	ADDA	bx,exb				; 地址再加上列地址
	MOV	_RC,A
	IOW	_IOCB
	ANDA	_RD,@(0x80)
	OR	A,exa
	MOV	_RD,A
	IOW	_IOCC
	INC	exb
	SUBA	exb,@5
	JPNZ	LcdUpdateChar_digit_loop
	INC	cnt
	SUBA	cnt,@16
	JPNZ	LcdUpdateChar_loop
	
	RET



/*************************************************
点阵类型1
输入：	acc	-- 高位com，低位com
	r0_ax	-- 点阵起始地址。

	字符	-- 在当前的ram addr中

说明：
本类型只适合以下情况：
1、7段数码管。
2、只占两个common口。
*************************************************/
LcdMatrixType1:
	MOV	cnt,A
	CALL	LcdGetData
	LCALL	TabLed
	MOV	ax,A
	CLR	r0_cnt

LcdMatrixType1_loop:
	ANDA	cnt,@(0x0f)
	MOV	bx,A
	
	ADDA	r0_ax,r0_cnt
	CALL	TabLcdMatrixType1
	MOV	r0_exa,A
	XOR	A,@(0xff)
	JPZ	LcdMatrixType1_change
	ANDA	r0_exa,@(0x0f)
	MOV	exb,A
	SWAPA	r0_exa
	AND	A,@(0x0f)
	MOV	exa,A
	CALL	LcdUpdateBit
	JMP	LcdMatrixType1_next
LcdMatrixType1_change:
	SWAP	cnt
LcdMatrixType1_next:
	INC	r0_cnt
	JPNB	r0_cnt,3,LcdMatrixType1_loop
LcdMatrixType1_ret:
	RET

TabLcdMatrixType1:				; 高位:段码的位；低位:segment口
	TBL
; 第一种，起始地址0x00
	RETL	@(0x00)				; A
	RETL	@(0x51)				; F
	RETL	@(0x42)				; E
	RETL	@(0xff)				; ff:转换common口
	RETL	@(0x10)				; B
	RETL	@(0x61)				; G
	RETL	@(0x22)				; C
	RETL	@(0x33)				; D
; 第二种，起始地址0x08
	RETL	@(0x00)				; A
	RETL	@(0x51)				; F
	RETL	@(0x42)				; E
	RETL	@(0x33)				; D
	RETL	@(0xff)				; ff:转换common口
	RETL	@(0x10)				; B
	RETL	@(0x61)				; G
	RETL	@(0x22)				; C
; 第三种，起始地址0x10
	RETL	@(0x25)				; C
	RETL	@(0x66)				; G
	RETL	@(0x17)				; B
	RETL	@(0xff)				; ff:转换common口
	RETL	@(0x34)				; D
	RETL	@(0x45)				; E
	RETL	@(0x56)				; F
	RETL	@(0x07)				; A
	

/*************************************************
点阵类型2
输入：

	字符	-- 在当前的ram addr中

说明：
本类型只适合以下情况：
1、特殊数码管，月份的高位。
*************************************************/
LcdMatrixType2:
	CALL	LcdGetData
	LCALL	TabLed
	MOV	ax,A
	MOV	exa,@(0x01)
	MOV	bx,@(0x07)
	MOV	exb,@(0x04)
	CALL	LcdUpdateBit
	RET


/*************************************************
点阵类型3
输入：	acc	-- 高位segment，低位segment
	r0_ax	-- 点阵起始地址
	
	字符	-- 在当前的ram addr中

说明：
本类型只适合以下情况：
1、7段数码管。
2、只占两个segment口。
*************************************************/
LcdMatrixType3:
	MOV	cnt,A
	CALL	LcdGetData
	LCALL	TabLed
	MOV	ax,A
	CLR	r0_cnt

LcdMatrixType3_loop:
	ANDA	cnt,@(0x0f)
	MOV	exb,A
	
	ADDA	r0_ax,r0_cnt
	CALL	TabLcdMatrixType3
	MOV	r0_exa,A
	XOR	A,@(0xff)
	JPZ	LcdMatrixType3_change
	ANDA	r0_exa,@(0x0f)
	MOV	bx,a
	SWAPA	r0_exa
	AND	A,@(0x0f)
	MOV	exa,A
	CALL	LcdUpdateBit
	JMP	LcdMatrixType3_next
LcdMatrixType3_change:
	SWAP	cnt
LcdMatrixType3_next:
	INC	r0_cnt
	JPNB	r0_cnt,3,LcdMatrixType3_loop
LcdMatrixType3_ret:
	RET

TabLcdMatrixType3:				; 高位:段码位；地位:common口
	TBL
; 第一种，起始地址0x00
	RETL	@(0x3b)				; D
	RETL	@(0x2c)				; C
	RETL	@(0x1d)				; B
	RETL	@(0x0e)				; A
	RETL	@(0xff)				; ff: 转换segment口
	RETL	@(0x4c)				; E
	RETL	@(0x6d)				; G
	RETL	@(0x5e)				; F
; 第二种，起始地址0x08
	RETL	@(0x1c)				; B
	RETL	@(0x6d)				; G
	RETL	@(0x2e)				; C
	RETL	@(0xff)				; ff: 转换segment口
	RETL	@(0x0b)				; A
	RETL	@(0x5c)				; F
	RETL	@(0x4d)				; E
	RETL	@(0x3e)				; D


/*************************************************
点阵类型4
输入：	acc	-- segment起始地址
	r0_ax	-- 点阵起始地址。

	字符	-- 在当前的ram addr中

说明：
本类型只适合以下情况：
1、7段数码管。
2、只占两个common口。并且是固定的，com7和com15
*************************************************/
LcdMatrixType4:
	MOV	cnt,A
	CALL	LcdGetData
	LCALL	TabLed
	MOV	ax,A
	CLR	r0_cnt
	MOV	bx,@(0x07)

LcdMatrixType4_loop:
	ADDA	r0_ax,r0_cnt
	CALL	TabLcdMatrixType4
	MOV	r0_exa,A
	XOR	A,@(0xff)
	JPZ	LcdMatrixType4_change
	ANDA	r0_exa,@(0x0f)
	ADD	A,cnt
	MOV	exb,A
	SWAPA	r0_exa
	AND	A,@(0x0f)
	MOV	exa,A
	CALL	LcdUpdateBit
	JMP	LcdMatrixType4_next
LcdMatrixType4_change:
	MOV	bx,@(0x0f)
LcdMatrixType4_next:
	INC	r0_cnt
	JPNB	r0_cnt,3,LcdMatrixType4_loop
LcdMatrixType4_ret:
	RET

TabLcdMatrixType4:				; 高位:段码的位；低位:segment口相对位置
	TBL
; 第一种，起始地址0x00
	RETL	@(0x00)				; A
	RETL	@(0x51)				; F
	RETL	@(0x62)				; G
	RETL	@(0x13)				; B
	RETL	@(0xff)				; ff:转换common口
	RETL	@(0x41)				; E
	RETL	@(0x32)				; D
	RETL	@(0x23)				; C
; 第二种，起始地址0x08
	RETL	@(0x00)				; A
	RETL	@(0x61)				; G
	RETL	@(0x22)				; C
	RETL	@(0xff)				; ff:转换common口
	RETL	@(0x50)				; F
	RETL	@(0x41)				; E
	RETL	@(0x32)				; D
	RETL	@(0x13)				; B


/*************************************************
点阵类型5
输入：	acc	-- 起始地址

	字符	-- 在当前的ram addr中

说明：
本类型只适合以下情况：
1、7段数码管。
2、第13个7段数码管和第24个7段数码管
*************************************************/
LcdMatrixType5:
	MOV	r0_ax,A
	CALL	LcdGetData
	LCALL	TabLed
	MOV	ax,A
	CLR	r0_cnt
	CLR	exa

LcdMatrixType5_loop:
	ADDA	r0_ax,r0_cnt
	CALL	TabLcdMatrixType5
	MOV	bx,A
	INC	r0_cnt
	ADDA	r0_ax,r0_cnt
	CALL	TabLcdMatrixType5
	MOV	exb,A
	INC	r0_cnt
	CALL	LcdUpdateBit
	INC	exa
	
	SUBA	r0_cnt,@14
	JPNC	LcdMatrixType5_loop
LcdMatrixType5_ret:
	RET
ORG	0x0b00
TabLcdMatrixType5:
	TBL
; 第一种，起始地址0x00
	RETL	@(11)
	RETL	@(4)
	RETL	@(15)
	RETL	@(10)
	RETL	@(7)
	RETL	@(9)
	RETL	@(15)
	RETL	@(9)
	RETL	@(15)
	RETL	@(8)
	RETL	@(15)
	RETL	@(4)
	RETL	@(7)
	RETL	@(8)
; 第二种，起始地址0x0e
	RETL	@(7)
	RETL	@(45)
	RETL	@(7)
	RETL	@(3)
	RETL	@(15)
	RETL	@(3)
	RETL	@(15)
	RETL	@(47)
	RETL	@(15)
	RETL	@(46)
	RETL	@(7)
	RETL	@(46)
	RETL	@(7)
	RETL	@(47)


/*************************************************
LcdUpdateBit
更新一个位
输入：	ax	-- 需要显示的段码
	exa	-- 段码的位
	bx	-- common口
	exb	-- segment口
*************************************************/
LcdUpdateBit:
	MOV	_RC,exb
	JPNB	bx,3,$+3
	ADD	_RC,@(0x40)			; 当前lcd的地址
	IOW	_IOCB,_RC
	MOV	A,exa
	LCALL	TabSetBit
	AND	A,ax
	JPNZ	LcdUpdateBit_1
LcdUpdateBit_0:
	ANDA	bx,@(0x07)
	LCALL	TabSetBit
	XOR	A,@(0xff)
	AND	_RD,A
	JMP	LcdUpdateBit_2
LcdUpdateBit_1:
	ANDA	bx,@(0x07)
	LCALL	TabSetBit
	OR	_RD,A
LcdUpdateBit_2:
	IOW	_IOCC,_RD
	RET


LcdGetCursor:
	SUBA	_RC,@(128+46)
	JPNC	LcdGetCursor_char
LcdGetCursor_err:
LcdGetCursor_false:
	RETL	@(0)
LcdGetCursor_true:
	RETL	@(1)
LcdGetCursor_char:
	SWAPA	cursor
	AND	A,@(0x03)
	SUB	A,@(3)
	JPNZ	LcdGetCursor_false
	SUBA	_RC,@(128+30)
	XOR	A,cursor
	AND	A,@(0x0f)
	JPNZ	LcdGetCursor_false
	JPNB	cursor,7,LcdGetCursor_false
	JMP	LcdGetCursor_true



	


LcdGetData:
	MOV	ax,_RD
	SUBA	_RC,@(128+1)
	JPNC	LcdGetData_err
	SUBA	_RC,@(128+4)
	JPNC	LcdGetData_stamp
	SUBA	_RC,@(128+14)
	JPNC	LcdGetData_num1
	SUBA	_RC,@(128+30)
	JPNC	LcdGetData_num2
	SUBA	_RC,@(128+46)
	JPNC	LcdGetData_char
LcdGetData_err:
	MOV	ax,@(0)
	JMP	LcdGetData_ret
LcdGetData_stamp:
	JPNB	sys_flag,LCDFLASHSTATUS,LcdGetData_ret
	SUBA	_RC,@(128+1)
	ADD	A,@(0x70+1)
	MOV	_RC,A
	XORA	_RD,@(0xff)
	AND	ax,A
	JMP	LcdGetData_ret
LcdGetData_num1:

	SWAPA	cursor
	AND	A,@(0x03)
	SUB	A,@(1)
	JPNZ	LcdGetData_num1_0
	SUBA	_RC,@(128+4)
	XOR	A,cursor
	AND	A,@(0x0f)
	JPNZ	LcdGetData_num1_0
	JPNB	cursor,7,LcdGetData_ret
	MOV	ax,@(127)
	JMP	LcdGetData_ret

LcdGetData_num1_0:
	JPNB	sys_flag,LCDFLASHSTATUS,LcdGetData_ret
	SUBA	_RC,@(128+4+8)
	JPC	LcdGetData_num1_1
	SUBA	_RC,@(128+4)
	LCALL	TabSetBit
	;DISI
	;MOV	int_ax,A
	MOV	r0_bx,A
	MOV	A,@(0x70+4)
	JMP	LcdGetData_ascii
LcdGetData_num1_1:
	LCALL	TabSetBit
	;DISI
	;MOV	int_ax,A
	MOV	r0_bx,A
	MOV	A,@(0x70+5)
	JMP	LcdGetData_ascii
LcdGetData_num2:

	SWAPA	cursor
	AND	A,@(0x03)
	SUB	A,@(2)
	JPNZ	LcdGetData_num2_0
	SUBA	_RC,@(128+14)
	XOR	A,cursor
	AND	A,@(0x0f)
	JPNZ	LcdGetData_num2_0
	JPNB	cursor,7,LcdGetData_ret
	MOV	ax,@(127)
	JMP	LcdGetData_ret

LcdGetData_num2_0:
	JPNB	sys_flag,LCDFLASHSTATUS,LcdGetData_ret
	SUBA	_RC,@(128+14+8)
	JPC	LcdGetData_num2_1
	SUBA	_RC,@(128+14)
	LCALL	TabSetBit
	;DISI
	;MOV	int_ax,A
	MOV	r0_bx,A
	MOV	A,@(0x70+6)
	JMP	LcdGetData_ascii
LcdGetData_num2_1:
	LCALL	TabSetBit
	;DISI
	;MOV	int_ax,A
	MOV	r0_bx,A
	MOV	A,@(0x70+7)
	JMP	LcdGetData_ascii
LcdGetData_char:

	SWAPA	cursor
	AND	A,@(0x03)
	SUB	A,@(3)
	JPNZ	LcdGetData_char_0
	SUBA	_RC,@(128+30)
	XOR	A,cursor
	AND	A,@(0x0f)
	JPNZ	LcdGetData_char_0
	JPNB	cursor,7,LcdGetData_ret
	MOV	ax,@(127)
	JMP	LcdGetData_ret

LcdGetData_char_0:
	JPNB	sys_flag,LCDFLASHSTATUS,LcdGetData_ret
	SUBA	_RC,@(128+30+8)
	JPC	LcdGetData_char_1
	SUBA	_RC,@(128+30)
	LCALL	TabSetBit
	;DISI
	;MOV	int_ax,A
	MOV	r0_bx,A
	MOV	A,@(0x70+8)
	JMP	LcdGetData_ascii
LcdGetData_char_1:
	LCALL	TabSetBit
	;DISI
	;MOV	int_ax,A
	MOV	r0_bx,A
	MOV	A,@(0x70+9)
	JMP	LcdGetData_ascii
	
LcdGetData_ascii:
	MOV	_RC,A
	;ANDA	_RD,int_ax
	ANDA	_RD,r0_bx
	JPZ	$+2
	CLR	ax
	;ENI
LcdGetData_ret:
	MOV	A,ax
	RET
	
	
