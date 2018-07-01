.LIST
;-------------------------------------------------------------------------------
DAA_SPKPHONE:
	PSH	CONF
;---	
	LACL	0x5E1C		;All power on
	CALL	DAM_BIOSFUNC

	LACL	0x5E11		;set Codec path
	CALL	DAM_BIOSFUNC
;---set mic-pre-gain
.if	DebugPhone	
	LAC	ATT_PHONE2
.else
	LACL	CATT_PHONE2
.endif
	SFR	8
	ANDK	0X000F

	;LACK	CMIC_GAIN	; default Demo=7(+18dB)
	CALL	SET_MICGAIN	;set mic-pre-gain
;---set AD1-pga
.if	DebugPhone	
	LAC	ATT_PHONE3
.else
	LACL	CATT_PHONE3
.endif	
	SFR	12
	ANDK	0X000F
	;LACK	0xD		; +15dB
	CALL	SET_AD1PGA	; set AD1-pga
;---set AD2-pga
.if	DebugPhone	
	LAC	ATT_PHONE3
.else
	LACL	CATT_PHONE3
.endif	
	SFR	8
	ANDK	0X000F
	;LACK	0X0F		; +9dB
	CALL	SET_AD2PGA	; set AD2-pga
;---set SPK volume
	LACK	0x0		; SPK_GAIN/Demo=0xE	
	CALL	SET_SPKVOL	; set SPK volume
;---set LINE volume
.if	DebugPhone	
	LAC	ATT_PHONE3
.else
	LACL	CATT_PHONE3
.endif	
	ANDK	0X001F
	;LACK	0x13		; -6dB
	CALL	SET_LINVOL	; set Lout volume
;---
	POP	CONF

	RET
;-------------------------------------------------------------------------------
.END
