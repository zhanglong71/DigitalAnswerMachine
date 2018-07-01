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
	
	RET
;-------------------------------------------------------------------------------
.END
