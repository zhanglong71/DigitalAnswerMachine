.LIST
;-------------------------------------------------------------------------------
;	Function : SET_NOISELEV
;	Set PSA duing playing
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
SET_NOISELEV:
	PSH	CONF

	SAH	SYSTMP0	
;-------
	LACL	0x5F47		; set denoise level 0: off - 15 max.
	CALL	DAM_BIOSFUNC
	LAC	SYSTMP0
	CALL	DAM_BIOSFUNC
;-------
	POP	CONF
	RET
;-------------------------------------------------------------------------------
.END
