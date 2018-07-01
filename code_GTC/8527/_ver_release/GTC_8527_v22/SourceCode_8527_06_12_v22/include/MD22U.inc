.NOLIST
;-------------------------------------------------------------------------------
;	Customer Variable Definitions
;-------------------------------------------------------------------------------
DAM_BIOS	.EQU	0x10
;-------------------------------------------------------------------------------
CONF            .EQU	0X00		;don't move this address location
RESP            .EQU	0X01  		;don't move this address location
CONF1		.EQU	0X02		;don't move this address location
TMR_YEAR	.EQU	0X03		;save the part of year that over 4

BUF1            .EQU	CONF+0X04
BUF2            .EQU	CONF+0X05
BUF3		.EQU	CONF+0X06	;for BTONE/RING_DET

;PRO_VAR2	.EQU	CONF+0X07	;timer
;TMR0		.EQU	CONF+0X08
;TMR0_BAK	.EQU	CONF+0X09

DENOISE		.EQU	CONF+0X0A	;For De-noise(0..15)
INT_GPAD	.EQU	CONF+0X0B

;-------------------------------------------------------------------------------
ATT_PHONE1	.EQU	CONF+0x0C
ATT_PHONE2	.EQU	CONF+0x0D
ATT_PHONE3	.EQU	CONF+0x0E

CODECREG2       .EQU	CONF+0x0F	;for LOUTSPK(14..10)(9..5)(4..0) vol
;-------------------------------------------------------------------------------
EVENT           .EQU	CONF+0X10
ANN_FG		.EQU	CONF+0X11
KEY             .EQU	CONF+0X12
KEY_OLD		.EQU	CONF+0X13
MSG_ID		.EQU	CONF+0X14
MSG_N		.EQU	CONF+0X15
MSG_T		.EQU	CONF+0X16
ERR_FG		.EQU	CONF+0X17
;FILE_ID	.EQU	CONF+0X18
;FILE_LEN	.EQU	CONF+0X19
BTONE_BUF	.EQU	CONF+0X1A	;for BUSY_TONE
RING_ID		.EQU	CONF+0X1B
DTMF_VAL	.EQU	CONF+0X1C
VOI_ATT		.EQU	CONF+0X1D
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
TMR_DELAY	.EQU	CONF+0X2A	;for DELAY(or BEEP)
CURT_ADR1	.EQU	CONF+0X2B

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
OFFSET_S	.EQU	CONF+0X55	;��Ϊ��ȡ���ݵ���ʼ��ַ��ַ
OFFSET_D	.EQU	CONF+0X56	;��Ϊ�������ݵ�Ŀ�ĵ�ַ��ַ
;---------------------------------------
MSGLED_FG	.EQU	CONF+0X57	;for MSG-LED
;MSGLED_TMR	.EQU	MSGLED_FG+1	;for MSG-LED    ;!!!Can't move from MSGLED_FG
PHOLED_FG	.EQU	CONF+0X59	;for PHONE-LED
;PHOLED_TMR	.EQU	PHOLED_FG+1	;for PHONE-LED    ;!!!Can't move from PHOLED_FG

;-------------------------------------------------------------------------------


;---------------for iic send/receive
SER_FG		.EQU	CONF+0X5B
SEND_QUEUE	.EQU	CONF+0X5C
RECE_QUEUE	.EQU	CONF+0X5D	;0X60---0X6F��16�����ջ������
;-------------------------------------------------------------------------------
ADDR_BUF	.EQU	CONF+0X60	;0x60..0x6F
;-------------------------------------------------------------------------------
RECE_BUF1	.EQU	CONF+0X80	;0x80..0x9F
SEND_BUF1	.EQU	CONF+0XA0	;0xA0..0xBF
;-------------------------------------------------------------------------------


;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
.END
