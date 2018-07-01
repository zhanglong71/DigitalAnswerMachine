;-------------------------------------------------------------------------------
MAIN:
	CALL	#INITIAL		;initial
	NOP
MAIN_LOOP:
	BANK	0
	CALL 	get_msg
	JPZ	MAIN_LOOP
	MOV	msg,a
	
	CALL	sys_msg
	nop
	nop
	JPZ	MAIN_LOOP
	nop
	nop
	jmp 	goto_func		;do func
;-------------------------------------------------------------------------------
goto_func:
	call get_pro
	tbl
	jmp pro_main			;0
	jmp goto_call_num		;1
	jmp goto_call_out		;2
	jmp goto_menu			;3
	jmp Goto_Lcd_Contarst		;4 lcd contrast
	jmp Goto_Set_Language		;5 select language
	jmp Goto_Set_Area_Code		;6 set area code
	jmp Goto_Set_Week		;7 enter week
	jmp Goto_Set_Time		;8 enter time
	jmp Goto_Set_Date		;9 enter date
	jmp Goto_Set_Lcode		;a set long code
	jmp Goto_Data_Mode		;b data bank mode
	jmp Goto_Ogm_Rec		;c ogm rec
	jmp Goto_Ogm_Playback		;d ogm playback
	jmp Goto_Vol_Adj		;e vol adj
	jmp Goto_Edit			;f 编辑
	
	jmp Goto_Book			;10 电话本
;-------------------------------------------------------------------------------
;-------程序指针宏----------
	Cgoto_call_num		equ	0x01
	Cgoto_call_out		equ	0x02
	Cgoto_menu		equ	0x03
	Cgoto_Lcd_Contarst	equ	0x04
	Cgoto_Set_Language	equ	0x05
	Cgoto_Set_Area_Code	equ	0x06
	Cgoto_Set_Week		equ	0x07
	Cgoto_Set_Time		equ	0x08
	Cgoto_Set_Date		equ	0x09
	Cgoto_Set_Lcode		equ	0x0a
	Cgoto_Data_Mode		equ	0x0b
	Cgoto_Ogm_Rec		equ	0x0c
	Cgoto_Ogm_Playback	equ	0x0d
	Cgoto_Vol_Adj		equ	0x0e
	Cgoto_Edit		equ	0x0f
	
	Cgoto_Book		equ	0x10
;-------------------------------------------------------------------------------	
pro_main:
goto_call_num:
goto_call_out:
goto_menu:
Goto_Lcd_Contarst:
Goto_Set_Language:
Goto_Set_Area_Code:
Goto_Set_Week:
Goto_Set_Time:
Goto_Set_Date:
Goto_Set_Lcode:
Goto_Data_Mode:
Goto_Ogm_Rec:
Goto_Ogm_Playback:
Goto_Vol_Adj:
Goto_Edit:
Goto_Book:
	jmp 	MAIN_LOOP	
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------