.LIST
;.INCLUDE mx111S2.INC
;.INCLUDE reg2523b.inc
;.INCLUDE CONST.INC
;.global	RING_CHK
;.extern	INT_STOR_MSG
;.org 0xff00


CRING_OFF	.EQU	500	;RING OFF 时间(即一次来铃的多个铃流之间的最长时间)
CRING_WAIT	.EQU	6000	;RING WAIT时间(即一次来电的多次来铃之间的最长时间)

;------ BELOWS ARE FOR RING CHECKING (FREQUENCY RANGE : 14 - 100 Hz===###change 1 2 3 4) ---------
RING_CHK:

        LAC     RING_ID           ;if the target ring number is 0, not
        ANDK    0X0F              ;check ring in
        BS      ACZ,RING_CHK_END
        BIT     RING_ID,8         ;check if in ring low state ?
        BS      TB,RING_LOW_CHK
        BIT     RING_ID,9         ;check if in ring high state ?
        BS      TB,RING_HI_CHK
        BIT     RING_ID,10        ;check if in ring off state ?
        BS      TB,RING_OFF_CHK
        BIT     RING_ID,11        ;check if in ring wait state ?
        BS      TB,RING_WAIT
	
	LIPK    8
        IN      INT_TTMP1,GPBD
        BIT     INT_TTMP1,2	  ;check if the ring detector is low ?
        BS      TB,RING_CHK_END	  ;first check,only respond for low state
                                  ;ring low happens
        LAC     RING_ID
        ANDL    0XF0FF
        ORL     0X100             ;set in ring low state
        SAH     RING_ID
        LACK    67
        SAH     TMR3              ;TMR3=67 ms for min. 8 Hz
;-------------------------------------------------------------------------------
RING_LOW_CHK:
        LAC     TMR3              	;if TMR3 time out, the ring low time > 67ms
        BS      SGN,RING_OFF_CHK3	;it's not acceptable

	LIPK    8 
        IN      INT_TTMP1,GPBD
        BIT     INT_TTMP1,2     	;check if the ring detector is still low ?
        BZ      TB,RING_CHK_END
                                	;the ring detector changes to high
        LAC     TMR3            	;if TMR3 = 67, the ring low time < 1ms
        SBHK    67			;it's not acceptable
        BZ      SGN,RING_CHK_END
        LACK    67
        SBH     TMR3
        SAH     BUF3              	;save ring low time in BUF3

        LAC     RING_ID
        ANDL    0XF0FF
        ORL     0X200             	;set in ring high state
        SAH     RING_ID

        LACK    67                	;use 67 ms to check 15 Hz
        SAH     TMR3
        BS      B1,RING_CHK_END
;-------------------------------------------------------------------------------
RING_HI_CHK:
        LAC     TMR3              	;check if TMR3 is timed out ?
        BS      SGN,RING_OFF_CHK3

	LIPK    8
        IN      INT_TTMP1,GPBD
        BIT     INT_TTMP1,2           	;check if the ring detector is still high
        BS      TB,RING_CHK_END

        LAC     TMR3             	;ring detector changes to low
        SBHK    67             		;be sure that the ring high time > 1 ms
        BZ      SGN,RING_CHK_END
        LACL    67
        SBH     TMR3
        ADH     BUF3
        SBHK    78                	;be sure that the (ring low time + ring high time) < 78 ms
        BZ      SGN,RING_OFF_CHK3
        ADHK    71			;be sure that the (ring low time + ring high time) > 7 ms
        BS      SGN,RING_OFF_CHK3

        LAC     RING_ID
        ANDL    0XF0FF
        ORL     0X0100             	;set in ring low state
        SAH     RING_ID
        LACK    67                	;use 67 ms to check 15 Hz
        SAH     TMR3

	LACL	CRING_IN
	CALL	INT_STOR_MSG

        LAC     RING_ID           	;one ring pulse ok
        ADHL    0X1000
        SAH     RING_ID
        ANDL    0XF000
        SBHL    0X4000            	;check if the ring pulse number=5 ?
        BZ      ACZ,RING_CHK_END
                                  	;change to the ring off state
        LAC     RING_ID
        ANDL    0XF0FF
        ORL     0X0400             	;set in ring off state
        ADHK    0X0010
        SAH     RING_ID

        LACL    CRING_OFF               	;500 ms for min. ring off time
        SAH     TMR3
        BS      B1,RING_CHK_END
;-------------------------------------------------------------------------------
RING_OFF_CHK:
	LIPK    8
        IN      INT_TTMP1,GPBD
        BIT     INT_TTMP1,2
        BS      TB,RING_OFF_CHK2

        LACL    CRING_OFF               	;if ring detector changes to low, restore
        SAH     TMR3              	;500 ms in TMR3 and COUNT again
        BS      B1,RING_CHK_END
RING_OFF_CHK2:
        LAC     TMR3
        BZ      SGN,RING_CHK_END
RING_OFF_CHK3:                       	;ring off is finished
        LACL    CRING_WAIT              ;TMR3=8.0 sec for max. ring wait time
        SAH     TMR3
                                  	;one ring ok
        LAC     RING_ID
        ANDL    0X00FF
        ORL     0X0800             	;set in ring wait state
        SAH     RING_ID

        LAC     RING_ID           	;check if the accumulated ring number is
        ANDK    0X0F              	;equal to the target ring number ?
        SAH     INT_TTMP1
        LAC     RING_ID
        ANDL    0XF0
        SFR     4
        SBH     INT_TTMP1
        BS      SGN,RING_CHK_END

        LACL	CRING_OK
        CALL	INT_STOR_MSG
        
        BS      B1,RING_CHK_END
;-------------------------------------------------------------------------------
RING_WAIT:
	LIPK    8
        IN      INT_TTMP1,GPBD
        BIT     INT_TTMP1,2
        BS      TB,RING_WAIT1
                                  	;next ring starts
        LAC     RING_ID
        ANDL    0X00FF
        ORL     0X100             	;set in ring low state
        SAH     RING_ID
        LACK    67
        SAH     TMR3
        BS      B1,RING_LOW_CHK
RING_WAIT1:
        LAC     TMR3              	;if ring wait time > 8.0 sec, ring in fail
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
.END
