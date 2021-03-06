.NOLIST
;-------------------------------------------------------------------------------
;	Customer Variable Definitions
;-------------------------------------------------------------------------------
DAM_BIOS	.EQU	0x10
;-------------------------------------------------------------------------------
;CONF            .EQU	0X00		;don't move this address location
COMMAND		.EQU	0X00		;don't move this address location
COMMAND1	.EQU	0X01		;don't move this address location
COMMAND2	.EQU	0X02		;don't move this address location
RESPONSE	.EQU	0X03  		;don't move this address location
RESPONSE1	.EQU	0X04  		;don't move this address location

BUF1            .EQU	COMMAND+0X05
BUF2            .EQU	COMMAND+0X06
BUF3		.EQU	COMMAND+0X07	;for BTONE/RING_DET

TMR_MINUTE	.EQU	COMMAND+0X08	;用作调整时间时保存该时刻的时间
TMR_HOUR	.EQU	COMMAND+0X09	;用作调整时间时保存该时刻的时间
TMR_WEEK	.EQU	COMMAND+0X0A	;用作调整时间时保存该时刻的时间
TMR_YEAR	.EQU	COMMAND+0X0B		;save the part of year that over 4
;-------------------------------------------------------------------------------
ATT_PHONE1	.EQU	COMMAND+0x0C
ATT_PHONE2	.EQU	COMMAND+0x0D
ATT_PHONE3	.EQU	COMMAND+0x0E

PRO_VAR2	.EQU	COMMAND+0x0F
;-------------------------------------------------------------------------------
EVENT           .EQU	COMMAND+0X10
ANN_FG		.EQU	COMMAND+0X11
;KEY             .EQU	COMMAND+0X12
;KEY_OLD		.EQU	COMMAND+0X13
MSG_ID		.EQU	COMMAND+0X14
MSG_N		.EQU	COMMAND+0X15
MSG_T		.EQU	COMMAND+0X16
BTONE_BUF	.EQU	COMMAND+0X17	;for BUSY_TONE
RING_ID		.EQU	COMMAND+0X18
DTMF_VAL	.EQU	COMMAND+0X19
VOI_ATT		.EQU	COMMAND+0X1A
PASSWORD	.EQU	COMMAND+0X1B
LOCACODE	.EQU	COMMAND+0X1C
;--
DAM_ATT		.EQU	COMMAND+0X1D
DAM_ATT0	.EQU	COMMAND+0X1E
DAM_ATT1	.EQU	COMMAND+0X1F
;-------------以下作时钟计时，在时钟中断里更新,在MAIN中应用及初始化------------
TMR		.EQU	COMMAND+0X20	;for timer
TMR_BAK		.EQU	COMMAND+0X21	;FOR TIMER
TMR2		.EQU	COMMAND+0X22	;for KEY scan(扫描周期)
TMR3		.EQU	COMMAND+0X23	;for ring detect
TMR_VOX		.EQU	COMMAND+0X24	;for vox detect
TMR_BTONE	.EQU	COMMAND+0X25	;for busy tone
TMR_CTONE	.EQU	COMMAND+0X26	;for cont tone

TMR_BEEP	.EQU	COMMAND+0X28	;for beep (BEEP时间ms)
TMR_CPC		.EQU	COMMAND+0X29
TMR_DELAY	.EQU	COMMAND+0X2A	;for DELAY(or BEEP)
POLE_TMR	.EQU	COMMAND+0X2B

CURT_ADR1	.EQU	COMMAND+0X2C
INT_GPAD	.EQU	COMMAND+0X2D
INT_TTMP0	.EQU	COMMAND+0X2E	;//in TIMER,for I/O buffer
INT_TTMP1	.EQU	COMMAND+0X2F	;If interrupt enable don't change in main
;-------------------------------------------------------------------------------
VP_QUEUE	.EQU	COMMAND+0X30	;0X31---0X40，16个声音队列；
VP_ADDR		.EQU	COMMAND+0X31

MSG_QUEUE	.EQU	COMMAND+0X41
MSG_ADDR	.EQU	COMMAND+0X42	;0X42---0X45，8个消息队列(8 Byte)；
;---------------
FUNC_STACK	.EQU	COMMAND+0X46	;0X46---0X4A，4级流程栈(只用了一级CONF+0X47)；
;-------------------------------------------------------------------------------
PRO_VAR1	.EQU	COMMAND+0X4B	;用于计时器计时
PRO_VAR		.EQU	COMMAND+0X4C	;记录程序状态
MSG		.EQU	COMMAND+0X4D
;-------------------------------------------------------------------------------
SYSTMP0		.EQU	COMMAND+0X4E
SYSTMP1		.EQU	COMMAND+0X4F
SYSTMP2		.EQU	COMMAND+0X50
SYSTMP3		.EQU	COMMAND+0X51
COUNT		.EQU	COMMAND+0X52	;作为存取数据的计数(偏移)
ADDR_S		.EQU	COMMAND+0X53	;作为读取数据的起始地址基址
ADDR_D		.EQU	COMMAND+0X54	;作为存贮数据的目的地址基址
OFFSET_S	.EQU	COMMAND+0X55	;作为读取数据的起始地址基址
OFFSET_D	.EQU	COMMAND+0X56	;作为存贮数据的目的地址基址
;---------------------------------------
MSGLED_FG	.EQU	COMMAND+0X57	;for MSG-LED
;MSGLED_TMR	.EQU	MSGLED_FG+1	;for MSG-LED    ;!!!Can't move from MSGLED_FG
PHOLED_FG	.EQU	COMMAND+0X59	;for PHONE-LED
;PHOLED_TMR	.EQU	PHOLED_FG+1	;for PHONE-LED    ;!!!Can't move from PHOLED_FG

;---------------for iic send/receive
PSWORD_TMP	.EQU	COMMAND+0X5B	;Psword/RAWCid-time-Offset
LOCODE_TMP	.EQU	COMMAND+0X5C	;Locode/RAWCid-num-name-Offset

SER_FG		.EQU	COMMAND+0X5D
CbBUSY		.EQU   	6		;bi6 = IIC busy can`t receive command	
;-
SEND_QUEUE	.EQU	COMMAND+0X5E
RECE_QUEUE	.EQU	COMMAND+0X5F	;0X60---0X6F，16个发收缓冲队列
;-------------------------------------------------------------------------------
CidCheckSum	.EQU	COMMAND+0X60
CidLength	.EQU	COMMAND+0X61
CidFlag		.EQU	COMMAND+0X62	;for MDMF only(0x01-timedate, 0x02-number, 0x03-DDN, 0x04-no number, 0x06- , 0x07-name ,0x08-no name ,0xB-)
CidSubLength	.EQU	COMMAND+0X63

;---------
TMR_TIMER	.EQU	COMMAND+0X64	;For timer2
TMR_TIMER_BAK	.EQU	COMMAND+0X65	;For timer2
;-------------------------------------------------------------------------------



;PAGE1--------------------------------------------------------------------------
CidBuffer	.EQU	COMMAND+0X80	;0x80 - 0x9F(32words - 64Bytes)CID Rawdata
CidData		.EQU	COMMAND+0XA0	;0xA0 - 0xBF(32words - 64Bytes)CID cooked
RECE_BUF1	.EQU	COMMAND+0XC0	;0XC0---0XDF(32words - 64Bytes)接收缓冲队列最低地址
SEND_BUF1	.EQU	COMMAND+0XE0	;0XE0---0XFF(32words - 64Bytes)发送缓冲队列最低地址
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
.END
