
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
FLAG2531_0      .equ		CONF+0x0C
CODECREG0       .equ		CONF+0x0D
CODECREG1       .equ		CONF+0x0E
CODECREG2       .equ		CONF+0x0F

;------------------------------------------------------------------------------
EVENT           .EQU		CONF+0X10
ANN_FG		.EQU		CONF+0X11
KEY             .EQU		CONF+0X12
BUF3		.EQU		CONF+0X13
MSG_ID		.EQU		CONF+0X14
MSG_N		.EQU		CONF+0X15
MSG_T		.EQU		CONF+0X16
FILE_ID		.EQU		CONF+0X17	;for usr_dat/index-0(待机时存放的是录音时要用的USE_DAT)
BTONE_BUF	.EQU		CONF+0X18	;for BUSY_TONE
RING_ID		.EQU		CONF+0X19
RING_ID_BAK	.EQU		CONF+0X1A
PASSWORD	.EQU		CONF+0X1B
LANGUAGE	.EQU		CONF+0X1C
DTMF_VAL	.EQU		CONF+0X1D
VOI_ATT		.EQU		CONF+0X1E
VPLEN		.EQU		CONF+0X1F

;-------------以下作时钟计时，在时钟中断里更新,在MAIN中应用及初始化------------
TMR		.EQU		CONF+0X20	;for timer
TMR1		.EQU		CONF+0X21	;for time update
TMR2		.EQU		CONF+0X22	;for KEY scan(扫描周期)
TMR3		.EQU		CONF+0X23	;for ring detect

TMR_LED		.EQU		CONF+0X24	;FOR LED_TIMER
TMR_LED_BAK	.EQU		CONF+0X25	;FOR LED_TIMER
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
;------------------------------------------------------------------------------
NEW0		.EQU		CONF+0X30
NEW1		.EQU		CONF+0X31
NEW2		.EQU		CONF+0X32
NEW3		.EQU		CONF+0X33
NEW4		.EQU		CONF+0X34
NEW5		.EQU		CONF+0X35
NEW6		.EQU		CONF+0X36
NEW7		.EQU		CONF+0X37
NEW_ID		.EQU		CONF+0X38

RING_CNT	.EQU		CONF+0X3A	;记录来铃次数(8秒内不来铃则表示拔号方已挂机)
PRO_VAR2	.EQU		CONF+0X3B
FILE_LEN	.EQU		CONF+0X3C	;一次录音的条目数-1(初始为0)
MSG		.EQU		CONF+0X3D
PRO_VAR		.EQU		CONF+0X3E
PRO_VAR1	.EQU		CONF+0X3F
;------------------------------------------------------------------------------
VP_QUEUE	.EQU	CONF+0X40	;0X41---0X50，16个声音队列；
VP_ADDR		.EQU	CONF+0X41

MSG_QUEUE	.EQU	CONF+0X51	;0X52---0X59，8个消息队列；
MSG_ADDR	.EQU	CONF+0X52
;---------------
FUNC_STACK	.EQU	CONF+0X5A	;0X5A---0X5D，4级流程栈；

;------------------------------------------------------------------------------

SYSTMP0		.EQU		CONF+0X5E
SYSTMP1		.EQU		CONF+0X5F
;---------------
SYSTMP2		.EQU		CONF+0X60
SYSTMP3		.EQU		CONF+0X61
SYSTMP4		.EQU		CONF+0X62
SYSTMP5		.EQU		CONF+0X63
SYSTMP          .EQU		CONF+0X64
;---------------for send/receive
TRS_FG		.EQU		CONF+0X65
	REFLAG	.EQU	7
	SEFLAG	.EQU	9
C_RSIO1		.EQU		CONF+0X66
SIO_CNT		.EQU		CONF+0X67
TMR_TR		.EQU		CONF+0X68
RECE_BUF	.EQU		CONF+0X69
RECE_BUF1	.EQU		CONF+0X6A
RECE_BUF2	.EQU		CONF+0X6B
RECE_BUF3	.EQU		CONF+0X6C
RECE_BUF4	.EQU		CONF+0X6D
RECE_BUF5	.EQU		CONF+0X6E
;------------------------------------------------------------------------------
RECE_BUF6	.EQU		CONF+0X6F
RECE_BUF7	.EQU		CONF+0X70
RECE_BUF8	.EQU		CONF+0X71
RECE_BUF9	.EQU		CONF+0X72
RECE_BUF10	.EQU		CONF+0X73
RECE_BUF11	.EQU		CONF+0X74
RECE_BUF12	.EQU		CONF+0X75
RECE_BUF13	.EQU		CONF+0X76

RECE_QUEUE	.EQU		CONF+0X77	;0X69---0X76，13个发收缓冲队列；

;CLK_CN	.EQU	CONF+0X78	;for text
;------------------------------------------------------------------------------
.END
