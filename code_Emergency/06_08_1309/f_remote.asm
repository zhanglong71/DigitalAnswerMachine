;-------------------------------------------------------------------------------
.NOLIST
;---------------------------------------
.INCLUDE	include.inc
;---------------------------------------
.GLOBAL	REMOTE_PRO
;-------------------------------------------------------------------------------
.EXTERN	GetOneConst
;-------------------------------------------------------------------------------
.LIST
;-------------------------------------------------------------------------------
.ORG	ADDR_SECOND
;-------------------------------------------------------------------------------
.LIST
REMOTE_PRO:
	CALL	GET_RESPOND
	
	CALL	GET_MSG
	BS	ACZ,REMOTE_PRO_END
	SAH	MSG	
;-------------------------------------------------------------------------------
REMOTE_PRO_MSG:
	LAC	MSG
	XORL	CMSG_SER
	BS	ACZ,REMOTE_PRO_SER	;SEG-end

	LAC	MSG
	XORL	CHF_WORK
	BS	ACZ,REMOTE_PRO_HFREE
	LAC	MSG
	XORL	CHS_WORK
	BS	ACZ,REMOTE_PRO_HSETOFF

	LAC	PRO_VAR
	ANDL	0X0F
	BS	ACZ,REMOTE_PRO0		;0 = IDEL
	SBHK	1
	BS	ACZ,REMOTE_PROPNEW	;1 = play new
	SBHK	1
	BS	ACZ,REMOTE_PROPALL	;2 = play all
	SBHK	1
	BS	ACZ,REMOTE_PROMREC	;3 = record MEMO
	SBHK	4
	BS	ACZ,REMOTE_PROOGM	;7 = record/play OGM
	SBHK	1
	BS	ACZ,REMOTE_PROMONIT	;8 = room monitor
	SBHK	1
	BS	ACZ,REMOTE_PRO_END		;9 = reserved
	SBHK	1
	BS	ACZ,REMOTE_PROEXIT	;10 = exit

REMOTE_PRO_END:	
	RET
;---------------------------------------
REMOTE_PRO_STOP:
REMOTE_PRO_PMINE:
	LACL	CMSG_CPC
	CALL	STOR_MSG	;����CPCһ������
	
	RET
;---------------------------------------

REMOTE_PRO_SER:
	CALL	GETR_DAT
	ANDL	0XFF
	SAH	MSG
;-------------------
	LAC	MSG
	SBHK	0X5A
	BS	ACZ,REMOTE_PRO_SER_0X5A	;(0X5A)stop
	SBHK	0X04
	BS	ACZ,REMOTE_PRO_SER_0X5E	;(0X5E)Phone on/off
	SBHK	0X02
	BS	ACZ,REMOTE_PRO_SER_0X60	;(0X60)Handset on/off
	
	RET
;---------------------------------------
;-----------------------------
REMOTE_PRO_SER_0X5A:	;Stop(Same as CPC)
	LACL	CMSG_CPC
	CALL	STOR_MSG
	
	RET	
;-----------------------------
REMOTE_PRO_SER_0X5E:
	CALL	GETR_DAT
	ANDL	0X0FF
	BS	ACZ,REMOTE_PRO_SER_0X5E0X00
	SBHK	1
	BS	ACZ,ANS_STATE_SER_0X5E0X01
	
	RET
;---------
REMOTE_PRO_SER_0X5E0X00:
	LACL	CMSG_CPC
	CALL	STOR_MSG

	LACL	CHF_IDLE	;speaker phone mode
	CALL	STOR_MSG

	RET
;---------	
ANS_STATE_SER_0X5E0X01:
REMOTE_PRO_HFREE:
	LACL	CMSG_CPC
	CALL	STOR_MSG

	LACL	CHF_WORK	;speaker phone mode
	CALL	STOR_MSG

	RET
;---------------------------------------
REMOTE_PRO_SER_0X60:
	CALL	GETR_DAT
	ANDL	0X0FF
	BS	ACZ,REMOTE_PRO_SER_0X600X00
	SBHK	1
	BS	ACZ,REMOTE_PRO_SER_0X600X01
	
	RET
REMOTE_PRO_SER_0X600X00:
	LACL	CMSG_CPC
	CALL	STOR_MSG
	
	LACL	CHS_IDLE	;put down the handset to on hook for end a call
	CALL	STOR_MSG
	
	RET
REMOTE_PRO_SER_0X600X01:
REMOTE_PRO_HSETOFF:
	LACL	CMSG_CPC
	CALL	STOR_MSG
	
	LACL	CHS_WORK	;pickup the handset to off hook in handset mode
	CALL	STOR_MSG
	
	RET
;-------------------------------------------------------------------------------
REMOTE_PRO0:
	LAC	MSG
	XORL	CMSG_INIT		;INITIAL(������BEEP)
	BS	ACZ,REMOTE_PRO0_INIT
;REMOTE_PRO0_1:
	LAC	MSG
	XORL	CREV_DTMF		;CREV_DTMF
	BS	ACZ,REMOTE_PRO0_REV_DTMF
;REMOTE_PRO0_2:	
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,REMOTE_PRO0_STOPVP	;VP��
;REMOTE_PRO0_3:	
	LAC	MSG
	XORL	CMSG_BTONE
	BS	ACZ,REMOTE_PRO0_TONE
;REMOTE_PRO0_4:	
	LAC	MSG
	XORL	CMSG_CTONE
	BS	ACZ,REMOTE_PRO0_TONE
;REMOTE_PRO0_5:	
	LAC	MSG
	XORL	CMSG_TMR
	BS	ACZ,REMOTE_PRO0_TMR
;REMOTE_PRO0_6:		
	LAC	MSG			;���ߺ�ժ��(�൱��CPC)
	XORL	CMSG_CPC
	BS	ACZ,REMOTE_PRO0_CPC
	
	RET
;---------------------------------------
REMOTE_PRO0_CPC:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACL	0X005
	CALL	STOR_VP
	CALL	VPMSG_CHK
	
	LACK	10
	SAH	PRO_VAR

	RET
;---------------------------------------
REMOTE_PRO0_INIT:
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK
	CALL	BBEEP		;BB
	
	RET
;---------------------------------------
REMOTE_PRO0_STOPVP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_REC
	CALL	LINE_START
	
	LACK	0			;��ʼ��ʱ
	SAH	PRO_VAR1
	LACL	CTMR1S
	CALL	SET_TIMER
	
	CALL	BCVOX_INIT
	
	RET
;---------------------------------------
REMOTE_PRO0_REV_DTMF:
	CALL	CLR_TIMER
	LACK	0
	SAH	PRO_VAR1
	CALL	BCVOX_INIT
		
	LAC	DTMF_VAL
	CALL	RMTFUNC_CHK
	BS	ACZ,REMOTE_PRO0_INDOORMONITOR	;0 (0&#)---in door monitor
	SBHK	1
	BS	ACZ,REMOTE_PRO0_PLYNEW		;1 (1&#)---play new
	SBHK	1
	BS	ACZ,REMOTE_PRO0_PLYALL		;2 (2&#)---play all
	SBHK	1
	BS	ACZ,REMOTE_PRO0_ERAOLD		;3 (3&#)---erase all
	SBHK	4
	BS	ACZ,REMOTE_PRO0_PROONOFF	;7 (7&#)---on/off
	SBHK	1
	BS	ACZ,REMOTE_PRO0_RECOGM		;8 (8&#)---record/play OGM
	SBHK	1
	BS	ACZ,REMOTE_PRO0_RECMEMO		;9 (9&#)---record memo
	
	RET	
;---------------------------------------
REMOTE_PRO0_PLYNEW:
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK
	
	CALL	VPMSG_CHK
	BIT	ANN_FG,12
	BS	TB,REMOTE_PRO0_PLYNEW_1

	CALL	BBBEEP		;BBB
	
	LACK	0
	SAH	PRO_VAR
	RET
REMOTE_PRO0_PLYNEW_1:
	LACK	0
	SAH	PRO_VAR1
	LACL	CTMR1S
	CALL	SET_TIMER
	
	LACK	1
	SAH	PRO_VAR

	LACK	0
	SAH	MSG_ID

	LACL	0X005
	CALL	STOR_VP
	
	RET	
	
REMOTE_PRO0_PLYALL:
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK
	CALL	VPMSG_CHK

	LACK	0
	SAH	MSG_ID
	
	BIT	ANN_FG,14
	BS	TB,REMOTE_PRO0_REV_DTMF_2_1

	CALL	BBBEEP		;BBB
	LACK	0
	SAH	PRO_VAR
	
	BS	B1,REMOTE_PRO0_REV_DTMF_2_END
REMOTE_PRO0_REV_DTMF_2_1:
	LACK	0
	SAH	PRO_VAR1
	LACL	CTMR1S
	CALL	SET_TIMER
	
	LACK	2
	SAH	PRO_VAR

	LACL	0X005
	CALL	STOR_VP
REMOTE_PRO0_REV_DTMF_2_END:
	
	RET
;---------------------------------------
REMOTE_PRO0_ERAOLD:
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK
	CALL	VPMSG_CHK
	LACK	0
	SAH	PRO_VAR
	
	LACL	0X6100
	CALL	DAM_BIOSFUNC
	
	LACL	0X6080
	CALL	DAM_BIOSFUNC

	CALL	VPMSG_CHK
	BIT	ANN_FG,14
	BS	TB,REMOTE_PRO0_REV_DTMF_3_1

	CALL	BBBEEP		;BBB
	
	RET
REMOTE_PRO0_REV_DTMF_3_1:	
	CALL	BBEEP		;BB

	RET
;---------------------------------------
REMOTE_PRO0_RECOGM:
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK
	
	CALL	OGM_SELECT	;Delete old first
	LAC	MSG_ID
	ORL	0X6000
	CALL	DAM_BIOSFUNC
	CALL	GC_CHK
	
	CALL	VPMSG_CHK
	
	BIT	ANN_FG,13
	BS	TB,REMOTE_PRO0_RECOGM_MFUL
	
	LACK	0X0007
	SAH	PRO_VAR
	CALL	LBEEP		;Lbee...
	
	RET
REMOTE_PRO0_RECOGM_MFUL:
	CALL	INIT_DAM_FUNC
	CALL	BBBEEP
	CALL	VP_MemoryIsFull
	LACK	0X0017
	SAH	PRO_VAR
	
	RET
;---------------------------------------
REMOTE_PRO0_RECMEMO:
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK
	
	BIT	ANN_FG,13
	BS	TB,REMOTE_PRO0_RECMEMO_MFUL
	
	LACK	0X0003
	SAH	PRO_VAR
	CALL	LBEEP		;Lbee...

	RET
REMOTE_PRO0_RECMEMO_MFUL:		;mfull ֱ���˳�
	CALL	BBBEEP
	CALL	VP_MemoryIsFull
	LACK	0
	SAH	PRO_VAR

	RET
;---------------------------------------
REMOTE_PRO0_INDOORMONITOR:
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK
	CALL	LBEEP		;Lbee...
		
	LACK	0X0008
	SAH	PRO_VAR
	
	RET
;---------------------------------------
REMOTE_PRO0_PROONOFF:
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK
	LAC	EVENT
	XORL	1<<9
	SAH	EVENT

	BIT	EVENT,9
	BS	TB,REMOTE_PRO0_PROOFF
;REMOTE_PRO0_PROON:
	CALL	BEEP
	CALL	BEEP
	
	RET
REMOTE_PRO0_PROOFF:
	CALL	BEEP
	CALL	BEEP
	CALL	BEEP
	
	RET
;---------------------------------------
REMOTE_PRO0_EXIT:
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK
		
	LACK	10
	SAH	PRO_VAR

	LACL	0X005
	CALL	STOR_VP

	RET
;---------------------------------------
REMOTE_PRO0_TONE:
	BS	B1,REMOTE_PRO0_EXIT
REMOTE_PRO0_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	;SBHK	10
	SBHK	20		;20s�޲����˳�
	BZ	SGN,REMOTE_PRO0_EXIT
	
	RET	
;-------------------------------------------------------------------------------
REMOTE_PROPNEW:				;������message
	LAC	MSG			;���ߺ�ժ��(�൱��CPC)
	XORL	CMSG_CPC
	BS	ACZ,REMOTE_PROPNEW_CPC
	
	LAC	PRO_VAR
	SFR	4
	ANDK	0XF
	BS	ACZ,REMOTE_PROPNEW0
	SBHK	1
	BS	ACZ,REMOTE_PROX_PAUSE		;������ͣ
	SBHK	1
	BS	ACZ,REMOTE_PROXTMR_PAUSE	;ʱ����ͣ(play 2'40",wait for key press)
	
	RET
;---------------
REMOTE_PROPNEW_CPC:
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACL	0X005
	CALL	STOR_VP
	
	LACL	0X6100
	CALL	DAM_BIOSFUNC
	CALL	GC_CHK
	CALL	VPMSG_CHK
	
	LACK	10
	SAH	PRO_VAR
	
	RET
;-----------------------------------------------------------
REMOTE_PROPNEW0:
	LAC	MSG
	XORL	CVP_STOP		;PLAY END
	BS	ACZ,REMOTE_PROPNEW_OVER
;REMOTE_PROPNEW0_1:
	LAC	MSG
	XORL	CREV_DTMF		;CREV_DTMF
	BS	ACZ,REMOTE_PROPNEW_DTMF
;REMOTE_PROPNEW0_2:
	LAC	MSG
	XORL	CMSG_BTONE		;CMSG_BTONE
	BS	ACZ,REMOTE_PROEXIT_VPSTOP
;REMOTE_PROPNEW0_3:
	LAC	MSG
	XORL	CMSG_TMR		;CMSG_TMR
	BS	ACZ,REMOTE_PROPNEW0_TMR
;REMOTE_PROPNEW0_4:	

	RET
;---------------------------------------
REMOTE_PROPNEW0_TMR:
REMOTE_PROPX_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHL	160		;2��40��
	;SBHL	16
	BZ	SGN,REMOTE_PROPX_TMRPASUE
	
	RET
REMOTE_PROPX_TMRPASUE:
	LAC	COMMAND
	ORL	1<<8
	CALL	DAM_BIOSFUNC
	
	LACL	500
	CALL	PAUBEEP		;BEEP Prompt

	LAC	PRO_VAR
	ORK	0X20
	SAH	PRO_VAR
	
	LACL	CTMR1S
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1
	
	RET
;---------------------------------------
REMOTE_PROPNEW_OVER:
	LAC	MSG_ID
	SBH	MSG_N
	BZ	SGN,REMOTE_PROX_PLYSTOP

	LAC	MSG_ID			;next message
	ADHK	1
	SAH	MSG_ID
REMOTE_PRONEW_LOADNEWVP:
	CALL	BEEP

	LAC	MSG_ID
	ORL	0XFD00
	CALL	STOR_VP
		
	CALL	STOR_TIMETAG_NEW
	
	RET
;---------------------------------------
REMOTE_PROPNEW_DTMF:	
	LAC	DTMF_VAL
	CALL	RMTFUNC_CHK
	SBHK	3
	BS	ACZ,REMOTE_PRONEW_ERAPLYING	;3#---erase playing message
	SBHK	1
	BS	ACZ,REMOTE_PROPNEW_PLYPRE	;4#---repeat/previous message
	SBHK	1
	BS	ACZ,REMOTE_PROX_PLYSTOP		;5#---stop play message
	SBHK	1
	BS	ACZ,REMOTE_PROPNEW_NEXT		;6#---repeat message
	
	RET
;-------------------
REMOTE_PRONEW_ERAPLYING:
	CALL	INIT_DAM_FUNC
	LAC	MSG_ID
	ORL	0X2480
	CALL	DAM_BIOSFUNC
	LACK	0X025
	CALL	STOR_VP
	
	RET
;-------
REMOTE_PROPNEW_PLYPRE:
	CALL	INIT_DAM_FUNC

	LAC	MSG_ID
	SBHK	1
	BS	ACZ,REMOTE_PROPNEW_PLYPRE_1

	LAC	MSG_ID
	SBHK	1
	SAH	MSG_ID	
	
REMOTE_PROPNEW_PLYPRE_1:
	BS	B1,REMOTE_PRONEW_LOADNEWVP
;-------
REMOTE_PROPNEW_REPEAT:
	CALL	INIT_DAM_FUNC
	BS	B1,REMOTE_PRONEW_LOADNEWVP
;-------
REMOTE_PROPNEW_NEXT:
	CALL	INIT_DAM_FUNC
	BS	B1,REMOTE_PROPNEW_OVER
;-------
REMOTE_PROX_DO_PAUSE:
	LAC	COMMAND
	ORL	1<<8
	CALL	DAM_BIOSFUNC
	
	LAC	PRO_VAR
	ORK	0X10
	SAH	PRO_VAR
	
	LACL	CTMR1S
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1
	
	RET
;-------------------------------------------------------------------------------
REMOTE_PROX_PAUSE:
	LAC	MSG
	XORL	CREV_DTMF		;CREV_DTMF
	BS	ACZ,REMOTE_PROX_PAUSE_DTMF
REMOTE_PROX_PAUSE_1:
	LAC	MSG
	XORL	CMSG_TMR		;CMSG_TMR
	BS	ACZ,REMOTE_PROX_PAUSE_TIMER
	
	RET
;---------------------------------------
REMOTE_PROX_PAUSE_DTMF:
	LAC	DTMF_VAL
	CALL	RMTFUNC_CHK
	SBHK	3
	BS	ACZ,REMOTE_PROX_ERAPLYING	;3#---erase playing message
	SBHK	1
	BS	ACZ,REMOTE_PROPNEW_PLYPRE	;6#---skip to previous message
	SBHK	1
	BS	ACZ,REMOTE_PROX_PLYSTOP		;7#---skip to next message
	SBHK	1
	BS	ACZ,REMOTE_PROPNEW_NEXT		;8#---repeat message
	
	RET
;---------------------------------------
REMOTE_PROX_ERAPLYING:
	RET
;---------------
REMOTE_PROX_PAUSE_TIMER:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	10
	BS	SGN,REMOTE_PROX_PAUSE_TIMER_1
	
	CALL	INIT_DAM_FUNC
	CALL	BBEEP
	LACK	0
	SAH	PRO_VAR

REMOTE_PROX_PAUSE_TIMER_1:	
	RET
REMOTE_PROX_PAUSE_PLY:
	LAC	COMMAND
	ANDL	~(1<<8)
	CALL	DAM_BIOSFUNC
	
	LAC	PRO_VAR
	ANDL	0XFF0F
	SAH	PRO_VAR
	
	RET
;-------------------------------------------------------------------------------
REMOTE_PROXTMR_PAUSE:		;ʱ����ͣ
	LAC	MSG
	XORL	CREV_DTMF		;Any key pressed,then continue play
	BS	ACZ,REMOTE_PROXTMR_PAUSE_DTMF
REMOTE_PROXTMR_PAUSE_1:
	LAC	MSG
	XORL	CMSG_TMR		;CMSG_TMR
	BS	ACZ,REMOTE_PROXTMR_PAUSE_TIMER

	RET
;---------------
REMOTE_PROXTMR_PAUSE_DTMF:
	LAC	COMMAND
	ANDL	~(1<<8)
	CALL	DAM_BIOSFUNC
	
	LAC	PRO_VAR
	ANDL	0XFF0F
	SAH	PRO_VAR
	
	LACK	0
	SAH	PRO_VAR1

	RET
REMOTE_PROXTMR_PAUSE_TIMER:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	8
	BZ	SGN,REMOTE_PROXTMR_PAUSE_TIMER_EXIT
	
	RET
REMOTE_PROXTMR_PAUSE_TIMER_EXIT:
	CALL	INIT_DAM_FUNC

	LACL	0X6100
	CALL	DAM_BIOSFUNC

	BS	B1,REMOTE_PRO0_EXIT

;=======================================================================
;22222222222222222222222222222222222222222222222222222222222222222222222
REMOTE_PROPALL:
	LAC	MSG			;���ߺ�ժ��(�൱��CPC)
	XORL	CMSG_CPC
	BS	ACZ,REMOTE_PROPALL_CPC
	
	LAC	PRO_VAR
	SFR	4
	ANDK	0XF
	BS	ACZ,REMOTE_PROPALL0		;����
	SBHK	1
	BS	ACZ,REMOTE_PROX_PAUSE		;������ͣ
	SBHK	1
	BS	ACZ,REMOTE_PROXTMR_PAUSE	;ʱ����ͣ

	RET
;---------------------------------------
REMOTE_PROPALL_CPC:
	BS	B1,REMOTE_PROPNEW_CPC
;-------------------------------------------------------------------------------
REMOTE_PROPALL0:	
	LAC	MSG
	XORL	CVP_STOP		;PLAY END
	BS	ACZ,REMOTE_PROPALL_OVER
REMOTE_PROPALL0_1:
	LAC	MSG
	XORL	CREV_DTMF		;CREV_DTMF
	BS	ACZ,REMOTE_PROPALL_DTMF
REMOTE_PROPALL0_2:
	LAC	MSG
	XORL	CMSG_BTONE		;CMSG_BTONE
	BS	ACZ,REMOTE_PROEXIT_VPSTOP
REMOTE_PROPALL0_3:	
	LAC	MSG
	XORL	CMSG_TMR		;CMSG_TMR
	BS	ACZ,REMOTE_PROPALL0_TMR
	
	RET
;---------------------------------------
REMOTE_PROPALL0_TMR:
	BS	B1,REMOTE_PROPX_TMR
;---------------------------------------
REMOTE_PROPALL_OVER:	
	LAC	MSG_ID
	SBH	MSG_T
	BZ	SGN,REMOTE_PROX_PLYSTOP

	LAC	MSG_ID			;next message
	ADHK	1
	SAH	MSG_ID

REMOTE_PROALL_LOADVP:
	CALL	BEEP

	LAC	MSG_ID
	ORL	0XFE00
	CALL	STOR_VP
	
	CALL	STOR_TIMETAG_ALL
	
	RET
;---------------------------------------
REMOTE_PROPALL_DTMF:	
	LAC	DTMF_VAL
	CALL	RMTFUNC_CHK
	SBHK	3
	BS	ACZ,REMOTE_PROALL_ERAPLYING	;3#---erase playing message
	SBHK	1
	BS	ACZ,REMOTE_PROPALL_PLYPRE	;4#---repeat/previous message
	SBHK	1
	BS	ACZ,REMOTE_PROX_PLYSTOP		;5#---stop play message
	SBHK	1
	BS	ACZ,REMOTE_PROPALL_NEXT		;6#---next message
	
	RET
;---------------------------------------
REMOTE_PROALL_ERAPLYING:
	CALL	INIT_DAM_FUNC
	LAC	MSG_ID
	ORL	0X2080
	CALL	DAM_BIOSFUNC
	LACK	0X025
	CALL	STOR_VP
	;CALL	BEEP
	
	RET
;---------------------------------------
REMOTE_PROPALL_PLYPRE:		;ǰһ��
	CALL	INIT_DAM_FUNC

	LAC	MSG_ID
	SBHK	1
	BS	ACZ,REMOTE_PROPALL_PLYPRE_1 ;��һ����?
	
	LAC	MSG_ID
	SBHK	1
	SAH	MSG_ID	
	
REMOTE_PROPALL_PLYPRE_1:
	BS	B1,REMOTE_PROALL_LOADVP
;---------------------------------------
REMOTE_PROPALL_REPEAT:		;�ظ���ǰ��һ��
	CALL	INIT_DAM_FUNC
	BS	B1,REMOTE_PROALL_LOADVP
;---------------------------------------
REMOTE_PROPALL_NEXT:		;��һ��
	CALL	INIT_DAM_FUNC
	BS	B1,REMOTE_PROPALL_OVER
;---------------------------------------
REMOTE_PROX_PLYSTOP:
	CALL	INIT_DAM_FUNC
	CALL	BBEEP		;BB
	CALL	VPMSG_CHK
	
	LACL	0X6100
	CALL	DAM_BIOSFUNC

	LACK	0
	SAH	PRO_VAR
	SAH	PRO_VAR1
	
	RET
;-------------------------------------------------------------------------------
REMOTE_PROMREC:
	LAC	PRO_VAR
	SFR	4
	BS	ACZ,REMOTE_PROMREC0	;play LBEEP
	SBHK	1
	BS	ACZ,REMOTE_PROMREC1	;record MEMO
	SBHK	1
	BS	ACZ,REMOTE_PROMREC2	;record end BEEP
	RET
;-------------------------------------------------------------------------------
REMOTE_PROMREC0:
	LAC	MSG
	XORL	CVP_STOP		;PLAY END
	BS	ACZ,REMOTE_PROMREC0_OVER
	
	LAC	MSG			;���ߺ�ժ��(�൱��CPC)
	XORL	CMSG_CPC
	BS	ACZ,REMOTE_PRO0_CPC
	
	RET
;---------------------------------------
REMOTE_PROMREC0_OVER:
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_REC
	LACK	0X0013
	SAH	PRO_VAR
	CALL	VPMSG_CHK

	CALL	REC_START

	LACL	CTMR1S
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1

	RET
;-------------------------------------------------------------------------------
REMOTE_PROMREC1:
	LAC	MSG
	XORL	CMSG_TMR		;TIMER
	BS	ACZ,REMOTE_PROMREC1_TIMER
	LAC	MSG
	XORL	CMSG_2TMR		;TIMER2
	BS	ACZ,REMOTE_PROMREC1_TIMER2
	LAC	MSG
	XORL	CREV_DTMFS		;DTMF
	BS	ACZ,REMOTE_PROMREC1_DTMFS
	LAC	MSG
	XORL	CREV_DTMF		;DTMF
	BS	ACZ,REMOTE_PROMREC1_DTMF
	LAC	MSG
	XORL	CMSG_BTONE
	BS	ACZ,REMOTE_PROMREC1_BTONE
	LAC	MSG
	XORL	CMSG_CTONE
	BS	ACZ,REMOTE_PROMREC1_CTONE
	LAC	MSG
	XORL	CREC_FULL		;REC_FULL
	BS	ACZ,REMOTE_PROMREC1_STOP
	LAC	MSG			;���ߺ�ժ��(�൱��CPC)
	XORL	CMSG_CPC
	BS	ACZ,REMOTE_PROMREC1_CPC
	
	RET
;---------------------------------------
REMOTE_PROMREC1_CPC:
	LAC	PRO_VAR1
	SBHK	2
	BZ	SGN,REMOTE_PROMREC1_CPC1
	
	LAC	COMMAND
	ORL	1<<11
	SAH	COMMAND
	CALL	DAM_BIOSFUNC
REMOTE_PROMREC1_CPC1:	
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF
	LACK	0X005
	CALL	STOR_VP

	CALL	VPMSG_CHK
	
	LACK	0X00A
	SAH	PRO_VAR

	RET

;---------------------------------------
REMOTE_PROMREC1_CTONE:
REMOTE_PROMREC1_BTONE:
	CALL	INIT_DAM_FUNC
	CALL	VPMSG_CHK
	LAC	MSG_T
	ORL	0XA400
	CALL	DAM_BIOSFUNC
	SBHK	3
	BZ	SGN,REMOTE_PROMREC1_END
;---ɾ����3s�̵�¼��
	LAC	MSG_T
	ORL	0X6000
	CALL	DAM_BIOSFUNC
	CALL	GC_CHK
REMOTE_PROMREC1_END:
	BS	B1,REMOTE_PRO0_TONE
REMOTE_PROMREC1_TIMER:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1	;time length 1min
	SBHK	60
	BZ	SGN,REMOTE_PROMREC1_STOP
	
	RET

;---------------------------------------
REMOTE_PROMREC1_TIMER2:
	LAC	PRO_VAR2
	ADHK	1
	SAH	PRO_VAR2
	
	RET
;---------------------------------------
REMOTE_PROMREC1_DTMFS:
	LAC	DTMF_VAL
	XORL	0XF8
	BS	ACZ,REMOTE_PROMREC1_8DTMF	;pressed "8"

	RET
REMOTE_PROMREC1_8DTMF:		;��8�ͼ�ʱ��0
	LACK	0
	SAH	PRO_VAR2
	LACL	CTMR400MS
	CALL	SET_2TIMER
	
	RET
;---------------------------------------
REMOTE_PROMREC1_DTMF:
	
	LAC	DTMF_VAL
	CALL	RMTFUNC_CHK
	SBHK	5
	BS	ACZ,REMOTE_PROMREC1_DTMF_STOP	;pressed "5","#"

	RET
;---------------------------------------
REMOTE_PROMREC1_DTMF_STOP:
	LAC	COMMAND
	OR	PRO_VAR2
	ADHK	1
	CALL	DAM_BIOSFUNC
REMOTE_PROMREC1_STOP:		;mfull/timer over
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK

	CALL	CLR_TIMER2
;---
	CALL	VPMSG_CHK
	LAC	MSG_T
	ORL	0XA400
	CALL	DAM_BIOSFUNC
	SBHK	3
	BZ	SGN,REMOTE_PROMREC1_STOP1
;---ɾ����3s�̵�¼��
	LAC	MSG_T
	ORL	0X6000
	CALL	DAM_BIOSFUNC
	CALL	GC_CHK
REMOTE_PROMREC1_STOP1:
		
	CALL	BEEP
	LACK	0X003F		;��ʱ
	CALL	STOR_VP

	CALL	VPMSG_CHK
	
	LACK	0X0023
	SAH	PRO_VAR
	
	RET
;-------------------------------------------------------------------------------
REMOTE_PROMREC2:
	LAC	MSG
	XORL	CVP_STOP		
	BS	ACZ,REMOTE_PROMREC2_VPSTOP	;beep�������
	
	LAC	MSG			;���ߺ�ժ��(�൱��CPC)
	XORL	CMSG_CPC
	BS	ACZ,REMOTE_PRO0_CPC

	RET
;---------------------------------------
REMOTE_PROMREC2_VPSTOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK
	CALL	BBEEP

	LACK	0X0
	SAH	PRO_VAR
	SAH	PRO_VAR1
	
	RET
;=======================================================================
;44444444444444444444444444444444444444444444444444444444444444444444444
;REMOTE_PRO4:
;=======================================================================
;55555555555555555555555555555555555555555555555555555555555555555555555
;REMOTE_PRO5:
;=======================================================================
;66666666666666666666666666666666666666666666666666666666666666666666666
;REMOTE_PRO6:
	RET
;=======================================================================
;77777777777777777777777777777777777777777777777777777777777777777777777
REMOTE_PROOGM:
	LAC	PRO_VAR
	SFR	4
	BS	ACZ,REMOTE_PROOGM0	;play LBEEP
	SBHK	1
	BS	ACZ,REMOTE_PROOGM_REC	;record OGM
	SBHK	1
	BS	ACZ,REMOTE_PROOGM_PLY	;play OGM
	
	RET
;-------------------------------------------------------------------------------
REMOTE_PROOGM_REC:
	LAC	MSG
	XORL	CMSG_TMR		;TIMER
	BS	ACZ,REMOTE_PROOGM_REC_TMR
	LAC	MSG
	XORL	CMSG_2TMR		;TIMER2
	BS	ACZ,REMOTE_PROOGM_REC_TMR2
;REMOTE_PRO7_RECORD_1:
	LAC	MSG
	XORL	CREV_DTMFS		;DTMFS
	BS	ACZ,REMOTE_PROOGM_REC_DTMFS
	LAC	MSG
	XORL	CREV_DTMF		;DTMF
	BS	ACZ,REMOTE_PROOGM_REC_DTMF
;REMOTE_PRO7_RECORD_2:	
	LAC	MSG
	XORL	CMSG_BTONE
	BS	ACZ,REMOTE_PROOGM_REC_BTONE
;REMOTE_PRO7_RECORD_3:	
	LAC	MSG
	XORL	CMSG_CTONE
	BS	ACZ,REMOTE_PROOGM_REC_CTONE
;REMOTE_PRO7_RECORD_4:	
	LAC	MSG
	XORL	CREC_FULL		;REC_FULL
	BS	ACZ,REMOTE_PROOGM_REC_MFUL
;REMOTE_PRO7_RECORD_5:
	LAC	MSG			;���ߺ�ժ��(�൱��CPC)
	XORL	CMSG_CPC
	BS	ACZ,REMOTE_PROOGM_REC_CPC
;REMOTE_PRO7_RECORD_6:
	LAC	MSG			;Beep/Memfull
	XORL	CVP_STOP
	BS	ACZ,REMOTE_PROOGM_REC_STOP

	RET
;---------------------------------------
REMOTE_PROOGM_REC_CPC:
	BS	B1,REMOTE_PROMREC1_CPC
;---------------------------------------
REMOTE_PROOGM_REC_MFUL:
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK
	CALL	BBBEEP
	CALL	VP_MemoryIsFull
	
	RET	
;---------------------------------------	
REMOTE_PROOGM_REC_CTONE:
REMOTE_PROOGM_REC_BTONE:
	CALL	INIT_DAM_FUNC
	CALL	VPMSG_CHK
	LAC	MSG_T
	;CALL	GET_VPTLEN
	SBHK	3
	BZ	SGN,REMOTE_PRO7_RECORD_END
;---ɾ����3s�̵�¼��
	LAC	MSG_T
	ORL	0X6000
	CALL	DAM_BIOSFUNC
	CALL	GC_CHK
REMOTE_PRO7_RECORD_END:
	BS	B1,REMOTE_PRO0_TONE
;---------------------------------------
REMOTE_PROOGM_REC_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	60
	BZ	SGN,REMOTE_PROOGM_REC_STOP

	RET
;---------------------------------------
REMOTE_PROOGM_REC_TMR2:
	LAC	PRO_VAR2
	ADHK	1
	SAH	PRO_VAR2
	
	RET
;---------------------------------------
REMOTE_PROOGM_REC_DTMFS:
	CALL	BCVOX_INIT
	
	LAC	DTMF_VAL
	XORL	0XF7
	BS	ACZ,REMOTE_PROOGM_REC_7DTMFS	;pressed "7","#"

	RET
;---------------------------------------
REMOTE_PROOGM_REC_7DTMFS:
	LACK	0
	SAH	PRO_VAR2
	LACL	CTMR400MS
	CALL	SET_2TIMER

	RET
;---------------------------------------
REMOTE_PROOGM_REC_DTMF:	
	LAC	DTMF_VAL
	CALL	RMTFUNC_CHK
	SBHK	5
	BS	ACZ,REMOTE_PROOGM_REC_DTMF_STOP		;pressed "5","#"

	RET
;---------------------------------------
REMOTE_PROOGM_REC_DTMF_STOP:
	LAC	PRO_VAR1
	SBHK	2
	BZ	SGN,REMOTE_PROOGM_REC_DTMF_STOP1
	
	LAC	COMMAND
	ORL	1<<11
	CALL	DAM_BIOSFUNC	;¼��̫��,ֱ��ɾ��
REMOTE_PROOGM_REC_DTMF_STOP1:	
	LAC	COMMAND
	OR	PRO_VAR2
	ADHK	1
	CALL	DAM_BIOSFUNC
	
REMOTE_PROOGM_REC_STOP:		;����"#","mfull"

	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_SPK
	LACK	0X0027
	SAH	PRO_VAR
	
	CALL	CLR_TIMER2
	
	CALL	OGM_SELECT
	
	CALL	BEEP
	LAC	MSG_ID
	ORL	0XFE00
	CALL	STOR_VP

	CALL	OGM_SELECT
	BZ	ACZ,MAIN_PRO0_PLAY_OGM1
	
	CALL	INIT_DAM_FUNC
	CALL	BEEP
	CALL	VP_DefOGM
	
MAIN_PRO0_PLAY_OGM1:

	RET	

;-------------------------------------------------------------------------------	
REMOTE_PROOGM0:
	LAC	MSG
	XORL	CVP_STOP		;PLAY END
	BS	ACZ,REMOTE_PRO7_PLAY_OVER
	
	LAC	MSG			;���ߺ�ժ��(�൱��CPC)
	XORL	CMSG_CPC
	BS	ACZ,REMOTE_PRO0_CPC
	
	RET
;---------------------------------------
REMOTE_PRO7_PLAY_OVER:
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_REC
	LACK	0X0017
	SAH	PRO_VAR
;---
	CALL	OGM_SELECT
;---	
	CALL	REC_START
	LACK	0
	SAH	PRO_VAR1
	LACL	CTMR1S
	CALL	SET_TIMER

	RET
;-------------------------------------------------------------------------------
REMOTE_PROOGM_PLY:
	LAC	MSG
	XORL	CVP_STOP		;CVP_STOP
	BS	ACZ,REMOTE_PROOGM_PLY_STOP
;REMOTE_PRO7_2_1:
	LAC	MSG
	XORL	CREV_DTMF		;CREV_DTMF
	BS	ACZ,REMOTE_PROOGM_PLY_DTMF
;REMOTE_PRO7_2_2:	
	LAC	MSG			;���ߺ�ժ��(�൱��CPC)
	XORL	CMSG_CPC
	BS	ACZ,REMOTE_PRO0_CPC
	
	RET
;---------------------------------------
REMOTE_PROOGM_PLY_STOP:
	CALL	INIT_DAM_FUNC	
	CALL	BBEEP
	
	LACK	0
	SAH	PRO_VAR
	SAH	PRO_VAR1

	RET

;---------------------------------------
REMOTE_PROOGM_PLY_DTMF:
	LAC	DTMF_VAL
	CALL	RMTFUNC_CHK
	SBHK	3
	BS	ACZ,REMOTE_PROOGM_PLY_DTMF_3	;"3","#"
	SBHK	2
	BS	ACZ,REMOTE_PROOGM_PLY_STOP	;"5","#"

	RET
;---------------------------------------
REMOTE_PROOGM_PLY_DTMF_3:
	CALL	INIT_DAM_FUNC
	CALL	OGM_SELECT
;---delete the old OGM fisrt------------
	LAC	MSG_ID
	ORL	0X6000
	CALL	DAM_BIOSFUNC
	CALL	GC_CHK

	CALL	BBEEP		;BB
	LACK	0
	SAH	PRO_VAR
	
	RET
;=======================================================================
;88888888888888888888888888888888888888888888888888888888888888888888888
REMOTE_PROMONIT:
	LAC	MSG			;���ߺ�ժ��(�൱��CPC)
	XORL	CMSG_CPC
	BS	ACZ,REMOTE_PRO0_CPC
	
	LAC	PRO_VAR
	SFR	4
	ANDK	0X0F
	BS	ACZ,REMOTE_PROMONIT_VOP
	SBHK	1
	BS	ACZ,REMOTE_PROMONIT_MONIT
	
	RET
;---------------------------------------
REMOTE_PROMONIT_MONIT:
	LAC	MSG
	XORL	CREV_DTMF		;CREV_DTMF
	BS	ACZ,REMOTE_PRORMONIT_DTMF
	LAC	MSG
	XORL	CMSG_TMR		;TIMER
	BS	ACZ,REMOTE_PRORMONIT_TIMER

	RET
;---------------������Ϣ
REMOTE_PRORMONIT_DTMF:
	LAC	DTMF_VAL
	CALL	RMTFUNC_CHK
	BS	ACZ,REMOTE_PRORMONIT_RESTART	;"0","#"
	SBHK	5
	BS	ACZ,REMOTE_PRORMONIT_STOP	;"5","#"

	RET
;---------------------------------------
REMOTE_PRORMONIT_RESTART:
	LACK	0
	SAH	PRO_VAR1

	RET

;---------------------------------------
REMOTE_PRORMONIT_STOP:
	CALL	INIT_DAM_FUNC
	CALL	BCVOX_INIT
	
	LACK	0
	SAH	PRO_VAR
	SAH	PRO_VAR1
	
	LACL	CMSG_INIT
	CALL	STOR_MSG

	RET

;---------------------------------------
REMOTE_PRORMONIT_TIMER:
	LACL	CTMR_CTONE	;---���ò���VOX,CTONE��Ϣ,�ɲ���BTONE
	SAH	TMR_VOX
	SAH	TMR_CTONE
	
	LAC	PRO_VAR1	;��ʱ
	ADHK	1
	SAH	PRO_VAR1
	SBHK	30		;30s��ʱ
	BZ	SGN,REMOTE_PRORMONIT_STOP
		
	RET
;-------------------------------------------------------------------------------
REMOTE_PROMONIT_VOP:
	LAC	MSG
	XORL	CVP_STOP			;CVP_STOP
	BS	ACZ,REMOTE_PROMONIT_VOPOVER
	
	RET
;---------------------------------------
REMOTE_PROMONIT_VOPOVER:
	CALL	INIT_DAM_FUNC
	CALL	DAA_ROMMOR_ON
	CALL	LINE_START
	
	LACK	0X0018
	SAH	PRO_VAR
	
	LACL	CTMR1S
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1


	RET	
;-------------------------------------------------------------------------------
REMOTE_PROEXIT:
	LAC	MSG
	XORL	CVP_STOP
	BS	ACZ,REMOTE_PROEXIT_VPSTOP
	
	RET
;---------------------------------------
REMOTE_PROEXIT_VPSTOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_OFF	
	CALL	HOOK_ON		;hook idle

	LACL	CMODE9
	CALL	DAM_BIOSFUNC

	CALL	VPMSG_CHK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	SEND_MSGNUM
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	MSGLED_IDLE

	CALL	CLR_FUNC
	LACL	LOCAL_PRO	;goto local mode
     	CALL	PUSH_FUNC	
	
	LACK	0
	SAH	PRO_VAR

	LACL	CMSG_INIT
	CALL	STOR_MSG

	RET
;-------------------------------------------------------------------------------
;       Function : RMTFUNC_CHK
;       Password check
;	Input  : ACCH = VALUE(DTMF_VAL)
;       Output : ACCH = 0 - 0x0#
;                       1 - 0x1#
;                       2 - 0x2#
;                       3 - 0x3#
;                       4 - 0x4#
;                       5 - 0x5#
;                       6 - 0x6#
;                       7 - 0x7#
;                       8 - 0x8#
;                       9 - 0x9#
;                       A - 0xA#
;                       B - 0xB#
;                       C - 0xC#
;                       D - 0xD#
;                       E - 0x*#
;                       F - 0x##
;
;                       0XFF - password fail
;-------------------------------------------------------------------------------
RMTFUNC_CHK:
        SAH	SYSTMP0
;RMTFUNC_CHK1:
        LAC     PSWORD_TMP
        SFL	8
	OR	SYSTMP0
        SAH     PSWORD_TMP	;PSWORD_TMP keep the new input digit string
        
        LAC     PSWORD_TMP
	SAH     SYSTMP0
	
	LACK	0
	SAH	PSWORD_TMP
;-------------------------------------------------------------------------------
	LAC     SYSTMP0
	ANDL	0XF0FF
        XORL	0XF0FF
        BZ      ACZ,RMTFUNC_NOT_IN	;Not "#"

	LAC     SYSTMP0
	SFR	8
	ANDK	0X0F
	
	RET
;-------------------
RMTFUNC_NOT_IN:		;the intput not digital or wrong remote access code
	LAC     SYSTMP0
	SAH     PSWORD_TMP
	
        LACL    0XFF
        RET	

;---------------------------------------
	;LIPK 6
	;OUTL 0x8E85, ANALOG_POWER_REG
	;OUTL 0x0B,ANALOG_SWITCH_REG      
	;OUTL 0x00CB, ANALOG_MUTE_REG 
;---------------------------------------
DAA_ROMMOR_ON:
	LIPK    6	
.IF	1		
				; MIC ->pre-pga -> ad1-pga -> SW4 -> LOUT
				; LIN -> ad2-pga -> ADC2
	OUTK	(1<<4)|(1<<1)|1,SWITCH
		;OUTK	(1<<4)|1,SWITCH
	OUTL	(0x17<<5),LOUTSPK
		;LOPVOL
	;OUTL	0X0F50,AGC
	OUTL	(0XF<<8)|(0XB<<4),AGC
	;	MIC	 AGCM	  AGCL
.ELSE	
	OUTL	0x8E85,ANAPWR
	OUTL	0x0B,SWITCH
	OUTL	0x00CB,MUTE
	OUTL	0x2F0,LOUTSPK 	; Bit4-0: SPK-DRV, Bit9-5: LOUT-DRV
	OUTL	0xF50,AGC     	; Bit7-4: AD0-PGA, Bit11-8:MIC-PGA
 
.ENDIF		
	RET

;-------------------------------------------------------------------------------

.INCLUDE	l_beep/l_bbbeep.asm
.INCLUDE	l_beep/l_lbeep.asm
.INCLUDE	l_beep/l_pbeep.asm

;.INCLUDE	l_CodecPath/l_allopen.asm
.INCLUDE	l_CodecPath/l_rmtply.asm
.INCLUDE	l_CodecPath/l_rmtrec.asm

;.INCLUDE	l_flashmsg/l_biosfull.asm
;.INCLUDE	l_flashmsg/l_flashmsg.asm
.INCLUDE	l_flashmsg/l_plymsg.asm
.INCLUDE	l_flashmsg/l_flashogm.asm

.INCLUDE	l_iic/l_storsqueue.asm
.INCLUDE	l_iic/l_getrqueue.asm
.INCLUDE	l_iic/l_flashfull.asm
.INCLUDE	l_iic/l_flashmsg.asm
.INCLUDE	l_iic/l_exit.asm

.INCLUDE	l_math/l_hexdgt.asm

.INCLUDE	l_line.asm

.INCLUDE	l_port/l_cidtalk.asm
.INCLUDE	l_port/l_hookidle.asm
;.INCLUDE	l_port/l_hookoff.asm
.INCLUDE	l_port/l_hookon.asm
.INCLUDE	l_port/l_hwalc.asm
.INCLUDE	l_port/l_msgled.asm
.INCLUDE	l_port/l_spkctl.asm

.INCLUDE	l_respond/l_btone.asm
.INCLUDE	l_respond/l_ctone.asm
.INCLUDE	l_respond/l_vox.asm
.INCLUDE	l_respond/l_dtmf.asm
.INCLUDE	l_respond/l_ansrmt_resp.asm

.INCLUDE	l_table/l_dtmftable.asm

.INCLUDE	l_voice/l_answeroff.asm
.INCLUDE	l_voice/l_answeron.asm
.INCLUDE	l_voice/l_call.asm
.INCLUDE	l_voice/l_endof.asm
.INCLUDE	l_voice/l_memfull.asm
.INCLUDE	l_voice/l_num.asm
.INCLUDE	l_voice/l_plymsg.asm
.INCLUDE	l_voice/l_plyogm.asm
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
.END
	