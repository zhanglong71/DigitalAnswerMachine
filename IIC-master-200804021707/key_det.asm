.LIST
KEY_DOWN	.EQU		80	;按键被识别的最短按下时间
KEY_PLUSE	.EQU		400	;按键按下被识别,发连续脉冲的时间间隔

KEYSCAN_CHK:
	
	LAC	KEY
	CALL	KEYTOMSG
	SAH	INT_TTMP1
	SAH	INT_TTMP2
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
	lipk	8

        IN      INT_TTMP1,GPAD
        LAC     INT_TTMP1
        ANDL    0XF000
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
INT_SP40:				;scan the 4th(GPAD.11---KEY15..12)
	LAC	INT_TTMP1
        ORL	0X0700
        OR	LED4	;???????????????
        SAH	INT_TTMP1
        OUT	INT_TTMP1,GPAD
        ADHK	0
        BS	B1,INT_SP_IN
INT_SP30:                         	;scan the 3rd(GPAD.10---KEY0..3)
        LAC	INT_TTMP1
        ORL	0X0B00
	OR	LED3	;???????????????
        SAH	INT_TTMP1
        OUT	INT_TTMP1,GPAD
        ADHK	0
        BS	B1,INT_SP_IN
INT_SP20:				;scan the 2nd(GPAD.9---KEY4..7)
        LAC	INT_TTMP1
        ORL	0X0D00
	OR	LED2	;???????????????
        SAH     INT_TTMP1
        OUT     INT_TTMP1,GPAD
        ADHK	0
	BS	B1,INT_SP_IN      
INT_SP10:                         	;scan the 1st(GPAD.8---KEY8..11)
        LAC     INT_TTMP1
        ORL	0X0E00
	OR	LED1	;???????????????
        SAH     INT_TTMP1
        OUT     INT_TTMP1,GPAD
        ADHK	0
	BS	B1,INT_SP_IN
;---
INT_SP_IN:     
INT_SP40_IN:
	LAC	TMR2
	SBHK	13
	BZ	ACZ,INT_SP30_IN
	
        IN	INT_TTMP1,GPAD
        LAC	INT_TTMP1
	ANDL	0XF000
        SAH	INT_TTMP1
        LAC	KEY
        ANDL	0X0FFF
        OR	INT_TTMP1
        SAH	KEY
        BS	B1,DspModeINT_STMR_END	;SAVE the 4th key set in KEY(15..12)
	              
INT_SP30_IN:
	LAC	TMR2
	SBHK	9
	BZ	ACZ,INT_SP20_IN
	
        IN	INT_TTMP1,GPAD
        LAC	INT_TTMP1
        SFR	4
        ANDL	0X0F00
        SAH	INT_TTMP1
        LAC	KEY
        ANDL	0XF0FF
        OR	INT_TTMP1
        SAH	KEY
        BS	B1,DspModeINT_STMR_END	;SAVE the 3rd key set in KEY(11..8)
	
INT_SP20_IN:
	LAC	TMR2
	SBHK	5
	BZ	ACZ,INT_SP10_IN
	
        IN      INT_TTMP1,GPAD        		;read in the 2nd key set
        LAC     INT_TTMP1
        SFR	8
        ANDL    0X00F0
        SAH     INT_TTMP1
        LAC     KEY               	;update the 2nd key set in KEY(7..4)
        ANDL    0XFF0F
        OR      INT_TTMP1
        SAH     KEY
        BS	B1,DspModeINT_STMR_END
                                  ;// display the 1st digit and scan the 1st
INT_SP10_IN:
	LAC	TMR2
	SBHK	1
	BZ	ACZ,DspModeINT_STMR_END
	
        IN      INT_TTMP1,GPAD        	;// read in the 1st key set
        LAC     INT_TTMP1
        SFR	12
        ANDK    0X0F
        SAH     INT_TTMP1
        LAC     KEY               	;// update the 1st key set in KEY(3..0)
        ANDL    0XFFF0
        OR      INT_TTMP1
        SAH     KEY
        BS	B1,DspModeINT_STMR_END
DspModeINT_STMR_END:	
	LAC	KEY
	XORL	0XFFFF
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
	BS	B1,INT_KEYSCAN_END			
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
;	input : ACCH
;	output: ACCH = the address of key bit=0(1..12)key pressed
;			 =0 no key pressed
;-------------------------------------------------------------------------------
KEYTOMSG:
	SAH	INT_TTMP2
	
	LACK	1
	SAH	INT_TTMP1	;计数
KEYTOMSG_LOOP:	
	BIT	INT_TTMP2,0
	BZ	TB,KEYTOMSG_END

	LAC	INT_TTMP1
	SBHK	16
	BS	ACZ,KEYTOMSG_END0
	
	LAC	INT_TTMP1
	ADHK	1
	SAH	INT_TTMP1

	LAC	INT_TTMP2
	SFR	1
	SAH	INT_TTMP2

	BS	B1,KEYTOMSG_LOOP
KEYTOMSG_END:
	LAC	INT_TTMP1
KEYTOMSG_END0:
	RET
;-------------------------------------------------------------------------------
KEY_TABLE:
.if	0
      ;	0	1	2	3	4	5	6	7
.DATA   0X0E00	0XFFF0	0X0	0X0	0X0D00	0XFF0F	0X0	0X0	
      ;	8	9	10	11	12	13	14	15
.DATA	0X0B00	0XF0FF	0X0	0X0	0X0700	0X0FFF	0X0	0X0
.else

.endif
;-------------------------------------------------------------------------------
LED_TABLE:
.if	0
      ;	0	1	2	3	4
.DATA   0X0E00	0XFFF0	0X0	0X0	0X0D00
.else

.endif
;-------------------------------------------------------------------------------
.END
