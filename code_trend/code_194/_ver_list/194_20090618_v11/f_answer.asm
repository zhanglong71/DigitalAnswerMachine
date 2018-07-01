.NOLIST
.INCLUDE MD20U.INC
.INCLUDE REG_D20.inc
.INCLUDE CONST.INC
.INCLUDE EXTERN.INC
;-------------------------------------------------------------------------------
.EXTERN	SetFlashStartAddress
.EXTERN	LoadHostCode
.EXTERN	GetOneConst	;(INPUT=ACCH(ProgramRamAddress),OUTPUT=ACCH(ReadData))
.EXTERN	GetMoreConst	;(INPUT=ACCH(ProgramRamStartingAddress)ACCL(ReadWordNumber)AR1(StoreDataRamAddress),OUTPUT=)
;-------------------------------------------------------------------------------
.GLOBAL	ANS_STATE
;-------------------------------------------------------------------------------
.LIST
.ORG    ADDR_SECOND
;-------------------------------------------------------------------------------
ANS_STATE:
	LAC	MSG
	XORL	CMSG_KEY7S		;接线按ON/OFF(相当于CPC)
	BS	ACZ,ANS_STATE_STOP
;---
	LAC	MSG
	XORL	CMSG_KEYBP		;VOL+
	BS	ACZ,ICM_STATE_VOLP
	LAC	MSG
	XORL	CMSG_KEYBD		;VOL+
	BS	ACZ,ICM_STATE_VOLA
;---
	LAC	PRO_VAR
	ANDK	0XF
	BS	ACZ,ANS_STATE0		;(0Xyyy0) - for initial
	SBHK	1
	BS	ACZ,ANS_STATE_VOP	;(0Xyyy1) - VOP before record/psword
	SBHK	1
	BS	ACZ,ANS_STATE_REC	;(0Xyyy2) - for record(ANSWER AND RECORD ICM)
	SBHK	1
	BS	ACZ,ANS_STATE_LINE	;(0Xyyy3) - for line(ANSWER ONLY)
	SBHK	1
	BS	ACZ,ANS_STATE_EXIT	;(0Xyyy4) - for end(TimeOut/BTONE/CTONE/VOX_ON)

	RET
;---------------------------------------
ICM_STATE_VOLP:
	LAC	VOI_ATT
	ANDK	0XF
	SBHK	CMAX_VOL
	BZ	SGN,ICM_STATE_VOL_END	;已经是最大了就不再增大
ICM_STATE_VOLA:
	LACL	CMSG_VOLA
	CALL	STOR_MSG
;---	
	LACK	CMIN_VOL
	SAH	SYSTMP1
	LACK	CMAX_VOL
	SAH	SYSTMP2
	
	LAC	VOI_ATT
	ANDK	0XF
	CALL	VALUE_ADD
	SAH	SYSTMP0
	
	LAC	VOI_ATT
	ANDL	0XFFF0
	OR	SYSTMP0
	SAH	VOI_ATT
;---
ICM_STATE_VOL_END:
	RET

;---------------------------------------
ANS_STATE_STOP:
	LACL	CMSG_CPC
	SAH	MSG
	BS	B1,ANS_STATE
;-------------------------------------------------------------------------------
ANS_STATE0:
	LAC	MSG
	XORL	CMSG_INIT		;INITIAL
	BS	ACZ,ICM_STATE_INIT
	LAC	MSG
	XORL	CMSG_CPC		;接线后摘机(相当于CPC)
	BS	ACZ,ANS_STATE0_CPC

	RET
;---------------------------------------
ANS_STATE0_CPC:
	BS	B1,ANS_STATE_EXIT_END
;---------------------------------------
ICM_STATE_INIT:
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_SPK
	CALL	SET_COMPS
	CALL	BCVOX_INIT
	CALL	BLED_ON	

	LACL	CMODE9|(1<<3)	;Line ON
	CALL	DAM_BIOSFUNC
     	
     	LACK	1
     	SAH	MBOX_ID		;Default mailbox
     	
     	LACL	0XFFFF
	SAH	PSWORD_TMP
	CALL	HOOK_ON
;!!!!!!!!!!!!!!!    	
     	LACL	0XD0		;告诉MCU摘机了
	CALL	SEND_DAT
	LACK	0
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!
	CALL	CLR_TIMER
	LACK	0
   	SAH	PRO_VAR1
;---有新来电吗?
	BIT	ANN_FG,1
	BZ	TB,ICM_STATE_INIT_CHKCID_END

;---新来电是Filter吗?
	LACK	CGROUP_CID
	CALL	SET_TELGROUP

	CALL	GET_TELT
	SAH	MSG_T
	ORL	0XEA00
	CALL	DAM_BIOSFUNC	;Get the index-0
	ANDK	0X03
	SBHK	0X02
	BZ	ACZ,ICM_STATE_INIT_CHKCID_END
;---Filter-CID
	LACK	3
	CALL	OGM_SELECT
	BS	ACZ,ICM_STATE_INIT_DEFOGM
	BS	B1,ICM_STATE_INIT_SELOGM
ICM_STATE_INIT_CHKCID_END:	

	CALL	OGM_STATUS	;选择当前OGM
	BS	ACZ,ICM_STATE_INIT_DEFOGM
ICM_STATE_INIT_SELOGM:
;ICM_STATE_INIT_RECDOGM:	;播录制的语音
	LACK	0X07D
	CALL	STOR_VP		;延时1 second
	LAC	MSG_ID
	ANDL	0X0FF
	ORL	0XFE00
	CALL	STOR_VP
	
	BS	B1,ICM_STATE_INIT_CHK
;---------------------------------------
ICM_STATE_INIT_DEFOGM:		;播默认的语音()
	LACK	0X030
	CALL	STOR_VP

	LAC	MSG_N
	ANDK	0X0F
	SBHK	3
	;BS	ACZ,ICM_STATE_INIT_EXIT		;OGM3无Default VOP
	BS	ACZ,ICM_STATE_INIT_DEFOGM5	
	
	CALL	INIT_DAM_FUNC	;for OGM(1,2,3,4)
	LACK	0X07D
	CALL	STOR_VP		;延时1 second
	CALL	VP_DEFAULTOGM

	CALL	LBEEP
	LACK	0X11
	SAH	PRO_VAR		;VOP before record

	RET
ICM_STATE_INIT_DEFOGM5:
	call	VP_DEFANSONLYOGM
ICM_STATE_INIT_EXIT:
	CALL	BEEP
	
	LACK	0X21
	SAH	PRO_VAR
	
	RET
;---------------------------------------	
ICM_STATE_INIT_CHK:	;VP exit
	LAC	MSG_N
	ANDK	0X0F
	SBHK	3
	BS	ACZ,ICM_STATE_INIT_EXIT	
ICM_STATE_INIT_CHK_1:
	CALL	LBEEP
	LACK	0X11
	SAH	PRO_VAR		;VOP before record
	
	RET
;-------------------------------------------------------------------------------
ANS_STATE_VOP:	
	LAC	MSG
	XORL	CVP_STOP		
	BS	ACZ,ANS_STATE_VOP_VPSTOP	;CVP_STOP,OGM播放完毕
;ANS_STATE_VOP_1:
	LAC	MSG
	XORL	CREV_DTMF		;CREV_DTMF
	BS	ACZ,ANS_STATE_VOP_DTMF
;ANS_STATE_VOP_2:
	LAC	MSG
	XORL	CMSG_CPC		;接线后摘机(相当于CPC)
	BS	ACZ,ANS_STATE_VOP_CPC
;ANS_STATE_VOP_3:
	LAC	MSG
	XORL	CMSG_VOX		;VOX_ON 10s
	BS	ACZ,ANS_STATE_VOP_VOX
;ANS_STATE_REC_4:
	LAC	MSG
	XORL	CMSG_CTONE		;CTONE 10s
	BS	ACZ,ANS_STATE_VOP_CTONE
;ANS_STATE_REC_5:
	LAC	MSG
	XORL	CMSG_BTONE		;BTONE 10s
	BS	ACZ,ANS_STATE_VOP_BTONE

	RET
;---------------------------------------
ANS_STATE_VOP_CPC:
	BS	B1,ANS_STATE_EXIT_END
;---------------------------------------
ANS_STATE_VOP_VOX:
ANS_STATE_VOP_BTONE:
ANS_STATE_VOP_CTONE:
	BS	B1,ANS_STATE_EXIT_END
;---------------------------------------
ANS_STATE_VOP_DTMF:		;Check '*' when play OGM
	LAC	DTMF_VAL
	XORL	0XFE
	BS	ACZ,ANS_STATE_VOP_DTMF_CHKSTAR

	CALL	BCVOX_INIT	;有键按下BCVOX要清零
	
	LAC	DTMF_VAL
	ANDK	0X0F
	CALL	PSWORD_CHK	;check psword
	BS	ACZ,ANS_STATE_VOP_DTMFPASS
				;change mailbox is no need when playing OGM
	RET
;---------------------------------------
ANS_STATE_VOP_DTMF_CHKSTAR:
	LAC	PRO_VAR
	SFR	4
	ANDK	0X0F
	SBHK	2
	BS	ACZ,ANS_STATE_VOP_DTMF_CHKSTAR1
	
	CALL	INIT_DAM_FUNC
	CALL	LBEEP

	RET
ANS_STATE_VOP_DTMF_CHKSTAR1:	
	CALL	INIT_DAM_FUNC
	CALL	BEEP
	
	RET
;---------------------------------------	
ANS_STATE_VOP_VPSTOP:		;开始录音(ICM)/ON_LINE(only)
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_REC
	CALL	BCVOX_INIT

	LACK	0
	SAH	PRO_VAR1
	LACL	CTMR1S
	CALL	SET_TIMER
	
	LAC	PRO_VAR
	SFR	4
	ANDK	0X0F
	SBHK	2
	BS	ACZ,ANS_STATE_VOP_VPSTOP2

	CALL	INIT_DAM_FUNC
	LACK	0X02		;OGM1,2,3,4/record
	SAH	PRO_VAR
	
	CALL	VPMSG_CHK

;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XC5
	CALL	SEND_DAT
	LACK	1
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!

;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LAC	PRO_VAR1	;秒
	CALL	SEND_HHMMSS
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	CTAG_ICM	;set ICM flag(we can recognize it as an ICM message)
	CALL	SET_USRDAT1
	
	CALL	REC_START
;ANS_STATE_VOP_VPSTOP1:		

	RET
ANS_STATE_VOP_VPSTOP2:
	LACK	0X03		;OGM5/line
	SAH	PRO_VAR
	CALL	LINE_START

	RET
;---------------------------------------
ANS_STATE_VOP_DTMFPASS:		;psword ok
	CALL	INIT_DAM_FUNC
	CALL	DAA_LIN_REC

	LAC	ANN_FG
	ANDL	~(1<<1)
	SAH	ANN_FG		;New-CID flag

	LACL	CRMOT_OK
	CALL	STOR_MSG
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XC6		;stop record ICM
	CALL	SEND_DAT
	LACK	1
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XAAAA
	SAH	PSWORD_TMP
	LACK	0
	SAH	PRO_VAR1	;clear timer
	CALL	BCVOX_INIT

	RET
;-------------------------------------------------------------------------------
ANS_STATE_REC:
	LAC	MSG
	XORL	CREV_DTMF		;DTMF
	BS	ACZ,ANS_STATE_REC_DTMF
;ANS_STATE_REC_1:
	LAC	MSG
	XORL	CMSG_TMR		;time 1s
	BS	ACZ,ANS_STATE_REC_TMR
;ANS_STATE_REC_2:
	LAC	MSG
	XORL	CMSG_VOX		;VOX_ON 10s
	BS	ACZ,ANS_STATE_REC_VOX
;ANS_STATE_REC_3:
	LAC	MSG
	XORL	CMSG_CTONE		;CTONE 10s
	BS	ACZ,ANS_STATE_REC_CTONE
;ANS_STATE_REC_4:
	LAC	MSG
	XORL	CMSG_BTONE		;BTONE 10s
	BS	ACZ,ANS_STATE_REC_BTONE
;ANS_STATE_REC_5:
	LAC	MSG
	XORL	CREC_FULL		;REC_FULL
	BS	ACZ,ANS_STATE_REC_FULL
;ANS_STATE_REC_6:	
	LAC	MSG
	XORL	CMSG_CPC		;接线后摘机(相当于CPC)
	BS	ACZ,ANS_STATE_REC_CPC
;ANS_STATE_REC_7:
	
	RET
;---------------------------------------
ANS_STATE_REC_DTMF:
	CALL	BCVOX_INIT	;有键按下BCVOX要清零
	
	LAC	DTMF_VAL
	ANDK	0X0F
	CALL	PSWORD_CHK
	BS	ACZ,ANS_STATE_REC_DTMFPASS
	
	RET
;---------------------------------------
ANS_STATE_REC_DTMFPASS:		;密码成功
	LAC	CONF
	ORL	1<<11
	CALL	DAM_BIOSFUNC	;若是录音过程,则删除之	
	BS	B1,ANS_STATE_VOP_DTMFPASS
;---------------------------------------
ANS_STATE_REC_CPC:
	LAC	PRO_VAR1
	SBHK	3
	BZ	SGN,ANS_STATE_REC_CPC_0
;---录音时间小于3秒——删除之	
	LAC	CONF
	ORL	1<<11
	CALL	DAM_BIOSFUNC
	CALL	INIT_DAM_FUNC
	
	CALL	GC_CHK
	BS	B1,ANS_STATE_REC_CPC_END
ANS_STATE_REC_CPC_0:
	CALL	INIT_DAM_FUNC
	BIT	ANN_FG,1
	BZ	TB,ANS_STATE_REC_CPC_END	;有 NEW CID吗?
;---有NEW CID
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;---
	CALL	GET_TOTALMSG
	CALL	GET_ONLYID	;get only id of the newest VP
	CALL	SET_TELUSRDAT	;set user data0
;---Copy the latest TEL to Destation Group
	LACK	CGROUP_CID
	CALL	SET_TELGROUP

	CALL	GET_TELT
	SAH	MSG_T
	ORL	0XED00
	CALL	DAM_BIOSFUNC	;copy caller_id to the mailbox
	LAC	MBOX_ID
	ORL	0XED00
	CALL	DAM_BIOSFUNC	;Destnation MBOX

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
ANS_STATE_REC_CPC_END:	
	BS	B1,ANS_STATE_EXIT_END
;---------------------------------------
ANS_STATE_REC_VOX:	;考虑小长度的录音删除问题
ANS_STATE_REC_BTONE:
ANS_STATE_REC_CTONE:
;---Recording
	CALL	INIT_DAM_FUNC
	CALL	GET_TOTALMSG
	SAH	MSG_T			;总数(同时也是最后一条录音的ID号)
	CALL	GET_VPTLEN
	SBHK	3
	BZ	SGN,ANS_STATE_RECSUCC
;---录音长度小于3秒——删除	
	LAC	MSG_T
	ORL	0X6000
	CALL	DAM_BIOSFUNC
	CALL	GC_CHK
	BS	B1,ANS_STATE_REC_BCVOX_END

ANS_STATE_RECSUCC:
;---Record success
	BIT	ANN_FG,1
	BZ	TB,ANS_STATE_REC_BCVOX_END	;有来电吗?

ANS_STATE_RECSUCC_CID:		;---录音成功且有来电
	CALL	INIT_DAM_FUNC
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;---
	CALL	GET_TOTALMSG
	CALL	GET_ONLYID	;get only id of the newest VP
	CALL	SET_TELUSRDAT	;set user data0
;---Copy the latest TEL to Destation Group
	LACK	CGROUP_CID
	CALL	SET_TELGROUP

	CALL	GET_TELT
	SAH	MSG_T
	ORL	0XED00
	CALL	DAM_BIOSFUNC	;copy caller_id to the mailbox
	LAC	MBOX_ID
	ORL	0XED00
	CALL	DAM_BIOSFUNC	;Destnation MBOX

	;LAC	MBOX_ID
	;CALL	SET_TELGROUP
	;CALL	GET_TELT
	;SAH	MSG_T

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
ANS_STATE_REC_BCVOX_END:
	BS	B1,ANS_STATE_EXIT_END
;---------------------------------------
ANS_STATE_REC_TMR:
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	CLICM
	BZ	SGN,ANS_STATE_RECSUCC	;---录音时间上限到
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LAC	PRO_VAR1	;秒
	CALL	SEND_HHMMSS
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	RET
;---------------------------------------
ANS_STATE_REC_FULL:
	CALL	INIT_DAM_FUNC
	CALL	BBBEEP		;警告语音BBB
	CALL	VP_MEMFUL
	
	LACK	0X04
	SAH	PRO_VAR		;退出答录
	
	RET
;-------------------------------------------------------------------------------
ANS_STATE_LINE:
	LAC	MSG
	XORL	CREV_DTMF		;REV DTMF
	BS	ACZ,ANS_STATE_LINE_DTMF
;ANS_STATE_LINE_1:
	LAC	MSG
	XORL	CMSG_TMR		;time 1s
	BS	ACZ,ANS_STATE_LINE_TMR
;ANS_STATE_LINE_2:
	LAC	MSG
	XORL	CMSG_VOX		;VOX_ON 8s
	BS	ACZ,ANS_STATE_LINE_VOX
;ANS_STATE_LINE_3:
	LAC	MSG
	XORL	CMSG_CTONE		;C-TONE 8s
	BS	ACZ,ANS_STATE_LINE_CTONE
;ANS_STATE_LINE_4:
	LAC	MSG
	XORL	CMSG_BTONE		;B-TONE
	BS	ACZ,ANS_STATE_LINE_BTONE
;ANS_STATE_LINE_5:
	LAC	MSG
	XORL	CMSG_CPC		;接线后摘机(相当于CPC)
	BS	ACZ,ANS_STATE_LINE_CPC

	RET
;---------------------------------------
ANS_STATE_LINE_CPC:
	BS	B1,ANS_STATE_EXIT_END
;---------------------------------------
ANS_STATE_LINE_VOX:
ANS_STATE_LINE_BTONE:
ANS_STATE_LINE_CTONE:
	BS	B1,ANS_STATE_EXIT_END
;---------------------------------------
ANS_STATE_LINE_DTMF:
	LACK	0
	SAH	PRO_VAR1
	LACL	CTMR1S
	CALL	SET_TIMER
	
	CALL	BCVOX_INIT	;有键按下BCVOX要清零
	
	LAC	DTMF_VAL
	ANDK	0X0F
	CALL	PSWORD_CHK
	BS	ACZ,ANS_STATE_VOP_DTMFPASS
	
	RET
;---------------------------------------
ANS_STATE_LINE_TMR:		;for memful/answer only/answer off
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	3
	BS	SGN,ANS_STATE_LINE_TMREND

	LACK	0X04
	SAH	PRO_VAR
	
	CALL	INIT_DAM_FUNC
	CALL	DAA_ANS_SPK
	CALL	BBEEP		;替换语音BB
ANS_STATE_LINE_TMREND:

	RET
;-------------------------------------------------------------------------------
ANS_STATE_EXIT:
	LAC	MSG
	XORL	CVP_STOP		
	BS	ACZ,ANS_STATE_EXIT_END	;VOP STOP播放完毕
	LAC	MSG
	XORL	CMSG_CPC		
	BS	ACZ,ANS_STATE_EXIT_END	;CPC
	
	RET
;---------------------------------------
ANS_STATE_EXIT_END:

	CALL	INIT_DAM_FUNC
	CALL	HOOK_OFF
	CALL	CLR_FUNC	;先空
	LACK	0
	SAH	PRO_VAR

	LAC	ANN_FG
	ANDL	~(1<<1)
	SAH	ANN_FG		;New-CID flag
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XD0		;告诉MCU挂机了
	CALL	SEND_DAT
	LACK	1
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	CMODE9		;Line OFF
	CALL	DAM_BIOSFUNC
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0XC6
	CALL	SEND_DAT
	LACK	1
	CALL	SEND_DAT
	LACL	0X0FF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACK	CGROUP_CID
	CALL	SET_TELGROUP
	CALL	GET_TELT	;来电总数同步
	SAH	MSG_N

	LACL	0X82		;新旧来电同步(3bytes)
	CALL	SEND_DAT
	LACK	0
	CALL	SEND_DAT
	LAC	MSG_N
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	VPMSG_CHK
	CALL	NEWICM_CHK
	LACK	1
	SAH	MBOX_ID
	
	CALL	VPMSG_CHK
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	CALL	SEND_MSGNUM	;录音数量同步(4bytes)
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	0X9E
	CALL	SEND_DAT
	LACK	6
	CALL	SEND_DAT
	LACL	0XFF
	CALL	SEND_DAT
;!!!!!!!!!!!!!!!!!!!!!!!!!!!

	LACL	CMSG_INIT
	CALL	STOR_MSG

	RET	
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;       Function : PSWORD_CHK
;       Password check
;	Input  : ACCH = VALUE(DTMF_VAL)
;       Output : ACCH = 0 - password in ok
;                       1 - password for mailbox 1
;                       2 - password for mailbox 2
;                       3 - password for mailbox 3
;                       0XFF - password fail
;-------------------------------------------------------------------------------
PSWORD_CHK:
        SAH	SYSTMP0

        LAC     PSWORD_TMP
        SFL     4
	OR	SYSTMP0
        SAH     PSWORD_TMP        ; PSWORD_TMP keep the new input digit string
;-------------------------------------------------------------------------------
        LAC     PSWORD_TMP
        ANDL    0X0FFF
        SBH     PASSWORD
        BS      ACZ,PSWORD_IN_OK
;---
        LAC     PSWORD_TMP
        XORL	0XF1F
        ANDL	0X0FFF
        BS      ACZ,PSWORD_MBOX1_OK
;---
        LAC     PSWORD_TMP
        XORL	0XF2F
        ANDL	0X0FFF
        BS      ACZ,PSWORD_MBOX2_OK
;---
        LAC     PSWORD_TMP
        XORL	0XF3F
        ANDL	0X0FFF
        BS      ACZ,PSWORD_MBOX3_OK
;---
        LAC     PSWORD_TMP
        XORL	0XF4F
        ANDL	0X0FFF
        BS      ACZ,PSWORD_MBOX4_OK
        
        

PSWORD_NOT_IN:		;the intput not digital or wrong remote access code
        LACL    0XFF
        RET	
PSWORD_IN_OK:
	LACK	0
        RET
PSWORD_MBOX1_OK:
	LACK	1
	RET
PSWORD_MBOX2_OK:
	LACK	2
	RET
PSWORD_MBOX3_OK:
	LACK	3
	RET
PSWORD_MBOX4_OK:
	LACK	4
	RET
;--------------------------------------------------------------------------------
.INCLUDE	l_math.asm
;-------------------------------------------------------------------------------
.END
