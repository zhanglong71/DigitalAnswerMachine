.LIST
;-------------------------------------------------------------------------------
MAIN_PRO6:		;��������״̬Ҫ���ǵ���Ϣ
	LAC	MSG
	XORL	CMSG_KEYAS
	BS	ACZ,MAIN_PRO6_EXIT	;VOL+
	
	LAC	MSG
	XORL	CMSG_KEYBS
	BS	ACZ,MAIN_PRO6_EXIT	;VOL-
	
	LAC	MSG
	XORL	CMSG_KEY3S
	BS	ACZ,MAIN_PRO6_EXIT	;OGM
	
	LAC	MSG
	XORL	CMSG_KEY3L
	BS	ACZ,MAIN_PRO6_EXIT	;OGM_
	
	LAC	MSG
	XORL	CMSG_KEY1S
	BS	ACZ,MAIN_PRO6_EXIT	;PLAY
	
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,MAIN_PROX_RINGIN
	
	LAC	PRO_VAR
	SFR	4
	ANDK	0X0F
	BS	ACZ,MAIN_PRO6_0		;����
	SBHK	1
	BS	ACZ,MAIN_PRO6_1		;�κ�
	SBHK	1
	BS	ACZ,MAIN_PRO6_2		;ɾ��
	
	RET
MAIN_PRO6_EXIT:		;��Ӧ�������ܶ��˳�
	LACK	0
	SAH	PRO_VAR
	SAH	PRO_VAR1
	
	;LACL	0X86
	;CALL	STOR_DAT
	;LACL	0XFF
	;CALL	STOR_DAT

	LAC	MSG
	CALL	STOR_MSG
	
	RET
MAIN_PRO6_0:
	
	LAC	PRO_VAR
	SFR	8
	ANDK	0X0F
	BS	ACZ,MAIN_PRO6_0_0
	SBHK	1
	BS	ACZ,MAIN_PRO6_0_1	;���벢������
	;SBHK	1
	;BS	ACZ,MAIN_PRO6_0_2	;���뱣����(�������绰��)
	RET
MAIN_PRO6_0_0:
;MAIN_PRO6_0_0_1:
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,MAIN_PRO6_0_0_REW	;REW
;MAIN_PRO6_0_0_2:	
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO6_0_0_FFW	;FFW
;MAIN_PRO6_0_0_3:	
	LAC	MSG
	XORL	CMSG_KEY8P
	BS	ACZ,MAIN_PRO6_0_0_PREW	;REW
;MAIN_PRO6_0_0_4:	
	LAC	MSG
	XORL	CMSG_KEYCP
	BS	ACZ,MAIN_PRO6_0_0_PFFW	;FFW
;MAIN_PRO6_0_0_5:
	LAC	MSG
	XORL	CMSG_KEY9S
	BS	ACZ,MAIN_PRO6_0_0_MENU	;MENU
;MAIN_PRO6_0_0_6:
	LAC	MSG
	XORL	CMSG_KEY2S
	BS	ACZ,MAIN_PRO6_0_0_TIME	;������ȡ
;MAIN_PRO6_0_0_7:
	LAC	MSG
	XORL	CMSG_KEY6S
	BS	ACZ,MAIN_PRO6_0_0_END	;STOP
;MAIN_PRO6_0_0_8:
	LAC	MSG
	XORL	CMSG_KEY5S
	BS	ACZ,MAIN_PRO6_0_0_ERAONE	;
;MAIN_PRO6_0_0_9:
	LAC	MSG
	XORL	CMSG_KEY5L
	BS	ACZ,MAIN_PRO6_0_0_ERAALL	;
;MAIN_PRO6_0_0_10:
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,MAIN_PRO6_0_0_TMR	;
;MAIN_PRO6_0_0_11:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,MAIN_PRO6_0_0_VPSTOP	;
;MAIN_PRO6_0_0_12:
	
		
	RET
MAIN_PRO6_0_1_SENDCOMM:
	CALL	TEL_SENDCOMM	
	BS	ACZ,MAIN_PRO6_0_SENDCOMM_END	;start||continue
	SBHK	1
	BS	ACZ,MAIN_PRO6_0_1_SENDCOMM_1	;over
	;SBHK	1
	;BS	ACZ,MAIN_PRO6_0_SENDCOMM_END	;display
	
	LACL	0XCA
	CALL	STOR_DAT
	LAC	MSG_ID
	CALL	STOR_DAT	;��ʾ����
	LACL	0XFF
	CALL	STOR_DAT
	
	RET
MAIN_PRO6_0_1_SENDCOMM_1:	
	LACK	0X006
	SAH	PRO_VAR
MAIN_PRO6_0_SENDCOMM_END:
	
	RET

MAIN_PRO6_0_0_VPSTOP:
	LACK	0
	SAH	PRO_VAR1		;����������(�����ɿ���BEEP����)	
	CALL	DAA_OFF
	
	RET
MAIN_PRO6_0_0_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	30
	BZ	SGN,MAIN_PRO6_0_0_END

	RET
MAIN_PRO6_0_0_TIME:
	LAC	MSG_ID
	BS	ACZ,MAIN_PRO6_WARN	;����Ŀ��Ϊ��,����ת��
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
	
	LACK	NEW_ID
	SAH	ADDR_D		;�����ַ
	LAC	MSG_ID		;��Ŀ��
	CALL	READ_TELNUM	;����ǰ��Ŀ����
	CALL	STOPREADDAT
	
	LAC	NEW_ID
	ANDK	0X7F
	SAH	FILE_LEN	;�ȱ���flag��Ϣ(ֻ�����)
;---������ԭ��չ��
	LACK	NEW1
	SAH	ADDR_S
	SAH	ADDR_D

	LAC	FILE_LEN
	ANDK	0X7F
	CALL	DECONCEN_DAT
;---�������Ƶ���ĵط��ݴ�
	LACK	NEW1		;��NEW1��ʼ�ĵط�ȡ����
	SAH	ADDR_S
	ADHK	9		;���ݴ浽��NEW9+1Ϊ��ʼ��ַ�Ŀռ�
	SAH	ADDR_D
	LACK	9
	CALL	MOVE_DAT	;�ƶ�9 words
	
	;LACK	NEW1
	;ADHK	9
	;SAH	ADDR_S
	;SAH	ADDR_D		;ת�������Ŀ�ʼ��ַ

	;LAC	FILE_LEN
	;ANDK	0X7F
	;CALL	DECONCEN_DAT	;������ԭ��չ��
;-------д��FLASH����	
	LACK	4
	CALL	SET_TELGROUP
	CALL	GET_TELT
	SAH	MSG_T		;ȡ����
	
	
	LACL	0X9E		;����mcuת�����
	CALL	STOR_DAT
	LACK	2
	CALL	STOR_DAT
	LACL	0XFF
	CALL	STOR_DAT
	BS	B1,MAIN_PRO10_2_0_0_MENU_1
MAIN_PRO6_WARN:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BBBEEP
	
	RET
;-------------------------------------------------------------------------------	
MAIN_PRO6_0_0_REW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
MAIN_PRO6_0_0_PREW:	
	LACK	0
	SAH	SYSTMP1
	LAC	MSG_T
	SAH	SYSTMP2

	LAC	MSG_ID
	CALL	VALUE_SUB
	SAH	MSG_ID
MAIN_PRO6_0_REWFFW_TEL:	
	;LAC	MSG_T
	;BS	ACZ,MAIN_PRO6_WARN	;����Ŀ��Ϊ��,���ܷ���
	
	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER
	
	LACL	0X106
	SAH	PRO_VAR
	
	LACK	RECE_BUF11
	SAH	ADDR_D		;�����ַ
	LAC	MSG_ID		;��Ŀ��
	CALL	READ_TELNUM	;����ǰ��Ŀ����
	CALL	STOPREADDAT
	
	LACK	RECE_BUF11
	SAH	ADDR_S
	CALL	SET_WAITFG
	SRAM	EVENT,10
;---����־
	LACL	0X80
	CALL	STOR_DAT
	LACL	0X80
	CALL	STOR_DAT
	LACK	RECE_BUF11
	SAH	ADDR_S		;BASE
	LACK	0
	SAH	COUNT		;offset
	LACK	4		;length
	CALL	TOSENDBUF
	LACL	0XFF
	CALL	STOR_DAT

	RET
;-------
MAIN_PRO6_0_0_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
MAIN_PRO6_0_0_PFFW:
	LACK	0
	SAH	SYSTMP1
	LAC	MSG_T
	SAH	SYSTMP2

	LAC	MSG_ID
	CALL	VALUE_ADD
	SAH	MSG_ID
	BS	B1,MAIN_PRO6_0_REWFFW_TEL
	
MAIN_PRO6_0_0_MENU:		;����绰��ʱ�ذ�����ת����
	LAC	MSG_ID
	BS	ACZ,MAIN_PRO6_WARN	;;��Ŀ��Ϊ��,���ܻذ�
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
	
	LACK	0X16
	SAH	PRO_VAR
	
	LACK	0
	SAH	PRO_VAR1	;���¿�ʼ��ʱ,�����ذ���������
	LACL	1000
	CALL	SET_TIMER
	
	RET

MAIN_PRO6_0_0_END:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BBEEP
	
	LACK	0
	SAH	PRO_VAR

	LACL	0X9E
	CALL	STOR_DAT
	LACK	6
	CALL	STOR_DAT
	
	RET
MAIN_PRO6_0_0_ERAONE:
	LAC	MSG_ID
	BS	ACZ,MAIN_PRO6_WARN	;��Ŀ��Ϊ��,����ɾ��
	
	LACL	0X126
	SAH	PRO_VAR
	
	LACL	0XCC
	CALL	STOR_DAT
	LACK	0
	CALL	STOR_DAT	;ɾ��?
	
	BS	B1,MAIN_PRO6_0_ERABEEP
MAIN_PRO6_0_0_ERAALL:
	LACL	0X226
	SAH	PRO_VAR
	
	LACL	0XCC
	CALL	STOR_DAT
	LACK	2
	CALL	STOR_DAT	;ɾ��
MAIN_PRO6_0_ERABEEP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP

	RET
;-----------------------------------------------------------
MAIN_PRO6_0_1:		;������벢������,����Ӧ
;MAIN_PRO6_0_1_1:
	LAC	MSG	
	XORL	CBUF_EMPTY
	BS	ACZ,MAIN_PRO6_0_1_SENDCOMM
;MAIN_PRO6_0_1_2:	
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,MAIN_PRO6_0_1_SENDCOMM_1	;һ����,��ͨ�Ź�������
;MAIN_PRO6_0_1_3:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,MAIN_PRO6_0_0_VPSTOP	;	
	RET

;-------------------------------------------------------------------------------	
MAIN_PRO6_1:
	LAC	PRO_VAR
	SFR	8
	BS	ACZ,MAIN_PRO6_1_0	;�ȴ�(�κŷ�ʽ)
	SBHK	1
	BS	ACZ,MAIN_PRO6_1_1	;��ʽ�κ�
	
	RET
MAIN_PRO6_1_0:
;MAIN_PRO6_1_0_0:
	LAC	MSG
	XORL	CMSG_KEY9S
	BS	ACZ,MAIN_PRO6_1_0_MENU	;MENU
;MAIN_PRO6_1_0_1	
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,MAIN_PRO6_1_0_TMR	;TMR
	
	RET
MAIN_PRO6_1_0_MENU:	;��0�κ�
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP

	LACL	0X116
	SAH	PRO_VAR
	
	CALL	HOOK_ON
;!!!!!!!!!!!!!!!    	
     	LACL	0XD0		;����MCUժ����
	CALL	STOR_DAT
	LACK	0
	CALL	STOR_DAT
	LACL	0XFF
	CALL	STOR_DAT
		
	LACL	0X9E		;����MCU�κ�
	CALL	STOR_DAT
	LACK	4
	CALL	STOR_DAT

;!!!!!!!!!!!!!!!
	LACK	0
	SAH	PRO_VAR1
	
	RET
MAIN_PRO6_1_0_TMR:	;�κ�
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	2
	BS	SGN,MAIN_PRO6_1_0_TMR_END
	
	LACL	0X116
	SAH	PRO_VAR

	LACK	0
	SAH	PRO_VAR1
	CALL	HOOK_ON
;!!!!!!!!!!!!!!!    	
     	LACL	0XD0		;����MCUժ����
	CALL	STOR_DAT
	LACK	0
	CALL	STOR_DAT
	LACL	0XFF
	CALL	STOR_DAT
	
	LACL	0X9E		;����MCU�κ�
	CALL	STOR_DAT
	LACK	3
	CALL	STOR_DAT

;!!!!!!!!!!!!!!!
MAIN_PRO6_1_0_TMR_END:
	RET
;---------------------------------------------------------------------
MAIN_PRO6_1_1:
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,MAIN_PRO6_1_1_TMR	;TMR
	
	RET
MAIN_PRO6_1_1_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	8
	BS	SGN,MAIN_PRO6_1_0_TMR_END	;�����κ������8sec�˳�
	
	LACK	0
	SAH	PRO_VAR
;!!!!!!!!!!!!!!!
	LACL	0XD0		;����MCU�һ���
	CALL	STOR_DAT
	LACK	1
	CALL	STOR_DAT
	LACL	0XFF
	CALL	STOR_DAT
;!!!!!!!!!!!!!!!		
	;LACL	0X9E
	;CALL	STOR_DAT
	;LACK	6
	;CALL	STOR_DAT
	
	CALL	HOOK_OFF

	LACL	CMSG_INIT
   	CALL	STOR_MSG
MAIN_PRO6_1_1_TMR_END:	
	RET
;---------------------------------------------------------------------
MAIN_PRO6_2:
;MAIN_PRO6_2_X_1:
	LAC	MSG
	XORL	CMSG_KEY5S
	BS	ACZ,MAIN_PRO6_2_ERASE	;ERASE
;MAIN_PRO6_2_X_2:
	LAC	MSG
	XORL	CMSG_KEY6S
	BS	ACZ,MAIN_PRO6_2_END	;ON/OFF
	
	RET
MAIN_PRO6_2_ERASE:	
	LAC	PRO_VAR
	SFR	8
	ANDK	0X0F
	SBHK	1
	BS	ACZ,MAIN_PRO6_2_1	;ɾ����ǰ
	SBHK	1
	BS	ACZ,MAIN_PRO6_2_2	;�ȴ��ͷ�
	SBHK	1
	BS	ACZ,MAIN_PRO6_2_3	;ɾ������
	
	RET
MAIN_PRO6_2_1:			;ȷ��ɾ����ǰ����
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
MAIN_PRO6_2_1_EXE:	
	LAC	MSG_ID
	CALL	DEL_ONETEL	;ɾ��
	CALL	TEL_GC_CHK
	CALL	GC_CHK

	CALL	GET_TELT
	SBH	MSG_T
	BS	ACZ,MAIN_PRO6_2_1_EXE	;ɾ�����ɹ�������һ��

	CALL	GET_TELT
	SAH	MSG_T		;���¾�����֮ǰ
	
	LACK	0X06
	SAH	PRO_VAR

;!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X82		;�¾�����ͬ��
	CALL	STOR_DAT
	LACK	0	;???????????????
	CALL	STOR_DAT
	LAC	MSG_T
	CALL	STOR_DAT
	
	LACL	0XFF
	CALL	STOR_DAT
;!!!!!!!!!!!!!!!
	LAC	MSG_ID
	SBHK	1
	SAH	MSG_ID
	SBH	MSG_T			;���һ����?
	BS	SGN,MAIN_PRO6_0_0_PFFW

	LACL	0XCA
	CALL	STOR_DAT
	LACK	0X0
	SAH	MSG_ID
	CALL	STOR_DAT
	
	LACL	0XFF
	CALL	STOR_DAT

	RET
MAIN_PRO6_2_2:
	LACL	0X0326
	SAH	PRO_VAR
	
	RET
MAIN_PRO6_2_3:		;ȷ��ɾ������
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BBEEP
	
	LACL	0XCC
	CALL	STOR_DAT
	LACK	3
	CALL	STOR_DAT
	
	LACL	0XFF
	CALL	STOR_DAT
MAIN_PRO6_2_3_EXE:
	CALL	GET_TELT
	CALL	DEL_ALLTEL	;ɾ����������
	CALL	TEL_GC_CHK
	CALL	GC_CHK
	
	CALL	GET_TELT
	BZ	ACZ,MAIN_PRO6_2_3_EXE	;ɾ�����ɹ�������һ��
	
	LACL	0X9E
	CALL	STOR_DAT
	LACK	6
	CALL	STOR_DAT
	
	LACK	0
	SAH	PRO_VAR
	
	RET
MAIN_PRO6_2_END:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
	
	LACL	0XCA
	CALL	STOR_DAT
	LAC	MSG_ID
	CALL	STOR_DAT
	
	LACK	0X06
	SAH	PRO_VAR
	
	RET
;-------------------------------------------------------------------------------

.END
