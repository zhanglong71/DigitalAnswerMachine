.LIST

;-------------------------------------------------------------------------------
;	Function : MSG_WEEK/MSG_HOUR/MSG_MIN
;	
;-------------------------------------------------------------------------------
MSG_WEEKNEW:
	LAC	MSG_ID
	ORL	0XA380
	CALL	DAM_BIOSFUNC
	BS	B1,MSG_WEEK_STOR
MSG_WEEK:
	LAC	MSG_ID
	ORL	0XA300
	CALL	DAM_BIOSFUNC
MSG_WEEK_STOR:
	CALL	VP_Week
	
	RET
;---
MSG_HOURNEW:
	LAC	MSG_ID
	ORL	0XA280
	CALL	DAM_BIOSFUNC
	BS	B1,MSG_HOUR_STOR
MSG_HOUR:
	LAC	MSG_ID
	ORL	0XA200
	CALL	DAM_BIOSFUNC
MSG_HOUR_STOR:
	SAH	SYSTMP0
	BS	ACZ,MSG_HOUR_0		;0
	SBHK	12
	BS	ACZ,MSG_HOUR_12		;12
	BS	SGN,MSG_HOUR_LESS12	;1,2,3,4,5,6,7,8,9,10,11,
;---	
	SAH	SYSTMP0			;13,14,15,16,17,18,19,20,21,22,23
	BS	B1,MSG_HOUR_LESS12
MSG_HOUR_0:
MSG_HOUR_12:
	LACK	12	
MSG_HOUR_EXE:
	CALL	ANNOUNCE_NUM
	
	RET
MSG_HOUR_LESS12:
	LAC	SYSTMP0
	BS	B1,MSG_HOUR_EXE
;-------------------
MSG_MINNEW:
	LAC	MSG_ID
	ORL	0XA180
	CALL	DAM_BIOSFUNC
	BS	B1,MSG_MIN_1
MSG_MIN:
	LAC	MSG_ID
	ORL	0XA100
	CALL	DAM_BIOSFUNC
MSG_MIN_1:
	SAH	SYSTMP0
	CALL	GET_LANGUAGE
	BS	ACZ,MSG_MIN_English
;---Not English
	LAC	SYSTMP0
	BS	ACZ,MSG_MIN_00		;<10
MSG_MIN_STOR:
	LAC	SYSTMP0
	CALL	ANNOUNCE_NUM
MSG_MIN_00:
	RET
;-------------------
MSG_MIN_English:
	LAC	SYSTMP0
	BS	ACZ,MSG_MIN_English00		;"0"
	SBHK	10
	BS	SGN,MSG_MIN_EnglishLess10	;(1..9)
	BS	B1,MSG_MIN_STOR			;(10...)
MSG_MIN_English00:
	;CALL	VP_Oh	;GTC demand
	;CALL	VP_Oh
	RET
MSG_MIN_EnglishLess10:
	PSH	SYSTMP0
	NOP
	CALL	VP_Oh
	NOP
	POP	SYSTMP0
	BS	B1,MSG_MIN_STOR			;(10...)
;---------------------------------------
MSG_AMPMNEW:

	LAC	MSG_ID
	ORL	0XA280
	CALL	DAM_BIOSFUNC
	BS	B1,AM_PM_STOR
MSG_AMPM:
;---Get hour
	LAC	MSG_ID
	ORL	0XA200
	CALL	DAM_BIOSFUNC
AM_PM_STOR:
	SBHK	12
	BS	SGN,MSG_MIN_AM
;MSG_MIN_PM
	CALL	VP_PM	
	RET
MSG_MIN_AM:
	CALL	VP_AM	
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_AM:
	CALL	GET_LANGUAGE
	BS	ACZ,VP_AM_0
	SBHK	1
	BS	ACZ,VP_AM_French
	SBHK	1
	BS	ACZ,VP_AM_Spanish
VP_AM_0:	
	LACL	0XFF00|29
	CALL	STOR_VP
	RET
VP_AM_French:
	LACL	0XFF00|153
	CALL	STOR_VP
	RET
VP_AM_Spanish:
	LACL	0XFF00|89
	CALL	STOR_VP
	RET
;---------------
;	input : no
;	output: no
;---------------
VP_PM:
	CALL	GET_LANGUAGE
	BS	ACZ,VP_PM_0
	SBHK	1
	BS	ACZ,VP_PM_French
	SBHK	1
	BS	ACZ,VP_PM_Spanish
VP_PM_0:	
	LACL	0XFF00|30
	CALL	STOR_VP
	RET
VP_PM_French:
	LACL	0XFF00|154
	CALL	STOR_VP
	RET
VP_PM_Spanish:
	LACL	0XFF00|90
	CALL	STOR_VP
	RET
;---------------------------------------
;	input : ACCH = week(0..6)
;---------------------------------------	
VP_Week:
	SAH	SYSTMP0
	CALL	GET_LANGUAGE
	BS	ACZ,VP_Week_0
	SBHK	1
	BS	ACZ,VP_Week_French
	SBHK	1
	BS	ACZ,VP_Week_Spanish
VP_Week_0:
	LAC	SYSTMP0
	ADHK	31
	ORL	0XFF00
	CALL	STOR_VP
	RET
VP_Week_Spanish:
	LAC	SYSTMP0
	ADHK	91
	ORL	0XFF00
	CALL	STOR_VP
	RET
VP_Week_French:
	LAC	SYSTMP0
	ADHL	155
	ORL	0XFF00
	CALL	STOR_VP
	RET
;---------------------------------------
;	input : no
;	output: no
;---------------------------------------	
VP_Oh:			;for English only
	LACL	0XFF00|38
	CALL	STOR_VP
	RET
;---------------------------------------
;	input : no
;	output: no
;---------------------------------------	
VP_HourFre:			;for French only
	ADHL	0XFF00|190
	CALL	STOR_VP
	RET
;---------------------------------------
;	input : no
;	output: no
;---------------------------------------
VP_MinutFre:			;for French only
	SAH	SYSTMP0
	BS	ACZ,VP_MinutFre0
	SBHK	21
	BS	SGN,VP_MinutFre1_20
;VP_Minute21_59:	
	ADHL	0XFF00|214	;0-38 --> 21-59
	CALL	STOR_VP

	RET
VP_MinutFre1_20:
	LAC	SYSTMP0
	CALL	ANNOUNCE_NUM
	RET
VP_MinutFre0:
	LACK	0X005
	CALL	STOR_VP
	RET
;---------------------------------------
;	input : no
;	output: no
;---------------------------------------	
VP_Youhavenomessage:		;for French only
	LACL	0XFF00|189
	CALL	STOR_VP
	RET

;-------------------------------------------------------------------------------
.END
