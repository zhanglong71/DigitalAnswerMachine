
;-------------------------------------------------------------------------------
;	Customer Variable Definitions
;-------------------------------------------------------------------------------
;00-page0-0000000000000000000000000000000000000000000000000000000000000000000000
CONF            .EQU		0X00       	;don't move this address location
RESP            .EQU		CONF+0X01  	;don't move this address location
;CONF1		.EQU		CONF+0X02 
BUF1            .EQU		CONF+0X03  	;don't move this address location
BUF2            .EQU		CONF+0X04  	;don't move this address location
BUF3		.EQU		CONF+0X05	;for BTONE/RING_DET
INDEX		.EQU		CONF+0X06  	;don't move this address location

VOP_FG		.EQU		CONF+0X07

TMR_MINUTE	.EQU		CONF+0X08	;用作调整时间时保存该时刻的时间
TMR_HOUR	.EQU		CONF+0X09	;用作调整时间时保存该时刻的时间
TMR_DAY		.EQU		CONF+0X0A	;用作调整时间时保存该时刻的时间
TMR_MONTH	.EQU		CONF+0X0B	;用作调整时间时保存该时刻的时间
TMR_WEEK	.EQU		CONF+0X0C	;用作调整时间时保存该时刻的时间

INT_EVENT	.EQU		CONF+0X0F	;change it in interupt only
;------------------------------------------------------------------------------
EVENT           .EQU		CONF+0X10
ANN_FG		.EQU		CONF+0X11
KEY             .EQU		CONF+0X12
KEY_OLD		.EQU		CONF+0X13	;For key scan
MSG_ID		.EQU		CONF+0X14	;message id
MSG_N		.EQU		CONF+0X15
MSG_T		.EQU		CONF+0X16
MBOX_ID		.EQU		CONF+0X17
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
TMR_DELAY	.EQU		CONF+0X21	;for date/time update
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
ADDR_S		.EQU		CONF+0X56	;作为读取数据的起始基址
ADDR_D		.EQU		CONF+0X57	;作为存贮数据的目的基址
OFFSET_S	.EQU		CONF+0X58	;作为读取数据的起始偏移
OFFSET_D	.EQU		CONF+0X59	;作为存贮数据的目的偏移
;---------------for send/receive
SER_FG		.EQU		CONF+0X5A
SEND_QUEUE	.EQU		CONF+0X5B
RECE_QUEUE	.EQU		CONF+0X5C
;-------------------------------------------------------------------------------
NEW_ID		.EQU		CONF+0X5D
;NEW1		.EQU		NEW_ID+0X01
;NEW2		.EQU		NEW_ID+0X02
;NEW3		.EQU		NEW_ID+0X03
;NEW4		.EQU		NEW_ID+0X04
;NEW5		.EQU		NEW_ID+0X05
;NEW6		.EQU		NEW_ID+0X06
;NEW7		.EQU		NEW_ID+0X07

;11-page1-1111111111111111111111111111111111111111111111111111111111111111111111
TEL_RAM		.EQU		CONF+0X80
;0x80 - 0x9F	;for CID/TEL		;0x80 - 0x9F(32words - 64Bytes)CID data
;---!!!大规模数据的临时存放点;主要是来电/电话本数据
;---收CID时	
;			(TEL_RAM..TEL_RAM+2),		以0xff结尾(3word - flag)
;			(TEL_RAM+3..TEL_RAM+11),	以0xff结尾(9word - num)
;			(TEL_RAM+12..TEL_RAM+20),	以0xff结尾(9word - name)
;---Edit时	
;			(TEL_RAM..TEL_RAM+1),		以0xff结尾(2word - flag)
;			(TEL_RAM+2..TEL_RAM+10),	以0xff结尾(9word - num)
;			(TEL_RAM+12..TEL_RAM+20),	以0xff结尾(9word - name)
;-------------------------------------------------------------------------------
RECE_BUF1	.EQU		CONF+0XA0	;0xA0 - 0xBF(32words - 64Bytes)CID data
;RECE_BUF2	.EQU		RECE_BUF1+0X01
;RECE_BUF3	.EQU		RECE_BUF1+0X02
;RECE_BUF4	.EQU		RECE_BUF1+0X03
;RECE_BUF5	.EQU		RECE_BUF1+0X04
;RECE_BUF6	.EQU		RECE_BUF1+0X05
;RECE_BUF7	.EQU		RECE_BUF1+0X06
;RECE_BUF8	.EQU		RECE_BUF1+0X07
;RECE_BUF9	.EQU		RECE_BUF1+0X08
;RECE_BUF10	.EQU		RECE_BUF1+0X09
;RECE_BUF11	.EQU		RECE_BUF1+0X0A	;0XAA
test_buf	.EQU		CONF+0XC0
;-------------------------------------------------------------------------------
.END
