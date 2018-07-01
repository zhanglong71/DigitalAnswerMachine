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
;SYS_MSG0_1:
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
	XORL	CMSG_VOLA
	BS	ACZ,SYS_VOL_ADD		;VOL+
;SYS_MSG4:	
	LAC	MSG
	XORL	CMSG_VOLS
	BS	ACZ,SYS_VOL_SUB		;VOL-
;SYS_MSG5:	
	LAC	MSG
	XORL	CRING_OK
	BS	ACZ,SYS_MSG_RUN_ICM
;SYS_MSG6:	
	LAC	MSG
	XORL	CRMOT_OK
	BS	ACZ,SYS_MSG_RUN_RMT
;SYS_MSG7:
	LAC	MSG	
	XORL	CFIRST_RI
	BS	ACZ,SYS_MSG_FIRST_RING
;SYS_MSG8:	
	LAC	MSG
	XORL	CMSG_SER
	BS	ACZ,SYS_SER_RUN
;SYS_MSG9:	
	
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
	ANDL	0XFFE0
	SAH	CODECREG2
	
        LAC	VOI_ATT
        ANDL	0X07
        SBHK	7		;上限
        BS	ACZ,SYS_VOL_ADD1
        LAC	VOI_ATT
        ADHK	1
        SAH	VOI_ATT
SYS_VOL_ADD1:
SYS_VOL_SET:
	LAC	VOI_ATT
	ANDL	0X07
	ADHL	VOL_TAB
	CALL    GetOneConst
        OR	CODECREG2
        SAH	CODECREG2
	
	LIPK    6
	OUT	CODECREG2,LOUTSPK
	ADHK	0
	BS	B1,SYS_MSG_YES
SYS_VOL_SUB:
	LAC	CODECREG2
	ANDL	0XFFE0
	SAH	CODECREG2
	
	LAC	VOI_ATT
        ANDL	0X07
        SBHK	0		;下限
        BS	ACZ,SYS_VOL_SUB1
        BS	SGN,SYS_VOL_SUB1
        LAC	VOI_ATT
	SBHK	1
        SAH	VOI_ATT
SYS_VOL_SUB1:
	BS	B1,SYS_VOL_SET
;---------------------------------------
SYS_MSG_FIRST_RING:

	;CRAM	ANN_FG,1	;第一次来铃,清除来电标志
	BS	B1,SYS_MSG_YES
SYS_RING_FAIL:

	;CRAM	ANN_FG,1	;来铃失败,清除来电标志(不管有没有)
	BS	B1,SYS_MSG_YES

SYS_MSG_RUN_ICM:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	CALL	HOOK_ON
	CALL	SET_COMPS
	
	LACL	0X9008
	ORL	CMODE9
	ADHK	0
	CALL	DAM_BIOSFUNC
	CALL	INIT_DAM_FUNC
;-------
	LACL	FlashLoc_H_f_answer
	ADLL	FlashLoc_L_f_answer
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_answer
	ADLL	CodeSize_f_answer
	CALL	LoadHostCode
;-------
	LACL	CMSG_INIT
	CALL	STOR_MSG

	LACK	0
	SAH	PRO_VAR
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER

	CALL	CLR_FUNC	;先空
	LACL	ANS_STATE	;答录状态
	CALL	PUSH_FUNC

	BS	B1,SYS_MSG_YES
;---------------------------------------
SYS_MSG_RUN_RMT:
	LACL	DISP_Ln	;"Ln"
	SAH	LED_L
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_REC

	CALL	CLR_FUNC	;先空
	LACL	REMOTE_PRO	;进入遥控
	CALL	PUSH_FUNC

	LACL	CMSG_INIT
	CALL	STOR_MSG
;-------
	LACL	FlashLoc_H_f_remote
	ADLL	FlashLoc_L_f_remote
	CALL	SetFlashStartAddress
	NOP	
	LACL	RamLoc_f_remote
	ADLL	CodeSize_f_remote
	CALL	LoadHostCode
;-------	
	LACK	0
	SAH	PRO_VAR		;程序步骤
	SAH	PRO_VAR1	;计时清零
	SAH	PSWORD_TMP	;功能字符清零
	CALL	BCVOX_INIT

	BS	B1,SYS_MSG_YES
;-------检查收到的命令
SYS_SER_RUN:
	BS	B1,SYS_MSG_YES
;-------------------------------------------------------------------------------
;DAM_BIOS的软中断程序:record/play/beep/line/VoicePrompt/speakerphone
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
	BIT	EVENT,3
	BS	TB,INT_BIOS_PHONE	;speakerphone
	CALL	GET_VP
	BZ	ACZ,INT_BIOS_START

	RET
;---
INT_BIOS_PHONE:
	
	CALL	DAM_BIOS
	BS	B1,INT_BIOS_END
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
	BIT	EVENT,10
	BZ	TB,INT_BIOS_RESP_LOCAL		;本地工作,不查VOX/BTONE/CTONE/DTMF
	BIT	EVENT,6
	BS	TB,INT_BIOS_RESP_BTONEDTMF	;play mode,不查VOX/CTONE
;*********
;---接线状态---接线状态---接线状态---接线状态---接线状态---接线状态---接线状态---接线状态
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
	SBHK	1
	BS	ACZ,INT_BIOS_RESP_DTMFSTART
	SBHK	1
	BS	ACZ,INT_BIOS_RESP_DTMFEND
	BS	B1,INT_BIOS_RESP_DTMF_END
INT_BIOS_RESP_DTMFSTART:
;---返回 1
	LACL	CREV_DTMFS
	CALL	STOR_MSG
	BS	B1,INT_BIOS_RESP_DTMF_END
INT_BIOS_RESP_DTMFEND:
;---返回 2
	LACL	CREV_DTMF
	CALL	STOR_MSG
INT_BIOS_RESP_DTMF_END:
;---------
	BS	B1,INT_BIOS_END
;---本地状态---本地状态---本地状态---本地状态---本地状态---本地状态---本地状态---本地状态
INT_BIOS_RESP_LOCAL:			;开始查CID
;---------

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
	BS	ACZ,INT_BIOS_START_BEEP0	;frequency = 0(发声间隙)
	SAH	BUF1			;frequency
	
	LACL	CBEEP_COMMAND		;ON
	SAH	CONF
	CALL    DAM_BIOS
	
	LAC	BUF1
	SAH	CONF
	CALL    DAM_BIOS
	LACK	0
	SAH	CONF
	CALL    DAM_BIOS
INT_BIOS_START_BEEP0:	
	LACL	CBEEP_COMMAND		;
	SAH	CONF

INT_BIOS_START_BEEP_END:	
	LAC	EVENT		;SET flag(bit5)
	ORK	0X020
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
	LAC	EVENT		;SET flag(bit6)
	ORK	0X040
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
	ANDL	0XFF00
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
	SBHK	1
	BS      ACZ,DAM_STOP_PHONE	;// 0XC000
	BS	B1,DAM_STOP_IDLE
DAM_STOP_REC:
	LAC	CONF
	ORK	0X40
	SAH	CONF
	CALL	DAM_BIOS
	BS	B1,DAM_STOP_IDLE
DAM_STOP_PHONE:
	LACL    0XC080
	SAH     CONF
	CALL    DAM_BIOS
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
	LACL	0X4400
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
	LAC	EVENT		;SET flag(bit7)
	ANDL	0XFF00
	ORL	0X080
	SAH	EVENT

	;CALL	STATUS_PRB_OFF	;Clear(bit3)
	
	LACL	0X1000
	SAH	CONF
	
	RET
;----------------------------------------------------------------------------
;	Function : LINE_START
;	input : no
;	output: no
;----------------------------------------------------------------------------
LINE_START:
	LAC	EVENT		;SET flag(bit4)
	ANDL	0XFF00
	ORK	0X010
	SAH	EVENT
	
	LACL	0X5000
	SAH	CONF
	
	RET
;----------------------------------------------------------------------------
;	Function : PHONE_START
;	input : no
;	output: no
;----------------------------------------------------------------------------
PHONE_START:
	LAC	EVENT
	ANDL	0XFF00
	ORK	0X08
	SAH	EVENT
	
	LACL	0XC000
	SAH	CONF
	
	RET
;----------------------------------------------------------------------------
;       Function : DTMF_CHK
;
;       The general routine used in remote line operation. It checks DTMF
;       Input  : CONF (Record Mode, Play Mode, Line Mode or Voice Prompt Mode)
;       Output : ACCH = 0  -  No detected
;                ACCH = 1  -  DTMF start detected
;	 	 ACCH = 2  -  DTMF end detected

;		 DTMF_VAL  =  DTMF value
;       Parameters:
;               8. EVEVT.11 - store the detected DTMF flag
;----------------------------------------------------------------------------
DTMF_CHK:
        LAC     RESP            ;check the DTMF value ?
        ANDK    0X0F
        BS      ACZ,DTMF_CHK1
	
	ADHL	DTMF_TABLE
	CALL	GetOneConst
        SAH     DTMF_VAL	;save the DTMF value in DTMF_VAL

	BIT     EVENT,11
        BS      TB,DTMF_CHK_END
;---DTMF从无到有	
	;LACL	1600		;DTMF定时长度
	;SAH	TMR_DTMF
	
	;LACL	400
	;CALL	SET_DTMFTMR

        LAC     EVENT
        ORL	1<<11
        SAH     EVENT

	LACK	1		;DTMF start detected, return ACCH = 1

        RET
DTMF_CHK1:
	BIT     EVENT,11
        BZ      TB,DTMF_CHK_END
;---DTMF从有到无       
	;LACK	0
	;SAH	TMR_DTMF
;DTMF_CHK2:
        LAC     EVENT
        ANDL	~(1<<11)
        SAH     EVENT

        LACK    2		;DTMF end detected, return ACCH = 2
        RET
DTMF_CHK_END:
	LACK	0
	
	RET
;----------------------------------------------------------------------------
;       Function : CASTONE_CHK
;
;       The general routine used in remote line operation. It checks Cas-tone
;       Input  : CONF (Record Mode, Play Mode, Line Mode or Voice Prompt Mode)
;       Output : ACCH = 0  -  No detected
;                ACCH = 1  -  Cas-tone start detected
;	 	 ACCH = 2  -  Cas-tone end detected
;
;       Parameters:
;               8. EVEVT.12 - store the detected Cas-tone flag
;----------------------------------------------------------------------------
.if	1
CASTONE_CHK:
	BIT	RESP,8
	BZ	TB,CASTONEE_CHK
;---有
	LAC	RESP
        ANDK	0X0F
        BZ	ACZ,CASTONE_CHK_END

	BIT	EVENT,12
	BS	TB,CASTONE_CHK_END
;---无 ==> 有
	LAC     EVENT
        ORL	1<<12
        SAH     EVENT
	
	LACK    1		;Cas-Tone start detected, return ACCH=3
	
	RET
CASTONE_CHK_END:		;(有-有)||(无-无)
	LACK	0
	
	RET
CASTONEE_CHK:
;---无
	BIT	EVENT,12
	BZ	TB,CASTONE_CHK_END
;---有 ==> 无
	LAC     EVENT
        ANDL	~(1<<12)
        SAH     EVENT
	
	LACK    2		;Cas-Tone end detected, return ACCH=4
	
	RET
.endif
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
        LACL    CTMR_CTONE              	; continuous tone off
        SAH     TMR_CTONE
CTONE_CHK_ON:
        LAC     TMR_CTONE
        BZ      SGN,CTONE_CHK_ON_2
        
CTONE_CHK_ON_1:	
        LACK    1                 	; continuous tone period found, return ACCH=1
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
;               1. TMR_VOX - for VOX detection(initial TMR_VOX=VOX time)
;----------------------------------------------------------------------------
VOX_CHK:				; check the VOX
        BIT     RESP,6
        BZ      TB,VOX_CHK_OFF
VOX_CHK_ON:                     ; VOX on
        LAC     TMR_VOX
        BZ      SGN,VOX_CHK_END
       
VOX_CHK_ON_1:
        LACK    1                 ; VOX found over 8.0 sec, return ACCH=1
        RET
VOX_CHK_OFF:                     ; VOX off
        LACL    CTMR_CTONE              ; restore 8.0 sec in TMR_VOX
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
;
;		BUF3.4 = BTONE-on
;		BUF3.5 = BTONE-off
;		BUF3.6 = 1/0 ==>first busy tone on to off happend/not
;		BUF3.7 = 1/0 ==>first busy tone off to on happend/not
;----------------------------------------------------------------------------
BTONE_CHK:
        BIT     RESP,5
        BZ      TB,BTONE_CHK_OFF
BTONE_CHK_ON:                    	; busy tone on
        BIT     BUF3,5            	; check if transition from busy tone off ?
        BZ      TB,BTONE_CHK_ON_ONTON
;---off to on
        LAC     TMR_BTONE              	; if busy tone off time < 200 ms, fails
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
.IF	0
	LAC     BUF3
	ADHK    1                 	; increase the 'tone on/off count' by 1
	SAH     BUF3
        ANDK    0X0F
        SBHK    5                 	; if the 'tone on/off count' >= 5, busy tone
        BS      SGN,BTONE_CHK_ON1_5 	; period found
.ELSE
	LAC     BUF3
	ANDK    0X0F
	SBHK	5
	BZ      SGN,BTONE_CHK_ON1_2_1
	
        LAC     BUF3
	ADHK    1
	SAH     BUF3	;计数个数大于5个就不增加了
	BS      B1,BTONE_CHK_ON1_5
BTONE_CHK_ON1_2_1:		;---计数个数为大于5个，且时长满足要求
        LAC     BTONE_BUF            	;BUSY TONE >= 7.0(=1750*4) SEC CHECK
        ;SBHL	1750 		;1750 --- 7s
	SBHL	1500            	;6s
	;SBHL	1250            	;5s
	;SBHL	1000            	;4s
	;SBHL	750	            	;3s
	;SBHL	500       	     	;2s
        BS      SGN,BTONE_CHK_ON1_5
.ENDIF
BTONE_CHK_ON1_3:          		; busy tone period found
	LAC	CONF
	SFR	12
	SBHK	1
	BZ	ACZ,BTONE_CHK_ON1_4	;record mode or not?
	
	LAC     BTONE_BUF
	ADH     TMR_BTONE
	SFR     6                 	; tail cut base 400 ms
	ANDK    0X3F              	; cut units ~= (SFR 6 + SFR 7) / 2
	SAH     BTONE_BUF
	SFR     1
	ADH     BTONE_BUF
	SFR     1
	SBHK	5		;2009-2-20 10:47特意少切5*400ms=2s
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
BTONE_CHK_ON_ONTON:		;first on or on-to-on
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
;-------------------------------------------------------------------------------
BCVOX_INIT:
	LACL	CTMR_CTONE
	SAH	TMR_VOX
	SAH	TMR_CTONE
	
	LACK	0
	SAH	BUF1
	SAH	BUF2
	SAH	BUF3
	SAH	TMR_BTONE
	SAH	BTONE_BUF
	
	RET
;-----------------------------------------------------------
SET_TIMER2:
	SAH	TMR0
	SAH	TMR0_BAK
	
	RET	
;---------------
CLR_TIMER2:
	LACK	0
	SAH	TMR0
	SAH	TMR0_BAK
	RET	
;-------------------------------------------------------------------------------

.END
	