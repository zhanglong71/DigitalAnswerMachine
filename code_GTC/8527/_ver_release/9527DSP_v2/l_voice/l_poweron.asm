.LIST
.if	1	;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;-------------------------------------------------------------------------------
;	Function : VP_ElectrifyOn	
;	INPUT : no
;	output: no
;-------------------------------------------------------------------------------
VP_ElectrifyOn:
	CALL	GET_LANGUAGE
	BS	ACZ,VP_ElectrifyOn_0
	SBHK	1
	BS	ACZ,VP_ElectrifyOn_1
	SBHK	1
	BS	ACZ,VP_ElectrifyOn_2
VP_ElectrifyOn_0:		;English
	LACK	57
	BS	B1,INIT_VOP
VP_ElectrifyOn_1:		;Spanish
	LACK	116
	BS	B1,INIT_VOP
VP_ElectrifyOn_2:		;French
	LACL	180
	BS	B1,INIT_VOP
;-------------------------------------------------------------------------------
;	Function : INIT_VOP	
;	INPUT : ACCH = the MSGID
;	output: no
;-------------------------------------------------------------------------------
INIT_VOP:
	ANDL	0XFF
	SAH	SYSTMP1
;---
	LAC	SYSTMP1
	ORL	0XB000
	SAH	CONF
INIT_VOP_LOOP:
	CALL    DAM_BIOS
	BIT	RESP,6
	BZ	TB,INIT_VOP_LOOP
	
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