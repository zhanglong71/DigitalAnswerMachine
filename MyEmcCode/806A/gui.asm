;-------------------------------------------------------------------------------
;	约定中继程序用BANK 1
;-------------------------------------------------------------------------------
stor_int_msg:
	mov 	int_temp0,a
	
	BANK	0
	mov 	a,msg_queue
	and 	a,@0x07
	add 	a,@msg_queue_start
	mov 	_R4,a
	mov 	a,int_temp0
	mov 	_R0,a
;---整理msg_queue	
	inca 	msg_queue
	and 	a,@0x77
	mov 	msg_queue,a
	
	BANK	1

	ret
;-------------------------------------------------------------------------------
stor_msg:
	disi
;---
	mov 	temp0,a
	mov 	a,_R4
	mov 	old_ram,a	;push _R4
	BANK	0
	
	mov 	a,msg_queue
	and 	a,@0x07
	add 	a,@msg_queue_start
	mov 	_R4,a
	mov 	a,temp0
	mov 	_R0,a
;---整理msg_queue	
	inca 	msg_queue
	and 	a,@0x77
	mov 	msg_queue,a
	mov 	a,old_ram
	mov 	_R4,a	;pop _R4
;---
	eni
	ret
;-------------------------------------------------------------------------------
get_msg:
	disi
	
	mov 	a,_R4
	mov 	old_ram,a	;push _R4

	BANK	0
;---
	swapa 	msg_queue
	and 	a,@0x07
	mov 	temp0,a		;get address
	mov 	a,msg_queue
	and 	a,@0x07
	sub 	a,temp0
	jbc 	_STATUS,z
	jmp 	get_msg_empty
;---整理msg_queue	
	mov 	a,msg_queue
	add 	a,@0x10
	and 	a,@0x77
	mov 	msg_queue,a
	
	mov 	a,temp0		;get data in specific address
	add 	a,@msg_queue_start
	mov 	_R4,a
	mov 	a,_R0
	mov 	temp0,a		;Save the data
get_msg_end:
	mov 	a,old_ram
	mov 	_R4,a	;pop _R4
	
	mov	a, temp0
;---
	eni
	ret
get_msg_empty:
	clr	temp0	
	jmp	get_msg_end
	
;-------------------------------------------------------------------------------
push_pro:
	mov temp0,a

	mov a,_R4
	mov old_ram,a		;push _R4

	BANK	0
	inca pro_stack
	and a,@0x07		;整理
	mov pro_stack,a
	
	add a,@pro_stack
	mov _R4,a
	mov a,temp0
	mov _R0,a
	
	mov a,old_ram
	mov _R4,a		;pop _R4
	
	ret
;---------------------------------------
clr_pro_stack:
	mov a,_R4
	mov old_ram,a	;push _R4

	BANK	0
	clr pro_stack
	
	mov a,old_ram
	mov _R4,a	;pop _R4
	ret
;---------------------------------------
pop_pro:
	mov a,_R4
	mov old_ram,a	;push _R4
	
	BANK	0
	mov a,pro_stack
	jbc _STATUS,z
	jmp pro_stack_end
	dec pro_stack

	mov a,pro_stack
	jbc _STATUS,z
	jmp pro_stack_end
	
	add a,@pro_stack
	mov _R4,a
	mov a,_R0
	mov temp0,a
pro_stack_end:

	mov a,old_ram
	mov _R4,a	;pop _R4
	
	mov a,temp0

	ret
;---------------------------------------
get_pro:
	mov a,_R4
	mov old_ram,a	;push _R4
	
	BANK	0
	mov a,pro_stack
	jbc _STATUS,z
	jmp get_pro_end
	add a,@pro_stack
	mov _R4,a
	mov a,_R0
get_pro_end:
	mov temp0,a
	
	mov a,old_ram
	mov _R4,a	;pop _R4

	mov a,temp0
	ret
;-------------------------------------------------------------------------------
set_timer:
	mov temp0,a

	mov a,_R4
	mov old_ram,a	;push _R4

	BANK	1
	
	mov a,temp0
	mov tmr_timer,a
	mov tmr_timer_bak,a	;打开定时器 A=1/256秒
	
	mov a,old_ram
	mov _R4,a

	ret
clr_timer:
	mov a,_R4
	mov old_ram,a	;push _R4
;---	
	BANK	1
	clr tmr_timer
	clr tmr_timer_bak	;关闭定时器
;---	
	mov a,old_ram
	mov _R4,a
	ret
;-------------------------------------------------------------------------------
;	Function : get_dat	
;	从以base_s为基地址以offset_s偏移地址的数据取出
;	INPUT : offset_s = the offset you will get data from
;		base_s = the BASE you will get data from
;	output: acc = the data you want
;-------------------------------------------------------------------------------
get_dat:
	;mov	a,_R4
	;mov	old_ram,a	;push _R4
;---
	;BANK	0
	mov	a,base_s
	add 	a,offset_s
	mov 	_R4,a
	mov 	a,_R0
	mov 	temp0,a
	
	inc	offset_s

	;mov 	a,old_ram
	;mov 	_R4,a
	
	mov	a,temp0

	RET
;-------------------------------------------------------------------------
;	Function : stor_dat	
;	将数据存在以base_d为基地址以offset_d偏移地址的空间(一个字节)
;	INPUT : ACCH = the data you will stor
;		offset_d = the offset you will stor data
;		base_d = the BASE you will stor data
;	output: no
;-------------------------------------------------------------------------
stor_dat:
	mov	temp0,a

	;mov	a,_R4
	;mov	old_ram,a	;push _R4
;---
	;BANK	0
	mov	a,base_d
	add 	a,offset_d
	mov 	_R4,a
	mov 	a,temp0
	mov 	_R0,a

	inc	offset_d

	;mov 	a,old_ram
	;mov 	_R4,a

	ret
;-------------------------------------------------------------------------------
;	Function : move_ltoh
;	从以base_s为基址,offset_s为起始偏移,长度为count的数据移动
;	到以base_d为基址,offset_d为起始偏移的地方
;	INPUT : count = 要移动的数据的长度byte
;		offset_s = the souce offset
;		offset_d = the dest offset
;		base_s = BASE address
;		base_d = BASE address
;	OUTPUT: no
;NOTE : move high address data first(ADDR_S+OFFSET_S/2 < ADDR_D+OFFSET_D/2)
;-------------------------------------------------------------------------------
move_ltoh:
	mov	a,offset_s
	add 	a,count
	mov	offset_s,a
	dec	offset_s
	
	mov	a,offset_d
	add 	a,count
	mov	offset_d,a
	dec	offset_d
move_ltoh_loop:
	CALL	get_dat
	CALL	stor_dat
	
	dec	offset_d
	dec	offset_d
	
	dec	offset_s
	dec	offset_s

	dec	count
	mov 	a,count
	jbs 	_STATUS,z
	jmp 	move_ltoh_loop
	
move_ltoh_end:	
	RET
;-------------------------------------------------------------------------------
;	Function : move_htol
;	从以base_s为基址,offset_s为起始偏移,长度为count的数据移动
;	到以base_d为基址,offset_d为起始偏移的地方
;	INPUT : count = 要移动的数据的长度byte
;		offset_s = the souce offset
;		offset_d = the dest offset
;		base_s = BASE address
;		base_d = BASE address
;	OUTPUT: no
;NOTE : move low address data first(ADDR_S+OFFSET_S/2 > ADDR_D+OFFSET_D/2)
;-------------------------------------------------------------------------------
move_htol:

	CALL	get_dat
	CALL	stor_dat
	
	dec	count
	mov 	a,count
	jbs 	_STATUS,z
	jmp 	move_htol
move_htol_end:
	
	RET
;-------------------------------------------------------------------------------
;	Function : ram_stor
;	将base_d为基址,offset_d为起始偏移,长度为count的地方,填充数据
;	INPUT : ACCH = 要填充的数据
;		count = 要填充的数据的长度byte
;		offset_d = the offset
;		base_d = BASE address
;	OUTPUT: no
;NOTE : move low address data first(ADDR_S+OFFSET_S/2 > ADDR_D+OFFSET_D/2)
;-------------------------------------------------------------------------------
ram_stor:
	mov	temp0,a
	
	mov	a,_R4
	mov	old_ram,a	;push _R4
;---
	BANK	0
ram_stor_loop:
	mov	a,base_d
	add 	a,offset_d
	mov 	_R4,a
	mov 	a,temp0
	mov 	_R0,a

	inc	offset_d

	dec	count
	mov 	a,count
	jbs 	_STATUS,z
	jmp 	ram_stor_loop
;---
	mov 	a,old_ram
	mov 	_R4,a

	RET
;-------------------------------------------------------------------------------