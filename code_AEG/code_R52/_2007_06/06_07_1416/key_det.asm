.LIST
KEY_DOWN	.EQU		80	;按键被识别的最短按下时间
KEY_PLUSE	.EQU		400	;按键按下被识别,发连续脉冲的时间间隔

KEYSCAN_CHK:
	
	LAC	KEY
	CALL	KEYTOMSG
	SAH	INT_TTMP1
	SAH	INT_TTMP0
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
;---------------
INT_KEYSCAN_OUT:
	LAC	TMR2
	ANDK	0X03
	BZ	ACZ,INT_KEYSCAN_IN	;Output(only TMR = 0000/0100/1000/1100)
;---只修改GPAD(11,10,9,8)
	lipk	8
        IN      INT_TTMP1,GPAD
	LAC	INT_TTMP1
	ANDL	0XF0FF
	SAH	INT_TTMP1
	
	LAC	TMR2
	SFR	2
	ANDK	0X01
	CALL	KEYTAB_OUT
	ADHK	0
        OR	INT_TTMP1
        SAH	INT_TTMP1
	OUT     INT_TTMP1,GPAD
        ADHK	0

INT_KEYSCAN_IN:  

	LAC	TMR2
	ANDK	0X03
	SBHK	2
	BZ	ACZ,DspModeINT_STMR_END
	
	IN	INT_TTMP1,GPAD
        LAC	INT_TTMP1
	ANDL	0XF000
        SAH	INT_TTMP1
	
	LAC	TMR2
	SFR	2
	ANDK	0X01
	BS	ACZ,INT_SP10_IN		;0X0001
	SBHK	1
	BS	ACZ,INT_SP20_IN		;0X0005

	BS	B1,DspModeINT_STMR_END

INT_SP20_IN:				;read in the 2nd key set
        LAC     INT_TTMP1
        SFR	8
        ;ANDL    0X00F0
        SAH     INT_TTMP1

        LAC     KEY               	;update the 2nd key set in KEY(7..4)
        ANDL    0XFF0F
        OR      INT_TTMP1
        SAH     KEY
        BS	B1,DspModeINT_STMR_END
                                  ;// display the 1st digit and scan the 1st
INT_SP10_IN:	        		;read in the 1st key set
        LAC     INT_TTMP1
        SFR	12
        ;ANDK    0X0F
        SAH     INT_TTMP1

        LAC     KEY               	;update the 1st key set in KEY(3..0)
        ANDL    0XFFF0
        OR      INT_TTMP1
        SAH     KEY
        BS	B1,DspModeINT_STMR_END
DspModeINT_STMR_END:	
	LAC	KEY
	ANDL	0X0FF
	XORL	0X0FF
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

	LAC	TMR_KEY
	SBHK	2
	SBHK	KEY_DOWN
	BS	SGN,NO_KEY_PRESSED1	;按下时间小于KEY_DOWN视为误操作
	
	LAC	INT_TTMP0
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
.if	1
	SAH	INT_TTMP0
	
	LACK	1
	SAH	INT_TTMP1	;计数
KEYTOMSG_LOOP:	
	BIT	INT_TTMP0,0
	BZ	TB,KEYTOMSG_END

	LAC	INT_TTMP1
	;SBHK	16
	SBHK	8
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
.else
.endif
;-------------------------------------------------------------------------------
INT_LEDDISP:
.if	1
;---只修改OPT(7..0)
	lipk	8
        IN      INT_TTMP1,GPAD
	LAC	INT_TTMP1
	ANDL	0XF000
	SAH	INT_TTMP1

	LAC	TMR2
	SFR	2
	ANDK	0X01
	CALL	KEYTAB_OUT
        OR	INT_TTMP1
        SAH	INT_TTMP1

	LAC	TMR2
	SFR	2
	ANDK	0X01
	BS	ACZ,INT_LEDDISP_0	;0X00xx
	SBHK	1
	BS	ACZ,INT_LEDDISP_1	;0X01xx

	RET

INT_LEDDISP_0:	
	LAC	LED_L
	sfr	8
	BS	B1,INT_LEDDISP1
INT_LEDDISP_1:
        LAC	LED_L
	;ANDL	0X0FF
	;BS	B1,INT_LEDDISP1

INT_LEDDISP1:
	ANDL	0X0FF
        OR	INT_TTMP1
        SAH	INT_TTMP1
	OUT	INT_TTMP1,GPAD
	ADHK	0
.endif
INT_LEDDISP_END:
	
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

	RET
KEYTAB_OUT1:
	LACL	(0X0F00)&~(1<<9)	;0X0D00	;

	RET
KEYTAB_OUT2:
	LACL	(0X0F00)&~(1<<10)	;0X0B00	;

	RET
KEYTAB_OUT3:
	LACL	(0X0F00)&~(1<<11)	;0X0700	;

	RET

;-------------------------------------------------------------------------------
.END
