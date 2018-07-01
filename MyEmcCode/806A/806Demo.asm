
/***************************************
             项目主程序
功能：
	程序调用
	程序分配

***************************************/

include	"emc806.inc"	; emc806定义文件
include	"CONST.inc"
include "main.inc"

ORG	0X0000
	JMP	MAIN
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP
	NOP

ORG	0X0008
INT_BEGIN:
	DISI
	MOV	intbuf_acc,A
	SWAP	intbuf_acc
	MOV	intbuf_status,_STATUS
	MOV	intbuf_rsr,_RSR
	MOV	intbuf_ppsr,_PPSR
;---
	BANK	1
	MOV	intbuf_cidaddr,_RC
	MOV	A,_RB			; 保存CID体
	AND	A,@0X05
	MOV	intbuf_cidbank,A
	
	PAGE	0

;-------------------------------
	JPB	_ISR,6,INT_FSK
	JPB	_ISR,0,INT_TCC
	JPB	_ISR,1,INT_0
	JPB	_ISR,2,INT_1
	JPB	_ISR,3,INT_2
	JPB	_ISR,4,INT_CNT1
	JPB	_ISR,5,INT_CNT2
	JPB	_ISR,7,INT_STD
	JMP	INT_ERR
;-------------------------------
INT_END:
	BANK	1
;---
	MOV	A,_RB
	AND	A,@0XFA
	ADD	A,intbuf_cidbank
	MOV	_RB,A
	MOV	_RC,intbuf_cidaddr
;---
	MOV	_PPSR,intbuf_ppsr
	MOV	_RSR,intbuf_rsr
	MOV	_STATUS,intbuf_status
	SWAPA	intbuf_acc
	RETI
/*****************************FSK接收******************************/

INT_FSK:
	;MOV	_ISR,@0XBE
	MOV	_ISR,@(~((1<<6)|(1)))
	
	JMP	INT_END

/******************************************************************/
INT_TCC:
	;MOV	_ISR,@0XFE
	MOV	_ISR,@(~1)
	;CRAM	_ISR,0
	
	JMP	INT_END
/******************************************************************/
INT_0:
	;MOV	_ISR,@0XFD
	MOV	_ISR,@(~(1<<1))
	;CRAM	_ISR,1
	JMP	INT_END
/******************************************************************/
INT_1:
	;MOV	_ISR,@0XFB
	MOV	_ISR,@(~(1<<2))
	;CRAM	_ISR,2
	JMP	INT_END
/******************************************************************/
INT_2:
	;MOV	_ISR,@0XF7
	MOV	_ISR,@(~(1<<3))
	;CRAM	_ISR,3
	JMP	INT_END
/******************************************************************/
INT_CNT1:			; 0.5S
	;MOV	_ISR,@0XEF
	MOV	_ISR,@(~(1<<4))
;---	
	BANK	1
	
	INC	SEC_REG
	BC	_STATUS,C
	RRCA	SEC_REG
	SUB	A,@60
	JPNZ	INT_CNT1_1
	CLR	SEC_REG
	INC	MIN_REG
	SUBA	MIN_REG,@60
	JPNZ	INT_CNT1_1
	CLR	MIN_REG
	INC	HOUR_REG
	SUBA	HOUR_REG,@24
	JPNZ	INT_CNT1_1
	CLR	HOUR_REG
	INC	DAY_REG
	INC	WEEK_REG
	SUBA	WEEK_REG,@7
	JPNZ	INT_CNT1_1
	CLR	WEEK_REG
INT_CNT1_1:

	JMP	INT_END
/******************************************************************/
INT_CNT2:	;8ms
	;CRAM	_ISR,5
	MOV	_ISR,@(~(1<<5))
;---
	INC	TMR_TIMER
	
	MOV	A,TMR_TIMER
	JPNZ	INT_CNT2_END

	MOV	TMR_TIMER,@(0XFF-64)

	BANK	0
	mov	a,@CMSG_BLINK
	call	stor_int_msg
INT_CNT2_END:
		
	JMP	INT_END

;-------------------------------------------------------------------------------
INT_STD:
	;MOV	_ISR,@0X7F
	MOV	_ISR,@(~(1<<7))
	
	JMP	INT_END
;-------------------------------------------------------------------------------
INT_ERR:
	JMP	INT_END
;-------------------------------------------------------------------------------
/*
int_key:
;---Set port7(3..0) as an input
	IOR	_IOC7
	OR	A,@0X0F
	IOW	_IOC7
;---Enable internal pull-high-port7(3..0)

	PAGEIO	1
	IOR	_IOCD
	OR	A,@0X0F
	IOW	_IOCD

;---Enable scan key signal
	IOR	_IOCA
	OR	A,@0X01
	IOW	_IOCA
	
	NOP
	NOP
	NOP
	NOP
;---Blank LCD
	MOV	A,_RE
	AND	A,@0XF9
	OR	A,@0X02
	MOV	_RE,A
;---Disable scan key signal
	IOR	_IOCA
	AND	A,@(~1)
	IOW	_IOCA
;---Set P6S=0
	IOR	_IOCA
	AND	A,@(~(1<<6))
	IOW	_IOCA
;---Read p7
	MOV	A,_P7
;---Set P6S=1
	IOR	_IOCA
	OR	A,@(1<<6)
	IOW	_IOCA
;---Enable LCD
	MOV	A,_RE
	AND	A,@0XF9
	OR	A,@0X02
	MOV	_RE,A

	ret
*/
;---------------------------------------
KEY_SCAN:
	AND	_RE,@(0xfb)			; blank LCD
	IOR	_IOCE
	AND	A,@(0xdf)
	IOW	_IOCE
	
	BS	_P8,6
	
	BC	_STATUS,C
/*
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
*/
;-------------------------------------------------------------------------------
/***************************************
副程序区
***************************************/

; PAGE 0
include		"initial.asm"
include		"main.asm"
include		"gui.asm"
include		"sys_pro.asm"
include		"lcddrv.asm"
include		"string.asm"

;include	"timer.asm"
;include	"ASCII.asm"
;include	"iic.asm"

;include	"CID.asm"		; 400
;include	"stcp.asm"

;include	"math.asm"
;以下占用1400~1FFF
; 显示模块
;include	"VGA.asm"
; LCD驱动模块
; 0X1800~0X1FD2
;include	"lcddrv.asm"

