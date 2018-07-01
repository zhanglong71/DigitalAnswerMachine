.LIST
;---------------------------
SYS_MSG:
	LAC	MSG
	XORL	CSEG_END		;SEG_END
	BS	ACZ,SYS_SEG_END
SYS_MSG0:
	LAC	MSG
	XORL	CSEG_STOP		;SEG_STOP
	BS	ACZ,SYS_SEG_STOP
SYS_MSG1:
	LAC	MSG
	XORL	CMSG_TMR2		;时钟
	BS	ACZ,SYS_SYS_TMR
;---------------------------------------传递消息区
SYS_MSG2:
	;LAC	MSG
	;XORL	CREC_FULL		;REC_FULL
	;BS	ACZ,SYS_REC_FULL
SYS_MSG3:
	;LAC	MSG
	;XORL	CREC_STOP		;REC_STOP
	;BS	ACZ,SYS_REC_STOP
SYS_MSG4:	
	;LAC	MSG
	;XORL	CMSG_VOLA
	;BS	ACZ,SYS_VOL_ADD		;VOL+
SYS_MSG5:	
	;LAC	MSG
	;XORL	CMSG_VOLS
	;BS	ACZ,SYS_VOL_SUB		;VOL-
SYS_MSG6:	
	LAC	MSG
	XORL	CRING_OK
	BS	ACZ,SYS_MSG_RUN_ICM
SYS_MSG7:	
	LAC	MSG
	XORL	CMSG_LED
	BS	ACZ,SYS_LED_FLASH
SYS_MSG8:	
	LAC	MSG
	XORL	CNO_NMSG
	BS	ACZ,SYS_NO_NMSG
SYS_MSG9:	
	
SYS_MSG10:	
	LAC	MSG
	XORL	CMSG_SER
	BS	ACZ,SYS_SER_RUN

;============================================================功能区

SYS_MSG_NO:
	RET				;NO

SYS_MSG_YES:				;ACK
	LACK	0
	RET

;---------------
SYS_SEG_END:
	CALL	GET_VP
	BS	ACZ,SYS_SEG_END0
	CALL	INT_BIOS_START
	BS	B1,SYS_MSG_YES
SYS_SEG_END0:
	CALL	INIT_DAM_FUNC
	LACL	CVP_STOP		;通知系统播放完毕
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
;---
SYS_SEG_STOP:
	BS	B1,SYS_SEG_END0	
;---
SYS_REC_STOP:
	
	BS	B1,SYS_MSG_YES
;---
SYS_SYS_TMR:
	LAC	PRO_VAR2
	ADHK	1
	ANDL	0X7FFF
	SAH	PRO_VAR2
;---
	LAC	PRO_VAR2
	SBHK	1
	BZ	ACZ,SYS_SYS_TMR1
	LAC	RING_ID
	ANDK	0X0F
	BS	ACZ,SYS_SYS_TMR1
	SBH	RING_CNT
	BZ	ACZ,SYS_SYS_TMR1
	
	LACL	CRING_OK	;来铃次数达到摘机次数而且延后1秒后开始摘机
        CALL	STOR_MSG
        
        LACK	0
	SAH	RING_CNT
SYS_SYS_TMR1:
;---	
	LAC	PRO_VAR2
	;SBHK	8
	SBHK	6		;来铃次超时改为“6s”---2006/10/12
	BS	SGN,SYS_SYS_TMR2
	LACK	0
	SAH	RING_CNT
SYS_SYS_TMR2:
	BS	B1,SYS_MSG_YES
;-------
SYS_REC_FULL:
	;CALL	INIT_DAM_FUNC		;stop recording
	;SRAM	ANN_FG,13		;告诉"mcu"MEMOFUL(录音时的假memoful-12.8kbps/162s-4.8kbps/733s)

	;BS	B1,SYS_MSG_YES
;---
SYS_VOL_ADD:
	LAC	CODECREG2
	ANDL	0XFF0F
        SAH	CODECREG2
	
        LAC	VOI_ATT
        ANDL	0X07
        SBHK	7
        BS	ACZ,SYS_VOL_ADD1
        LAC	VOI_ATT
        ADHK	1
        SAH	VOI_ATT
SYS_VOL_ADD1:
	LAC	VOI_ATT
	ANDL	0X07
        ADHL    VOL_TAB
        RPTK    0
        TBR     SYSTMP
        LAC     SYSTMP    
        ORL	0X03
        OR	CODECREG2
        SAH	CODECREG2
	
	call    InSetCodecReg
	BS	B1,SYS_MSG_YES
SYS_VOL_SUB:
	LAC	CODECREG2
	ANDL	0XFF0F
        SAH	CODECREG2
	
	LAC	VOI_ATT
        ANDL	0X07
        BS	ACZ,SYS_VOL_SUB1
        LAC	VOI_ATT
	SBHK	1
        SAH	VOI_ATT
SYS_VOL_SUB1:
	LAC	VOI_ATT
	ANDL	0X07
        ADHL    VOL_TAB
        RPTK    0
        TBR     SYSTMP
        LAC     SYSTMP    
        ORL	0X03
        OR	CODECREG2
        SAH	CODECREG2
	
	call    InSetCodecReg
	BS	B1,SYS_MSG_YES
SYS_MSG_RUN_ICM:

	LACL	CNO_NMSG
	CALL	STOR_MSG	;LED不要闪烁了(进入答录)
	
     	CALL	CLR_FUNC	;先空
    	LACL	ICM_STATE
     	CALL	PUSH_FUNC
     	
     	CALL	REMT_EEXE
     	
     	LAC	RING_ID
     	SFL	12
     	SAH	RING_ID		;保存在最高四位
     	
  	LACL	CMSG_INIT
   	CALL	STOR_MSG
   	
   	LACK	0
   	SAH	PRO_VAR
  	BS	B1,SYS_MSG_YES
;-------
SYS_LED_FLASH:
	;BIT	EVENT,0
	;BS	TB,SYS_LED_FLASH1	;查是工作状态吗?
	LAC	EVENT
	ANDK	0X0F
	BZ	ACZ,SYS_LED_FLASH1
	
	CALL	LED_FLASH
	BS	B1,SYS_LED_FLASH_END
SYS_LED_FLASH1:
	CALL	LED_ON
SYS_LED_FLASH_END:
	BS	B1,SYS_MSG_YES
;-------
SYS_NO_NMSG:
	CALL	CLR_LEDTIMER
	CALL	LED_ON
	BS	B1,SYS_MSG_YES

;-------检查收到的命令
SYS_SER_RUN:
	
.IF	TEXT_SIOVP	;;;;;;;;;;;;;;;;;;;;;;;;;

	LAC	RECE_BUF1
	ANDL	0X0FF
	XORL	0X8F
	BS	ACZ,TEXTA11
	
	;CALL	INIT_DAM_FUNC
	;BS	B1,SYS_SER_RUN_ENDT
	
	LAC	RECE_BUF1		;BYTE 1(command)
	SFR	4
	ANDL	0X0F
	ORL	0XFF00
	CALL	STOR_VP
	LAC	RECE_BUF1
	ANDL	0X0F
	ORL	0XFF00
	CALL	STOR_VP
	
	LAC	RECE_BUF1		;BYTE 2(second)
	SFR	12
	ANDL	0X0F
	ORL	0XFF00
	CALL	STOR_VP
	LAC	RECE_BUF1
	SFR	8
	ANDL	0X0F
	ORL	0XFF00
	CALL	STOR_VP
;111111111111111111111111111111111111111111111111	
	LAC	RECE_BUF2
	ANDL	0X0FF
	SBHL	0X0FF
	BS	ACZ,SYS_SER_RUN_ENDT
	LAC	RECE_BUF2		;BYTE 3(minute)
	SFR	4
	ANDL	0X0F
	ORL	0XFF00
	CALL	STOR_VP
	LAC	RECE_BUF2
	ANDL	0X0F
	ORL	0XFF00
	CALL	STOR_VP
	
	LAC	RECE_BUF2		;BYTE 4(hour)
	SFR	12
	ANDL	0X0F
	ORL	0XFF00
	CALL	STOR_VP
	LAC	RECE_BUF2
	SFR	8
	ANDL	0X0F
	ORL	0XFF00
	CALL	STOR_VP
;222222222222222222222222222222222222222222222222	
	LAC	RECE_BUF3
	ANDL	0X0FF
	SBHL	0X0FF
	BS	ACZ,SYS_SER_RUN_ENDT
	LAC	RECE_BUF3		;BYTE 5(day)
	SFR	4
	ANDL	0X0F
	ORL	0XFF00
	CALL	STOR_VP
	LAC	RECE_BUF3
	ANDL	0X0F
	ORL	0XFF00
	CALL	STOR_VP
	
	LAC	RECE_BUF3		;BYTE 6(month)
	SFR	12
	ANDL	0X0F
	ORL	0XFF00
	CALL	STOR_VP
	LAC	RECE_BUF3
	SFR	8
	ANDL	0X0F
	ORL	0XFF00
	CALL	STOR_VP
;333333333333333333333333333333333333333333333333	
	LAC	RECE_BUF4
	ANDL	0X0FF
	SBHL	0X0FF
	BS	ACZ,SYS_SER_RUN_ENDT
	LAC	RECE_BUF4		;BYTE 7(year)
	SFR	4
	ANDL	0X0F
	ORL	0XFF00
	CALL	STOR_VP
	LAC	RECE_BUF4
	ANDL	0X0F
	ORL	0XFF00
	CALL	STOR_VP
TEXTA11:	;?????????????????	TEL length
	CALL	INIT_DAM_FUNC
	
	LAC	RECE_BUF4		;BYTE 8(TEL length)
	SFR	12
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
	LAC	RECE_BUF4
	SFR	8
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
;444444444444444444444444444444444444444444444444	
	LAC	RECE_BUF5		;BYTE 9(TEL NUM1)
	ANDL	0X0FF
	SBHL	0X0FF
	BS	ACZ,SYS_SER_RUN_ENDT
	LAC	RECE_BUF5
	SFR	4
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
	LAC	RECE_BUF5
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
	
	LAC	RECE_BUF5		;BYTE 10(TEL NUM2)
	SFR	12
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
	LAC	RECE_BUF5
	SFR	8
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
	
;555555555555555555555555555555555555555555555555
	LAC	RECE_BUF6		;BYTE 11(TEL NUM3)
	ANDL	0X0FF
	SBHL	0X0FF
	BS	ACZ,SYS_SER_RUN_ENDT
	LAC	RECE_BUF6
	SFR	4
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
	LAC	RECE_BUF6
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
	
	LAC	RECE_BUF6		;BYTE 12(TEL NUM4)
	SFR	12
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
	LAC	RECE_BUF6
	SFR	8
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
	
;66666666666666666666666666666666666666666666666
	LAC	RECE_BUF7		;BYTE 13(TEL NUM5)
	ANDL	0X0FF
	SBHL	0X0FF
	BS	ACZ,SYS_SER_RUN_ENDT
	LAC	RECE_BUF7
	SFR	4
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
	LAC	RECE_BUF7
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
	
	LAC	RECE_BUF7		;BYTE 14(TEL NUM6)
	SFR	12
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
	LAC	RECE_BUF7
	SFR	8
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
	
;77777777777777777777777777777777777777777777777
	LAC	RECE_BUF8		;BYTE 15(TEL NUM7)
	ANDL	0X0FF
	SBHL	0X0FF
	BS	ACZ,SYS_SER_RUN_ENDT
	LAC	RECE_BUF8
	SFR	4
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
	LAC	RECE_BUF8
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
	
	LAC	RECE_BUF8		;BYTE 16(TEL NUM8)
	SFR	12
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
	LAC	RECE_BUF8
	SFR	8
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
;888888888888888888888888888888888888888888888888
	LAC	RECE_BUF9		;BYTE 17(TEL NUM9)
	ANDL	0X0FF
	SBHL	0X0FF
	BS	ACZ,SYS_SER_RUN_ENDT
	LAC	RECE_BUF9
	SFR	4
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
	LAC	RECE_BUF9
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
	
	LAC	RECE_BUF9		;BYTE 18(TEL NUM10)
	SFR	12
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
	LAC	RECE_BUF9
	SFR	8
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
;999999999999999999999999999999999999999999999999
	LAC	RECE_BUF10
	ANDL	0X0FF
	SBHL	0X0FF
	BS	ACZ,SYS_SER_RUN_ENDT
	LAC	RECE_BUF10
	SFR	4
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
	LAC	RECE_BUF10
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
	
	LAC	RECE_BUF10
	SFR	12
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
	LAC	RECE_BUF10
	SFR	8
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
;AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	LAC	RECE_BUF11
	ANDL	0X0FF
	SBHL	0X0FF
	BS	ACZ,SYS_SER_RUN_ENDT
	LAC	RECE_BUF11
	SFR	4
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
	LAC	RECE_BUF11
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
	
	LAC	RECE_BUF11
	SFR	12
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
	LAC	RECE_BUF11
	SFR	8
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
;BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB
	LAC	RECE_BUF12
	ANDL	0X0FF
	SBHL	0X0FF
	BS	ACZ,SYS_SER_RUN_ENDT
	LAC	RECE_BUF12
	SFR	4
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
	LAC	RECE_BUF12
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
	
	LAC	RECE_BUF12
	SFR	12
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
	LAC	RECE_BUF12
	SFR	8
	ANDL	0X0F
	ADHK	1		;????????????????
	ORL	0XFF00
	CALL	STOR_VP
;CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
SYS_SER_RUN_ENDT:
	CALL	DAA_SPK	
	BS	B1,SYS_MSG_YES
.ELSE	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;for text end
SYS_SER_RUN1_1:
	LAC	RECE_BUF1
	ANDL	0X0FF
	XORL	0XA7
	BS	ACZ,SYS_SER_RUN_TEST
SYS_SER_RUN1_2:
	LAC	RECE_BUF1
	ANDL	0X0FF
	XORL	0X81
	BS	ACZ,SYS_SER_RUN_LANGUAGE
SYS_SER_RUN1_3:
	LAC	RECE_BUF1
	ANDL	0X0FF
	XORL	0X82
	BS	ACZ,SYS_SER_RUN_DATET
SYS_SER_RUN1_4:
	LAC	RECE_BUF1
	ANDL	0X0FF
	XORL	0X83
	BS	ACZ,SYS_SER_RUN_RINGN
SYS_SER_RUN1_5:
	
SYS_SER_RUN1_6:
	LAC	RECE_BUF1
	ANDL	0X0FF
	XORL	0X85
	BS	ACZ,SYS_SER_RUN_ONOFF
SYS_SER_RUN1_7:
	LAC	RECE_BUF1
	ANDL	0X0FF
	XORL	0X86
	BS	ACZ,SYS_SER_RUN_ONOFF
SYS_SER_RUN1_8:
	LAC	RECE_BUF1
	ANDL	0X0FF
	XORL	0X87
	BS	ACZ,SYS_SER_RUN_PSID
SYS_SER_RUN1_9:
	LAC	RECE_BUF1
	ANDL	0X0FF
	XORL	0X88
	BS	ACZ,SYS_SER_RUN_VPLEN
SYS_SER_RUN1_10:
	LAC	RECE_BUF1
	ANDL	0X0FF
	XORL	0X89
	BS	ACZ,SYS_SER_RUN_COMPR
SYS_SER_RUN1_11:
	LAC	RECE_BUF1
	ANDL	0X0FF
	XORL	0X8A
	BS	ACZ,SYS_SER_RUN_SOGM
SYS_SER_RUN1_12:
	LAC	RECE_BUF1
	ANDL	0X0FF
	XORL	0X8B
	BS	ACZ,SYS_SER_RUN_TELE
SYS_SER_RUN1_13:
	LAC	RECE_BUF1
	ANDL	0X0FF
	XORL	0X8C
	BS	ACZ,SYS_SER_EXIT_TELE
SYS_SER_RUN1_14:
	LAC	RECE_BUF1
	ANDL	0X0FF
	XORL	0X8F
	BS	ACZ,SYS_SER_RECEIVE_TELNUM
SYS_SER_RUN2:
	LAC	RECE_BUF1
	ANDL	0X0FF
	XORL	0X91
	BS	ACZ,SYS_SER_RUN_REC_OGM1
SYS_SER_RUN2_1:
	LAC	RECE_BUF1
	ANDL	0X0FF
	XORL	0X92
	BS	ACZ,SYS_SER_RUN_REC_OGM2
SYS_SER_RUN2_2:
	LAC	RECE_BUF1
	ANDL	0X0FF
	XORL	0X93
	BS	ACZ,SYS_SER_RUN_PLY_OGM1
SYS_SER_RUN2_3:
	LAC	RECE_BUF1
	ANDL	0X0FF
	XORL	0X94
	BS	ACZ,SYS_SER_RUN_PLY_OGM2
SYS_SER_RUN2_4:
	LAC	RECE_BUF1
	ANDL	0X0FF
	XORL	0X95
	BS	ACZ,SYS_SER_RUN_ERA_OGM
SYS_SER_RUN2_5:
	LAC	RECE_BUF1
	ANDL	0X0FF
	XORL	0X96
	BS	ACZ,SYS_SER_RUN_STOP
SYS_SER_RUN7:
	LAC	RECE_BUF1
	ANDL	0X0FF
	XORL	0XB1
	BS	ACZ,SYS_SER_RUN_PLY_MSG
SYS_SER_RUN8:
	;LAC	RECE_BUF1
	;ANDL	0X0FF
	;XORL	0XB2
	;BS	ACZ,SYS_SER_RUN_PLY_PAUSE	;在接收时已处理
SYS_SER_RUN9:
	LAC	RECE_BUF1
	ANDL	0X0FF
	XORL	0XB3
	BS	ACZ,SYS_SER_RUN_PLY_ERA
SYS_SER_RUN10:
	LAC	RECE_BUF1
	ANDL	0X0FF
	XORL	0XB4
	BS	ACZ,SYS_SER_RUN_ERAALL
SYS_SER_RUN11:
	LAC	RECE_BUF1
	ANDL	0X0FF
	XORL	0XB5
	BS	ACZ,SYS_SER_RUN_PLY_FFW
SYS_SER_RUN12:
	LAC	RECE_BUF1
	ANDL	0X0FF
	XORL	0XB6
	BS	ACZ,SYS_SER_RUN_PLY_REW
SYS_SER_RUN13:
	LAC	RECE_BUF1
	ANDL	0X0FF
	XORL	0XA1
	BS	ACZ,SYS_SER_RUN_REC_MSG
SYS_SER_RUN14:
	LAC	RECE_BUF1
	ANDL	0X0FF
	XORL	0XA2
	BS	ACZ,SYS_SER_RUN_REC_TWAY
SYS_SER_RUN15:
	LAC	RECE_BUF1
	ANDL	0X0FF
	XORL	0XA3
	BS	ACZ,SYS_SER_RUN_FORMAT
SYS_SER_RUN16:
	LAC	RECE_BUF1
	ANDL	0X0FF
	XORL	0XA5
	BS	ACZ,SYS_SER_RUN_PLY_ERA
SYS_SER_RUN17:
	LAC	RECE_BUF1
	ANDL	0X0FF
	XORL	0XA6
	BS	ACZ,SYS_SER_RUN_RINGIN
SYS_SER_RUN18:
	;LAC	RECE_BUF1
	;ANDL	0X0FF
	;XORL	0X96
	;BS	ACZ,SYS_SER_RUN_RECMSG_STOP	;在接收时已处理
	
	BS	B1,SYS_MSG_YES
.ENDIF	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;-------处理命令
SYS_SER_RUN_TEST:
	LACL	CMSG_TEST
	CALL	STOR_MSG

	BS	B1,SYS_MSG_YES
SYS_SER_RUN_LANGUAGE:
	LAC	RECE_BUF1
	SFR	8
	ANDL	0X0FF
	SAH	LANGUAGE
	BS	B1,SYS_MSG_YES
;---
SYS_SER_RUN_DATET:
	LAC	RECE_BUF1
	SFR	8
	ANDL	0X0FF
	CALL	DGT_HEX
	SAH	TMR_YEAR	;年
;---
	LAC	RECE_BUF2
	ANDL	0XFF
	CALL	DGT_HEX
	SAH	TMR_MONTH	;月
	
	LAC	RECE_BUF2
	SFR	8
	ANDL	0XFF
	CALL	DGT_HEX
	SAH	TMR_DAY		;日
;---
	LAC	RECE_BUF3
	ANDL	0XFF
	CALL	DGT_HEX
	SAH	TMR_WEEK	;星期
	
	LAC	RECE_BUF3
	SFR	8
	ANDL	0XFF
	CALL	DGT_HEX
	SAH	TMR_HOUR	;时
;---	
	LAC	RECE_BUF4
	ANDL	0XFF
	CALL	DGT_HEX
	SAH	TMR_MIN		;分
	
	LAC	RECE_BUF4
	SFR	8
	ANDL	0XFF
	CALL	DGT_HEX
	SAH	TMR_SEC		;秒
	BS	B1,SYS_MSG_YES
;---
SYS_SER_RUN_REC_OGM1:
	;CRAM	EVENT,8
	LACK	3
	SAH	MSG_N
	
	LACL	CMSG_KEY3L
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
;---
SYS_SER_RUN_REC_OGM2:
	;SRAM	EVENT,8
	LACK	4
	SAH	MSG_N
	
	LACL	CMSG_KEY3L
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
;---	
SYS_SER_RUN_PLY_OGM1:
	;CRAM	EVENT,8
	LACK	3
	SAH	MSG_N
	
	LACL	CMSG_KEY3S
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
;---
SYS_SER_RUN_PLY_OGM2:
	;SRAM	EVENT,8
	LACK	4
	SAH	MSG_N
	
	LACL	CMSG_KEY3S
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
;---
SYS_SER_RUN_ERA_OGM:
	LACL	CMSG_KEY5S
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
;---
SYS_SER_RUN_STOP:
	LACL	CMSG_KEY6S
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
;---
SYS_SER_RUN_PLY_MSG:
	LACL	CMSG_KEY1S
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
;---
;SYS_SER_RUN_PLY_PAUSE:
	;LACL	CSEG_PAUSE
	;CALL	STOR_MSG
	;BS	B1,SYS_MSG_YES
;---
SYS_SER_RUN_PLY_ERA:
	LACL	CMSG_KEY5S
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
;---
SYS_SER_RUN_ERAALL:
	LACL	CMSG_KEY5L
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
;---
SYS_SER_RUN_PLY_FFW:
	LACL	CMSG_KEYCS
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
;---
SYS_SER_RUN_PLY_REW:
	LACL	CMSG_KEY8S
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
;---
SYS_SER_RUN_REC_MSG:
	LACL	CMSG_KEY4L
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
;---
SYS_SER_RUN_REC_TWAY:
	LACL	CNO_NMSG
	CALL	STOR_MSG	;LED不要闪烁了(进入答录)
	
	CALL	CLR_FUNC	;先空
    	LACL	TWAY_STATE
     	CALL	PUSH_FUNC
     	
     	CALL	REMT_EEXE
     	
     	LAC	RING_ID
     	SFL	12
     	SAH	RING_ID		;保存在最高四位
     	
  	LACL	CMSG_INIT
   	CALL	STOR_MSG
   	
   	LACK	0
   	SAH	PRO_VAR

	BS	B1,SYS_MSG_YES
;---
SYS_SER_RUN_FORMAT:
	CALL	CLR_TIMER
	
	LACL	0X9051
	SAH	CONF
	CALL	DAM_BIOS
	
	LACL    0XD109		;12.8kbps
	SAH	CONF
	CALL	DAM_BIOS
	
	LACK	0
	SAH	PASSWORD
	SAH	LANGUAGE
	
	LACK	10
        SAH	RING_ID
        SRAM	EVENT,9
        CRAM	EVENT,8
        
        LACK	6
        SAH	RING_ID_BAK
        
        
        
	LACL	CMSG_INIT
	CALL	STOR_MSG
	BS	B1,SYS_MSG_YES
;---
;SYS_SER_RUN_RECMSG_STOP:
	;LACL	CMSG_KEY6S
	;CALL	STOR_MSG
	;BS	B1,SYS_MSG_YES
;---
SYS_SER_RUN_RINGN:
	LACK	10
	SAH	RING_ID
	BIT	EVENT,9
	BS	TB,SYS_SER_RUN_RINGN_END
	
	LAC	RECE_BUF1
	SFR	8
	ANDL	0XFF
	SAH	RING_ID_BAK
	SAH	RING_ID
SYS_SER_RUN_RINGN_END:
	BS	B1,SYS_MSG_YES
;---
SYS_SER_RUN_RINGIN:
	LAC	RING_CNT
	BZ	ACZ,SYS_SER_RUN_RINGIN1
	
	LACL	CMSG_KEY6S
	CALL	STOR_MSG
	LACL	CMSG_KEY6S
	CALL	STOR_MSG

	LACK	1
	SAH	RING_CNT
	
	LACK	0
	SAH	PRO_VAR2
	
	LACL	1000
	CALL	SET_TIMER
	BS	B1,SYS_SER_RUN_RINGIN2
SYS_SER_RUN_RINGIN1:
	LAC	PRO_VAR2
	SBHK	2
	BS	SGN,SYS_SER_RUN_RINGIN2		;两次来铃时间间隔大于2秒
	
	LAC	RING_CNT
	ADHK	1
	SAH	RING_CNT
	
	LACK	0
	SAH	PRO_VAR2	
SYS_SER_RUN_RINGIN2:
		
	BS	B1,SYS_MSG_YES
;---
SYS_SER_RUN_ONOFF:
	CRAM	EVENT,9
	LACK	2
	SAH	RING_ID
	
	LAC	RING_ID_BAK
	BS	ACZ,SYS_SER_RUN_ONOFF_1
	SAH	RING_ID
SYS_SER_RUN_ONOFF_1:	
	LAC	RECE_BUF1
	SBHL	0X85
	BS	ACZ,SYS_SER_RUN_ONOFF_END
	SRAM	EVENT,9
	LAC	RING_ID
	ANDK	0X0F
	SAH	RING_ID_BAK
	
	LACK	10
	SAH	RING_ID
SYS_SER_RUN_ONOFF_END:	
	BS	B1,SYS_MSG_YES
;-------
SYS_SER_RUN_PSID:
;---PS1
	LAC	PASSWORD
	ANDL	0X0FFF
	SAH	PASSWORD

	LAC	RECE_BUF1
	SFL	4
	ANDL	0XF000
	OR	PASSWORD
	SAH	PASSWORD
;---PS2	
	LAC	PASSWORD
	ANDL	0XF0FF
	SAH	PASSWORD

	LAC	RECE_BUF2
	SFL	8
	ANDL	0X0F00
	OR	PASSWORD
	SAH	PASSWORD
;---PS3	
	LAC	PASSWORD
	ANDL	0XFF0F
	SAH	PASSWORD
	
	LAC	RECE_BUF2
	SFR	4
	ANDL	0X00F0
	OR	PASSWORD
	SAH	PASSWORD
;---PS4	
	LAC	PASSWORD
	ANDL	0XFFF0
	SAH	PASSWORD
	
	LAC	RECE_BUF3
	ANDK	0X0F
	OR	PASSWORD
	SAH	PASSWORD
	
	BS	B1,SYS_MSG_YES
;---
SYS_SER_RUN_VPLEN:
	LAC	RECE_BUF1
	SFR	8
	ANDL	0X0FF
	SAH	VPLEN		;录音最短长度
	BS	B1,SYS_MSG_YES
;---
SYS_SER_RUN_COMPR:
	CALL	INIT_DAM_FUNC	
	
	LACL    0XD109		;12.8kbps
	SAH	CONF
	
	LAC	RECE_BUF1
	SFR	8
	ANDK	0X7F	
	BS	ACZ,SYS_SER_RUN_COMPR1
	
	LACL    0XD101		;4.8kbps
	SAH	CONF
SYS_SER_RUN_COMPR1:
	CALL	DAM_BIOS	
	BS	B1,SYS_MSG_YES
;---
SYS_SER_RUN_SOGM:
	CRAM	EVENT,8
	
	LACK	3
	SAH	MSG_N
	
	LAC	RECE_BUF1
	SFR	8
	ANDK	0X7F
	BS	ACZ,SYS_SER_RUN_SOGM1
	
	LACK	4
	SAH	MSG_N
	
	SRAM	EVENT,8
SYS_SER_RUN_SOGM1:		;初始化时为0,收到选择OGM命令时不播放相应OGM
	BS	B1,SYS_MSG_YES
SYS_SER_RUN_TELE:
	SRAM	EVENT,0
	
	;LACL	CNO_NMSG
	;CALL	STOR_MSG	;LED不要闪烁了(进入通话状态)
	BS	B1,SYS_MSG_YES
SYS_SER_EXIT_TELE:
	CRAM	EVENT,0
	
	;LACL	CMSG_INIT
	;CALL	STOR_MSG	;LED要闪烁了(退出通话状态)
	BS	B1,SYS_MSG_YES
SYS_SER_RECEIVE_TELNUM:
.IF	TEXT_m58
	CALL	TELNUM_WRITE
.ENDIF
	BS	B1,SYS_MSG_YES
;-----------------------------------------------------------------------
;DAM_BIOS的软中断程序:record/play/beep/VoicePrompt/line
;-----------------------------------------------------------------------
INT_BIOS:
	BIT	EVENT,7
	BS	TB,INT_BIOS_REC		;RECORD
	BIT	EVENT,6
	BS	TB,INT_BIOS_PLAY	;PLAY
	BIT	EVENT,5
	BS	TB,INT_BIOS_END		;BEEP不作处理
	BIT	EVENT,4
	BS	TB,INT_BIOS_LINE	;LINE
	CALL	GET_VP
	BZ	ACZ,INT_BIOS_START

	
	RET
;---
INT_BIOS_LINE:				;line mode
	LACL	0X5000
	SAH	CONF
	CALL	DAM_BIOS
	
	BS	B1,INT_BIOS_RESP
INT_BIOS_REC:				;record mode
	CALL	DAM_BIOS
	BIT	RESP,7
	BZ	TB,INT_BIOS_RESP
	
	LACL	CREC_FULL		;产生FLASH满消息
	CALL	STOR_MSG
	BS	B1,INT_BIOS_RESP
;---
INT_BIOS_PLAY:				;play(voice prompt) mode
	CALL	DAM_BIOS
	BIT	RESP,6
	BZ	TB,INT_BIOS_RESP
	
	LACL	CSEG_END
	CALL	STOR_MSG		;产生结束消息
	BS	B1,INT_BIOS_RESP
;---------
;---------
INT_BIOS_RESP:
	
;---------
;---------
INT_BIOS_RESP_VOX:
	CALL	VOX_CHK
	BS	ACZ,INT_BIOS_RESP_VOX_END
	LACL	CMSG_VOX
	CALL	STOR_MSG
INT_BIOS_RESP_VOX_END:	
;---------
;---------	
INT_BIOS_RESP_DTMF:
	CALL	DTMF_CHK
	BS	ACZ,INT_BIOS_RESP_DTMF_END
	LACL	CREV_DTMF
	CALL	STOR_MSG
INT_BIOS_RESP_DTMF_END:
;---------
;---------
INT_BIOS_RESP_CTONE:
	CALL	CTONE_CHK
	BS	ACZ,INT_BIOS_RESP_CTONE_END
	LACL	CMSG_CTONE
	CALL	STOR_MSG
INT_BIOS_RESP_CTONE_END:
;---------
;---------
INT_BIOS_RESP_BTONE:
	CALL	BTONE_CHK
	BS	ACZ,INT_BIOS_RESP_BTONE_END
	LACL	CMSG_BTONE
	CALL	STOR_MSG
INT_BIOS_RESP_BTONE_END:
;---------
INT_BIOS_END:
	
	RET
;----
;----
INT_BIOS_START:
	SAH	SYSTMP
	CALL	DAM_STOP
	
	LAC	SYSTMP
	ANDL	0XFF
	SAH	SYSTMP0
	
	LAC	SYSTMP
	SFR	8
	SAH	SYSTMP1
	
	SBHL	0XFF
	BS	ACZ,INT_BIOS_START_VP
	LAC	SYSTMP1
	SBHL	0XFE
	BS	ACZ,INT_BIOS_START_PLAY_TOTAL
	LAC	SYSTMP1
	SBHL	0XFD
	BS	ACZ,INT_BIOS_START_PLAY_NEW
INT_BIOS_START_BEEP:
	LAC	SYSTMP0
	SFL	3
	SAH	TMR_BEEP		;length of time
	LAC	SYSTMP1
	SFL	8
	BS	ACZ,INT_BIOS_START_BEEP_END	;frequency = 0
	SAH	BUF1			;frequency
	
	LACL	CBEEP_COMMAND		;ON
	SAH	CONF
	CALL    DAM_BIOS
INT_BIOS_START_BEEP_END:	
	LAC	EVENT
	ORK	0X20			;SET flag(bit5)
	SAH	EVENT

	RET
;---
INT_BIOS_START_PLAY_TOTAL:
	LAC	SYSTMP0
	ORL	0X2000
	SAH	CONF
	BS	B1,INT_BIOS_START_VP_FLAG
;---
INT_BIOS_START_PLAY_NEW:
	LAC	SYSTMP0
	ORL	0X2400
	SAH	CONF
	BS	B1,INT_BIOS_START_VP_FLAG
;---
INT_BIOS_START_VP:
	LAC	SYSTMP0
	ORL	0XB000
	SAH	CONF
INT_BIOS_START_VP_FLAG:
	LAC	EVENT
	ORK	0X40		;set flag(bit6)
	SAH	EVENT
	RET
;---
INIT_DAM_FUNC:
	CALL	DAM_STOP	;停止DAM_BIOS
	LACK	0
	SAH	VP_QUEUE	;发声队列清空
	RET
;---

DAM_STOP:			;关闭前面操作和标志位并设成IDLE模式
	LACK	0
	SAH	TMR_BEEP	;BEEP TMR清
	LAC	EVENT
	ANDL	0XFF0F
	SAH	EVENT		;标志清空
	
	LAC	CONF
	BS	ACZ,DAM_STOP_IDLE
	SFR	12
	SBHK	1
	BS      ACZ,DAM_STOP_REC	;// 0X1000
	SBHK	1
	BS      ACZ,DAM_STOP_PLAY	;// 0X2000
	SBHK	2
	BS      ACZ,DAM_STOP_BEEP	;// 0X4000
	SBHK	1
	BS      ACZ,DAM_STOP_LINE	;// 0X5000
	SBHK	6
	BS      ACZ,DAM_STOP_PLAY	;// 0XB000
	BS	B1,DAM_STOP_IDLE
DAM_STOP_REC:
	LAC	CONF
	ORK	0X40
	SAH	CONF
	CALL	DAM_BIOS
	BS	B1,DAM_STOP_IDLE
DAM_STOP_LINE:
	LACL    0X5001
	SAH     CONF
	CALL    DAM_BIOS
	BS	B1,DAM_STOP_IDLE
DAM_STOP_PLAY:
	LAC	CONF
	ORL     0X0200
	SAH	CONF
	CALL	DAM_BIOS
	BS	B1,DAM_STOP_IDLE
DAM_STOP_BEEP:
	LAC	CONF
	ORL     0X0400
	SAH	CONF
	CALL	DAM_BIOS
DAM_STOP_IDLE:				;// IDLE MODE
	LACK	0
	SAH     CONF
	
	RET
;----------------------------------------------------------------------------
;	Function : REC_START
;	input : no
;	output: no
;----------------------------------------------------------------------------
REC_START:
	LAC	EVENT
	ANDL	0XFF0F
	ORL	0X080
	SAH	EVENT
	
	LACL	0X1000
	SAH	CONF
	
	RET
;----------------------------------------------------------------------------
;	Function : LINE_START
;	input : no
;	output: no
;----------------------------------------------------------------------------
LINE_START:
	LAC	EVENT
	ANDL	0XFF0F
	ORL	0X010
	SAH	EVENT
	
	LACL	0X5000
	SAH	CONF
	
	RET
;----------------------------------------------------------------------------
;       Function : GC_CHK
;
;       Check garbage collection
;----------------------------------------------------------------------------
GC_CHK:
	LACL	GCVP_TLEN
	SAH	TMR_CTONE
GC_CHK_LOOP:
	LACL	0X3003
	SAH	CONF
	CALL	DAM_BIOS
	LAC	RESP
	SBHL	200		  	;剩下200秒?
	BZ	SGN,GC_CHK_1
	
	LACL    0X3007   		; do garbage collection
        SAH     CONF
        CALL    DAM_BIOS
GC_CHK_1:
        LACL    0X9004   		; do garbage collection
        SAH     CONF
        CALL    DAM_BIOS
        
	BIT	ANN_FG,13
        BZ	TB,GC_CHK_NEXT
        LAC	TMR_CTONE
        BS	SGN,GC_CHK_RTN
GC_CHK_NEXT:
	LACL    0X3005           	; check if garbage collection is required ?
        SAH     CONF
        CALL    DAM_BIOS
        LAC     RESP
        BZ      ACZ,GC_CHK_LOOP
GC_CHK_RTN:	
	LACL    0X9050   		; do garbage collection
        SAH     CONF
        CALL    DAM_BIOS

	RET
;----------------------------------------------------------------------------
;       Function : TEL_GC_CHK
;
;       Check garbage collection
;----------------------------------------------------------------------------
.IF	0
TEL_GC_CHK:
        LACL    0XE405            ; check if garbage collection is required ?
        SAH     CONF
        CALL    DAM_BIOS
        LAC     RESP
        BS      ACZ,TEL_GC_CHK_RTN

        LACL    0XE407          ; do garbage collection
        SAH     CONF
        CALL    DAM_BIOS
        BS      B1,TEL_GC_CHK       ; L111S2
TEL_GC_CHK_RTN:
        RET
.ELSE
;-------------------------------------------------------------------------------
TEL_GC_CHK:
	LACL	GCTEL_TLEN
	SAH	TMR_CTONE
TEL_GC_LOOP:
        LACL    0XE407          ; do garbage collection first
        SAH     CONF
        CALL    DAM_BIOS
	
	BIT	ANN_FG,13
	BZ	TB,TEL_GC_NEXT
	LAC	TMR_CTONE
	BS	SGN,TEL_GC_CHK_RTN
TEL_GC_NEXT:	
        LACL    0XE405            ; check if garbage collection is required ?
        SAH     CONF
        CALL    DAM_BIOS

        LAC     RESP
        BZ      ACZ,TEL_GC_LOOP

TEL_GC_CHK_RTN:
        RET
.ENDIF
;----------------------------------------------------------------------------
;	Function : ACK_H
;	input : no
;	output: no
;----------------------------------------------------------------------------
ACK_H:
	lipk    0
	SIO	11,OPTR		;ACK ON---(OPTR.11)
	RET
;----------------------------------------------------------------------------
;	Function : ACK_L
;	input : no
;	output: no
;----------------------------------------------------------------------------
ACK_L:
	lipk    0
	CIO	11,OPTR		;ACK OFF---(OPTR.11)
	RET
;----------------------------------------------------------------------------
;	Function : IDMONIT_ON
;	input : no
;	output: no
;----------------------------------------------------------------------------
IDMONIT_ON:
	lipk    0
	SIO	14,OPTR		;in door monitor---(OPTR14)
	RET
;----------------------------------------------------------------------------
;	Function : IDMONIT_OFF
;	input : no
;	output: no
;----------------------------------------------------------------------------
IDMONIT_OFF:
	lipk    0
	CIO	14,OPTR		;in door monitor end---(OPTR14)
	RET
;----------------------------------------------------------------------------
;	Function : LED_ON
;	input : no
;	output: no
;----------------------------------------------------------------------------
LED_ON:
	lipk    0
	SIO	12,OPTR		;LED ON---OPTR(bit12)
	RET
;----------------------------------------------------------------------------
;	Function : LED_OFF
;	input : no
;	output: no
;----------------------------------------------------------------------------
LED_OFF:
	lipk    0
	CIO	12,OPTR		;LED OFF---OPTR(bit12)
	RET
;----------------------------------------------------------------------------
;	Function : LED_FLASH
;	input : no
;	output: no
;----------------------------------------------------------------------------
LED_FLASH:
	lipk    0
	BINV	12,OPTR		;LED FLASH---OPTR(bit12)
	
	LACL	1000
	CALL	SET_LEDTIMER	;要求HIGH/LOW=1/0.3
	
	IN      SYSTMP,OPTR
        BIT     SYSTMP,12
        BS	TB,LED_FLASH_END
	
	LACL	300
	CALL	SET_LEDTIMER
	
LED_FLASH_END:	
	RET
;----------------------------------------------------------------------------
;	Function : REC_EEXE
;	input : no
;	output: no
;----------------------------------------------------------------------------
REC_EEXE:
	SRAM	EVENT,1
	RET
;----------------------------------------------------------------------------
;	Function : REC_EEND
;	input : no
;	output: no
;----------------------------------------------------------------------------
REC_EEND:
	CRAM	EVENT,1
	RET
;----------------------------------------------------------------------------
;	Function : PLY_EEXE
;	input : no
;	output: no
;----------------------------------------------------------------------------
PLY_EEXE:
	SRAM	EVENT,2
	RET
;----------------------------------------------------------------------------
;	Function : PLY_EEND
;	input : no
;	output: no
;----------------------------------------------------------------------------
PLY_EEND:
	CRAM	EVENT,2
	RET
;----------------------------------------------------------------------------
;	Function : REMT_EEXE
;	input : no
;	output: no
;----------------------------------------------------------------------------
REMT_EEXE:
	SRAM	EVENT,3
	RET
;----------------------------------------------------------------------------
;	Function : REMT_EEND
;	input : no
;	output: no
;----------------------------------------------------------------------------
REMT_EEND:
	CRAM	EVENT,3
	RET
;----------------------------------------------------------------------------
;       Function : DTMF_CHK
;
;       The general routine used in remote line operation. It checks VOX,
;       BUSY TONE, DTMF, MEMORY FULL, POWER DOWN, ...
;       Input  : CONF (Record Mode, Play Mode, Line Mode or Voice Prompt Mode)
;       Output : ACCH = 0  -  One DTMF detected
;                ACCH = 1  -  Play end

;		 DTMF_VAL  =  DTMF value
;       Parameters:
;               8. ANN_FG.7 - store the detected DTMF flag
;----------------------------------------------------------------------------
DTMF_CHK:
        LAC     RESP              	;check the DTMF value ?
        ANDK    0X0F
        BS      ACZ,DTMF_CHK1

        ADHL    DTMF_TABLE
        RPTK    0
        TBR     SYSTMP
        LAC     SYSTMP
        SAH     DTMF_VAL          	;save the DTMF value in DTMF_VAL
        
        LAC     ANN_FG
        ORL	0X80
        SAH     ANN_FG
        BS      B1,DTMF_CHK_END
DTMF_CHK1:
        BIT     ANN_FG,7
        BZ      TB,DTMF_CHK_END
DTMF_CHK2:
        LAC     ANN_FG
        ANDL    0XFF7F
        SAH     ANN_FG

        LACK    1                 	; DTMF detected, return ACCH=1
        RET
DTMF_CHK_END:
	LACK	0
	
	RET
;----------------------------------------------------------------------------
;       Function : CTONE_CHK
;
;       The general routine used in remote line operation. It checks CONT TONE
;       Input  : CONF (Record Mode, Line Mode)
;       Output : ACCH = 1  -  continuous tone period found
;                ACCH = 0  -  no continuous tone period found
;       Parameters:
;               1. TMR_CTONE     - for continuous tone detection
;----------------------------------------------------------------------------
CTONE_CHK:
	
        BIT     RESP,4            	; check if continuous tone happens ?
        BS      TB,CTONE_CHK_ON
        LACL    8000              	; continuous tone off
        SAH     TMR_CTONE
CTONE_CHK_ON:
        LAC     TMR_CTONE
        BZ      SGN,CTONE_CHK_ON_2
        LAC     CONF
        SFR     12
        SBHK    1
        BZ      ACZ,CTONE_CHK_ON_1
        LAC     CONF
        ORK     20                	;//continuous tone period found and do
        SAH     CONF              	;//tail cut of 8.0 sec
CTONE_CHK_ON_1:	
        LACK    1                 	; continuous tone period found, return ACCH=0
        RET
CTONE_CHK_ON_2:
	LACK    0
        RET
;----------------------------------------------------------------------------
;       Function : VOX_CHK
;
;       The general routine used in remote line operation. It checks VOX
;       Input  : CONF (Record Mode)
;       Output : ACCH = 1  -  VOX found over 8.0 sec
;                ACCH = 0  -  no VOX found over 8.0 sec
;               
;       Parameters:
;               1. TMR_VOX - for VOX detection(initial TMR8=VOX time)
;----------------------------------------------------------------------------
VOX_CHK:				; check the VOX
        BIT     RESP,6
        BZ      TB,VOX_CHK_OFF
VOX_CHK_ON:                     ; VOX on
        LAC     TMR_VOX
        BZ      SGN,VOX_CHK_END
        LAC	CONF
        SFR	12
        SBHK	1
	BZ	ACZ,VOX_CHK_ON_1
        LAC     CONF
        ORK     20                ; VOX over 8.0 sec and do tail cut of 8.0 sec
        SAH     CONF
VOX_CHK_ON_1:
        LACK    1                 ; VOX found over 8.0 sec, return ACCH=5
        RET
VOX_CHK_OFF:                     ; VOX off
        LACL    8000              ; restore 8.0 sec in TMR8
        SAH     TMR_VOX
VOX_CHK_END:
	LACK    0
	RET
;----------------------------------------------------------------------------
;       Function : BTONE_CHK
;
;       The general routine used in remote line operation. It checks BUSY TONE
;       Input  : CONF (Record Mode, Play Mode, Line Mode or Voice Prompt Mode)
;       Output : ACCH = 1  -  Busy tone
;                ACCH = 0  -  NO Busy tone
;
;       Parameters:
;               3. TMR_BTONE     - for busy tone detection
;               4. BTONE_BUF    - store the total time of busy tone
;               5. BUF1     - store the last on time of busy tone
;               6. BUF2     - store the last off time of busy tone
;               7. BUF3     - store some flags for busy tone detection
;                  (see BUF3.DOC)
;----------------------------------------------------------------------------
BTONE_CHK:
        BIT     RESP,5
        BZ      TB,BTONE_CHK_OFF
BTONE_CHK_ON:                    	; busy tone on
        BIT     BUF3,5            	; check if transition from busy tone off ?
        BZ      TB,BTONE_CHK_ON_ONTON
                                  	; enter busy tone on first time
        LAC     TMR_BTONE              	; if busy tone off time < 60 ms, fails
        ;SBHK    15
        SBHK    50		;change1 2006/11/04(busy tone off time < 200 ms, fails)
        BS      SGN,BTONE_CHK_ON_FAIL

        LAC     BUF3
        ANDL    0XCF
        ORK     0X10              	; set 'in busy tone on' bit to 1
        SAH     BUF3

        BIT     BUF3,7            	; check if the first busy tone off to on
        BS      TB,BTONE_CHK_ON1_1 	; has happened ?
                                  	; from busy tone off to on first time
        LAC     BUF3
        ORL     0X80
        SAH     BUF3
        BS      B1,BTONE_CHK_ON1_2
BTONE_CHK_ON1_1:
        SOVM
        LAC     TMR_BTONE              	; TMR_BTONE=the current busy tone off time
        SBH     BUF2              	; BUF2=the last busy tone off time
        ABS                       	; the difference between TMR_BTONE and BUF2
        ROVM                      	;   must be < 64 ms
        SBHK    0X10
        BZ      SGN,BTONE_CHK_ON_FAIL
        
        LAC     TMR_BTONE	;change2 2006/11/04(the 400ms<TONEon + TONEoff<1400ms)
        ADH	BUF1
        SBHL	100
        BS      SGN,BTONE_CHK_ON_FAIL
        SBHL	250
        BZ      SGN,BTONE_CHK_ON_FAIL
BTONE_CHK_ON1_2:
        LAC     BTONE_BUF             	; BTONE_BUF store the total busy tone time
        ADH     BUF1              	; add the last busy tone on time to BTONE_BUF
        SAH     BTONE_BUF

        LAC     BUF3
        ADHK    1                 	; increase the 'tone on/off count' by 1
        SAH     BUF3
        ANDK    0X0F
        SBHK    5                 	; if the 'tone on/off count' >= 5, busy tone
        BS      SGN,BTONE_CHK_ON1_5 	;   period found
BTONE_CHK_ON1_3: 
	;LAC	CONF
	;SFR	12
	;SBHK	1
	;BZ	ACZ,BTONE_CHK_ON1_4	;record mode or not?
	                  		; busy tone period found
        ;LAC     BTONE_BUF
	;ADH     TMR_BTONE
        ;SFR     6                 	; tail cut base 400 ms
        ;ANDK    0X3F              	; cut units ~= (SFR 6 + SFR 7) / 2
        ;SAH     BTONE_BUF
        ;SFR     1
        ;ADH     BTONE_BUF
        ;SFR     1
        ;SAH     BTONE_BUF

        ;LAC     CONF
        ;OR      BTONE_BUF
        ;SAH     CONF
BTONE_CHK_ON1_4:        
        LACK    1                 	; busy tone period found, return ACCH=0
        RET

BTONE_CHK_ON1_5:
        LAC     TMR_BTONE
        SAH     BUF2              	; save the current busy tone off time in BUF2

        LACK    0
        SAH     TMR_BTONE
        BS      B1,BTONE_CHK_END
BTONE_CHK_ON_FAIL:                    	; busy tone fails
        LAC     TMR_BTONE
        SAH     BUF2
        SAH     BTONE_BUF

        LACK    0
        SAH     TMR_BTONE
        SAH     BUF1

        LACL    0X90              	; set first busy tone off to on happened
        SAH     BUF3              	; set 'in busy tone on' bit to 1
        BS      B1,BTONE_CHK_END
BTONE_CHK_ON_ONTON:
        LAC     BUF3
        ANDL    0XCF
        ORK     0X10
        SAH     BUF3

        LAC     TMR_BTONE            	; FOR FIRST BUSY TONE > 7.0 SEC CHECK
        SBHL    1750            	; BUSY TONE 7.0 SEC
        BS      SGN,BTONE_CHK_END

        LAC     TMR_BTONE            	; OVER 7.0 SECOND BUSY TONE CONTINOUS
        SAH     BTONE_BUF
        LACK    0
        SAH     TMR_BTONE
        BS      B1,BTONE_CHK_ON1_3  	; JUMP TO TAIL CUT
BTONE_CHK_OFF:                   	; busy tone off
        BIT     BUF3,4            	; check if transition from busy tone on ?
        BZ      TB,BTONE_CHK_OFF_OFFTOFF

        LAC     TMR_BTONE              	; if busy tone on time < 60 ms, fails
        ;SBHK    15
        SBHK    50		;change3 2006/11/04(busy tone on time < 200 ms, fails)
        BS      SGN,BTONE_CHK_OFF_FAIL
        SBHK	125		;change4 2006/11/04(busy tone on time > 700 ms, fails)
	BZ      SGN,BTONE_CHK_OFF_FAIL

        LAC     BUF3
        ANDL    0XCF
        ORK     0X20              	; set 'in busy tone off' bit to 1
        SAH     BUF3

        BIT     BUF3,6             	; check if the first busy tone on to off
        BS      TB,BTONE_CHK_OFF1_1 	;   has happened ?
                                   	; from busy tone on to off first time
        LAC     TMR_BTONE
        SAH     BUF1

        LAC     BUF3
        ORK     0X40
        SAH     BUF3
        BS      B1,BTONE_CHK_OFF1_2
BTONE_CHK_OFF1_1:
        SOVM
        LAC     TMR_BTONE		; TMR_BTONE=the current busy tone on time
        SBH     BUF1              	; BUF2=the last busy tone on time
        ABS                       	; the difference between TMR_BTONE and BUF1
        ROVM                      	;   must be < 64 ms
        SBHK    0X10
        BZ      SGN,BTONE_CHK_OFF_FAIL

        LAC     BTONE_BUF             	; BTONE_BUF store the total busy tone time
        ADH     BUF2              	; add the last busy tone off time to BTONE_BUF
        SAH     BTONE_BUF

        ;LAC     BUF3
        ;ADHK    1                 	; increase the 'tone on/off count' by 1
        ;SAH     BUF3		;change5 2006/11/04(increase the tone on/off only in "off to on")
        
        LAC     TMR_BTONE
        SAH     BUF1              	; save the current busy tone on time in BUF1
BTONE_CHK_OFF1_2:
        LACK    0                 	; reset TMR_BTONE for restart
        SAH     TMR_BTONE
        BS      B1,BTONE_CHK_END
BTONE_CHK_OFF_FAIL:                   	; busy tone fails
        LAC     TMR_BTONE
        SAH     BUF1

        LACK    0
        SAH     TMR_BTONE
        SAH     BTONE_BUF
        SAH     BUF2

        LACK    0X60              	; set first busy tone on to off happened
        SAH     BUF3              	; set 'in busy tone off' bit to 1
        BS      B1,BTONE_CHK_END
BTONE_CHK_OFF_OFFTOFF:
        BIT     BUF3,6
        BS      TB,BTONE_CHK_END
        BIT     BUF3,7
        BS      TB,BTONE_CHK_END
        LACK    0
        SAH     TMR_BTONE
BTONE_CHK_END:
	LACK	0
	RET
;----------------------------------------------------------------------------
;       Function : BCVOX_INIT
;	input : no
;	output: no
;	variable : no
;----------------------------------------------------------------------------
BCVOX_INIT:
	LACL	8000
	SAH	TMR_VOX
	SAH	TMR_CTONE
	
	LACK	0
	SAH	BUF1
	SAH	BUF2
	SAH	BUF3
	SAH	TMR_BTONE
	SAH	BTONE_BUF
	
	RET      
;----------------------------------------------------------------------------

.END
	