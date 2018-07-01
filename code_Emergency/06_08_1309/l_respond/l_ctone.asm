.LIST
;----------------------------------------------------------------------------
;       Function : CTONE_CHK
;
;       The general routine used in remote line operation. It checks CONT TONE
;       Input  : CONF (Record Mode, Line Mode)
;       Output : ACCH = 1  -  continuous tone period found
;                ACCH = 0  -  no continuous tone period found
;       Parameters:
;               1. TMR_CTONE     - for continuous tone detection
;----------------------------------------------------------------------------
CTONE_CHK:
	
        BIT     RESPONSE,4            	; check if continuous tone happens ?
        BS      TB,CTONE_CHK_ON
        LACL    CTMR_CTONE              	; continuous tone off
        SAH     TMR_CTONE
CTONE_CHK_ON:
        LAC     TMR_CTONE
        BZ      SGN,CTONE_CHK_ON_2
        
CTONE_CHK_ON_1:	
        LACK    1                 	; continuous tone period found, return ACCH=1
        RET
CTONE_CHK_ON_2:
	LACK    0
        RET
;-------------------------------------------------------------------------------
.END
