
;-----------------------------// Constant key defines,ȫ����C��ͷ��--------------------------------
;---SYS MSG CONST------------------
	CMSG_KEY1S	.EQU	0X01	;messages for key released(�ɿ�����UP)
	CMSG_KEY2S	.EQU	0X02
	CMSG_KEY3S	.EQU	0X03
	CMSG_KEY4S	.EQU	0X04
	CMSG_KEY5S	.EQU	0X05
	CMSG_KEY6S	.EQU	0X06
	CMSG_KEY7S	.EQU	0X07
	CMSG_KEY8S	.EQU	0X08
	CMSG_KEY9S	.EQU	0X09
	CMSG_KEYAS	.EQU	0X0A
	CMSG_KEYBS	.EQU	0X0B
	CMSG_KEYCS	.EQU	0X0C
;---	
	CMSG_KEY1L	.EQU	0X11	;messages for key beening pressed 2s
	CMSG_KEY2L	.EQU	0X12
	CMSG_KEY3L	.EQU	0X13
	CMSG_KEY4L	.EQU	0X14
	CMSG_KEY5L	.EQU	0X15
	CMSG_KEY6L	.EQU	0X16
	CMSG_KEY7L	.EQU	0X17
	CMSG_KEY8L	.EQU	0X18
	CMSG_KEY9L	.EQU	0X19
	CMSG_KEYAL	.EQU	0X1A
	CMSG_KEYBL	.EQU	0X1B
	CMSG_KEYCL	.EQU	0X1C
;---	
	CMSG_KEY1P	.EQU	0X21	;messages for key beening pressed every 512ms
	CMSG_KEY2P	.EQU	0X22
	CMSG_KEY3P	.EQU	0X23
	CMSG_KEY4P	.EQU	0X24
	CMSG_KEY5P	.EQU	0X25
	CMSG_KEY6P	.EQU	0X26
	CMSG_KEY7P	.EQU	0X27
	CMSG_KEY8P	.EQU	0X28
	CMSG_KEY9P	.EQU	0X29
	CMSG_KEYAP	.EQU	0X2A
	CMSG_KEYBP	.EQU	0X2B
	CMSG_KEYCP	.EQU	0X2C
	
	CMSG_KEY1D	.EQU	0X31	;messages for key beening pressed DOWN(48ms later)
	CMSG_KEY2D	.EQU	0X32
	CMSG_KEY3D	.EQU	0X33
	CMSG_KEY4D	.EQU	0X34
	CMSG_KEY5D	.EQU	0X35
	CMSG_KEY6D	.EQU	0X36
	CMSG_KEY7D	.EQU	0X37
	CMSG_KEY8D	.EQU	0X38
	CMSG_KEY9D	.EQU	0X39
	CMSG_KEYAD	.EQU	0X3A
	CMSG_KEYBD	.EQU	0X3B
	CMSG_KEYCD	.EQU	0X3C
;---messages for function	
	
	CMSG_INIT	.EQU	0X81
	
	CMSG_TIFAT	.EQU	0X83	;��MCU����ʱ����ʽ
	CMSG_CTONE	.EQU	0X84
	CMSG_BTONE	.EQU	0X85
	CREV_DTMF	.EQU	0X86
	CMSG_VOX	.EQU	0X87

	CSEG_STOP	.EQU	0X89
	CSEG_PAUSE	.EQU	0X8A

;	CTWAY_REC	.EQU	0X8C
	CMSG_VOLA	.EQU	0X8D
	CMSG_VOLS	.EQU	0X8E
;---------------------------------------	
	CMSG_TMR	.EQU	0X90	;MSG OF BASE TIME
	CSEG_END	.EQU	0X91	;���ŵȵ�һ��β
	CVP_STOP	.EQU	0X92	;������ϣ�
	;CCOM_INIT	.EQU	0X93	;Ӳ����ʼ������
	
	CMENU_LGGE	.EQU	0X94	;����language
	CMENU_TIME	.EQU	0X95	;����time
	CMENU_CTRT	.EQU	0X96	;����contrast
	CMENU_PSWD	.EQU	0X97	;����PSWORD
	CMENU_LCOD	.EQU	0X98	;����local code
	CMENU_RCNT	.EQU	0X99	;����ring counter
	CMENU_OGMC	.EQU	0X9A	;����OGM
;---------------------------------------	
	CBOOK_SLET	.EQU	0XA0	;ѡ��绰����Ŀ --- ����/�༭(edit/search)
	CNUMB_BADD	.EQU	0XA1	;���ӵ绰����Ŀ�еĺ���
	CNAME_BADD	.EQU	0XA2	;���ӵ绰����Ŀ�е�����
	CNUMB_EDIT	.EQU	0XA3	;�༭�绰����Ŀ�еĺ���
	CNAME_EDIT	.EQU	0XA4	;�༭�绰����Ŀ�е�����
;-------
	CREC_FULL	.EQU	0XB1	;FLASH FULL
	;CLINE_CONNT	.EQU	0XB2	;�е绰�߲����γ�
	;CBUF_EMPTY	.EQU	0XB8	;���ͻ�������
;-------
	;CMIC_REC	.EQU	0XD1
	;CREC_OGM	.EQU	0XD2	;¼��0GM����ID�ж�1��2
	;CREC_VP	.EQU	0XD3	;¼��
	;CREC_ICM	.EQU	0XD4	;����¼��
	;CRUN_DEL	.EQU	0XD5	;ɾ¼��
	;CDEL_OGM	.EQU	0XD6	;ɾOGMX
	;CDEL_REC	.EQU	0XD7	;ɾ¼��
	;CDEL_ICM	.EQU	0XD8	;ɾ����
	
	;CPLAY_ID	.EQU	0XD9	;����
	;CPLAY_NEW	.EQU	0XDA	;������
	;CPLAY_TOTAL	.EQU	0XDB
	;CPLAY_OGM	.EQU	0XDC	;��OGMX����ID�ж�1��2
;---�ⲿ�¼���Ϣ(����֮���)	
	CMSG_SER	.EQU	0XE7	;�յ�����
	CMSG_CPC	.EQU	0XE8
	CFIRST_RI	.EQU	0XE9	;��һ������
	CRING_OK	.EQU	0XEA
	CRMOT_OK	.EQU	0XEB	;ENTER REMOTE stat
	CRING_IN	.EQU	0XEC
	CRING_FAIL	.EQU	0XED
;-------------------------------------------------------------------------------
CTAG_ICM	.EQU		120
CTAG_MEMO	.EQU		121
CTEL_MNUM	.EQU		16	;Declare TEL-Message Number in FLASH
;-------------------------------------------------------------------------------
COGM1_ID	.EQU	0x71	;for OGM VP USR-DAT
COGM2_ID	.EQU	0x72
COGM3_ID	.EQU	0x73
COGM4_ID	.EQU	0x74
COGM5_ID	.EQU	0x75
;-------------------------------------------------------------------------------
CMAX_VOL	.EQU	0x5
CMIN_VOL	.EQU	0x1
;-------------------------------------------------------------------------------
CBEEP_COMMAND	.EQU		0X48F7	;BEEP CON
;-------------------------------------------------------------------------------
CMODE9		.EQU		0x9240
;-------------------------------------------------------------------------------
;SER_FG	(change only in interrupt)
CbRx		.EQU   	4	;bit4 = receive
CbTx		.EQU   	5	;bit5 = send

CbBUSY		.EQU   	6	;bi6 = IIC busy can`t receive command
CbLINE		.EQU   	8	;bi8 = ring or Torev on line
;-------------------------------------------------------------------------------
ADDR_FIRST	.EQU	0X4400
ADDR_SECOND	.EQU	0X5A00
;-------------------------------------------------------------------------------
CCOMMOND_SETCONTRAST	.EQU	0X87
;---
CCOMMOND_LANGUAGE	.EQU	0X90

CCOMMOND_HOUR		.EQU	0X91
CCOMMOND_MINUTE		.EQU	0X92
CCOMMOND_MONTH		.EQU	0X93
CCOMMOND_DAY		.EQU	0X94
CCOMMOND_WEEK		.EQU	0X95

CCOMMOND_CONTRAST	.EQU	0X96

CCOMMOND_PSWORD1	.EQU	0X97
CCOMMOND_PSWORD2	.EQU	0X98
CCOMMOND_PSWORD3	.EQU	0X99

CCOMMOND_OGMSELECT	.EQU	0XC0
CCOMMOND_RINGCNT	.EQU	0XCE
;-------------------------------------------------------------------------------
CMIC_PRE_GAIN		.EQU	0X08	;for local record
CAD0_PRE_GAIN		.EQU	0X07	;for local record
;---------------------------------------
CLNE_VOL		.EQU	0X19	;for answer/remote LINE-OUT volume
CAD0_PRE_RGAIN		.EQU	0X03	;for answer/remote AD0
;---------------------------------------
CAD0_PRE_2GAIN		.EQU	0X03	;for 2-way AD0
;---------------------------------------
CMICROM_MOR	.EQU	0X0A		;for room-monitor
CAD0ROM_MOR	.EQU	0X0C		;for room-monitor
CAD1ROM_MOR	.EQU	0X09		;for room-monitor
;-------------------------------------------------------------------------------
CGROUP_CID	.EQU	0	;CID
;CGROUP_MBOX1	.EQU	1	;��VP������CID
;CGROUP_MBOX2	.EQU	2	;��VP������CID
;CGROUP_MBOX3	.EQU	3	;��VP������CID
CGROUP_PBOOK	.EQU	4	;�绰��
CGROUP_DATT	.EQU	5	;DAM attribute
CGROUP_DATETIME	.EQU	6	;Datetime
;-------------------------------------------------------------------------------

;---------------
CTMR1S		.EQU	1024

CLICM	.EQU	120	;s
CLOGM	.EQU	120	;s
CLMEM	.EQU	0X7FFF	;s
CL2WAY	.EQU	0X7FFF	;s
;-------------------------------------------------------------------------------
DebugAD1	.EQU	1	;Use for room-monitor
;-------------------------------------------------------------------------------

.END
