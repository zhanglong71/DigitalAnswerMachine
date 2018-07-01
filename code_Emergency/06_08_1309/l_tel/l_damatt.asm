.LIST

;###############################################################################
;       Function : DAM_ATT_WRITE
;	将DAM相关参数写入Flash
;
;	input  : no
;	OUTPUT : no
;###############################################################################
DAM_ATT_WRITE:
;---
	MAR	+0,1
	LARL	CTEL_BASE,1
;---Word1 ==> ps1,2,3,4
	LAC	PASSWORD
	SAH	+
;---Word2 ==> lc1,2,3,4
	LAC	LOCACODE
	SAH	+
;---Word3 ==> pause time(15..12)/flash time(11..10)/Language(9,8)/ring melody(7..4)/LCD constrast(3..0)
	LAC	DAM_ATT
	SAH	+
;---Word4 ==> 
	LAC	DAM_ATT0
	SAH	+
;---Word5 ==> 
	LAC	DAM_ATT1
	SAH	+
;---Word6 ==> 
	LAC	EVENT
	ANDL	0XFF00
	SAH	+
;---------------------------------------
	CALL	DAT_WRITE

	RET
;-------------------------------------------------------------------------------
	
.END
