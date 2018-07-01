.NOLIST
;PAGE0--------------------------------------------------------------------------
;	Customer Variable Definitions
;PAGE0--------------------------------------------------------------------------
DAM_BIOS	.EQU	0x10
;-------------------------------------------------------------------------------
CONF            .EQU	0X00		;don't move this address location
RESP            .EQU	0X01  		;don't move this address location
CONF1		.EQU	0X02		;don't move this address location
TMR_YEAR	.EQU	0X03		;save the part of year that over 4

BUF1            .EQU	CONF+0X04
BUF2            .EQU	CONF+0X05
BUF3		.EQU	CONF+0X06	;for BTONE/RING_DET

PRO_VAR2	.EQU	CONF+0X07	;timer
TMR0		.EQU	CONF+0X08
TMR0_BAK	.EQU	CONF+0X09

TMR_LINE	.EQU	CONF+0X0A
;---------------
CID_CHKSUM	.EQU	CONF+0X0C
CidLength	.EQU	CONF+0X0D

OGM_ID		.EQU	CONF+0X0E
;-------------------------------------------------------------------------------

CODECREG2       .EQU	CONF+0x0F	;for SPK vol
;-------------------------------------------------------------------------------
EVENT           .EQU	CONF+0X10
ANN_FG		.EQU	CONF+0X11
CID_FG		.EQU	CONF+0X12
PASSWORD	.EQU	CONF+0X13
LOCACODE	.EQU	CONF+0X14	;for local code
DAM_ATT		.EQU	CONF+0X15
DAM_ATT0	.EQU	CONF+0X16
DAM_ATT1	.EQU	CONF+0X17
MSG_ID		.EQU	CONF+0X18
MSG_N		.EQU	CONF+0X19
MSG_T		.EQU	CONF+0X1A
MIDI_ID		.EQU	CONF+0X1B
MIDI_BUF	.EQU	CONF+0X1C
BTONE_BUF	.EQU	CONF+0X1D	;for BUSY_TONE
DTMF_VAL	.EQU	CONF+0X1E

;-------------以下作时钟计时，在时钟中断里更新,在MAIN中应用及初始化------------
TMR		.EQU	CONF+0X20	;for timer
TMR_BAK		.EQU	CONF+0X21	;FOR TIMER
TMR2		.EQU	CONF+0X22	;for KEY scan(扫描周期)
TMR_KEY		.EQU	CONF+0X23	;for key scan(按键按下的时间ms)
TMR3		.EQU	CONF+0X24	;for ring detect
TMR_VOX		.EQU	CONF+0X25	;for vox detect
TMR_BTONE	.EQU	CONF+0X26	;for busy tone
TMR_CTONE	.EQU	CONF+0X27	;for cont tone

TMR_BEEP	.EQU	CONF+0X28	;for beep (BEEP时间ms)
TMR_CPC		.EQU	CONF+0X29
;---
TMR_LED1	.EQU	CONF+0X2A	;for LED1
TMR_DELAY	.EQU	CONF+0X2B	;for DELAY(or BEEP)
;---

RING_ID		.EQU	CONF+0X2C
TMR_MIDI	.EQU	CONF+0X2D	;for midi write/read
INT_TTMP0	.EQU	CONF+0X2E	;//in TIMER,for I/O buffer
INT_TTMP1	.EQU	CONF+0X2F	;If interrupt enable don't change in main
;-------------------------------------------------------------------------------
VP_QUEUE	.EQU	CONF+0X30	;0X31---0X40，16个声音队列；
VP_ADDR		.EQU	CONF+0X31

MSG_QUEUE	.EQU	CONF+0X41
MSG_ADDR	.EQU	CONF+0X42	;0X42---0X45，8个消息队列(8 Byte)；
;---------------
FUNC_STACK	.EQU	CONF+0X46	;0X46---0X4A，4级流程栈(只用了一级CONF+0X47)；
;-------------------------------------------------------------------------------
PRO_VAR1	.EQU	CONF+0X4B	;用于计时器计时
PRO_VAR		.EQU	CONF+0X4C	;记录程序状态
MSG		.EQU	CONF+0X4D
;-------------------------------------------------------------------------------
SYSTMP0		.EQU	CONF+0X4E
SYSTMP1		.EQU	CONF+0X4F
SYSTMP2		.EQU	CONF+0X50
SYSTMP3		.EQU	CONF+0X51
COUNT		.EQU	CONF+0X52	;作为存取数据的计数
OFFSET_S	.EQU	CONF+0X53	;作为取数据时相对基址偏移
OFFSET_D	.EQU	CONF+0X54	;作为存数据时相对基址偏移
ADDR_S		.EQU	CONF+0X55	;作为读取数据的起始地址基址
ADDR_D		.EQU	CONF+0X56	;作为存贮数据的目的地址基址

PSWORD_TMP	.EQU	CONF+0X58
LOCODE_TMP	.EQU	CONF+0X59
;-------------------------------------------------------------------------------
LED_L		.EQU	CONF+0X5B
CURT_ADR1	.EQU	CONF+0X5C
;---------------for iic send/receive
SER_FG		.EQU	CONF+0X5D

SEND_QUEUE	.EQU	CONF+0X5E
RECE_QUEUE	.EQU	CONF+0X5F
RECE_BUF1	.EQU	RECE_QUEUE+0X01	;0X60---0X7F(64Byte个发收缓冲队列)
;===============================================================================
;PAGE1--------------------------------------------------------------------------
CidBuffer	.EQU	CONF+0X80	;0x80 - 0x9F(32words - 64Bytes)CID data
CidData		.EQU	CONF+0XA0	;0xA0 - 0xBF(32words - 64Bytes)CID cooked
;-------------------------------------------------------------------------------
.END
