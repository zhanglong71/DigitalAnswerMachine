.LIST
;-------------------------------------------------------------------------------
STOR_HOUR:
.if	0	
	CALL	ANNOUNCE_NUM
	RET
.else
	BS	B1,ANNOUNCE_NUM
.endif
;-------------------
STOR_MINUTE:	
.if	0	
	CALL	ANNOUNCE_NUM
	RET
.else
	BS	B1,ANNOUNCE_NUM
.endif
;---------------------------------------
;	input : ACCH = week(0..6)
;---------------------------------------
STOR_WEEK:	
VP_Week:
	SAH	SYSTMP0
	CALL	GET_LANGUAGE
	BS	ACZ,VP_Week_0
	SBHK	1
	BS	ACZ,VP_Week_French
	
VP_Week_0:
VP_Week_French:
	LAC	SYSTMP0
	ADHL	VOPIDX_FR_Sunday
	ORL	0XFF00
	CALL	STOR_VP
	RET
;-------------------------------------------------------------------------------
;	function: STOR_TIMETAG
;
;	input : no
;	output:	no
;-------------------------------------------------------------------------------
STOR_TIMETAG:
	BIT	ANN_FG,12
	BS	TB,STOR_TIMETAG_NEW
STOR_TIMETAG_ALL:
	LAC	MSG_ID
	ANDK	0X7F
	SAH	SYSTMP1
	BS	B1,STOR_TIMETAG_2
STOR_TIMETAG_NEW:
	LAC	MSG_ID
	ANDK	0X7F
	ORL	1<<7
	SAH	SYSTMP1
;---------
STOR_TIMETAG_2:
	LAC	SYSTMP1
	ORL	0XA500		;Time set or not
	CALL	DAM_BIOSFUNC
	BS	ACZ,STOR_TIMETAG_END
;---
	LAC	SYSTMP1
	ORL	0XA100		;Minute
	CALL	DAM_BIOSFUNC
	SAH	TMR_MINUTE
;---
	LAC	SYSTMP1
	ORL	0XA200		;Hour
	CALL	DAM_BIOSFUNC
	SAH	TMR_HOUR
;---
	LAC	SYSTMP1
	ORL	0XA300		;Week
	CALL	DAM_BIOSFUNC
	SAH	TMR_WEEK
;-------------------
	LAC	TMR_WEEK
	CALL	STOR_WEEK
;---
	LAC	TMR_HOUR
	CALL	STOR_HOUR
;---
	LAC	TMR_MINUTE
	CALL	STOR_MINUTE
		
STOR_TIMETAG_END:	
	RET
;-------------------------------------------------------------------------------
.END
