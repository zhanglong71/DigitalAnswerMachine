.LIST

;----------------------------------------------------------------------------
;       Function : TEL_GC_CHK
;
;       Check garbage collection
;-------------------------------------------------------------------------------
TEL_GC_CHK:
	LACL    0XE404		;Get used TEL block number
        CALL    DAM_BIOSFUNC
        SBHK	32
        BS	SGN,TEL_GC_CHK_END

	LACK	1
	SAH	SYSTMP0		;Set flag
TEL_GC_CHK_0:
        LACL    0XE405		;check if garbage collection is required ?
        CALL    DAM_BIOSFUNC
        BS      ACZ,TEL_GC_CHK_1

        LACL    0XE407
        CALL    DAM_BIOSFUNC
        BS      ACZ,TEL_GC_CHK_0

        CALL	DAM_GC_CHK
        BS	B1,TEL_GC_CHK_0
TEL_GC_CHK_1:
	CALL	DAM_GC_CHK
TEL_GC_CHK_END:
	LACK	0
	SAH	SYSTMP0		;Clear flag
	
	RET
;---------------------------------------
DAM_GC_CHK:	
	LACL    0X3005           	; check if garbage collection is required ?
        CALL    DAM_BIOSFUNC
        BS      ACZ,DAM_GC_CHK_1
        
        LACL    0X3007   		; do garbage collection
        CALL    DAM_BIOSFUNC
        BS	B1,DAM_GC_CHK
DAM_GC_CHK_1:
	LAC	SYSTMP0
	BS	ACZ,SET_DECLTEL_END
;-------
SET_DECLTEL:
	LACL	0X5FA0
	CALL	DAM_BIOSFUNC
	ANDL	0XFF00
	BZ	ACZ,SET_DECLTEL_END	;error,exit
	LACK	CTEL_MNUM
	CALL	DAM_BIOSFUNC
SET_DECLTEL_END:

	RET
;-------------------------------------------------------------------------------
.END
