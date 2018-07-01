.LIST
;----------------------------------------------------------------------------
;       Function : DTMF_CHK
;
;       The general routine used in remote line operation. It checks DTMF
;       Input  : CONF (Record Mode, Play Mode, Line Mode or Voice Prompt Mode)
;       Output : ACCH = 0  -  DTMF end detected
;                ACCH = 1  -  DTMF start detected
;	 	 ACCH = 2  -  CAS-tone
;		 ACCH = 3  -  No
;
;		 DTMF_VAL  =  DTMF value
;       Parameters:
;               8. EVEVT.11 - store the detected DTMF flag
;----------------------------------------------------------------------------
DTMF_CHK:
	LAC     RESP            ;check the DTMF value 'D'?
        ANDL    0X010F
        SBHL	0X0100
        BS	ACZ,DTMF_CHK_CAS
        SBHK	0X000F
        BS	ACZ,DTMF_CHK_D
;---check "0..9","ABC",'*','#'
DTMF_CHK0:	
	LAC     RESP            ;check the DTMF value ?
	ANDK    0X0F
	BS      ACZ,DTMF_CHK1
DTMF_CHK0_1:
	ADHL	DTMF_TABLE
	CALL	GetOneConst
	SAH     DTMF_VAL	;save the DTMF value in DTMF_VAL
DTMF_CHK0_2:
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

	LAC	DTMF_VAL
	SBHL	0x100
	BS	ACZ,DTMF_CHK1_1
	
	LACK    0		;DTMF end detected, return ACCH = 0
	
	RET
DTMF_CHK1_1:			;CAS-tone
	LACK	2
	RET
DTMF_CHK_END:			;No 
	LACK	3
	
	RET
;---------------------------------------
DTMF_CHK_D:	;---check 'D'
        LACK	16
        BS	B1,DTMF_CHK0_1
DTMF_CHK_CAS:
        LACK	17
        BS	B1,DTMF_CHK0_1
;-------------------------------------------------------------------------------
DTMF_TABLE:
 	;no	1	2	3	4	5	6	7	8	
.DATA	0X00	0XF1	0XF2	0XF3	0XF4	0XF5	0XF6	0XF7	0XF8

	;9	*	0	#	A	B	C	D	CAS-tone
.DATA	0XF9	0XFE	0XF0	0XFF	0XFA	0XFB	0XFC	0XFD  	0x100
;-------------------------------------------------------------------------------
.END
