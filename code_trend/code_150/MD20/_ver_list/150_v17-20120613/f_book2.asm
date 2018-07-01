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
.GLOBAL	LOCAL_PROBOOK2
;-------------------------------------------------------------------------------
.LIST
.ORG    ADDR_SECOND
;-------------------------------------------------------------------------------
;	����/�༭�绰��
;	NOTE : MSG_ID/MSG_T/MSG_N = current_TEL_ID/the total number of tel/the order of current tel
;-------------------------------------------------------------------------------
LOCAL_PROBOOK2:
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,MAIN_PROX_RINGIN
	LAC	MSG
	XORL	CVP_STOP		;PLAY END
	BS	ACZ,MAIN_PRO10_VPSTOP
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,MAIN_PRO10_TMR
;---
	LAC	MSG
	XORL	CNUMB_BADD	;phone-book Add(add phone-number)
	BS	ACZ,LOCAL_PROBOOK2_0_BADD
	LAC	MSG
	XORL	CNAME_BADD
	BS	ACZ,LOCAL_PROBOOK2_NAMEADD
;---	
	LAC	PRO_VAR
	ANDK	0X0F
	BS	ACZ,LOCAL_PROBOOK2_0	;(0xyyy0)local-idle to display
	SBHK	1
	BS	ACZ,LOCAL_PROBOOK2_1	;(0xyyy1)TEL-number
	SBHK	1
	BS	ACZ,LOCAL_PROBOOK2_2	;(0xyyy2)TEL-name

	RET
;-------------------------------------------------------------------------------
MAIN_PRO10_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	30
	BZ	SGN,LOCAL_PROBOOK2_EXIT		;�޲�����ʱ�˳�

	RET
;---------------
LOCAL_PROBOOK2_EXIT:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BBEEP
	
	CALL	CLR_FUNC
	LACK	0
	SAH	PRO_VAR1
	SAH	PRO_VAR
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9E		;exit COMMAND
	CALL	SEND_DAT
	LACK	6
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	RET
;---------------------------------------
MAIN_PRO10_VPSTOP:
	LACK	0
	SAH	PRO_VAR1		;����������(�����ɿ���BEEP����)	
	CALL	DAA_OFF
	
	RET
;---------------------------------------
LOCAL_PROBOOK2_NAMEADD:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK
	CALL	BEEP
;---��CID-Group��������
	LACK	CGROUP_CID
	CALL	SET_TELGROUP	;

	LACL	TEL_RAM
	SAH	ADDR_D		;Address-Base
	LACK	0
	SAH	OFFSET_D	;Address-Offset		;�����ַ
	LAC	MSG_ID		;��Ŀ��
	CALL	READ_TELNUM	;����ǰ��Ŀ����
	CALL	STOPREADDAT
;---ת���绰��Group	
	LACK	CGROUP_PBOOK
	CALL	SET_TELGROUP	;
;---Get TEL-flag	
	LACL	TEL_RAM
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	CALL	GETBYTE_DAT	;Get flag-num/name
	ORL	0X0100
	SAH	FILE_LEN
;---��0XFF����(Number)
	LACL	TEL_RAM+2
	SAH	ADDR_D
	LAC	FILE_LEN	;��0XFF����(Number)
	ANDK	0X1F
	ADHK	1
	SFR	1
	SAH	OFFSET_D
	LACL	0XFF
	CALL	STORBYTE_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.if	0
	LACL	TEL_RAM
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	CALL	TEL_SENDCOMM	;��������

	LACL	0X9F
	CALL	SEND_DAT
	LAC	MSG_ID
	CALL	SEND_DAT	;��ʾ����
	LACL	0XFF
	CALL	SEND_DAT
.endif
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

;---�ƶ�����	
.if	0
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
.endif
;---�Ƚ�Name��������ȫ0xFFFF
	LACL	TEL_RAM+12
	SAH	ADDR_D		;Base address
	LACK	0
	SAH	OFFSET_D	;offset
	LACK	40
	SAH	COUNT		;length
	LACL	0XFF		;data
	CALL	RAM_STOR	;����ʱĬ�ϵĺ�����Ч(16λ)
	
	BS	B1,MAIN_PRO10_2_0_MENU_1
;-------------------------------------------------------------------------------
LOCAL_PROBOOK2_0:
	
	RET
;---------------------------------------
LOCAL_PROBOOK2_0_BADD:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
	
	LACK	0X0001
	SAH	FILE_LEN	;���ӵ绰����Ӧ"����(7..0)+����(15..8)"��Ϣ
				;���ӵ绰��û��ʱ���OGM_ID,����ʱֱ��Ϊ��ɲ�������
;---�Ƚ���������ȫ0xFFFF
	LACL	TEL_RAM
	SAH	ADDR_D		;Base address
	LACK	0
	SAH	OFFSET_D	;offset
	LACK	64
	SAH	COUNT		;length
	LACL	0XFF		;data
	CALL	RAM_STOR	;����ʱĬ�ϵĺ�����Ч(16λ)

	LACL	0XA0
	SAH	NEW_ID
	LACK	0X0F
	SAH	MSG_N

	LACK	0X01
	SAH	PRO_VAR		;��������״̬
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LAC	NEW_ID		;SEND COMMAND 
	CALL	SEND_DAT
	LAC	MSG_N
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

	RET
;-------------------------------------------------------------------------
LOCAL_PROBOOK2_1:		;(tel-number)

;MAIN_PRO10_2_0_0_1:
	LAC	MSG
	XORL	CMSG_KEY5S
	BS	ACZ,MAIN_PRO10_2_0_0_REW	;REW
;MAIN_PRO10_2_0_0_2:
	LAC	MSG
	XORL	CMSG_KEY9S
	BS	ACZ,MAIN_PRO10_2_0_0_FFW	;FFW
;MAIN_PRO10_2_0_0_3:
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,MAIN_PRO10_X_END	;EXIT no save
;MAIN_PRO10_2_0_0_4:
	;LAC	MSG
	;XORL	CMSG_TMR
	;BS	ACZ,MAIN_PRO10_TMR	;TMR
;MAIN_PRO10_2_0_0_5:
	LAC	MSG
	XORL	CMSG_KEY3S
	BS	ACZ,MAIN_PRO10_2_0_0_TIME	;TIME
;MAIN_PRO10_2_0_0_6:
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO10_2_0_0_MENU	;MENU
;MAIN_PRO10_2_0_0_7:
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,MAIN_PRO10_2_0_0_ERASE 	;ERASE
;MAIN_PRO10_2_0_0_8:	
	LAC	MSG
	XORL	CMSG_KEY5P
	BS	ACZ,MAIN_PRO10_2_0_0_PREW	;REW
;MAIN_PRO10_2_0_0_9:
	LAC	MSG
	XORL	CMSG_KEY9P
	BS	ACZ,MAIN_PRO10_2_0_0_PFFW	;FFW

	RET
;---------------------------------------
MAIN_PRO10_2_0_0_REW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
MAIN_PRO10_2_0_0_PREW:
	LACK	0
	SAH	SYSTMP1
	LACK	9
	SAH	SYSTMP2
	
	LAC	MSG_N
	CALL	VALUE_SUB
	SAH	MSG_N
	
	BS	B1,MAIN_PRO10_X_SENDCOMM
;---------------------------------------
MAIN_PRO10_2_0_0_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
MAIN_PRO10_2_0_0_PFFW:	
	LACK	0
	SAH	SYSTMP1
	LACK	9
	SAH	SYSTMP2
	
	LAC	MSG_N
	CALL	VALUE_ADD
	SAH	MSG_N
	;BS	B1,MAIN_PRO10_X_SENDCOMM
MAIN_PRO10_X_SENDCOMM:
	LAC	NEW_ID
	CALL	SEND_DAT	;��(NEW_ID)λ
	LAC	MSG_N
	CALL	SEND_DAT	;ֵ
	LACL	0XFF
	CALL	SEND_DAT	;ָ�����
	
	RET
;---------------------------------------			
MAIN_PRO10_2_0_0_TIME:		;������һλ
	LAC	MSG_N		;�����ǰֵ����Ч����(����10 or С��0)���ܽ��뵽��һλ����
	BS	SGN,MAIN_PRO10_2_X_TIMEEND
	SBHK	10
	BZ	SGN,MAIN_PRO10_2_X_TIMEEND
;---	
	LAC	NEW_ID
	XORL	0XAF
	BS	ACZ,MAIN_PRO10_2_0_0_MENU	;���һλ(�ɱ���FILE_LEN���������)
;---���浱ǰֵ
	LACL	TEL_RAM+2	;BASE address
	SAH	ADDR_D
	LAC	NEW_ID		;offset
	ANDK	0X0F
	SAH	OFFSET_D
	LAC	MSG_N		;ֵ
	CALL	STORBYTE_DAT
;---ȡ��һ��
	LAC	FILE_LEN
	ADHK	0X0001
	ANDK	0X001F
	SAH	FILE_LEN		;����λ����1(���õ�ǰNEW_ID����)
;---	
	LACL	0XA0
	SAH	SYSTMP1
	LACL	0XAF
	SAH	SYSTMP2
	LAC	NEW_ID
	CALL	VALUE_ADD
	SAH	NEW_ID		;get next command
;---
	LACL	TEL_RAM+2	;BASE address
	SAH	ADDR_S
	LAC	NEW_ID		;offset
	ANDK	0X0F
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	ANDK	0X7F
	SAH	MSG_N
MAIN_PRO10_2_0_TIME_END:
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
	
	BS	B1,MAIN_PRO10_X_SENDCOMM
;---------------------------------------
MAIN_PRO10_2_X_TIMEEND:		;�Ƿ�����
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BBBEEP		;BBB
	
	RET	
;---------------------------------------	
LOCAL_PROBOOK2_2_MENUEND:	;Press "Menu" when Edit TEL-Name ;but the length of Name is 0
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BBBEEP		;BBB

	LAC	FILE_LEN
	ANDK	0X003F
	ORL	0X0100
	SAH	FILE_LEN	;������������1

	RET
;---------------------------------------
LOCAL_PROBOOK2_1_MENUEND:	;Press "Menu" when Edit TEL-Number ;but the length of Number is 0
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BBBEEP		;BBB

	LACK	1		
	SAH	FILE_LEN	;���ú��볤��1

	RET
;---------------------------------------
MAIN_PRO10_2_0_0_MENU:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
;---���浱ǰֵ
	LACL	TEL_RAM+2	;BASE address
	SAH	ADDR_D
	LAC	NEW_ID		;ƫ��
	ANDK	0X0F
	SAH	OFFSET_D
	LAC	MSG_N		;ֵ
	CALL	STORBYTE_DAT

	LAC	MSG_N		;�����ǰֵ����Ч����(����10 or С��0)�򳤶ȼ�1
	BS	SGN,MAIN_PRO10_2_0_0_MENU_0
	SBHK	10
	BZ	SGN,MAIN_PRO10_2_0_0_MENU_0
	BS	B1,MAIN_PRO10_2_0_0_MENU_0_1	;��Ч�ַ�
MAIN_PRO10_2_0_0_MENU_0:
	LAC	FILE_LEN
	SBHK	1
	SAH	FILE_LEN
	ANDK	0X1F
	BS	ACZ,LOCAL_PROBOOK2_1_MENUEND	;���볤��Ϊ0,���ܽ��������༭
MAIN_PRO10_2_0_0_MENU_0_1:
;---������͵�ѹ��
	LACL	TEL_RAM+2
	SAH	ADDR_S
	SAH	ADDR_D
	LACK	0
	SAH	OFFSET_S
	SAH	OFFSET_D
	LAC	FILE_LEN
	ANDK	0X7F
	SAH	COUNT
	CALL	CONCEN_DAT
MAIN_PRO10_2_0_0_MENU_1:	;���봦�����,��ʼ�����Ĵ���
	LAC	FILE_LEN
	ORL	0X0100
	SAH	FILE_LEN
	SAH	NEW_ID		;
;---��ʼ�Ƚ�Tel-num
	LACL	TEL_RAM
	SAH	ADDR_S
	SAH	ADDR_D

	CALL	COMP_ALLTELNUM
	BS	ACZ,MAIN_PRO10_2_0_MENU_1
	SAH	MSG_ID
;---�Ƚ�==>�����ӵ��༭
;---�ҵ�����ͬ�������Ŀ,������༭�绰���������޸��ֶ�	
	CALL	CLR_FUNC
	LACL	0X0
	SAH	PRO_VAR
	LACL	CNAME_EDIT
	CALL	STOR_MSG

	RET
;����---����---��Ϊ�༭����״̬
MAIN_PRO10_2_0_MENU_1:
	LACL	0XB0
	SAH	NEW_ID
	LACK	0X7F
	SAH	MSG_N		;current value

	LACK	0X02
	SAH	PRO_VAR		;����༭����
	BS	B1,MAIN_PRO10_X_SENDCOMM
;---------------------------------------
MAIN_PRO10_2_0_0_ERASE:
	LAC	NEW_ID
	SBHL	0XA0
	BZ	ACZ,MAIN_PRO10_2_0_0_ERASE1
	
	LACK	0XF
	SAH	MSG_N
	BS	B1,MAIN_PRO10_X_SENDCOMM	
MAIN_PRO10_2_0_0_ERASE1:	;���ǵ�һλʱ
;---���浱ǰֵ0X0F
	LACL	TEL_RAM+2	;BASE address
	SAH	ADDR_D
	LAC	NEW_ID		;ƫ��
	ANDK	0X0F
	SAH	OFFSET_D
	LACK	0X0F		;ֵ
	CALL	STORBYTE_DAT
;---ȡ��һ��
	LAC	FILE_LEN
	SBHK	0X01
	SAH	FILE_LEN
	
	LACL	0XA0
	SAH	SYSTMP1
	LACL	0XAF
	SAH	SYSTMP2
	LAC	NEW_ID
	CALL	VALUE_SUB
	SAH	NEW_ID		;get next command

	LACL	TEL_RAM+2	;BASE address
	SAH	ADDR_S
	LAC	NEW_ID		;offset
	ANDK	0X0F
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	ANDK	0X7F
	SAH	MSG_N
MAIN_PRO10_2_X_ERASE_SENDCOMM:	;ɾ������֮��������ʾ��һλ
	LAC	NEW_ID
	CALL	SEND_DAT	;��(NEW_ID)λ
	LACL	0X80
	CALL	SEND_DAT	;ֵ0X80
	LACL	0XFF
	CALL	SEND_DAT
	
	LAC	NEW_ID
	CALL	SEND_DAT	;��(NEW_ID)λ
	LAC	MSG_N
	CALL	SEND_DAT	;ֵ0X80
	LACL	0XFF
	CALL	SEND_DAT
;---BEEP
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP

	RET
MAIN_PRO10_2_0_1_SENDCOMM_DISP:
	LACL	0X9F
	CALL	SEND_DAT
	LAC	MSG_ID
	CALL	SEND_DAT	;��ʾ����
	LACL	0XFF
	CALL	SEND_DAT

	RET

;---------------------------------------------------------------------
LOCAL_PROBOOK2_2:		;����
;MAIN_PRO10_2_1_1:
	;LAC	MSG
	;XORL	CVP_STOP		;PLAY END
	;BS	ACZ,MAIN_PRO10_VPSTOP
;MAIN_PRO10_2_1_2:	
	LAC	MSG
	XORL	CMSG_KEY5S
	BS	ACZ,MAIN_PRO10_2_1_REW	;REW
;MAIN_PRO10_2_1_3:
	LAC	MSG
	XORL	CMSG_KEY9S
	BS	ACZ,MAIN_PRO10_2_1_FFW	;FFW
;MAIN_PRO10_2_1_4:
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,MAIN_PRO10_X_END	;EXIT no save
;MAIN_PRO10_2_1_5:
	;LAC	MSG
	;XORL	CMSG_TMR
	;BS	ACZ,MAIN_PRO10_TMR	;(������ʱ��Ӧ����)
;MAIN_PRO10_2_1_6:
	LAC	MSG
	XORL	CMSG_KEY3S
	BS	ACZ,MAIN_PRO10_2_1_TIME	;TIME
;MAIN_PRO10_2_1_7:
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO10_2_1_MENU	;MENU
;MAIN_PRO10_2_1_8:
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,MAIN_PRO10_2_1_ERASE ;ERASE
;MAIN_PRO10_2_1_9:	
	LAC	MSG
	XORL	CMSG_KEY5P
	BS	ACZ,MAIN_PRO10_2_1_PREW	;REW
;MAIN_PRO10_2_1_10:
	LAC	MSG
	XORL	CMSG_KEY9P
	BS	ACZ,MAIN_PRO10_2_1_PFFW	;FFW

	RET
;---------------------------------------
MAIN_PRO10_2_1_ERASE:
	LAC	NEW_ID
	SBHL	0XB0
	BZ	ACZ,MAIN_PRO10_2_1_ERASE1
	
	LACK	0X7F
	SAH	MSG_N
	BS	B1,MAIN_PRO10_2_1_ERASEEND
MAIN_PRO10_2_1_ERASE1:	

;---���浱ǰֵ0X7F
	LACL	TEL_RAM+12	;BASE address
	SAH	ADDR_D
	LAC	NEW_ID		;ƫ��
	ANDK	0X0F
	SAH	COUNT
	LACK	0X7F		;ֵ
	CALL	STORBYTE_DAT
;---ȡ��һ��
	LAC	FILE_LEN
	SBHL	0X0100
	SAH	FILE_LEN

	LACL	0XB0
	SAH	SYSTMP1
	LACL	0XBF
	SAH	SYSTMP2
	LAC	NEW_ID
	CALL	VALUE_SUB
	SAH	NEW_ID		;get next command
	
	LACL	TEL_RAM+12	;BASE address
	SAH	ADDR_S		;BASE address
	LAC	NEW_ID		;offset
	ANDK	0X0F
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	ANDK	0X7F
	SAH	MSG_N

	BS	B1,MAIN_PRO10_2_X_ERASE_SENDCOMM

MAIN_PRO10_2_1_ERASEEND:
	BS	B1,MAIN_PRO10_X_SENDCOMM
;---------------------------------------
MAIN_PRO10_2_1_REW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
MAIN_PRO10_2_1_PREW:
	LACK	0
	SAH	SYSTMP1
	LACK	0X24
	SAH	SYSTMP2
	
	LAC	MSG_N
	CALL	VALUE_SUB
	SAH	MSG_N
	
	BS	B1,MAIN_PRO10_X_SENDCOMM
;---------------------------------------
MAIN_PRO10_2_1_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
MAIN_PRO10_2_1_PFFW:	
	LACK	0
	SAH	SYSTMP1
	LACK	0X24
	SAH	SYSTMP2
	
	LAC	MSG_N
	CALL	VALUE_ADD
	SAH	MSG_N
	
	BS	B1,MAIN_PRO10_X_SENDCOMM
;---------------------------------------
MAIN_PRO10_2_1_TIME:
	LAC	MSG_N		;�����ǰֵ����Ч����(����0X25 or С��0)���ܽ��뵽��һλ����
	BS	SGN,MAIN_PRO10_2_X_TIMEEND
	SBHK	0X25
	BZ	SGN,MAIN_PRO10_2_X_TIMEEND
;-��������Ч�ַ�(0..0X24)ֵ	
	LAC	NEW_ID
	XORL	0XB0
	BZ	ACZ,MAIN_PRO10_2_1_TIME1	;���ǵ�һλ��ת
	
	LAC	MSG_N
	XORL	0X24
	BS	ACZ,MAIN_PRO10_2_X_TIMEEND	;��һλΪ�ո�
MAIN_PRO10_2_1_TIME1:	
	LAC	NEW_ID
	XORL	0XBF
	BS	ACZ,MAIN_PRO10_2_1_MENU		;�����һλ�����˳�
MAIN_PRO10_2_1_TIME2:
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
;---���浱ǰֵ
	LACL	TEL_RAM+12	;BASE address
	SAH	ADDR_D
	LAC	NEW_ID		;ƫ��
	ANDK	0X0F
	SAH	OFFSET_D
	LAC	MSG_N		;ֵ
	CALL	STORBYTE_DAT
;---ȡ��һ��
	LAC	FILE_LEN
	ADHL	0X0100
	ANDL	0X1FFF
	SAH	FILE_LEN		;ӦȡNEW_ID�ĵ�4λ���ֵ��1

	LACL	0XB0
	SAH	SYSTMP1
	LACL	0XBF
	SAH	SYSTMP2
	LAC	NEW_ID
	CALL	VALUE_ADD
	SAH	NEW_ID		;get next command

	LACL	TEL_RAM+12	;BASE address
	SAH	ADDR_S
	LAC	NEW_ID		;offset
	ANDK	0X0F
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	ANDK	0X7F
	SAH	MSG_N

	BS	B1,MAIN_PRO10_X_SENDCOMM
;---------------------------------------
MAIN_PRO10_2_1_MENU:		;�������/����(д��FLASH)
;---���浱ǰֵ
	LACL	TEL_RAM+12	;BASE address
	SAH	ADDR_D
	LAC	NEW_ID		;ƫ��
	ANDK	0X0F
	SAH	OFFSET_D
	LAC	MSG_N		;ֵ
	CALL	STORBYTE_DAT
	LACL	0XFF		;��0XFF����
	CALL	STORBYTE_DAT
	
	LAC	MSG_N		;�����ǰֵ����Ч����(����0X24 or С��0)�򳤶ȼ�1
	BS	SGN,MAIN_PRO10_2_1_MENU_0
	SBHK	0X24
	BZ	SGN,MAIN_PRO10_2_1_MENU_0
	BS	B1,MAIN_PRO10_2_1_MENU_0_1
MAIN_PRO10_2_1_MENU_0:	
	LAC	FILE_LEN
	SBHL	0X0100
	SAH	FILE_LEN
	ANDL	0X1F00
	BS	ACZ,LOCAL_PROBOOK2_2_MENUEND	;��Ч�ַ�����Ϊ0
MAIN_PRO10_2_1_MENU_0_1:
;---Set TEL-Group then write into flash
	LACK	CGROUP_PBOOK
	CALL	SET_TELGROUP

	LAC	FILE_LEN
	ANDL	0XFF
	ORL	0X80
	CALL	DAT_WRITE
	LAC	FILE_LEN
	SFR	8
	ORL	0X80
	CALL	DAT_WRITE
	LACK	0
	CALL	DAT_WRITE
	LACK	0
	CALL	DAT_WRITE	;д������(TEL flag)
;---д������(TEL-number)
	LACL	TEL_RAM+2	;BASE address
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	CALL	TELNUM_WRITE	;
;---д������(TEL-name)	
	LACL	TEL_RAM+12
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	CALL	TELNUM_WRITE
;---д������(TEL-time)
	;CALL	TELTIME_WRITE
	
	CALL	DAT_WRITE_STOP
	
	;CALL	GET_TELT	;ȡTEL_ID
	;CALL	SET_TELUSRDAT	;��usr-dat

	;BS	B1,MAIN_PRO10_X_END
;---------------------------------------
MAIN_PRO10_X_END:		;no/save exit(exit,return to Edit/Search status)
.if	0
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
	
	LACK	0X0
	SAH	PRO_VAR		;�绰��״̬
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	LACL	0X9E
	CALL	SEND_DAT
	LACK	0
	SAH	MSG_N
	CALL	SEND_DAT
	LACL	0X0FF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.else
	CALL	INIT_DAM_FUNC

	CALL	CLR_FUNC	;�ȿ�   	
     	LACK	0
     	SAH	PRO_VAR
     	
     	LACL	CBOOK_SLET
     	CALL	STOR_MSG
.endif
	RET

;-------------------------------------------------------------------------------
MAIN_PROX_RINGIN:
	CALL	INIT_DAM_FUNC
	LACK	0
	SAH	PRO_VAR
	CALL	BLED_ON
	LACL	CMSG_INIT
	CALL	STOR_MSG
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9E
	CALL	SEND_DAT
	LACK	6
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!	

	RET
;===============================================================================

;-------------------------------------------------------------------------------	
.END
