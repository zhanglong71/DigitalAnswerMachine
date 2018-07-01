.LIST
;-------------------------------------------------------------------------------

CMULT		.EQU	1		;倍数()
CHALFP		.EQU	100*CMULT	;100ms(8*100)	- 一次脉冲最长持续时间(最长脉冲周期的一半)
CRING_ON	.EQU	380*CMULT	;400ms(8*400)	- RING ON  时间(即一次来铃的铃流最短时间)
CRING_OFF	.EQU	700	;700ms(8*700)	- RING OFF 时间(即一次来铃的多个铃流之间的最长时间)
CRING_WAIT	.EQU	8000	;8000ms(8*8000)	- RING WAIT时间(即一次来电的多次来铃之间的最长时间)
;------ BELOWS ARE FOR RING CHECKING (FREQUENCY RANGE : 11 - 100 Hz===###change 1 2 3 4) ---------
RING_CHK:
	LAC     RING_ID		;if the target ring number is 0, not
	ANDK    0X0F		;check ring in
	BS      ACZ,RING_CHK_END
        
	BIT     RING_ID,11	;check if in ring wait state ?
	BS      TB,RING_WAIT
	BIT     RING_ID,10	;check if in ring off state ?
	BS      TB,RING_OFF_CHK
	BIT     RING_ID,9		;check if in ring start-high state ?
        BS      TB,RING_PCHK
	BIT     RING_ID,8		;check if in ring start-low state ?
        BS      TB,RING_PCHK
;---ring check start
	LACK	0
	SAH	BTONE_BUF
RING_PCHK:	
	LACK	5
	CALL	RING_PULSE
	BS	ACZ,RING_PCHK_POK
	ANDK	0X01
	BS	ACZ,RING_END1		;time out
	BS	B1,RING_CHK_END
RING_PCHK_POK:
;---铃流的脉冲次数达到要求,再查铃流的持续时间
	LAC	BTONE_BUF
	SBHL	CRING_ON
	;BS	SGN,RING_CHK_END	;第一个铃流持续时间满足要求吗?
;---pulse ok(enter off status)
	LAC     RING_ID
	ANDL    0X03FF
	ORL     0X0400		;set in ring off state
	SAH     RING_ID

	LACL    CRING_OFF
	SAH	TMR_CTONE
	
	LACL	CRING_IN
	CALL	INT_STOR_MSG

	BS	B1,RING_CHK_END
;-------------------------------------------------------------------------------
RING_OFF_CHK:
	LACK	3
	CALL	RING_PULSE
	BZ	ACZ,RING_OFF_CHK2
;---pulse ok
	LACL    CRING_OFF	;detector 2 pulse, restore
	SAH	TMR_CTONE

        BS      B1,RING_CHK_END
RING_OFF_CHK2:
        LAC	TMR_CTONE
        BZ      SGN,RING_CHK_END
				;ring off is finished
				;TMR_CTONE=8.0 sec for max. ring wait time
	LACL    CRING_WAIT
	SAH     TMR_CTONE	;one ring ok
	LACK	0
	SAH	BTONE_BUF
	LACL	CMULT
	SAH	TMR3

	LAC     RING_ID
	ANDL    0X03FF
	ADHK    0X0010
	ORL     0X0800             	;set in ring wait state
	SAH     RING_ID

        LAC     RING_ID           	;check if the accumulated ring number is
        ANDK    0X0F              	;equal to the target ring number ?
        SAH     INT_TTMP1
	LAC     RING_ID
	SFR     4
        ANDK    0X0F
        SBH     INT_TTMP1
        BS      SGN,RING_CHK_END

        LACL	CRING_OK
        CALL	INT_STOR_MSG
        
        BS      B1,RING_CHK_END
;-------------------------------------------------------------------------------
RING_WAIT:
	LACK	5
	CALL	RING_PULSE
	BS	ACZ,RING_WAIT_POK		;0
	SBHK	1
	BS	ACZ,RING_WAIT_HL		;1
	SBHK	1
	BS	ACZ,RING_WAIT_HL_TIMEOUT	;2
	SBHK	1
	BS	ACZ,RING_WAIT_LH		;3
	SBHK	1
	BS	ACZ,RING_WAIT_LH_TIMEOUT	;4
	SBHK	1
	BS	ACZ,RING_WAIT_HH		;5
	SBHK	1
	BS	ACZ,RING_WAIT_HH_TIMEOUT	;6
	SBHK	1
	BS	ACZ,RING_WAIT_LL		;7
	SBHK	1
	BS	ACZ,RING_WAIT_LL_TIMEOUT	;8
	BS	B1,RING_WAIT1
RING_WAIT_POK:
;---铃流的脉冲次数达到要求,再查铃流的持续时间	
	LAC	BTONE_BUF
	SBHL	CRING_ON
	;BS	SGN,RING_WAIT1		;铃流持续时间满足要求吗?
;---the next ring flue ok(enter off status)
	LAC     RING_ID
	ANDL    0X03FF
	ORL     0X0400		;set in ring off state
	SAH     RING_ID

	LACL    CRING_OFF
	SAH	TMR_CTONE

	LACL	CRING_IN
	CALL	INT_STOR_MSG

	BS      B1,RING_CHK_END
RING_WAIT_LL:
RING_WAIT_HL:
	LACL    CRING_WAIT	;pulse()
	SAH	TMR_CTONE
	BS      B1,RING_CHK_END
RING_WAIT_HL_TIMEOUT:		;执行到此的可能不大
	LACL    CRING_WAIT
	SAH	TMR_CTONE
	
	LACL	CHALFP-1
	SAH	TMR3
	
	LACK	0
	SAH	BTONE_BUF
	BS      B1,RING_CHK_END
RING_WAIT_HH_TIMEOUT:		;无脉冲等待中
	LACL	CHALFP-1
	SAH	TMR3

	BS	B1,RING_WAIT1
RING_WAIT_LH_TIMEOUT:		;执行到此的可能不大
RING_WAIT_LL_TIMEOUT:
	LACL	CHALFP-1
	SAH	TMR3
	BS      B1,RING_CHK_END
RING_WAIT_LH:			;pulse()
RING_WAIT_HH:	
	BS      B1,RING_CHK_END
;---------------------------------------
RING_WAIT1:
	LAC     TMR_CTONE              	;if ring wait time > 8.0 sec, ring in fail
	BZ      SGN,RING_CHK_END
;-------------------------------------------------------------------------------
RING_FAIL_CHK:				;ring in fail check
	LAC	RING_ID
	ANDL	0X0F0
	BS	ACZ,RING_END1
	
	LACL	CRING_FAIL
        CALL	INT_STOR_MSG		;从有铃流到8秒外无铃流
RING_END1:
        LAC     RING_ID         	;reset all flags of RING_ID
        ANDK    0X0F
        SAH     RING_ID
RING_CHK_END:                       	;not ring in ok

	RET
;-------------------------------------------------------------------------------
;	Function : RING_PULSE
;	check pulse
;	input : ACCH = ring/pulse(一次有效铃流的脉冲个数)
;	output: ACCH = 0/1/2/3
;			0 = pulse ok
;			1 = (H->L)and(no time out)
;			2 = (H->L)and(time out)
;			3 = (L->H)and(no time out)
;			4 = (L->H)and(time out)
;			5 = (H->H)and(no time out) or idle
;			6 = (H->H)and(time out)
;			7 = (L->L)and(no time out)
;			8 = (L->L)and(time out)
;			9 = (idle->H)
;作以下归纳	:返回值:0	= ok
;			奇数	= no time out
;			偶数	= time out
;-------------------------------------------------------------------------------
RING_PULSE:
	SAH	INT_TTMP0
;---
        BIT     RING_ID,9		;check if in ring high state ?
        BS      TB,RING_PULSE_HIGH
	BIT     RING_ID,8		;check if in ring low state ?
        BS      TB,RING_PULSE_LOW
;---
	LIPK    8
        IN      INT_TTMP1,GPBD
        BIT	INT_TTMP1,2		;check if the ring detector is low ?
        BS	TB,RING_PULSE_9END	;first check,only respond for low state
					;ring low happens
	LAC	RING_ID
	ANDL	0XFCFF
	ORL	0X0100			;set in ring low state
	SAH     RING_ID

	LACL	CHALFP
	SAH	TMR3
;-------------------------------------------------------------------------------
RING_PULSE_LOW:
        LAC     TMR3              	;if TMR3 time out, the ring low time > 100ms
        BS      SGN,RING_PULSE_8END	;it's not acceptable
;---持续低的时间不大于规定时间
	LIPK    8
        IN      INT_TTMP1,GPBD
        BIT     INT_TTMP1,2		;check if the ring detector is still low ?
        BZ      TB,RING_PULSE_7END
;---low->high
	LAC     RING_ID
	ANDL    0XFCFF
	ORL     0X0200             	;set in ring high state
	SAH     RING_ID

	LAC     TMR3            	;if TMR3 = CHALFP, the ring low time < 1/8ms
	SBHL	CHALFP			;it's not acceptable
	BZ      SGN,RING_PULSE_4END
;---持续低的时间不小于规定时间
        LACL    CHALFP
        SBH     TMR3			;( 0<=TMR3<=CHALFP-1 )
        SAH     BUF3              	;save ring low time in BUF3( 1<=BUF3<=CHALFP )

        LACL    CHALFP
        SAH     TMR3
        BS      B1,RING_PULSE_3END
;-------------------------------------------------------------------------------
RING_PULSE_HIGH:
        LAC     TMR3              	;if TMR3 time out, the ring high time > 100ms
        BS      SGN,RING_PULSE_6END	;it's not acceptable
;---持续高的时间不大于规定时间
	LIPK    8
        IN      INT_TTMP1,GPBD
        BIT     INT_TTMP1,2           	;check if the ring detector is still high
        BS      TB,RING_PULSE_5END
;---high->low
        LAC     RING_ID
        ANDL    0XFCFF
	ORL     0X0100             	;(set in ring off state)&(Save the port status - low)
        SAH     RING_ID

	LAC     TMR3             	;if TMR3 = CHALFP, the ring high time < 1/8ms
	SBHL    CHALFP			;it's not acceptable
	BZ      SGN,RING_PULSE_2END
;---持续高的时间不小于规定时间
	LACL    CHALFP
	SBH     TMR3
	ADH     BUF3
	SBHL    85*CMULT               	;be sure that the (ring low time + ring high time) < 80 ms
	BZ      SGN,RING_PULSE_2END
	ADHL    75*CMULT		;be sure that the (ring low time + ring high time) > 10 ms
	BS      SGN,RING_PULSE_2END
;---持续高与持续低的时间之和满足时间限制(pulse valid)
	LAC	BTONE_BUF
	ADH	BUF3
	ADHL    CHALFP
	SBH	TMR3
	SAH	BTONE_BUF	;本次铃流持续的时间

	LAC     RING_ID           ;one ring pulse ok
	ADHL    0X1000
	SAH     RING_ID
	SFR	12
	ANDK    0X0F
	SBH	INT_TTMP0            ;check if the ring pulse number>=5 ?
	BS      SGN,RING_PULSE_1END

	LACL    CHALFP
	SAH     TMR3
	;BS	B1,RING_PULSE_0END

;RING_PULSE_0END:
	LACK	0	;pulse ok
	RET
RING_PULSE_1END:
	LACK	1
	RET
RING_PULSE_2END:
	LACK	2
	RET
RING_PULSE_3END:
	LACK	3
	RET
RING_PULSE_4END:
	LACK	4
	RET
RING_PULSE_5END:
	LACK	5
	RET
RING_PULSE_6END:
	LACK	6
	RET
RING_PULSE_7END:
	LACK	7
	RET
RING_PULSE_8END:
	LACK	8
	RET
RING_PULSE_9END:
	LACK	9
	RET

;-------------------------------------------------------------------------------
.END
