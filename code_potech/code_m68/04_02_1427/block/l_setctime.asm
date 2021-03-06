.LIST
;===============================================================================
;	Function : WEEK_SET
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
WEEK_SET:
	ORL	0X7300
	CALL	DAM_BIOSFUNC
	RET
;===============================================================================
;	Function : YEAR_SET
;将大于4的部分保存在 TMR_YEAR 中,小于4的部分保存在机器的指定区域
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
YEAR_SET:
	SAH	SYSTMP0
	LACK	0
	SAH	TMR_YEAR
YEAR_SET_LOOP:
	LAC	SYSTMP0
	SBHK	4
	BS	SGN,YEAR_SET_1

	LAC	SYSTMP0
	SBHK	4
	SAH	SYSTMP0
	
	LAC	TMR_YEAR
	ADHK	4
	SAH	TMR_YEAR
	BS	B1,YEAR_SET_LOOP
YEAR_SET_1:
	LAC	SYSTMP0
	ORL	0X7600
	CALL	DAM_BIOSFUNC
	RET
;-------------------------------------------------------------------------------
;	Function : MON_SET
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
MON_SET:
	ORL	0X7500
	CALL	DAM_BIOSFUNC
	RET
;-------------------------------------------------------------------------------
;	Function : DAY_SET
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
DAY_SET:
	ORL	0X7400
	CALL	DAM_BIOSFUNC
	RET
;-------------------------------------------------------------------------------
;	Function : HOUR_SET
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
HOUR_SET:
	ORL	0X7200
	CALL	DAM_BIOSFUNC
	RET
;-------------------------------------------------------------------------------
;	Function : MIN_SET
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
MIN_SET:
	ORL	0X7100
	CALL	DAM_BIOSFUNC
	RET
;-------------------------------------------------------------------------------
;	Function : SEC_SET
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
SEC_SET:
	ORL	0X7000
	CALL	DAM_BIOSFUNC
	RET
;-------------------------------------------------------------------------------
.END
