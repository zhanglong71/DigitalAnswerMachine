.LIST
;############################################################################
;       Function : TEL_IICREAD
;	����TEL_ID�ӵ�ǰGroup�����绰����(����Ŀ��ȫ��),���뷢�ͻ�����
;
;	input  : ACCH = TEL_ID
;	OUTPUT : no
;
;	variable:SYSTMP0,SYSTMP1
;############################################################################
TEL_IICREAD:
	SAH	SYSTMP1
TEL_IICREAD_LOOP:
	LAC	SYSTMP1
	ORL	0XE200
       	CALL    DAM_BIOSFUNC
       	SAH	SYSTMP0
       	SFR     8
	BZ	ACZ,TEL_IICREAD_END
	LAC	SYSTMP0
	CALL	SEND_DAT
	BS	B1,TEL_IICREAD_LOOP
TEL_IICREAD_END:

	RET

;-------------------------------------------------------------------------------
.END
