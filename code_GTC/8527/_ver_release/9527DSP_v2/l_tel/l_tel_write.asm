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
	LAC	COUNT
	SBHK	1
	SAH	COUNT
	BS	SGN,TELNUM_WRITE_EXIT	;�ﵽָ���ĸ���
	
	CALL	GETBYTE_DAT
	ORL	0XE000
	CALL	DAM_BIOSFUNC
	SFR	8
	BS	ACZ,TELNUM_WRITE	;û�������/���������
TELNUM_WRITE_EXIT:

	RET
;-------------------------------------------------------------------------------
.END
