.LIST
;---------------------------
SYS_MSG:
	LAC	MSG
	XORL	CSEG_END		;SEG_END
	BS	ACZ,SYS_SEG_END
;SYS_MSG0:
	LAC	MSG
	XORL	CSEG_STOP		;SEG_STOP
	BS	ACZ,SYS_SEG_STOP
;SYS_MSG1:
	;LAC	MSG
	;XORL	CVP_PAUSE		;VP_PAUSE
	;BS	ACZ,SYS_VP_PAUSE
;---------------------------------------传递消息区
;SYS_MSG2:
	LAC	MSG
	XORL	CRING_FAIL		;RING_FAIL
	BS	ACZ,SYS_RING_FAIL
;SYS_MSG3:
	LAC	MSG
	XORL	CMSG_TIFAT
	BS	ACZ,SYS_RING_TIMEFAT
;SYS_MSG4:	
	LAC	MSG
	XORL	CMSG_VOLA
	BS	ACZ,SYS_VOL_ADD		;VOL+
;SYS_MSG5:	
	LAC	MSG
	XORL	CMSG_VOLS
	BS	ACZ,SYS_VOL_SUB		;VOL-
;SYS_MSG6:	
	LAC	MSG
	XORL	CRING_OK
	BS	ACZ,SYS_MSG_RUN_ICM
;SYS_MSG7:
	LAC	MSG	
	XORL	CFIRST_RI
	BS	ACZ,SYS_MSG_FIRST_RING
;SYS_MSG8:	
	LAC	MSG
	XORL	CMSG_SER
	BS	ACZ,SYS_SER_RUN
;SYS_MSG9:	
	;LAC	MSG
	;XORL	CBUF_EMPTY
	;BS	ACZ,SYS_BUF_EMPTY
;SYS_MSG10:	
	;LAC	MSG
	;XORL	CCOM_INIT
	;BS	ACZ,SYS_SER_RUN_DAMINIT
;============================================================功能区
SYS_MSG_NO:
	LACK	1
	
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
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
SYS_VOL_ADD:
	LAC	CODECREG2
	ANDL	0XFF0F
        SAH	CODECREG2
	
        LAC	VOI_ATT
        ANDL	0X07
        SBHK	5		;5级音量
        BS	ACZ,SYS_VOL_ADD1
        LAC	VOI_ATT
        ADHK	1
        SAH	VOI_ATT
SYS_VOL_ADD1:
	LAC	VOI_ATT
	ANDL	0X07
        ADHL    VOL_TAB
        RPTK    0
        TBR     SYSTMP0
        LAC     SYSTMP0    
        ORL	0X03
        OR	CODECREG2
        SAH	CODECREG2
	
	CALL	InSetCodecReg
	BS	B1,SYS_MSG_YES
SYS_VOL_SUB:
	LAC	CODECREG2
	ANDL	0XFF0F
        SAH	CODECREG2
	
	LAC	VOI_ATT
        ANDL	0X07
        SBHK	1
        BS	ACZ,SYS_VOL_SUB1
        BS	SGN,SYS_VOL_SUB1
        LAC	VOI_ATT
	SBHK	1
        SAH	VOI_ATT
SYS_VOL_SUB1:
	LAC	VOI_ATT
	ANDL	0X07
        ADHL    VOL_TAB
        RPTK    0
        TBR     SYSTMP0
        LAC     SYSTMP0    
        ORL	0X03
        OR	CODECREG2
        SAH	CODECREG2
	
	call    InSetCodecReg
	BS	B1,SYS_MSG_YES
SYS_RING_TIMEFAT:
	LACL	0X88
	CALL	STOR_DAT
	CALL	GET_TIMEFAT
	CALL	STOR_DAT
	LACL	0X0FF
	CALL	STOR_DAT
	
	BS	B1,SYS_MSG_YES
SYS_MSG_FIRST_RING:

	LACL	0XCD		;RING FIRST
	CALL	STOR_DAT
	LACK	0
	CALL	STOR_DAT
	LACL	0XFF
	CALL	STOR_DAT
	
	CRAM	ANN_FG,1	;第一次来铃,清除来电标志
	BS	B1,SYS_MSG_YES
SYS_RING_FAIL:
	
	CRAM	ANN_FG,1	;来铃失败,清除来电标志(不管有没有)
	BS	B1,SYS_MSG_YES

SYS_MSG_RUN_ICM:
	CALL	INIT_DAM_FUNC
	CALL	SET_COMPS
	LACK	0X0A		;// set silence threshold
	CALL	SET_SILENCE
	CALL	BLED_ON	
     	CALL	CLR_FUNC	;先空
    	LACL	ICM_STATE
     	CALL	PUSH_FUNC
     	
	LACL	0X9008		;Line ON
	ORK	CMODE9
	SAH	CONF
	CALL	DAM_BIOS
     	
     	LACK	1
     	SAH	MBOX_ID
     	
     	LACL	0XFFFF
	SAH	PSWORD_TMP
	CALL	HOOK_ON

;!!!!!!!!!!!!!!!    	
     	LACL	0XD0		;告诉MCU摘机了
	CALL	STOR_DAT
	LACK	0
	CALL	STOR_DAT
	LACL	0XFF
	CALL	STOR_DAT
;!!!!!!!!!!!!!!!
  	LACL	CMSG_INIT
   	CALL	STOR_MSG
   	
   	LACK	0
   	SAH	PRO_VAR
   	SAH	PRO_VAR1
  	BS	B1,SYS_MSG_YES

;-------检查收到的命令
SYS_SER_RUN:

;SYS_SER_RUN1_1:
	
	;BS	ACZ,SYS_SER_RUN_SERINIT
;SYS_SER_RUN1_2:
	LAC	RECE_BUF1
	ANDL	0X0FF
	XORL	0X80
	BS	ACZ,SYS_SER_RECEIVE_TELNUM
;SYS_SER_RUN1_3:
	
	BS	B1,SYS_MSG_YES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;-------处理命令
SYS_SER_RECEIVE_TELNUM:
	LIPK	0
	IN	SYSTMP0,OPTR
	BIT	SYSTMP0,13
	BS	TB,SYS_MSG_YES		;HOOK_ON摘机了不收CID
	
	BIT	RECE_BUF1,15
	BS	TB,SYS_SER_RECEIVE_TELNUM0	;第零号来电吗?
	LAC	RECE_BUF1
	ANDL	0X6000
	BS	ACZ,SYS_SER_RECEIVE_TELNUM1	;第一号来电(号码)吗?
	LAC	RECE_BUF1
	ANDL	0X6000
	XORL	0X2000
	BS	ACZ,SYS_SER_RECEIVE_TELNUM2	;第二号来电(姓名)吗?
	LAC	RECE_BUF1
	ANDL	0X6000
	XORL	0X4000
	BS	ACZ,SYS_SER_RECEIVE_TELNUM3	;第三号来电(时间)吗?
	LAC	RECE_BUF1
	ANDL	0X6000
	XORL	0X6000
	BS	ACZ,SYS_SER_RECEIVE_TELNUM4	;第四号来电(OGM)吗?
	
	BS	B1,SYS_MSG_YES
;---------------TEL FLAG
SYS_SER_RECEIVE_TELNUM0:
;---考虑到有来电却无铃流的情况
	;LAC	RING_ID
	;ANDL	0X0F0
	;BZ	ACZ,SYS_SER_RECEIVE_TELNUM0_1	;有/无铃流一样处理
;---无铃流
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACK	0
	SAH	PRO_VAR
	LACK	1
	SAH	MBOX_ID	
;---	
SYS_SER_RECEIVE_TELNUM0_1:
	SRAM	ANN_FG,2	;receiving caller_id(no key responed)
	SRAM	ANN_FG,1	;new caller_id

	LACK	RECE_BUF2
	SAH	ADDR_S
	CALL	SET_WAITFG

	LAC	RECE_BUF3
	ORL	0X84
	SAH	RECE_BUF3

	LACK	RECE_BUF2	;头部0X84+0X82丢弃
	SAH	ADDR_S
	LACK	RECE_BUF11	;数据存到以RECE_BUF11为起始地址的空间
	SAH	ADDR_D
	LACK	3
	CALL	MOVE_DAT	;移动MSG1+MSG2+MSG3_MSG4+0XFF+0XFF

	LAC	EVENT
	ANDK	0X0F
	BZ	ACZ,SYS_SER_RECEIVE_TELNUM0_END
SYS_SER_RECEIVE_TELNUM_WRITE:
	CALL	SET_LED1FG	;set new call flag

	CALL	INIT_DAM_FUNC
	LACK	0
	CALL	SET_TELGROUP
	
	CALL	GET_TELT
	SBHK	99
	BS	SGN,SYS_SER_RECEIVE_TELNUM_WRITE_0
	
	LACK	1
	CALL	DEL_ONETEL	;总数超过99条时就先删除第一条
	CALL	TEL_GC_CHK
	CALL	GC_CHK
SYS_SER_RECEIVE_TELNUM_WRITE_0:
	
	;CALL	GET_NOUSETELUSRDAT	;取usr-dat并保存
	;SAH	BUF1
;-------
	
;!!!!
	LACK	RECE_BUF11
	SAH	ADDR_S
	SAH	ADDR_D
	
	LACK	2		;时间标志
	SAH	COUNT
	LACL	0X84
	CALL	STORBYTE_DAT
;!!!!
	CALL	TELNUM_WRITE	;写入数据(TEL flag)
	BZ	ACZ,SYS_SER_RECEIVE_TELNUM0_ERROR
SYS_SER_RECEIVE_TELNUM_WRITE_1:	
	LAC	RECE_BUF11
	ANDL	0X80
	BS	ACZ,SYS_SER_RECEIVE_TELNUM_WRITE_2	;有号码吗?
	
	LACK	RECE_BUF11
	ADHK	3
	SAH	ADDR_S
	CALL	TELNUM_WRITE	;写入数据(TEL NUM)
	BZ	ACZ,SYS_SER_RECEIVE_TELNUM0_ERROR
SYS_SER_RECEIVE_TELNUM_WRITE_2:	
	LAC	RECE_BUF11
	ANDL	0X8000
	BS	ACZ,SYS_SER_RECEIVE_TELNUM_WRITE_3	;有姓名吗?
	
	LACK	RECE_BUF2
	SAH	ADDR_S
	CALL	TELNUM_WRITE	;写入数据(TEL NAME)
	BZ	ACZ,SYS_SER_RECEIVE_TELNUM0_ERROR
SYS_SER_RECEIVE_TELNUM_WRITE_3:	
	;LAC	RECE_BUF12
	;ANDL	0X8000
	;BS	ACZ,SYS_SER_RECEIVE_TELNUM_WRITE_STOP	;有时间吗?
	
	CALL	TELTIME_WRITE	;写入数据(TEL TIME)	;必须写入时间
	BZ	ACZ,SYS_SER_RECEIVE_TELNUM0_ERROR
SYS_SER_RECEIVE_TELNUM_WRITE_STOP:
	CALL	DAT_WRITE_STOP
;---	
;	CALL	GET_TELT
;	CALL	SET_TELUSRDAT	;置usr-dat

	LACL	0X82		;新旧来电同步
	CALL	STOR_DAT
	LACK	0	;???????????????
	CALL	STOR_DAT
	CALL	GET_TELT	;来电总数同步
	CALL	STOR_DAT
	LACL	0XFF
	CALL	STOR_DAT		
;---	
	CALL	REAL_DEL
	CALL	MSG_CHK
	LACL	0X83		;录音数量同步(3bytes)
	CALL	STOR_DAT
	LAC	MSG_N
	CALL	STOR_DAT
	LAC	MSG_T
	CALL	STOR_DAT
	LACL	0XFF
	CALL	STOR_DAT
	
	CRAM	ANN_FG,2	;receiving caller_id end(可以响应按键)
	
	CALL	TEL_GC_CHK
	CALL	GC_CHK	
SYS_SER_RECEIVE_TELNUM0_END:
	BS	B1,SYS_MSG_YES
SYS_SER_RECEIVE_TELNUM0_ERROR:
	CALL	DAT_WRITE_STOP
	CALL	DAA_SPK
	CALL	BBBEEP
	
	BS	B1,SYS_MSG_YES
;---------------TEL NUM
SYS_SER_RECEIVE_TELNUM1:	;---TEL NUM
	CRAM	EVENT,0		;clear TEL NUM flag
	
	LACK	RECE_BUF2	;头部0X84+000XXXXXb丢弃
	SAH	ADDR_S
	LACK	RECE_BUF11	;数据存到以RECE_BUF11+3为起始地址的空间
	ADHK	3
	SAH	ADDR_D
	LAC	SIO_CNT
	LACK	5
	CALL	MOVE_DAT	;移动数据5words
	
	LAC	EVENT
	ANDK	0X0F
	BS	ACZ,SYS_SER_RECEIVE_TELNUM_WRITE
	BS	B1,SYS_MSG_YES
;---------------TEL NAME
SYS_SER_RECEIVE_TELNUM2:	;---TEL NAME
	CRAM	EVENT,1		;clear TEL NAME flag

	;LACK	RECE_BUF2	;头部0X84+001XXXXXb丢弃
	;SAH	ADDR_S
	;LACK	RECE_BUF11	;数据存到以RECE_BUF11+12为起始地址的空间
	;ADHK	12
	;SAH	ADDR_D
	;LACK	9
	;CALL	MOVE_DAT	;移动数据9words

	LAC	EVENT
	ANDK	0X0F
	BS	ACZ,SYS_SER_RECEIVE_TELNUM_WRITE

	BS	B1,SYS_MSG_YES
;---------------TEL TIME
SYS_SER_RECEIVE_TELNUM3:	;---TEL TIME
	CRAM	EVENT,2		;clear TEL NAME flag

	LACK	0
	SAH	TMR1
	SAH	TMR_SEC

	LAC	RECE_BUF2	;头部0X84+010XXXXXb丢弃
	ANDL	0XFF
	SAH	TMR_MONTH
	
	LAC	RECE_BUF2
	SFR	8
	SAH	TMR_DAY
	
	LAC	RECE_BUF3
	ANDL	0XFF
	SAH	TMR_HOUR
	
	LAC	RECE_BUF3
	SFR	8
	SAH	TMR_MIN
	
	LACK	0
	SAH	TMR1
	SAH	TMR_SEC
	
	LAC	EVENT
	ANDK	0X0F
	BS	ACZ,SYS_SER_RECEIVE_TELNUM_WRITE

	BS	B1,SYS_MSG_YES
;---------------TEL OGM
SYS_SER_RECEIVE_TELNUM4:	;---TEL OGM
.IF	0
	LACK	0
	CALL	SET_TELGROUP
	CALL	GET_TELT
	CALL	GET_TELUSRDAT
	SAH	PRO_VAR3	;取usr-dat

	CALL	TELNUM_WRITE	;写入数据

	CALL	GET_TELT
	SAH	SYSTMP1		;取TEL_ID
	
	LAC	PRO_VAR3
	CALL	SET_TELUSRDAT	;置usr-dat
.ENDIF
	BS	B1,SYS_MSG_YES

;-------------------------------------------------------------------------------
;DAM_BIOS的软中断程序:record/play/beep/VoicePrompt/line
;-------------------------------------------------------------------------------
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
	
	LACL	CREC_FULL		;产生memfull消息
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
;*********
INT_BIOS_RESP:
	LAC	RING_ID			
	ANDK	0X0F
	BZ	ACZ,INT_BIOS_END	;本地工作,不查VOX/BTONE/CTONE/DTMF
	BIT	EVENT,6
	BS	TB,INT_BIOS_RESP_BTONEDTMF	;play mode,不查VOX/CTONE
;*********
;---------
INT_BIOS_RESP_VOX:			;for record/line mode 
	CALL	VOX_CHK
	BS	ACZ,INT_BIOS_RESP_VOX_END
	LACL	CMSG_VOX
	CALL	STOR_MSG
INT_BIOS_RESP_VOX_END:	
;---------
;---------
INT_BIOS_RESP_CTONE:			;for record/line mode 
	CALL	CTONE_CHK
	BS	ACZ,INT_BIOS_RESP_CTONE_END
	LACL	CMSG_CTONE
	CALL	STOR_MSG
INT_BIOS_RESP_CTONE_END:
;---------
;---------
INT_BIOS_RESP_BTONEDTMF:
	
;---------
;---------
INT_BIOS_RESP_BTONE:			;for record/play/line/voice_prompt mode 
	CALL	BTONE_CHK
	BS	ACZ,INT_BIOS_RESP_BTONE_END
	LACL	CMSG_BTONE
	CALL	STOR_MSG
INT_BIOS_RESP_BTONE_END:
;---------
;---------	
INT_BIOS_RESP_DTMF:			;for record/play/line/voice_prompt mode 
	CALL	DTMF_CHK
	BS	ACZ,INT_BIOS_RESP_DTMF_END
	LACL	CREV_DTMF
	CALL	STOR_MSG
INT_BIOS_RESP_DTMF_END:
;---------

INT_BIOS_END:
	
	RET
;----
;----
INT_BIOS_START:
	SAH	SYSTMP2
	CALL	DAM_STOP
	
	LAC	SYSTMP2
	ANDL	0XFF
	SAH	SYSTMP0
	
	LAC	SYSTMP2
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
	BS	ACZ,INT_BIOS_START_BEEP_END	;frequency = 0(发声间隙)
	SAH	BUF1			;frequency
	
	LACL	CBEEP_COMMAND		;ON
	SAH	CONF
	CALL    DAM_BIOS
INT_BIOS_START_BEEP_END:	
	
	SRAM	EVENT,5		;SET flag(bit5)

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
	
	SRAM	EVENT,6		;SET flag(bit6)

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
	CALL	DAM_BIOS
	
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
        TBR     SYSTMP0
        LAC     SYSTMP0
        SAH     DTMF_VAL          	;save the DTMF value in DTMF_VAL
        
	SRAM	ANN_FG,4
        BS      B1,DTMF_CHK_END
DTMF_CHK1:
        BIT     ANN_FG,4
        BZ      TB,DTMF_CHK_END
DTMF_CHK2:

        CRAM	ANN_FG,4

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
	
        BIT     RESP,4            ; check if continuous tone happens ?
        BS      TB,CTONE_CHK_ON
        LACL    8000              ; continuous tone off
        SAH     TMR_CTONE
CTONE_CHK_ON:
        LAC     TMR_CTONE
        BZ      SGN,CTONE_CHK_ON_2
        
CTONE_CHK_ON_1:	
	LAC	CONF
	ORK	20
	SAH	CONF
	
        LACK    1                 ; continuous tone period found, return ACCH=1
        RET
CTONE_CHK_ON_2:
	LACK    0
        RET
;----------------------------------------------------------------------------
;       Function : VOX_CHK
;
;       The general routine used in remote line operation. It checks VOX
;       Input  : CONF (Record Mode)
;       Output : ACCH = 1  -  VOX found over 10.0 sec
;                ACCH = 0  -  no VOX found over 10.0 sec
;               
;       Parameters:
;               1. TMR_VOX - for VOX detection(initial TMR8=VOX time)
;----------------------------------------------------------------------------
VOX_CHK:			; check the VOX
	
        BIT     RESP,6
        BZ      TB,VOX_CHK_OFF
VOX_CHK_ON:                     ; VOX on
        LAC     TMR_VOX
        BZ      SGN,VOX_CHK_END
       
VOX_CHK_ON_1:
	LAC	CONF
	ORK	20
	SAH	CONF
	
        LACK    1		; VOX found over 8.0 sec, return ACCH=1
        RET
VOX_CHK_OFF:                     ; VOX off
        LACL    8000              ; restore 8.0 sec in TMR_VOX
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
	LAC	CONF
	SFR	12
	SBHK	1
	BZ	ACZ,BTONE_CHK_ON1_4	;record mode or not?
	                  		; busy tone period found
        LAC     BTONE_BUF
	ADH     TMR_BTONE
        SFR     6                 	; tail cut base 400 ms
        ANDK    0X3F              	; cut units ~= (SFR 6 + SFR 7) / 2
        SAH     BTONE_BUF
        SFR     1
        ADH     BTONE_BUF
        SFR     1
        SAH     BTONE_BUF

        LAC     CONF
        OR      BTONE_BUF
        SAH     CONF
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
.IF	0
;----------------------------------------------------------------------------
;	Function : ANNOUNCE_RECE --- 数字入播放队列(测试用正式版中删除)
;	input : ACCH = 要播放的数字(0..0XFF)
;	output : no
;----------------------------------------------------------------------------
ANNOUNCE_RECE:
	ANDL	0XFF
	SAH	SYSTMP3
	BS	ACZ,ANNOUNCE_RECE1
	SBHK	21
	BS	SGN,ANNOUNCE_RECE2
	
	LAC	SYSTMP3
	SFR	4
	ADHK	18
	ORL	0XFF00
	CALL	STOR_VP
	
	LAC	SYSTMP3
	ANDL	0X0F
	BS	ACZ,ANNOUNCE_RECE_END
	ORL	0XFF00
	CALL	STOR_VP
	BS	B1,ANNOUNCE_RECE_END
ANNOUNCE_RECE1:
	LACK	38
	ORL	0XFF00
	CALL	STOR_VP
	BS	B1,ANNOUNCE_RECE_END
ANNOUNCE_RECE2:
	LAC	SYSTMP3
	ORL	0XFF00
	CALL	STOR_VP
ANNOUNCE_RECE_END:
	
	RET
;-------------------------------------------------------------------------
;	Function : ANNOUNCE_READ --- 将从FLASH读出的数字入播放队列(测试用正式版中删除)
;	input : ACCH = 要播放的数字(0..0XFF)
;	output : no
;-------------------------------------------------------------------------
ANNOUNCE_READ:
	LAC	MSG_ID
	CALL	READ_ONETELNUM
	BS	ACZ,ANNOUNCE_READ_END
	
	LAC	SYSTMP1
	SAH	SYSTMP3
	BS	ACZ,ANNOUNCE_READ1
	SBHK	21
	BS	SGN,ANNOUNCE_READ2
	
	LAC	SYSTMP3
	SFR	4
	ADHK	18
	ORL	0XFF00
	CALL	STOR_VP
	
	LAC	SYSTMP3
	ANDL	0X0F
	BS	ACZ,ANNOUNCE_READ
	ORL	0XFF00
	CALL	STOR_VP
	BS	B1,ANNOUNCE_READ
ANNOUNCE_READ1:
	LACK	38
	ORL	0XFF00
	CALL	STOR_VP
	BS	B1,ANNOUNCE_READ
ANNOUNCE_READ2:
	LAC	SYSTMP3
	ORL	0XFF00
	CALL	STOR_VP
	BS	B1,ANNOUNCE_READ
ANNOUNCE_READ_END:
	;CALL	STOPREADTELNUM
		
	RET
.ENDIF
;-------------------------------------------------------------------------------


.END
	