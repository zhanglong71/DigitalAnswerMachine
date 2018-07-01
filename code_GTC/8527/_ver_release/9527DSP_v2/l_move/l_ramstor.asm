.LIST
;-------------------------------------------------------------------------------
;	Function : RAM_STOR
;	����ʼ��ַΪ(ADDR_D,OFFSET_D),����ΪCOUNT�ĵط�,�������
;	INPUT : ACCH = Ҫ��������
;		COUNT = Ҫ�������ݵĳ���byte
;		OFFSET_D = the offset
;		ADDR_D = BASE address
;	OUTPUT: no
;NOTE : move low address data first(ADDR_S+OFFSET_S/2 > ADDR_D+OFFSET_D/2)
;-------------------------------------------------------------------------------
RAM_STOR:
	SAH	SYSTMP1
RAM_STOR_LOOP:	
	LAC	COUNT
	SBHK	1
	SAH	COUNT
	BS	SGN,RAM_STOR_END

	LAC	SYSTMP1
	CALL	STORBYTE_DAT
	BS	B1,RAM_STOR_LOOP
RAM_STOR_END:
	
	RET
;-------------------------------------------------------------------------------
.END
