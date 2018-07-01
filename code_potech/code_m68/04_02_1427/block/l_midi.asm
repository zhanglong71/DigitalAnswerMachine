.NOLIST
;-------------------------------------------------------------------------------
;	SYSTMP1(0..11)  --- timerfor receive/send data	(0..2400Tw)
;	SYSTMP1(12..15) --- bit counter for receive/send data	(0..10)

;SER_FG the bit flag 
CbS	.EQU	8	;idle bit flag
CbI	.EQU	9	;start bit flag
CbT	.EQU	10	;send bit flag
CbR	.EQU	11	;receive bit flag
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
.LIST
;-------------------------------------------------------------------------------
;	input : ACCH = write data
;	output: no
;-------------------------------------------------------------------------------
MIDI_WCOM:
	DINT		;
	SAH	MIDI_BUF
;---high 1ms start	
	CALL	MIDI_DOUT
	CALL	MIDI_DH
	LACl	100
	CALL	DELAY_MIDI	;delay 100*10us=1000us=1ms
;---	

MIDI_WCOM_START:
;---make start pulse
	LACK	0
	SAH	SYSTMP1

	CALL	MIDI_DOUT
	CALL	MIDI_DL
	CALL	MIDI_DIN
MIDI_WCOM_START_0:	
	CALL	DELAY_10US
	
	LAC	SYSTMP1
	ADHK	1
	SAH	SYSTMP1
	SBHL	10000
	BZ	SGN,MIDI_WCOM_NO	;(100ms time out)no MIDI exit
	
	CALL	MIDI_GETD	;detect the answer pulse (raise pulse)
	BS	ACZ,MIDI_WCOM_START_0	;

	LACK	0
	SAH	SYSTMP1
MIDI_WCOM_SANS:
	
	CALL	DELAY_10US
	
	LAC	SYSTMP1
	ADHK	1
	SAH	SYSTMP1
	SBHL	1000
	BZ	SGN,MIDI_WCOM_NO	;(10ms time out)no MIDI exit
	
	CALL	MIDI_GETD	;detect the answer pulse end (fall pulse)
	BZ	ACZ,MIDI_WCOM_SANS	;
;---end start answer
	CALL	MIDI_DOUT
	CALL	MIDI_DL
	CALL	DELAY_50US

	LACK	0
	SAH	SYSTMP1

MIDI_WCOM_WR:
;---End Tsc and start WR bit
	CALL	MIDI_DOUT
	CALL	MIDI_DH
	LACK	20		;ignore the Tw(see it as const=50us)
	CALL	DELAY_MIDI
;---End WR bit
	CALL	MIDI_DL
	CALL	DELAY_50US
	
	LACK	0
	SAH	SYSTMP1
;---------------------------------------------------------------------
MIDI_WCOM_1:
;---send bit data
	CALL	MIDI_DOUT
	CALL	MIDI_DH
	
	LACK	5
	BIT	MIDI_BUF,0
	BZ	TB,MIDI_WCOM_1_1
	LACK	20
MIDI_WCOM_1_1:
	CALL	DELAY_MIDI
;---send bit data end
	CALL	MIDI_DL
	CALL	DELAY_50US

	LAC	MIDI_BUF
	SFR	1
	SAH	MIDI_BUF
	
	LAC	SYSTMP1
	ADHK	0X01
	SAH	SYSTMP1
	SBHK	9
	BS	SGN,MIDI_WCOM_1

	CALL	MIDI_DIN

	LACK	0
	SAH	SYSTMP1
MIDI_WCOM_ASK:
	
;---------------------------------------
MIDI_WCOM_YES:
	EINT
	RET
MIDI_WCOM_NO:
	EINT
	RET
;---------------------------------------
MIDI_STOP:
	DINT		;
;---high 1ms start	
	CALL	MIDI_DOUT
	CALL	MIDI_DH
	LACl	100
	CALL	DELAY_MIDI	;delay 100*10us=1000us=1ms
;---	
;---make start pulse
	LACK	0
	SAH	SYSTMP1

	CALL	MIDI_DOUT
	CALL	MIDI_DL
	CALL	MIDI_DIN
	
	EINT
	RET
;--------------------------------------------------------------------------------
.if	0
MIDI_RX:
	DINT		;
;---	
	LACK	0
	SAH	SYSTMP1
	SAH	MIDI_BUF
MIDI_RX_START:
;---make start pulse
	CALL	MIDI_DOUT
	CALL	MIDI_DL
;---Tst=1ms
	LACK	20
	CALL	DELAY_MIDI	;delay 20*50us=1000us=1ms
;---end Tsc
	CALL	MIDI_DOUT
	CALL	MIDI_DH
	CALL	MIDI_DIN
;---start Tec
MIDI_RX_Tec:
	CALL	DELAY_50US
	LAC	SYSTMP1
	ADHK	1
	SAH	SYSTMP1
	ANDL	0X0FFF
	SBHL	2400
	BZ	SGN,MIDI_RX_NO	;Tec time out(50us*2400=120000us=120ms)
	CALL	MIDI_GETD
	BZ	ACZ,MIDI_RX_Tec
;---start Tw(start answer pulse begin)	
	LACK	0
	SAH	SYSTMP1
MIDI_RX_Tw:	
	CALL	DELAY_50US
	LAC	SYSTMP1
	ADHK	1
	SAH	SYSTMP1
	ANDK	0X7F
	SBHK	100
	BZ	SGN,MIDI_RX_NO	;Tec time out(50us*100=5000us=5ms)
	CALL	MIDI_GETD
	BS	ACZ,MIDI_RX_Tw
;---!!!End Tw and Save the Tw
	LAC	SYSTMP1
	SAH	COUNT
	LACK	0
	SAH	SYSTMP1
;---delay Tsc=2Tw
	LAC	COUNT
	SFL	1
	CALL	DELAY_MIDI
MIDI_RX_WR:
;---End Tsc and start WR bit
	CALL	MIDI_DOUT
	CALL	MIDI_DL
;---	
	LAC	COUNT
	CALL	DELAY_MIDI
;---End WR bit
	CALL	MIDI_DH
	CALL	MIDI_DIN	
	LAC	COUNT
	SFL	1
	CALL	DELAY_MIDI

	LACK	0
	SAH	SYSTMP1
MIDI_RX_1:
;---begin send bit 
	LAC	MIDI_BUF
	SFL	1
	SAH	MIDI_BUF

	CALL	MIDI_DOUT
	CALL	MIDI_DL
	
	LAC	COUNT
	CALL	DELAY_MIDI
	
	CALL	MIDI_DH
	CALL	MIDI_DIN
MIDI_RX_1_LOOP:
	LAC	SYSTMP1
	ADHK	1
	SAH	SYSTMP1		;为防在此死机,可设一计数上限
	ANDL	0X0FFF
	SBHL	2400
	BZ	SGN,MIDI_RX_NO

	LAC	COUNT
	CALL	DELAY_MIDI

	CALL	MIDI_GETD
	BS	ACZ,MIDI_RX_1_LOOP

	LAC	COUNT
	SFL	1
	CALL	DELAY_MIDI

	LAC	SYSTMP1
	ANDK	0X7F
	SBHK	3
	BS	SGN,MIDI_RX_2
	
	LAC	MIDI_BUF
	ORK	1
	SAH	MIDI_BUF
MIDI_RX_2:
	LAC	SYSTMP1
	ANDL	0XF000
	ADHL	0X1000
	SAH	SYSTMP1
	SFR	12
	ANDK	0X0F
	SBHK	8
	BS	SGN,MIDI_RX_1
	BS	B1,MIDI_RX_YES

MIDI_RX_NO:
	EINT
	RET
MIDI_RX_YES:
	EINT
	RET
.endif
;---------------------------------------
;---------------------------------------
MIDI_DL:		;Reset MIDI_DATA
	LIPK	8

	IN	SYSTMP2,GPBD
	LAC	SYSTMP2
	ANDL	~(1<<CbMIDID)
	SAH	SYSTMP2
	OUT	SYSTMP2,GPBD
	ADHK	0
	
	RET
	
MIDI_DH:		;set MIDI_DATA
	LIPK	8

	IN	SYSTMP2,GPBD
	LAC	SYSTMP2
	ORL	1<<CbMIDID
	SAH	SYSTMP2
	OUT	SYSTMP2,GPBD
	ADHK	0
	
	RET
MIDI_DIN:		;set MIDI_DATA Port as an input port
	LIPK	8

	IN	SYSTMP2,GPBC
	LAC	SYSTMP2
	ANDL	~(1<<CbMIDID)
	SAH	SYSTMP2
	OUT	SYSTMP2,GPBC
	ADHK	0
	
	RET
MIDI_DOUT:		;set MIDI_DATA Port as an output port
	LIPK	8

	IN	SYSTMP2,GPBC
	LAC	SYSTMP2
	ORL	1<<CbMIDID
	SAH	SYSTMP2
	OUT	SYSTMP2,GPBC
	ADHK	0
	
	RET
	
MIDI_GETD:		;set MIDI_DATA Port as an input port
	LIPK	8

	IN	SYSTMP2,GPBD
	LAC	SYSTMP2
	SFR	CbMIDID
	ANDK	0X01
	
	RET

;-------------------------------------------------------------------------------
;	input : ACCH = Counter(the times of 10US)
;	OUTPUT: no
;-------------------------------------------------------------------------------
DELAY_MIDI:
	PSH	SYSTMP3
;---	
	SAH	SYSTMP3
DELAY_MIDI_LOOP:	
	LAC	SYSTMP3
	BS	ACZ,DELAY_MIDI_END
	SBHK	1
	SAH	SYSTMP3

	CALL	DELAY_10US
	BS	B1,DELAY_MIDI_LOOP
DELAY_MIDI_END:
	POP	SYSTMP3
;---	
	RET
;-------------------------------------------------------------------------------
;	Note:23ns/cycles(21ns)
;	
;	前三条指令:	1+1+1	  	=3cycles
;	最后一次循环:	1+1+1+3+1+1 	=8cycles
;	中间循环n次,每次1+1+1+4	 	=7cycles
;	(3+8+7n)*21=50000 ==> n=340
;-------------------------------------------------------------------------------
DELAY_50US:
	PSH	SYSTMP3
	
	LACL	340
	SAH	SYSTMP3
DELAY_50US_1:
	LAC	SYSTMP3
	SBHK	1
	SAH	SYSTMP3
	BZ	SGN,DELAY_50US_1

	POP	SYSTMP3
	
	RET

;-------------------------------------------------------------------------------
;	Note:23ns/cycles(21ns)
;	
;	前三条指令:	1+1+1	  	=3cycles
;	最后一次循环:	1+1+1+3+1+1 	=8cycles
;	中间循环n次,每次1+1+1+4	 	=7cycles
;	(3+8+7n)*21=10000 ==> n=66
;-------------------------------------------------------------------------------
DELAY_10US:
	PSH	SYSTMP3
	
	LACL	66
	SAH	SYSTMP3
DELAY_10US_1:
	LAC	SYSTMP3
	SBHK	1
	SAH	SYSTMP3
	BZ	SGN,DELAY_10US_1

	POP	SYSTMP3
	
	RET
;-------------------------------------------------------------------------------
.END
