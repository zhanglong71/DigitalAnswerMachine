
;//-----------------------------------------------------------------------------
;//     Customer Variable Definitions
;//-----------------------------------------------------------------------------
DAM_BIOS	.EQU	0x10
;-------------------------------------------------------------------------------
CONF            .EQU		0X00	;// don't move this address location
RESP            .EQU		0X01  	;// don't move this address location
;TMR_SEC	.EQU		CONF+0X02 
;TMR_MIN	.EQU		CONF+0X03 
;TMR_HOUR	.EQU		CONF+0X04
TMR_TEST	.EQU		CONF+0X04
;TMR_WEEK	.EQU		CONF+0X05
;INDEX		.EQU		CONF+0X06
BUF1            .EQU		CONF+0X07
BUF2            .EQU		CONF+0X08
;TMR_DAY	.EQU		CONF+0X09
;TMR_MONTH	.EQU		CONF+0X0A
;TMR_YEAR	.EQU		CONF+0X0B
CIDCHECKSUM	.EQU		CONF+0X0B
CID_CHKSUM	.EQU		CONF+0X0B
;-------------------------------------------------------------------------------
BUF3		.EQU		CONF+0X0C	;for BTONE/RING_DET
;CODECREG0       .EQU		CONF+0x0D
TAD_ATT       .EQU		CONF+0x0E
CODECREG2       .EQU		CONF+0x0F
;------------------------------------------------------------------------------
EVENT           .EQU		CONF+0X10
ANN_FG		.EQU		CONF+0X11
KEY             .EQU		CONF+0X12
KEY_OLD 	.EQU		CONF+0X13
MSG_ID		.EQU		CONF+0X14
MSG_N		.EQU		CONF+0X15
MSG_T		.EQU		CONF+0X16
MBOX_ID		.EQU		CONF+0X17
FILE_ID		.EQU		CONF+0X18
FILE_LEN	.EQU		CONF+0X19	;一次录音的条目数-1(初始为0)
BTONE_BUF	.EQU		CONF+0X1A	;for BUSY_TONE
RING_ID		.EQU		CONF+0X1B
DTMF_VAL	.EQU		CONF+0X1C
VOI_ATT		.EQU		CONF+0X1D	;LANGUAGE/OGM_ID/RING_CNT/ATT1
PASSWORD	.EQU		CONF+0X1E
PSWORD_TMP	.EQU		CONF+0X1F
;-------------以下作时钟计时，在时钟中断里更新,在MAIN中应用及初始化------------
TMR		.EQU		CONF+0X20	;for timer
TMR_BAK		.EQU		CONF+0X21	;FOR TIMER
TMR2		.EQU		CONF+0X22	;for KEY scan(扫描周期)
TMR3		.EQU		CONF+0X23	;for ring detect
TMR_VOX		.EQU		CONF+0X24	;for vox detect
TMR_BTONE	.EQU		CONF+0X25	;for busy tone
TMR_CTONE	.EQU		CONF+0X26	;for cont tone
TMR_KEY		.EQU		CONF+0X27	;for key scan(按键按下的时间ms)
TMR_BEEP	.EQU		CONF+0X28	;for beep (BEEP时间ms)
TMR_CPC		.EQU		CONF+0X29


TMR_LED1	.EQU		CONF+0X24	;for LED1
;TMR_LED2	.EQU		CONF+0X25	;for LED2

INT_TTMP0	.EQU		CONF+0X2E	;//in TIMER,for I/O buffer
INT_TTMP1	.EQU		CONF+0X2F	;If interrupt enable don't change in main
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
COUNT		.EQU		CONF+0X52	;作为存取数据的计数(偏移)
ADDR_S		.EQU		CONF+0X53	;作为读取数据的起始地址基址
ADDR_D		.EQU		CONF+0X54	;作为存贮数据的目的地址基址
;-------------------------------------------------------------------------------
;---------------for iic send/receive
IicCnt		.EQU		CONF+0X5A
IicDataLength	.EQU		CONF+0X5B
;-------------------------------------------------------------------------------
RECE_QUEUE	.EQU		CONF+0X5C	;0X60---0X6F，16个发收缓冲队列
RECE_BUF1	.EQU		RECE_QUEUE+0X01
RECE_BUF2	.EQU		RECE_QUEUE+0X02
RECE_BUF3	.EQU		RECE_QUEUE+0X03
RECE_BUF4	.EQU		RECE_QUEUE+0X04
RECE_BUF5	.EQU		RECE_QUEUE+0X05
RECE_BUF6	.EQU		RECE_QUEUE+0X06
RECE_BUF7	.EQU		RECE_QUEUE+0X07
RECE_BUF8	.EQU		RECE_QUEUE+0X08
RECE_BUF9	.EQU		RECE_QUEUE+0X09
RECE_BUF10	.EQU		RECE_QUEUE+0X0A	;0X66
;-------------------------------------------------------------------------------
NEW_ID		.EQU		CONF+0X68	;在MENU调整菜单中将其作为临时变量,在PLAY时作为NEW标记,SpeakerPhone时作为拔号号码
NEW1		.EQU		CONF+0X6A
NEW2		.EQU		CONF+0X6B
NEW3		.EQU		CONF+0X6C
NEW4		.EQU		CONF+0X6D
NEW5		.EQU		CONF+0X6E
NEW6		.EQU		CONF+0X6F
NEW7		.EQU		CONF+0X70

NEW8		.EQU		CONF+0X71	;此处开始不作NEW标记
;-------------------------------------------------------------------------------
PHONE_ATT	.EQU		CONF+0X7B
LED_H		.EQU		CONF+0X7C
LED_L		.EQU		CONF+0X7D
DugRam1		.EQU		CONF+0X7E
DugRam2		.EQU		CONF+0X7F
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
.END
