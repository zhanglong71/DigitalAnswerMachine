.LIST
;-------------------------------------------------------------------------------
;PRO_VAR(7..4)��ʾ�˴˶εĹ���
;-------------------------------------------------------------------------------
MAIN_PRO9:				;MENU����״̬Ҫ���ǵ���Ϣ(PRO_VAR)
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,MAIN_PROX_RINGIN
	
	LAC	PRO_VAR
	SFR	4
	ANDK	0X0F
	BS	ACZ,MAIN_PRO9_0		;language
	SBHK	1
	BS	ACZ,MAIN_PRO9_1		;date/time
	SBHK	1
	BS	ACZ,MAIN_PRO9_2		;contrast
	SBHK	1
	BS	ACZ,MAIN_PRO9_3		;password
	SBHK	1
	BS	ACZ,MAIN_PRO9_4		;local code
	SBHK	1
	BS	ACZ,MAIN_PRO9_5		;Rnt
	SBHK	1
	BS	ACZ,MAIN_PRO9_6		;OGM
	
	RET
;-------common respond
MAIN_PRO9_VPSTOP:
	LACK	0
	SAH	PRO_VAR1		;����������(�����ɿ���BEEP����)	
	CALL	DAA_OFF

	RET
MAIN_PRO9_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	30
	BZ	SGN,MAIN_PRO9_TMROVER
	
	RET
MAIN_PRO9_TMROVER:		;��ʱ�˳�
	BS	B1,MAIN_PRO9_X_STOP
;-----------------------------------------------------------	
MAIN_PRO9_0:				;adjust language
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,MAIN_PRO9_TMR	;TMR
	
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,MAIN_PRO9_VPSTOP	;VP end

	LAC	PRO_VAR
	SFR	8
	ANDK	0X0F
	BS	ACZ,MAIN_PRO9_0_0
	SBHK	1
	BS	ACZ,MAIN_PRO9_0_1

	RET
;---------------
MAIN_PRO9_0_0:
	LAC	MSG
	XORL	CMSG_KEY9S
	BS	ACZ,MAIN_PRO9_0_0_MENU	;MENU
	
	RET
MAIN_PRO9_0_0_MENU:
	LACL	0X0109	
	SAH	PRO_VAR
	
	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER		;�򿪶�ʱ,��������,��ʱ�˳�	

	RET
;-----------------------------------------------------------
MAIN_PRO9_0_1_MENU:		;����������һ��
	LAC	VOI_ATT
	ANDL	0XCFFF
        SAH	VOI_ATT
	LAC	NEW0
	SFL	12
	OR	VOI_ATT
	SAH	VOI_ATT		;dsp SAVE language set
	
	CALL	SENDLANGUAGE	;mcu SAVE
	LACL	0XFF
	CALL	STOR_DAT
;---
	LACK	10
	SAH	COUNT
	LAC	VOI_ATT
	SFR	12
	ANDK	0x03
	CALL	STORBYTE_DAT
	
	LACK	11
	SAH	COUNT
	LACL	0XFF
	CALL	STORBYTE_DAT	;��0XFF��β
;---
	LACK	1
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK
	CALL	GC_CHK
	
	CALL	TELNUM_WRITE	;д������
	CALL	DAT_WRITE_STOP
;---������һ��
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP

	LAC	TMR_HOUR
	SAH	NEW0		;CURRENT VALUE
	LACK	0
	SAH	NEW1		;MIN VALUE
	LACK	23
	SAH	NEW2		;MAX VALUE
	
	LACL	0X91
	SAH	NEW7		;COMMAND = 0X91+hour
	CALL	STOR_DAT
	LAC	NEW0
	CALL	STOR_DAT

	LACK	0X019
	SAH	PRO_VAR
	
	RET

;---------------------------------------------------------------------	
MAIN_PRO9_0_1:
;MAIN_PRO9_0_1_1:		
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,MAIN_PRO9_0_1_REW	;REW
;MAIN_PRO9_0_1_2:	
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO9_0_1_FFW	;FFW
;MAIN_PRO9_0_1_3:	
	LAC	MSG
	XORL	CMSG_KEY8P
	BS	ACZ,MAIN_PRO9_0_1_PREW	;REW
;MAIN_PRO9_0_1_4:	
	LAC	MSG
	XORL	CMSG_KEYCP
	BS	ACZ,MAIN_PRO9_0_1_PFFW	;FFW
;MAIN_PRO9_0_1_5:
	LAC	MSG
	XORL	CMSG_KEY9S
	BS	ACZ,MAIN_PRO9_0_1_MENU	;MENU
;MAIN_PRO9_0_1_6:
	LAC	MSG
	XORL	CMSG_KEY6S
	BS	ACZ,MAIN_PRO9_X_STOP	;STOP
	
	RET

;-------respond9-0-1(language)	
MAIN_PRO9_0_1_REW:	
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
MAIN_PRO9_0_1_PREW:
	LAC	NEW1
	SAH	SYSTMP1
	LAC	NEW2
	SAH	SYSTMP2

	LAC	NEW0
	CALL	VALUE_SUB
	SAH	NEW0
MAIN_PRO9_0_2_SENDCOMM:
	LAC	NEW7		;SEND COMMAND
	CALL	STOR_DAT
	LAC	NEW0
	CALL	STOR_DAT
	
	RET

MAIN_PRO9_0_1_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
MAIN_PRO9_0_1_PFFW:
	LAC	NEW1
	SAH	SYSTMP1
	LAC	NEW2
	SAH	SYSTMP2

	LAC	NEW0
	CALL	VALUE_ADD
	SAH	NEW0
	
	BS	B1,MAIN_PRO9_0_2_SENDCOMM

;-------------------------------------------------------------------------------
MAIN_PRO9_1:			;adjust time/date
	LAC	MSG
	XORL	CMSG_TMR		;TMR
	BS	ACZ,MAIN_PRO9_TMR
	
	LAC	PRO_VAR
	SFR	8
	ANDK	0X0F
	BS	ACZ,MAIN_PRO9_1_0	;display
	SBHK	1
	BS	ACZ,MAIN_PRO9_1_1	;adjust hour
	SBHK	1
	BS	ACZ,MAIN_PRO9_1_2	;adjust minute
	SBHK	1
	BS	ACZ,MAIN_PRO9_1_3	;adjust month
	SBHK	1
	BS	ACZ,MAIN_PRO9_1_4	;adjust day
	SBHK	1
	BS	ACZ,MAIN_PRO9_1_5	;adjust week

	RET
	
;-------respond-1-0(date/time)

MAIN_PRO9_1_0:		;adjust
	LACL	0X0119
	SAH	PRO_VAR

	LAC	MSG
	CALL	STOR_MSG

	RET

;-------------------------------------------------------------------------------
MAIN_PRO9_1_1:				;adjust hour
;MAIN_PRO9_1_1_0:	
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,MAIN_PRO9_VPSTOP	;VP end
;MAIN_PRO9_1_1_1:		
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,MAIN_PRO9_1_X_REW	;REW
;MAIN_PRO9_1_1_2:	
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO9_1_X_FFW	;FFW
;MAIN_PRO9_1_1_3:	
	LAC	MSG
	XORL	CMSG_KEY8P
	BS	ACZ,MAIN_PRO9_1_X_PREW	;REW
;MAIN_PRO9_1_1_4:	
	LAC	MSG
	XORL	CMSG_KEYCP
	BS	ACZ,MAIN_PRO9_1_X_PFFW	;FFW
;MAIN_PRO9_1_1_5:
	LAC	MSG
	XORL	CMSG_KEY9S
	BS	ACZ,MAIN_PRO9_1_1_MENU	;MENU
;MAIN_PRO9_1_1_6:
	LAC	MSG
	XORL	CMSG_KEY6S
	BS	ACZ,MAIN_PRO9_X_STOP	;STOP

	RET
;-------respond9-1-1(hour)
MAIN_PRO9_1_1_MENU:		;�ȱ����޸�
	LAC	NEW0
	SAH	TMR_HOUR
	
	CALL	SENDTIME
	LACL	0XFF
	CALL	STOR_DAT
;---
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
	
	LACL	0X0219
	SAH	PRO_VAR

	LAC	TMR_MIN
	SAH	NEW0		;CURRENT VALUE
	LACK	0
	SAH	NEW1		;MIN VALUE
	LACK	59
	SAH	NEW2		;MAX VALUE
	
	LACL	0X92		;COMMAND = 0X92+value
	SAH	NEW7
MAIN_PRO9_1_X_SENDCOMM:
	LAC	NEW7
	CALL	STOR_DAT
	LAC	NEW0
	CALL	STOR_DAT

	RET

MAIN_PRO9_1_X_REW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP

MAIN_PRO9_1_X_PREW:
	LAC	NEW1
	SAH	SYSTMP1
	LAC	NEW2
	SAH	SYSTMP2

	LAC	NEW0
	CALL	VALUE_SUB
	SAH	NEW0

	BS	B1,MAIN_PRO9_1_X_SENDCOMM

MAIN_PRO9_1_X_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
MAIN_PRO9_1_X_PFFW:
	LAC	NEW1
	SAH	SYSTMP1
	LAC	NEW2
	SAH	SYSTMP2

	LAC	NEW0
	CALL	VALUE_ADD
	SAH	NEW0
	
	BS	B1,MAIN_PRO9_1_X_SENDCOMM

;-----------------------------------------------------------
MAIN_PRO9_1_2:		;adjust minute
;MAIN_PRO9_1_2_0:	
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,MAIN_PRO9_VPSTOP	;VP end
;MAIN_PRO9_1_2_1:		
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,MAIN_PRO9_1_X_REW	;REW
;MAIN_PRO9_1_2_2:	
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO9_1_X_FFW	;FFW
;MAIN_PRO9_1_2_3:	
	LAC	MSG
	XORL	CMSG_KEY8P
	BS	ACZ,MAIN_PRO9_1_X_PREW	;REW
;MAIN_PRO9_1_2_4:	
	LAC	MSG
	XORL	CMSG_KEYCP
	BS	ACZ,MAIN_PRO9_1_X_PFFW	;FFW
;MAIN_PRO9_1_2_5:
	LAC	MSG
	XORL	CMSG_KEY9S
	BS	ACZ,MAIN_PRO9_1_2_MENU	;MENU
;MAIN_PRO9_1_2_6:
	LAC	MSG
	XORL	CMSG_KEY6S
	BS	ACZ,MAIN_PRO9_X_STOP	;STOP

	RET
;-------respond9-1-2(minute)
MAIN_PRO9_1_2_MENU:
	LAC	NEW0
	SAH	TMR_MIN
	
	CALL	SENDTIME
	LACL	0XFF
	CALL	STOR_DAT
;---
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
	
	LACL	0X0319
	SAH	PRO_VAR

	LAC	TMR_MONTH
	SAH	NEW0		;CURRENT VALUE
	LACK	1
	SAH	NEW1		;MIN VALUE
	LACK	12
	SAH	NEW2		;MAX VALUE
;---	
	LACL	0X93		;COMMAND = 0X93+value
	SAH	NEW7
	BS	B1,MAIN_PRO9_1_X_SENDCOMM
;-----------------------------------------------------------	
MAIN_PRO9_1_3:		;adjust month
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,MAIN_PRO9_VPSTOP	;VP end
;MAIN_PRO9_1_3_1:		
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,MAIN_PRO9_1_X_REW	;REW
;MAIN_PRO9_1_3_2:	
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO9_1_X_FFW	;FFW
;MAIN_PRO9_1_3_3:	
	LAC	MSG
	XORL	CMSG_KEY8P
	BS	ACZ,MAIN_PRO9_1_X_PREW	;REW
;MAIN_PRO9_1_3_4:	
	LAC	MSG
	XORL	CMSG_KEYCP
	BS	ACZ,MAIN_PRO9_1_X_PFFW	;FFW
;MAIN_PRO9_1_3_5:
	LAC	MSG
	XORL	CMSG_KEY9S
	BS	ACZ,MAIN_PRO9_1_3_MENU	;MENU
;MAIN_PRO9_1_3_6:
	LAC	MSG
	XORL	CMSG_KEY6S
	BS	ACZ,MAIN_PRO9_X_STOP	;STOP	

	RET
;-------respond9-1-3(month)
MAIN_PRO9_1_3_MENU:
	LAC	NEW0
	SAH	TMR_MONTH
	
	CALL	SENDTIME
	LACL	0XFF
	CALL	STOR_DAT
;---
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
	
	LACL	0X0419
	SAH	PRO_VAR

	LAC	TMR_DAY
	SAH	NEW0		;CURRENT VALUE
	LACK	1
	SAH	NEW1		;MIN VALUE
	LACK	31
	SAH	NEW2		;MAX VALUE
;---
	LAC	TMR_MONTH
	SBHK	2
	BS	ACZ,MAIN_PRO9_1_3_MENU_2YUE	;February
	SBHK	2
	BS	ACZ,MAIN_PRO9_1_3_MENU_XYUE	;April
	SBHK	2
	BS	ACZ,MAIN_PRO9_1_3_MENU_XYUE	;June
	SBHK	3
	BS	ACZ,MAIN_PRO9_1_3_MENU_XYUE	;September
	SBHK	2
	BS	ACZ,MAIN_PRO9_1_3_MENU_XYUE	;November
	BS	B1,MAIN_PRO9_1_3_MENU_END
MAIN_PRO9_1_3_MENU_2YUE:
	LACK	29
	SAH	NEW2		;MAX VALUE(�����,ֻ�����)
	BS	B1,MAIN_PRO9_1_3_MENU_END
MAIN_PRO9_1_3_MENU_XYUE:
	LACK	30
	SAH	NEW2		;MAX VALUE
	BS	B1,MAIN_PRO9_1_3_MENU_END
MAIN_PRO9_1_3_MENU_END:
;---	
	LACL	0X94		;COMMAND = 0X94+value
	SAH	NEW7
	BS	B1,MAIN_PRO9_1_X_SENDCOMM

;-----------------------------------------------------------
MAIN_PRO9_1_4:		;adjust day
;MAIN_PRO9_1_4_0:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,MAIN_PRO9_VPSTOP	;VP end
;MAIN_PRO9_1_4_1:		
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,MAIN_PRO9_1_X_REW	;REW
;MAIN_PRO9_1_4_2:	
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO9_1_X_FFW	;FFW
;MAIN_PRO9_1_4_3:	
	LAC	MSG
	XORL	CMSG_KEY8P
	BS	ACZ,MAIN_PRO9_1_X_PREW	;REW
;MAIN_PRO9_1_4_4:	
	LAC	MSG
	XORL	CMSG_KEYCP
	BS	ACZ,MAIN_PRO9_1_X_PFFW	;FFW
;MAIN_PRO9_1_4_5:
	LAC	MSG
	XORL	CMSG_KEY9S
	BS	ACZ,MAIN_PRO9_1_4_MENU	;MENU
;MAIN_PRO9_1_4_6:
	LAC	MSG
	XORL	CMSG_KEY6S
	BS	ACZ,MAIN_PRO9_X_STOP	;STOP	

	RET
;-------respond9-1-4(day)
MAIN_PRO9_1_4_MENU:
	LAC	NEW0
	SAH	TMR_DAY
	
	CALL	SENDTIME
	LACL	0XFF
	CALL	STOR_DAT
;---
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
	
	LACL	0X0519
	SAH	PRO_VAR

	LAC	TMR_WEEK
	SAH	NEW0		;CURRENT VALUE
	LACK	0
	SAH	NEW1		;MIN VALUE
	LACK	6
	SAH	NEW2		;MAX VALUE
;---	
	LACL	0X95		;COMMAND = 0X93+value
	SAH	NEW7
	BS	B1,MAIN_PRO9_1_X_SENDCOMM

;-----------------------------------------------------------
MAIN_PRO9_1_5:		;adjust week
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,MAIN_PRO9_VPSTOP	;VP end
;MAIN_PRO9_1_5_1:		
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,MAIN_PRO9_1_X_REW	;REW
;MAIN_PRO9_1_5_2:	
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO9_1_X_FFW	;FFW
;MAIN_PRO9_1_5_3:	
	LAC	MSG
	XORL	CMSG_KEY8P
	BS	ACZ,MAIN_PRO9_1_X_PREW	;REW
;MAIN_PRO9_1_5_4:	
	LAC	MSG
	XORL	CMSG_KEYCP
	BS	ACZ,MAIN_PRO9_1_X_PFFW	;FFW
;MAIN_PRO9_1_5_5:
	LAC	MSG
	XORL	CMSG_KEY9S
	BS	ACZ,MAIN_PRO9_1_5_MENU	;MENU
;MAIN_PRO9_1_5_6:
	LAC	MSG
	XORL	CMSG_KEY6S
	BS	ACZ,MAIN_PRO9_X_STOP	;STOP	

	RET
;-------respond9-1-5(week)
MAIN_PRO9_1_5_MENU:
	LAC	NEW0
	SAH	TMR_WEEK
	
	CALL	SENDTIME
	LACL	0XFF
	CALL	STOR_DAT
;---
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP

	LACL	0X0029
	SAH	PRO_VAR
;---	
	LAC	LOCACODE1
	SFR	4
	ANDK	0x0F
	;LACK	3
	SAH	NEW0		;CURRENT VALUE
	LACK	1
	SAH	NEW1		;MIN VALUE
	LACK	5
	SAH	NEW2		;MAX VALUE

	LACL	0X96		;COMMAND = 0X96+value
	SAH	NEW7
	CALL	STOR_DAT
	LAC	NEW0
	CALL	STOR_DAT
	
	RET
;-------------------------------------------------------------------------------
MAIN_PRO9_2:			;adjust contrast
	LAC	MSG
	XORL	CMSG_TMR		;TMR
	BS	ACZ,MAIN_PRO9_TMR
	
	LAC	PRO_VAR
	SFR	8
	ANDK	0X0F
	BS	ACZ,MAIN_PRO9_2_0
	SBHK	1
	BS	ACZ,MAIN_PRO9_2_1
	
	RET
;-------------------------------------------------------------------------------
MAIN_PRO9_2_0:
	LACL	0X0129
	SAH	PRO_VAR

	LAC	MSG
	CALL	STOR_MSG
	
	RET
;-------------------------------------------------------------------------------
MAIN_PRO9_2_1:			;adjust contrast
;MAIN_PRO9_2_1_0:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,MAIN_PRO9_VPSTOP	;VP end
;MAIN_PRO9_2_1_1:		
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,MAIN_PRO9_2_1_REW	;REW
;MAIN_PRO9_2_1_2:	
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO9_2_1_FFW	;FFW
;MAIN_PRO9_2_1_3:	
	LAC	MSG
	XORL	CMSG_KEY8P
	BS	ACZ,MAIN_PRO9_2_1_PREW	;REW
;MAIN_PRO9_2_1_4:	
	LAC	MSG
	XORL	CMSG_KEYCP
	BS	ACZ,MAIN_PRO9_2_1_PFFW	;FFW
;MAIN_PRO9_2_1_5:
	LAC	MSG
	XORL	CMSG_KEY9S
	BS	ACZ,MAIN_PRO9_2_1_MENU	;MENU
;MAIN_PRO9_2_1_6:	
	LAC	MSG
	XORL	CMSG_KEY6S
	BS	ACZ,MAIN_PRO9_2_STOP	;STOP(�����˳�,Ҫ�ָ���ǰ������)
	
	RET
;-------respond9-2-1(contrast)
MAIN_PRO9_2_STOP:
	LACL	0X87		;LCD ����
	CALL	STOR_DAT
	LAC	LOCACODE1
	SFR	4
	ANDK	0x07
	CALL	STOR_DAT
	LACL	0X0FF
	CALL	STOR_DAT
	
	BS	B1,MAIN_PRO9_X_STOP
MAIN_PRO9_2_1_REW:	
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
MAIN_PRO9_2_1_PREW:
	LAC	NEW1
	SAH	SYSTMP1
	LAC	NEW2
	SAH	SYSTMP2

	LAC	NEW0
	CALL	VALUE_SUB
	SAH	NEW0
MAIN_PRO9_2_1_SENDCOMM:		;Send and save LCD contrast
	
	LAC	NEW7		;SEND COMMAND
	CALL	STOR_DAT
	LAC	NEW0
	CALL	STOR_DAT
	
	RET
MAIN_PRO9_2_1_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
MAIN_PRO9_2_1_PFFW:
	LAC	NEW1
	SAH	SYSTMP1
	LAC	NEW2
	SAH	SYSTMP2

	LAC	NEW0
	CALL	VALUE_ADD
	SAH	NEW0
	BS	B1,MAIN_PRO9_2_1_SENDCOMM

MAIN_PRO9_2_1_MENU:
	LAC	LOCACODE1
	ANDL	0xFF0F
	SAH	LOCACODE1
	
	LAC	NEW0
	SFL	4
	ANDL	0x0F0
	OR	LOCACODE1
	SAH	LOCACODE1
;---	
	LACL	0X87		;LCD ����
	CALL	STOR_DAT
	LAC	NEW0
	CALL	STOR_DAT
	LACL	0X0FF
	CALL	STOR_DAT
;---
	LACK	9
	SAH	COUNT
	LAC	LOCACODE1
	SFR	4
	ANDK	0x07
	CALL	STORBYTE_DAT
	
	LACK	11
	SAH	COUNT
	LACL	0XFF
	CALL	STORBYTE_DAT	;��0XFF��β
;---
	LACK	1
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK
	CALL	GC_CHK
	
	CALL	TELNUM_WRITE	;д������
	CALL	DAT_WRITE_STOP
;---������һ��
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
	
	LACL	0X0039
	SAH	PRO_VAR
;---�Ȱ����ݷ���ȥ
	CALL	SENDPSWORD
	LACL	0X0FF
	CALL	STOR_DAT
;---�ٷ�������	
	LAC	PASSWORD
	SFR	8
	ANDK	0X0F
	SAH	NEW0		;CURRENT VALUE
	LACK	0
	SAH	NEW1		;MIN VALUE
	LACK	9
	SAH	NEW2		;MAX VALUE

	LACL	0X97		;COMMAND = 0X97+value
	SAH	NEW7
	CALL	STOR_DAT
	LAC	NEW0
	CALL	STOR_DAT

	RET

;-----------------------------------------------------------
MAIN_PRO9_3:
	LAC	MSG
	XORL	CMSG_TMR		;TMR
	BS	ACZ,MAIN_PRO9_TMR
	
	LAC	PRO_VAR
	SFR	8
	ANDK	0X0F
	BS	ACZ,MAIN_PRO9_3_0	;display
	SBHK	1
	BS	ACZ,MAIN_PRO9_3_1	;adjust ps1
	SBHK	1
	BS	ACZ,MAIN_PRO9_3_2	;adjust ps2
	SBHK	1
	BS	ACZ,MAIN_PRO9_3_3	;adjust ps3

	RET
MAIN_PRO9_3_0:
	LACL	0X0139
	SAH	PRO_VAR

	LAC	MSG
	CALL	STOR_MSG
	
	RET
;-----------------------------------------------------------
MAIN_PRO9_3_1:
;MAIN_PRO9_3_1_0:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,MAIN_PRO9_VPSTOP	;VP end
;MAIN_PRO9_3_1_1:		
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,MAIN_PRO9_3_X_REW	;REW
;MAIN_PRO9_3_1_2:	
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO9_3_X_FFW	;FFW
;MAIN_PRO9_3_1_3:	
	LAC	MSG
	XORL	CMSG_KEY8P
	BS	ACZ,MAIN_PRO9_3_X_PREW	;REW
;MAIN_PRO9_3_1_4:	
	LAC	MSG
	XORL	CMSG_KEYCP
	BS	ACZ,MAIN_PRO9_3_X_PFFW	;FFW
;MAIN_PRO9_3_1_5:
	LAC	MSG
	XORL	CMSG_KEY9S
	BS	ACZ,MAIN_PRO9_3_1_MENU	;MENU
;MAIN_PRO9_3_1_6:
	LAC	MSG
	XORL	CMSG_KEY6S
	BS	ACZ,MAIN_PRO9_X_STOP	;STOP(��һ�β������˳�,û��Ҫ���������)

	RET
MAIN_PRO9_3_1_MENU:
	LAC	PASSWORD
	ANDL	0XF0FF
	SAH	PASSWORD

	LAC	NEW0
	SFL	8
	ANDL	0X0F00
	OR	PASSWORD
	SAH	PASSWORD
	
	CALL	SENDPSWORD
	LACL	0XFF
	CALL	STOR_DAT
;---	
	LACK	0
	SAH	COUNT
	LAC	PASSWORD
	SFR	8
	CALL	STORBYTE_DAT
	;LACK	9
	LACK	11
	SAH	COUNT
	LACL	0XFF
	CALL	STORBYTE_DAT	;��0XFF��β

	;LACK	1
	;CALL	DEL_ONETEL
	;CALL	TEL_GC_CHK
	;CALL	GC_CHK
	
	;CALL	TELNUM_WRITE	;д������
	;CALL	DAT_WRITE_STOP
;---
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
	
	LACL	0X0239
	SAH	PRO_VAR
	
	LACL	0X98		;for ps2
	SAH	NEW7

	LAC	PASSWORD
	SFR	4
	ANDK	0X0F
	SAH	NEW0		;LOAD CURRENT VALUE(ps2)
MAIN_PRO9_3_X_SENDCOMM:
	LAC	NEW7		;SEND COMMAND
	CALL	STOR_DAT
	LAC	NEW0
	CALL	STOR_DAT

	RET

MAIN_PRO9_3_X_REW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
MAIN_PRO9_3_X_PREW:
	LAC	NEW1
	SAH	SYSTMP1
	LAC	NEW2
	SAH	SYSTMP2

	LAC	NEW0
	CALL	VALUE_SUB
	SAH	NEW0

	BS	B1,MAIN_PRO9_3_X_SENDCOMM

MAIN_PRO9_3_X_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
MAIN_PRO9_3_X_PFFW:
	LAC	NEW1
	SAH	SYSTMP1
	LAC	NEW2
	SAH	SYSTMP2

	LAC	NEW0
	CALL	VALUE_ADD
	SAH	NEW0
	
	BS	B1,MAIN_PRO9_3_X_SENDCOMM

;-----------------------------------------------------------
MAIN_PRO9_3_2:
;MAIN_PRO9_3_2_0:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,MAIN_PRO9_VPSTOP	;VP end
;MAIN_PRO9_3_2_1:		
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,MAIN_PRO9_3_X_REW	;REW
;MAIN_PRO9_3_2_2:	
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO9_3_X_FFW	;FFW
;MAIN_PRO9_3_2_3:	
	LAC	MSG
	XORL	CMSG_KEY8P
	BS	ACZ,MAIN_PRO9_3_X_PREW	;REW
;MAIN_PRO9_3_2_4:	
	LAC	MSG
	XORL	CMSG_KEYCP
	BS	ACZ,MAIN_PRO9_3_X_PFFW	;FFW
;MAIN_PRO9_3_2_5:
	LAC	MSG
	XORL	CMSG_KEY9S
	BS	ACZ,MAIN_PRO9_3_2_MENU	;MENU
;MAIN_PRO9_3_2_6:
	LAC	MSG
	XORL	CMSG_KEY6S
	BS	ACZ,MAIN_PRO9_3_STOP	;STOP(�ȱ���ǰ�������,���˳�)

	RET
MAIN_PRO9_3_2_MENU:
	LAC	PASSWORD
	ANDL	0XFF0F
	SAH	PASSWORD

	LAC	NEW0
	SFL	4
	ANDL	0X00F0
	OR	PASSWORD
	SAH	PASSWORD
	
	CALL	SENDPSWORD
	LACL	0XFF
	CALL	STOR_DAT
;---
	LACK	1
	SAH	COUNT
	LAC	PASSWORD
	SFR	4
	CALL	STORBYTE_DAT
	;LACK	9
	LACK	11
	SAH	COUNT
	LACL	0XFF
	CALL	STORBYTE_DAT	;��0XFF��β

	;LACK	1
	;CALL	DEL_ONETEL
	;CALL	TEL_GC_CHK
	;CALL	GC_CHK
	
	;CALL	TELNUM_WRITE	;д������
	;CALL	DAT_WRITE_STOP
;---�������
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
	
	LACL	0X0339
	SAH	PRO_VAR
	
	LACL	0X99		;for ps3
	SAH	NEW7

	LAC	PASSWORD
	ANDK	0X0F
	SAH	NEW0		;LOAD CURRENT VALUE(ps2)

	BS	B1,MAIN_PRO9_3_X_SENDCOMM
	
MAIN_PRO9_3_3:
;MAIN_PRO9_3_3_0:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,MAIN_PRO9_VPSTOP	;VP end
;MAIN_PRO9_3_3_1:		
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,MAIN_PRO9_3_X_REW	;REW
;MAIN_PRO9_3_3_2:	
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO9_3_X_FFW	;FFW
;MAIN_PRO9_3_3_3:	
	LAC	MSG
	XORL	CMSG_KEY8P
	BS	ACZ,MAIN_PRO9_3_X_PREW	;REW
;MAIN_PRO9_3_3_4:	
	LAC	MSG
	XORL	CMSG_KEYCP
	BS	ACZ,MAIN_PRO9_3_X_PFFW	;FFW
;MAIN_PRO9_3_3_5:
	LAC	MSG
	XORL	CMSG_KEY9S
	BS	ACZ,MAIN_PRO9_3_3_MENU	;MENU
;MAIN_PRO9_3_3_6:
	LAC	MSG
	XORL	CMSG_KEY6S
	BS	ACZ,MAIN_PRO9_3_STOP	;STOP(�ȱ���ǰ�������,���˳�)
	
	RET
MAIN_PRO9_3_STOP:
	
	LACK	1
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK
	CALL	GC_CHK
	
	CALL	TELNUM_WRITE	;д������
	CALL	DAT_WRITE_STOP
	
	BS	B1,MAIN_PRO9_X_STOP	;����ʱ�˳�
;---------------
MAIN_PRO9_3_3_MENU:
	LAC	PASSWORD
	ANDL	0XFFF0
	SAH	PASSWORD

	LAC	NEW0
	ANDK	0X00F
	OR	PASSWORD
	SAH	PASSWORD
	
	CALL	SENDPSWORD
	LACL	0XFF
	CALL	STOR_DAT

	LACK	2
	SAH	COUNT
	LAC	PASSWORD
	CALL	STORBYTE_DAT
	;LACK	9
	LACK	11
	SAH	COUNT
	LACL	0XFF
	CALL	STORBYTE_DAT	;��0XFF��β

	LACK	1
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK
	CALL	GC_CHK
	
	CALL	TELNUM_WRITE	;д������
	CALL	DAT_WRITE_STOP
;----------End password and begin local code
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
	
	LACL	0X0049		;PRO_VAR = 0X0049(display)
	SAH	PRO_VAR

	LAC	LOCACODE
	SFR	12
	ANDK	0X0F
	SAH	NEW1		;load local code 1
	SAH	MSG_N
	
	LAC	LOCACODE
	SFR	8
	ANDK	0X0F
	SAH	NEW2		;load local code 2
	
	LAC	LOCACODE
	SFR	4
	ANDK	0X0F
	SAH	NEW3		;load local code 3
	
	LAC	LOCACODE
	ANDK	0X0F
	SAH	NEW4		;load local code 4
	
	LAC	LOCACODE1
	ANDK	0X0F
	SAH	NEW5		;load local code 5

	LACL	200
	CALL	DELAY		;wait for command send
	
	CALL	SENDLOCACODE
	LACL	0XFF
	CALL	STOR_DAT
;---Display
	LACL	0X9A		;local code1
	SAH	MSG_ID
	CALL	STOR_DAT
	LAC	MSG_N		;
	CALL	STOR_DAT

	RET
;-----------------------------------------------------------
MAIN_PRO9_4:
	LAC	MSG
	XORL	CMSG_TMR		;TMR
	BS	ACZ,MAIN_PRO9_TMR
	
	LAC	PRO_VAR
	SFR	8
	ANDK	0X0F
	BS	ACZ,MAIN_PRO9_4_0	;display
	SBHK	1
	BS	ACZ,MAIN_PRO9_4_1	;adjust local code1
	SBHK	1
	BS	ACZ,MAIN_PRO9_4_2	;adjust local code2
	SBHK	1
	BS	ACZ,MAIN_PRO9_4_3	;adjust local code3
	SBHK	1
	BS	ACZ,MAIN_PRO9_4_4	;adjust local code4
	SBHK	1
	BS	ACZ,MAIN_PRO9_4_5	;adjust local code4

	RET

MAIN_PRO9_4_0:
	LACL	0X0149
	SAH	PRO_VAR

	LAC	MSG
	CALL	STOR_MSG

	RET
;-----------------------------------------------------------
MAIN_PRO9_4_1:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,MAIN_PRO9_VPSTOP	;VP end
;MAIN_PRO9_4_1_1:		
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,MAIN_PRO9_4_X_REW	;REW
;MAIN_PRO9_4_1_2:	
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO9_4_X_FFW	;FFW
;MAIN_PRO9_4_1_3:	
	LAC	MSG
	XORL	CMSG_KEY8P
	BS	ACZ,MAIN_PRO9_4_X_PREW	;REW
;MAIN_PRO9_4_1_4:	
	LAC	MSG
	XORL	CMSG_KEYCP
	BS	ACZ,MAIN_PRO9_4_X_PFFW	;FFW
;MAIN_PRO9_4_1_5:
	LAC	MSG
	XORL	CMSG_KEY9S
	BS	ACZ,MAIN_PRO9_4_1_MENU	;MENU
;MAIN_PRO9_4_1_6:
	LAC	MSG
	XORL	CMSG_KEY6S
	BS	ACZ,MAIN_PRO9_X_STOP	;STOP(��һ�β������˳�,û��Ҫ���������)
;MAIN_PRO9_4_1_7:
	LAC	MSG
	XORL	CMSG_KEY5S
	BS	ACZ,MAIN_PRO9_4_1_ERASE	;ERASE
	
	RET
;---------------
MAIN_PRO9_4_STOP:
	
	LAC	NEW1
	SFL	4
	OR	NEW2
	SFL	4
	OR	NEW3
	SFL	4
	OR	NEW4
	SAH	LOCACODE
	
	LAC	LOCACODE1
	ANDL	0xFFF0
	SAH	LOCACODE1
	
	LAC	NEW5
	ANDK	0x0F
	OR	LOCACODE1
	SAH	LOCACODE1
;---	
	CALL	SENDLOCACODE
	LACL	0XFF
	CALL	STOR_DAT
;----------
	LACK	3
	SAH	COUNT
	LAC	LOCACODE
	SFR	12
	CALL	STORBYTE_DAT
;-
	LACK	4
	SAH	COUNT
	LAC	LOCACODE
	SFR	8
	CALL	STORBYTE_DAT
;-
	LACK	5
	SAH	COUNT
	LAC	LOCACODE
	SFR	4
	CALL	STORBYTE_DAT
;-
	LACK	6
	SAH	COUNT
	LAC	LOCACODE
	CALL	STORBYTE_DAT
;-
	LACK	7
	SAH	COUNT
	LAC	LOCACODE1
	ANDK	0x0F
	CALL	STORBYTE_DAT
;-
	;LACK	9
	LACK	11
	SAH	COUNT
	LACL	0XFF
	CALL	STORBYTE_DAT	;��0XFF��β

	LACK	1
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK
	CALL	GC_CHK
	
	CALL	TELNUM_WRITE	;д������	
	CALL	DAT_WRITE_STOP
	BS	B1,MAIN_PRO9_X_STOP
;---------------
MAIN_PRO9_4_1_MENU:
	LAC	MSG_N		;blank ?
	ANDK	0X0F
	XORK	0X0A
	BS	ACZ,MAIN_PRO9_4_SAVE
	;BZ	SGN,MAIN_PRO9_4_SAVE

	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
	
	LAC	MSG_N
	SAH	NEW1		;Save Local code1

	LACL	0X0249
	SAH	PRO_VAR
	
	LACL	0X9B		;local code2
	SAH	MSG_ID
	
	LAC	NEW2
	SAH	MSG_N		;LOAD CURRENT VALUE(local code2)
MAIN_PRO9_4_X_SENDCOMM:
	LAC	MSG_ID
	CALL	STOR_DAT
	LAC	MSG_N
	CALL	STOR_DAT

	RET
MAIN_PRO9_4_X_REW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
MAIN_PRO9_4_X_PREW:
	LACK	0
	SAH	SYSTMP1
	LACK	9
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_SUB
	SAH	MSG_N
	BS	B1,MAIN_PRO9_4_X_SENDCOMM

MAIN_PRO9_4_X_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
MAIN_PRO9_4_X_PFFW:	
	LACK	0
	SAH	SYSTMP1
	LACK	9
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_ADD
	SAH	MSG_N

	BS	B1,MAIN_PRO9_4_X_SENDCOMM
	
MAIN_PRO9_4_1_ERASE:
	LAC	NEW2
	SAH	NEW1
	SAH	MSG_N		;ɾ����һλ(�ڶ�������λ����,��һλ������)
	
	LAC	NEW3
	SAH	NEW2
	
	LAC	NEW4
	SAH	NEW3
	
	LAC	NEW5
	SAH	NEW4
	
	LACK	0X0A
	SAH	NEW5
;---	
	LACL	0X0149
	SAH	PRO_VAR
	
	LACL	0X9A		;SEND COMMAND
	SAH	MSG_ID
	CALL	STOR_DAT
	LACL	0X80
	CALL	STOR_DAT
	;BS	B1,MAIN_PRO9_4_X_ERASE_SENDCOMM

MAIN_PRO9_4_X_ERASE_SENDCOMM:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP

	RET	
MAIN_PRO9_4_2_ERASE:
	LAC	MSG_ID
	XORL	0X9B
	BZ	ACZ,MAIN_PRO9_4_2_ERASE_EXE
;---��ǰλ�Ĳ���(lc2)	
	LAC	MSG_N
	ANDK	0XF
	SBHK	0XA
	BZ	SGN,MAIN_PRO9_4_1_ERASE	;�����ǰλ����Чλ,��ɾ��ǰһλ
MAIN_PRO9_4_2_ERASE_EXE:
	
	LAC	NEW3
	SAH	NEW2
	SAH	MSG_N		;ɾ���ڶ�λ,��������λ����
	
	LAC	NEW4
	SAH	NEW3
	
	LAC	NEW5
	SAH	NEW4
	
	LACK	0X0A
	SAH	NEW5
;---	
	LACL	0X0249
	SAH	PRO_VAR
	
	LACL	0X9B		;SEND COMMAND
	SAH	MSG_ID
	CALL	STOR_DAT
	LACL	0X80
	CALL	STOR_DAT
	BS	B1,MAIN_PRO9_4_X_ERASE_SENDCOMM

MAIN_PRO9_4_3_ERASE:
	LAC	MSG_ID
	XORL	0X9C
	BZ	ACZ,MAIN_PRO9_4_3_ERASE_EXE
;---��ǰλ�Ĳ���(lc3)	
	LAC	MSG_N
	ANDK	0XF
	SBHK	0XA
	BZ	SGN,MAIN_PRO9_4_2_ERASE	;�����ǰλ����Чλ,��ɾ��ǰһλ
MAIN_PRO9_4_3_ERASE_EXE:	
	LAC	NEW4
	SAH	NEW3
	SAH	MSG_N		;ɾ������λ,����λ����
	
	LAC	NEW5
	SAH	NEW4
	
	LACK	0X0A
	SAH	NEW5
;---
	LACL	0X0349
	SAH	PRO_VAR
	
	LACL	0X9C		;SEND COMMAND
	SAH	MSG_ID
	CALL	STOR_DAT
	LACL	0X80
	CALL	STOR_DAT
	BS	B1,MAIN_PRO9_4_X_ERASE_SENDCOMM
MAIN_PRO9_4_4_ERASE:
	LAC	MSG_ID
	XORL	0X9D
	BZ	ACZ,MAIN_PRO9_4_4_ERASE_EXE
;---��ǰλ�Ĳ���(lc4)
	LAC	MSG_N
	ANDK	0XF
	SBHK	0XA
	BZ	SGN,MAIN_PRO9_4_3_ERASE	;�����ǰλ����Чλ,��ɾ��ǰһλ
MAIN_PRO9_4_4_ERASE_EXE:
	LAC	NEW5
	SAH	NEW4
	SAH	MSG_N
	
	LACK	0XA
	SAH	NEW5		;ɾ������λ,��λȡ��λ
;---
	LACL	0X0449
	SAH	PRO_VAR
		
	LACL	0X9D		;SEND COMMAND
	SAH	MSG_ID
	CALL	STOR_DAT
	LACL	0X80
	CALL	STOR_DAT
	BS	B1,MAIN_PRO9_4_X_ERASE_SENDCOMM

MAIN_PRO9_4_5_ERASE:
	LAC	MSG_N
	ANDK	0XF
	SBHK	0XA
	BZ	SGN,MAIN_PRO9_4_4_ERASE	;�����ǰλ����Чλ,��ɾ��ǰһλ
;---��Ч����(С��0X0A)
	LACK	0XA
	SAH	MSG_N		;ɾ������λ
	SAH	NEW5
;---
	LACL	0X0549
	SAH	PRO_VAR
		
	LACL	0XCF		;SEND COMMAND
	SAH	MSG_ID
	CALL	STOR_DAT
	LACL	0X80
	CALL	STOR_DAT
	BS	B1,MAIN_PRO9_4_X_ERASE_SENDCOMM
;-----------------------------------------------------------
MAIN_PRO9_4_2:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,MAIN_PRO9_VPSTOP	;VP end
;MAIN_PRO9_4_2_1:		
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,MAIN_PRO9_4_X_REW	;REW
;MAIN_PRO9_4_2_2:	
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO9_4_X_FFW	;FFW
;MAIN_PRO9_4_2_3:	
	LAC	MSG
	XORL	CMSG_KEY8P
	BS	ACZ,MAIN_PRO9_4_X_PREW	;REW
;MAIN_PRO9_4_2_4:	
	LAC	MSG
	XORL	CMSG_KEYCP
	BS	ACZ,MAIN_PRO9_4_X_PFFW	;FFW
;MAIN_PRO9_4_2_5:
	LAC	MSG
	XORL	CMSG_KEY9S
	BS	ACZ,MAIN_PRO9_4_2_MENU	;MENU
;MAIN_PRO9_4_2_6:
	LAC	MSG
	XORL	CMSG_KEY6S
	BS	ACZ,MAIN_PRO9_4_STOP	;STOP(�ȱ���ǰ�������,���˳�)
;MAIN_PRO9_4_2_7:
	LAC	MSG
	XORL	CMSG_KEY5S	
	BS	ACZ,MAIN_PRO9_4_2_ERASE	;ERASE

	RET
	
MAIN_PRO9_4_2_MENU:	
	LAC	MSG_N		;blank ?
	ANDK	0X0F
	XORK	0X0A
	BS	ACZ,MAIN_PRO9_4_SAVE

	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
	
	LAC	MSG_N
	SAH	NEW2
	
	LACL	0X0349
	SAH	PRO_VAR
	
	LACL	0X9C		;local code3
	SAH	MSG_ID

	LAC	NEW3
	SAH	MSG_N		;LOAD CURRENT VALUE()
	BS	B1,MAIN_PRO9_4_X_SENDCOMM
;-----------------------------------------------------------
MAIN_PRO9_4_3:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,MAIN_PRO9_VPSTOP	;VP end
;MAIN_PRO9_4_3_1:		
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,MAIN_PRO9_4_X_REW	;REW
;MAIN_PRO9_4_3_2:	
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO9_4_X_FFW	;FFW
;MAIN_PRO9_4_3_3:	
	LAC	MSG
	XORL	CMSG_KEY8P
	BS	ACZ,MAIN_PRO9_4_X_PREW	;REW
;MAIN_PRO9_4_3_4:	
	LAC	MSG
	XORL	CMSG_KEYCP
	BS	ACZ,MAIN_PRO9_4_X_PFFW	;FFW
;MAIN_PRO9_4_3_5:
	LAC	MSG
	XORL	CMSG_KEY9S
	BS	ACZ,MAIN_PRO9_4_3_MENU	;MENU
;MAIN_PRO9_4_3_6:
	LAC	MSG
	XORL	CMSG_KEY6S
	BS	ACZ,MAIN_PRO9_4_STOP	;STOP(�ȱ���ǰ�������,���˳�)
;MAIN_PRO9_4_3_7:
	LAC	MSG
	XORL	CMSG_KEY5S	
	BS	ACZ,MAIN_PRO9_4_3_ERASE	;ERASE


	RET
	
MAIN_PRO9_4_3_MENU:
	LAC	MSG_N		;blank ?
	ANDK	0X0F
	XORK	0X0A
	BS	ACZ,MAIN_PRO9_4_SAVE

	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
	
	LAC	MSG_N
	SAH	NEW3
	
	LACL	0X0449
	SAH	PRO_VAR
	
	LACL	0X9D		;local code4
	SAH	MSG_ID

	LAC	NEW4
	SAH	MSG_N		;LOAD CURRENT VALUE()
	BS	B1,MAIN_PRO9_4_X_SENDCOMM
;-----------------------------------------------------------
MAIN_PRO9_4_4:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,MAIN_PRO9_VPSTOP	;VP end
;MAIN_PRO9_4_4_1:		
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,MAIN_PRO9_4_X_REW	;REW
;MAIN_PRO9_4_4_2:	
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO9_4_X_FFW	;FFW
;MAIN_PRO9_4_4_3:	
	LAC	MSG
	XORL	CMSG_KEY8P
	BS	ACZ,MAIN_PRO9_4_X_PREW	;REW
;MAIN_PRO9_4_4_4:	
	LAC	MSG
	XORL	CMSG_KEYCP
	BS	ACZ,MAIN_PRO9_4_X_PFFW	;FFW
;MAIN_PRO9_4_4_5:
	LAC	MSG
	XORL	CMSG_KEY9S
	BS	ACZ,MAIN_PRO9_4_4_MENU	;MENU
;MAIN_PRO9_4_4_6:
	LAC	MSG
	XORL	CMSG_KEY6S
	BS	ACZ,MAIN_PRO9_4_STOP	;STOP(�ȱ���ǰ�������,���˳�)
;MAIN_PRO9_4_4_7:
	LAC	MSG
	XORL	CMSG_KEY5S	
	BS	ACZ,MAIN_PRO9_4_4_ERASE	;ERASE

	RET
MAIN_PRO9_4_4_MENU:
	LAC	MSG_N		;blank ?
	ANDK	0X0F
	XORK	0X0A
	BS	ACZ,MAIN_PRO9_4_SAVE

	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
	
	LAC	MSG_N
	SAH	NEW4
	
	LACL	0X0549
	SAH	PRO_VAR
	
	LACL	0XCF		;local code5
	SAH	MSG_ID

	LAC	NEW5
	SAH	MSG_N		;LOAD CURRENT VALUE()
	BS	B1,MAIN_PRO9_4_X_SENDCOMM

;-----------------------------------------------------------
MAIN_PRO9_4_5:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,MAIN_PRO9_VPSTOP	;VP end
;MAIN_PRO9_4_5_1:		
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,MAIN_PRO9_4_X_REW	;REW
;MAIN_PRO9_4_5_2:	
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO9_4_X_FFW	;FFW
;MAIN_PRO9_4_5_3:	
	LAC	MSG
	XORL	CMSG_KEY8P
	BS	ACZ,MAIN_PRO9_4_X_PREW	;REW
;MAIN_PRO9_4_5_4:	
	LAC	MSG
	XORL	CMSG_KEYCP
	BS	ACZ,MAIN_PRO9_4_X_PFFW	;FFW
;MAIN_PRO9_4_5_5:
	LAC	MSG
	XORL	CMSG_KEY9S
	BS	ACZ,MAIN_PRO9_4_5_MENU	;MENU
;MAIN_PRO9_4_5_6:
	LAC	MSG
	XORL	CMSG_KEY6S
	BS	ACZ,MAIN_PRO9_4_STOP	;STOP(�ȱ���ǰ�������,���˳�)
;MAIN_PRO9_4_5_7:
	LAC	MSG
	XORL	CMSG_KEY5S	
	BS	ACZ,MAIN_PRO9_4_5_ERASE	;ERASE

	RET
;---------------------------------------
MAIN_PRO9_4_5_MENU:
	LAC	MSG_N
	SAH	NEW5

MAIN_PRO9_4_SAVE:
	
	LAC	NEW1
	SFL	4
	OR	NEW2
	SFL	4
	OR	NEW3
	SFL	4
	OR	NEW4
	SAH	LOCACODE
	
	LAC	LOCACODE1
	ANDL	0xFFF0
	SAH	LOCACODE1	;�Աȶȼ���������Ҫ��
	
	LAC	NEW5
	ANDK	0x0F
	OR	LOCACODE1
	SAH	LOCACODE1
;---	
	CALL	SENDLOCACODE
	LACL	0XFF
	CALL	STOR_DAT
;----------
	LACK	3
	SAH	COUNT
	LAC	LOCACODE
	SFR	12
	ANDK	0X0F
	CALL	STORBYTE_DAT
;-
	LACK	4
	SAH	COUNT
	LAC	LOCACODE
	SFR	8
	ANDK	0X0F
	CALL	STORBYTE_DAT
;-
	LACK	5
	SAH	COUNT
	LAC	LOCACODE
	SFR	4
	ANDK	0X0F
	CALL	STORBYTE_DAT
;-
	LACK	6
	SAH	COUNT
	LAC	LOCACODE
	ANDK	0X0F
	CALL	STORBYTE_DAT
;-
	LACK	7
	SAH	COUNT
	LAC	LOCACODE1
	ANDK	0x0F
	CALL	STORBYTE_DAT
;-
	;LACK	9
	LACK	11
	SAH	COUNT
	LACL	0XFF
	CALL	STORBYTE_DAT	;��0XFF��β

	LACK	1
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK
	CALL	GC_CHK
	
	CALL	TELNUM_WRITE	;д������	
	CALL	DAT_WRITE_STOP
;MAIN_PRO9_4_LOCCODEEXIT:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
	
	LACL	0X0059
	SAH	PRO_VAR

	LACL	0XCE		;select RING_CNT
	SAH	NEW7
	
	LAC	VOI_ATT		;LANGUAGE/OGM_ID/RING_CNT/ATT1
	SFR	4
	ANDK	0X0F
	SAH	NEW0		;load CURRENT VALUE(RING_CNT)
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LAC	NEW7
	CALL	STOR_DAT
	LAC	NEW0
	CALL	STOR_DAT	;goto next(RING_CNT)
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	RET
;-----------------------------------------------------------
MAIN_PRO9_5:
	LAC	MSG
	XORL	CMSG_TMR		;TMR
	BS	ACZ,MAIN_PRO9_TMR
	
	LAC	PRO_VAR
	SFR	8
	ANDK	0X0F
	BS	ACZ,MAIN_PRO9_5_0
	SBHK	1
	BS	ACZ,MAIN_PRO9_5_1
	
	RET
;---------------------------------------
MAIN_PRO9_5_0:
	LACL	0X0159
	SAH	PRO_VAR

	LAC	MSG
	CALL	STOR_MSG
	RET
;---------------------------------------
MAIN_PRO9_5_1:	
;MAIN_PRO9_5_1_0:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,MAIN_PRO9_VPSTOP	;VP end
;MAIN_PRO9_5_1_1:		
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,MAIN_PRO9_5_1_REW	;REW
;MAIN_PRO9_5_1_2:	
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO9_5_1_FFW	;FFW
;MAIN_PRO9_5_1_3:	
	LAC	MSG
	XORL	CMSG_KEY8P
	BS	ACZ,MAIN_PRO9_5_1_PREW	;REW
;MAIN_PRO9_5_1_4:	
	LAC	MSG
	XORL	CMSG_KEYCP
	BS	ACZ,MAIN_PRO9_5_1_PFFW	;FFW
;MAIN_PRO9_5_1_5:
	LAC	MSG
	XORL	CMSG_KEY9S
	BS	ACZ,MAIN_PRO9_5_1_MENU	;MENU
;MAIN_PRO9_5_1_6:	
	LAC	MSG
	XORL	CMSG_KEY6S
	BS	ACZ,MAIN_PRO9_X_STOP	;STOP

	RET
;---------------
MAIN_PRO9_5_1_REW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
MAIN_PRO9_5_1_PREW:
	LACK	1
	SAH	SYSTMP1
	LACK	9
	SAH	SYSTMP2

	LAC	NEW0
	CALL	VALUE_SUB
	SAH	NEW0
	BS	B1,MAIN_PRO9_5_X_SENDCOMM
MAIN_PRO9_5_1_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
MAIN_PRO9_5_1_PFFW:	
	LACK	1
	SAH	SYSTMP1
	LACK	9
	SAH	SYSTMP2

	LAC	NEW0
	CALL	VALUE_ADD
	SAH	NEW0

MAIN_PRO9_5_X_SENDCOMM:
	LAC	NEW7
	CALL	STOR_DAT
	LAC	NEW0
	CALL	STOR_DAT
	
	RET
MAIN_PRO9_5_1_MENU:
	LAC	VOI_ATT
	ANDL	0XFF0F
	SAH	VOI_ATT
	
	LAC	NEW0
	SFL	4
	OR	VOI_ATT
	SAH	VOI_ATT
	
	LACK	8
	SAH	COUNT
	LAC	NEW0
	CALL	STORBYTE_DAT
	;LACK	9
	LACK	11
	SAH	COUNT
	LACL	0XFF
	CALL	STORBYTE_DAT	;��0XFF��β

	LACK	1
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK
	CALL	GC_CHK
	
	CALL	TELNUM_WRITE	;д������	
	CALL	DAT_WRITE_STOP
;---	
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP		;BEEP
	
	LACL	0X0069
	SAH	PRO_VAR

	LACL	0XC0		;select OGM
	SAH	NEW7
	
	LAC	VOI_ATT		;LANGUAGE/OGM_ID/RING_CNT/ATT1
	SFR	8
	ANDK	0X0F
	SAH	NEW0		;load CURRENT VALUE(OGM_ID)
	CALL	OGM_SELECT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LAC	NEW7
	CALL	STOR_DAT
	LAC	MSG_N
	SAH	NEW0
	CALL	STOR_DAT	;goto next(OGM-phone)
;!!!!!!!!!!!!!!!!!!!!!!!!!!!

	RET
;-----------------------------------------------------------
MAIN_PRO9_6:			;OGM record
	LAC	PRO_VAR
	SFR	8
	ANDK	0X0F
	BS	ACZ,MAIN_PRO9_6_0	;display
	SBHK	1
	BS	ACZ,MAIN_PRO9_6_1	;adjust OGM_ID
	SBHK	1
	BS	ACZ,MAIN_PRO9_6_2	;long beep before record
	SBHK	1
	BS	ACZ,MAIN_PRO9_6_3	;record OGM
	SBHK	1
	BS	ACZ,MAIN_PRO9_6_4	;playing back OGM

	RET
MAIN_PRO9_6_0:
	LACL	0X0169
	SAH	PRO_VAR
	
	LAC	MSG
	CALL	STOR_MSG

	RET

MAIN_PRO9_X_STOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BBEEP		;BB
;!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	LACL	0X9E		;exit COMMAND = 0X9E+6
	CALL	STOR_DAT
	LACK	6
	CALL	STOR_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	0
	SAH	PRO_VAR
	
	RET
;---------------
MAIN_PRO9_6_1:
	LAC	MSG
	XORL	CMSG_TMR		;TMR
	BS	ACZ,MAIN_PRO9_TMR
;MAIN_PRO9_6_1_0:	
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,MAIN_PRO9_VPSTOP	;VP end
;MAIN_PRO9_6_1_1:		
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,MAIN_PRO9_6_1_REW	;REW
;MAIN_PRO9_6_1_2:	
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO9_6_1_FFW	;FFW
;MAIN_PRO9_6_1_3:	
	LAC	MSG
	XORL	CMSG_KEY8P
	BS	ACZ,MAIN_PRO9_6_1_PREW	;REW
;MAIN_PRO9_6_1_4:	
	LAC	MSG
	XORL	CMSG_KEYCP
	BS	ACZ,MAIN_PRO9_6_1_PFFW	;FFW
;MAIN_PRO9_6_1_5:
	LAC	MSG
	XORL	CMSG_KEY9S
	BS	ACZ,MAIN_PRO9_6_1_MENU	;MENU
;MAIN_PRO9_6_1_6:
	LAC	MSG
	XORL	CMSG_KEY6S
	BS	ACZ,MAIN_PRO9_X_STOP	;STOP
;MAIN_PRO9_6_1_8:
	LAC	MSG
	XORL	CMSG_KEY3S
	BS	ACZ,MAIN_PRO9_6_1_OGM
	
	RET
;-------

MAIN_PRO9_6_1_REW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
MAIN_PRO9_6_1_PREW:

	LACK	1
	SAH	SYSTMP1
	LACK	5
	SAH	SYSTMP2

	LAC	NEW0
	CALL	VALUE_SUB
	SAH	NEW0

	BS	B1,MAIN_PRO9_6_SAVE
MAIN_PRO9_6_1_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
MAIN_PRO9_6_1_PFFW:
	LACK	1
	SAH	SYSTMP1
	LACK	5
	SAH	SYSTMP2

	LAC	NEW0
	CALL	VALUE_ADD
	SAH	NEW0
;---
MAIN_PRO9_6_SAVE:
	BIT	EVENT,8
	BS	TB,MAIN_PRO9_6_SAVE_END

	LAC	VOI_ATT
	ANDL	0XF0FF
	SAH	VOI_ATT
	
	LAC	NEW0
	SFL	8
	OR	VOI_ATT		;LANGUAGE/OGM_ID/RING_CNT/ATT1
	SAH	VOI_ATT
MAIN_PRO9_6_SAVE_END:
	LAC	NEW0
	CALL	OGM_SELECT
;!!!!!!!!!!!!!!!!!!!!!!!!!!	
	LACL	0XC0
	CALL	STOR_DAT
	LAC	MSG_N
	SAH	NEW0
	CALL	STOR_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!
	RET
MAIN_PRO9_6_1_OGM:		;start play OGM
	CALL	INIT_DAM_FUNC	;���벥��OGM�ӹ���
	CALL	DAA_SPK

	LACL	0X0469
	SAH	PRO_VAR

	LACL	0XC3
	CALL	STOR_DAT
	LAC	NEW0
	CALL	STOR_DAT
	
	LAC	NEW0
	CALL	OGM_SELECT
	BS	ACZ,MAIN_PRO9_6_1_END_2
	
	;CALL	VP_DEFAULTOGM
	LAC	NEW0
	CALL	DEFOGM_LOCALPLY		;load default OGM

	BS	B1,MAIN_PRO9_6_1_END_3
MAIN_PRO9_6_1_END_2:
	LAC	MSG_ID
	ANDL	0X0FF
	ORL	0XFE00
	CALL	STOR_VP
	
MAIN_PRO9_6_1_END_3:
	LACK	0X005
	CALL	STOR_VP

	RET
MAIN_PRO9_6_1_MENU:		;ready for record OGM
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	LBEEP
	
	LACL	0X0269
	SAH	PRO_VAR

	RET

;---------------
MAIN_PRO9_6_2:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,MAIN_PRO9_6_2_VPSTOP	;VP end
;MAIN_PRO9_6_2_1:
	LAC	MSG
	XORL	CMSG_KEY6S
	BS	ACZ,MAIN_PRO9_6_X_IDEL		;STOP
	
	RET
MAIN_PRO9_6_2_VPSTOP:
	CALL	INIT_DAM_FUNC

	LAC	NEW0
	CALL	OGM_SELECT
;-------delete the old OGM----------------	
	LAC	MSG_ID		;��ӦOGM���ھ�ɾ��,û�ж�ӦOGM���˲���Ҳ����ν
	CALL	MSG_DEL
	CALL	GC_CHK
;---	
    	LAC	NEW0
    	ADHK	100
    	ORL	0X7500
    	SAH	CONF
    	CALL	DAM_BIOS
    	LACK	0X0A		;// set silence threshold
	CALL	SET_SILENCE
	CALL	SET_COMPS
	
	LACL	0X0369
	SAH	PRO_VAR

	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER
	CALL	DAA_REC
	CALL	REC_START
;!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XC1
	CALL	STOR_DAT
	LAC	NEW0
	CALL	STOR_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!
	RET
;---------------
MAIN_PRO9_6_3:
	LAC	MSG
	XORL	CMSG_KEY6S		;ON/OFF
	BS	ACZ,MAIN_PRO9_6_3_END
;MAIN_PRO9_6_3_1:
	LAC	MSG
	XORL	CMSG_TMR		;TMR
	BS	ACZ,MAIN_PRO9_6_3_TMR	
;MAIN_PRO9_6_3_2:
	LAC	MSG
	XORL	CREC_FULL		;REC_FULL
	BS	ACZ,MAIN_PRO9_6_3_END
	
	RET
;---------------------------------------	
MAIN_PRO9_6_3_END:
	LAC	PRO_VAR1
	SBHK	3
	BZ	SGN,MAIN_PRO9_6_3_END_1	;���ڵ���3sec�ͱ���
	SRAM	CONF,11
	CALL	DAM_BIOS
MAIN_PRO9_6_3_END_1:	
	CALL	INIT_DAM_FUNC		;���벥��OGM�ӹ���
	CALL	DAA_SPK

	LAC	NEW0
	CALL	OGM_SELECT
	BS	ACZ,MAIN_PRO9_6_3_END_2

	;CALL	VP_DEFAULTOGM	;default OGM
	LAC	NEW0
	CALL	DEFOGM_LOCALPLY		;load default OGM
	
	BS	B1,MAIN_PRO9_6_3_END_3
MAIN_PRO9_6_3_END_2:	
	LAC	MSG_ID
	ANDL	0X0FF
	ORL	0XFE00
	CALL	STOR_VP
	
MAIN_PRO9_6_3_END_3:	

	LACL	0X0469
	SAH	PRO_VAR

	LACL	0XC3
	CALL	STOR_DAT
	LAC	NEW0
	CALL	STOR_DAT

	RET
;---------------------------------------
MAIN_PRO9_6_3_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	120
	BZ	SGN,MAIN_PRO9_6_3_END
	
	RET
;-------
MAIN_PRO9_6_4:
	LACK	0
	SAH	PRO_VAR1
;MAIN_PRO9_6_4_0:
	LAC	MSG
	XORL	CMSG_KEY5S		;ERASE
	BS	ACZ,MAIN_PRO9_6_4_ERASE
;MAIN_PRO9_6_4_1:
	LAC	MSG
	XORL	CMSG_KEY6S		;ON/OFF(stop)
	BS	ACZ,MAIN_PRO9_6_X_IDEL
;MAIN_PRO9_6_4_2:
	LAC	MSG
	XORL	CVP_STOP		;play end
	BS	ACZ,MAIN_PRO9_6_X_IDEL
;MAIN_PRO9_6_4_3:
	LAC	MSG
	XORL	CMSG_KEYAP		;VOL+
	BS	ACZ,MAIN_PRO1_PLAY_VOLA
;MAIN_PRO9_6_4_4:
	LAC	MSG
	XORL	CMSG_KEYAS		;VOL+
	BS	ACZ,MAIN_PRO1_PLAY_VOLA
;MAIN_PRO9_6_4_5:
	LAC	MSG
	XORL	CMSG_KEYBP		;VOL-
	BS	ACZ,MAIN_PRO1_PLAY_VOLS
;MAIN_PRO9_6_4_6:
	LAC	MSG
	XORL	CMSG_KEYBS		;VOL-
	BS	ACZ,MAIN_PRO1_PLAY_VOLS

	RET

MAIN_PRO9_6_4_ERASE:
	LAC	MSG_ID
	ANDL	0X0FF
	ORL	0X2080
	SAH	CONF
	CALL	DAM_BIOS
	
	LACL	0X6100
	SAH	CONF
	CALL	DAM_BIOS

MAIN_PRO9_6_X_IDEL:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BBEEP

	LACL	0X169
	SAH	PRO_VAR
	LACK	0
	SAH	PRO_VAR1
	
	LACL	0XC0
	SAH	NEW7
	CALL	STOR_DAT
	LAC	NEW0
	CALL	STOR_DAT
	
	RET

;=========================================================================
	
.END
