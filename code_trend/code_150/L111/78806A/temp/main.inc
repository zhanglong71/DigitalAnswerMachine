
/*****************�Ĵ�������*********************/

int_temp0	==	0x10
int_temp1	==	0x11
int_temp2	==	0x12
int_temp3	==	0x13
int_temp4	==	0x14
int_temp5	==	0x15
temp0		==	0x16
temp1		==	0x17
temp2		==	0x18
temp3		==	0x19
temp4		==	0x1a
TEMP5		==	0X1b
FSK_FG		==	0X1c
STAMP_FG	==	0X1d			; ӡ����־�Ĵ���
SYS_FG		==	0X1e
EVENT		==	0X1F

;BANK 0
BANK0_TEMP0	==	0X20
BANK0_TEMP1	==	0X21
BANK0_TEMP2	==	0X22
BANK0_TEMP3	==	0X23
YEAR_REG	==	0X24
MONTH_REG	==	0X25
DAY_REG		==	0X26
WEEK_REG	==	0X27
HOUR_REG	==	0X28
MIN_REG		==	0X29
SEC_REG		==	0X2A

TOTAL_CALL	==	0X2B
NEW_CALL	==	0X2C
TOTAL_MSG	==	0X2D
NEW_MSG		==	0X2E
TOTAL_BOOK	==	0X2F

;LCD_CONTRAST	==	0X30			; ��4λΪ�Աȶ�
;CODE1		==	0X30			; ��4λΪ����1
;CODE23		==	0X31

LCALL12		==	0X30
LCALL34		==	0X31
LCALL5		==	0X32

TMR		==	0X34
TMR_DELAY	==	0X35
TMR_FLASH	==	0X36
TMR_SER		==	0X37
TMR_NAME	==	0X38
;TMR_IDLE	==	0X39
MENU_STATE	==	0X39

CONT		==	0X3A
STR_REG		==	0X3B
;SER_FLAG	==	0X3C
;SER_FLAG	==	0X3D
;SER_FLAG	==	0X3E
;SER_DATA	==	0X3F


;BANK 1
BANK1_TEMP0	==	0X20
BANK1_TEMP1	==	0X21
BANK1_TEMP2	==	0X22
BANK1_TEMP3	==	0X23
FSK_BYTE	==	0X24
FSK_SUM		==	0X25
FSK_LENGTH	==	0X26
FSK_COUNT	==	0X27
FSK_TMP		==	0X28
FSK_ADR		==	0X29
DTMF_ADR	==	0X2A

TIME_MS		==	0X2B
TIME_SEC	==	0X2C
TIME_MIN	==	0X2D
TIME_HOUR	==	0X2E
TMR_LINEDET	==	0X2F

TMR_PROTOCOL	==	0X30

R1_TEST_L111	==	0X31

R1_SYS_FG	==	0X32

R1_CD		==	0X33
R1_TMR_DTMF	==	0X34

R1_LCD_CONTRAST	==	0X35
R1_CODE1	==	0X35
R1_CODE23	==	0X36




/*****************��������***********************/

LCD_CTRL	==	128
VGA_ADDR	==	172

FSK_ADDR	==	0
DTMF_ADDR	==	0
CID_ADDR	==	60
EDIT_ADDR	==	94

DIAL_ADDR	==	132

TCP_ADDR	==	153

/*****************��־λ����*********************/

; SYS_FG
LANGUAGE	==	0			; ���Ա�־
NEWCALL		==	1			; 
STAMP		==	2			; ӡ�����ı�
SYS_CLOCK	==	3			; ��һ�����ֱ��ı�
LEEP_YEAR	==	4
LOCK_TOPLINE	==	5
LOCK_STR	==	6
TIME		==	7			; ��ʱ

; R1_SYS_FG
TIMEFORMAT	==	0			; ʱ����ʽ
HOOKSTATUS	==	1			; hook״̬


; EVENT
TEST		==	7
; STAMP_FG
;.0		REPEAT
;.1		NEW
;.2		battery
;.3		MEMO
;.4		second
;.5		/
;.6		spk
;.7		CALL
STAMP_REPEAT	==	0
STAMP_NEW	==	1
STAMP_BAT	==	2
STAMP_MEMO	==	3
STAMP_SEC	==	4
STAMP_SLASH	==	5
STAMP_SPK	==	6
STAMP_CALL	==	7

; FSK_FG
;TCC_400U	==	0
FSK_VALID	==	0
FSK_SUC		==	1			; FSK�������
FSK_ERR		==	2			; FSK���մ���
DTMF_START	==	3
DTMF_SUC	==	4			; DTMF�������
ERR_NUM		==	5			; �������
ERR_NAME	==	6			; ��������
CALLIN		==	7			; ������


/***************************************
CID BANK �滮

BANK0:
0~127	LCD RAMӳ��
LCD_CTRL == 128
0	��ʾ����
1	ӡ���Ĵ���
2~11	��һ�����ּĴ���
12~27	�ڶ������ּĴ���
28~43	�������ַ��Ĵ���
VGA_ADDR == 172
0	ӡ��������			; ��ʱ����
1	��ʾ����ӡ��������		; ����
2	��һ�п�����			; ����
3~12	��ʾ���ݵ�һ�����ֻ�����	; ����
13	�ڶ��п�����
14~45	��ʾ���ݵڶ������ֻ�����	��������С��Ϊ32��������ʾǰ16��
46	�����п�����
47~78	��ʾ���ݵ������ַ�������	��������С��Ϊ32��������ʾǰ16��
; ------------------------------------------------
BANK1:
FSK_ADDR == 0
0~59	FSK ����������������Ϣ����-��Ϣ����-��Ϣ��/��Ϣ����-��Ϣ����-��������-��������-�����֣�
DTMF_ADDR == 0
0~19	DTMF ������������

CID_ADDR == 60
�ӽ��������յ�����Ϣ����֮��õ�����Ϣ��
��93L111���յ��ĺ�����Ϣ��
Ԥ���͸�93L111�ĺ�����Ϣ��
0	CID_CTRL
	.7	�Ƿ�Ҫ���ε�һ��
	.6~.5	��ʾģʽ
1	��Ϣ��־λ
	.7	���ã�0��
	.1	�Ƿ�������
	.0	�Ƿ�REPEAT
2	���볤�� 1~16;0x00δ����/û�к���;0x43('C')Ͷ�ҵ绰����;0x49('I')��������Ĺ��ʺ���;0x4F('O')��������;0x50('P')˽��;0xFF�������;����������
3~10	�绰���룬һ���ֽڴ����λ����������ΪF��
11	�������� 1~16;0x00δ����/û�к���;0x4F('O')��������;0x50('P')˽��;0xFF�������;����������
12~27	��������������ΪFF��
28	ʱ�䳤�� 4;0X00/0XFFû��ʱ����Ϣ��
29~32	ʱ����Ϣ������ʱ�֣�
33	OGM��/��š�

COMMAND_ADDR == 94
0	������
1~20	�ṩ20�����մ�����������

EDIT_ADDR == 94
�༭��
0	ӡ��
1~5	��һ��
6~21	�ڶ���
22~37	������

DIAL_ADDR == 132
0	���ſ�����
.7	1
.6	0/1	START/CONTINUE
.5	0/1	PAUSE/DIAL
.4~.0	->
1~20	���뻺����

TCP_ADDR == 153
0	TCP������
.7	0

1~70
153�ɷ��� �ͽ��� ���û�������

224~255	ͨѶʹ��
****************************************/