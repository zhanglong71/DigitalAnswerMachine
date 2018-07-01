.LIST
;-------------------------------------------------------------------------------
;	Function : SYS_MONITOR
;	���˿�״̬��һЩ��Ҫ��ʵʱͬ�����¼�
;-------------------------------------------------------------------------------
SYS_MONITOR:
;-------��ʼʱ����ʽѡ��12/24---------------------------------------------------
.if	0
SYS_SELTIME:
	LIPK	8
	IN      SYSTMP0,GPBD
	BIT	SYSTMP0,3
	BS	TB,SYS_SELTIME2
SYS_SELTIME1:
	BIT	EVENT,11
	BZ	TB,INI_SELTIME_END

	LAC	EVENT
	ANDL	~(1<<11)
	SAH	EVENT		;(GPBD.3 = 0)�б仯
	;CRAM	EVENT,11
	BS	B1,SYS_SELTIME_CHANGED	
SYS_SELTIME2:
	BIT	EVENT,11
	BS	TB,INI_SELTIME_END
	
	LAC	EVENT
	ORL	1<<11		;???????????????????????????
	SAH	EVENT		;(GPBD.3 = 0)�б仯
SYS_SELTIME_CHANGED:
	LACL	CMSG_TIFAT
	CALL	STOR_MSG
INI_SELTIME_END:
.endif
;---------------4.8/9.6kbps-----------------------------------------------------
.IF	1
SYS_MONI_SELCOMPRESS:
	LIPK	8
	IN      SYSTMP0,GPBD
	BIT	SYSTMP0,1
	BS	TB,SYS_MONI_SELCOMPS_HIGH
;SYS_MONI_SELCOMPRESS_LOW:
	LAC	ANN_FG
	ANDL	~(1<<15)
	SAH	ANN_FG
	BS	B1,SYS_MONI_SELCOMPRESS_END
SYS_MONI_SELCOMPS_HIGH:
	
	LAC	ANN_FG
	ORL	1<<15
	SAH	ANN_FG
SYS_MONI_SELCOMPRESS_END:
.ENDIF
;-------------------------------------------------------------------------------	
	RET	

;-------------------------------------------------------------------------------

.END
