.LIST
;-------------------------------------------------------------------------
;	Function : MOVE_DAT	
;	����ADDR_SΪ��ʼ��ַ�����ݷŵ���ADDR_DΪ��ʼ��ַ������(���word)
;	INPUT : ACCH = the length you will move(word)
;	output: no
;-------------------------------------------------------------------------
MOVE_DAT:		;���ڵ�ַ���������ԭ��(�ȸߵ�ַ),�ʺϵ͵�ַ��������ߵ�ַ���ƶ�
	SBHK	1
	SAH	SYSTMP1		;Offset=length-1

	LAC	ADDR_S
	ADH	SYSTMP1
	SAH	ADDR_S
	
	LAC	ADDR_D
	ADH	SYSTMP1
	SAH	ADDR_D

	LAR	ADDR_S,1
	LAR	ADDR_D,2
	MAR	+0,1
MOVE_DAT_LOOP:
	LAC	SYSTMP1
	BS	SGN,MOVE_DAT_END

	LAC	-,2
	SAH	-,1

	LAC	SYSTMP1
	SBHK	1
	SAH	SYSTMP1
	BS	B1,MOVE_DAT_LOOP
MOVE_DAT_END:	
	RET

;-------------------------------------------------------------------------------
.END
