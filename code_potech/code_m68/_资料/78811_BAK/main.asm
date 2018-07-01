
/*************************************************
	main.asm

Creator:	范学明 (mail.fxming@163.com)
Date:		2007.9.19

*************************************************/

INCLUDE	"emc78811.inc"
INCLUDE	"main.inc"
INCLUDE	"application.inc"
INCLUDE	"string.inc"
INCLUDE	"config.inc"


ORG	0x0000
	JMP	main

ORG	0x0008

IntBegin:
	DISI
	MOV	int_acc,A
	SWAP	int_acc
	MOV	int_status,_STATUS
	MOV	int_rsr,_RSR
	CLR	_STATUS
	CLR	_RSR				; set bank0, and indirect address=0
	MOV	r0_int_ppsr,_PPSR
	MOV	r0_int_addr,_ADDR
	IOR	_IOCA
	AND	A,@(0x1e)
	MOV	r0_int_block,A
	
	PAGE	0
	
	JPB	_ISR,1,Int_0
	JPB	_ISR,2,Int_1
	JPB	_ISR,3,Int_2
	JPB	_ISR,7,Int_3
	JPB	_ISR,6,IntFsk
	JPB	_ISR,0,IntTcc
	JPB	_ISR,5,IntCnt2			; 1ms
	JPB	_ISR,4,IntCnt1			; 用作时钟计时

IntEnd:
	BANK	0
	IOR	_IOCA
	AND	A,@(0xe1)
	OR	A,r0_int_block
	IOW	_IOCA
	MOV	_ADDR,r0_int_addr
	MOV	_PPSR,r0_int_ppsr
	MOV	_RSR,int_rsr
	MOV	_STATUS,int_status
	SWAPA	int_acc
	RETI

Int_0:
	BC	_ISR,1
	JMP	IntEnd

Int_1:
	BC	_ISR,2
	JMP	IntEnd

Int_2:
	BC	_ISR,3
	JMP	IntEnd

Int_3:
	BC	_ISR,7
	JMP	IntEnd



IntTcc:
	BC	_ISR,0
	JMP	IntEnd

IntCnt1:			; (1/16s)
	BC	_ISR,4
	BANK	1
	INC	r1_rtc_tmr
IntFlash:
	ANDA	r1_rtc_tmr,@(0x07)
	JPNZ	IntFlash_ret
	BLOCK	0
	MOV	_RC,@(128)
	BS	_RD,3
IntFlash_ret:
IntClock:
	ANDA	r1_rtc_tmr,@(0x0f)
	JPNZ	IntEnd
	BS	r1_rtc_flag,7
	JMP	IntEnd

IntCnt2:			; (1ms)
	BC	_ISR,5
	
	BS	_STATUS,PG
	IOW	_IOCC,@(0xdf)
	BC	_STATUS,PG
	
	INC	r0_tmr

	PAGE	#(SerIntKeyScan)
	CALL	SerIntKeyScan
	CALL	SerIntKeyProtect
	CALL	SerIntTimer
	CALL	SerIntKeyRead
	PAGE	#($)

	ANDA	r0_tmr,@(0x03)
	JPNZ	IntCnt2_4ms_end
IntCnt2_4ms:
	MOV	A,tmr_cursor
	JPZ	$+2
	DEC	tmr_cursor
	
	BANK	2
	MOV	A,r2_tmr_dial
	JPNZ	$+5
	MOV	A,r2_tmr_dial1
	JPZ	$+3
	DEC	r2_tmr_dial1
	DEC	r2_tmr_dial

IntCnt2_newcall:
	JPNB	r2_led_newcall,6,IntCnt2_newcall_1
	BC	r2_led_newcall,6
	JMP	IntCnt2_newcall_off
IntCnt2_newcall_1:
	JPNB	r2_led_newcall,7,IntCnt2_newcall_end
	DEC	r2_tmr_newcall
	JPNZ	IntCnt2_newcall_end
	INC	r2_led_newcall
	ANDA	r2_led_newcall,@(0x0f)
	SUB	A,@(3)
	JPNC	IntCnt2_newcall_on

IntCnt2_newcall_off:
	BS	_P9,1
	MOV	r2_tmr_newcall,@(250)
	JMP	IntCnt2_newcall_end
IntCnt2_newcall_on:
	BC	_P9,1
	MOV	r2_tmr_newcall,@(75)		; 300ms
	AND	r2_led_newcall,@(0xf0)
	
IntCnt2_newcall_end:

IntCnt2_4ms_end:

	JMP	IntEnd

IntFsk:
	BC	_ISR,6
	JMP	IntEnd


Main:
	NOP
	CALL	Initial
	;CALL	Main_test

	MOV	A,@(PRO_AppIdle)
	LCALL	LibPushProgram
	

Main_loop:
	
	PAGE	#SerClock
	CALL	SerClock
	
	PAGE	#(SerProtocol)
	CALL	SerProtocol
	
	PAGE	#(LcdDriver)
	CALL	LcdDriver
	
	PAGE	#(SerCursor)
	CALL	SerCursor
	
	PAGE	#SerMessager
	CALL	SerMessager
	CALL	SerServer
	
	PAGE	#(Application)
	CALL	Application
	PAGE	#($)
	ADD	A,@(0)
	JPNZ	Main_loop
	CLR	sys_msg
	JMP	Main_loop



INCLUDE	"iic.asm"
INCLUDE	"initial.asm"
INCLUDE	"library.asm"
INCLUDE	"lcddrv.asm"
INCLUDE	"vga.asm"
INCLUDE	"service.asm"
INCLUDE	"application.asm"
INCLUDE	"temp.asm"
INCLUDE	"table.asm"
INCLUDE	"string.asm"


