.LIST
;-------------------------------------------------------------------
;	Function : VALUE_SUB(ACCH-1==>ACCH)
;	
;	input : ACCH ==>SYSTMP0
;	output: ACCH
;	minvalue: SYSTMP1
;	maxvalue: SYSTMP2
;		
;-------------------------------------------------------------------        
VALUE_SUB:
	SAH	SYSTMP0
VALUE_SUB1:
        LAC     SYSTMP1
        SBH	SYSTMP0
        BZ	SGN,VALUE_SUB3	;比最小的还小
        LAC	SYSTMP2
        SBH	SYSTMP0
        BS	SGN,VALUE_SUB3	;比最大的还大
        
        LAC	SYSTMP0
	SBHK	1
       
        RET
VALUE_SUB3:
	LAC	SYSTMP2

	RET

;-------------------------------------------------------------------------------
.END
