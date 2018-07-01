.LIST
;-------------------------------------------------------------------------------
KEY_DOWN	.EQU		90	;按键被识别的最短按下时间
KEY_PLUSE	.EQU		400	;按键按下被识别,发连续脉冲的时间间隔
;-------------------------------------------------------------------------------
;LEDH(15..8) => LED1;LEDH(7..0) => LED2
;LEDL(15..8) => LED3;LEDL(7..0) => LED4
;-------------------------------------------------------------------------------
KEYSCAN_CHK:
;---------------
INT_KEYOUT:
;---------------
	lipk	8
        IN      INT_TTMP1,GPAD
        LAC     INT_TTMP1
        ANDL    0XF000
        SAH     INT_TTMP1

        LAC	TMR2
        ANDK	0X0F
        BS	ACZ,INT_KEYOUT_10		;TMR2=0ms
        SBHK	0X04
	BS	ACZ,INT_KEYOUT_20		;TMR2=4ms
	SBHK	0X04
	BS	ACZ,INT_KEYOUT_30		;TMR2=8ms
	SBHK	0X04
	BS	ACZ,INT_KEYOUT_40		;TMR2=12ms
	BS	B1,INT_KEYOUT_END
INT_KEYOUT_40:		;scan the 4th(GPAD.11---KEY15..12)
.IF	1
	LAC	LED_L
	ANDL	0X0FF
	ORL	0X0700
	OR	INT_TTMP1
.ELSE	
	LAC	INT_TTMP1
        ORL	0X0700
        OR	LED4	;???????????????
.ENDIF
        SAH	INT_TTMP1
        OUT	INT_TTMP1,GPAD
        ADHK	0
        BS	B1,INT_KEYOUT_END
INT_KEYOUT_30:		;scan the 3rd(GPAD.10---KEY0..3)
.IF	1
	LAC	LED_L
	SFR	8
	ANDL	0X0FF
	ORL	0X0B00
	OR	INT_TTMP1
.ELSE
        LAC	INT_TTMP1
        ORL	0X0B00
	OR	LED3	;???????????????
.ENDIF
        SAH	INT_TTMP1
        OUT	INT_TTMP1,GPAD
        ADHK	0
        BS	B1,INT_KEYOUT_END
INT_KEYOUT_20:		;scan the 2nd(GPAD.9---KEY4..7)
.IF	1
	LAC	LED_H
	ANDL	0X0FF
	ORL	0X0D00
	OR	INT_TTMP1
.ELSE	
	LAC	INT_TTMP1
        ORL	0X0D00
	OR	LED2	;???????????????
.ENDIF
        SAH     INT_TTMP1
        OUT     INT_TTMP1,GPAD
        ADHK	0
	BS	B1,INT_KEYOUT_END      
INT_KEYOUT_10:                         	;scan the 1st(GPAD.8---KEY8..11)
.IF	1
	LAC	LED_H
	SFR	8
	ANDL	0X0FF
	OR	INT_TTMP1
	ORL	0X0E00
.ELSE
	LAC     INT_TTMP1
        ORL	0X0E00
	OR	LED1	;???????????????
.ENDIF
        SAH     INT_TTMP1
        OUT     INT_TTMP1,GPAD
        ADHK	0
	;BS	B1,INT_KEYOUT_END
INT_KEYOUT_END:
;---
INT_KEYIN:   
INT_KEYIN_40:
	LAC	TMR2
	ANDK	0XF
	SBHK	13
	BZ	ACZ,INT_KEYIN_30
	
        IN	INT_TTMP1,GPAD
        LAC	INT_TTMP1
	ANDL	0XF000
        SAH	INT_TTMP1
        LAC	KEY
        ANDL	0X0FFF
        OR	INT_TTMP1
        SAH	KEY
        BS	B1,INT_KEYIN_END	;SAVE the 4th key set in KEY(15..12)

INT_KEYIN_30:
	LAC	TMR2
	ANDK	0XF
	SBHK	9
	BZ	ACZ,INT_KEYIN_20
	
        IN	INT_TTMP1,GPAD
        LAC	INT_TTMP1
        SFR	4
        ANDL	0X0F00
        SAH	INT_TTMP1
        LAC	KEY
        ANDL	0XF0FF
        OR	INT_TTMP1
        SAH	KEY
	BS	B1,INT_KEYIN_END	;SAVE the 3rd key set in KEY(11..8)

INT_KEYIN_20:
	LAC	TMR2
	ANDK	0XF
	SBHK	5
	BZ	ACZ,INT_KEYIN_10
	
        IN      INT_TTMP1,GPAD        		;read in the 2nd key set
        LAC     INT_TTMP1
        SFR	8
        ANDL    0X00F0
        SAH     INT_TTMP1
        LAC     KEY               	;update the 2nd key set in KEY(7..4)
        ANDL    0XFF0F
        OR      INT_TTMP1
        SAH     KEY
	BS	B1,INT_KEYIN_END
	
INT_KEYIN_10:                             	;display the 1st digit and scan the 1st

	LAC	TMR2
	ANDK	0XF
	SBHK	1
	BZ	ACZ,INT_KEYIN_END
	
        IN      INT_TTMP1,GPAD        	;read in the 1st key set
        LAC     INT_TTMP1
        SFR	12
        ANDK    0X0F
        SAH     INT_TTMP1
        LAC     KEY               	;update the 1st key set in KEY(3..0)
        ANDL    0XFFF0
        OR      INT_TTMP1
        SAH     KEY
	;BS	B1,INT_KEYIN_END

INT_KEYIN_END:
;-------------------------------------------------------------------------------
INT_KEYMSG:
	CALL	KEY_CHK

	LAC	KEY_OLD
	CALL	KEYTOMSG
	SAH	INT_TTMP0
	BS	ACZ,INT_KEYMSG_2		;no key pressed ?

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
	BS	SGN,INT_KEYMSG_2		;要求按下时长大于1000ms
	
	LAC	TMR_KEY
	ANDL	0X01FF
	BZ	ACZ,INT_KEYMSG_2
	
	LAC	INT_TTMP0
	ADHK	0X020
	CALL	INT_STOR_MSG		;长按每512ms消息0X20(512*2+32ms,512*3+32ms,...,)

INT_KEYMSG_2:
;!!!!!!!!!!!!!!!
	LAC	KEY_OLD
	XORL	0XFFFF
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
	SBHK	16
	BS	ACZ,KEYTOMSG_END0
	
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
	XORL	0XFFFF
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