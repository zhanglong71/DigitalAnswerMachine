.NOLIST
;*******************************************************************************
;*This section use to edit tel-data(number and name)
;*
;*The program can go to here by the reason as bellow:
;*
;*lookup phonebook then edit the specific telephone-number,respone "CNUMB_EDIT"
;*or
;*lookup CID then edit the specific CID-number to phonebook,respone "CNAME_EDIT"
;*or
;*Add phonebook-number end and find the TEL-data that the number same as the number you enter,respone "CNAME_EDIT"
;*--------------------------------------
;*The program can exit by the reason as bellow:
;*
;*Exit-KEY detected then exit with "CBOOK_SLET"
;*or
;*Menu-KEY detected when edit name then exit with "CLOOK_ATEL"
;*******************************************************************************
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
.GLOBAL	LOCAL_PROBOOK3
;-------------------------------------------------------------------------------
.LIST
.ORG    ADDR_SECOND
;-------------------------------------------------------------------------------
;	�༭�绰��
;	NOTE : MSG_ID/MSG_T/MSG_N = current_TEL_ID/the total number of tel/the order of current tel
;-------------------------------------------------------------------------------
LOCAL_PROBOOK3:
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,LOCAL_PROBOOK_RING
	LAC	MSG
	XORL	CVP_STOP		;PLAY END
	BS	ACZ,LOCAL_PROBOOK_VPSTOP

	LAC	MSG
	XORL	CNUMB_EDIT
	BS	ACZ,LOCAL_PROBOOK1_NUMBEDIT	;lookup -> Edit
	LAC	MSG
	XORL	CNAME_EDIT
	BS	ACZ,LOCAL_PROBOOK1_NAMEEDIT	;Addbook -> Edit

	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,LOCAL_PROBOOK1_TMR

	LAC	PRO_VAR
	ANDK	0X0F
	BS	ACZ,LOCAL_PROBOOK1_0	;local-idle to display
	SBHK	1
	BS	ACZ,LOCAL_PROBOOK1_1	;Edit number
	SBHK	1
	BS	ACZ,LOCAL_PROBOOK1_2	;Edit name
	SBHK	1
	BS	ACZ,LOCAL_PROBOOK1_3	;Save it as Nomal/VIP/Filter

	RET
;---------------------------------------
LOCAL_PROBOOK_RING:		;Exit to idle
	CALL	INIT_DAM_FUNC
	CALL	CLR_FUNC
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
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	
	RET
;---------------------------------------
LOCAL_PROBOOK1_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	30
	BZ	SGN,LOCAL_PROBOOK1_TMROUT

	RET
;-------------------
LOCAL_PROBOOK1_TMROUT:		;Timer out, exit to idle	
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
LOCAL_PROBOOK_VPSTOP:
	LACK	0
	SAH	PRO_VAR1		;����������(�����ɿ���BEEP����)	
	CALL	DAA_OFF
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROBOOK1_0:
	
	RET

;---------------------------------------
LOCAL_PROBOOK1_EXIT:		;Exit to phone-idle(no save exit)
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF	

	CALL	CLR_FUNC	;�ȿ�
     	LACK	0
     	SAH	PRO_VAR
     	
     	LACL	CBOOK_SLET
     	CALL	STOR_MSG
     	
	RET
;---------------------------------------
LOCAL_PROBOOK1_NUMBEDIT:		;����绰��ʱ����༭״̬	
	LAC	MSG_ID
	BS	ACZ,MAIN_PRO10_WARN_VP	;�༭��0������
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
	
	LACL	0X01
	SAH	PRO_VAR		;Edit Phone-number
;---����TEL����
	LACL	TEL_RAM
	SAH	ADDR_D		;Address-Base
	LACK	0
	SAH	OFFSET_D	;Address-Offset
	LAC	MSG_ID		;��Ŀ��
	CALL	READ_TELNUM	;����ǰ��Ŀ����
	CALL	STOPREADDAT
;---����TEL����
	LACL	TEL_RAM
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	CALL	TEL_SENDCOMM	;��������
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9F
	CALL	SEND_DAT
	LAC	MSG_ID
	CALL	SEND_DAT	;��ʾ����
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
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
;---Move TEL-name	
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
;---��0XFF����(Name)
	LACL	TEL_RAM+12
	SAH	ADDR_D
	LAC	FILE_LEN	;��0XFF����(Number/Name)
	SFR	8
	ANDK	0X1F
	SAH	OFFSET_D
	LACL	0XFF
	CALL	STORBYTE_DAT
;ttt:
	;bs	b1,ttt	
;---������ԭ��չ��
	LACL	TEL_RAM+2
	SAH	ADDR_S
	SAH	ADDR_D
	LACK	0
	SAH	OFFSET_S
	SAH	OFFSET_D
	LAC	FILE_LEN
	ANDK	0X7F
	SAH	COUNT
	CALL	DECONCEN_DAT
;---��0XFF����(Number)
	LACL	TEL_RAM+2
	SAH	ADDR_D
	LAC	FILE_LEN
	ANDK	0X1F
	SAH	OFFSET_D
	LACL	0XFF
	CALL	STORBYTE_DAT
;---Get first tel-num
	LACL	TEL_RAM+2
	SAH	ADDR_S		;BASE address of tel-num
	LACL	0XA0
	SAH	NEW_ID
	ANDK	0X0F
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	ANDK	0X7F
	SAH	MSG_N
MAIN_PRO10_1_X_SENDCOMM:
	LAC	NEW_ID
	CALL	SEND_DAT	;��(NEW_ID)λ
	LAC	MSG_N
	CALL	SEND_DAT	;ֵ
	LACL	0XFF
	CALL	SEND_DAT	;����
	
	RET
;---------------------------------------
MAIN_PRO10_WARN_VP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BBBEEP
	
	RET

;---------------------------------------------------------------------
LOCAL_PROBOOK1_1:			;�༭�绰��---����
;LOCAL_PROBOOK1_1_1_0:
	LAC	MSG
	XORL	CMSG_KEY5S
	BS	ACZ,LOCAL_PROBOOK1_1_1_REW	;REW
;LOCAL_PROBOOK1_1_1_3:
	LAC	MSG
	XORL	CMSG_KEY9S
	BS	ACZ,LOCAL_PROBOOK1_1_1_FFW	;FFW
;LOCAL_PROBOOK1_1_1_4:
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,LOCAL_PROBOOK1_EXIT	;EXIT(when edit TEL-data)
;LOCAL_PROBOOK1_1_1_5:
	LAC	MSG
	XORL	CMSG_KEY3S
	BS	ACZ,MAIN_PRO10_1_1_TIME	;TIME
;LOCAL_PROBOOK1_1_1_6:
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO10_1_1_MENU	;MENU
;LOCAL_PROBOOK1_1_1_7:
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,MAIN_PRO10_1_1_ERASE	;ERASE
;LOCAL_PROBOOK1_1_1_8:
	LAC	MSG
	XORL	CMSG_KEY5P
	BS	ACZ,LOCAL_PROBOOK1_1_1_PREW	;REW
;LOCAL_PROBOOK1_1_1_9:
	LAC	MSG
	XORL	CMSG_KEY9P
	BS	ACZ,LOCAL_PROBOOK1_1_1_PFFW	;FFW
	
	RET
;---------------------------------------
LOCAL_PROBOOK1_1_1_REW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
LOCAL_PROBOOK1_1_1_PREW:
	LACK	0
	SAH	SYSTMP1
	LACK	9
	SAH	SYSTMP2
	
	LAC	MSG_N
	CALL	VALUE_SUB
	SAH	MSG_N
	BS	B1,MAIN_PRO10_1_X_SENDCOMM
;---------------------------------------
LOCAL_PROBOOK1_1_1_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
LOCAL_PROBOOK1_1_1_PFFW:
	LACK	0
	SAH	SYSTMP1
	LACK	9
	SAH	SYSTMP2
	
	LAC	MSG_N
	CALL	VALUE_ADD
	SAH	MSG_N
	
	BS	B1,MAIN_PRO10_1_X_SENDCOMM
;---------------------------------------
MAIN_PRO10_1_1_ERASE:
;---It isn`t the fisrt one?
	LAC	NEW_ID
	ANDK	0X0F
	BS	ACZ,MAIN_PRO10_1_1_ERASE1_1	;�༭��1λ(���β������Ա༭��1λ,������ȴ���1,�ͼ�1)
;---�Ƿ����һλ?
	LAC	FILE_LEN
	ANDK	0X1F
	SAH	SYSTMP1		;Get length
	
	LAC	NEW_ID
	ANDK	0X0F
	ADHK	1
	SBH	SYSTMP1		;Compare length with offset(check if the last byte)
	BS	SGN,MAIN_PRO10_1_1_ERASE1_1	;�༭���м�λ(���β������Ա༭�ڵ�ǰλ,������ȴ���1,�ͼ�1)
;---���һλ�ҵ�ǰλ��Ч?	
	LAC	MSG_N
	SBHK	10
	BZ	SGN,MAIN_PRO10_1_1_ERASE1_0	;�༭���һλ�ҵ�ǰλ��Ч(���β�����༭ǰһλ,������ȴ���1,�ͼ�1)
	LAC	FILE_LEN
	ADHK	0X01
	SAH	FILE_LEN	;�ȶԺ���ĳ��ȵ�����������
	BS	B1,MAIN_PRO10_1_1_ERASE1_1	;�༭���һλ�ҵ�ǰλ��Ч(���β������Ա༭�ڵ�ǰλ,������Ȳ���)
MAIN_PRO10_1_1_ERASE1_0:
	LAC	NEW_ID
	SBHK	1
	SAH	NEW_ID
MAIN_PRO10_1_1_ERASE1_1:
;---���ȵ���(-1�򲻱�)
	LAC	FILE_LEN
	ANDK	0X1F
	SBHK	1
	BS	ACZ,MAIN_PRO10_1_1_ERASE2	;���һλ

	LAC	FILE_LEN
	SBHK	0X01
	SAH	FILE_LEN
MAIN_PRO10_1_1_ERASE2:	
;---���ƺ���
	LACL	TEL_RAM+2
	SAH	ADDR_S		;BASE address
	SAH	ADDR_D

	LAC	NEW_ID
	ANDK	0XF
	SAH	OFFSET_D	;��ǰλΪĿ����ʼoffset
	ADHK	1
	SAH	OFFSET_S	;��ǰλ����һλΪԴ��ʼoffset
	LACK	16
	SBH	OFFSET_S
	SAH	COUNT		;�ƶ��ĳ���
	CALL	MOVE_HTOL
	LACL	0XFF		;��0XFF��β
	CALL	STORBYTE_DAT

;---ĩλ��0X0F
	LAC	FILE_LEN		
	ANDK	0X1F
	SAH	OFFSET_D	;����Ŀ��ĩƫ�ƴ�
	LACK	0X0F		;ֵ
	CALL	STORBYTE_DAT
;---ȡ��һλ
	LAC	NEW_ID		;ȡ��һλ
	ANDK	0X0F
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	ANDK	0X7F
	SAH	MSG_N
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;---����mcuɾ����ǰλ
	LAC	NEW_ID
	CALL	SEND_DAT	;��(NEW_ID)λ
	LACL	0X80
	CALL	SEND_DAT	;ֵ

	LACL	0XFF
	CALL	SEND_DAT

	LAC	NEW_ID
	CALL	SEND_DAT	;��(NEW_ID)λ
	LAC	MSG_N
	CALL	SEND_DAT	;ֵ
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
MAIN_PRO10_1_1_ERASEEND:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
		
	RET
;---------------------------------------
MAIN_PRO10_1_1_TIME:		;NEXT TEL_NUM
	LAC	MSG_N
	BS	SGN,MAIN_PRO10_1_1_TIME_END
	SBHK	10
	BZ	SGN,MAIN_PRO10_1_1_TIME_END	;����Ч�ַ�(ֻ�����һλ������Ч�ַ�)��?
;---Valid TEL-number	
	LAC	NEW_ID
	XORL	0XAF
	BS	ACZ,MAIN_PRO10_1_1_MENU		;���һλ
;---Save the current value(make sure it isn`t the fifteenth --- from 0)
	LACL	TEL_RAM+2	;��ַ
	SAH	ADDR_D
	LAC	NEW_ID		;ƫ��
	ANDK	0X0F
	SAH	OFFSET_D
	LAC	MSG_N		;ֵ
	CALL	STORBYTE_DAT
;---Get next one
	LACL	0XA0
	SAH	SYSTMP1
	LACL	0XAF
	SAH	SYSTMP2

	LAC	NEW_ID
	CALL	VALUE_ADD
	SAH	NEW_ID
;---�ж��Ƿ������ӵ�
	LAC	FILE_LEN
	ANDK	0X1F
	SBHK	1
	ORL	0XA0
	SBH	NEW_ID
	BZ	SGN,MAIN_PRO10_1_1_TIME_1
;---�����ӵ�	
	LACK	0X0A
	SAH	MSG_N
	
	LAC	FILE_LEN
	ADHK	1
	SAH	FILE_LEN
	BS	B1,MAIN_PRO10_1_1_TIME_END
;---Get the next one	
MAIN_PRO10_1_1_TIME_1:
		
	LACL	TEL_RAM+2		;��ַ
	SAH	ADDR_S		;BASE address
	LAC	NEW_ID		;offset
	ANDK	0X0F
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	ANDK	0X7F
	SAH	MSG_N
MAIN_PRO10_1_1_TIME_END:
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
	
	BS	B1,MAIN_PRO10_1_X_SENDCOMM
;---------------------------------------	
MAIN_PRO10_1_1_MENU:
;---���浱ǰֵ
	LACL	TEL_RAM+2	;BASE address
	SAH	ADDR_D
	LAC	NEW_ID		;ƫ��
	ANDK	0X0F
	SAH	OFFSET_D
	LAC	MSG_N		;ֵ
	CALL	STORBYTE_DAT

	LAC	FILE_LEN
	ANDK	0X01F
	SBHK	1
	SAH	OFFSET_S
	CALL	GETBYTE_DAT	;������һλֵ����Ч����(����10 or С��0)�򳤶ȼ�1
	BS	SGN,MAIN_PRO10_2_0_0_MENU_0
	SBHK	10
	BZ	SGN,MAIN_PRO10_2_0_0_MENU_0
	BS	B1,MAIN_PRO10_2_0_0_MENU_0_1	;��Ч�ַ�
MAIN_PRO10_2_0_0_MENU_0:
	LAC	FILE_LEN
	SBHK	1
	SAH	FILE_LEN
	ANDK	0X1F
	BS	ACZ,MAIN_PRO10_1_1_MENU_END	;���볤��Ϊ0,���ܽ��������༭
MAIN_PRO10_2_0_0_MENU_0_1:
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;---ĩλ��0X0F
	LAC	FILE_LEN		
	ANDK	0X1F
	SAH	OFFSET_D	;����Ŀ��ĩƫ�ƴ�
	LACK	0X0F		;ֵ
	CALL	STORBYTE_DAT
;---��ѹ������
	LACL	TEL_RAM+2
	SAH	ADDR_S
	SAH	ADDR_D
	LACK	0
	SAH	OFFSET_S
	SAH	OFFSET_D
	LAC	FILE_LEN
	ANDK	0X1F
	SAH	COUNT
	CALL	CONCEN_DAT
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

;---��ʼ�Ƚ�Tel-num
	LACL	TEL_RAM
	SAH	ADDR_S
	SAH	ADDR_D

	CALL	COMP_ALLTELNUM
	BS	ACZ,MAIN_PRO10_1_1_MENU_1
	SAH	MSG_ID
	BS	B1,LOCAL_PROBOOK1_NAMEEDIT	;�ҵ�����ͬ�������Ŀ
MAIN_PRO10_1_1_MENU_1:
;---
	LACL	TEL_RAM+12
	SAH	ADDR_S		;BASE address
	LACL	0XB0
	SAH	NEW_ID		;offset
	ANDK	0X0F
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	ANDK	0X7F
	SAH	MSG_N

	LACK	0X02
	SAH	PRO_VAR		;��ʼ�༭����
MAIN_PRO10_1_1_MENU_END:	
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP

	BS	B1,MAIN_PRO10_1_X_SENDCOMM
;---------------------------------------
LOCAL_PROBOOK1_NAMEEDIT:	;�������Ŀʱ�ҵ�������ͬ����Ŀ,��༭֮��������һ��Ŀ�ĺ�����ͬ
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
;---����TEL����
	LACL	TEL_RAM
	SAH	ADDR_D		;Address-Base
	LACK	0
	SAH	OFFSET_D	;Address-Offset
	LAC	MSG_ID		;��Ŀ��
	CALL	READ_TELNUM	;����ǰ��Ŀ����
	CALL	STOPREADDAT
;---����TEL����
	LACL	TEL_RAM
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	CALL	TEL_SENDCOMM	;��������
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9F
	CALL	SEND_DAT
	LAC	MSG_ID
	CALL	SEND_DAT	;��ʾ����
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
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
;---Move TEL-name data
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
;---��0XFF����(Name)
	LACL	TEL_RAM+12
	SAH	ADDR_D
	LAC	FILE_LEN	;��0XFF����(Number/Name)
	SFR	8
	ANDK	0X1F
	SAH	OFFSET_D
	LACL	0XFF
	CALL	STORBYTE_DAT
;---
	LACL	TEL_RAM+12
	SAH	ADDR_S		;BASE address
	LACL	0XB0
	SAH	NEW_ID		;offset
	ANDK	0X0F
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	ANDK	0X7F
	SAH	MSG_N

	LACK	0X02
	SAH	PRO_VAR		;��ʼ�༭����	

	BS	B1,MAIN_PRO10_1_X_SENDCOMM
;-------------------------------------------------------------------------------
LOCAL_PROBOOK1_2:		;�༭�绰��---����
;MAIN_PRO10_1_2_0:
	LAC	MSG
	XORL	CMSG_KEY5S
	BS	ACZ,MAIN_PRO10_1_2_REW	;REW
;MAIN_PRO10_1_2_3:
	LAC	MSG
	XORL	CMSG_KEY9S
	BS	ACZ,MAIN_PRO10_1_2_FFW	;FFW
;MAIN_PRO10_1_2_4:
	LAC	MSG
	XORL	CMSG_KEY7S
	BS	ACZ,LOCAL_PROBOOK1_EXIT	;EXIT(when edit TEL-data)
;MAIN_PRO10_1_2_5:
	LAC	MSG
	XORL	CMSG_KEY3S
	BS	ACZ,MAIN_PRO10_1_2_TIME	;TIME
;MAIN_PRO10_1_2_6:
	LAC	MSG
	XORL	CMSG_KEYCS
	BS	ACZ,MAIN_PRO10_1_2_MENU	;MENU
;MAIN_PRO10_1_2_7:
	LAC	MSG
	XORL	CMSG_KEY8S
	BS	ACZ,MAIN_PRO10_1_2_ERASE	;ERASE	
;MAIN_PRO10_1_2_8:
	LAC	MSG
	XORL	CMSG_KEY5P
	BS	ACZ,MAIN_PRO10_1_2_PREW	;REW
;MAIN_PRO10_1_2_9:
	LAC	MSG
	XORL	CMSG_KEY9P
	BS	ACZ,MAIN_PRO10_1_2_PFFW	;FFW
		
	RET
;---------------------------------------
MAIN_PRO10_1_2_REW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
MAIN_PRO10_1_2_PREW:	
	LACK	0
	SAH	SYSTMP1
	LACK	0X24
	SAH	SYSTMP2
	
	LAC	MSG_N
	CALL	VALUE_SUB
	SAH	MSG_N
	
	BS	B1,MAIN_PRO10_1_X_SENDCOMM
;---------------------------------------
MAIN_PRO10_1_2_FFW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
MAIN_PRO10_1_2_PFFW:	
	LACK	0
	SAH	SYSTMP1
	LACK	0X24
	SAH	SYSTMP2
	
	LAC	MSG_N
	CALL	VALUE_ADD
	SAH	MSG_N
	
	BS	B1,MAIN_PRO10_1_X_SENDCOMM
;---------------------------------------
MAIN_PRO10_1_2_TIME:
	LAC	MSG_N
	BS	SGN,MAIN_PRO10_1_2_TIMEEND
	SBHK	0X25
	BZ	SGN,MAIN_PRO10_1_2_TIMEEND	;����Ч�ַ�(ֻ�����һλ������Ч�ַ�)��?
	
	LAC	NEW_ID
	XORL	0XB0
	BZ	ACZ,MAIN_PRO10_1_2_TIME_1
	
	LAC	MSG_N
	XORL	0X24
	BS	ACZ,MAIN_PRO10_1_2_TIMEEND	;��һ���ո񲻽���
MAIN_PRO10_1_2_TIME_1:
	LAC	NEW_ID
	XORL	0XBF
	BZ	ACZ,MAIN_PRO10_1_2_TIME_1_1
	
	LAC	MSG_N
	XORL	0X24
	BS	ACZ,MAIN_PRO10_1_2_TIMEEND	;���һ���ո񲻽���
MAIN_PRO10_1_2_TIME_1_1:
;---���浱ǰֵ		
	LACL	TEL_RAM+12	;��ַ
	SAH	ADDR_D
	LAC	NEW_ID		;ƫ��
	ANDK	0X0F
	SAH	OFFSET_D
	LAC	MSG_N		;ֵ
	CALL	STORBYTE_DAT
;---ȡ��һ���ַ�
	LACL	0XB0
	SAH	SYSTMP1
	LACL	0XBF
	SAH	SYSTMP2

	LAC	NEW_ID
	CALL	VALUE_ADD
	SAH	NEW_ID		;ȡ��һ�ַ�
;---�ж��Ƿ������ӵ�
	LAC	FILE_LEN
	SFR	8
	ANDK	0X1F
	SBHK	1
	ORL	0XB0
	SBH	NEW_ID
	BZ	SGN,MAIN_PRO10_1_2_TIME_2
;---�����ӵ�
	LACK	0X7F
	SAH	MSG_N
	
	LAC	FILE_LEN
	ADHL	0X0100
	SAH	FILE_LEN
	BS	B1,MAIN_PRO10_1_2_TIMEEND
;---ȡ��һ��	
MAIN_PRO10_1_2_TIME_2:
	LACL	TEL_RAM+12		;��ַ
	SAH	ADDR_S		;BASE address
	LAC	NEW_ID		;offset
	ANDK	0X0F
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	ANDK	0X7F
	SAH	MSG_N
MAIN_PRO10_1_2_TIMEEND:
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
	
	BS	B1,MAIN_PRO10_1_X_SENDCOMM
;---------------------------------------
MAIN_PRO10_1_2_MENU:
;;---���浱ǰֵ
;	LACL	TEL_RAM+12	;��ַ
;	SAH	ADDR_S
;	SAH	ADDR_D
;	LAC	NEW_ID		;ƫ��
;	ANDK	0X0F
;	SAH	OFFSET_D
;	LAC	MSG_N		;ֵ
;	CALL	STORBYTE_DAT
;;---
;	LAC	FILE_LEN
;	SFR	8
;	SBHK	1
;	ANDK	0XF
;	SAH	OFFSET_S	;offset
;	CALL	GETBYTE_DAT		;������ֵ����Ч�ַ�(����0x24 or С��0)���ܱ����˳�
;	BS	SGN,MAIN_PRO10_1_2_MENU_END
;	SBHK	0X24
;	BZ	SGN,MAIN_PRO10_1_2_MENU_END
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;---���浱ǰֵ
	LACL	TEL_RAM+12	;BASE address
	SAH	ADDR_S
	SAH	ADDR_D
	LAC	NEW_ID		;Offset
	ANDK	0X0F
	SAH	OFFSET_D
	LAC	MSG_N		;Value
	CALL	STORBYTE_DAT

	LAC	FILE_LEN
	SFR	8
	SBHK	1
	ANDK	0XF
	SAH	OFFSET_S	;offset
	CALL	GETBYTE_DAT	;������ֵ����Ч�ַ�(����0x24 or С��0)�򳤶ȼ�1
	BS	SGN,MAIN_PRO10_2_1_MENU_0
	SBHK	0X24
	BZ	SGN,MAIN_PRO10_2_1_MENU_0
	BS	B1,MAIN_PRO10_2_1_MENU_0_1
MAIN_PRO10_2_1_MENU_0:	
	LAC	FILE_LEN
	SBHL	0X0100
	SAH	FILE_LEN
	ANDL	0X1F00
	BS	ACZ,MAIN_PRO10_1_2_MENU_END	;��Ч�ַ�����Ϊ0
MAIN_PRO10_2_1_MENU_0_1:
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	0
	SAH	OFFSET_S		;offset
	CALL	GETBYTE_DAT		;�����һ��ֵ����Ч�ַ�(����0x24 or С��0)���ܱ����˳�

	BS	SGN,MAIN_PRO10_1_2_MENU_END
	SBHK	0X24
	BZ	SGN,MAIN_PRO10_1_2_MENU_END
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	CALL	BEEP
;---��0XFF����	
	LAC	FILE_LEN
	SFR	8
	ANDK	0X1F
	SAH	OFFSET_D
	LACL	0XFF		;��0XFF����
	CALL	STORBYTE_DAT
;---ɾ����ǰ��
	LAC	MSG_ID
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK
;---д������---(TEL flag)
	LAC	FILE_LEN
	ANDK	0X7F
	ORL	0X80
	CALL	DAT_WRITE
	LAC	FILE_LEN
	SFR	8
	ORL	0X80
	CALL	DAT_WRITE
	LACK	0
	CALL	DAT_WRITE
	LACK	0
	CALL	DAT_WRITE
;---д������---(TEL NUM)	
	LACL	TEL_RAM+2
	SAH	ADDR_S		;Base address
	LACK	0
	SAH	OFFSET_S	;First offset address
	LAC	FILE_LEN
	ANDK	0X7F
	SAH	COUNT
	CALL	TELNUM_WRITE
;---д������---(TEL NAME)		
	LACL	TEL_RAM+12
	SAH	ADDR_S		;Base address
	LACK	0
	SAH	OFFSET_S	;First offset address
	LAC	FILE_LEN
	SFR	8
	ANDK	0X7F
	SAH	COUNT
	CALL	TELNUM_WRITE
	
	;CALL	TELTIME_WRITE	;д������(TEL TIME)	;????????????
	CALL	DAT_WRITE_STOP
	
	CALL	GET_TELT	;ȡTEL_ID
	SAH	MSG_T
	;CALL	SET_TELUSRDAT	;��usr-dat

	LAC	MSG_T
	SAH	MSG_ID
;-------------------
	CALL	CLR_FUNC	;�ȿ�
     	LACK	0
     	SAH	PRO_VAR
     	
     	LACL	CBOOK_SLET
     	CALL	STOR_MSG

	RET
	
MAIN_PRO10_1_2_MENU_END:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK	
	CALL	BBBEEP
	
	RET
;---------------------------------------
MAIN_PRO10_1_2_ERASE:
;---It isn`t the fisrt one?	
	LAC	NEW_ID
	ANDK	0X0F
	BS	ACZ,MAIN_PRO10_1_2_ERASE1_1	;�༭��1λ(���β������Ա༭��1λ,������ȴ���1,�ͼ�1)
;---�Ƿ����һλ?
	LAC	FILE_LEN
	SFR	8
	ANDK	0X1F
	SAH	SYSTMP1		;Get length
	
	LAC	NEW_ID
	ANDK	0X0F
	ADHK	1
	SBH	SYSTMP1		;Compare length with offset(check if the last byte)
	BS	SGN,MAIN_PRO10_1_2_ERASE1_1	;�༭���м�λ(���β������Ա༭�ڵ�ǰλ,������ȴ���1,�ͼ�1)
;---���һλ�ҵ�ǰλ��Ч?
	LAC	MSG_N
	SBHK	0X25
	BZ	SGN,MAIN_PRO10_1_2_ERASE1_0	;�༭���һλ�ҵ�ǰλ��Ч(���β�����༭ǰһλ,������ȴ���1,�ͼ�1)
	LAC	FILE_LEN
	ADHL	0X0100
	SAH	FILE_LEN	;�ȶԺ���ĳ��ȵ�����������
	BS	B1,MAIN_PRO10_1_2_ERASE1_1	;�༭���һλ�ҵ�ǰλ��Ч(���β������Ա༭�ڵ�ǰλ,������Ȳ���)
MAIN_PRO10_1_2_ERASE1_0:
	LAC	NEW_ID
	SBHK	1
	SAH	NEW_ID
MAIN_PRO10_1_2_ERASE1_1:
;---���ȵ���(-1�򲻱�)
	LAC	FILE_LEN
	SFR	8
	ANDK	0X1F
	SBHK	1
	BS	ACZ,MAIN_PRO10_1_2_ERASE2

	LAC	FILE_LEN
	SBHL	0X0100
	SAH	FILE_LEN
MAIN_PRO10_1_2_ERASE2:	
;---��������
	LACL	TEL_RAM+12
	SAH	ADDR_S		;BASE address
	SAH	ADDR_D

	LAC	NEW_ID
	ANDK	0XF
	SAH	OFFSET_D	;��ǰλΪĿ����ʼoffset
	ADHK	1
	SAH	OFFSET_S	;��ǰλ����һλΪԴ��ʼoffset
	LACK	16
	SBH	OFFSET_S
	SAH	COUNT		;�ƶ��ĳ���
	CALL	MOVE_HTOL
	LACL	0XFF		;��0XFF��β
	CALL	STORBYTE_DAT
;---ĩλ��0X7F
	LAC	FILE_LEN
	SFR	8	
	ANDK	0X1F
	SAH	OFFSET_D		;����Ŀ��ĩƫ�ƴ�
	LACK	0X7F		;ֵ
	CALL	STORBYTE_DAT
;---ȡ��һλ
	LAC	NEW_ID		;ȡ��һλ
	ANDK	0X0F
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	ANDK	0X7F
	SAH	MSG_N

	LAC	NEW_ID
	CALL	SEND_DAT	;��(NEW_ID)λ
	LACL	0X80
	CALL	SEND_DAT	;ֵ
	
	LACL	0XFF
	CALL	SEND_DAT

	LAC	NEW_ID
	CALL	SEND_DAT	;��(NEW_ID)λ
	LAC	MSG_N
	CALL	SEND_DAT	;ֵ
MAIN_PRO10_1_2_ERASEEND:
	CALL	INIT_DAM_FUNC
	CALL	DAA_BSPK	
	CALL	BEEP
		
	RET
;-------------------------------------------------------------------------------
LOCAL_PROBOOK1_3:	;Save it as Nomal/VIP/Filter
	
	RET

;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------	
.END

