.LIST
;############################################################################
;       Function : DAT_READ
;	读出数据
;
;	input  : TEL-Message number
;		data at where from 0x2600 to 0x261D
;	OUTPUT : ACCH = 1/0 ===> 无效/有效
;		
;############################################################################
DAT_READ:
	SAH	COMMAND1
	LACL	0XE200
	BS	B1,DAT_READ_DO
DAT_NREAD:
	SAH	COMMAND1
	LACL	0XE280
DAT_READ_DO:
       	CALL    DAM_BIOSFUNC
       	SFR     8	
	RET
;-------------------------------------------------------------------------------
.END
