.LIST
;----------------------------------------------------------------------------
;       Function : VOX_CHK
;
;       The general routine used in remote line operation. It checks VOX
;       Input  : CONF (Record Mode)
;       Output : ACCH = 1  -  VOX found over 10.0 sec
;                ACCH = 0  -  no VOX found over 10.0 sec
;               
;       Parameters:
;               1. TMR_VOX - for VOX detection(initial TMR_VOX=VOX time)
;----------------------------------------------------------------------------
VOX_CHK:				; check the VOX
        BIT     RESPONSE,6
        BZ      TB,VOX_CHK_OFF
VOX_CHK_ON:                     ; VOX on
        LAC     TMR_VOX
        BZ      SGN,VOX_CHK_END   
VOX_CHK_ON_1:
        LACK    1                 ; VOX found over 7.0 sec, return ACCH=1
        RET
VOX_CHK_OFF:                     ; VOX off

        LACL    CTMR_CVOX              ; restore 7.0 sec in TMR_VOX
        SAH     TMR_VOX
VOX_CHK_END:
	LACK    0
	RET
;-------------------------------------------------------------------------------
.END
