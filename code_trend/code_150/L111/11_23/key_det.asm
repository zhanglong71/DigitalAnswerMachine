.LIST
KEY_DOWN	.EQU		80	;按键被识别的最短按下时间
KEY_PLUSE	.EQU		400	;按键按下被识别,发连续脉冲的时间间隔

.INCLUDE mx111S4.INC
.INCLUDE reg2523b.inc
.INCLUDE CONST.INC
.extern	INT_STOR_MSG
.global	KEYSCAN_CHK
.org 0xfc00	;s2中的用0xfe00--s4中的用0xfc00

KEYSCAN_CHK:
INT_SP00:
	CALL	KEYTOMSG
	BS	ACZ,INT_SP00_2		;no key pressed ?
	
	LAC	TMR_KEY
	SBHK	KEY_DOWN
	BZ	ACZ,INT_SP00_0
	
	LAC	INT_TTMP1
	ADHK	0X030
	CALL	INT_STOR_MSG		;按下消息0X30(KEY_DOWN ms防抖)
	BS	B1,INT_SP00_2
INT_SP00_0:
	
	LAC	TMR_KEY
	SBHL	2000
	BZ	ACZ,INT_SP00_1
	
	LAC	INT_TTMP1
	ADHK	0X010
	CALL	INT_STOR_MSG		;长按2second消息0X10
	BS	B1,INT_SP00_2
INT_SP00_1:
	LAC	TMR_KEY
	SBHL	1000
	BS	SGN,INT_SP00_2		;要求按下时长大于1000ms
	
	LAC	TMR_KEY
	ANDL	0X01FF
	BZ	ACZ,INT_SP00_2
	
	LAC	INT_TTMP1
	ADHK	0X020
	CALL	INT_STOR_MSG		;长按每512ms消息0X20(512*2+32ms,512*3+32ms,...,)	
;---------------
INT_SP00_2:	
;---------------
        IN      INT_TTMP1,OPTR
        LAC     INT_TTMP1
        ANDL    0X7800
        SAH     INT_TTMP1

        LAC	TMR2
        BS	ACZ,INT_SP10		;TMR2=0ms
        SBHK	0X04
	BS	ACZ,INT_SP20		;TMR2=4ms
	SBHK	0X04
	BS	ACZ,INT_SP30		;TMR2=8ms
	SBHK	0X04
	BS	ACZ,INT_SP40		;TMR2=12ms
	BS	B1,INT_SP_IN
INT_SP40:				;//scan the 4th(OPT.15---KEY0..3);//  key set
	LAC	INT_TTMP1
        ORL	0X0700
        SAH	INT_TTMP1
        OUT	INT_TTMP1,OPTR
        NOP
        BS	B1,INT_SP_IN
INT_SP30:                         	;//scan the 3rd(OPT.10---KEY0..3);//  key set
        LAC	INT_TTMP1
        ORL	0X8300
        SAH	INT_TTMP1
        OUT	INT_TTMP1,OPTR
        NOP
        BS	B1,INT_SP_IN
INT_SP20:				;// scan the 2nd(OPT.9---KEY4..7)
        LAC	INT_TTMP1
        ORL	0X8500
        ;OR	LED_H
        SAH     INT_TTMP1
        OUT     INT_TTMP1,OPTR
        NOP
	BS	B1,INT_SP_IN      
INT_SP10:                         	;// scan the 1st(OPT.8---KEY8..11)
        LAC     INT_TTMP1
        ORL	0X8600
        ;OR	LED_L
        SAH     INT_TTMP1
        OUT     INT_TTMP1,OPTR
        NOP
	BS	B1,INT_SP_IN
;---
INT_SP_IN:     
INT_SP40_IN:
	LAC	TMR2
	SBHK	14
	BZ	ACZ,INT_SP30_IN
	
        IN	INT_TTMP1,IPTR
        LAC	INT_TTMP1
	SFL	12
        SAH	INT_TTMP1
        LAC	KEY
        ANDL	0X0FFF
        OR	INT_TTMP1
        SAH	KEY
        BS	B1,DspModeINT_STMR_END	;SAVE the 4th key set in KEY(3..0)
	              
INT_SP30_IN:
	LAC	TMR2
	SBHK	10
	BZ	ACZ,INT_SP20_IN
	
        IN	INT_TTMP1,IPTR
        LAC	INT_TTMP1
        ANDK	0X0F
        SAH	INT_TTMP1
        LAC	KEY
        ANDL	0XFFF0
        OR	INT_TTMP1
        SAH	KEY
        BS	B1,DspModeINT_STMR_END	;SAVE the 3rd key set in KEY(3..0)
	
INT_SP20_IN:
	LAC	TMR2
	SBHK	6
	BZ	ACZ,INT_SP10_IN
	
        IN      INT_TTMP1,IPTR		;read in the 2nd key set
        LAC     INT_TTMP1
        ANDK    0X0F
        SFL     4
        SAH     INT_TTMP1
        LAC     KEY               	;update the 2nd key set in KEY(7..4)
        ANDL    0XFF0F
        OR      INT_TTMP1
        SAH     KEY
        BS	B1,DspModeINT_STMR_END
                                  	;display the 1st digit and scan the 1st
INT_SP10_IN:
	LAC	TMR2
	SBHK	2
	BZ	ACZ,DspModeINT_STMR_END
	
        IN      INT_TTMP1,IPTR		;read in the 1st key set
        LAC     INT_TTMP1
        ANDK    0X0F
        SFL     8
        SAH     INT_TTMP1
        LAC     KEY               	;update the 1st key set in KEY(11..8)
        ANDL    0XF0FF
        OR      INT_TTMP1
        SAH     KEY
        BS	B1,DspModeINT_STMR_END
DspModeINT_STMR_END:
	;LACL	0XF000
	;OR	KEY
	;SAH	KEY
			
	LAC	KEY
	ANDL	0X0FFF
	SBHL	0X0FFF
	BS	ACZ,NO_KEY_PRESSED

	LAC	TMR_KEY
	ADHK	1
	SAH	TMR_KEY
	
	LAC	TMR_KEY
	SBHL	3073
	BS	SGN,DspModeINT_STMR_END1
	
	LAC	TMR_KEY
	SBHL	KEY_PLUSE		;此数的大小和TMR_KEY最大值与长按时的脉冲消息有关
	SAH	TMR_KEY
DspModeINT_STMR_END1:		
	BS		B1,INT_KEYSCAN_END			
NO_KEY_PRESSED:
	;LAC	TMR_KEY
	;BS	ACZ,NO_KEY_PRESSED1
	LAC	TMR_KEY
	SBHK	KEY_DOWN
	BS	SGN,NO_KEY_PRESSED1	;按下时间小于KEY_DOWN视为误操作
	
	LAC	INT_TTMP2
	CALL	INT_STOR_MSG		;released KEY
NO_KEY_PRESSED1:	
	LACK	0
	SAH	TMR_KEY

INT_KEYSCAN_END:

KEYSCAN_CHK_END:
	RET
;-------------------------------------------------------------------------------
;	Funtion : transmit the address of bit=0 to messages
;	input : KEY
;	output: ACCH
;			INT_TTMP1=INT_TTMP2=the address of key bit=0(1..12)key pressed
;			 =0 no key pressed
;-------------------------------------------------------------------------------
KEYTOMSG:
	LAC	KEY
	SAH	INT_TTMP2
	
	LACK	1
	SAH	INT_TTMP1	;计数
	
	BIT	INT_TTMP2,0
	BZ	TB,KEYTOMSG_END
KEYTOMSG_LOOP:
	LAC	INT_TTMP1
	SBHK	12
	BS	SGN,KEYTOMSG1
	
	LACK	0
	SAH	INT_TTMP1
	SAH	INT_TTMP2	;no key pressed
	RET
KEYTOMSG1:	
	LAC	INT_TTMP1
	ADHK	1
	SAH	INT_TTMP1

	LAC	INT_TTMP2
	SFR	1
	SAH	INT_TTMP2
	
	BIT	INT_TTMP2,0	;对应按键按下了吗?
	BS	TB,KEYTOMSG_LOOP
KEYTOMSG_END:
	LAC	INT_TTMP1
	SAH	INT_TTMP2
	
	RET
;-------------------------------------------------------------------------------
.END
