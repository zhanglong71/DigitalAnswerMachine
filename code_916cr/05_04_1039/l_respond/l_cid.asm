.LIST
;----------------------------------------------------------------------------
;       Function : CID_CHK
;
;       The general routine used in remote line operation. It checks DTMF
;       Input  : RESP (Line Mode)
;       Output : ACCH = 0  -  CS-MS-DS/DTMF/CAS从无到有
;                ACCH = 1  -  CS-MS-DS/DTMF/CAS从有到无
;	 	 ACCH = 0x7F  no
;
;       Parameters:
;               8. EVEVT.1 - store the detected CS-MS-DS flag
;----------------------------------------------------------------------------
CID_CHK:
	LAC     RESP            ;check the DTMF value 'D'?
        ANDL    0X710F
        BS	ACZ,CID_CHK1
;---CS/MS/DS detected

	BIT     EVENT,1
	BS      TB,CID_CHK_END
;---CS/MS/DS从无到有
	LAC     EVENT
	ORL	1<<1
	SAH     EVENT

	LACK	0		;CS/MS/DS start detected, return ACCH = 1

        RET
CID_CHK1:
	BIT     EVENT,1
        BZ      TB,CID_CHK_END

	LAC     EVENT
	ANDL	~(1<<1)
	SAH     EVENT

	LACK    1		;DTMF end detected, return ACCH = 0
	
	RET
CID_CHK_END:			;No
	LACK	0x7f
	
	RET
;-------------------------------------------------------------------------------
.END
