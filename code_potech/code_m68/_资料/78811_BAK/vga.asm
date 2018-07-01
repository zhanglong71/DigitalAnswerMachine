
ORG	0x0c00
VGA:

VgaStamp1:
	MOV	ax,A
	MOV	_RC,@(128+1)
	JMP	VgaStamp
VgaStamp2:
	MOV	ax,A
	MOV	_RC,@(128+2)
	JMP	VgaStamp
VgaStamp3:
	MOV	ax,A
	MOV	_RC,@(128+3)
VgaStamp:
	BLOCK	0
	MOV	_RD,ax
	RET

VgaNum1:
	MOV	ax,A
	MOV	_RC,@(128+48)
	MOV	cnt,@(10)
	JMP	VgaLcd

VgaNum2:
	MOV	ax,A
	MOV	_RC,@(128+60)
	MOV	cnt,@(32)
	JMP	VgaLcd

VgaChar:
	MOV	ax,A
	MOV	_RC,@(128+94)
	MOV	cnt,@(32)
	JMP	VgaLcd

VgaLcd:
	BLOCK	0
	MOV	A,ax
	JPZ	VgaLcd_end
	JPNB	_RD,7,VgaLcd_begin
	INC	_RC
	SUBA	_RD,cnt
	JPC	VgaLcd_full
	INC	_RD
VgaLcd_capital:
	/*
	MOV	bx,_RD
	DEC	_RC
	
	SWAPA	_RD
	AND	A,@(0x07)
	TBL
	JMP	VgaLcd_normal
	JMP	VgaLcd_all
	JMP	VgaLcd_word
	JMP	VgaLcd_char
	JMP	VgaLcd_letter
	JMP	VgaLcd_lower
	JMP	VgaLcd_normal
	JMP	VgaLcd_normal
VgaLcd_normal:
	JMP	VgaLcd_ret
VgaLcd_all:
	JMP	VgaLcd_caps
VgaLcd_word:				; 每个单词的第一个字符大写
	MOV	exa,_RC
	CLR	exb
	SUBA	bx,@(2)
	JPNC	VgaLcd_word_1
	ADD	_RC,bx
	MOV	A,_RD
	CALL	VgaGetCharType		; 得到上一个字符的类型
	MOV	exb,A
VgaLcd_word_1:
	SUBA	exb,@(2)
	JPNC	VgaLcd_caps
	JMP	VgaLcd_ret
VgaLcd_char:				; 首字符大写
	SUBA	bx,@(1)
	JPNZ	VgaLcd_ret
	AND	_RD,@(0x8f)
	JMP	VgaLcd_caps
VgaLcd_letter:				; 首字母大写
	MOV	A,ax
	CALL	VgaGetCharType		; 得到当前字符的类型
	SUB	A,@(2)
	JPC	VgaLcd_ret
	AND	_RD,@(0x8f)
	JMP	VgaLcd_caps
VgaLcd_lower:				; 第一个小写字母大写
	MOV	A,ax
	CALL	VgaGetCharType
	SUB	A,@(6)
	JPC	VgaLcd_ret
	AND	_RD,@(0x8f)
	JMP	VgaLcd_caps
VgaLcd_caps:
	MOV	A,ax
	CALL	VgaGetCharType
	CALL	VgaLetterCaps
	SUB	ax,A
	

VgaLcd_ret:
	INC	_RC
	*/
	ADD	_RC,_RD
	MOV	_RD,ax
	RET

VgaLcd_begin:
	MOV	_RD,ax
	INC	_RC
	INC	cnt			; 清空包括计数器
	CLR	ax
	LCALL	LibClearRam
	RET
	
VgaLcd_full:
	MOV	exb,ax
	MOV	bx,_RC
	MOV	_RC,@(0x30)
	MOV	_RD,bx
	INC	_RC
	MOV	_RD,cnt
	INC	bx
	ADDA	bx,@(1)
	MOV	ax,A
	LCALL	LibCopyRam
	MOV	_RC,@(0x31)
	MOV	cnt,_RD
	DEC	_RC
	MOV	_RC,_RD
	MOV	ax,exb
	JMP	VgaLcd_capital
	
	
	MOV	exb,ax
	ADDA	_RC,@(1)
	MOV	bx,A
	ADD	A,@(1)
	MOV	ax,A
	DEC	cnt
	MOV	_RC,@(0x30)
	ADDA	bx,cnt
	MOV	_RD,A
	LCALL	LibCopyRam
	MOV	_RC,@(0x30)
	MOV	_RC,_RD
	MOV	_RD,exb
	
	RET
	
VgaLcd_end:
	BC	_RD,7			; 复位控制器的起始位
	RET
/*
; input: acc
VgaGetCharType:
	ADD	A,@(0)
	JPZ	VgaGetCharType_null
	ADD	A,@(256-255)
	JPC	VgaGetCharType_lower3
	ADD	A,@(255-248)
	JPC	VgaGetCharType_lower4
	ADD	A,@(248-247)
	JPC	VgaGetCharType_other
	ADD	A,@(247-224)
	JPC	VgaGetCharType_lower4
	ADD	A,@(224-223)
	JPC	VgaGetCharType_other
	ADD	A,@(223-216)
	JPC	VgaGetCharType_upper4
	ADD	A,@(216-215)
	JPC	VgaGetCharType_other
	ADD	A,@(215-192)
	JPC	VgaGetCharType_upper4
	ADD	A,@(192-160)
	JPC	VgaGetCharType_other
	ADD	A,@(160-159)
	JPC	VgaGetCharType_upper3
	ADD	A,@(159-158)
	JPC	VgaGetCharType_lower2
	ADD	A,@(158-157)
	JPC	VgaGetCharType_other
	ADD	A,@(157-156)
	JPC	VgaGetCharType_lower2
	ADD	A,@(156-155)
	JPC	VgaGetCharType_other
	ADD	A,@(155-154)
	JPC	VgaGetCharType_lower2
	ADD	A,@(154-143)
	JPC	VgaGetCharType_other
	ADD	A,@(143-142)
	JPC	VgaGetCharType_upper2
	ADD	A,@(142-141)
	JPC	VgaGetCharType_other
	ADD	A,@(141-140)
	JPC	VgaGetCharType_upper2
	ADD	A,@(140-139)
	JPC	VgaGetCharType_other
	ADD	A,@(139-138)
	JPC	VgaGetCharType_upper2
	ADD	A,@(138-123)
	JPC	VgaGetCharType_other
	ADD	A,@(123-97)
	JPC	VgaGetCharType_lower1
	ADD	A,@(97-91)
	JPC	VgaGetCharType_other
	ADD	A,@(91-65)
	JPC	VgaGetCharType_upper1
	ADD	A,@(65-33)
	JPC	VgaGetCharType_other
	ADD	A,@(33-32)
	JPC	VgaGetCharType_blank
	JMP	VgaGetCharType_other
VgaGetCharType_null:
	RETL	@(0)
VgaGetCharType_blank:
	RETL	@(1)
VgaGetCharType_other:
	RETL	@(2)
VgaGetCharType_upper1:
	RETL	@(3)
VgaGetCharType_upper2:
	RETL	@(4)
VgaGetCharType_upper3:
	RETL	@(5)
VgaGetCharType_upper4:
	RETL	@(6)
VgaGetCharType_lower1:
	RETL	@(7)
VgaGetCharType_lower2:
	RETL	@(8)
VgaGetCharType_lower3:
	RETL	@(9)
VgaGetCharType_lower4:
	RETL	@(10)

VgaLetterCaps:
	TBL
	RETL	@(0)
	RETL	@(0)
	RETL	@(0)
	RETL	@(0)
	RETL	@(0)
	RETL	@(0)
	RETL	@(0)
	RETL	@(97-65)
	RETL	@(154-138)
	RETL	@(255-159)
	RETL	@(224-192)
*/

VgaDrawStamp:
	BS	sys_flag,STAMP
	RETL	@(0)
VgaDrawNum1:
	MOV	A,@(1)
	JMP	VgaDraw
VgaDrawNum2:
	MOV	A,@(2)
	JMP	VgaDraw
VgaDrawChar:
	MOV	A,@(3)
	JMP	VgaDraw

VgaDraw:
	LCALL	LcdDraw			; 已经指定 block 0
	MOV	A,ax
	TBL
	JMP	VgaDraw_stamp
	JMP	VgaDraw_num1
	JMP	VgaDraw_num2
	JMP	VgaDraw_char
VgaDraw_stamp:
	RET
VgaDraw_num1:
	MOV	ax,@(128+50)
	MOV	bx,@(128+4)
	MOV	exb,@(10)
	MOV	_RC,@(128+48)
	JMP	VgaDraw_ascii

VgaDraw_num2:
	MOV	ax,@(128+62)
	MOV	bx,@(128+14)
	MOV	exb,@(16)
	MOV	_RC,@(128+60)
	JMP	VgaDraw_ascii

VgaDraw_char:
	MOV	ax,@(128+96)
	MOV	bx,@(128+30)
	MOV	exb,@(16)
	MOV	_RC,@(128+94)
	JMP	VgaDraw_ascii


VgaDraw_ascii:
	MOV	exa,_RD
	INC	_RC
	INC	_RC
	LCALL	LibGetValidLength32
	JPZ	VgaDraw_ret
	MOV	cnt,A
	ANDA	exa,@(0x03)
	TBL
	JMP	VgaDraw_ascii_normal
	JMP	VgaDraw_ascii_left
	JMP	VgaDraw_ascii_right
	JMP	VgaDraw_ascii_center
VgaDraw_ascii_normal:
VgaDraw_ascii_left:
	SUBA	cnt,exb
	JPNC	VgaDraw_shift
	MOV	cnt,exb
	JMP	VgaDraw_shift
VgaDraw_ascii_right:
	SUBA	cnt,exb
	JPNC	VgaDraw_ascii_right_1
	ADD	ax,A
	MOV	cnt,exb
	JMP	VgaDraw_shift
VgaDraw_ascii_right_1:
	XOR	A,@(0xff)
	ADD	A,@(1)
	ADD	bx,A
	JMP	VgaDraw_shift
VgaDraw_ascii_center:
	SUBA	cnt,exb
	JPNC	VgaDraw_ascii_center_1
	JMP	VgaDraw_ascii_right
VgaDraw_ascii_center_1:
	XOR	A,@(0xff)
	ADD	A,@(1)
	MOV	exa,A
	RRCA	exa
	ADD	bx,A
	JMP	VgaDraw_shift

VgaDraw_shift:
	LCALL	LibCopyRam
	
	MOV	_RC,@(128+8)
	SUBA	_RD,@(49)
	JPZ	VgaDraw_ret
	MOV	_RD,@(32)
VgaDraw_ret:
	RET

VgaBlankStamp:
	MOV	A,@(0)
	JMP	VgaBlank
VgaBlankNum1:
	MOV	A,@(1)
	JMP	VgaBlank
VgaBlankNum2:
	MOV	A,@(2)
	JMP	VgaBlank
VgaBlankChar:
	MOV	A,@(3)
	JMP	VgaBlank

VgaBlank:
	LCALL	LcdDraw
	MOV	A,ax
	TBL
	JMP	VgaBlank_stamp
	JMP	VgaBlank_num1
	JMP	VgaBlank_num2
	JMP	VgaBlank_char
VgaBlank_stamp:
	MOV	_RC,@(128+1)
	MOV	cnt,@(3)
	JMP	VgaBlank_ret
VgaBlank_num1:
	MOV	_RC,@(128+4)
	MOV	cnt,@(10)
	JMP	VgaBlank_ret
VgaBlank_num2:
	MOV	_RC,@(128+14)
	MOV	cnt,@(16)
	JMP	VgaBlank_ret
VgaBlank_char:
	MOV	_RC,@(128+30)
	MOV	cnt,@(16)
VgaBlank_ret:
	CLR	ax
	LCALL	LibClearRam
	RET

; input:	acc
;		.7 =1 flash
;		.6~.4	flash bit
;		.3~.0	flash address

VgaFlash:
	MOV	ax,A
	SWAPA	ax
	AND	A,@(0x07)
	LCALL	TabSetBit
	MOV	exa,A
	BLOCK	0
	MOV	_RC,@(0x70+1)
	ANDA	ax,@(0x0f)
	ADD	_RC,A
	
	JPNB	ax,7,VgaFlash_off
VgaFlash_on:
	OR	_RD,exa
	JMP	VgaFlash_chk
VgaFlash_off:
	XORA	exa,@(0xff)
	AND	_RD,A
VgaFlash_chk:
	CLR	ax
	MOV	_RC,@(0x71)
	MOV	A,_RD
	JPNZ	VgaFlash_chk_stamp
	INC	_RC
	MOV	A,_RD
	JPNZ	VgaFlash_chk_stamp
	INC	_RC
	MOV	A,_RD
	JPZ	VgaFlash_chk_1
VgaFlash_chk_stamp:
	BS	ax,7
VgaFlash_chk_1:
	MOV	_RC,@(0x74)
	MOV	A,_RD
	JPNZ	VgaFlash_chk_num1
	INC	_RC
	MOV	A,_RD
	JPZ	VgaFlash_chk_2
VgaFlash_chk_num1:
	BS	ax,6
VgaFlash_chk_2:
	MOV	_RC,@(0x76)
	MOV	A,_RD
	JPNZ	VgaFlash_chk_num2
	INC	_RC
	MOV	A,_RD
	JPZ	VgaFlash_chk_3
VgaFlash_chk_num2:
	BS	ax,5
VgaFlash_chk_3:
	MOV	_RC,@(0x78)
	MOV	A,_RD
	JPNZ	VgaFlash_chk_char
	INC	_RC
	MOV	A,_RD
	JPZ	VgaFlash_chk_4
VgaFlash_chk_char:
	BS	ax,4
VgaFlash_chk_4:
	MOV	_RC,@(0x70)
	MOV	_RD,ax
	
	RET
	
; 字符串输入
; input:	acch -- string ID
; output:	none
; note:
; 	字符串输入，只限于第三行
VGASTR	MACRO	#STR_ADDR
	MOV	A,_RD
	LCALL	STR_ADDR
	JMP	VgaString_loop1
	ENDM

VgaString:
	MOV	ax,A
	BLOCK	0
	MOV	_RC,@(0x7a)
	MOV	_RD,ax
	MOV	_RC,@(0x7b)
	CLR	_RD

VgaString_loop:
	MOV	_RC,@(0x7a)
	MOV	ax,_RD
	INC	_RC
	MOV	A,ax
	TBL
	JMP	VgaString_000
	JMP	VgaString_001
	JMP	VgaString_002
	JMP	VgaString_003
	JMP	VgaString_004
	JMP	VgaString_005
	JMP	VgaString_006
	JMP	VgaString_007
	JMP	VgaString_008
	JMP	VgaString_009
	JMP	VgaString_010
	JMP	VgaString_011
	JMP	VgaString_012
	JMP	VgaString_013
	JMP	VgaString_014
	JMP	VgaString_015
	JMP	VgaString_016
	JMP	VgaString_017
	JMP	VgaString_018
	JMP	VgaString_019
	JMP	VgaString_020
	JMP	VgaString_021
	JMP	VgaString_022
	JMP	VgaString_023
	JMP	VgaString_024
	JMP	VgaString_025
	JMP	VgaString_026
	JMP	VgaString_027
	JMP	VgaString_028
	JMP	VgaString_029
	JMP	VgaString_030
	JMP	VgaString_031
	JMP	VgaString_032
	JMP	VgaString_033
	JMP	VgaString_034
	JMP	VgaString_035
	JMP	VgaString_036
	JMP	VgaString_037
	JMP	VgaString_038
	JMP	VgaString_039
	JMP	VgaString_040
	JMP	VgaString_041
	JMP	VgaString_042
	JMP	VgaString_043
	JMP	VgaString_044
	JMP	VgaString_045
	JMP	VgaString_046
	JMP	VgaString_047
	JMP	VgaString_048
	JMP	VgaString_049
	JMP	VgaString_050
	JMP	VgaString_051
	JMP	VgaString_052
	JMP	VgaString_053
	JMP	VgaString_054
	JMP	VgaString_055
	JMP	VgaString_056
	JMP	VgaString_057
	JMP	VgaString_058
	JMP	VgaString_059
	JMP	VgaString_060
	JMP	VgaString_061
	JMP	VgaString_062
	JMP	VgaString_063
	JMP	VgaString_064
	JMP	VgaString_065
	JMP	VgaString_066
	JMP	VgaString_067
	JMP	VgaString_068
	JMP	VgaString_069
	JMP	VgaString_070
	JMP	VgaString_071
	JMP	VgaString_072
	JMP	VgaString_073
	JMP	VgaString_074
	JMP	VgaString_075
	JMP	VgaString_076
	JMP	VgaString_077
	JMP	VgaString_078
	JMP	VgaString_079
	JMP	VgaString_080
	JMP	VgaString_081
	JMP	VgaString_082
	JMP	VgaString_083
	JMP	VgaString_084
	JMP	VgaString_085
	JMP	VgaString_086
	JMP	VgaString_087
	JMP	VgaString_088
VgaString_000:
	VGASTR	#(TabString_NoContent)
VgaString_001:
	VGASTR	#(TabString_CallList)
VgaString_002:
	VGASTR	#(TabString_PhoneBook)
VgaString_003:
	VGASTR	#(TabString_PleaseInput)
VgaString_004:
	VGASTR	#(TabString_null)
VgaString_005:
	VGASTR	#(TabString_SystemSetting)
VgaString_006:
	VGASTR	#(TabString_DAM)
VgaString_007:
	VGASTR	#(TabString_TwoWay)
VgaString_008:
	VGASTR	#(TabString_HighQuality)
VgaString_009:
	VGASTR	#(TabString_LowQuality)
VgaString_010:
	VGASTR	#(TabString_Delete)
VgaString_011:
	VGASTR	#(TabString_BrowsePhonebook)
VgaString_012:
	VGASTR	#(TabString_InputNumber)
VgaString_013:
	VGASTR	#(TabString_InputName)
VgaString_014:
	VGASTR	#(TabString_EditPhonebook)
VgaString_015:
	VGASTR	#(TabString_Deleteall)
VgaString_016:
	VGASTR	#(TabString_Input)
VgaString_017:
	VGASTR	#(TabString_Again)
VgaString_018:
	VGASTR	#(TabString_ClockSetting)
VgaString_019:
	VGASTR	#(TabString_PhoneSetting)
VgaString_020:
	VGASTR	#(TabString_RestoreDefault)
VgaString_021:
	VGASTR	#(TabString_Play)
VgaString_022:
	VGASTR	#(TabString_Record)
VgaString_023:
	VGASTR	#(TabString_Ringmelody)
VgaString_024:
	VGASTR	#(TabString_Ringvolume)
VgaString_025:
	VGASTR	#(TabString_Areacode)
VgaString_026:
	VGASTR	#(TabString_Flashtime)
VgaString_027:
	VGASTR	#(TabString_Pausetime)
VgaString_028:
	VGASTR	#(TabString_LCDcontrast)
VgaString_029:
	VGASTR	#(TabString_HFDialing)
VgaString_030:
	VGASTR	#(TabString_Memorecord)
VgaString_031:
	VGASTR	#(TabString_OGM1record)
VgaString_032:
	VGASTR	#(TabString_OGM2record)
VgaString_033:
	VGASTR	#(TabString_PreHFdial)
VgaString_034:
	VGASTR	#(TabString_MUTE)
VgaString_035:
	VGASTR	#(TabString_BLANK)
VgaString_036:
	VGASTR	#(TabString_Jingle)
VgaString_037:
	VGASTR	#(TabString_BabyElephant)
VgaString_038:
	VGASTR	#(TabString_Bonanza)
VgaString_039:
	VGASTR	#(TabString_Choopeta)
VgaString_040:
	VGASTR	#(TabString_ForElise)
VgaString_041:
	VGASTR	#(TabString_MarcheTurque)
VgaString_042:
	VGASTR	#(TabString_ALittleNight)
VgaString_043:
	VGASTR	#(TabString_SmokeOnWater)
VgaString_044:
	VGASTR	#(TabString_TheEntertainer)
VgaString_045:
	VGASTR	#(TabString_FinalCountdown)
VgaString_046:
	VGASTR	#(TabString_TwinPeaks)
VgaString_047:
	VGASTR	#(TabString_ZorbaLeGrec)
VgaString_048:
	VGASTR	#(TabString_OFF)
VgaString_049:
	VGASTR	#(TabString_NoMessage)
VgaString_050:
	VGASTR	#(TabString_Pause)
VgaString_051:
	VGASTR	#(TabString_OGM)
VgaString_052:
	VGASTR	#(TabString_Memo)
VgaString_053:
	VGASTR	#(TabString_SelectRingTone)
VgaString_054:
	VGASTR	#(TabString_DateSetting)
VgaString_055:
	VGASTR	#(TabString_DAMSetting)
VgaString_056:
	VGASTR	#(TabString_RecorderON)
VgaString_057:
	VGASTR	#(TabString_RecorderOFF)
VgaString_058:
	VGASTR	#(TabString_Setringdelay)
VgaString_059:
	VGASTR	#(TabString_Setremotecode)
VgaString_060:
	VGASTR	#(TabString_Setrecordtime)
VgaString_061:
	VGASTR	#(TabString_SetOGM)
VgaString_062:
	VGASTR	#(TabString_Sun)
VgaString_063:
	VGASTR	#(TabString_Mon)
VgaString_064:
	VGASTR	#(TabString_Tue)
VgaString_065:
	VGASTR	#(TabString_Wed)
VgaString_066:
	VGASTR	#(TabString_Thu)
VgaString_067:
	VGASTR	#(TabString_Fri)
VgaString_068:
	VGASTR	#(TabString_Sat)
VgaString_069:
	VGASTR	#(TabString_memoryset)
VgaString_070:
	VGASTR	#(TabString_Successful)
VgaString_071:
	VGASTR	#(TabString_NewCall)
VgaString_072:
	VGASTR	#(TabString_ICM)
VgaString_073:
	VGASTR	#(TabString_Remote)
VgaString_074:
	VGASTR	#(TabString_Answered)
VgaString_075:
	VGASTR	#(TabString_RingTimes)
VgaString_076:
	VGASTR	#(TabString_ToPhonebook)
VgaString_077:
	VGASTR	#(TabString_Total)
VgaString_078:
	VGASTR	#(TabString_New)
VgaString_079:
	VGASTR	#(TabString_EndOfList)
VgaString_080:
	VGASTR	#(TabString_Private)
VgaString_081:
	VGASTR	#(TabString_WrongMessage)
VgaString_082:
	VGASTR	#(TabString_Unavallable)
VgaString_083:
	VGASTR	#(TabString_null)
VgaString_084:
	VGASTR	#(TabString_null)
VgaString_085:
	VGASTR	#(TabString_null)
VgaString_086:
	VGASTR	#(TabString_null)
VgaString_087:
	VGASTR	#(TabString_null)
VgaString_088:
	VGASTR	#(TabString_null)

VgaString_loop1:
	MOV	ax,A
	INC	_RD
	MOV	A,ax
	JPZ	VgaString_ret
	CALL	VgaChar
	JMP	VgaString_loop
VgaString_ret:
	RET
                             
                             
                             
                             
                             
                             
                             
                             
                             
                             