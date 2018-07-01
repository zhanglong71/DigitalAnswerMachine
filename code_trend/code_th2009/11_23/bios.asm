.LIST
;############################################################################
;	FUNCTION : SET_DELMARK
;	INPUT : ACCH = MSG_ID     
;	OUTPUT: NO
;############################################################################
SET_DELMARK:
	ANDK	0X7F
	ORL	0X2080
	CALL	DAM_BIOSFUNC

	RET
;############################################################################
;	FUNCTION : SET_DELMARKNEW
;	INPUT : ACCH = MSG_ID(the MSG_ID is related to new messages)  
;	OUTPUT: NO
;############################################################################
SET_DELMARKNEW:
	ANDK	0X7F
	ORL	0X2480
	CALL	DAM_BIOSFUNC

	RET
;############################################################################
;	FUNCTION : REAL_DEL
;	INPUT : NO
;	OUTPUT: NO
;############################################################################
REAL_DEL:
	LACL	0X6100
	CALL	DAM_BIOSFUNC
	
	RET
;############################################################################
;	FUNCTION : MSG_DEL
;	INPUT : NO
;	OUTPUT: NO
;############################################################################
;------------------------------------------------------------------------------
;	delete message with specific MSG_ID
;	input : ACCH = MSG_ID
;	output: no
;------------------------------------------------------------------------------
VPMSG_DEL:
	ANDK	0X7F
	ORL	0X6000	; delete
	CALL	DAM_BIOSFUNC
	
	RET
;############################################################################
;	FUNCTION : VPMSG_DELALL
;	INPUT : NO
;	OUTPUT: NO
;############################################################################
VPMSG_DELALL:
	LACL	0X6080
	CALL	DAM_BIOSFUNC
	
	RET
;############################################################################
;	FUNCTION : GET_VPTLEN
;	INPUT : ACCH = MSG_ID
;	OUTPUT: ACCH = RECORD LENGTH
;############################################################################
GET_VPTLEN:
	ANDK	0X7F
	ORL	0XA400
	CALL	DAM_BIOSFUNC

	RET
;############################################################################
;	FUNCTION : GET_USR0ID
;	Get message index-0 information
;	INPUT : ACCH = MSG_ID
;	OUTPUT: ACCH = USER INDEX DATA0
;############################################################################
GET_USR0ID:
	ANDL	0XFF
	ORL	0XA900
	CALL	DAM_BIOSFUNC
	
	RET
;############################################################################
;	FUNCTION : GET_USR1ID
;	Get message index-1 information
;	INPUT : ACCH = MSG_ID
;	OUTPUT: ACCH = USER INDEX DATA1
;############################################################################
GET_USR1ID:
	ANDL	0XFF
	ORL	0XAA00
	CALL	DAM_BIOSFUNC
	
	RET

;############################################################################
;	Function : CWEEK_GET
;	input : no
;	output: ACCH
;############################################################################
CWEEK_GET:
	LACL	0X8300
	CALL	DAM_BIOSFUNC

	RET
;############################################################################
;	Function : CHOUR_GET
;	input : no
;	output: ACCH
;############################################################################
CHOUR_GET:
	LACL	0X8200
	CALL	DAM_BIOSFUNC
	
	RET
;############################################################################
;	Function : CMIN_GET
;	input : no
;	output: ACCH
;############################################################################
CMIN_GET:
	LACL	0X8100
	CALL	DAM_BIOSFUNC
	RET
;############################################################################
;	Function : WEEK_SET
;	input : ACCH
;	output: ACCH
;############################################################################
WEEK_SET:
	ORL	0X7300
	CALL	DAM_BIOSFUNC
	RET
;############################################################################
;	Function : HOUR_SET
;	input : ACCH
;	output: ACCH
;############################################################################
HOUR_SET:
	ORL	0X7200
	CALL	DAM_BIOSFUNC
	RET
;############################################################################
;	Function : MIN_SET
;	input : ACCH
;	output: ACCH
;############################################################################
MIN_SET:
	ORL	0X7100
	CALL	DAM_BIOSFUNC
	RET
;############################################################################
;	Function : SEC_SET
;	input : ACCH
;	output: ACCH
;############################################################################
SEC_SET:
	ORL	0X7000
	CALL	DAM_BIOSFUNC
	RET

;############################################################################
;	Function : BEEP_STOP
;	
;	The general function for beep generation
;############################################################################
BEEP_STOP:
        LACL    0X4400            	;// beep stop
        CALL    DAM_BIOSFUNC

        RET
;############################################################################
;	Function : BEEP_START
;	
;	The general function for beep generation
;	Input  : BUF1=the beep frequency
;############################################################################
BEEP_START:
        LACL    CBEEP_COMMAND            	;// beep start
        CALL    DAM_BIOSFUNC

        RET
RBEEP_START:
	LACL    0X48F0            	;// beep start
	CALL    DAM_BIOSFUNC

	RET
;---
B_START:
	BIT     RING_ID,10
	BS	TB,RBEEP_START
	BS	B1,BEEP_START
;############################################################################
;       Function : GC_CHK
;
;       Check garbage collection
;############################################################################
GC_CHK:
	LACL    0X3007   		; do garbage collection
        CALL    DAM_BIOSFUNC

	LACL    0X3005           	; check if garbage collection is required ?
        CALL    DAM_BIOSFUNC
        BZ      ACZ,GC_CHK

	RET
;############################################################################
;       Function : TEL_GC_CHK
;
;       Check garbage collection
;############################################################################
TEL_GC_CHK:
        LACL    0XE405		;check if garbage collection is required ?
        CALL    DAM_BIOSFUNC
        BS      ACZ,TEL_GC_CHK_RTN

        LACL    0XE407		;do garbage collection
        CALL    DAM_BIOSFUNC
        BS      ACZ,TEL_GC_CHK	;(for D20)
        
        CALL	GC_CHK
TEL_GC_CHK_RTN:
        RET	
;-------------------------------------------------------------------------------
.END
	