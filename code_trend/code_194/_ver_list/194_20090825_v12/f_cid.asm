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
.GLOBAL	LOCAL_PROCID
;-------------------------------------------------------------------------------
.LIST
.ORG    ADDR_SECOND
;-------------------------------------------------------------------------------
LOCAL_PROCID:		;��������״̬Ҫ���ǵ���Ϣ
	LAC	MSG
	XORL	CMSG_KEYBD
	BS	ACZ,LOCAL_PROCID_EXIT	;VOL+

	LAC	PRO_VAR
	ANDK	0X0F
	BS	ACZ,LOCAL_PROCID_0	;Idle
	SBHK	1
	BS	ACZ,LOCAL_PROCID_1	;look up
	SBHK	1
	BS	ACZ,LOCAL_PROCID_2	;dial
	SBHK	1
	BS	ACZ,LOCAL_PROCID_3	;delete
	SBHK	1
	BS	ACZ,LOCAL_PROCID_4	;Announce CID
		
	RET
;---------------------------------------
LOCAL_PROCID_EXIT:		;��Ӧ�������ܶ��˳�(������������,�ɲ����˳�����)
	CALL	CLR_FUNC
	LACK	0
	SAH	PRO_VAR
	SAH	PRO_VAR1

	LAC	MSG
	CALL	STOR_MSG
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROCID_0:
	LAC	MSG
	XORL	CMSG_KEYAS
	BS	ACZ,LOCAL_PROCID_0_FFW	;Lookup CID
	LAC	MSG
	XORL	CMSG_CID
	BS	ACZ,LOCAL_PROCID_0_CID	;Received new CID(compare it with Filter)
	
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,LOCAL_PROCID_X_RINGIN
;---
	RET
;---------------------------------------
LOCAL_PROCID_0_FFW:
	LACL	CMSG_KEY1S
	BS	B1,LOCAL_PROCID_0_REWFFW
LOCAL_PROCID_0_REW:
	LACL	CMSG_KEY2S
LOCAL_PROCID_0_REWFFW:
	SAH	MSG
;---
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
	CALL	BLED_ON

	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER
	
	LACK	0x01
	SAH	PRO_VAR
	
	LAC	MSG
	CALL	STOR_MSG
	
	LACK	CGROUP_CID
	CALL	SET_TELGROUP	;
	CALL	GET_TELT
	SAH	MSG_T		;����Ŀ��MSG_T
	
	LACK	0
	SAH	MSG_ID		;��ǰ��Ŀ��

	RET
;---------------------------------------
LOCAL_PROCID_0_CID:		;Received new CID

	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
;---Read the newest CID first	
	LACK	CGROUP_CID
	CALL	SET_TELGROUP	;
	CALL	GET_TELT
	SAH	MSG_ID
	
	LACL	TEL_RAM
	SAH	ADDR_D		;Address-Base
	LACK	0
	SAH	OFFSET_D	;Address-Offset
	LAC	MSG_ID		;message-id
	CALL	READ_TELNUM	;����ǰ��Ŀ����
	CALL	STOPREADDAT
;-------Get TEL-flag	
	LACL	TEL_RAM
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	CALL	GETBYTE_DAT	;Get flag-num
	SAH	FILE_LEN
	CALL	GETBYTE_DAT	;Get flag-name
	SFL	8
	ANDL	0XFF00
	OR	FILE_LEN
	SAH	FILE_LEN	;�ȱ���flag��Ϣ(Number/Name)
;---��0XFF��β
	LACL	TEL_RAM+2
	SAH	ADDR_S
	SAH	ADDR_D
	LAC	FILE_LEN
	ANDK	0X1F
	ADHK	1
	SFR	1
	SAH	OFFSET_D
	LACL	0XFF		;ֵ
	CALL	STORBYTE_DAT
;---Set current-Group = phonebook
	LACK	CGROUP_PBOOK
	CALL	SET_TELGROUP	;
;---��ʼ�Ƚ�Tel-num
	LACL	TEL_RAM
	SAH	ADDR_S
	SAH	ADDR_D

	CALL	COMP_ALLTELNUM
	BS	ACZ,LOCAL_PROCID_0_CID_1
	SAH	MSG_ID		;�ҵ�����ͬ�������Ŀ
;---Get the user-flag(Filter)
	LAC	MSG_ID
	ORL	0XEA00
	CALL	DAM_BIOSFUNC
	ANDK	0X03
	SAH	SYSTMP0		;The flag of the current CID(Normal/VIP/Filter) ---  Same as number in phonebook
;---Set current-Group = CID
	LACK	CGROUP_CID
	CALL	SET_TELGROUP	;
	CALL	GET_TELT
	SAH	MSG_T
;---Get index-0 of the newest cid
	LAC	MSG_T
	ORL	0XEA00
	CALL	DAM_BIOSFUNC
	ANDL	0XFC
	OR	SYSTMP0
	SFL	8
	ANDL	0XFF00
	SAH	SYSTMP0
;---Set index-0 of the newest cid
	LAC	MSG_T		;��Ŀ��
	OR	SYSTMP0		;new-flag
	CALL	SET_TEL0ID	;Clear the new-flag
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.if	0
	LAC	VOP_FG
	ANDL	~(1<<14)
	SAH	VOP_FG

	CALL	GET_VIPNTEL	;Get the number of new-VIP TEL
	BS	ACZ,LOCAL_PROCID_0_CID_1
	
	LAC	VOP_FG
	ORL	1<<14
	SAH	VOP_FG
.endif
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
LOCAL_PROCID_0_CID_1:
;---Read the newest CID first	
	LACK	CGROUP_CID
	CALL	SET_TELGROUP	;
	CALL	GET_TELT
	SAH	MSG_ID
	
	LACL	TEL_RAM
	SAH	ADDR_D		;Address-Base
	LACK	0
	SAH	OFFSET_D	;Address-Offset
	LAC	MSG_ID		;message-id
	CALL	READ_TELNUM	;read tel-num with specify tel-id
	CALL	STOPREADDAT
;---Get flag-num	
	LACL	TEL_RAM
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	SAH	MSG_T	;Save the flag-num
	LACK	4
	SAH	OFFSET_S
	LACK	0
	SAH	MSG_ID		;���
.if	0	;CID announce function
	LACK	0X04
	SAH	PRO_VAR
.else	;No CID announce function
	CALL	CLR_FUNC
	LACK	0X0
	SAH	PRO_VAR
.endif
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACK	0X005
	CALL	STOR_VP

	RET
;-------------------------------------------------------------------------------
LOCAL_PROCID_1:
;LOCAL_PROCID_1_1:
	LAC	MSG
	XORL	CMSG_KEY2S
	BS	ACZ,LOCAL_PROCID_1_REW	;REW
;LOCAL_PROCID_1_2:	
	LAC	MSG
	XORL	CMSG_KEY1S
	BS	ACZ,LOCAL_PROCID_1_FFW	;FFW
;LOCAL_PROCID_1_3:	
	LAC	MSG
	XORL	CMSG_KEY2P
	BS	ACZ,LOCAL_PROCID_1_PREW	;REW
;LOCAL_PROCID_1_4:	
	LAC	MSG
	XORL	CMSG_KEY1P
	BS	ACZ,LOCAL_PROCID_1_PFFW	;FFW
;LOCAL_PROCID_1_5:
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,LOCAL_PROCID_1_MENU	;MENU
;LOCAL_PROCID_1_6:
	LAC	MSG
	XORL	CMSG_KEY4S
	BS	ACZ,LOCAL_PROCID_1_PLAY	;PLAY,������ȡ,��Filter-pbook��ʽ����
;LOCAL_PROCID_1_7:
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,LOCAL_PROCID_END	;STOP
;LOCAL_PROCID_1_8:
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,LOCAL_PROCID_1_ERAONE	;
;LOCAL_PROCID_1_9:
	LAC	MSG
	XORL	CMSG_KEY8L
	BS	ACZ,LOCAL_PROCID_1_ERAALL	;
;LOCAL_PROCID_1_10:	
	LAC	MSG
	XORL	CMSG_KEYAS
	BS	ACZ,LOCAL_PROCID_1_FFW	;Enter the CID-book
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,MAIN_PRO6_0_0_TMR	;
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROCID_1_VPSTOP	;
;LOCAL_PROCID_1_12:
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,LOCAL_PROCID_X_RINGIN

	RET
;---------------------------------------
LOCAL_PROCID_1_VPSTOP:
	CALL	DAA_OFF
	LACK	0
	SAH	PRO_VAR1	;����������(�����ɿ���BEEP����)	

	LAC	MSG_T
	BS	ACZ,LOCAL_PROCID_END

	RET

;---------------------------------------
MAIN_PRO6_0_0_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	30
	BZ	SGN,LOCAL_PROCID_END

	RET
;---------------------------------------
LOCAL_PROCID_1_PLAY:		;�˴��ĵ�ַ���ò��յ绰������
	LAC	MSG_ID
	BS	ACZ,MAIN_PRO6_WARN	;����Ŀ��Ϊ��,����ת��
	
	CALL	INIT_DAM_FUNC
;---����CID����
	LACK	CGROUP_CID
	CALL	SET_TELGROUP	;set group 4
	LACL	TEL_RAM
	SAH	ADDR_D		;Address-Base
	LACK	0
	SAH	OFFSET_D	;Address-Offset
	LAC	MSG_ID		;TEL-index
	CALL	READ_TELNUM	;
	CALL	STOPREADDAT
;---Get TEL-flag	
	LACL	TEL_RAM
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	CALL	GETBYTE_DAT	;Get flag-num
	SAH	FILE_LEN
	CALL	GETBYTE_DAT	;Get flag-name
	SFL	8
	ANDL	0XFF00
	OR	FILE_LEN
	SAH	FILE_LEN	;�ȱ���flag��Ϣ(Number/Name)
;---�ƶ�����	
	LAC	FILE_LEN
	ANDK	0X7F
	ADHK	1
	SFR	2		;����ѹ����ĳ���
	ADHK	2		;ͷ��Flag(4bytes)
	ADHL	TEL_RAM
	SAH	ADDR_S		;�洢�����Ŀ�ʼ����ַ
	LACL	TEL_RAM+12
	SAH	ADDR_D		;ת��������Ŀ�����ַ

	LAC	FILE_LEN
	ANDK	0X7F
	ADHK	1
	SFR	1
	ANDK	0X1
	SAH	OFFSET_S	;������ĳ���Ϊ4*L+1��4*L+2ʱ
	
	LACK	0
	SAH	OFFSET_D
	
	LAC	FILE_LEN
	SFR	8
	ANDK	0X7F
	ADHK	1	;����һ��BYTE
	SAH	COUNT		;Ҫ���ƶ��ĳ���(BYTE)
	CALL	MOVE_LTOH	;�������ƶ�
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.if	1
	LACL	0X9E		;����mcuת�����
	CALL	SEND_DAT
	LACK	2
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
.endif
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;---��ʼ�Ƚ�Tel-num
	;LACL	TEL_RAM
	;SAH	ADDR_S
	;SAH	ADDR_D

	;LACK	CGROUP_PBOOK
	;CALL	SET_TELGROUP	;set group 4
	;CALL	COMP_ALLTELNUM
	;BS	ACZ,LOCAL_PROCID_1_TIME_SAVETOBOOK
	;SAH	MSG_ID
	
	;CALL	CLR_FUNC
	;LACL	0X0
	;SAH	PRO_VAR
	;LACL	CNAME_EDIT	;the same TEL-number find in phonebook
	;CALL	STOR_MSG

	;RET
;LOCAL_PROCID_1_TIME_SAVETOBOOK:
;---�༭����
	CALL	INIT_DAM_FUNC
	CALL	CLR_FUNC
	LACL	0X0
	SAH	PRO_VAR
	LACL	CNUMB_ECID	;Note !!! MSG_ID specific the current TEL
	CALL	STOR_MSG

	RET
;---------------------------------------
MAIN_PRO6_WARN:			;������
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BBBEEP
	LACK	0X07D
	CALL	STOR_VP
	
	RET
;-------------------------------------------------------------------------------	
LOCAL_PROCID_1_REW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
LOCAL_PROCID_1_PREW:	
	LACK	0
	SAH	SYSTMP1
	LAC	MSG_T
	SAH	SYSTMP2

	LAC	MSG_ID
	CALL	VALUE_ADD
	SAH	MSG_ID
LOCAL_PROCID_1_SENDFORDISP:
	
	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER

	LACL	TEL_RAM
	SAH	ADDR_D		;Address-Base
	LACK	0
	SAH	OFFSET_D	;Address-Offset
	LAC	MSG_ID		;��Ŀ��
	CALL	READ_TELNUM	;����ǰ��Ŀ����
	CALL	STOPREADDAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LAC	MSG_ID
	ORL	0XEA00		;Get index-0 by specific TEL-message number
	CALL	DAM_BIOSFUNC
	CALL	TELFG_CHK
	SAH	SYSTMP0		;Save the flag
;---
	LACL	TEL_RAM
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	LAC	SYSTMP0		;TEL-flag
	CALL	TEL_SENDCOMM	;��������
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LAC	MSG_ID
	ORL	0XEA00		;Get index-0 by specific TEL-message number
	CALL	DAM_BIOSFUNC
	ANDK	0X7F	;Clear new-flag(bit7) only !!!!!!!!!!!!!!!!
	SFL	8
	ANDL	0XFF00
	SAH	SYSTMP0
;---Set index-0 of the newest cid
	LAC	MSG_ID		;��Ŀ��
	OR	SYSTMP0		;new-flag=0
	CALL	SET_TEL0ID	;Clear the new-flag
;---------Check NewCid
	CALL	GET_TELN
	BZ	ACZ,NEWLEDFG_1	;
	CALL	CLR_LED1FG	;clear new call flag	
NEWLEDFG_1:
;---------Check NewVIPCid
	CALL	GET_VIPNTEL	;Get the number of new-VIP TEL
	BZ	ACZ,NEWVIPCIDFG_1
	
	LAC	VOP_FG
	ANDL	~(1<<14)
	SAH	VOP_FG
NEWVIPCIDFG_1:
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XCA
	CALL	SEND_DAT
	LAC	MSG_ID
	CALL	SEND_DAT	;��ʾ����
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LAC	MSG_T
	BS	ACZ,MAIN_PRO6_WARN	;����Ŀ��Ϊ��,���ܷ���
	
	RET
;---------------------------------------
LOCAL_PROCID_1_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
LOCAL_PROCID_1_PFFW:
	LACK	0
	SAH	SYSTMP1
	LAC	MSG_T
	SAH	SYSTMP2

	LAC	MSG_ID
	CALL	VALUE_SUB
	SAH	MSG_ID
	BS	B1,LOCAL_PROCID_1_SENDFORDISP
;---------------------------------------
LOCAL_PROCID_1_MENU:
	LAC	MSG_ID
	BS	ACZ,MAIN_PRO6_WARN	;;��Ŀ��Ϊ��,���ܻذ�
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
	
	LACK	0X02
	SAH	PRO_VAR
	
	LACK	0
	SAH	PRO_VAR1	;���¿�ʼ��ʱ,�����ذ���������
	LACL	1000
	CALL	SET_TIMER
	
	RET
;---------------------------------------
LOCAL_PROCID_END:	;�����˳�
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BBEEP
	
	CALL	CLR_FUNC
	LACK	0
	SAH	PRO_VAR
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9E
	CALL	SEND_DAT
	LACK	6
	CALL	SEND_DAT
	LACL	0xFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	RET
;---------------------------------------
LOCAL_PROCID_1_ERAONE:
	LAC	MSG_ID
	BS	ACZ,MAIN_PRO6_WARN	;��Ŀ��Ϊ��,����ɾ��
	
	LACL	0X13
	SAH	PRO_VAR
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	LACL	0XCC
	CALL	SEND_DAT
	LACK	0
	CALL	SEND_DAT	;LCD Disp "delete it ?"
	LACL	0xFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	BS	B1,LOCAL_PROCID_1_ERABEEP
;---------------------------------------
LOCAL_PROCID_1_ERAALL:
	LACL	0X23
	SAH	PRO_VAR
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	LACL	0XCC
	CALL	SEND_DAT
	LACK	2	;LCD Disp "Delete all CID ?"
	CALL	SEND_DAT	
	LACL	0xFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
LOCAL_PROCID_1_ERABEEP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP

	RET
;-------------------------------------------------------------------------------	
LOCAL_PROCID_2:
	LAC	PRO_VAR
	SFR	4
	ANDK	0XF
	BS	ACZ,LOCAL_PROCID_2_0	;�ȴ�(�κŷ�ʽ)
	SBHK	1
	BS	ACZ,LOCAL_PROCID_2_1	;��ʽ�κ�
	
	RET
;---------------------------------------
LOCAL_PROCID_2_0:
;LOCAL_PROCID_2_0_0:
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,LOCAL_PROCID_2_0_MENU	;MENU
;LOCAL_PROCID_2_0_1:
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PROCID_2_0_TMR	;TMR
	
	RET
;---------------------------------------
LOCAL_PROCID_2_0_MENU:	;��0�κ�
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP

	LACL	0X12
	SAH	PRO_VAR
	
	CALL	HOOK_ON
;!!!!!!!!!!!!!!! !!!!!!!!!!!!!  	
     	LACL	0XD0		;����MCUժ����
	CALL	SEND_DAT
	LACK	0
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!		
	LACL	0X9E		;����MCU�κ�
	CALL	SEND_DAT
	LACK	4
	CALL	SEND_DAT
	LACL	0xFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	1000
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1
	
	RET
;---------------------------------------
LOCAL_PROCID_2_0_TMR:	;�κ�
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	2
	BS	SGN,LOCAL_PROCID_2_0_TMR_END
	
	LACL	0X12
	SAH	PRO_VAR

	LACK	0
	SAH	PRO_VAR1
	CALL	HOOK_ON
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
     	LACL	0XD0		;����MCUժ����
	CALL	SEND_DAT
	LACK	0
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	LACL	0X9E		;����MCU�κ�
	CALL	SEND_DAT
	LACK	3
	CALL	SEND_DAT
	LACL	0xFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
LOCAL_PROCID_2_0_TMR_END:
	RET
;---------------------------------------------------------------------
LOCAL_PROCID_2_1:
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PROCID_2_1_TMR	;TMR
	
	RET
;---------------------------------------
LOCAL_PROCID_2_1_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	8
	BS	SGN,LOCAL_PROCID_2_0_TMR_END	;�����κ������8sec�˳�

	CALL	CLR_FUNC
	LACK	0
	SAH	PRO_VAR
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XD0		;����MCU�һ���
	CALL	SEND_DAT
	LACK	1
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!		
	LACL	0X9E
	CALL	SEND_DAT
	LACK	6
	CALL	SEND_DAT
	LACL	0xFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	CALL	HOOK_OFF

	RET
;-------------------------------------------------------------------------------
LOCAL_PROCID_3:
;LOCAL_PROCID_3_0:
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,LOCAL_PROCID_3_ERASE	;ERASE
;LOCAL_PROCID_3_1:
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,LOCAL_PROCID_3_STOP		;ON/OFF
;LOCAL_PROCID_3_2:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROCID_1_VPSTOP
;LOCAL_PROCID_3_3:
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,LOCAL_PROCID_X_RINGIN
	RET
;---------------------------------------
LOCAL_PROCID_3_ERASE:
	LAC	PRO_VAR
	SFR	4
	ANDK	0X0F
	BS	ACZ,LOCAL_PROCID_3_ERASE_0
	SBHK	1
	BS	ACZ,LOCAL_PROCID_3_ERASE_1	;Delete current tel-num
	SBHK	1
	BS	ACZ,LOCAL_PROCID_3_ERASE_2	;wait for key-released
	SBHK	1
	BS	ACZ,LOCAL_PROCID_3_ERASE_3	;Delete all tel-num
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROCID_3_ERASE_0:		;Reserved
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROCID_3_ERASE_1:			;ȷ��ɾ����ǰ����
	CALL	INIT_DAM_FUNC

LOCAL_PROCID_3_ERASE_1_EXE:	

	LAC	MSG_ID
	CALL	DEL_ONETEL	;ɾ��
	CALL	TEL_GC_CHK
	CALL	GC_CHK

	CALL	GET_TELT
	SBH	MSG_T
	BS	ACZ,LOCAL_PROCID_3_ERASE_1_EXE	;ɾ�����ɹ�������һ��

	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
	CALL	GET_TELT
	SAH	MSG_T		;���¾�����֮ǰ
	
	LACK	0X01
	SAH	PRO_VAR

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X82		;�¾�����ͬ��
	CALL	SEND_DAT
	LACK	0
	CALL	SEND_DAT
	LAC	MSG_T
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LAC	MSG_ID
	SBHK	1
	SAH	MSG_ID
	SBH	MSG_T			;���һ����?
	BS	SGN,LOCAL_PROCID_1_PFFW
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XCA
	CALL	SEND_DAT
	LACK	0X0
	SAH	MSG_ID
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	RET
;---------------------------------------
LOCAL_PROCID_3_ERASE_2:
	LACL	0X033
	SAH	PRO_VAR
	
	RET
;---------------------------------------
LOCAL_PROCID_3_ERASE_3:		;ȷ��ɾ������
	CALL	INIT_DAM_FUNC
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	LACL	0XCC
	CALL	SEND_DAT
	LACK	3
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
LOCAL_PROCID_3_ERASE_EXE:
	CALL	GET_TELT
	CALL	DEL_ALLTEL	;ɾ����������
	CALL	GET_TELT
	BZ	ACZ,LOCAL_PROCID_3_ERASE_EXE	;ɾ�����ɹ�������һ��
	CALL	TEL_GC_CHK
;---------Check NewCid
	CALL	GET_TELN
	BZ	ACZ,LOCAL_PROCID_3_NEWLEDFG_1	;
	CALL	CLR_LED1FG	;clear new call flag	
LOCAL_PROCID_3_NEWLEDFG_1:
;---------Check NewVIPCid
	CALL	GET_VIPNTEL	;Get the number of new-VIP TEL
	BZ	ACZ,LOCAL_PROCID_3_NEWVIPCIDFG_1
	
	LAC	VOP_FG
	ANDL	~(1<<14)
	SAH	VOP_FG
LOCAL_PROCID_3_NEWVIPCIDFG_1:	
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X82		;�¾�����ͬ��
	CALL	SEND_DAT
	LACK	0
	CALL	SEND_DAT
	LACK	0
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9E
	CALL	SEND_DAT
	LACK	6
	CALL	SEND_DAT
	LACL	0xFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	CLR_FUNC
	LACK	0
	SAH	PRO_VAR
	
	RET
;---------------------------------------
LOCAL_PROCID_3_STOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XCA
	CALL	SEND_DAT
	LAC	MSG_ID
	CALL	SEND_DAT
	LACL	0xFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	0X01
	SAH	PRO_VAR
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROCID_X_RINGIN:
	CALL	INIT_DAM_FUNC
	LACK	0
	SAH	PRO_VAR
	CALL	BLED_ON
	LACL	CMSG_INIT
	CALL	STOR_MSG
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9E
	CALL	SEND_DAT
	LACL	6
	CALL	SEND_DAT
	LACL	0xFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROCID_4:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROCID_4_VPSTOP	;	

	RET
;---------------------------------------
LOCAL_PROCID_4_VPSTOP:
	
	BIT	MSG_T,7
	BZ	TB,LOCAL_PROCID_4_VPSTOP_END	;����ֵ����
	
	LAC	MSG_T
	ANDK	0X7F
	SBH	MSG_ID
	sbhk	1
	BS	SGN,LOCAL_PROCID_4_VPSTOP_END	;�Ѳ�����

	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK

	LACL	TEL_RAM
	SAH	ADDR_S

	LAC	MSG_ID
	ADHK	2
	SAH	MSG_ID		;two num every byte
	SBHK	2
	SFR	1
	ADHK	4	;Ҫ���2-word(4��byte) flag
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	SAH	MSG_N
	
;---����Ƿ�������
	LAC	MSG_N
	SFR	4
	ANDK	0X0F
	SBHK	10
	BZ	SGN,LOCAL_PROCID_4_VPSTOP_END	;>10,��Ч
	LAC	MSG_N
	SFR	4
	ANDK	0X0F
	CALL	ANNOUNCE_NUM
	
	LAC	MSG_N
	ANDK	0X0F
	SBHK	10
	BZ	SGN,LOCAL_PROCID_4_VPSTOP_1	;>10,��Ч(��ǰһ����Ч)
	LAC	MSG_N
	ANDK	0X0F
	CALL	ANNOUNCE_NUM
LOCAL_PROCID_4_VPSTOP_1:
	
	RET
;-------------------	
LOCAL_PROCID_4_VPSTOP_END:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACK	0X005
	CALL	STOR_VP
	
	CALL	CLR_FUNC	;�ȿ�
     	LACK	0
     	SAH	PRO_VAR
     	
	RET
;-------------------------------------------------------------------------------
;	TEL-flag check
;	new-flag only
;	input : ACCH
;	output : ACCH
;-------------------------------------------------------------------------------
TELFG_CHK:

	PSH	SYSTMP0
	PSH	SYSTMP1
	
	SAH	SYSTMP1
	ANDL	0XFF00
	BZ	ACZ,TELFG_CHK_OLD	;Error

	LACK	(1<<1)
	SAH	SYSTMP0
	
	BIT	SYSTMP1,7
	BS	TB,TELFG_CHK_END
TELFG_CHK_OLD:	
	LACK	0
	SAH	SYSTMP0
TELFG_CHK_END:
	LAC	SYSTMP0	
	
	POP	SYSTMP1
	POP	SYSTMP0	

	RET	

;-------------------------------------------------------------------------------
;	����Number��Name�����ޱ�ǶԳ��Ⱥͱ�ǽ������
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
TELDATA_CHK:
	SAH	SYSTMP0
	BIT	SYSTMP0,7
	BS	TB,TELDATA_CHK_NUMBER
;---No Number
	LAC	SYSTMP0
	ANDL	0XFF00
	SAH	SYSTMP0
TELDATA_CHK_NUMBER:
	BIT	SYSTMP0,15
	BS	TB,TELDATA_CHK_NAME
;---No Name	
	LAC	SYSTMP0
	ANDL	0X00FF
	SAH	SYSTMP0
TELDATA_CHK_NAME:
	LAC	SYSTMP0	
	
	RET
;-------------------------------------------------------------------------------
;	����Name��ǶԳ��Ⱥͱ�ǽ�����λ�͸�ֵ
;	input : ACCH
;	output: ACCH
;-------------------------------------------------------------------------------
TELNAME_ADD:
	SAH	SYSTMP0
	BIT	SYSTMP0,15
	BS	TB,TELNAME_ADD_NAME
;---No Name	
	LAC	SYSTMP0
	ANDL	0X00FF
	ORL	(1<<15)|(1<<8)		;Set flag and length
	SAH	SYSTMP0
TELNAME_ADD_NAME:
	LAC	SYSTMP0	
	
	RET

;-------------------------------------------------------------------------------
.INCLUDE l_tel.asm
;-------------------------------------------------------------------------------
.END

