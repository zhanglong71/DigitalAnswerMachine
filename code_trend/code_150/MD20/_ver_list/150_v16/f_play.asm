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
.global	LOCAL_PROPLY
;-------------------------------------------------------------------------------
.LIST
.ORG    ADDR_SECOND
;===================================================================
LOCAL_PROPLY:	;����(MSG)״̬Ҫ���ǵ���Ϣ
	LAC	PRO_VAR
	ANDK	0X0F
	BS	ACZ,LOCAL_PROPLY_0	;normal
	SBHK	1
	BS	ACZ,LOCAL_PROPLY_1	;pause
	
	RET
;-------------------------------------------------------------------------------	
LOCAL_PROPLY_0:
	LAC	MSG
	XORL	CMSG_KEYBP		;VOL+
	BS	ACZ,LOCAL_PROPLY_X_VOLA
;LOCAL_PROPLY_0_2_4:
	LAC	MSG
	XORL	CMSG_KEYBS		;VOL+
	BS	ACZ,LOCAL_PROPLY_X_VOLA
;LOCAL_PROPLY_0_2_5:
	LAC	MSG
	XORL	CMSG_KEYAP		;VOL-
	BS	ACZ,LOCAL_PROPLY_X_VOLS
;LOCAL_PROPLY_0_2_6:
	LAC	MSG
	XORL	CMSG_KEYAS		;VOL-
	BS	ACZ,LOCAL_PROPLY_X_VOLS
;LOCAL_PROPLY_0_2_7:
	
	LAC	PRO_VAR
	SFR	4
	ANDK	0X0F
	BS	ACZ,LOCAL_PROPLY_0_0	;local-idle to play
	SBHK	1
	BS	ACZ,LOCAL_PROPLY_0_1	;VOP before play(x messages)
	SBHK	1
	BS	ACZ,LOCAL_PROPLY_0_2	;message playing
	SBHK	1
	BS	ACZ,LOCAL_PROPLY_0_3	;end of message/no message
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROPLY_0_0:
	LAC	MSG
	XORL	CMSG_KEY4S		;pause
	BS	ACZ,LOCAL_PROPLY_0_0_PLAY

	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,LOCAL_PROPLY_0_0_RINGIN
	LAC	MSG
	XORL	CMSG_KEY7S		;ON/OFF(stop)
	BS	ACZ,LOCAL_PROPLY_0_0_STOP

	RET
;---------------------------------------
LOCAL_PROPLY_0_0_RINGIN:
LOCAL_PROPLY_0_0_STOP:
	CALL	INIT_DAM_FUNC
	CALL	REAL_DEL	;0x6100
	CALL	TEL_GC_CHK
	CALL	GC_CHK
	
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
	LAC	MSG
	CALL	STOR_MSG

	RET
;---------------------------------------	
LOCAL_PROPLY_0_0_PLAY:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK

	CALL	BLED_ON
	LACK	0X010
	SAH	PRO_VAR			;���벥���ӹ���

	CALL	VPMSG_CHK
	LAC	MBOX_ID
	CALL	SET_TELGROUP		;set tel group
	
	LACK	0
	SAH	MSG_ID
;???????????????????????????????????????	

	BIT	ANN_FG,12
	BS	TB,LOCAL_PROPLY_0_PLAY_NEW
	BIT	ANN_FG,14
	BS	TB,MAIN_PRO0_PLAY_OLD

	CALL	VP_NO
	CALL	VP_MESSAGES
	CALL	BB_VOP
	
	LACK	0X030
	SAH	PRO_VAR
	
	BS	B1,MAIN_PRO0_PLAY_END
;-------play new messages

LOCAL_PROPLY_0_PLAY_NEW:
	LAC	MSG_N
	SBHK	1
	BS	ACZ,MAIN_PRO0_PLAY_ONENEWMESSAGE

	LAC	MSG_N
	CALL	ANNOUNCE_NUM
	CALL	VP_NEW
	
	CALL	VP_MESSAGES
	
	BS	B1,MAIN_PRO0_PLAY_END
MAIN_PRO0_PLAY_ONENEWMESSAGE:
	CALL	VP_ONE
	CALL	VP_NEW
	BS	B1,MAIN_PRO0_PLAY_VPMESSAGE
;-------play old messages
MAIN_PRO0_PLAY_OLD:
LOCAL_PROPLY_0_PLAY_OLD:
	LAC	MSG_T
	SBHK	1
	BS	ACZ,MAIN_PRO0_PLAY_ONEMESSAGE
	
	LAC	MSG_T
	CALL	ANNOUNCE_NUM
	CALL	VP_MESSAGES
		
	BS	B1,MAIN_PRO0_PLAY_END
MAIN_PRO0_PLAY_ONEMESSAGE:
	CALL	VP_ONE
	;BS	B1,MAIN_PRO0_PLAY_VPMESSAGE
MAIN_PRO0_PLAY_VPMESSAGE:	
	CALL	VP_MESSAGE
MAIN_PRO0_PLAY_END:
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XC7
	CALL	SEND_DAT
	LACK	0X0
	CALL	SEND_DAT	;��ʾ/׼������¼��
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	RET

;-------------------------------------------------------------------------------
LOCAL_PROPLY_0_1:		;play VOP
	LAC	MSG
	XORL	CVP_STOP		;VOP play end
	BS	ACZ,LOCAL_PROPLY_0_1_OVER

	LAC	MSG
	XORL	CMSG_KEY4S		;pause
	BS	ACZ,LOCAL_PROPLY_0_1_PLAY
	
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,LOCAL_PROPLY_0_1_RINGIN
	LAC	MSG
	XORL	CMSG_KEY7S		;ON/OFF(stop)
	BS	ACZ,LOCAL_PROPLY_0_1_STOP

	RET
;---------------------------------------
LOCAL_PROPLY_0_1_RINGIN:
LOCAL_PROPLY_0_1_STOP:
	BS	B1,LOCAL_PROPLY_0_0_RINGIN
LOCAL_PROPLY_0_1_PLAY:		;Pause
	BS	B1,LOCAL_PROPLY_0_2_PAUSE
LOCAL_PROPLY_0_1_OVER:
	LACK	0X020
	SAH	PRO_VAR
	
	LACK	0
	SAH	MSG_ID
	
	LAC	MSG
	CALL	STOR_MSG
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROPLY_0_2:
	LAC	MSG
	XORL	CMSG_KEY4S		;pause
	BS	ACZ,LOCAL_PROPLY_0_2_PAUSE
;LOCAL_PROPLY_0_2_1:
	LAC	MSG
	XORL	CMSG_KEY8S		;erase
	BS	ACZ,LOCAL_PROPLY_0_2_ERASE
;LOCAL_PROPLY_0_2_2:
	LAC	MSG
	XORL	CMSG_KEY7S		;ON/OFF(stop)
	BS	ACZ,LOCAL_PROPLY_X_STOP
;LOCAL_PROPLY_0_2_3:
	LAC	MSG
	XORL	CMSG_KEY9S		;FFW
	BS	ACZ,LOCAL_PROPLY_0_2_FFW
;LOCAL_PROPLY_0_2_8:
	LAC	MSG
	XORL	CMSG_KEY5S		;REW
	BS	ACZ,LOCAL_PROPLY_0_2_REW
;LOCAL_PROPLY_0_2_9:
	LAC	MSG
	XORL	CVP_STOP		;PLAY END
	BS	ACZ,LOCAL_PROPLY_0_2_OVER
	
	
	RET

;-------��Ϣ����
LOCAL_PROPLY_0_2_PAUSE:
	LAC	CONF
	SFR	12
	SBHK	2
	BS	ACZ,LOCAL_PROPLY_0_2_PAUSE_DONEPAUSE	;0X2000
	SBHK	9
	BS	ACZ,LOCAL_PROPLY_0_2_PAUSE_DONEPAUSE	;0XB000
	
	RET

LOCAL_PROPLY_0_2_PAUSE_DONEPAUSE:
	LAC	PRO_VAR
	ANDL	0XFFF0
	ORK	0X0001
	SAH	PRO_VAR
	
	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER

	LAC	CONF
	ORL	1<<8
	CALL	DAM_BIOSFUNC
;???????????????????????????
	LACL	0XC8
	CALL	SEND_DAT
	LAC	MSG_ID
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;???????????????????????????

	RET
;---------------------------------------
LOCAL_PROPLY_0_2_ERASE:
	BIT	ANN_FG,12
	BS	TB,LOCAL_PROPLY_0_2_ERASENEW
;???????????????????????????
	;LACL	0X83
	;CALL	SEND_DAT
	;LAC	MSG_ID
	;CALL	SEND_DAT
	;LACL	0XF3
	;CALL	SEND_DAT
;???????????????????????????
	CALL	INIT_DAM_FUNC
	LAC	MSG_ID
	ORL	0x2080
	CALL	DAM_BIOSFUNC

	LAC	MSG_ID
	CALL	GET_ONLYID
	CALL	GET_TELID
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK

	CALL	B_VOP

	RET
LOCAL_PROPLY_0_2_ERASENEW:
	CALL	INIT_DAM_FUNC
	LAC	MSG_ID
	ORL	0x2480
	CALL	DAM_BIOSFUNC

	LAC	MSG_ID
	CALL	GET_ONLYIDNEW
	CALL	GET_TELID
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK

	CALL	B_VOP
	
	RET
;---------------------------------------
LOCAL_PROPLY_X_VOLA:
	LACL	CMSG_VOLA
	CALL	STOR_MSG

	RET
;---------------------------------------
LOCAL_PROPLY_X_VOLS:	
	LACL	CMSG_VOLS
	CALL	STOR_MSG

	RET
;---------------------------------------
LOCAL_PROPLY_0_2_FFW:
	CALL	INIT_DAM_FUNC

	LACL	CVP_STOP
	CALL	STOR_MSG
MAIN_PRO1_PLAY_DONE:
	RET
;---------------------------------------
LOCAL_PROPLY_0_2_REW:
	CALL	INIT_DAM_FUNC

	LAC	MSG_ID
	SBHK	1
	BS	ACZ,MAIN_PRO1_PLAY_REW_1 	;��һ����?

	LAC	MSG_ID
	SBHK	1
	SAH	MSG_ID
MAIN_PRO1_PLAY_REW_1:	
	BS	B1,LOCAL_PROPLY_0_2_GETCID
;-------------------------------------------------------------------------------
LOCAL_PROPLY_0_2_OVER:
	BIT	ANN_FG,12
	BS	TB,LOCAL_PROPLY_0_2_OVER_NEW
	LAC	MSG_ID
	SBH	MSG_T
	BZ	SGN,LOCAL_PROPLY_X_VPEND
	BS	B1,LOCAL_PROPLY_0_2_OVER_1
LOCAL_PROPLY_0_2_OVER_NEW:
	LAC	MSG_ID
	SBH	MSG_N
	BZ	SGN,LOCAL_PROPLY_X_VPEND
	;BS	B1,LOCAL_PROPLY_0_2_OVER_1
LOCAL_PROPLY_0_2_OVER_1:
	LAC	MSG_ID			;next message
	ADHK	1
	SAH	MSG_ID	
;-------------------------------------------------------------------------------
LOCAL_PROPLY_0_2_GETCID:			;Get the msg_id you will play
	;CALL	DAA_SPK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!	SEND_TELNUM
	BIT	ANN_FG,12
	BS	TB,LOCAL_PROPLY_0_2_GETCID_NEW

	LAC	MSG_ID
	CALL	GET_ONLYID
	SAH	SYSTMP0
	BS	B1,LOCAL_PROPLY_0_2_GETCID_DONE
LOCAL_PROPLY_0_2_GETCID_NEW:
	LAC	MSG_ID
	CALL	GET_ONLYIDNEW
	SAH	SYSTMP0
	;BS	B1,LOCAL_PROPLY_0_2_GETCID_DONE
LOCAL_PROPLY_0_2_GETCID_DONE:

	LAC	SYSTMP0
	CALL	GET_TELID
	BS	ACZ,MAIN_PRO1_PLAY_OVER2_1	;No CID
	SAH	NEW_ID

	LACL	TEL_RAM
	SAH	ADDR_D
	LACK	0
	SAH	OFFSET_D	;�����ַ

	LAC	NEW_ID		;��Ŀ��
	CALL	READ_TELNUM	;����ǰ��Ŀ����
	CALL	STOPREADDAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!Ҫ����³�VP��ʱ��,����VP��LCD��һ��
	BS	B1,MAIN_PRO1_PLAY_OVER2_1_TIME
;---------------------------------------
MAIN_PRO1_PLAY_OVER2_1:
	LACL	TEL_RAM
	SAH	ADDR_D
	LACK	0
	SAH	OFFSET_D
;---	
	LACK	0
	CALL	STORBYTE_DAT	;Byte1
	LACK	0
	CALL	STORBYTE_DAT	;Byte2
	LACL	0X84
	CALL	STORBYTE_DAT	;Byte3
	LACK	0
	CALL	STORBYTE_DAT	;Byte4

MAIN_PRO1_PLAY_OVER2_1_TIME:
;---make sure the VOP-time is same as LCD-time
	LACL	TEL_RAM
	SAH	ADDR_D
	SAH	ADDR_S
	
	CALL	GET_TIMEOFFSET	;
	SAH	OFFSET_D
;---New/Old Check
	BIT	ANN_FG,12
	BS	TB,MAIN_PRO1_PLAY_OVER2_1_TIME_NEW
;MAIN_PRO1_PLAY_OVER2_1_TIME_OLD:
	LAC	MSG_ID
	CALL	GET_MSGMONTH	;Byte5-month
	CALL	STORBYTE_DAT
	LAC	MSG_ID
	CALL	GET_MSGDAY	;Byte6-day
	CALL	STORBYTE_DAT
	LAC	MSG_ID
	CALL	GET_MSGHOUR	;Byte7-hour
	CALL	STORBYTE_DAT
	LAC	MSG_ID
	CALL	GET_MSGMINUTE	;Byte8-minute
	CALL	STORBYTE_DAT
	BS	B1,MAIN_PRO1_PLAY_OVER3_SENDTEL
MAIN_PRO1_PLAY_OVER2_1_TIME_NEW:
	LAC	MSG_ID
	CALL	GET_MSGMONTHNEW		;Byte5-month
	CALL	STORBYTE_DAT
	LAC	MSG_ID
	CALL	GET_MSGDAYNEW		;Byte6-day
	CALL	STORBYTE_DAT
	LAC	MSG_ID
	CALL	GET_MSGHOURNEW		;Byte7-hour
	CALL	STORBYTE_DAT
	LAC	MSG_ID
	CALL	GET_MSGMINUTENEW	;Byte8-minute
	CALL	STORBYTE_DAT
;-------------------------------------------------------------------------------
MAIN_PRO1_PLAY_OVER3_SENDTEL:	
;---����׼�����,��ʼ����---������/����/ʱ��(�����)----------------------------
	LACL	TEL_RAM		;(TEL_RAM..)
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	CALL	TEL_SENDCOMM
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;---��ʾ��ӦCID����
	LACL	0XCA
	CALL	SEND_DAT
	LAC	MSG_ID		;message_ID	;��ʾ��(Ҫ�뱨��VPһ��)
	CALL	SEND_DAT	;��ʾ����
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
;---��ʾPlaying-MSG_ID
	LACL	0XC7
	CALL	SEND_DAT
	LAC	MSG_ID
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
MAIN_PRO1_PLAY_LOADVP:
	BIT	ANN_FG,12
	BS	TB,MAIN_PRO1_PLAY_LOADVPNEW

	CALL	INIT_DAM_FUNC

	CALL	VP_MESSAGE		;VP"message"
	LAC	MSG_ID			;message_ID	;������
	CALL	ANNOUNCE_NUM	
	
	CALL	MSG_WEEK
	CALL	MSG_HOUR
	CALL	MSG_MIN

	LAC	MSG_ID
	ORL	0XFE00
	CALL	STOR_VP

	RET	
MAIN_PRO1_PLAY_LOADVPNEW:
	CALL	INIT_DAM_FUNC

	CALL	VP_MESSAGE		;VP"message"
	LAC	MSG_ID			;message_ID	;������
	CALL	ANNOUNCE_NUM	
	
	CALL	MSG_WEEKNEW
	CALL	MSG_HOURNEW
	CALL	MSG_MINNEW

	LAC	MSG_ID
	ORL	0XFD00
	CALL	STOR_VP

	RET
;---------------------------------------
LOCAL_PROPLY_X_VPEND:		;�������
	CALL	INIT_DAM_FUNC
	;CALL	DAA_SPK
	CALL	VP_ENDOF
	CALL	VP_MESSAGES
	CALL	BB_VOP

	CALL	REAL_DEL	;0x6100
	CALL	TEL_GC_CHK
	CALL	GC_CHK
	CALL	VPMSG_CHK
	CALL	NEWICM_CHK	;
;!!!!!!!!!!!!!!!!!!!!!!!!
;	LACL	0XC9
;	CALL	SEND_DAT
;	LAC	FILE_ID
;	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	0X030
	SAH	PRO_VAR

	RET
;---------------------------------------
LOCAL_PROPLY_X_STOP:		;��ON/OFFǿ���˳�;PauseTimeOut�˳�
	CALL	INIT_DAM_FUNC
	;CALL	DAA_SPK
	;CALL	VP_ENDOF
	;CALL	VP_MESSAGES
	CALL	BB_VOP

	CALL	REAL_DEL	;0x6100
	CALL	TEL_GC_CHK
	CALL	GC_CHK
	CALL	VPMSG_CHK
	CALL	NEWICM_CHK	;
;!!!!!!!!!!!!!!!!!!!!!!!!
;	LACL	0XC9
;	CALL	SEND_DAT
;	LAC	FILE_ID
;	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	0X030
	SAH	PRO_VAR

	RET
;-------------------------------------------------------------------------------
LOCAL_PROPLY_0_3:
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,LOCAL_PROPLY_0_3_RINGIN
	LAC	MSG
	XORL	CMSG_KEY7S		;stop
	BS	ACZ,LOCAL_PROPLY_0_3_STOP
	LAC	MSG
	XORL	CVP_STOP		;VP end
	BS	ACZ,LOCAL_PROPLY_0_3_STOP
	
	RET
;---------------------------------------
LOCAL_PROPLY_0_3_RINGIN:
LOCAL_PROPLY_0_3_STOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	CALL	CLR_FUNC
	LACK	0
	SAH	PRO_VAR
	
	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER	;���������ʱ

	CALL	VPMSG_CHK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X83		;¼������ͬ��(3bytes)
	CALL	SEND_DAT
	LAC	MSG_N
	CALL	SEND_DAT
	LAC	MSG_T
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X0FF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9E
	CALL	SEND_DAT
	LACL	6
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X0FF
	CALL	SEND_DAT
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROPLY_1:		;Pause
	LAC	MSG
	XORL	CMSG_KEY4S		;PLAY
	BS	ACZ,LOCAL_PROPLY_1_CPLAY
;MAIN_PRO2_1:
	LAC	MSG
	XORL	CMSG_KEY7S		;stop
	BS	ACZ,LOCAL_PROPLY_X_STOP
;MAIN_PRO2_2:
	LAC	MSG
	XORL	CMSG_TMR		;TMR
	BS	ACZ,LOCAL_PROPLY_1_TMR
	
	RET
;-------
LOCAL_PROPLY_1_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	31
	BZ	SGN,LOCAL_PROPLY_X_STOP		;Pause time out
	
	RET
;-------
LOCAL_PROPLY_1_CPLAY:
	LAC	PRO_VAR
	ANDL	0XFFF0
	SAH	PRO_VAR

	LAC	CONF
	ANDL	~(1<<8)
	CALL	DAM_BIOSFUNC
;!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	LACL	0XC7
	CALL	SEND_DAT
	LAC	MSG_ID
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT	
;!!!!!!!!!!!!!!!!!!!!!!!!!!!

	RET
;-------------------------------------------------------------------------------
;	Get the address-offset of time in CID-message
;	input : ADDR_S
;	output: ACCH = offset
;-------------------------------------------------------------------------------
GET_TIMEOFFSET:
	MAR	+0,1
	LAR	ADDR_S,1
	LACK	0
	SAH	COUNT

	LAC	+,1
	LAC	-,1
	ANDL	0X80
	BS	ACZ,GET_TIMEADDR_END	;��ʱ����?
	
	LACK	0
	SAH	OFFSET_S
	
	LAC	+0,1
	ANDL	0X80
	BS	ACZ,GET_TIMEADDR_1
	LAC	+0,1
	ANDK	0X7F
	ADHK	1
	SFR	1
	SAH	OFFSET_S	;add NUM length
GET_TIMEADDR_1:
	LAC	+0,1
	ANDL	0X8000
	BS	ACZ,GET_TIMEADDR_2
	LAC	+0,1
	SFR	8
	ANDK	0X7F
	ADH	OFFSET_S		
	SAH	OFFSET_S	;add NAME length
GET_TIMEADDR_2:
	LAC	OFFSET_S
	ADHK	4
	SAH	OFFSET_S	;add flag length
GET_TIMEADDR_END:
	RET
	
;-------------------------------------------------------------------------------
.INCLUDE l_ply.asm
;-------------------------------------------------------------------------------
	
.END
