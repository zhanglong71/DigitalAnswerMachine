.LIST
;-------------------------------------------------------------------------
;	Function : STORBYTE_DAT	
;	�����ݴ�����ADDR_DΪ��ʼ��ַ��OFFSET_DΪoffset�Ŀռ�(һ���ֽ�),Ȼ��OFFSET_D��1
;	INPUT : ACCH = the data you will stor
;		OFFSET_D = the offset you will stor data
;		ADDR_D = the BASE you will stor data
;	output: no
;
;!!!NOTE: Only OFFSET_D changed,no another temporary changed
;
;-------------------------------------------------------------------------
STORBYTE_DAT:
	DINT	;????????????????????????????
	PSH	SYSTMP1
	PSH	SYSTMP2
	
	ANDL	0XFF
	SAH	SYSTMP2		;stor DAT
STORBYTEDAT_STOR:
	LAC	OFFSET_D
	SFR	1
	ADH	ADDR_D
	SAH	SYSTMP1		;GET ADDR(row)
	
	LAC	OFFSET_D
	ADHK	1
	SAH	OFFSET_D	;!!!Update for next Byte(offset_d��Ӧ��һ����ַ������������ж�Ҫע��)

	MAR	+0,1
	LAR	SYSTMP1,1

	LAC	OFFSET_D
	ANDK	0X01			;GET ADDR(col)
	BS	ACZ,STORBYTEDAT_STOR2
	
	LAC	+0,1		;���ַ
	ANDL	0XFF00
	OR	SYSTMP2
	SAH	+0,1
	BS	B1,STORBYTEDAT_END	
STORBYTEDAT_STOR2:		;ż��ַ
	LAC	+0,1	
	ANDL	0XFF
	SAH	+0,1
	
	LAC	SYSTMP2
	SFL	8
	ANDL	0XFF00
	OR	+0,1
	SAH	+0,1
STORBYTEDAT_END:
	POP	SYSTMP2
	POP	SYSTMP1	
	EINT	;????????????????????????
	RET
;-------------------------------------------------------------------------------
.END
