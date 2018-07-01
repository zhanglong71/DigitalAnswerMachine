.LIST
;----------------------------------------------------------------------------
;       Function : DTMF_CHK
;
;       The general routine used in remote line operation. It checks DTMF
;       Input  : CONF (Record Mode, Play Mode, Line Mode or Voice Prompt Mode)
;       Output : ACCH = 0  -  No detected
;                ACCH = 1  -  DTMF start detected
;	 	 ACCH = 2  -  DTMF end detected

;		 DTMF_VAL  =  DTMF value
;       Parameters:
;               8. EVEVT.11 - store the detected DTMF flag
;----------------------------------------------------------------------------
DTMF_CHK:
        LAC     RESP            ;check the DTMF value ?
        ANDK    0X0F
        BS      ACZ,DTMF_CHK1
	ADHL	DTMF_TABLE
	CALL	GetOneConst
        SAH     DTMF_VAL	;save the DTMF value in DTMF_VAL

	BIT     EVENT,11
        BS      TB,DTMF_CHK_END
;---DTMF从无到有
        LAC     EVENT
        ORL	1<<11
        SAH     EVENT

	LACK	1		;DTMF start detected, return ACCH = 1

        RET
DTMF_CHK1:
	BIT     EVENT,11
        BZ      TB,DTMF_CHK_END

        LAC     EVENT
        ANDL	~(1<<11)
        SAH     EVENT

        LACK    2		;DTMF end detected, return ACCH = 2
        RET
DTMF_CHK_END:
	LACK	0
	
	RET
;-------------------------------------------------------------------------------
.END
