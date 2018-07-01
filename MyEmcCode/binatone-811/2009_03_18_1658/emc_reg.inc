
/************************寄存器定义*************************/
INTBUF_ACC	==	0X10	;ACC
CURSOR		==	0X11
SYS_FLAG	==	0X12	;status FLAG FOR SYSTEM
EVENT		==	0X13	;ACTION FLAG FOR SYSTEM
DAM_FLAG	==	0X14	;ACTION FLAG FOR DAM

TEMP0		==	0X15
TEMP1		==	0X16
TEMP2		==	0X17
TEMP3		==	0X18
TEMP4		==	0X19
TEMP5		==	0X1A
OLD_RAM		==	0X1B	;Save the R4 while call function(Note:最上层的函数才能用)
OFFSET_S	==	0X1C	;offset		(source 	)
OFFSET_D	==	0X1D	;offset		(destination	)
COUNT		==	0X1E	;counter
BASE_ADDR	==	0X1F	;bank/block	(bit7..4=source/bin3..0=destination)
;-------------------------------------------------------------------------------
;bank 0---for inrurrupt
INTBUF_PPSR	==	0X20	;R5(PROGRAM PAGE SELECT REGISTER)
INTBUF_STATUS	==	0X21	;R3(STATUS)
INTBUF_RSR	==	0X22	;R4(RAM SELECT REGISTER)
INTBUF_CIDADDR	==	0X23	;RC
INTBUF_CIDBLOCK	==	0X24	;CID-block
INT_OLD_RAM	==	0X25

BANK0_TEMP0	==	0X26
BANK0_TEMP1	==	0X27

B0_TMR		==	0X29



;--------
B0_TMR_TIMER		==	0X30
B0_TMR_TIMER_BAK	==	0X31

B0_SEC_REG	==	0X32	;RTC
B0_MIN_REG	==	0X33
B0_HOUR_REG	==	0X34
B0_DAY_REG	==	0X35
B0_MON_REG	==	0X36
B0_YEAR_REG	==	0X37
B0_WEEK_REG	==	0X38

B0_TMR_VOX	==	0X39
B0_TMR_CTONE	==	0X3A
B0_BUF		==	0X3B	;total time
B0_TMR_BTONE	==	0X3C	;timer
B0_BTONE_BUF1	==	0X3D	;last on time
B0_BTONE_BUF2	==	0X3E	;last off time
B0_BTONE_BUF3	==	0X3F	;status
;-------------------------------------------------------------------------------
;bank 1
B1_MSG		==	0X20	;CURRENT SYSTEM MESSAGE
B1_PRO_VAR	==	0X21	;FOR SYSTEM STATUS
B1_PRO_VAR1	==	0X22	;timer counter
B1_CONTRAST	==	0X23	;LCD contrast
B1_LANGUAGE	==	0X24	;LANGUAGE
B1_FLASH	==	0X25	;flash time
B1_RING_NUM	==	0X26	;LENGTH/ring to answer
B1_12PSWORD	==	0X27	;
B1_34PSWORD	==	0X28	;
B1_DTMF_VAL	==	0X29	;
;B1_CID_TYPE	==	0X2A	;the CID type 0=normal/1=Secret/2=Unknown-number or error/3=MessageWaitingActivate/4=MessageWaitingDeactivate

;---
B1_CID_T	==	0X2E
B1_CID_N	==	0X2F
B1_MSG_T	==	0X30
B1_MSG_N	==	0X31
B1_MSG_ID	==	0X32
;---
B1_SEC_REG	==	0X33	;work temp(date/time/psword)
B1_MIN_REG	==	0X34
B1_HOUR_REG	==	0X35
B1_DAY_REG	==	0X36	;either for ps
B1_MON_REG	==	0X37	;either for ps
B1_YEAR_REG	==	0X38
B1_WEEK_REG	==	0X39
;---for buckup
BANK1_TEMP0	==	0X3A
BANK1_TEMP1	==	0X3B
BANK1_TEMP2	==	0X3C
BANK1_TEMP3	==	0X3D
BANK1_TEMP4	==	0X3E
BANK1_TEMP5	==	0X3F
;-------------------------------------------------------------------------------
;bank 2
BANK2_TEMP0	==	0X20
BANK2_TEMP1	==	0X21
BANK2_TEMP2	==	0X22
B2_TMR		==	0X23
B2_RING_TMR2	==	0X24

B2_TMR_TIMER		==	0X25
B2_TMR_TIMER_BAK	==	0X26

B2_TMR_CPC	==	0X27

B2_POLE_TMR	==	0X28	;极性反转计时和标记
;--------
B2_KEY1_GET	==	0X29
B2_KEY2_GET	==	0X2A
B2_KEY3_GET	==	0X2B
B2_KEY4_GET	==	0X2C
B2_KEY1_BAK	==	0X2D
B2_KEY2_BAK	==	0X2E
B2_KEY3_BAK	==	0X2F
B2_KEY4_BAK	==	0X30
B2_KEY1_VAL	==	0X31
B2_KEY2_VAL	==	0X32
B2_KEY3_VAL	==	0X33
B2_KEY4_VAL	==	0X34
B2_TMR_KEYSCAN	==	0X35
B2_TMR_KEYAFFM	==	0X36
B2_KEYFLAG	==	0X37

B2_TMR_PLUSE_BAK==	0X38
B2_TMR_PLUSE	==	0X39

B2_TMR_BEEP	==	0X3A



B2_RING_FLAG	==	0X3B
B2_RING_ID	==	0X3C
B2_RING_TMR	==	0X3D
B2_BUF		==	0X3E
B2_BUF1		==	0X3F
;-------------------------------------------------------------------------------
; bank 3
B3_CidTimer	==	0X20
B3_CidCheckSum	==	0X21
B3_CidLength	==	0X22


;---
B3_1BIOSVER	==	0X23
B3_2BIOSVER	==	0X24
B3_3BIOSVER	==	0X25
B3_4BIOSVER	==	0X26
;-------------------------------------------------------------------------------
; bit



