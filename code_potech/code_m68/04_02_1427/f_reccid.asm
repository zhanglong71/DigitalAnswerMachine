.NOLIST
.INCLUDE	include/REG_D22.inc
.INCLUDE	include/MD22U.inc
.INCLUDE	include/CONST.inc

.GLOBAL	LOCAL_PROCID
;-------------------------------------------------------------------------------
.EXTERN	GetOneConst

.EXTERN	INIT_DAM_FUNC

.EXTERN	BCVOX_INIT
.EXTERN	BBBEEP
.EXTERN	BBEEP
.EXTERN	BEEP

.EXTERN	CLR_FUNC
.EXTERN	CLR_TIMER

.EXTERN	DAA_SPK
.EXTERN	DAA_REC
.EXTERN	DAA_OFF
.EXTERN	DAM_BIOSFUNC
.EXTERN	DAM_BIOSFUNC1
.EXTERN	DELAY
.EXTERN	DGT_TAB
.EXTERN	DGT_HEX
.EXTERN	DspStop
.EXTERN	HEX_DGT

.EXTERN	GC_CHK
.EXTERN	TEL_GC_CHK
.EXTERN	GETBYTE_DAT

.EXTERN	LBEEP

.EXTERN	LINE_START
.EXTERN	LOCAL_PRO
.EXTERN	MIDI_STOP
.EXTERN	MIDI_WCOM

.EXTERN	OGM_SELECT

.EXTERN	PUSH_FUNC

;.EXTERN	REAL_DEL
.EXTERN	REC_START

.EXTERN	SET_PLYPSA
.EXTERN	SET_TIMER

.EXTERN	SEND_DAT
;.EXTERN	SEND_MFULL
.EXTERN	SEND_MSGNUM
;.EXTERN	SEND_RECSTART
.EXTERN	SEND_TEL
.EXTERN	SET_DECLTEL
.EXTERN	STOR_MSG
.EXTERN	STOR_VP
.EXTERN	STORBYTE_DAT


.EXTERN	TELNUM_WRITE
.EXTERN	TELNUM_READ

.EXTERN	VPMSG_CHK
.EXTERN	VPMSG_DEL
;-------------------------------------------------------------------------------
;you can go to here,because you detected CID or ring,so you can exit when ring time out or
;hook_off or phone_on or exit
;-------------------------------------------------------------------------------
;---
.LIST
;-------------------------------------------------------------------------------
.ORG	ADDR_SECOND
;-------------------------------------------------------------------------------
LOCAL_PROCID:	
	LAC	MSG
	XORL	CFSK_CID		;FSK-CID
	BS	ACZ,LOCAL_PROCID_FSKCID
	LAC	MSG
	XORL	CDTMF_CID		;DTMF-CID
	BS	ACZ,LOCAL_PROCID_DTMFCID
	LAC	MSG
	XORL	CMSG_TMR		;TMR
	BS	ACZ,LOCAL_PROCID_TMR
;---	
	LAC	MSG
	XORL	CMIDI_VOP
	BS	ACZ,LOCAL_PROCID_MIDIVOP
;---
	LAC	MSG
	XORL	CRING_IN
	BS	ACZ,LOCAL_PROCID_RINGIN	;
;
	LAC	MSG
	XORL	CRING_FAIL
	BS	ACZ,LOCAL_PROCID_RINGFAIL

	LAC	MSG
	XORL	CHOOK_OFF
	BS	ACZ,LOCAL_PROCID_PHONE	;摘机
	LAC	MSG
	XORL	CPHONE_ON
	BS	ACZ,LOCAL_PROCID_PHONE	;免提

	RET
;---------------------------------------
LOCAL_PROCID_FSKCID:
	CALL	FSK_DECODE
	BS	B1,LOCAL_PROCID_COMPLCODE
LOCAL_PROCID_DTMFCID:
		
	CALL	DTMF_DECODE
LOCAL_PROCID_COMPLCODE:		;---Decode CID over,detect LocalCode
	CALL	INIT_DAM_FUNC

;---Set	Flag(New-CID have been write into Flash)
	LAC	ANN_FG
	ORL	(1<<2)
	SAH	ANN_FG

	;bs	b1,LOCAL_PROCID_SAVECID	;???????????????????????????????????????????????????????????
	LACL	CidData
	SAH	ADDR_S
	SAH	ADDR_D
;---
	LACK	5		;the offset of Num-Len Byte
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	SAH	CidLength	;for CID
	SBHK	16
	BZ	SGN,LOCAL_PROCID_irregularity	;

;---the length is less than 16
	LACK	6		;the offset of first Num
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	SAH	SYSTMP0
	SFL	12
	ANDL	0XF000
	SAH	LOCODE_TMP
	
	LAC	SYSTMP0
	SBHK	0X4F
	BS	ACZ,LOCAL_PROCID_private	;unavailable
	SBHK	0X01
	BS	ACZ,LOCAL_PROCID_private	;private
;-
	LACK	7		;the offset of first Num
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	SFL	8
	ANDL	0X0F00
	OR	LOCODE_TMP
	SAH	LOCODE_TMP
;-
	LACK	8		;the offset of second Num
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	SFL	4
	ANDL	0X00F0
	OR	LOCODE_TMP
	SAH	LOCODE_TMP
;-
	LACK	9		;the offset of third Num
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	ANDK	0X0F
	OR	LOCODE_TMP
	SAH	LOCODE_TMP
	
	CALL	CUT_LCODE
	BS	ACZ,LOCAL_PROCID_COMPBOOK
	ADHK	6
	SAH	OFFSET_S
	LACK	6	
	SAH	OFFSET_D
	
	LACK	31
	SAH	COUNT
LOCAL_PROCID_MOVE:		;OverWrite the LocalCode
	CALL	GETBYTE_DAT
	CALL	STORBYTE_DAT
	
	LAC	OFFSET_S
	ADHK	1
	SAH	OFFSET_S
	
	LAC	OFFSET_D
	ADHK	1
	SAH	OFFSET_D
	
	LAC	COUNT
	SBHK	1
	SAH	COUNT
	BZ	ACZ,LOCAL_PROCID_MOVE
;-------------------------------------------------LocalCode detect end
LOCAL_PROCID_COMPBOOK:		;---Decode CID and LocalCode det over,compare the data in phonebook(TEL-num only)
	LACK	0
	SAH	PRO_VAR1
	LACL	1000
	CALL	SET_TIMER
;---	
	CALL	INIT_DAM_FUNC
	LACK	CGROUP_PBOOK
	CALL	SET_TELGROUP	;Set phonebook Group
;---
	LACL	CidData
	SAH	ADDR_S
	SAH	ADDR_D
	LACK	56
	SAH	OFFSET_S
	SAH	OFFSET_D
	LACK	0
	CALL	STORBYTE_DAT	;the default Repeat-Byte=0

	LACL	CidData
	SAH	ADDR_S
	CALL	COMP_ALLTELNUM			;从电话本中找到有相同号码的条目
	BS	ACZ,LOCAL_PROCID_COMPBOOK_NOPBOOK	;电话本里没有找到相同号码的条目,直接开始比较CID
	SAH	SYSTMP1
;---读出比较得到的条目,将收到的CID覆盖
	LACL	CidData
	SAH	ADDR_D
	LACK	0
	SAH	OFFSET_D

	LAC	SYSTMP1
	CALL	TELNUM_READ
	
	LACL	CidData
	SAH	ADDR_S
	LACK	55
	SAH	OFFSET_S
	CALL	GETBYTE_DAT	;Get music id
	SAH	MIDI_ID

	LACL	CMIDI_VOP
	CALL	STOR_MSG	;!!!识别号码,然后发MIDI-VOP
	
	BS	B1,LOCAL_PROCID_COMPCID
LOCAL_PROCID_irregularity:	;irregularity CID

	LACK	5		;the offset of Num-Len Byte
	SAH	OFFSET_D
	LACK	0
	CALL	STORBYTE_DAT
LOCAL_PROCID_RING_MIDI:	
	LACL	CMIDI_VOP
	CALL	STOR_MSG	;!!!无识别到的号码,然后发MIDI-VOP
	LAC	DAM_ATT0
	SFR	4
	ANDK	0X00F
	SAH	MIDI_ID
	BS	B1,LOCAL_PROCID_SAVECID
LOCAL_PROCID_private:
	LACK	5		;the offset of Num-Len Byte
	SAH	OFFSET_D

	LAC	SYSTMP0
	CALL	STORBYTE_DAT

	BS	B1,LOCAL_PROCID_RING_MIDI
LOCAL_PROCID_COMPBOOK_NOPBOOK:		;没有在PBOOK中找到相同号码时
	LACL	CMIDI_VOP
	CALL	STOR_MSG	;!!!无识别到的号码,然后发MIDI-VOP
	LAC	DAM_ATT0
	SFR	4
	ANDK	0X00F
	SAH	MIDI_ID

;---------------------------------------
LOCAL_PROCID_COMPCID:		;compare the data in CID group
	
	LACK	CGROUP_MISSCID
	CALL	SET_TELGROUP	;Set CID Group

	CALL	COMP_ALLTEL	;find the same tel-number in old CID
	BS	ACZ,LOCAL_PROCID_SAVECID	;以前的CID中没有找到相同号码的条目,直接写入flash保存
	SAH	SYSTMP1
;---先清空目标区,不要亦可
	LACL	CidData
	SAH	ADDR_D
	LACK	0
	SAH	OFFSET_D
	LACK	64
	SAH	COUNT
	CALL	CLR_RAM	
;---Read TEL data with specific TEL-ID,over write the CID
	LACL	CidData
	SAH	ADDR_D
	LACK	0
	SAH	OFFSET_D
	LAC	SYSTMP1
	CALL	TELNUM_READ
;---!!!!!!!!!!!!!
	LAC	SYSTMP1
	CALL	DEL_ONETEL	;删除找到的号码
	CALL	TEL_GC_CHK
;---!!!!!!!!!!!!!
;---Repeat increase 1
	LACL	CidData
	SAH	ADDR_S
	SAH	ADDR_D
	LACK	56		;the offset of Repeat-Byte
	SAH	OFFSET_S
	SAH	OFFSET_D

	CALL	GETBYTE_DAT
	ADHK	1
	CALL	STORBYTE_DAT

LOCAL_PROCID_SAVECID:	;---compeare TEL end and begin write TEL into flash
	LACK	CGROUP_MISSCID
	CALL	SET_TELGROUP		;Set CID Group
	CALL	GET_TELT
	SBHK	CMAX_MISSCID	;The MAX. number off miss-CID
	BS	SGN,LOCAL_PROCID_SAVECID_EXE
;---99 TEL exist,delete oldest one
	LACK	1
	CALL	DEL_ONETEL
	CALL	TEL_GC_CHK
LOCAL_PROCID_SAVECID_EXE:
;---time first	
	LACL	CidData
	SAH	ADDR_D		;BASE address
	LACK	1		
	SAH	OFFSET_D	;offset-month
	CALL	CMONTH_GET
	CALL	STORBYTE_DAT
	LACK	2		
	SAH	OFFSET_D	;offset-day
	CALL	CDAY_GET
	CALL	STORBYTE_DAT
	LACK	3		
	SAH	OFFSET_D	;offset-hour
	CALL	CHOUR_GET
	CALL	STORBYTE_DAT
	LACK	4		
	SAH	OFFSET_D	;offset-minute
	CALL	CMIN_GET
	CALL	STORBYTE_DAT
;---
	LACK	57		
	SAH	OFFSET_D	;New flag(固定发0x80)
	LACL	0X080
	CALL	STORBYTE_DAT
;---Write data into flash
	LACL	CidData
	SAH	ADDR_S		;BASE address
	LACK	0
	SAH	OFFSET_S	;offset
	LACK	57
	SAH	COUNT		;counter
	CALL	TELNUM_WRITE
	CALL	DAT_WRITE_STOP
;---Write index-0 into the specified new TEL(set NEW-BIT flag).
	CALL	GET_TELT
	ORL	CFLAG<<8	;Set index-1 = CFLAG(new flag,固定写入CFLAG)
	CALL	SET_TELUSRID1

;---!!!!!!!!!!!!!!!!!!!!!!!!!!
.IF	1
;---total cid
	LACK	CGROUP_MISSCID
	CALL	SET_TELGROUP		;Set CID Group
	CALL	GET_TELT
	CALL	SEND_MISSCID
;---new cid
	CALL	GET_TELN
	CALL	SEND_NEWCID

	LACK	5
	CALL	DELAY
.ENDIF
;---!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	CidData
	SAH	ADDR_S
	LACK	0
	SAH	OFFSET_S
	LACK	58
	SAH	COUNT
	CALL	SEND_TEL

	LACK	20
	CALL	DELAY	

	LACK	0		;CID ok
	CALL	SEND_TELOK

	CALL	LINE_START	;!!!可继续收CID

	RET
;---------------------------------------------------------------------------------------------------
LOCAL_PROCID_RINGIN:
	LACK	0X19
	CALL	SEND_DAT
	LACK	0X19
	CALL	SEND_DAT
;-------
	LACL	1000
	CALL	SET_TIMER
	LACK	0
	SAH	PRO_VAR1

	RET
;-------------------------------------------------
LOCAL_PROCID_TMR:		;
	LAC	PRO_VAR1
	ADHK	1
	SAH	PRO_VAR1
	SBHK	8
	BZ	SGN,LOCAL_PROCID_STOP_TMROUT
	
	RET
;---------------------------------------------------------------------------------------------------
LOCAL_PROCID_RINGFAIL:
LOCAL_PROCID_STOP_TMROUT:
;---Reset Flag(new-CID)
	LAC	ANN_FG
	ANDL	~(1<<2)
	SAH	ANN_FG
;---
	CALL	INIT_DAM_FUNC
	CALL	MIDI_STOP
	CALL	DAA_OFF
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!	
	CALL	VPMSG_CHK
	CALL	SEND_MSGNUM		;Tell MCU
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	LACL	CMSG_INIT
	CALL	STOR_MSG
	LACK	0
	SAH	PRO_VAR		;先加入返回点
	
	RET
;-------------------------------------------------
LOCAL_PROCID_MIDIVOP:
	CALL	INIT_DAM_FUNC
	CALL	DAA_SPK
	CALL	LINE_START
	
	LAC	MIDI_ID		;(1..12)
	ADHK	0X21
	CALL	MIDI_WCOM	;(0X22..0X2D)

	RET
;-------------------------------------------------
LOCAL_PROCID_PHONE:
	;BS	B1,LOCAL_PROCID_PHONE	;???????????????????????????????????????
	CALL	INIT_DAM_FUNC
	CALL	MIDI_STOP
	LACK	0
	SAH	PRO_VAR		;先加入返回点
	
	LAC	MSG
	CALL	STOR_MSG
	
	RET
;-------------------------------------------------------------------------------
;	将原始的CID格式数据转换成自定义的格式(format convert)
;	!!!(ADDR_S-DS),(ADDR_D-ES),(OFFSET_S-SI),(OFFSET_D-DI),(COUNT-CX)
;-------------------------------------------------------------------------------
FSK_DECODE:
	LACL	CidBuffer	;the BASE address of originality CID data
	SAH	ADDR_S
	LACL	CidData		;the BASE address of Cooked CID data
	SAH	ADDR_D
	
	LACK	0
	SAH	OFFSET_S
	SAH	OFFSET_D
	LACL	0X80
	CALL	STORBYTE_DAT

	CALL	GETBYTE_DAT
	SBHK	0X04
	BS	ACZ,FSK_DECODE0X04
	SBHK	0X7C
	BS	ACZ,FSK_DECODE0X80
	SBHK	0X01
	BS	ACZ,FSK_DECODE0X81
	SBHK	0X01
	BS	ACZ,FSK_DECODE0X82

	BS	B1,FSK_DECODE_END
FSK_DECODE0X04:
;---Set base address
	LACL	CidBuffer
	SAH	ADDR_S
	LACL	CidData
	SAH	ADDR_D
;---Decode time
	LACK	2		;原始CID-Time数据的存放地址
	SAH	OFFSET_S
	LACK	1		;(1,2,3,4)解码后CID-Time数据的存放地址
	SAH	OFFSET_D
	LACK	4
	SAH	COUNT		;时间的长度
	CALL	TIME_DECODE
;---TelNum-length
	LACK	1		;原始CID-length数据的存放地址
	SAH	OFFSET_S
	LACK	5		;解码后CID-length数据的存放地址
	SAH	OFFSET_D
	CALL	GETBYTE_DAT
	SBHK	8		;去掉时间长度8,余下的就是号码长度
	SAH	COUNT		;号码长度
	CALL	STORBYTE_DAT
;---Decode TelNum
	LACK	10		;原始CID-Num数据的存放地址(11...)
	SAH	OFFSET_S
	LACL	6		;解码后CID-Num数据的存放地址(6..37)
	SAH	OFFSET_D
	CALL	MOVE_FSKCIDDAT
;---姓名长度
	LACK	38	;解码后CIDName-length数据的存放地址
	SAH	OFFSET_D
	LACK	0
	CALL	STORBYTE_DAT
	
	BS	B1,FSK_DECODE_END
FSK_DECODE0X80:	
FSK_DECODE0X81:
FSK_DECODE0X82:	
	
;---解时间
	LACK	4		;原始CID-Time数据的存放地址
	SAH	OFFSET_S
	LACK	1		;(1,2,3,4)解码后CID-Time数据的存放地址
	SAH	OFFSET_D
	LACK	4
	SAH	COUNT		;时间的长度
	CALL	TIME_DECODE

;---号码长度
	LACK	13		;原始CIDNum-length数据的存放地址
	SAH	OFFSET_S
	LACK	5		;解码后CIDNum-length数据的存放地址
	SAH	OFFSET_D
	CALL	GETBYTE_DAT
	SAH	COUNT		;号码长度
	CALL	STORBYTE_DAT
;---移号码
	LACK	14		;原始CID-Num数据的存放地址(14...)
	SAH	OFFSET_S
	LACK	6		;解码后CID-Num数据的存放地址(6..37)
	SAH	OFFSET_D
	CALL	MOVE_FSKCIDDAT
;---姓名长度
	LACK	13		;原始CIDNum-length数据的存放地址
	SAH	OFFSET_S
	LACK	38		;解码后CIDName-length数据的存放地址
	SAH	OFFSET_D
	CALL	GETBYTE_DAT	;取号码长度
	ADHK	13+2	;地址补偿后得原始CIDName-length数据的存放地址
	SAH	OFFSET_S	;存放姓名长度的偏移
	CALL	GETBYTE_DAT
	SAH	COUNT		;姓名长度
	CALL	STORBYTE_DAT	
;---移姓名
	LACK	13		;原始CIDName-length数据的存放地址
	SAH	OFFSET_S
	LACK	38+1		;解码后CIDName数据的起始存放地址
	SAH	OFFSET_D
	CALL	GETBYTE_DAT
	ADHK	13+2+1	;地址补偿后得原始CIDName数据的起始存放地址
	SAH	OFFSET_S	;存放姓名起始地址的偏移
	CALL	MOVE_FSKCIDDAT

FSK_DECODE_END:	
	RET
;-------------------------------------------------------------------------------
DTMF_DECODE:
	LACL	CidBuffer	;原始CID数据的存放地址
	SAH	ADDR_S
	LACL	CidData		;解码后CID数据的存放地址
	SAH	ADDR_D

	LACK	0
	SAH	OFFSET_S
	SAH	OFFSET_D
	LACL	0X80
	CALL	STORBYTE_DAT

	CALL	GETBYTE_DAT
	SBHK	0X0A
	BS	ACZ,DTMF_DECODE0X0A	;"A"
	SBHK	0X01
	BS	ACZ,DTMF_DECODE0X0B	;"B"
	SBHK	0X02
	BS	ACZ,DTMF_DECODE0X0D	;"D"
	
	BS	B1,FSK_DECODE_END
DTMF_DECODE0X0A:	;正常解码
;---Decode TelNum
	LACK	1
	SAH	OFFSET_S
	LACK	6
	SAH	OFFSET_D
	CALL	MOVE_DTMFCIDDAT
	SAH	SYSTMP1		;保存返回值(计算得到的数据长度)
;---号码长度	
	LACK	5
	SAH	OFFSET_D
	LAC	SYSTMP1
	CALL	STORBYTE_DAT
		
	LACK	38	;解码后CIDName-length数据的存放地址
	SAH	OFFSET_D
	LACK	0
	CALL	STORBYTE_DAT	
;---时间
	CALL	INIT_DAM_FUNC

	LACK	1
	SAH	OFFSET_D
	CALL	CMONTH_GET
	CALL	STORBYTE_DAT
	
	LACK	2
	SAH	OFFSET_D
	CALL	CDAY_GET
	CALL	STORBYTE_DAT
	
	LACK	3
	SAH	OFFSET_D
	CALL	CHOUR_GET
	CALL	STORBYTE_DAT
	
	LACK	4
	SAH	OFFSET_D
	CALL	CMIN_GET
	CALL	STORBYTE_DAT
	
	;CALL	LINE_START
	
	LACK	3
	
	RET
;-------------------------------------------------------------------------------		
DTMF_DECODE0X0B:
	LACK	1
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	BS	ACZ,DTMF_DECODE0X0B_Unknow	;B0(BOOC)
	SBHK	1
	BS	ACZ,DTMF_DECODE0X0B_Secret	;B1(B1OC)
DTMF_DECODE0X0B_Unknow:
	LACK	0
	RET
DTMF_DECODE0X0B_Secret:
	LACK	1
	RET
;------------------------------------------
DTMF_DECODE0X0D:

	LACK	2
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	SBHK	0X0F
	BS	ACZ,DTMF_DECODE0X0DF
	BS	B1,DTMF_DECODE0X0A
DTMF_DECODE0X0DF:	;Dx#
	LACK	1
	SAH	OFFSET_S
	CALL	GETBYTE_DAT
	SBHK	1
	BS	ACZ,DTMF_DECODE0X0B_Secret	;D1#(Secret)
	SBHK	1
	BS	ACZ,DTMF_DECODE0X0B_Intern	;D2#(international number)
	BS	B1,DTMF_DECODE0X0B_Unknow	;Dx#(Unknown number)
;---	
DTMF_DECODE0X0B_Intern:
	LACK	2
	
	RET	
DTMF_DECODE_END:	
	RET
;-------------------------------------------------------------------------------
;---将(OFFSET_S/OFFSET_S+1),(OFFSET_S+2/OFFSET_S+3),OFFSET_S+4/OFFSET_S+5),(OFFSET_S+6/OFFSET_S+7)
;---处的数据处理后存放在
;---(OFFSET_D/OFFSET_D+1/OFFSET_D+2/OFFSET_D+3)处
;-------------------------------------------------------------------------------
TIME_DECODE:
	LACK	0
	SAH	SYSTMP1
TIME_DECODE_LOOP:
;---
	CALL	GETBYTE_DAT	;Get 0,2,4,6
	ANDK	0X0F
	SFL	4
	SAH	OGM_ID
	
	LAC	OFFSET_S
	ADHK	1
	SAH	OFFSET_S
;---	
	CALL	GETBYTE_DAT	;Get 1,3,5,7
	ANDK	0X0F
	OR	OGM_ID
	SAH	OGM_ID		;Month/day/hour/minute
	
	LAC	OFFSET_S
	ADHK	1
	SAH	OFFSET_S
;---
	LAC	OGM_ID
	CALL	DGT_HEX
	SAH	OGM_ID
	CALL	STORBYTE_DAT	;Stor 1,2,3,4
	
	LAC	OGM_ID
	CALL	FSK_UPDATETIME
	
	LAC	OFFSET_D
	ADHK	1
	SAH	OFFSET_D

	LAC	SYSTMP1
	ADHK	1
	SAH	SYSTMP1		;已处理数据的个数
	SBH	COUNT		;要求处理数据的个数
	BS	SGN,TIME_DECODE_LOOP


	RET
;-------------------------------------------------------------------------------
;	将起始地址为ADDR_S长度为CidLength的数所移到ADDR_D处
;	input : ADDR_S/ADDR_D/COUNT
;	output: no
;-------------------------------------------------------------------------------
MOVE_FSKCIDDAT:
	LAC	COUNT
	SBHK	0X4F
	BS	ACZ,MOVE_FSKCIDDAT_END	;"P"
	SBHK	0X1
	BS	ACZ,MOVE_FSKCIDDAT_END	;"Q"

	LACK	0
	SAH	SYSTMP1
MOVE_FSKCIDDAT_LOOP:
	CALL	GETBYTE_DAT
	ANDK	0X7F
	CALL	STORBYTE_DAT

	LAC	OFFSET_S
	ADHK	1
	SAH	OFFSET_S
	
	LAC	OFFSET_D
	ADHK	1
	SAH	OFFSET_D

	LAC	SYSTMP1
	ADHK	1
	SAH	SYSTMP1
	SBH	COUNT
	BS	SGN,MOVE_FSKCIDDAT_LOOP	
MOVE_FSKCIDDAT_END:
	RET
;-------------------------------------------------------------------------------
;	将起始地址为ADDR_S长度为CidLength的数所移到ADDR_D处
;	input : ADDR_S/ADDR_D/COUNT
;	output: ACCH = Num-length
;-------------------------------------------------------------------------------
MOVE_DTMFCIDDAT:
	
	LACK	0
	SAH	SYSTMP1
MOVE_DTMFCIDDAT_LOOP:
	CALL	GETBYTE_DAT
	ANDK	0X000F
	SAH	SYSTMP0
	SBHK	0X0C
	BZ	SGN,MOVE_DTMFCIDDAT_END	;大于C
	;SBHK	0X3
	;BS	ACZ,MOVE_DTMFCIDDAT_END	;#
	
	LAC	SYSTMP0
	ORK	0X030		;以ASCII码保存
	CALL	STORBYTE_DAT
	
	LAC	OFFSET_S
	ADHK	1
	SAH	OFFSET_S
	
	LAC	OFFSET_D
	ADHK	1
	SAH	OFFSET_D
	
	LAC	SYSTMP1
	ADHK	1
	SAH	SYSTMP1		;有效数据的长度
	
	BS	B1,MOVE_DTMFCIDDAT_LOOP
MOVE_DTMFCIDDAT_END:
	LAC	SYSTMP1
	
	RET
;-------------------------------------------------------------------------------
FSK_UPDATETIME:
	SAH	SYSTMP0
	
	LAC	OFFSET_D
	SBHK	1
	BS	ACZ,FSK_UPDATETIME_MONTH	;The data in offset_d=1 is month
	SBHK	1
	BS	ACZ,FSK_UPDATETIME_DAY		;The data in offset_d=2 is day
	SBHK	1
	BS	ACZ,FSK_UPDATETIME_HOUR		;The data in offset_d=3 is hour
	SBHK	1
	BS	ACZ,FSK_UPDATETIME_MINUTE	;The data in offset_d=4 is minute

	RET
FSK_UPDATETIME_MONTH:
	LAC	SYSTMP0
	CALL	MON_SET

	RET
FSK_UPDATETIME_DAY:
	LAC	SYSTMP0
	CALL	DAY_SET
	
	RET
FSK_UPDATETIME_HOUR:
	LAC	SYSTMP0
	CALL	HOUR_SET
	
	RET
FSK_UPDATETIME_MINUTE:
	LAC	SYSTMP0
	CALL	MIN_SET
	
	RET
;-------------------------------------------------------------------------------
;	input : no
;	output: ACCH =  0 - no 
;			1 - ok(the length of localcode=1)
;			2 - ok(the length of localcode=2)
;			3 - ok(the length of localcode=3)
;			4 - ok(the length of localcode=4)
;算法如下:如果相同的个数为L,第L+1位是无效LC,则比较成功,否则失败
;-------------------------------------------------------------------------------
CUT_LCODE:
	LAC	LOCACODE
	XOR	LOCODE_TMP
	BS	ACZ,CUT_LCODE_4		;4位相同
	ANDL	0XFFF0
	BS	ACZ,CUT_LCODE_3		;3位相同
	ANDL	0XFF00
	BS	ACZ,CUT_LCODE_2		;2位相同
	ANDL	0XF000
	BS	ACZ,CUT_LCODE_1		;1位相同
CUT_LCODE_END:
	LACK	0
	RET
CUT_LCODE_4:
	LACK	4
	RET
CUT_LCODE_3:
	LAC	LOCACODE
	ANDK	0X0F
	SBHK	10
	BS	SGN,CUT_LCODE_END
	
	LACK	3
	
	RET
CUT_LCODE_2:
	LAC	LOCACODE
	SFR	4
	ANDK	0X0F
	SBHK	10
	BS	SGN,CUT_LCODE_END
	
	LACK	2

	RET
CUT_LCODE_1:
	LAC	LOCACODE
	SFR	8
	ANDK	0X0F
	SBHK	10
	BS	SGN,CUT_LCODE_END
	
	LACK	1

	RET
;-------------------------------------------------------------------------------
;	Function : CLR_RAM	
;	将以ADDR_D为起始地址以OFFSET_D为起始地址的空间(一个字节)清零
;	INPUT : COUNT = the length(Bytes)
;		OFFSET_D = the offset you will stor data
;		ADDR_D = the BASE you will stor data
;	output: ACCH = no
;	variable:No(SYSTMP1,SYSTMP2)
;-------------------------------------------------------------------------------
CLR_RAM:
	LAC	COUNT
	SBHK	1
	SAH	COUNT
	BS	SGN,CLR_RAM_END
	
	LACK	0
	CALL	STORBYTE_DAT
	
	LAC	OFFSET_D
	ADHK	1
	SAH	OFFSET_D
	BS	B1,CLR_RAM
CLR_RAM_END:
		
	RET
;-------------------------------------------------------------------------------
.INCLUDE	block/l_getctime.asm
.INCLUDE	block/l_setctime.asm
.INCLUDE	block/l_telcomm.asm
.INCLUDE	block/tel_wr.asm
.INCLUDE	block/tel_init.asm
;-------------------------------------------------------------------------------
.END
	