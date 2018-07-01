.LIST
.if	0	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;-------------------------------------------------------------------------------
;	Function : VP_ElectrifyOn	
;	INPUT : no
;	output: no
;	for power on
;-------------------------------------------------------------------------------
VP_ElectrifyOn:
	CALL	BBBEEP
	CALL	BBBEEP
	
	RET
.else	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;-------------------------------------------------------------------------------
;	Function : VP_ElectrifyOn	
;	INPUT : no
;	output: no
;	for power on
;-------------------------------------------------------------------------------
VP_ElectrifyOn:
	CALL	GET_LANGUAGE
	BS	ACZ,VP_ElectrifyOn_0
	SBHK	1
	BS	ACZ,VP_ElectrifyOn_French
	SBHK	1
	BS	ACZ,VP_ElectrifyOn_Spanish
VP_ElectrifyOn_0:		;English
	LACL	0XFF00|57
	CALL	STOR_VP
	RET
VP_ElectrifyOn_Spanish:		;Spanish
	LACL	0XFF00|116
	CALL	STOR_VP
	RET
VP_ElectrifyOn_French:		;French
	LACL	0XFF00|180
	CALL	STOR_VP
	RET
.endif	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;-------------------------------------------------------------------------------

.END
	