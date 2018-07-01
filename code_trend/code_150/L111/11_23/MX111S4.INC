
;//----------------------------------------------------------------------------
;//     Customer Variable Definitions
;//----------------------------------------------------------------------------

CONF            .EQU		0X00       ;// don't move this address location
RESP            .EQU		CONF+0X01  ;// don't move this address location
TMR_SEC         .EQU		CONF+0X02  ;// don't move this address location
TMR_MIN         .EQU		CONF+0X03  ;// don't move this address location
TMR_HOUR        .EQU		CONF+0X04  ;// don't move this address location
TMR_WEEK        .EQU		CONF+0X05  ;// don't move this address location
INDEX		.EQU		CONF+0X06  ;// don't move this address location
BUF1            .EQU		CONF+0X07  ;// don't move this address location
BUF2            .EQU		CONF+0X08  ;// don't move this address location
TMR_DAY		.EQU		CONF+0X09  ;// don't move this address location
TMR_MONTH       .EQU		CONF+0X0A  ;// don't move this address
TMR_YEAR	.EQU		CONF+0X0B  ;// don't move this address
;-------------------------------------------------------------------------------
BUF3		.EQU		CONF+0X0C	;for BTONE/RING_DET
CODECREG0       .equ		CONF+0x0D
CODECREG1       .equ		CONF+0x0E
CODECREG2       .equ		CONF+0x0F

;------------------------------------------------------------------------------
EVENT           .EQU		CONF+0X10
ANN_FG		.EQU		CONF+0X11
KEY             .EQU		CONF+0X12
MSG_ID		.EQU		CONF+0X13	;DSP用的id
MSG_N		.EQU		CONF+0X14
MSG_T		.EQU		CONF+0X15
MBOX_ID		.EQU		CONF+0X16
FILE_ID		.EQU		CONF+0X17	;自己管理的message id
FILE_LEN	.EQU		CONF+0X18	;自己管理的一次录音的条目数-1(初始为0)
BTONE_BUF	.EQU		CONF+0X19	;for BUSY_TONE
RING_ID		.EQU		CONF+0X1A
DTMF_VAL	.EQU		CONF+0X1B
VOI_ATT		.EQU		CONF+0X1C	;LANGUAGE/OGM_ID/RING_CNT/ATT1
PASSWORD	.EQU		CONF+0X1D
PSWORD_TMP	.EQU		CONF+0X1E
LOCACODE	.EQU		CONF+0X1F	;for local code
;-------------以下作时钟计时，在时钟中断里更新,在MAIN中应用及初始化------------
TMR		.EQU		CONF+0X20	;for timer
TMR1		.EQU		CONF+0X21	;for date/time update
TMR2		.EQU		CONF+0X22	;for KEY scan(扫描周期)
TMR3		.EQU		CONF+0X23	;for ring detect

TMR_LED1	.EQU		CONF+0X24	;for LED1
TMR_LED2	.EQU		CONF+0X25	;for LED2
TMR_VOX		.EQU		CONF+0X26	;for vox detect
TMR_BTONE	.EQU		CONF+0X27	;for busy tone
TMR_CTONE	.EQU		CONF+0X28	;for cont tone
TMR_KEY		.EQU		CONF+0X29	;for key scan(按键按下的时间ms)
TMR_BEEP	.EQU		CONF+0X2A	;for beep (BEEP时间ms)
TMR_CPC		.EQU		CONF+0X2B
TMR_BAK		.EQU		CONF+0X2C	;FOR TIMER

INT_TTMP0	.EQU		CONF+0X2D	;//in TIMER,for I/O buffer
INT_TTMP1	.EQU		CONF+0X2E	;don't change in main
INT_TTMP2	.EQU		CONF+0X2F
;-------------------------------------------------------------------------------
VP_QUEUE	.EQU	CONF+0X30	;0X31---0X40，16个声音队列；
VP_ADDR		.EQU	CONF+0X31

MSG_QUEUE	.EQU	CONF+0X41
MSG_ADDR	.EQU	CONF+0X42	;0X42---0X45，8个消息队列(8 Byte)；
;---------------
FUNC_STACK	.EQU	CONF+0X46	;0X46---0X4A，4级流程栈(只用了一级CONF+0X47)；
;-------------------------------------------------------------------------------
LOCACODE1	.EQU		CONF+0X4B	;for local code5(3..0)
CURT_ADR1	.EQU		CONF+0X4C	;Save the value of AR1(Don't change it)
PRO_VAR1	.EQU		CONF+0X4D	;用于计时器计时
PRO_VAR		.EQU		CONF+0X4E	;记录程序状态
MSG		.EQU		CONF+0X4F
;-------------------------------------------------------------------------------
SYSTMP0		.EQU		CONF+0X50
SYSTMP1		.EQU		CONF+0X51
SYSTMP2		.EQU		CONF+0X52
SYSTMP3		.EQU		CONF+0X53
SYSTMP4		.EQU		CONF+0X54
COUNT		.EQU		CONF+0X55	;作为存取数据的计数(偏移)
ADDR_S		.EQU		CONF+0X56	;作为读取数据的起始地址基址
ADDR_D		.EQU		CONF+0X57	;作为存贮数据的目的地址基址
;---------------for send/receive
TRS_FG		.EQU		CONF+0X58
	REFLAG	.EQU	7
	SEFLAG	.EQU	9
SIO_CNT		.EQU		CONF+0X59
TMR_TR		.EQU		CONF+0X5A
RECE_BUF	.EQU		CONF+0X5B
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

RECE_BUF11	.EQU		RECE_QUEUE+0X0B	;0X67
;-------------------------------------------------------------------------------
NEW_ID		.EQU		CONF+0X68	;在MENU调整菜单中将其作为临时变量,在PLAY时作为NEW标记
NEW0		.EQU		CONF+0X69
NEW1		.EQU		CONF+0X6A
NEW2		.EQU		CONF+0X6B
NEW3		.EQU		CONF+0X6C
NEW4		.EQU		CONF+0X6D
NEW5		.EQU		CONF+0X6E
NEW6		.EQU		CONF+0X6F
NEW7		.EQU		CONF+0X70
NEW8		.EQU		CONF+0X71	;此处开始不作NEW标记
NEW9		.EQU		CONF+0X72	
NEW10		.EQU		CONF+0X73
NEW11		.EQU		CONF+0X74
;------------------------------------------------------------------------------
.END
