.LIST
KEY_DOWN	.EQU		80	;按键被识别的最短按下时间
KEY_PLUSE	.EQU		400	;按键按下被识别,发连续脉冲的时间间隔

KEYSCAN_CHK:

;-------------------------------------------------------------------------------
INT_KEYSCAN_OUT:
	LAC	TMR2
	ANDK	0X0F
	SBHK	4
	BZ	SGN,INT_KEYSCANOUT_END
;---只修改GPAD(9,8)		;只有TMR2 = 0/1/2/3时方可扫按键
	lipk	8
        IN      INT_TTMP1,GPAD
	LAC	INT_TTMP1
	ANDL	0XF0FF
	SAH	INT_TTMP1
	
	LAC	TMR2
	ANDK	0X03
	CALL	KEYTAB_OUT
	ADHK	0
        OR	INT_TTMP1
        SAH	INT_TTMP1
	OUT     INT_TTMP1,GPAD
	ADHK	0
	
INT_KEYSCANOUT_END:
	RET
;-------------------------------------------------------------------------------
INT_KEYSCAN_IN:  
	LAC	TMR2
	ANDK	0X0F
	SBHK	4
	BZ	SGN,INT_KEYSCANIN_END
					;只有TMR2 = 0/1/2/3时方可扫按键
	lipk	8
	IN	INT_TTMP1,GPAD
        LAC	INT_TTMP1
	ANDL	0X3000
        SAH	INT_TTMP1		;Save GPA(13,12)
	
	LAC	TMR2
	ANDK	0X03
	BS	ACZ,INT_SP10_IN	
	SBHK	1
	BS	ACZ,INT_SP20_IN
	SBHK	1
	BS	ACZ,INT_SP30_IN
	SBHK	1
	BS	ACZ,INT_SP40_IN

	BS	B1,INT_KEYSCANIN_END
INT_SP40_IN:
	LAC     INT_TTMP1
	SFR	6
        ;ANDL    0X00C0
	SAH     INT_TTMP1

	LAC     KEY               	;update the 2nd key set in KEY(7,6)
	ANDL    0XFF3F
	OR      INT_TTMP1
	SAH     KEY
	BS	B1,INT_KEYSCANIN_END
INT_SP30_IN:
	LAC     INT_TTMP1
	SFR	8
	;ANDK    0X0030
	SAH     INT_TTMP1

	LAC     KEY               	;update the 2nd key set in KEY(5,4)
	ANDL    0XFFCF
	OR      INT_TTMP1
	SAH     KEY
	BS	B1,INT_KEYSCANIN_END
INT_SP20_IN:				;read in the 2nd key set
	LAC     INT_TTMP1
	SFR	10
        ;ANDK    0X00C
	SAH     INT_TTMP1

	LAC     KEY               	;update the 2nd key set in KEY(3,2)
	ANDL    0XFFF3
	OR      INT_TTMP1
	SAH     KEY
	BS	B1,INT_KEYSCANIN_END
					;scan the 1st
INT_SP10_IN:	        		;read in the 1st key set
        LAC     INT_TTMP1
        SFR	12
        ;ANDK    0X03
        SAH     INT_TTMP1

        LAC     KEY               	;update the 1st key set in KEY(1,0)
        ANDL    0XFFFC
        OR      INT_TTMP1
        SAH     KEY
	;BS	B1,INT_KEYSCANIN_END
INT_KEYSCANIN_END:
;-------------------------------------------------------------------------------
INT_KEYMSG:
	CALL	KEY_CHK

	LAC	KEY_OLD
	CALL	KEYTOMSG
	SAH	INT_TTMP0
	BS	ACZ,INT_KEYMSG_2	;no key pressed ?

;INT_KEYMSG_0:	
	LAC	TMR_KEY
	SBHL	2000
	BZ	ACZ,INT_KEYMSG_1
	
	LAC	INT_TTMP0
	ADHK	0X010
	CALL	INT_STOR_MSG		;长按2second消息0X10
	BS	B1,INT_KEYMSG_2

INT_KEYMSG_1:
	LAC	TMR_KEY
	SBHL	1000
	BS	SGN,INT_KEYMSG_2	;要求按下时长大于1000ms
	
	LAC	TMR_KEY
	ANDL	0X01FF
	BZ	ACZ,INT_KEYMSG_2
	
	LAC	INT_TTMP0
	ADHK	0X020
	CALL	INT_STOR_MSG		;长按每512ms消息0X20(512*2+32ms,512*3+32ms,...,)

INT_KEYMSG_2:
;!!!!!!!!!!!!!!!
	LAC	KEY_OLD
	XORL	0X00FF
	ANDL	0XFF
	BS	ACZ,INT_KEYMSG_NOPRESSED

	LAC	TMR_KEY
	ADHK	1
	SAH	TMR_KEY
	
	LAC	TMR_KEY
	SBHL	3073
	BS	SGN,INT_KEYMSG_END
	
	LAC	TMR_KEY
	SBHL	KEY_PLUSE		;此数的大小和TMR_KEY最大值与长按时的脉冲消息有关
	SAH	TMR_KEY		
	BS	B1,INT_KEYMSG_END			

INT_KEYMSG_NOPRESSED:
	LACK	0
	SAH	TMR_KEY

INT_KEYMSG_END:
	RET
;-------------------------------------------------------------------------------
;	Funtion : transmit the address of bit=0 to messages
;	input : ACCH
;	output: ACCH = the address of key bit=0(1..12)key pressed
;			 =0 no key pressed
;-------------------------------------------------------------------------------
KEYTOMSG:
	SAH	INT_TTMP0
	
	LACK	1
	SAH	INT_TTMP1	;计数
KEYTOMSG_LOOP:	
	BIT	INT_TTMP0,0
	BZ	TB,KEYTOMSG_END

	LAC	INT_TTMP1
	SBHK	8		;按键数
	BZ	SGN,KEYTOMSG_END0
	
	LAC	INT_TTMP1
	ADHK	1
	SAH	INT_TTMP1

	LAC	INT_TTMP0
	SFR	1
	SAH	INT_TTMP0

	BS	B1,KEYTOMSG_LOOP
KEYTOMSG_END:
	LAC	INT_TTMP1
KEYTOMSG_END0:
	
	RET
;-------------------------------------------------------------------------------
INT_LEDDISP:

	lipk	8
        IN      INT_TTMP1,GPAD
	LAC	INT_TTMP1
	ANDL	0XFF00
        OR	LED_L
        SAH	INT_TTMP1
	OUT	INT_TTMP1,GPAD
	ADHK	0

	RET
;-------------------------------------------------------------------------------
KEYTAB_OUT:
	BS	ACZ,KEYTAB_OUT0
	SBHK	1
	BS	ACZ,KEYTAB_OUT1
	SBHK	1
	BS	ACZ,KEYTAB_OUT2
	SBHK	1
	BS	ACZ,KEYTAB_OUT3
	RET
KEYTAB_OUT0:
	LACL	(0X0F00)&~(1<<8)	;0X0E00 ;
	BS	B1,KEYTAB_OUT_END
KEYTAB_OUT1:
	LACL	(0X0F00)&~(1<<9)	;0X0D00	;
	BS	B1,KEYTAB_OUT_END
KEYTAB_OUT2:
	LACL	(0X0F00)&~(1<<10)	;0X0B00	;
	BS	B1,KEYTAB_OUT_END
KEYTAB_OUT3:
	LACL	(0X0F00)&~(1<<11)	;0X0700	;
KEYTAB_OUT_END:
	ADHK	0

	RET
;-------------------------------------------------------------------------------
;	Funtion : check key press or release
;	
;	compare KEY with KEY_OLD and produce press or release MSG
;-------------------------------------------------------------------------------
KEY_CHK:
	LAC	KEY
	XOR	KEY_OLD
	BS	ACZ,KEY_CHK1
;---不同就计时	
	LAC	TMR2
	ADHL	0X0100
	SAH	TMR2
	SFR	8
	ANDL	0XFF
	SBHK	KEY_DOWN
	BS	SGN,KEY_CHK_END
KEY_CHK0:			;check key press or relessed
	LAC	KEY
	XORL	0X0FF
	ANDL	0X0FF
	BS	ACZ,KEY_CHK0_1
;---press	
	LAC	KEY
	CALL	KEYTOMSG
	ADHK	0X030
	CALL	INT_STOR_MSG		;pressed KEY	
	BS	B1,KEY_CHK1
KEY_CHK0_1:
;---release
	LAC	KEY_OLD
	CALL	KEYTOMSG
	CALL	INT_STOR_MSG		;released KEY
KEY_CHK1:		;相同退出
	LAC	KEY
	SAH	KEY_OLD
	
	LAC	TMR2
	ANDK	0X0F
	SAH	TMR2
;-------------------------------------------------------------------------------
KEY_CHK_END:		;条件未达到退出
	RET
;-------------------------------------------------------------------------------
.END
