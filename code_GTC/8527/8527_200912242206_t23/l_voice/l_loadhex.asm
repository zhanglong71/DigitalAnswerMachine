.LIST

;-------------------------------------------------------------------------
;	Function : LOAD_CIDVP	
;	input : ACCH = the data you will announce(0,1,2,3,4,5,6,7,8,9)
;
;	output: no
;
;-------------------------------------------------------------------------
LOAD_CIDVP:
	SAH	SYSTMP0

	LAC	SYSTMP0
	ANDK	0X0F
	BS	ACZ,LOAD_CIDVP_0
	SBHK	10
	BZ	SGN,LOAD_CIDVP_END
;LOAD_CIDVP_19:
LOAD_CIDVP_EXE:			;1-9
	LAC	SYSTMP0
	CALL	ANNOUNCE_NUM
	
	RET
LOAD_CIDVP_0:			;0
	CALL	GET_LANGUAGE
	BS	ACZ,LOAD_CIDVP_EXE	;English-0
LOAD_CIDVP_END:		;out of 0-9
	LACK	0X025	;300ms
	CALL	STOR_VP
	
	RET
;-------------------------------------------------------------------------------

.END
	