.LIST

;###############################################################################
;       Function : DAM_ATT_WRITE
;	将DAM相关参数写入Flash
;---!!!Note:以BYTE为单位
;	input  : no
;	OUTPUT : no
;###############################################################################
DAM_ATT_WRITE:
;---Byte1 ==> ps1,2
	LAC	PASSWORD
	SFR	8
	ANDL	0X0FF
	CALL	DAT_WRITE
;---Byte2 ==> ps3,4
	LAC	PASSWORD
	ANDL	0X0FF
	CALL	DAT_WRITE
;---Byte3 ==> lc1,2
	LAC	LOCACODE
	SFR	8
	ANDL	0X0FF
	CALL	DAT_WRITE
;---Byte4 ==> lc3,4
	LAC	LOCACODE
	ANDL	0X0FF
	CALL	DAT_WRITE
;---Byte5 ==> LCD constrast
	LAC	DAM_ATT0
	ANDK	0X00F
	CALL	DAT_WRITE
;---Byte6 ==> Language
	LAC	DAM_ATT0
	SFR	8
	ANDK	0X003
	CALL	DAT_WRITE
;---byte7 ==> ring melody
	LAC	DAM_ATT0
	SFR	4
	ANDK	0X00F
	CALL	DAT_WRITE
;---byte8 ==> ring volume
	LAC	DAM_ATT1
	ANDK	0X00F
	CALL	DAT_WRITE
;---byte9 ==> ring delay
	LAC	DAM_ATT
	SFR	12
	ANDK	0X00F
	CALL	DAT_WRITE
;---byte10 ==> compression rate
	LAC	DAM_ATT1
	SFR	4
	ANDK	0X00F
	CALL	DAT_WRITE
;---byte11 ==> flash time
	LAC	DAM_ATT0
	SFR	8
	ANDK	0X00F
	CALL	DAT_WRITE
;---byte12 ==> pause time
	LAC	DAM_ATT0
	SFR	12
	ANDK	0X00F
	CALL	DAT_WRITE
;---byte13 ==> DTAM status
	LACK	0X001
	SAH	SYSTMP0
	
	BIT	EVENT,9
	BZ	TB,DAM_ATT_WRITE_SELOGM
	
	LAC	SYSTMP0
	ORL	1<<7
	SAH	SYSTMP0
DAM_ATT_WRITE_SELOGM:	
	BIT	EVENT,8
	BZ	TB,DAM_ATT_WRITE_STATUS
	
	LAC	SYSTMP0
	ORK	0X002
	SAH	SYSTMP0
DAM_ATT_WRITE_STATUS:
	LAC	SYSTMP0
	CALL	DAT_WRITE
DAM_ATT_WRITE_END:
	CALL	DAT_WRITE_STOP
	
	RET
;-------------------------------------------------------------------------------
	
.END
