.LIST
;//---------------------------------------------------------------------
;//	Function : INITIAL
;//	上电初始化
;//---------------------------------------------------------------------
INITIAL:
	
	LIPK    2
	OUTK	11,PLLMR		;// 11 → PLLMR
	;OUTk    12,PLLMR
	;OUTk    0x02,TESTR  		;// test_erdb=1

        LACK    0               	;// CLEAR ALL INTERNAL RAM TO ZERO
        LARK    0,0             	;// INTERNAL RAM FOR 93010
        LARK    1,1              	;// IS 0000 ~ 1024
        MAR     +0,0            	;// FOR 93011 IS 0000 ~ 2048
INITIAL_CLR:
        LUPK    127,1           	;// LOOP 127 + 1 = 128 TIMES
        SAHP    +,0             	;// USE ' 0 ' TO SAVE INTERNAL RAM
        NOP
        MAR     +0,1
        MAR     -,0			;// USE AR1 TO DECREMENT
        BZ      ARZ,INITIAL_CLR    	;// TOTAL IS 128 * 8 = 1024 TIMES
        LDPK    0
        
        call    InitDateTime
        
        EINT
        
	SRAM	ANN_FG,0
	
        LIPK    0	
        OUTL    0X21FF,BIOR	;// set the BIOR register initial value(BIOR7..0=I/I/O/I/I/I/I/O)
        ;OUTK    0X1B,IMR 	;// set the IMR register, INT_STMR & INT_CODEC
        OUTK    0X19,IMR 	;// set the IMR register, INT_STMR & INT_CODEC & INT_INT1M
;//=================================	
	
	;call    SetFlashWaitState
        LIPK	1
	OUTL	0XF9FB,WSTR	; set FLASHWAIT(WSTR11..9)=100, PROGWAIT(WSTR2..0)=010
	;OUTL	0XF7FA,WSTR	; set FLASHWAIT(WSTR11..9)=011, PROGWAIT(WSTR2..0)=010
	LIPK	0
      
        call    SetDspRunMode
       
;//-----------------------------
.IF	ALC_ON	
        LACL    0XD719
        ;LACL    0XD710
.ELSE        
        LACL    0XD734
.ENDIF	
        SAH     CONF
        CALL    DAM_BIOS        ;// set VOX level
;---
	LACK	0X0B		;// set silence threshold
	;LACK	0X09
	CALL	SET_SILENCE
;------------------------------------------------
;	force   CODEC_INT  release
;------------------------------------------------
        LDPK    1																	;//????????????
        LAC     0X35
        ORL     0X0100
        SAH     0X35
;------------------------------------------------
	LIPK	0
	LDPK	0

	 
	LACL	0XC124		;NewMsgBeepPrompt(15)/BeepVoicePrompt(14)/LANGUAGE(13,12)/OGM_ID(11..8)/RING_CNT(7..4)/ATT1(3..0)
        SAH	VOI_ATT
        ;LACL	0x0030		;reserved(11..8)/reserved(11..8)/LCD(7..4)/Local5(3..0)
        ;SAH	LOCACODE1
	
	LACL	1000	;delay 1s(wait for MCU initial)
	CALL	DELAY		
;-------初始语言选择--------------------
	CALL	GET_INITLANGUAGE
	CALL	SENDLANGUAGE	;(2bytes)语言选择
	LACL	0XFF
	CALL	STOR_DAT
;-------初始时间制式选择12/24-----------
	LACL	0X88
	CALL	STOR_DAT
	CALL	GET_TIMEFAT
	CALL	STOR_DAT
;-------初始时间制式选择12/24完毕-------
	LACK	50	;delay 50ms
	CALL	DELAY

	;CALL	SET_LED2FG	;LED2 flash when initial
	;LACL	0X0002
        ;SAH	RING_ID		;中断里面完成
        
        LACL    0XFFFF
        SAH     KEY             ;// initial KEY value=FFFF

SF_TEST:
.IF	TEXT_0X9041	
	LACL    0X9041
.ELSE
	LACL	0X9042
.ENDIF
        SAH     CONF
	CALL    DAM_BIOS        ; replace by Mode9
        BIT     RESP,8          ;// check the result of initialization ?
        BS      TB,INIT_GOOD
INIT_FLASHFMT:                       ;// initialization fails
        LACL	0X9041      
        SAH     CONF        
        CALL    DAM_BIOS        ;// do AFLASH initialization

        BIT     RESP,8          ;// check the result of initialization ?
        BS      TB,INIT_GOOD
        
        LAC     RESP
        ANDK    0x0070
        SBHK    0x0010
        BZ      ACZ,INIT_FLASHFMT  	;// flash id ok,but init pattern error
InitError:
	CALL	DAA_SPK												;// bad,display 'Ar'
        CALL    WBEEP

        BS      B1,SF_TEST
INIT_GOOD:                       ;// initialization succeed
	
;--------设置voice prompt
E_V_TEST:
	
.IF	TEXT_FVOP
	LACL	0X7604	;// set voice prompt configuration: flash voice prompt
.ENDIF
.IF	TEXT_EVOP
	LACL	0X7602	;// set voice prompt configuration: external voice prompt
.ENDIF
.IF	TEXT_IVOP
	LACL	0X7601	;// set voice prompt configuration: internal voice prompt
.ENDIF
	SAH	CONF
 	CALL	DAM_BIOS

	
.IF	TEXT_FVOP
	BIT	RESP,4		;// if flash voice prompt test ok?
.ENDIF
.IF	TEXT_EVOP
	BIT	RESP,1		;// if external	voice prompt test ok?
.ENDIF	
.IF	TEXT_IVOP
	BIT	RESP,0		;// if internal	voice prompt test ok?
.ENDIF				
        BS	TB,E_V_OK

        CALL    DAA_SPK
        CALL    WBEEP

	;BS	B1,E_V_TEST
E_V_OK:
	
;//----------------------------------------------------------------
	ROVM

	LACK	3
	SAH	MBOX_ID
	CALL	MSG_CHK
        CALL	NEWICM_CHK
        
	LACK	2
	SAH	MBOX_ID
	CALL	MSG_CHK
        CALL	NEWICM_CHK
        
	LACK	1
	SAH	MBOX_ID
	CALL	MSG_CHK
	CALL	NEWICM_CHK

        LACL    0XD101
        ;LACL    0XD103			;// set the output level is equal to the input level
        SAH     CONF
        CALL    DAM_BIOS

;//-----------------------------------------------------------------------------
	CALL	DAA_SPK
	CALL	INITBEEP
INITIAL_RET:
	
	RET
;-------------------------------------------------------------------------------
;	Function : INITMCU
;	send data to initial mcu
;-------------------------------------------------------------------------------
INITMCU:
	LACK	5
	CALL	SET_TELGROUP
	CALL	GET_TELT
	BS	ACZ,INITMCU_1
	SAH	MSG_ID		;只一个,也是最后一个
	BS	B1,INITMCU_2
INITMCU_1:
	CALL	DEFATT_WRITE
	
	LACK	1
	SAH	MSG_ID	
INITMCU_2:
	LACK	RECE_BUF11
	SAH	ADDR_D		;保存地址
	SAH	ADDR_S		;提取地址
	LAC	MSG_ID		;条目号
	CALL	READ_TELNUM	;读当前条目数据
	CALL	STOPREADDAT

	LACK	0		;PS1
	SAH	COUNT
	CALL	GETBYTE_DAT
	ANDK	0XF
	SAH	PASSWORD
	SFL	4
	SAH	PASSWORD
	LACK	1		;PS2
	SAH	COUNT
	CALL	GETBYTE_DAT
	OR	PASSWORD
	SFL	4
	SAH	PASSWORD
	LACK	2		;PS3
	SAH	COUNT
	CALL	GETBYTE_DAT
	OR	PASSWORD
	SAH	PASSWORD
;---
	LACK	3		;local code1
	SAH	COUNT
	CALL	GETBYTE_DAT
	SAH	LOCACODE
	SFL	4
	SAH	LOCACODE
;-
	LACK	4		;local code2
	SAH	COUNT
	CALL	GETBYTE_DAT
	OR	LOCACODE
	SFL	4
	SAH	LOCACODE
;-
	LACK	5		;local code3
	SAH	COUNT
	CALL	GETBYTE_DAT
	OR	LOCACODE
	SFL	4
	SAH	LOCACODE
;-
	LACK	6		;local code4
	SAH	COUNT
	CALL	GETBYTE_DAT
	OR	LOCACODE
	SAH	LOCACODE
;-	
	LAC	LOCACODE1
	ANDL	0xFFF0
	SAH	LOCACODE1

	LACK	7		;local code5
	SAH	COUNT
	CALL	GETBYTE_DAT
	ANDK	0x0F
	OR	LOCACODE1
	SAH	LOCACODE1
;-	
	LAC	VOI_ATT
	ANDL	0XFF0F
	SAH	VOI_ATT
	
	LACK	8		;Rnt
	SAH	COUNT
	CALL	GETBYTE_DAT
	ANDK	0X0F
	SFL	4
	OR	VOI_ATT
	SAH	VOI_ATT
;-
	LAC	LOCACODE1
	ANDL	0xFF0F
	ORK	0x0030		;LCD contrast
	SAH	LOCACODE1
;-------------------------------------------------------------------------------
INITMCU_3:	
	LACK	0
	SAH	TMR1
	SAH	TMR_SEC
	
	CALL	SENDLANGUAGE	;(2bytes)语言选择

	LACL	0X0FF
	CALL	STOR_DAT	;(1byte)

	LACK	30		;delay 30ms
	CALL	DELAY
INITMCU_4:		
;---	
	LACL	0X87		;(2bytes)LCD 亮度
	CALL	STOR_DAT
	LAC	LOCACODE1
	SFR	4
	ANDK	0x0F
	;LACK	3
	CALL	STOR_DAT
	
	LACL	0X0FF
	CALL	STOR_DAT	;(1byte)

	LACK	30		;delay 30ms
	CALL	DELAY
;---
	;LACL	0X82		;新旧来电同步(4byte)
	;CALL	STOR_DAT
	;LACK	0	;???????????????
	;CALL	STOR_DAT
	;LACK	0
	;CALL	SET_TELGROUP
	;CALL	GET_TELT	;Total income call
	;CALL	STOR_DAT
INITMCU_5:	
	CALL	SENDLOCACODE	;(5byte)

;---
	LACL	60	;delay 60ms
	CALL	DELAY

	LACK	0		;清空消息队列
	SAH	MSG_QUEUE

	LACL	CMSG_INIT
	CALL	STOR_MSG
INITMCU_RET:
	RET
;-------------------------------------------------------------------------------
.END
