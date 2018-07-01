ORG	0x1000

SerMessager:
	MOV	A,sys_msg
	JPNZ	SerMessager_ret
	BANK	0
	CALL	SerPower
	JPNZ	SerMessager_ret
	CALL	SerCommand
	JPNZ	SerMessager_ret
	JPB	sys_flagext,DSPSTATUS,SerMessager_none
	CALL	SerHandset
	JPNZ	SerMessager_ret
	JPB	r0_tmr_timer,4,SerMessager_timer
	CALL	SerKeyCheck
	JPNZ	SerMessager_ret
SerMessager_timer:
	CALL	SerTimer
	JPNZ	SerMessager_ret
SerMessager_none:
	CLR	sys_data
	CLR	sys_msg
SerMessager_ret:
	MOV	A,sys_msg
	RET

SerPower:
	XORA	hardware,_P7
	MOV	ax,A
	JPB	ax,6,SerHardWare_power
	JMP	SerMessager_none

SerHandset:
	XORA	hardware,_P7
	MOV	ax,A
	JPB	ax,7,SerHardWare_handset
	JMP	SerMessager_none

/*
SerHardWare:
	XORA	hardware,_P7
	MOV	ax,A
	JPB	ax,6,SerHardWare_power
	JPB	ax,7,SerHardWare_handset
	CLR	sys_msg
	JMP	SerMessager_ret
*/
SerHardWare_power:
	XOR	hardware,@(1<<6)
	JPNB	hardware,6,SerHardWare_power_down
SerHardWare_power_up:
	MOV	A,@(POWER_ON)
	JMP	SerHardWare_power_ret
SerHardWare_power_down:
	MOV	A,@(POWER_DOWN)
SerHardWare_power_ret:
	MOV	sys_data,A
	MOV	sys_msg,@(WM_POWER)
	JMP	SerMessager_ret
SerHardWare_handset:
	XOR	hardware,@(1<<7)
	JPNB	hardware,7,SerHardWare_handset_off
SerHardWare_handset_on:
	MOV	A,@(HANDSET_ON)
	JMP	SerHardWare_handset_ret
SerHardWare_handset_off:
	MOV	A,@(HANDSET_OFF)
SerHardWare_handset_ret:
	MOV	sys_data,A
	MOV	sys_msg,@(WM_HANDSET)
	JMP	SerMessager_ret

/*
SerCommand:
	BLOCK	4
	CLR	sys_msg
SerCommand_1:
	MOV	_RC,@(128)
	MOV	A,_RD
	JPZ	SerCommand_ret
	MOV	cnt,A
	INC	_RC
	MOV	A,_RD
	;LCALL	LibCommandValidLength
	;ADD	A,@(0)
	JPNZ	SerCommand_valid
	DEC	cnt
	MOV	ax,@(128+2)
	MOV	bx,@(128+1)
	LCALL	LibCopyRam
	DEC	_RC
	DEC	_RD
	JMP	SerCommand_1
SerCommand_valid:
	MOV	exb,A
	SUBA	cnt,exb
	JPNC	SerCommand_error
	MOV	_RC,@(128+2)
	MOV	sys_data,_RD
	MOV	sys_msg,@(WM_COMMAND)
	
	MOV	cnt,exb
	MOV	ax,@(128+2)
	MOV	bx,@(63)
	LCALL	LibCopyRam
	INC	exb
	MOV	_RC,@(128)
	SUB	_RD,exb
	MOV	cnt,_RD
	ADDA	exb,@(128+1)
	MOV	ax,A
	MOV	bx,@(128+1)
	LCALL	LibCopyRam
	
SerCommand_ret:
	JMP	SerMessager_ret

SerCommand_error:
	MOV	_RC,@(128)
	MOV	cnt,A
	CLR	ax
	LCALL	LibClearRam
	JMP	SerMessager_ret
*/

SerCommand:
	BLOCK	4
	CLR	sys_msg
SerCommand_1:
	MOV	_RC,@(128)
	MOV	A,_RD
	JPZ	SerCommand_ret
	MOV	cnt,A
	INC	_RC
	MOV	A,_RD
	LCALL	IicCommandLength
	/*
	ADD	A,@(0)
	JPNZ	SerCommand_valid
	DEC	cnt
	MOV	ax,@(128+2)
	MOV	bx,@(128+1)
	LCALL	LibCopyRam
	DEC	_RC
	DEC	_RD
	JMP	SerCommand_1
	*/
SerCommand_valid:
	MOV	exb,A
	SUBA	cnt,exb
	JPNC	SerCommand_ret
	MOV	_RC,@(128+1)
	MOV	sys_data,_RD
	MOV	sys_msg,@(WM_COMMAND)
	
	MOV	cnt,exb
	MOV	ax,@(128+1)
	MOV	bx,@(63)
	LCALL	LibCopyRam
	MOV	_RC,@(128)
	SUB	_RD,exb
	MOV	cnt,_RD
	ADDA	exb,@(128+1)
	MOV	ax,A
	MOV	bx,@(128+1)
	LCALL	LibCopyRam
	
SerCommand_ret:
	JMP	SerMessager_ret
	


SerTimer:
	MOV	A,r0_tmr_timer
	JPZ	SerTimer_none
	MOV	sys_data,A
	SUB	r0_tmr_timer,sys_data
	MOV	sys_msg,@(WM_TIME)
	JMP	SerTimer_ret
SerTimer_none:
	CLR	sys_msg
SerTimer_ret:
	JMP	SerMessager_ret

SerKeyCheck:
	MOV	_RSR,@(r0_key1_dealed)
	MOV	ax,r0_key1
	MOV	exa,@(0xff)
	CALL	SerKey
	JPNZ	SerKeyCheck_1
	MOV	_RSR,@(r0_key2_dealed)
	MOV	ax,r0_key2
	MOV	exa,@(0xff)
	CALL	SerKey
	JPNZ	SerKeyCheck_2
	MOV	_RSR,@(r0_key3_dealed)
	MOV	ax,r0_key3
	MOV	exa,@(0xff)
	CALL	SerKey
	JPNZ	SerKeyCheck_3
	MOV	_RSR,@(r0_key4_dealed)
	MOV	ax,r0_key4
	MOV	exa,@(0x01)
	CALL	SerKey
	JPNZ	SerKeyCheck_4
	JMP	SerKeyCheck_none
SerKeyCheck_1:
	JMP	SerKeyCheck_ret
SerKeyCheck_2:
	ADD	sys_data,@(0x10)
	JMP	SerKeyCheck_ret
SerKeyCheck_3:
	ADD	sys_data,@(0x20)
	JMP	SerKeyCheck_ret
SerKeyCheck_4:
	ADD	sys_data,@(0x30)
	JMP	SerKeyCheck_ret
SerKeyCheck_none:
	CLR	sys_msg
SerKeyCheck_ret:
	JMP	SerMessager_ret

SerKey:
	XORA	_R0,ax
	AND	A,exa
	JPZ	SerKey_none
	MOV	ax,A
	
	CLR	cnt
SerKey_loop:
	JPB	cnt,3,SerKey_none
	RRC	ax
	JPC	SerKey_1
	INC	cnt
	JMP	SerKey_loop
SerKey_1:
	MOV	sys_data,cnt
	LCALL	TabSetBit
	MOV	ax,A
	XOR	_R0,A
	ANDA	_R0,ax
	JPNZ	SerKey_release
SerKey_press:
	MOV	sys_msg,@(WM_KEYPRESS)
	JMP	SerKey_ret
SerKey_release:
	MOV	sys_msg,@(WM_KEYRELEASE)
	JMP	SerKey_ret
SerKey_none:
	MOV	sys_msg,@(WM_NONE)
SerKey_ret:
	JMP	SerMessager_ret


SerIntKeyScan:
	AND	_RE,@(0xfb)			; blank LCD
	IOR	_IOCE
	AND	A,@(0xdf)
	IOW	_IOCE
	
	BS	_P8,6
	
	BC	_STATUS,C
	MOV	r0_int_ax,@(0xff)
	ANDA	r0_tmr,@(0x07)
	TBL
	RRC	r0_int_ax
	RRC	r0_int_ax
	RRC	r0_int_ax
	RRC	r0_int_ax
	RRC	r0_int_ax
	RRC	r0_int_ax
	RRC	r0_int_ax
	RRCA	r0_int_ax
	IOW	_IOC6
	MOV	_R6,A
	RET

SerIntKeyRead:
	MOV	r0_int_ax,@(r0_key1_get-1)
	RRCA	r0_tmr
	AND	A,@(0x03)
	TBL
	INC	r0_int_ax
	INC	r0_int_ax
	INC	r0_int_ax
	INC	r0_int_ax
	MOV	_RSR,r0_int_ax
	JPB	r0_tmr,0,SerIntKeyRead_l
SerIntKeyRead_h:
	AND	_R0,@(0x0f)
	SWAPA	_R7
	AND	A,@(0xf0)
	JMP	SerIntKeyRead_1
SerIntKeyRead_l:
	AND	_R0,@(0xf0)
	ANDA	_R7,@(0x0f)
SerIntKeyRead_1:
	OR	_R0,A
	IOW	_IOC6,@(0xff)
	
	BC	_P8,6
	
	IOR	_IOCE
	OR	A,@(0x20)
	IOW	_IOCE
	OR	_RE,@(0x06)			; open LCD
	
	RET

SerIntKeyProtect:
	XORA	r0_key1_get,r0_key1_bak
	AND	A,@(0xff)
	JPNZ	SerIntKeyProtect_newkey
	XORA	r0_key2_get,r0_key2_bak
	AND	A,@(0xff)
	JPNZ	SerIntKeyProtect_newkey
	XORA	r0_key3_get,r0_key3_bak
	AND	A,@(0xff)
	JPNZ	SerIntKeyProtect_newkey
	XORA	r0_key4_get,r0_key4_bak
	AND	A,@(0x01)
	JPNZ	SerIntKeyProtect_newkey
	MOV	A,r0_tmr_key
	JPZ	SerIntKeyProtect_end
	DEC	r0_tmr_key
	MOV	A,r0_tmr_key
	JPNZ	SerIntKeyProtect_end
	MOV	r0_key1,r0_key1_bak
	MOV	r0_key2,r0_key2_bak
	MOV	r0_key3,r0_key3_bak
	MOV	r0_key4,r0_key4_bak
	JMP	SerIntKeyProtect_end
SerIntKeyProtect_newkey:
	MOV	r0_key1_bak,r0_key1_get
	MOV	r0_key2_bak,r0_key2_get
	MOV	r0_key3_bak,r0_key3_get
	MOV	r0_key4_bak,r0_key4_get
	MOV	r0_tmr_key,@(50)
SerIntKeyProtect_end:
	RET

SerIntTimer:
	INC	r0_tmr_unit
	SUBA	r0_tmr_unit,@(TIME_UNIT)
	JPNC	SerIntTimer_end
	MOV	r0_tmr_unit,A
	INC	r0_tmr_timer
SerIntTimer_end:
	RET


SerIntDialNumber:
	RET

; 时钟
SerClock:
	BANK	1
	JPNB	r1_rtc_flag,7,SerClock_ret
	BC	r1_rtc_flag,7
	DISI
	SWAPA	r1_rtc_tmr
	AND	A,@(0x0f)
	ADD	r1_rtc_second,A
	AND	r1_rtc_tmr,@(0x0f)
	ENI
	BS	r1_rtc_flag,0
	SUBA	r1_rtc_second,@(60)
	JPNC	SerClock_ret
	SUB	r1_rtc_second,@(60)
	BS	r1_rtc_flag,1
	INC	r1_rtc_minute
	SUBA	r1_rtc_minute,@(60)
	JPNC	SerClock_ret
	CLR	r1_rtc_minute
	BS	r1_rtc_flag,2
	INC	r1_rtc_hour
	SUBA	r1_rtc_hour,@(24)
	JPNC	SerClock_ret
	CLR	r1_rtc_hour
	BS	r1_rtc_flag,3
	BS	hardware,SYNCCLOCK		; 时钟同步
	INC	r1_rtc_week
	SUBA	r1_rtc_week,@(7)
	JPNC	$+2
	CLR	r1_rtc_week
	INC	r1_rtc_day
	DECA	r1_rtc_month
	LCALL	TabMonth
	MOV	ax,A
	SUBA	r1_rtc_month,@(2)
	JPNZ	SerClock_1
	ANDA	r1_rtc_year,@(0x03)
	JPNZ	SerClock_normal
	MOV	A,r1_rtc_year
	JPNZ	SerClock_leap
	ANDA	r1_rtc_century,@(0x03)
	JPNZ	SerClock_normal
SerClock_leap:
	INC	ax
SerClock_normal:
SerClock_1:
	SUBA	r1_rtc_day,ax
	JPNC	SerClock_ret
	MOV	r1_rtc_day,@(1)
	BS	r1_rtc_flag,4
	INC	r1_rtc_month
	SUBA	r1_rtc_month,@(13)
	JPNC	SerClock_ret
	MOV	r1_rtc_month,@(1)
	BS	r1_rtc_flag,5
	INC	r1_rtc_year
	SUBA	r1_rtc_year,@(100)
	JPNC	SerClock_ret
	CLR	r1_rtc_year
	INC	r1_rtc_century
	SUBA	r1_rtc_century,@(100)
	JPNC	SerClock_ret
	CLR	r1_rtc_century
SerClock_ret:
	RETL	@(0)

SerServer:
	CALL	SerSync				; 同步
	CALL	SerClockUpdate
	CALL	SerBackLight			; 背光灯
	CALL	SerDspCheck			; 处理DSP的相关命令
	CALL	SerStamp
	RETL	@(0)

SerSync:
	XORA	sys_msg,@(WM_COMMAND)
	JPZ	SerSync_ret
	JPB	hardware,SYNCCLOCK,SerSync_clock
	JPB	hardware,SYNCSETTING,SerSync_setting
SerSync_ret:
	RETL	@(0)
SerSync_clock:
	BANK	1
	PAGE	#(IIC)
	MOV	A,@(0x40)
	CALL	IicSendData
	MOV	A,r1_rtc_century
	CALL	IicSendData
	MOV	A,r1_rtc_year
	CALL	IicSendData
	MOV	A,r1_rtc_month
	CALL	IicSendData
	MOV	A,r1_rtc_day
	CALL	IicSendData
	MOV	A,r1_rtc_hour
	CALL	IicSendData
	MOV	A,r1_rtc_minute
	CALL	IicSendData
	MOV	A,r1_rtc_second
	CALL	IicSendData
	MOV	A,r1_rtc_week
	CALL	IicSendData
	CALL	IicSer
	PAGE	#($)
	BC	hardware,SYNCCLOCK
	JMP	SerSync_ret
SerSync_setting:
	BANK	3
	PAGE	#(IIC)
	BANK	3
	MOV	A,@(0x7f)
	CALL	IicSendData
	MOV	A,r3_remotecode1
	CALL	IicSendData
	MOV	A,r3_remotecode2
	CALL	IicSendData
	MOV	A,r3_areacode1
	CALL	IicSendData
	MOV	A,r3_areacode2
	CALL	IicSendData
	MOV	A,r3_contrast
	CALL	IicSendData
	MOV	A,r3_language
	CALL	IicSendData
	MOV	A,r3_ringmelody
	CALL	IicSendData
	MOV	A,r3_ringvolume
	CALL	IicSendData
	MOV	A,r3_ringdelay
	CALL	IicSendData
	MOV	A,r3_rate
	CALL	IicSendData
	MOV	A,r3_flashtime
	CALL	IicSendData
	MOV	A,r3_pausetime
	CALL	IicSendData
	MOV	A,r3_ogm
	CALL	IicSendData
	CALL	IicSer
	PAGE	#($)
	BC	hardware,SYNCSETTING
	JMP	SerSync_ret

SerClockUpdate:
	BANK	1
	JPNB	r1_rtc_flag,1,SerClockUpdate_ret
	BC	r1_rtc_flag,1

	MOV	A,@(STYLE_LEFT)
	LCALL	VgaNum1
	MOV	ax,r1_rtc_hour
	JPB	sys_flag,TIMEFORMAT,SerClockUpdate_1
	MOV	A,r1_rtc_hour
	JPNZ	$+4
	MOV	ax,@(12)
	JMP	SerClockUpdate_1
	SUBA	ax,@(13)
	JPNC	SerClockUpdate_1
	SUB	ax,@(12)
SerClockUpdate_1:
	MOV	A,ax
	CALL	UpdateClock
	MOV	A,r1_rtc_minute
	CALL	UpdateClock
	MOV	A,r1_rtc_month
	CALL	UpdateClock
	MOV	A,r1_rtc_day
	CALL	UpdateClock
	PAGE	#(VGA)
	MOV	A,@(0x00)
	CALL	VgaNum1
	CALL	VgaDrawNum1
	PAGE	#($)
	
	MOV	ax,r1_rtc_hour
	BANK	2
	
	AND	r2_stamp1,@(0xc3)
	JPB	sys_flag,TIMEFORMAT,SerClockUpdate_2
	SUBA	ax,@(12)
	JPC	SerClockUpdate_pm
SerClockUpdate_am:
	BS	r2_stamp1,5
	JMP	SerClockUpdate_2
SerClockUpdate_pm:
	BS	r2_stamp1,4
	JMP	SerClockUpdate_2
SerClockUpdate_2:
	BS	r2_stamp1,3
	BS	r2_stamp1,2
	BS	sys_flag,STAMP
SerClockUpdate_ret:
	RETL	@(0)

UpdateClock:
	MOV	ax,A
	LCALL	LibMathHexToBcd
	MOV	r1_rtc_temp,ax
	PAGE	#(VGA)
	SWAPA	r1_rtc_temp
	AND	A,@(0x0f)
	ADD	A,@(48)
	CALL	VgaNum1
	ANDA	r1_rtc_temp,@(0x0f)
	ADD	A,@(48)
	CALL	VgaNum1
	PAGE	#($)
	RETL	@(0)



SerBackLight:
	JPNB	hardware,POWERSTATUS,SerBackLight_off
	XORA	sys_msg,@(WM_POWER)
	JPZ	SerBackLight_power
	XORA	sys_msg,@(WM_KEYPRESS)
	JPZ	SerBackLight_on
	XORA	sys_msg,@(WM_COMMAND)
	JPZ	SerBackLight_command
	XORA	sys_msg,@(WM_HANDSET)
	JPZ	SerBackLight_on
	JPNB	_R9,0,SerBackLight_ret
	XORA	sys_msg,@(WM_TIME)
	JPNZ	SerBackLight_ret
	BANK	2
	ADD	r2_tmr_blight,sys_data
SerBackLight_1:
	SUBA	r2_tmr_blight,@(100)
	JPNC	SerBackLight_2
	MOV	r2_tmr_blight,A
	INC	r2_tmr_blight1
	JMP	SerBackLight_1
SerBackLight_2:
	SUBA	r2_tmr_blight1,@(20)
	JPNC	SerBackLight_ret
SerBackLight_off:
	BC	_R9,0
	JMP	SerBackLight_ret

SerBackLight_power:
	XORA	sys_data,@(POWER_ON)
	JPZ	SerBackLight_on
	JMP	SerBackLight_off

SerBackLight_command:
	XORA	sys_data,@(0x19)
	JPZ	SerBackLight_on
	XORA	sys_data,@(0x1a)
	JPZ	SerBackLight_command_1
	RETL	@(0)
SerBackLight_command_1:
	MOV	A,@(1)
	LCALL	LibGetCommand
	ADD	A,@(0)
	JPZ	SerBackLight_on
	RETL	@(0)

SerBackLight_on:
	BS	_R9,0
	BANK	2
	CLR	r2_tmr_blight
	CLR	r2_tmr_blight1
	
SerBackLight_ret:
	RETL	@(0)

SerDspCheck:
	XORA	sys_msg,@(WM_HANDSET)
	JPZ	SerDspCheck_handset
	XORA	sys_msg,@(WM_POWER)
	JPZ	SerDspCheck_power
	XORA	sys_msg,@(WM_COMMAND)
	JPZ	SerDspCheck_command
SerDspCheck_ret:
	RETL	@(0)
SerDspCheck_handset:
	PAGE	#(IIC)
	MOV	A,@(0x51)
	CALL	IicSendData
	MOV	A,sys_data
	CALL	IicSendData
	CALL	IicSer
	PAGE	#($)
	RETL	@(0)
SerDspCheck_power:
	XORA	sys_data,@(POWER_ON)
	JPZ	SerDspCheck_power_on
	BC	_P9,6
	BC	hardware,DTAMPOWER
	RET
SerDspCheck_power_on:
	BS	_P9,6
	RETL	@(0)

SerDspCheck_command:
	SUBA	sys_data,@(0x07)
	JPC	SerDspCheck_command_1
	MOV	A,sys_data
	CALL	SerDspCheckTabInfo
	MOV	_RSR,A
	MOV	A,@(1)
	LCALL	LibGetCommand
	MOV	_R0,A
	
	SUBA	sys_data,@(0x04)
	JPNZ	SerDspCheck_command_1
	MOV	A,r3_newcall
	JPZ	$+2
	MOV	A,@(0x80)
	BANK	2
	ADD	A,@(0x40)
	MOV	r2_led_newcall,A
	RETL	@(0)
SerDspCheck_command_1:
	XORA	sys_data,@(0x1c)
	JPZ	SerDspCheck_status
	BC	sys_flagext,DSPSTATUS
	XORA	sys_data,@(0x1a)
	JPZ	SerDspCheck_caller
	XORA	sys_data,@(0x3f)
	JPZ	SerDspCheck_reset
	XORA	sys_data,@(0x40)
	JPZ	SerDspCheck_time
	XORA	sys_data,@(0x7f)
	JPZ	SerDspCheck_set
	XORA	sys_data,@(0x80)
	JPZ	SerDspCheck_cid
	RETL	@(0)
SerDspCheck_status:
	MOV	A,@(1)
	LCALL	LibGetCommand
	JPZ	SerDspCheck_status_idle
	BS	sys_flagext,DSPSTATUS
	;BS	sys_flag,PROGRAMREIN
	RETL	@(0)
SerDspCheck_status_idle:
	BC	sys_flagext,DSPSTATUS
	RETL	@(0)
SerDspCheck_caller:
	MOV	A,@(1)
	LCALL	LibGetCommand
	MOV	ax,A
	JPZ	SerDspCheck_ret
	SUBA	ax,@(0x04)
	JPZ	SerDspCheck_ret
SerDspCheck_memory:
	LCALL	AppCallerToEditor
	MOV	A,@(1)
	LCALL	LibGetCommand
	LCALL	AppEditorToMemory
	LCALL	LibClearEditor
	RETL	@(0)
SerDspCheck_reset:
	BS	hardware,SYNCCLOCK		; 时钟同步
	BS	hardware,DTAMPOWER
	RETL	@(0)

SerDspCheck_time:
	MOV	cnt,@(8)
	MOV	ax,@(64)
	MOV	bx,@(0)
SerDspCheck_time_loop:
	DEC	cnt
	BLOCK	4
	ADDA	ax,cnt
	MOV	_RC,A
	MOV	exa,_RD
	BLOCK	1
	ADDA	bx,cnt
	MOV	_RC,A
	MOV	_RD,exa
	MOV	A,cnt
	JPNZ	SerDspCheck_time_loop
	RETL	@(0)
SerDspCheck_cid:
	MOV	cnt,@(58)
	MOV	ax,@(64)
	MOV	bx,@(8)
	JMP	SerDspCheck_time_loop
SerDspCheck_set:
	CLR	cnt
SerDspCheck_set_loop:
	ADDA	cnt,@(1)
	LCALL	LibGetCommand
	MOV	ax,A
	
	MOV	A,cnt
	CALL	SetDspCheckTabSet
	MOV	_RSR,A
	MOV	_R0,ax
	INC	cnt
	SUBA	cnt,@(13)
	JPNC	SerDspCheck_set_loop
	MOV	A,r3_contrast
	LCALL	LibLcdContrast
	RETL	@(0)


SerStamp:
	JPNB	sys_flag,STAMP,SerStamp_ret
	BC	sys_flag,STAMP
	PAGE	#(VGA)
	BANK	2
	MOV	A,r2_stamp1
	CALL	VgaStamp1
	MOV	A,r2_stamp2
	CALL	VgaStamp2
	MOV	A,r2_stamp3
	CALL	VgaStamp3
	MOV	A,@(0)
	CALL	VgaDraw
	PAGE	#($)
SerStamp_ret:
	RETL	@(0)

SetDspCheckTabSet:
	TBL
	RETL	@(r3_remotecode1+0xc0)
	RETL	@(r3_remotecode2+0xc0)
	RETL	@(r3_areacode1+0xc0)
	RETL	@(r3_areacode2+0xc0)
	RETL	@(r3_contrast+0xc0)
	RETL	@(r3_language+0xc0)
	RETL	@(r3_ringmelody+0xc0)
	RETL	@(r3_ringvolume+0xc0)
	RETL	@(r3_ringdelay+0xc0)
	RETL	@(r3_rate+0xc0)
	RETL	@(r3_flashtime+0xc0)
	RETL	@(r3_pausetime+0xc0)
	RETL	@(r3_ogm+0xc0)
SerDspCheckTabInfo:
	TBL
	RETL	@(0x00)
	RETL	@(r3_newmsg+0xc0)
	RETL	@(r3_totalmsg+0xc0)
	RETL	@(r3_book+0xc0)
	RETL	@(r3_newcall+0xc0)
	RETL	@(r3_totalcall+0xc0)
	RETL	@(r3_dialedcall+0xc0)


