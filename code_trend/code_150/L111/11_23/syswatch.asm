.LIST
;-------------------------------------------------------------------------------
;	Function : SYS_MONITOR
;	���˿�״̬��һЩ��Ҫ��ʵʱͬ�����¼�
;-------------------------------------------------------------------------------
SYS_MONITOR:
;---------------Ӧ��ʱ�Ƿ�¼
SYS_MONI_SELOGM:
	LIPK    0
        IN      SYSTMP1,BIOR
	BIT	SYSTMP1,2
	BZ	TB,SYS_MONI_SELOGM2
;SYS_MONI_SELOGM1:	
	CRAM	EVENT,8		;answer and record(BIOR.2 = 1)
	BS	B1,SYS_MONI_SELOGM_END
SYS_MONI_SELOGM2:	
	SRAM	EVENT,8		;answer only(BIOR.2 = 0)
SYS_MONI_SELOGM_END:
;---------------4.8/12.8kbps
.IF	1
SYS_MONI_SELCOMPRESS:
	BIT	KEY,12
	BZ	TB,SYS_MONI_SELCOMPS_48
;SYS_MONI_SELCOMPS_128:
	SRAM	ANN_FG,15
	BS	B1,SYS_MONI_SELCOMPRESS_END
SYS_MONI_SELCOMPS_48:
	CRAM	ANN_FG,15
SYS_MONI_SELCOMPRESS_END:
.ELSE	;--------------

.ENDIF
;-------------------------------------------------------------------------------	
	RET	

;-------------------------------------------------------------------------------

.END
