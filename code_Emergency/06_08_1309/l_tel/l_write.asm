.LIST
;############################################################################
;
;	Function : DAT_WRITE
;	save the DAT in working group
;	input  : No
;		data at where from 0x2600 to 0x261D
;	output : ACCH = error code
;############################################################################	
DAT_WRITE:
	LACL	0XE000
	CALL	DAM_BIOSFUNC
	SFR	8
	
	RET
;-------------------------------------------------------------------------------
.END
