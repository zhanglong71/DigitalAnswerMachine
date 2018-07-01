.LIST
;############################################################################
;
;	Function : TELNUM_WRITE
;	save the telephone number in working group
;
;	将以ADDR_S为起始地址以的数据写入FLASH(以BYTE为单位)
;	input  : OFFSET_S = the offset addr of the TEL_NUM
;		 ADDR_S = the base addr of the TEL_NUM
;		 COUNT = the number of byte data
;	output : ACCH = error-code(0/!0---success/error)
;	variable : SYSTMP0
;
;############################################################################
TELNUM_WRITE:
	LAC	COUNT
	SBHK	1
	SAH	COUNT
	BS	SGN,TELNUM_WRITE_EXIT	;达到指定的个数
	
	CALL	GETBYTE_DAT
	ORL	0XE000
	CALL	DAM_BIOSFUNC
	SFR	8
	BS	ACZ,TELNUM_WRITE	;没问题继续/有问题结束
TELNUM_WRITE_EXIT:

	RET
;-------------------------------------------------------------------------------
.END
