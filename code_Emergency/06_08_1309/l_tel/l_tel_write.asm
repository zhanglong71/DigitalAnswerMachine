.LIST
;############################################################################
;
;	Function : TELNUM_WRITE
;	save the telephone number in working group
;
;	����ADDR_SΪ��ʼ��ַ�Ե�����д��FLASH(��BYTEΪ��λ)
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
