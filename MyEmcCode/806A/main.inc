
/*****************�Ĵ�������*********************/
intbuf_acc	==	0x10	;acc
intbuf_status	==	0x11	;r3(Status)
intbuf_rsr	==	0x12	;r4(RAM Select Register)
intbuf_ppsr	==	0x13	;r5(Program Page Select Register)

int_temp0	==	0x14
int_temp1	==	0x15

temp0		==	0x16
temp1		==	0x17
temp2		==	0x18
temp3		==	0x19

old_ram		==	0x1a

offset_s	==	0X1b
offset_d	==	0X1c
base_s		==	0X1d
base_d		==	0X1e                            
count		==	0X1f

temp4	==	0X1f	;???????????????????????????????????????????????????????
;-------------------------------------------------------------------------------
/*****************BANK 0 *********************/
msg_queue	==	0X20
msg_queue_start	==	0X21	;0x21..0x28
pro_stack	==	0X29	;0x2A..0x2D	;
msg		==	0X2E	;current system message
pro_var		==	0X2F	;for system status
pro_var1	==	0X30	;for timer counter
event		==	0X31	;action flag for system
tone_queue_head	==	0X32	;����ͷָ��
tone_queue_tail	==	0X33	;����βָ��
LCD_CONTRAST	==	0X34	;

/*****************BANK 1 *********************/
intbuf_cidaddr	==	0x20
intbuf_cidbank	==	0x21

tmr_timer	==	0X20
tmr_timer_bak	==	0X21

SEC_REG		==	0X22
MIN_REG		==	0X23
HOUR_REG	==	0X24
DAY_REG		==	0X25
MON_REG		==	0X26
YEAR_REG	==	0X27
WEEK_REG	==	0X28

tmr_flash	==	0X29
tmr_tone	==	0X2A

/*****************BANK 2 *********************/

/*****************BANK 3 *********************/


/*****************��������***********************/
tone_queue_start	==	0
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