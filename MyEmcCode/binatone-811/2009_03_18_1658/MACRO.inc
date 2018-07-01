;-------------------------------------------------------------------------------
;-MACRO
PHONE_STOPDIAL		MACRO
		MOV	_RB,@0XFF
		ENDM
;---------------------------------------
PHONE_STARTDIAL		MACRO
		MOV	_RB,A
		ENDM
;-------------------------------------------------------------------------------
DAM_MIC_ENABLE		MACRO
		BS	_P9,4
		ENDM
;---------------------------------------
DAM_MIC_DISABLE		MACRO
		BC	_P9,4
		ENDM
;-------------------------------------------------------------------------------
DAM_SPK_ENABLE		MACRO
		BS	_P9,5
		ENDM
;---------------------------------------
DAM_SPK_DISABLE		MACRO
		BC	_P9,5
		ENDM
;-------------------------------------------------------------------------------
DAM_NEWLED_H	MACRO
		BS	_P9,0
		ENDM
;---------------------------------------
DAM_NEWLED_L		MACRO
		BC	_P9,0
		ENDM
;---------------------------------------
DAM_NEWLED_COM		MACRO
		MOV	A,_P9
		XOR	A,@1
		MOV	_P9,A
		ENDM
;-------------------------------------------------------------------------------
HFLED_H	MACRO
		BS	_P9,7
		ENDM
;---------------------------------------
HFLED_L	MACRO
		BC	_P9,7
		ENDM
;-------------------------------------------------------------------------------
RESET_DSP_H	MACRO
		BS	_P8,1
		ENDM
;---------------------------------------
RESET_DSP_L	MACRO
		BC	_P8,1
		ENDM
;-------------------------------------------------------------------------------
XMUTE_H	MACRO
		BS	_P8,2
		ENDM
;---------------------------------------
XMUTE_L	MACRO
		BC	_P8,2
		ENDM
;-------------------------------------------------------------------------------
MUTE_H	MACRO
		BS	_P8,3
		ENDM
;---------------------------------------
MUTE_L	MACRO
		BC	_P8,3
		ENDM
;-------------------------------------------------------------------------------
HF_HOOK_H	MACRO			;working
		BS	_P8,4
		ENDM
;---------------------------------------
HF_HOOK_L	MACRO
		BC	_P8,4
		ENDM
;---------------------------------------
HF_HOOK_COM	MACRO
		MOV	A,_P8
		XOR	A,@(1<<4)
		MOV	_P8,A
		ENDM
;-------------------------------------------------------------------------------
DP_PULSE_L	MACRO			;Pulse/FLASH
		BC	_P8,5
		ENDM
;---------------------------------------
DP_PULSE_H	MACRO
		BS	_P8,5
		ENDM
;-------------------------------------------------------------------------------
REFURBISH_ICON	MACRO

		BLOCK	0
		MOV	_RC,@LCD_CTRL
		BS	_RD,4

		ENDM
;---------------------------------------
REFURBISH_1STL	MACRO

		BLOCK	0
		MOV	_RC,@LCD_CTRL
		BS	_RD,5

		ENDM
;---------------------------------------
REFURBISH_2NDL	MACRO

		BLOCK	0
		MOV	_RC,@LCD_CTRL
		BS	_RD,6

		ENDM
;---------------------------------------
REFURBISH_1AND2L	MACRO

		BLOCK	0
		MOV	_RC,@LCD_CTRL
		BS	_RD,5
		BS	_RD,6

		ENDM
;---------------------------------------
REFURBISH_3RDL	MACRO

		BLOCK	0
		MOV	_RC,@LCD_CTRL
		BS	_RD,7

		ENDM
;---------------------------------------
REFURBISH_2AND3L	MACRO

		BLOCK	0
		MOV	_RC,@LCD_CTRL
		BS	_RD,6
		BS	_RD,7

		ENDM
;---------------------------------------
REFURBISH_1AND2AND3L	MACRO

		BLOCK	0
		MOV	_RC,@LCD_CTRL
		BS	_RD,5
		BS	_RD,6
		BS	_RD,7

		ENDM
;-------------------------------------------------------------------------------
RTC_DISP_ENABLE	MACRO
		BS	SYS_FLAG,0
		ENDM
;---------------------------------------
RTC_DISP_DISABLE	MACRO
		BC	SYS_FLAG,0
		ENDM
;-------------------------------------------------------------------------------
SET_NLEDBLK_FLAG	MACRO
		BS	SYS_FLAG,2
		ENDM
;---------------------------------------
RESET_NLEDBLK_FLAG	MACRO
		BC	SYS_FLAG,2
		ENDM
;-------------------------------------------------------------------------------
SET_NEWESTCID_FLAG	MACRO
		BS	SYS_FLAG,4
		ENDM
;---------------------------------------
RESET_NEWESTCID_FLAG	MACRO
		BC	SYS_FLAG,4
		ENDM
;-------------------------------------------------------------------------------
;SET_DIRTY_FLAG	MACRO
;		BS	SYS_FLAG,5
;		ENDM
;---------------------------------------
;RESET_DIRTY_FLAG	MACRO
;		BC	SYS_FLAG,5
;		ENDM
;-------------------------------------------------------------------------------
SET_NEWVP_FLAG		MACRO
		BS	DAM_FLAG,7
		ENDM
;---------------------------------------
RESET_NEWVP_FLAG	MACRO
		BC	DAM_FLAG,7
		ENDM
;-------------------------------------------------------------------------------
SET_VPEXIST_FLAG		MACRO
		BS	DAM_FLAG,6
		ENDM
;---------------------------------------
RESET_VPEXIST_FLAG	MACRO
		BC	DAM_FLAG,6
		ENDM
;-------------------------------------------------------------------------------
SET_FULL_FLAG		MACRO
		BS	DAM_FLAG,5
		ENDM
;---------------------------------------
RESET_FULL_FLAG	MACRO
		BC	DAM_FLAG,5
		ENDM
;-------------------------------------------------------------------------------
SET_NEWCID_FLAG		MACRO
		BS	DAM_FLAG,4
		ENDM
;---------------------------------------
RESET_NEWCID_FLAG	MACRO
		BC	DAM_FLAG,4
		ENDM
;-------------------------------------------------------------------------------
SEL_OGM1	MACRO
		BC	DAM_FLAG,3
		ENDM
;---------------------------------------
SEL_OGM2	MACRO
		BS	DAM_FLAG,3
		ENDM
;---------------------------------------
SELOGM_COM	MACRO
		MOV	A,DAM_FLAG
		XOR	A,@(1<<3)
		MOV	DAM_FLAG,A
		ENDM
;-------------------------------------------------------------------------------
DAM_ON		MACRO
		BC	DAM_FLAG,2
		ENDM
;---------------------------------------
DAM_OFF		MACRO
		BS	DAM_FLAG,2
		ENDM
;---------------------------------------
DAM_COM		MACRO
		MOV	A,DAM_FLAG
		XOR	A,@(1<<2)
		MOV	DAM_FLAG,A
		ENDM
;-------------------------------------------------------------------------------

