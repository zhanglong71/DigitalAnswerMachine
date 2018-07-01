.NOLIST
;//-----------------------------------------------------------------------------
;//     Customer Variable Definitions
;//-----------------------------------------------------------------------------
DAM_BIOS	.EQU	0x10
;-------------------------------------------------------------------------------
CONF            .EQU	0X00	;// don't move this address location
RESP            .EQU	0X01  	;// don't move this address location

TMR_YEAR	.EQU	CONF+0X03	;save the part of year that over 4
;---
PRO_VAR2	.EQU	CONF+0X04	;for DTMF timer
TMR0		.EQU	CONF+0X05
TMR0_BAK	.EQU	CONF+0X06

BUF1            .EQU	CONF+0X07
BUF2            .EQU	CONF+0X08
BUF3		.EQU	CONF+0X09	;for BTONE/RING_DET

CIDCHECKSUM	.EQU	CONF+0X0A
CID_CHKSUM	.EQU	CONF+0X0B
TMR_PHONE	.EQU	CONF+0X0C
;-------------------------------------------------------------------------------
;CODECREG0       .EQU	CONF+0x0D
;CODECREG1       .EQU	CONF+0x0E
CODECREG2       .EQU	CONF+0x0F
;-------------------------------------------------------------------------------
EVENT           .EQU	CONF+0X10
ANN_FG		.EQU	CONF+0X11
KEY             .EQU	CONF+0X12
KEY_OLD		.EQU	CONF+0X13
MSG_ID		.EQU	CONF+0X14
MSG_N		.EQU	CONF+0X15
MSG_T		.EQU	CONF+0X16
MBOX_ID		.EQU	CONF+0X17
OGM_ID		.EQU	CONF+0X18	;user-data0
BTONE_BUF	.EQU	CONF+0X19	;for BUSY_TONE
RING_ID		.EQU	CONF+0X1A
DTMF_VAL	.EQU	CONF+0X1B
VOI_ATT		.EQU	CONF+0X1C
TAD_ATT1	.EQU	CONF+0X1D
PASSWORD	.EQU	CONF+0X1E
PSWORD_TMP	.EQU	CONF+0X1F
;-------------������ʱ�Ӽ�ʱ����ʱ���ж������,��MAIN��Ӧ�ü���ʼ��------------
TMR		.EQU	CONF+0X20	;for timer
TMR_BAK		.EQU	CONF+0X21	;FOR TIMER
TMR2		.EQU	CONF+0X22	;for KEY scan(ɨ������)
TMR3		.EQU	CONF+0X23	;for ring detect
TMR_VOX		.EQU	CONF+0X24	;for vox detect
TMR_BTONE	.EQU	CONF+0X25	;for busy tone
TMR_CTONE	.EQU	CONF+0X26	;for cont tone
TMR_KEY		.EQU	CONF+0X27	;for key scan(�������µ�ʱ��ms)
TMR_BEEP	.EQU	CONF+0X28	;for beep (BEEPʱ��ms)
TMR_CPC		.EQU	CONF+0X29

TMR_LED1	.EQU	CONF+0X2A	;for LED1
TMR_DELAY	.EQU	CONF+0X2B	;for DELAY(or BEEP)


INT_TTMP0	.EQU	CONF+0X2E	;//in TIMER,for I/O buffer
INT_TTMP1	.EQU	CONF+0X2F	;If interrupt enable don't change in main
;-------------------------------------------------------------------------------
VP_QUEUE	.EQU	CONF+0X30	;0X31---0X40��16���������У�
VP_ADDR		.EQU	CONF+0X31

MSG_QUEUE	.EQU	CONF+0X41
MSG_ADDR	.EQU	CONF+0X42	;0X42---0X45��8����Ϣ����(8 Byte)��
;---------------
FUNC_STACK	.EQU	CONF+0X46	;0X46---0X4A��4������ջ(ֻ����һ��CONF+0X47)��
;-------------------------------------------------------------------------------
PRO_VAR1	.EQU	CONF+0X4B	;���ڼ�ʱ����ʱ
PRO_VAR		.EQU	CONF+0X4C	;��¼����״̬
MSG		.EQU	CONF+0X4D
;-------------------------------------------------------------------------------
SYSTMP0		.EQU	CONF+0X4E
SYSTMP1		.EQU	CONF+0X4F
SYSTMP2		.EQU	CONF+0X50
SYSTMP3		.EQU	CONF+0X51
COUNT		.EQU	CONF+0X52	;��Ϊ��ȡ���ݵļ���(ƫ��)
ADDR_S		.EQU	CONF+0X53	;��Ϊ��ȡ���ݵ���ʼ��ַ��ַ
ADDR_D		.EQU	CONF+0X54	;��Ϊ�������ݵ�Ŀ�ĵ�ַ��ַ
;-------------------------------------------------------------------------------

CURT_ADR1	.EQU	CONF+0X5A
;---------------for iic send/receive
SER_FG		.EQU	CONF+0X5B
SEND_QUEUE	.EQU	CONF+0X5C
RECE_QUEUE	.EQU	CONF+0X5D	;0X60---0X6F��16�����ջ������
RECE_BUF1	.EQU	RECE_QUEUE+0X01
RECE_BUF2	.EQU	RECE_QUEUE+0X02
RECE_BUF3	.EQU	RECE_QUEUE+0X03
RECE_BUF4	.EQU	RECE_QUEUE+0X04
RECE_BUF5	.EQU	RECE_QUEUE+0X05
RECE_BUF6	.EQU	RECE_QUEUE+0X06
RECE_BUF7	.EQU	RECE_QUEUE+0X07
RECE_BUF8	.EQU	RECE_QUEUE+0X08
RECE_BUF9	.EQU	RECE_QUEUE+0X09
RECE_BUF10	.EQU	RECE_QUEUE+0X0A	;0X67
;-------------------------------------------------------------------------------
NEW_ID		.EQU	CONF+0X68	;��MENU�����˵��н�����Ϊ��ʱ����,��PLAYʱ��ΪNEW���
NEW1		.EQU	CONF+0X6A
NEW2		.EQU	CONF+0X6B
NEW3		.EQU	CONF+0X6C
NEW4		.EQU	CONF+0X6D
NEW5		.EQU	CONF+0X6E
NEW6		.EQU	CONF+0X6F
NEW7		.EQU	CONF+0X70
;NEW8		.EQU	CONF+0X71	;�˴���ʼ����NEW���
;-------------------------------------------------------------------------------

LED_L		.EQU	CONF+0X7E
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
.END
