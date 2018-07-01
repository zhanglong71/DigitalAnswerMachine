.LIST
;-------------------------------------------------------------------------------
;	Function : TEL_IICWEITE
;	input : COUNT =  the length of tel-data
;	output: no
;-------------------------------------------------------------------------------
TEL_IICWEITE:
	LAC	COUNT
	SBHK	1
	SAH	COUNT
	BS	SGN,TEL_IICWEITE_END
	
	CALL	GETR_DAT
	ORL	0XE000
	CALL	DAM_BIOSFUNC
	BS	B1,TEL_IICWEITE
TEL_IICWEITE_END:
	
	RET

;-------------------------------------------------------------------------------
.END
