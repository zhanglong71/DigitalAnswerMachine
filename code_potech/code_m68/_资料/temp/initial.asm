
Initial:
	MOV	_FSR,@(0x70)
	DISI
	WDTC
	CLR	_STATUS
	CLR	_RSR
	
	CALL	InitReg
	CALL	InitRam
	CALL	InitPort
	CALL	InitIntermit
	CALL	InitData
	CALL	InitLcd
	
	MOV	_RF,@(0x00)
	RETI

InitRam:
	CLR	cnt
InitRam_loop:
	RLCA	cnt
	AND	A,@(0x1e)
	ADD	A,@(VALUE_IOCA)
	IOW	_IOCA
	CLR	_RC
InitRam_loop1:
	CLR	_RD
	DEC	_RC
	JPNZ	InitRam_loop1
	INC	cnt
	SUBA	cnt,@(10)
	JPNZ	InitRam_loop
	BLOCK	0
	RET

InitReg:
	MOV	_RSR,@(0x10)
InitReg_loop:
	CLR	_R0
	INC	_RSR
	SUBA	_RSR,@(0x20)
	JPNZ	InitReg_loop
InitReg_loop1:
	CLR	_R0
	INC	_RSR
	ANDA	_RSR,@(0x1f)
	JPNZ	InitReg_loop1
	MOV	A,_RSR
	JPZ	InitReg_ret
	ADD	_RSR,@(0x20)
	JMP	InitReg_loop1
InitReg_ret:
	RET

InitPort:
	IOW	_IOCA,@(0x40)		; p8L for segment prot, p8H for normal IO port, block 0
	IOW	_IOCE,@(0x3c)		; p9 for normal IO prot, P6 for common port, Lcd contrast
	IOW	_IOC6,@(0xff)		; p6 for input
	IOW	_IOC7,@(0xcf)
	IOW	_IOC8,@(0xb0)
	IOW	_IOC9,@(0x00)
	MOV	_P7,@(0xff)
	MOV	_P8,@(0x00)
	MOV	_P9,@(0x02)
	IOW	_IOCD,@(0x00)
	RET

InitIntermit:
	BS	_STATUS,PG
	IOW	_IOCB,@(0x00)
	IOW	_IOCC,@(0xdf)
	IOW	_IOCE,@(0x0C)
	BC	_STATUS,PG
	MOV	A,@(0x25)
	CONTW
	MOV	_TCC,@(0x00)
	IOW	_IOCF,@(0x71)
	RET

InitData:
	MOV	hardware,@(0x80)
	BANK	1
	CLR	r1_rtc_second
	MOV	r1_rtc_minute,@(DEFAULT_minute)
	MOV	r1_rtc_hour,@(DEFAULT_hour)
	MOV	r1_rtc_day,@(DEFAULT_day)
	MOV	r1_day,A
	MOV	r1_rtc_month,@(DEFAULT_month)
	MOV	r1_month,A
	MOV	r1_rtc_year,@(DEFAULT_year)
	MOV	r1_year,A
	MOV	r1_rtc_century,@(DEFAULT_century)
	MOV	r1_century,A
	LCALL	LibWeekCheck
	MOV	r1_rtc_week,A

	LCALL	LibDefaultSetting

	BLOCK	4
	CLR	_RC
	MOV	_RD,@(0x41)
	RET

InitLcd:
	MOV	_RE,@(0x00)
	MOV	_RE,@(0x02)
	MOV	_RE,@(0x06)
	;OR	_RE,@(0x06)
	BANK	3
	MOV	A,r3_contrast
	PAGE	#(LibLcdContrast)
	CALL	LibLcdContrast
	
	PAGE	#(VgaBlank)
	MOV	A,@(0)
	CALL	VgaBlank
	MOV	A,@(1)
	CALL	VgaBlank
	MOV	A,@(2)
	CALL	VgaBlank
	MOV	A,@(3)
	CALL	VgaBlank
	PAGE	#($)

InitLcd_blank:
	CLR	cnt
InitLcd_blank_loop:
	IOW	_IOCB,cnt
	IOW	_IOCC,@(0x00)
	INC	cnt
	SUBA	cnt,@(128)
	JPNZ	InitLcd_blank_loop
/*
InitLcd_test:	
	MOV	cnt,@(0x00)
InitLcd_test_loop:
	IOW	_IOCB,cnt
	IOW	_IOCC,@(0x01)
	INC	cnt
	SUBA	cnt,@(0x80)
	JPNZ	InitLcd_test_loop
*/

/*
	IOW	_IOCB,@(10)
	IOW	_IOCC,@(0xff)
	IOW	_IOCB,@(0x40+10)
	IOW	_IOCC,@(0xff)

	IOW	_IOCB,@(18)
	IOW	_IOCC,@(0xff)
	IOW	_IOCB,@(0x40+18)
	IOW	_IOCC,@(0xff)

	IOW	_IOCB,@(28)
	IOW	_IOCC,@(0xff)
	IOW	_IOCB,@(0x40+28)
	IOW	_IOCC,@(0xff)
*/
	RET

