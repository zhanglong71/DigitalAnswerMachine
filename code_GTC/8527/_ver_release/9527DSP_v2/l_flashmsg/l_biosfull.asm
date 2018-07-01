.LIST

;-------------------------------------------------------------------------------
;	MEMFUL_CHK
;	memory full check
;	input : no
;	output: ACCH = 0/1-no/full
;-------------------------------------------------------------------------------
MEMFUL_CHK:
	LACL    0X3003		;check if memory is full ?(OGM use it)
	CALL	DAM_BIOSFUNC
       	SBHK	3
	BZ      SGN,MEMFUL_CHK_END
	
	LACK	1
	
	RET
MEMFUL_CHK_END:
	LACK	0
	
       	RET
;-------------------------------------------------------------------------------
.END
