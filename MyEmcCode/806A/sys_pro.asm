;-------------------------------------------------------------------------------
sys_msg:
	mov 	a,@Cmsg_exit	;处理exit
	sub 	a,msg
	jpnz 	sys_msg_1
	;///
	JMP	sys_msg_use
sys_msg_1:
	mov 	a,@CMSG_BLINK	;处理exit
	sub 	a,msg
	JPNZ 	sys_msg_2

	;MOV	A,_RE
	;XOR	A,@6
	;MOV	_RE,A

	call	#VIEW_STR
	call	#VIEW_NUM2
	
	MOV	A,@(LCD_CTRL+28)
	MOV	_RC,A
	MOV	A,pro_var1
	add	a,@0x01
	and	a,@0x1f
	MOV	pro_var1,A
	MOV	_RD,A
	
	MOV	A,@(LCD_CTRL+12)
	MOV	_RC,A
	MOV	A,pro_var1
	and	A,@0x0f
	MOV	_RD,A

	JMP	sys_msg_use
sys_msg_2:
	JMP 	sys_msg_end
sys_msg_use:
	clra
sys_msg_end:
	ret
;-------------------------------------------------------------------------------
;	Tone Generator
;-------------------------------------------------------------------------------
sys_tone:
	
	JPB	event,0,sys_ToneGenerating
	call	get_tone
	JPNZ	sys_tone_start
sys_NoTone:	
	ret
sys_ToneGenerating:
	ret
;-------------------
sys_tone_start:
	mov 	temp0,a
	and	a,@0x03
	CALL	#ToneTimeTable
	mov	tmr_tone,a	;时间长度(可暂不考虑)
	
	rrc	temp0
	rrc	temp0
	and	temp0,0x0f	;拔出号码的序号
;---tone-1
	mov	a,temp0
	CALL	#ToneIndexTableH
	IOW	_IOCD
;---tone-2
	mov	a,temp0
	CALL	#ToneIndexTableL
	IOW	_IOCE
	BS	_STATUS,5	;Enable TONE1
	BS	_STATUS,6	;Enable TONE2

	BS	event,0
	
	ret
;-------------------------------------------------------------------------------
;	Stor tone data to the tail of tone-queue
;	input : acc
;	output: no
;-------------------------------------------------------------------------------
stor_tone:
	mov 	temp0,a
;---
	mov 	a,_R4
	mov 	old_ram,a	;push _R4

	BANK	0
	CIDBANK	0
	
	mov 	a,tone_queue_tail
	add 	a,@tone_queue_start
	mov 	_RC,a
	mov 	a,temp0
	mov 	_RD,a
;---整理tone_queue	
	inca 	tone_queue_tail
	and 	a,@0x3f
	mov 	tone_queue_tail,a
	
	mov 	a,old_ram
	mov 	_R4,a	;pop _R4
;---
	ret
;-------------------------------------------------------------------------------
;	Get tone data from head of tone-queue
;	input : no
;	output: acc=0/~0 ==> no tone/
;-------------------------------------------------------------------------------
get_tone:
	mov 	a,_R4
	mov 	old_ram,a	;push _R4

	BANK	0
	CIDBANK	0
;---
	mov	a,tone_queue_head
	sub 	a,tone_queue_tail
	JPZ	get_tone_empty
;---整理tone_queue	
	mov 	a,tone_queue_head
	mov 	temp0,a		;Save it 
	add 	a,@0x01
	and 	a,@0x3f		;MAX.= 63
	mov 	tone_queue_head,a
	
	mov 	a,temp0		;get data in specific address
	add 	a,@tone_queue_start
	mov 	_RC,a
	mov 	a,_RD
	mov 	temp0,a		;Save the data
get_tone_end:
	mov 	a,old_ram
	mov 	_R4,a		;pop _R4
	
	mov	a, temp0
;---
	ret
get_tone_empty:
	clr	temp0	
	jmp	get_tone_end
	
;-------------------------------------------------------------------------------
ToneTimeTable:
	tbl
	RETL	@0	; 0
	RETL	@1	; 1
	RETL	@2	; 2
	RETL	@3	; 3
ToneIndexTableH:	;DTMF-H
	TBL
	RETL	0X77	; 0
	RETL	0XA0	; 1
	RETL	0XA0	; 2
	RETL	0XA0	; 3
	RETL	0X91	; 4
	RETL	0X91	; 5
	RETL	0X91	; 6
	RETL	0X83	; 7
	RETL	0X83	; 8
	RETL	0X83	; 9
	RETL	0XA0	; A
	RETL	0X91	; B
	RETL	0X83	; C
	RETL	0X77	; D
	RETL	0X77	; *
	RETL	0X77	; #

ToneIndexTableL:
	TBL
	RETL	0X54	; 0
	RETL	0X5D	; 1
	RETL	0X54	; 2
	RETL	0X4C	; 3
	RETL	0X5D	; 4
	RETL	0X54	; 5
	RETL	0X4C	; 6
	RETL	0X5D	; 7
	RETL	0X54	; 8
	RETL	0X4C	; 9
	RETL	0X44	; A
	RETL	0X44	; B
	RETL	0X44	; C
	RETL	0X44	; D
	RETL	0X5D	; *
	RETL	0X4C	; #
;-------------------------------------------------------------------------------


