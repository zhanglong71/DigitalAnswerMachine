.LIST
LOCAL_PRO:
	LAC	PRO_VAR
	ANDK	0X0F
	BS	ACZ,LOCAL_PRO0		;0 = idle
	SBHK	1
	BS	ACZ,LOCAL_PROPLY	;1 = play memo/icm
	SBHK	1
	BS	ACZ,LOCAL_PROREC	;2 = record memo
	SBHK	1
	BS	ACZ,LOCAL_PROOGM	;3 = record/play OGM
	SBHK	1
	BS	ACZ,LOCAL_PROEXT	;4 = for end BBEEP and return standby
	SBHK	1
	BS	ACZ,LOCAL_PROVOP	;5 = for VOP test
	
	RET
;---------------�¼���Ӧ��
LOCAL_PRO0:
	LAC	MSG
	XORL	CMSG_INIT		;INITIAL
	BS	ACZ,MAIN_PRO0_INIT
LOCAL_PRO0_0_1:	
	LAC	MSG
	XORL	CVP_STOP		;VP_STOP
	BS	ACZ,LOCAL_PRO0_VPSTOP
LOCAL_PRO0_1:
	LAC	MSG
	XORL	CMSG_KEY1S		;Record memo
	BS	ACZ,LOCAL_PRO0_MEMOHELP
LOCAL_PRO0_1_1:
	LAC	MSG
	XORL	CMSG_KEY1L		;Record 2-WAY
	BS	ACZ,LOCAL_PRO0_RECMSG
LOCAL_PRO0_2:
	LAC	MSG
	XORL	CMSG_KEY2S		;PLY NEXT
	BS	ACZ,LOCAL_PRO0_PLYNEXT
LOCAL_PRO0_3:
	LAC	MSG
	XORL	CMSG_KEY3S		;FPLY ON/OFF
	BS	ACZ,LOCAL_PRO0_RINGCNT
LOCAL_PRO0_4:
	LAC	MSG
	XORL	CMSG_KEY4S		;speakerphone On
	BS	ACZ,LOCAL_PRO0_PHONE
LOCAL_PRO0_5:
	LAC	MSG
	XORL	CMSG_KEY5S		;OGM_PLAY
	BS	ACZ,LOCAL_PRO0_PLYPREV
LOCAL_PRO0_5_1:
	LAC	MSG
	XORL	CMSG_KEY5L		;OGM_RECORD
	BS	ACZ,LOCAL_PRO0_RECOGM
LOCAL_PRO0_6:
	LAC	MSG
	XORL	CMSG_KEY6S		;Play digit
	BS	ACZ,LOCAL_PRO0_MENU
LOCAL_PRO0_7:
	LAC	MSG
	XORL	CMSG_KEY7S		;RING
	BS	ACZ,LOCAL_PRO0_RING
LOCAL_PRO0_8:
	LAC	MSG
	XORL	CMSG_KEY8S		;;speakerphone Off
	BS	ACZ,LOCAL_PRO0_FPLY
LOCAL_PRO0_9:
	LAC	MSG
	XORL	CMSG_KEY9S		;STOP
	BS	ACZ,LOCAL_PRO0_STOP
LOCAL_PRO0_10:
	LAC	MSG
	XORL	CMSG_KEYAS		;on/off
	BS	ACZ,LOCAL_PRO0_ONOFF
LOCAL_PRO0_11:
	LAC	MSG
	XORL	CMSG_KEYBS		;VOL-
	BS	ACZ,LOCAL_PRO0_VOLS
LOCAL_PRO0_12:
	LAC	MSG
	XORL	CMSG_KEYCS		;CID
	BS	ACZ,LOCAL_PRO0_SEDCID
LOCAL_PRO0_13:
	LAC	MSG
	XORL	CMSG_KEYDS		;CMSG_PLAY
	BS	ACZ,LOCAL_PRO0_PLYMSG
LOCAL_PRO0_14:
	LAC	MSG
	XORL	CMSG_KEYES		;del playing message
	BS	ACZ,LOCAL_PRO0_DELMSG
LOCAL_PRO0_14_1:
	LAC	MSG
	XORL	CMSG_KEYEL		;del all old message
	BS	ACZ,LOCAL_PRO0_DELOLD
LOCAL_PRO0_15:
	LAC	MSG
	XORL	CMSG_KEYFS		;VOL+
	BS	ACZ,LOCAL_PRO0_VOLA	
LOCAL_PRO0_16:
	LAC	MSG
	XORL	CMSG_KEY16S		;initial
	BS	ACZ,LOCAL_PRO0_INIT
LOCAL_PRO0_17:
	LAC	MSG
	XORL	CMSG_TMR		;CMSG_TMR
	BS	ACZ,LOCAL_PRO0_TMR
	
	RET
;---------------
LOCAL_PRO0_PLYNEXT:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	
	DINT
;---
	CALL	IIC_START	;start
	LACL	0X82+0		;WRITE
	CALL	SEND_BYTE	;address+W/R
	CALL	SLAVE_ACK
	LACL	0X56
	CALL	SEND_BYTE	;command
	CALL	SLAVE_ACK
	LACL	0X56
	CALL	SEND_BYTE	;
	CALL	SLAVE_ACK
	CALL	IIC_STOP
;---	
	EINT

	RET
;---------------
LOCAL_PRO0_FPLY:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP


	LACK	0X62
	SAH	SYSTMP1
	LACK	0X63
	SAH	SYSTMP2
	LAC	MSG_ID
	CALL	VALUE_ADD
	SAH	MSG_ID

	DINT
;---
	CALL	IIC_START	;start
	LACL	0X82+0		;WRITE
	CALL	SEND_BYTE	;address+W/R
	CALL	SLAVE_ACK
	LAC	MSG_ID
	CALL	SEND_BYTE	;command
	CALL	SLAVE_ACK
	LAC	MSG_ID
	CALL	SEND_BYTE	;
	CALL	SLAVE_ACK
	CALL	IIC_STOP
;---	
	EINT
	
	RET
LOCAL_PRO0_RINGCNT:	;speed down
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP

	LACK	0X2
	SAH	SYSTMP1
	LACK	0X9
	SAH	SYSTMP2
	LAC	MSG_ID
	CALL	VALUE_ADD
	SAH	MSG_ID

	DINT
;---
	CALL	IIC_START	;start
	LACL	0X82+0		;WRITE
	CALL	SEND_BYTE	;address+W/R
	CALL	SLAVE_ACK
	LACL	0X41
	CALL	SEND_BYTE	;command
	CALL	SLAVE_ACK
	LAC	MSG_ID
	CALL	SEND_BYTE	;
	CALL	SLAVE_ACK
	CALL	IIC_STOP
;---	
	EINT
	
	RET
LOCAL_PRO0_PHONE:	
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP

	LAC	EVENT
	XORL	1<<11
	SAH	EVENT
	
	DINT
;---
	CALL	IIC_START	;start
	LACL	0X82+0		;WRITE
	CALL	SEND_BYTE	;address+W/R
	CALL	SLAVE_ACK
	LACL	0X5E
	CALL	SEND_BYTE	;command
	CALL	SLAVE_ACK
	LAC	EVENT
	SFR	11
	ANDK	0X01
	CALL	SEND_BYTE	;
	CALL	SLAVE_ACK
	CALL	IIC_STOP
;---	
	EINT

	RET

;---------------
MAIN_PRO0_INIT:
	LACL	0X8E	;F000
	SAH	LED1
	LACL	0XC0
	SAH	LED2
	LACL	0XC0
	SAH	LED3
	LACL	0XC0
	SAH	LED4

	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER

	RET
LOCAL_PRO0_VPSTOP:
	LACL	CMSG_INIT
	CALL	STOR_MSG
	
	RET
LOCAL_PRO0_VOLS:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	
	LACK	0X1
	SAH	SYSTMP1
	LACK	0X8
	SAH	SYSTMP2
	
	LAC	MSG_ID
	CALL	VALUE_ADD
	SAH	MSG_ID

	DINT
;---
	CALL	IIC_START	;start
	LACL	0X82+0		;WRITE
	CALL	SEND_BYTE	;address+W/R
	CALL	SLAVE_ACK
	LACL	0X4A
	CALL	SEND_BYTE	;command
	CALL	SLAVE_ACK
	LAC	MSG_ID
	CALL	SEND_BYTE	;
	CALL	SLAVE_ACK
	CALL	IIC_STOP
;---	
	EINT
	
	RET
LOCAL_PRO0_VOLA:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	
	LAC	EVENT
	XORL	1<<12
	SAH	EVENT
	BIT	EVENT,12
	BS	TB,LOCAL_PRO0_VOLA_1
LOCAL_PRO0_VOLA_0:
	LACK	0X00
	SAH	MSG
	BS	B1,LOCAL_PRO0_VOLA_DONE
LOCAL_PRO0_VOLA_1:
	LACK	0X10
	SAH	MSG
LOCAL_PRO0_VOLA_DONE:	
	
	DINT
;---
	CALL	IIC_START	;start
	LACL	0X82+0		;WRITE
	CALL	SEND_BYTE	;address+W/R
	CALL	SLAVE_ACK
	LACL	0X4B
	CALL	SEND_BYTE	;command
	CALL	SLAVE_ACK

	LAC	VOI_ATT
	ADHK	0X010
	ANDL	0Xff7f
	SAH	VOI_ATT
	SFR	4
	ANDK	0x07
	OR	MSG
	CALL	SEND_BYTE	;
	CALL	SLAVE_ACK
	CALL	IIC_STOP
;---	
	EINT

	RET
LOCAL_PRO0_MEMOHELP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	
	DINT
;---
	CALL	IIC_START	;start
	LACL	0X82+0		;WRITE
	CALL	SEND_BYTE	;address+W/R
	CALL	SLAVE_ACK
	LACL	0X59
	CALL	SEND_BYTE	;command
	CALL	SLAVE_ACK
	LACL	0X0
	CALL	SEND_BYTE	;
	CALL	SLAVE_ACK
	CALL	IIC_STOP
;---	
	EINT
	
	RET
LOCAL_PRO0_RECMSG:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	
	DINT
;---
	CALL	IIC_START	;start
	LACL	0X82+0		;WRITE
	CALL	SEND_BYTE	;address+W/R
	CALL	SLAVE_ACK
	LACL	0X59
	CALL	SEND_BYTE	;command
	CALL	SLAVE_ACK
	LACL	0X01
	CALL	SEND_BYTE	;
	CALL	SLAVE_ACK
	CALL	IIC_STOP
;---	
	EINT
	
	RET

LOCAL_PRO0_RECOGM:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	
	DINT
;---
	CALL	IIC_START	;start
	LACL	0X82+0		;WRITE
	CALL	SEND_BYTE	;address+W/R
	CALL	SLAVE_ACK
	LACL	0X53
	CALL	SEND_BYTE	;command
	CALL	SLAVE_ACK
	LACL	0X53
	CALL	SEND_BYTE	;
	CALL	SLAVE_ACK
	CALL	IIC_STOP
;---	
	EINT

	RET
LOCAL_PRO0_PLYPREV:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	
	DINT
;---
	CALL	IIC_START	;start
	LACL	0X82+0		;WRITE
	CALL	SEND_BYTE	;address+W/R
	CALL	SLAVE_ACK
	LACL	0X57
	CALL	SEND_BYTE	;command
	CALL	SLAVE_ACK
	LACL	0X57
	CALL	SEND_BYTE	;
	CALL	SLAVE_ACK
	CALL	IIC_STOP
;---	
	EINT

	RET
LOCAL_PRO0_TMR:
	LAC	PRO_VAR1
	ADHK	1
	ANDK	0X0F
	SAH	PRO_VAR1
	ADHL	DGT_TAB
	CALL    GetOneConst
	SAH	LED4

	;call	BINVIO

	RET
LOCAL_PRO0_MENU:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	
	DINT
;---
	CALL	IIC_START	;start
	LACL	0X82+0		;WRITE
	CALL	SEND_BYTE	;address+W/R
	CALL	SLAVE_ACK
	LACL	0X6A
	CALL	SEND_BYTE	;command
	CALL	SLAVE_ACK
	LAC	MSG_ID
	ADHK	1
	ANDK	0X0F
	SAH	MSG_ID
	CALL	SEND_BYTE	;
	CALL	SLAVE_ACK
	CALL	IIC_STOP
;---	
	EINT
	
	RET
LOCAL_PRO0_RING:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP

	LACK	0X0
	SAH	SYSTMP1
	LACK	0X2
	SAH	SYSTMP2
	LAC	MSG_ID
	CALL	VALUE_ADD
	SAH	MSG_ID

	DINT
;---
	CALL	IIC_START	;start
	LACL	0X82+0		;WRITE
	CALL	SEND_BYTE	;address+W/R
	CALL	SLAVE_ACK
	LACL	0X40
	CALL	SEND_BYTE	;command
	CALL	SLAVE_ACK
	LAC	MSG_ID
	CALL	SEND_BYTE	;
	CALL	SLAVE_ACK
	CALL	IIC_STOP
;---	
	EINT
	
	RET

	RET
LOCAL_PRO0_SEDCID:	;password
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	
	DINT
;---
	CALL	IIC_START	;start
	LACL	0X82+0		;WRITE
	CALL	SEND_BYTE	;address+W/R
	CALL	SLAVE_ACK
	LACL	0X42
	CALL	SEND_BYTE	;command
	CALL	SLAVE_ACK
	LACL	0X07
	CALL	SEND_BYTE	;ps1
	CALL	SLAVE_ACK
	CALL	IIC_STOP
;---	
	LACL	2000
	CALL	DELAY
;-------------------------------------------------
;---
	CALL	IIC_START	;start
	LACL	0X82+0		;WRITE
	CALL	SEND_BYTE	;address+W/R
	CALL	SLAVE_ACK
	LACL	0X43
	CALL	SEND_BYTE	;command
	CALL	SLAVE_ACK
	LACL	0X89
	CALL	SEND_BYTE	;ps2,3
	CALL	SLAVE_ACK
	CALL	IIC_STOP
;---	
	EINT
	
	
	RET
LOCAL_PRO0_PLYMSG:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	
	DINT
;---
	CALL	IIC_START	;start
	LACL	0X82+0		;WRITE
	CALL	SEND_BYTE	;address+W/R
	CALL	SLAVE_ACK
	LACL	0X54
	CALL	SEND_BYTE	;command
	CALL	SLAVE_ACK
	LACL	0X54
	CALL	SEND_BYTE	;
	CALL	SLAVE_ACK
	CALL	IIC_STOP
;---	
	EINT
	
	RET
LOCAL_PRO0_DELMSG:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	
	DINT
;---
	CALL	IIC_START	;start
	LACL	0X82+0		;WRITE
	CALL	SEND_BYTE	;address+W/R
	CALL	SLAVE_ACK
	LACL	0X5B
	CALL	SEND_BYTE	;command
	CALL	SLAVE_ACK
	LACL	0X5B
	CALL	SEND_BYTE	;
	CALL	SLAVE_ACK
	CALL	IIC_STOP
;---	
	EINT
	
	RET
;---------------
LOCAL_PRO0_DELOLD:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	
	DINT
;---
	CALL	IIC_START	;start
	LACL	0X82+0		;WRITE
	CALL	SEND_BYTE	;address+W/R
	CALL	SLAVE_ACK
	LACL	0X5C
	CALL	SEND_BYTE	;command
	CALL	SLAVE_ACK
	LACL	0X5C
	CALL	SEND_BYTE	;
	CALL	SLAVE_ACK
	CALL	IIC_STOP
;---	
	EINT
	
	RET
LOCAL_PRO0_INIT:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	
	DINT
;---
	CALL	IIC_START	;start
	LACL	0X82+0		;WRITE
	CALL	SEND_BYTE	;address+W/R
	CALL	SLAVE_ACK
	LACL	0X80
	CALL	SEND_BYTE
	CALL	SLAVE_ACK
;-
	LACL	0X08		;year
	CALL	SEND_BYTE
	CALL	SLAVE_ACK
	LACL	0X12		;month
	CALL	SEND_BYTE
	CALL	SLAVE_ACK
	LACL	0X31		;day
	CALL	SEND_BYTE
	CALL	SLAVE_ACK
	LACL	0X23		;hour
	CALL	SEND_BYTE
	CALL	SLAVE_ACK
	LACL	0X59		;minute
	CALL	SEND_BYTE
	CALL	SLAVE_ACK
	LACL	0X01		;secretity code1
	CALL	SEND_BYTE
	CALL	SLAVE_ACK
	LACL	0X23		;secretity code2,3
	CALL	SEND_BYTE
	CALL	SLAVE_ACK
	LACL	0X35		;(ring-cnt)|VOL
	CALL	SEND_BYTE
	CALL	SLAVE_ACK
	LACL	0X1D		;bMAP
	CALL	SEND_BYTE
	CALL	SLAVE_ACK
	CALL	IIC_STOP
;---	
	EINT
	
	RET
;---------------
LOCAL_PRO0_STOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	
	DINT
;---
	CALL	IIC_START	;start
	LACL	0X82
	CALL	SEND_BYTE	;address+W/R
	CALL	SLAVE_ACK
	LACL	0X5A
	CALL	SEND_BYTE	;command
	CALL	SLAVE_ACK
	LACL	0X5A
	CALL	SEND_BYTE	;
	CALL	SLAVE_ACK
	CALL	IIC_STOP
;---	
	EINT

	RET
LOCAL_PRO0_ONOFF:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BEEP
	
	LAC	EVENT		;EVENT.9
	XORL	1<<9
	SAH	EVENT
	
	DINT
;---
	CALL	IIC_START	;start
	LACL	0X82
	CALL	SEND_BYTE	;address+W/R
	CALL	SLAVE_ACK
	LACL	0X50
	CALL	SEND_BYTE	;command
	CALL	SLAVE_ACK
	LAC	EVENT
	SFR	9
	XORK	1
	ANDK	1
	CALL	SEND_BYTE	;
	CALL	SLAVE_ACK
	CALL	IIC_STOP
;---	
	EINT
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROPLY:
	LAC	MSG
	XORL	CMSG_KEYDS		;pause
	BS	ACZ,LOCAL_PROPLY_PAUSE
LOCAL_PROPLY_0_2:
	LAC	MSG
	XORL	CMSG_KEYES		;erase
	BS	ACZ,LOCAL_PROPLY_ERASE
LOCAL_PROPLY_0_3:
	LAC	MSG
	XORL	CMSG_KEYAS		;ON/OFF(stop)
	BS	ACZ,LOCAL_PROPLY_STOP
LOCAL_PROPLY_0_4:
	LAC	MSG
	XORL	CMSG_KEYBS		;VOL-
	BS	ACZ,LOCAL_PROPLY_VOLS
LOCAL_PROPLY_0_5:
	LAC	MSG
	XORL	CMSG_KEYFS		;VOL+
	BS	ACZ,LOCAL_PROPLY_VOLA
LOCAL_PROPLY_0_6:
	LAC	MSG
	XORL	CVP_STOP		;PLAY END
	BS	ACZ,LOCAL_PROPLY_OVER	
	RET
LOCAL_PROPLY_PAUSE:
	RET
LOCAL_PROPLY_VOLS:
	LACL	CMSG_VOLS
	CALL	STOR_MSG
	
	RET
LOCAL_PROPLY_VOLA:
	LACL	CMSG_VOLA
	CALL	STOR_MSG
	
	RET
LOCAL_PROPLY_ERASE:
	LAC	MSG_ID
	CALL	SET_DELMARK
	CALL	INIT_DAM_FUNC
	LACK	0X001
	CALL	STOR_VP
	
	;LACK	0
	;SAH	PRO_VAR
	
	RET
LOCAL_PROPLY_OVER:
	CALL	INIT_DAM_FUNC

	LAC	MSG_ID
	SBH	MSG_T
	BZ	SGN,LOCAL_PROPLY_STOP

	LAC	MSG_ID			;next message
	ADHK	1
	SAH	MSG_ID
	
	BIT	ANN_FG,12
	BZ	TB,MAIN_PRO1_PLAY_OVER2

	CALL	FFW_MANAGE
	BZ	ACZ,LOCAL_PROPLY_STOP	;THE LAST ONE	

MAIN_PRO1_PLAY_OVER2:
	
	CALL	BEEP
	LAC	MSG_ID
	ORL	0XFE00
	CALL	STOR_VP
	
	RET
LOCAL_PROPLY_STOP:		;ȫ������ϻ�ǿ���˳�
	CALL	INIT_DAM_FUNC
	CALL	REAL_DEL
	BS	B1,LOCAL_PROEND_BEFORINIT

;-------------------------------------------------------------------------------
LOCAL_PROREC:			;record MEMO
	LAC	PRO_VAR
	SFR	4
	ANDK	0X0F
	BS	ACZ,LOCAL_PROREC0	;prompt
	SBHK	1
	BS	ACZ,LOCAL_PROREC1	;record
	
	RET
LOCAL_PROREC0:
	LAC	MSG
	XORL	CMSG_KEYAS		;worn and stop
	BS	ACZ,LOCAL_PROWORN
;LOCAL_PROREC0_1:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PRO0_RECSTART	;end beep and start record
	
	RET
LOCAL_PRO0_RECSTART:
	CALL	INIT_DAM_FUNC
	CALL	DAA_REC
	CALL	REC_START

	LACL	1000
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1

	LACK	0X012
	SAH	PRO_VAR
	
	RET	
LOCAL_PROREC1:
	LAC	MSG
	XORL	CMSG_KEYAS		;stop record
	BS	ACZ,LOCAL_PROREC_STOP
LOCAL_PROREC1_1:
	LAC	MSG
	XORL	CMSG_TMR		;timer
	BS	ACZ,LOCAL_PROX_TMR

	RET
LOCAL_PROX_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	
	RET
LOCAL_PROREC_STOP:
	LAC	PRO_VAR1
	SBHK	3
	BS	SGN,LOCAL_PRORECFAIL_STOP
	BS	B1,LOCAL_PROEND_BEFORINIT	;¼����Ϻ��˳�
LOCAL_PRORECFAIL_STOP:		;¼��ʧ��
	LAC	CONF
	ORL	0X0800
	SAH	CONF
	CALL	DAM_BIOS
	CALL	INIT_DAM_FUNC
	
	CALL	DAA_SPK
	CALL	BBBEEP
	
	LACK	0
	SAH	PRO_VAR
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROOGM:
	LAC	PRO_VAR
	SFR	4
	ANDK	0X0F
	BS	ACZ,LOCAL_PROOGM_PLYVOP		;0 - VOP
	SBHK	1
	BS	ACZ,LOCAL_PROOGM_RECOGM		;1 - record OGM
	SBHK	1
	BS	ACZ,LOCAL_PROOGM_PLYOGM		;2 - play OGM

	RET
LOCAL_PROOGM_PLYVOP:
	LAC	MSG
	XORL	CMSG_KEYAS
	BS	ACZ,LOCAL_PROWORN		;worn and stop
;LOCAL_PROOGM_PLYVOP0_1:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,LOCAL_PROOGM_RECSTART	;end beep and start record
	
	RET
LOCAL_PROOGM_RECSTART:
	CALL	INIT_DAM_FUNC
	CALL	DAA_REC
	LACK	0X0013
	SAH	PRO_VAR
PROOGM_RECREADY:		;Note: ң��¼OGMʱҲ��ת����,�����������
	LAC	VOI_ATT
	SFR	8
	ANDK	0X0F
	CALL	OGM_SELECT
;-------delete the old OGM fisrt------------
	LAC	MSG_ID
	CALL	VPMSG_DEL
	CALL	GC_CHK
;---	
    	LAC	MSG_N
    	ORL	0X8D00
    	CALL	DAM_BIOSFUNC		;set user index data0"OGM_ID"
;---	
	CALL	REC_START
	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER

	RET
LOCAL_PROOGM_RECOGM:		;record OGM
	LAC	MSG
	XORL	CMSG_KEYAS		;stop record
	BS	ACZ,LOCAL_PROOGM_RECOGM_STOP
LOCAL_PROOGM_REC1_1:
	LAC	MSG
	XORL	CMSG_TMR		;timer
	BS	ACZ,LOCAL_PROOGM_RECTMR
	
	RET
LOCAL_PROOGM_RECTMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	120
	BZ	SGN,LOCAL_PROOGM_RECOGMSUCC_STOP
	
	RET
LOCAL_PROOGM_RECOGM_STOP:
	LAC	PRO_VAR1
	SBHK	3
	BZ	SGN,LOCAL_PROOGM_RECOGMSUCC_STOP

;LOCAL_PROOGM_RECOGMFAIL_STOP:	
	LAC	CONF
	ORL	0X0800
	SAH	CONF
	CALL	DAM_BIOS
LOCAL_PROOGM_RECOGMSUCC_STOP:	;׼������OGM
	
	CALL	DAA_SPK
	LACK	0X0023
	SAH	PRO_VAR		;���벥��OGM�ӹ���
PROOGM_LOADOGM:
	CALL	INIT_DAM_FUNC
	LAC	VOI_ATT
	SFR	8
	ANDK	0X0F
	CALL	OGM_SELECT
	
	LAC	MSG_N
	ADHL	DGT_TAB
	CALL	GetOneConst
	SAH	LED4
	
	LAC	MSG_ID
	ORL	0XFE00
	CALL	STOR_VP

	LAC	MSG_N
	CALL	OGM_SELECT
	BZ	ACZ,MAIN_PRO0_PLAY_OGM1
	
	CALL	INIT_DAM_FUNC
	CALL	BBBEEP

MAIN_PRO0_PLAY_OGM1:

	RET

LOCAL_PROOGM_PLYOGM:		;PLAY 
	LAC	MSG
	XORL	CMSG_KEYAS		;stop record(�ֶ�ֹͣ)
	BS	ACZ,LOCAL_PROOGM_PLYOGM_STOP
LOCAL_PROOGM_PLYOGM0_1:	
	LAC	MSG
	XORL	CVP_STOP		;stop record(����ֹͣ)
	BS	ACZ,LOCAL_PROOGM_PLYOGM_STOP
LOCAL_PROOGM_PLYOGM0_2:	
	LAC	MSG
	XORL	CMSG_KEY5S		;stop record(����ֹͣ)
	BS	ACZ,LOCAL_PROOGM_PLYOGM_NEXT
	
	RET
LOCAL_PROOGM_PLYOGM_STOP:
	BS	B1,LOCAL_PROEND_BEFORINIT
LOCAL_PROOGM_PLYOGM_NEXT:
	CALL	INIT_DAM_FUNC
	
	LACK	1
	SAH	SYSTMP1
	LACK	5
	SAH	SYSTMP2

	LAC	MSG_N
	CALL	VALUE_ADD
	SAH	MSG_N

	LAC	VOI_ATT
	ANDL	0XF0FF
	SAH	VOI_ATT
	
	LAC	MSG_N
	SFL	8
	ANDL	0X0F00
	OR	VOI_ATT
	SAH	VOI_ATT	
	
	BS	B1,LOCAL_PROOGM_RECOGMSUCC_STOP
;-------------------------------------------------------------------------------	
LOCAL_PROEND_BEFORINIT:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BBEEP
	
	LACK	0X0004
	SAH	PRO_VAR

	RET
LOCAL_PROVOP:
	LAC	MSG
	XORL	CVP_STOP		;PLAY END
	BS	ACZ,LOCAL_PROVOP_OVER
LOCAL_PROVOP_1:	
	LAC	MSG
	XORL	CMSG_KEYAS		;ON/OFF(stop)
	BS	ACZ,LOCAL_PROVOP_STOP
	
	RET
LOCAL_PROVOP_OVER:
	CALL	INIT_DAM_FUNC

	LAC	MSG_ID
	SBHK	15
	BZ	SGN,LOCAL_PROVOP_STOP

	LAC	MSG_ID			;next message
	ADHK	1
	SAH	MSG_ID
	
	LAC	MSG_ID
	ORL	0XFF00
	CALL	STOR_VP
	
	RET
LOCAL_PROVOP_STOP:
	CALL	INIT_DAM_FUNC
	BS	B1,LOCAL_PROEND_BEFORINIT
;-------------------------------------------------------------------------------
LOCAL_PROEXT:
	LAC	MSG
	XORL	CVP_STOP		;stop record(����ֹͣ)
	BS	ACZ,LOCAL_PROEXT_END
LOCAL_PROEXT0_1:	
	LAC	MSG
	XORL	CMSG_KEYAS		;stop record(�ֶ�ֹͣ)
	BS	ACZ,LOCAL_PROEXT_END	
	RET
LOCAL_PROEXT_END:
	LACK	0
	SAH	PRO_VAR
	
	LACL	CMSG_INIT
	CALL	STOR_MSG
	
	RET
;-------------------------------------------------------------------------------
LOCAL_PROWORN:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	BBBEEP
	
	LACK	0X0004
	SAH	PRO_VAR
	
	RET

;-------------------------------------------------------------------------------
	
.END