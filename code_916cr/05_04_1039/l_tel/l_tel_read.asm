.LIST
;############################################################################
;       Function : TELNUM_READ
;	根据TEL_ID从当前Group读出电话号码(此条目的全部)
;
;	input  : ACCH = TEL_ID
;		 ADDR_D = the base address
;		 OFFSET_D = the offset address
;	OUTPUT : no
;
;	variable:SYSTMP0,SYSTMP1
;############################################################################
TELNUM_READ:
	SAH	SYSTMP1
TELNUM_READ_LOOP:	
	LAC	SYSTMP1
	ORL	0XE200
       	CALL    DAM_BIOSFUNC
       	SAH	SYSTMP0
       	SFR     8
	BZ	ACZ,TELNUM_READ_END
	LAC	SYSTMP0
	CALL	STORBYTE_DAT
	BS	B1,TELNUM_READ_LOOP
TELNUM_READ_END:
	RET
;-------------------------------------------------------------------------------
.END
