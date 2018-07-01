.LIST
;-------------------------------------------------------------------------------
;############################################################################
;       Function : SENDTIME
;	时间同步(6byte)
;
;	input  : no
;	output : no
;
;############################################################################
SENDTIME:
	
SENDTIME_SEND:
	LACL	0X8500
	CALL	DAM_BIOSFUNC	;Get month
	SFL	8
	SAH	SYSTMP1
	LACL	0X8400
	CALL	DAM_BIOSFUNC	;Get day
	OR	SYSTMP1
	SAH	SYSTMP1

	LACL	0X8200
	CALL	DAM_BIOSFUNC	;Get hour
	SFL	8
	SAH	SYSTMP2
	LACL	0X8100
	CALL	DAM_BIOSFUNC	;Get minute
	OR	SYSTMP2
	SAH	SYSTMP2
	LACL	0X8300
	CALL	DAM_BIOSFUNC	;Get week
	SAH	SYSTMP3

	LACL	0X7000
	CALL	DAM_BIOSFUNC	;clear second
;---Month/day/hour/minute/week	
	LACL	0X81		;时间同步(6byte)
	CALL	SEND_DAT
;---
	LAC	SYSTMP1
	SFR	8
	CALL	SEND_DAT
	LAC	SYSTMP1
	CALL	SEND_DAT
;---
	LAC	SYSTMP2
	SFR	8
	CALL	SEND_DAT
	LAC	SYSTMP2
	CALL	SEND_DAT
;---
	LAC	SYSTMP3
	CALL	SEND_DAT

	RET
;-------------------------------------------------------------------------------
.END
