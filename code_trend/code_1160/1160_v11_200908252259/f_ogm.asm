.NOLIST
.INCLUDE MD20U.INC
.INCLUDE REG_D20.inc
.INCLUDE CONST.INC
.INCLUDE EXTERN.INC
;-------------------------------------------------------------------------------
.EXTERN	SetFlashStartAddress
.EXTERN	LoadHostCode
.EXTERN	GetOneConst	;(INPUT=ACCH(ProgramRamAddress),OUTPUT=ACCH(ReadData))
.EXTERN	GetMoreConst	;(INPUT=ACCH(ProgramRamStartingAddress)ACCL(ReadWordNumber)AR1(StoreDataRamAddress),OUTPUT=)
;-------------------------------------------------------------------------------
.global	LOCAL_PROOGM
;-------------------------------------------------------------------------------
.LIST
.ORG    ADDR_SECOND
;================================================================================
LOCAL_PROOGM:	;����(OGM)״̬Ҫ���ǵ���Ϣ:
	LAC	PRO_VAR
	ANDL	0X0F
	BS	ACZ,LOCAL_PROOGM0	;local-idle to record
	SBHK	1
	BS	ACZ,LOCAL_PROOGM1	;LBEEP before record
	SBHK	1
	BS	ACZ,LOCAL_PROOGM2	;OGM recording
	SBHK	1
	BS	ACZ,LOCAL_PROOGM3	;OGM playing
	SBHK	1
	BS	ACZ,LOCAL_PROOGM4	;END VOP
	
	RET
	
;-------------------------------------------------------------------------------
LOCAL_PROOGM0:
	LAC	MSG
	XORL	CMSG_KEY2L
	BS	ACZ,LOCAL_PROOGM0_RECCOMM
	LAC	MSG
	XORL	CMSG_KEY2S
	BS	ACZ,LOCAL_PROOGM0_PLYCOMM
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,LOCAL_PROOGM0_RINGIN
	
	RET
;---------------------------------------
LOCAL_PROOGM0_PLYCOMM:
	BS	B1,LOCAL_PROOGM2_LOADOGM
LOCAL_PROOGM0_RECCOMM:
	CALL	INIT_DAM_FUNC
	CALL	LBEEP
	CALL	DAA_SPK
	CALL	BLED_ON

	LACK	0X01
	SAH	PRO_VAR

	BIT	ANN_FG,13	;check memoful?
	BS	TB,LOCAL_PROOGM0_RECCOMM1

	RET
LOCAL_PROOGM0_RECCOMM1:
	CALL	INIT_DAM_FUNC
	LACK	0X03
	SAH	PRO_VAR
	
	CALL	VP_MEMFUL
	CALL	BBBEEP		;memory full(BBB)
			
	RET
;---------------------------------------
LOCAL_PROOGM0_RINGIN:
	BS	B1,LOCAL_PROOGM4_STOP
;-------------------------------------------------------------------------------
LOCAL_PROOGM1:	
	LAC	MSG
	XORL	CMSG_KEY7S		;press ON/OFF key when playing voice prompt
	BS	ACZ,LOCAL_PROOGM1_STOP
	LAC	MSG
	XORL	CVP_STOP		;end of the voice prompt and begin to record
	BS	ACZ,LOCAL_PROOGM1_RECOGM
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,LOCAL_PROOGM1_RINGIN

	RET
;---------------------------------------
LOCAL_PROOGM1_RINGIN:
	BS	B1,LOCAL_PROOGM4_STOP
LOCAL_PROOGM1_STOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK	
	CALL	BB_VOP		;�滻����BB
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XC6
	CALL	SEND_DAT
	LACK	0
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	0X04
	SAH	PRO_VAR

	RET
;---------------------------------------
LOCAL_PROOGM1_RECOGM:
	CALL	INIT_DAM_FUNC
	CALL	DAA_REC

	LAC	VOI_ATT
	SFR	8
	ANDK	0X0F
	CALL	OGM_SELECT	;set mailbox-id first
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.if	0
;-------delete the old OGM----------------
	LAC	MSG_ID
	ORL	0X6000
	CALL	DAM_BIOSFUNC
	
	CALL	GC_CHK
.endif
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XC1
	CALL	SEND_DAT
	LAC	VOI_ATT		;LANGUAGE/OGM_ID/RING_CNT/ATT1
	SFR	8
	ANDK	0X0F
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!

	LACK	0
	SAH	PRO_VAR1
	LACL	CTMR1S
	CALL	SET_TIMER
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LAC	PRO_VAR1	;��
	CALL	SEND_HHMMSS
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
;---	
	;LAC	MSG_N
    	;ORL	0X8D00|0X70
	;CALL	DAM_BIOSFUNC		;set user index data0"OGM_ID"

	LACK	0X02
	SAH	PRO_VAR
	
	CALL	SET_COMPS
	CALL	REC_START
	
	RET
;-------------------------------------------------------------------------------	
LOCAL_PROOGM2:
	LAC	MSG
	XORL	CMSG_KEY7S		;ON/OFF
	BS	ACZ,LOCAL_PROOGM2_STOP
	LAC	MSG
	XORL	CMSG_TMR		;TMR
	BS	ACZ,LOCAL_PROOGM2_TMR
	LAC	MSG
	XORL	CREC_FULL		;REC_FULL
	BS	ACZ,LOCAL_PROOGM2_FULL
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,LOCAL_PROOGM2_RINGIN
	
	
	RET
;-------������Ϣ------------------------
LOCAL_PROOGM2_FULL:
	CALL	INIT_DAM_FUNC	;stop recording
	CALL	MEMFULL_CHK

	CALL	VP_MEMFUL
	CALL	BB_VOP
	CALL	DAA_SPK	

	LACK	0X03
	SAH	PRO_VAR
		
	RET

;---------------------------------------
LOCAL_PROOGM2_STOP:
	LAC	PRO_VAR1
	SBHK	3
	BZ	SGN,LOCAL_PROOGM2_STOP_1

	LAC	CONF
	ORL	1<<11
	CALL	DAM_BIOSFUNC
LOCAL_PROOGM2_STOP_1:
LOCAL_PROOGM2_LOADOGM:
	LAC	CONF
	ANDL	0XFFC0
	SAH	CONF
	CALL	INIT_DAM_FUNC
	CALL	GC_CHK		;perhaps delete action happend
	CALL	DAA_SPK
	CALL	BLED_ON
	LACK	0X03
	SAH	PRO_VAR		;���벥��OGM�ӹ���
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
LOCAL_PROOGM2_DELOLDOGM:
	LAC	VOI_ATT
	SFR	8
	ANDK	0X0F
	CALL	OGM_SELECT
	SBHK	2
	BS	SGN,LOCAL_PROOGM2_DELOLDOGM_1	;����2(ֻ��1/0)��ʱ�Ͳ�ɾ��
	LACL	0X6000|1	;ɾ��ɵ�
	CALL	DAM_BIOSFUNC
	CALL	GC_CHK
	BS	B1,LOCAL_PROOGM2_DELOLDOGM
LOCAL_PROOGM2_DELOLDOGM_1:
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LAC	VOI_ATT
	SFR	8
	ANDK	0X0F
	CALL	OGM_SELECT
	
	LAC	MSG_ID
	ANDL	0X0FF
	ORL	0XFE00
	CALL	STOR_VP
	
;!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XC3
	CALL	SEND_DAT
	LAC	MSG_N		;LANGUAGE/OGM_ID/RING_CNT/ATT1
	ANDK	0X0F
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!
	
	LAC	MSG_N
	ANDK	0X0F
	CALL	OGM_SELECT
	BZ	ACZ,LOCAL_PROOGM2_LOADOGM_END
	
	CALL	INIT_DAM_FUNC

	LAC	MSG_N
	ANDK	0X0F
	CALL	DEFOGM_LOCALPLY		;load default OGM

	;CALL	VP_DEFAULTOGM	;default OGM		
LOCAL_PROOGM2_LOADOGM_END:		
	RET
;---------------------------------------
LOCAL_PROOGM2_RINGIN:
	LAC	PRO_VAR1
	SBHK	3
	BZ	SGN,LOCAL_PROOGM2_RINGIN_1		;Ҫ������¼��ʱ��t>=3s���ܱ���

	LAC	CONF
	ORL	1<<11
	CALL	DAM_BIOSFUNC
LOCAL_PROOGM2_RINGIN_1:
	CALL	INIT_DAM_FUNC
	CALL	GC_CHK
	CALL	DAA_OFF

	CALL	VPMSG_CHK
	;CALL	GET_VPMSGN
	;SAH	MSG_N
	;CALL	GET_VPMSGT
	;SAH	MSG_T
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	SEND_MSGNUM	;¼������ͬ��(4bytes)
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9E
	CALL	SEND_DAT
	LACL	6
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	CLR_FUNC	;�ȿ�
	LACK	0
	SAH	PRO_VAR

	LAC	MSG
	CALL	STOR_MSG

	RET
;---------------------------------------
LOCAL_PROOGM2_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	CLOGM
	BZ	SGN,LOCAL_PROOGM2_STOP	;¼��ʱ��ﵽ120s
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LAC	PRO_VAR1	;��
	CALL	SEND_HHMMSS
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	RET	
;-------------------------------------------------------------------------------
LOCAL_PROOGM3:	
	LAC	MSG
	XORL	CMSG_KEY8S		;DEL
	BS	ACZ,LOCAL_PROOGM3_DEL
;LOCAL_PROOGM3_1:	
	LAC	MSG
	XORL	CMSG_KEY2S		;next OGM
	BS	ACZ,LOCAL_PROOGM3_NEXTOGM
;LOCAL_PROOGM3_2:
	LAC	MSG
	XORL	CMSG_KEY7S		;ON/OFF(stop)
	BS	ACZ,LOCAL_PROOGM3_STOP
;LOCAL_PROOGM3_3:
	LAC	MSG
	XORL	CVP_STOP		;play end
	BS	ACZ,LOCAL_PROOGM3_STOP
;LOCAL_PROOGM3_4:	
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,LOCAL_PROOGM3_RINGIN
;LOCAL_PROOGM3_5:
	LAC	MSG
	XORL	CMSG_KEYBP		;VOL+
	BS	ACZ,LOCAL_PROOGMX_VOLP
;LOCAL_PROOGM3_6:
	LAC	MSG
	XORL	CMSG_KEYBD		;VOL+
	BS	ACZ,LOCAL_PROOGMX_VOLA
;LOCAL_PROOGM3_7:
	
	RET
;-------��Ӧ����,��Ϣת��
LOCAL_PROOGM3_NEXTOGM:
	CALL	INIT_DAM_FUNC
	
	LACK	1
	SAH	SYSTMP1
	LACK	5
	SAH	SYSTMP2

	LAC	MSG_N
	ANDK	0X0F
	CALL	VALUE_ADD
	SAH	MSG_N
	CALL	OGM_SELECT

	LAC	MSG_ID
	ANDL	0X0FF
	ORL	0XFE00
	CALL	STOR_VP
	
	LAC	MSG_N
	ANDK	0X0F
	CALL	OGM_SELECT
	BZ	ACZ,LOCAL_PROOGM3_NEXTOGM_1
	
	CALL	INIT_DAM_FUNC
	
	LAC	MSG_N
	ANDK	0X0F
	CALL	DEFOGM_LOCALPLY		;load default OGM
	;CALL	VP_DEFAULTOGM	;default OGM
LOCAL_PROOGM3_NEXTOGM_1:
	BIT	EVENT,8
	BS	TB,LOCAL_PROOGM3_NEXTOGM_2		;ֻ��¼״̬���ɱ�OGM_ID
	
	LAC	VOI_ATT
	ANDL	0XF0FF
	SAH	VOI_ATT
	
	LAC	MSG_N
	SFL	8
	ANDL	0X0F00
	OR	VOI_ATT
	SAH	VOI_ATT
LOCAL_PROOGM3_NEXTOGM_2:

;!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XC3
	CALL	SEND_DAT
	LAC	MSG_N
	ANDK	0XF
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!	

	RET
;---------------------------------------
LOCAL_PROOGM3_DEL:
	CALL	INIT_DAM_FUNC
	LAC	MSG_ID
	ANDL	0X07F
	ORL	0X6000
	CALL	DAM_BIOSFUNC
	CALL	GC_CHK

	LACK	0X04
	SAH	PRO_VAR
	CALL	BB_VOP
	
	RET
;---------------------------------------
LOCAL_PROOGM3_STOP:
	CALL	INIT_DAM_FUNC
	CALL	BB_VOP
	
	LACK	0X04
	SAH	PRO_VAR

	RET
;---------------------------------------
LOCAL_PROOGM3_RINGIN:
	CALL	INIT_DAM_FUNC
	LACK	0X005
	CALL	STOR_VP

	LACK	0X04
	SAH	PRO_VAR

	CALL	BLED_ON
	LACL	CMSG_INIT
	CALL	STOR_MSG
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9E
	CALL	SEND_DAT
	LACL	6
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	
	RET
;---------------------------------------
LOCAL_PROOGMX_VOLP:
	LAC	VOI_ATT
	ANDK	0XF
	SBHK	CMAX_VOL
	BZ	SGN,LOCAL_PROOGMX_VOL_END	;�Ѿ�������˾Ͳ�������
LOCAL_PROOGMX_VOLA:	
	LACL	CMSG_VOLA
	CALL	STOR_MSG
;---	
	LACK	CMIN_VOL
	SAH	SYSTMP1
	LACK	CMAX_VOL
	SAH	SYSTMP2
	
	LAC	VOI_ATT
	ANDK	0XF
	CALL	VALUE_ADD
	SAH	SYSTMP0
	
	LAC	VOI_ATT
	ANDL	0XFFF0
	OR	SYSTMP0
	SAH	VOI_ATT
;---	
	LAC	SYSTMP0
	SBHK	CMAX_VOL
	BZ	ACZ,LOCAL_PROOGMX_VOL_END
;---�ﵽ�������,��BEEP��ʾ
	LAC	CONF
	SFR	12
	ANDK	0X0F
	SBHK	0X02
	BS	ACZ,LOCAL_PROOGM_X_VOLA_BEEP	;0x2000
	SBHK	0X09
	BS	ACZ,LOCAL_PROOGM_X_VOLA_BEEP	;0xB000
	BS	B1,LOCAL_PROOGMX_VOL_END
LOCAL_PROOGM_X_VOLA_BEEP:

	LAC	CONF
	ORL	1<<8
	SAH	CONF
	CALL	DAM_BIOSFUNC	;pause
	
	CALL	PBBEEP		;BBEEP
	
	LAC	CONF
	ANDL	~(1<<8)
	SAH	CONF
	CALL	DAM_BIOSFUNC	;continue play

LOCAL_PROOGMX_VOL_END:
	RET

;-------------------------------------------------------------------------------	
LOCAL_PROOGM4:
	LAC	MSG
	XORL	CMSG_KEY7S		;ON/OFF(stop)
	BS	ACZ,LOCAL_PROOGM4_STOP
;LOCAL_PROOGM3_3:
	LAC	MSG
	XORL	CVP_STOP		;play end
	BS	ACZ,LOCAL_PROOGM4_STOP
	
	RET
;---------------------------------------
LOCAL_PROOGM4_STOP:
	CALL	INIT_DAM_FUNC
	LACK	0X001
	CALL	STOR_VP
	CALL	CLR_FUNC	;�ȿ�
	LACK	0
	SAH	PRO_VAR

	CALL	BLED_ON
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9E
	CALL	SEND_DAT
	LACL	6
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!

	RET
;-------------------------------------------------------------------------------
.INCLUDE	l_math.asm
;-------------------------------------------------------------------------------
.END

