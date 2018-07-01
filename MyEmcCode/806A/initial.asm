
INITIAL:

	MOV	_FSR,@0X70			; 3.5826MHz
	DISI
	WDTC
	PAGEIO	0
	BANK	0
	
	MOV	_RE,@0X01			; set lcd 1/8 duty 1/4 bias
	MOV	_RE,@0X06			; set lcd display enable
;---Clear CALLID RAM
	CIDBANK	0
	CALL	CLR_LCD_RAM
	CIDBANK	1
	CALL	CLR_LCD_RAM
	CIDBANK	2
	CALL	CLR_LCD_RAM
	CIDBANK	3
	CALL	CLR_LCD_RAM
;---Clear DATA RAM
	BANK	0
	CALL	CLR_REG
	BANK	1
	CALL	CLR_REG
	BANK	2
	CALL	CLR_REG
	BANK	3
	CALL	CLR_REG
	BANK	0
; --------------------
	
	IOW	_IOC5,@0X0F
	MOV	A,@(0X00)
	IOW	_IOC6
	IOW	_IOC8
	IOW	_IOC9
;	
	;IOW	_IOCA,@0XF0			; port7 as normal port, set p5,p6,p9 for lcd
	IOW	_IOCA,@0XFA
	BS	_RB,6
	BS	_RB,7				; set p8 for lcd
	
	IOW	_IOC7,@0XF9
	MOV	_R7,@0XFF			; p7.5 = 1
	
	BS	_RE,3				; set /WURING enable
	
	PAGEIO	1
	IOW	_IOCE,@0X0E			; counter1 prescaler 1:64
	IOW	_IOCB,@0X80			; count1(0.5s) <==> 2^15/(0xff-0x80+1)/64=2^
	IOW	_IOCC,@0X0			; count2(0.5ms)<==> 2^15/(0xff+1)=.2^7
	;IOW	_IOCD,@0XFF
	PAGEIO	0

; ---------- dtmf open -----------
	BS	_PPSR,3				; open the PWDN to receive the dtmf data
	BC	_RB,4
	BC	_RB,5				; tone detection present time 5ms
	
	BC	_STATUS,5			; close the tone genarater1
	BC	_STATUS,6			; close the tone genarater2
; ---------- fsk open ------------
	BS	_FSR,3				; /FSKPWR = 1
	
	IOW	_IOCF,@0XB0			; DTMF,CONT2,CONT1  ENABLE. fsk disable
	CLR	_ISR
	;CLR	FSK_FG
	;CLR	SYS_FG
	;CLR	STAMP_FG
	
	MOV	A,@2
	CONTW
; ---------- INFO INIT ------------
	BANK	0
;---Set contrast
	MOV	LCD_CONTRAST,@0X03		; LCD对比度3，
	MOV	A,LCD_CONTRAST
	CALL	LCD_CONTRAST_APPLY

; ---------- time init ------------
	BANK	1
	CLR	SEC_REG
	CLR	MIN_REG
	CLR	HOUR_REG
	CLR	WEEK_REG
	MOV	DAY_REG,@1
	MOV	MON_REG,@1
	CLR	YEAR_REG

	CALL	#BLANK_LCD

	CIDBANK	0
	;MOV	_RC,@LCD_CTRL
	;MOV	_RD,@0X80
	;PAGE	#VGA_STAMP
	
	;CALL	CLR_STAMP
	;CALL	CLR_NUM1
	;CALL	CLR_NUM2
	;CALL	CLR_STR
	
	
	
	
	
	
	
	
	;PAGE	#($)
	;CALL	#VIEW_STR
	
	;BS	STAMP_FG,STAMP_SLASH		; 日期之间的斜杠，固定亮。
	;BS	SYS_FG,STAMP
	;BS	SYS_FG,SYS_CLOCK
	;BC	SYS_FG,LOCK_TOPLINE
	
	ENI
	;MOV	TMR_DELAY,@250
	;CALL	WAIT_FLASH
	
	
	BANK	1

	RET
;-------------------------------------------------------------------------------
CLR_LCD_RAM:
	CLR	TEMP0
CLR_LCD_RAM_LOOP:
	MOV	_RC,TEMP0
	CLR	_RD
	INC	TEMP0
	SUBA	TEMP0,@0XFF
	JPNZ	CLR_LCD_RAM_LOOP
	MOV	_RC,TEMP0
	CLR	_RD
	RET
;-------------------------------------------------------------------------------
CLR_REG:
	AND	_RSR,@0XC0
	ADD	_RSR,@0X0F	;Note! You clear register from 0x10 to 0x3f
CLR_REG_LOOP:
	INC	_RSR
	CLR	_R0
	ANDA	_RSR,@0X3F
	SUB	A,@0X3F
	JPNZ	CLR_REG_LOOP
	RET
;-------------------------------------------------------------------------------
BLANK_LCD:
	MOV	TEMP0,@0
BLANK_LCD_LOOP:
	MOV	A,TEMP0
	IOW	_IOCB
	MOV	A,@0
	IOW	_IOCC
	INC	TEMP0
	SUBA	TEMP0,@0X28
	JPNZ	BLANK_LCD_LOOP1
	MOV	TEMP0,@0X40
BLANK_LCD_LOOP1:
	SUBA	TEMP0,@0X68
	JPNZ	BLANK_LCD_LOOP
	
	RET

;-------------------------------------------------------------------------------
;LCD对比度
;-------------------------------------------------------------------------------
LCD_CONTRAST_APPLY:
	
	AND	A,@0X0F
;	ADD	A,@2				; OTP
	ADD	A,@0XFF				; 仿真
	MOV	TEMP0,A
	CLRC
	RLC	TEMP0
	IOR	_IOCA
	AND	A,@0XF1
	ADD	A,TEMP0
	IOW	_IOCA
	
	RET

;-------------------------------------------------------------------------------