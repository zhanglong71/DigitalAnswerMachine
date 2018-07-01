.LIST

;----------------------------------------------------------------------------
;       Function : SET_COMPS
;
;       Set the speech compression algorithm
;	(0XD107)	;0 - 3.6kbps
;	(0XD107)|(1<<3)	;1 - 4.8kbps
;	(0XD107)|(2<<3)	;2 - 6.0kbps
;	(0XD107)|(3<<3)	;3 - 7.2kbps
;	(0XD107)|(4<<3)	;4 - 8.4kbps
;	(0XD107)|(5<<3)	;5 - 9.6kbps
CRATE36		.EQU	0
CRATE48		.EQU	1<<3
CRATE60		.EQU	2<<3
CRATE72		.EQU	3<<3
CRATE84		.EQU	4<<3
CRATE96		.EQU	5<<3
;-------------------------------------------------------------------------------
SET_COMPS:
	BIT	VOI_ATT,10
	BZ	TB,SET_COMPS_60K
;SET_COMPS_36K:
	LACL	(0XD107)|CRATE36	;0 - 3.6kbps
	BS	B1,SET_COMPS_DONE
SET_COMPS_60K:
	LACL	(0XD107)|CRATE60	;2 - 6.0kbps
SET_COMPS_DONE:
	CALL	DAM_BIOSFUNC
	RET

;-------------------------------------------------------------------------------
.END
