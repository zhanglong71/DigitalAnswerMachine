
;-----------------------------// Constant key defines,全部以C开头。--------------------------------
;---SYS MSG CONST------------------
	CMSG_KEY1S	.EQU	0X01	;messages for key released(松开按键UP)
	CMSG_KEY2S	.EQU	0X02
	CMSG_KEY3S	.EQU	0X03
	CMSG_KEY4S	.EQU	0X04
	CMSG_KEY5S	.EQU	0X05
	CMSG_KEY6S	.EQU	0X06
	CMSG_KEY7S	.EQU	0X07
	CMSG_KEY8S	.EQU	0X08
	CMSG_KEY9S	.EQU	0X09
	CMSG_KEYAS	.EQU	0X0A
	CMSG_KEYBS	.EQU	0X0B
	CMSG_KEYCS	.EQU	0X0C
;---	
	CMSG_KEY1L	.EQU	0X11	;messages for key beening pressed 2s
	CMSG_KEY2L	.EQU	0X12
	CMSG_KEY3L	.EQU	0X13
	CMSG_KEY4L	.EQU	0X14
	CMSG_KEY5L	.EQU	0X15
	CMSG_KEY6L	.EQU	0X16
	CMSG_KEY7L	.EQU	0X17
	CMSG_KEY8L	.EQU	0X18
	CMSG_KEY9L	.EQU	0X19
	CMSG_KEYAL	.EQU	0X1A
	CMSG_KEYBL	.EQU	0X1B
	CMSG_KEYCL	.EQU	0X1C
;---	
	CMSG_KEY1P	.EQU	0X21	;messages for key beening pressed every 512ms
	CMSG_KEY2P	.EQU	0X22
	CMSG_KEY3P	.EQU	0X23
	CMSG_KEY4P	.EQU	0X24
	CMSG_KEY5P	.EQU	0X25
	CMSG_KEY6P	.EQU	0X26
	CMSG_KEY7P	.EQU	0X27
	CMSG_KEY8P	.EQU	0X28
	CMSG_KEY9P	.EQU	0X29
	CMSG_KEYAP	.EQU	0X2A
	CMSG_KEYBP	.EQU	0X2B
	CMSG_KEYCP	.EQU	0X2C
	
	CMSG_KEY1D	.EQU	0X31	;messages for key beening pressed DOWN(48ms later)
	CMSG_KEY2D	.EQU	0X32
	CMSG_KEY3D	.EQU	0X33
	CMSG_KEY4D	.EQU	0X34
	CMSG_KEY5D	.EQU	0X35
	CMSG_KEY6D	.EQU	0X36
	CMSG_KEY7D	.EQU	0X37
	CMSG_KEY8D	.EQU	0X38
	CMSG_KEY9D	.EQU	0X39
	CMSG_KEYAD	.EQU	0X3A
	CMSG_KEYBD	.EQU	0X3B
	CMSG_KEYCD	.EQU	0X3C
;---messages for function	
	
	CMSG_INIT	.EQU	0X81
	
	CMSG_TIFAT	.EQU	0X83	;向MCU发送时间制式
	CMSG_CTONE	.EQU	0X84
	CMSG_BTONE	.EQU	0X85
	CREV_DTMF	.EQU	0X86
	CMSG_VOX	.EQU	0X87

	CSEG_STOP	.EQU	0X89
	CSEG_PAUSE	.EQU	0X8A

;	CTWAY_REC	.EQU	0X8C
	CMSG_VOLA	.EQU	0X8D
	CMSG_VOLS	.EQU	0X8E
;---	
	CMSG_TMR	.EQU	0X90	;MSG OF BASE TIME
	CSEG_END	.EQU	0X91	;播放等到一段尾
	CVP_STOP	.EQU	0X92	;播放完毕；
	;CCOM_INIT	.EQU	0X93	;硬件初始化命令
;-------
;-------上传命令
	
	CREC_FULL	.EQU	0XB1	;FLASH FULL；
	CLINE_CONNT	.EQU	0XB2	;有电话线插入或拔出
	CBUF_EMPTY	.EQU	0XB8	;发送缓冲区空
	
;-------
	;CMIC_REC	.EQU	0XD1
	;CREC_OGM	.EQU	0XD2	;录音0GM，由ID判断1，2
	;CREC_VP		.EQU	0XD3	;录音
	;CREC_ICM	.EQU	0XD4	;来电录音
	;CRUN_DEL	.EQU	0XD5	;删录音
	;CDEL_OGM	.EQU	0XD6	;删OGMX
	;CDEL_REC	.EQU	0XD7	;删录音
	;CDEL_ICM	.EQU	0XD8	;删留言
	
	;CPLAY_ID	.EQU	0XD9	;播放
	;CPLAY_NEW	.EQU	0XDA	;播留言
	;CPLAY_TOTAL	.EQU	0XDB
	;CPLAY_OGM	.EQU	0XDC	;播OGMX，由ID判断1，2
;---外部事件消息(按键之外的)	
	CMSG_SER	.EQU	0XE7	;收到命令
	CMSG_CPC	.EQU	0XE8
	CFIRST_RI	.EQU	0XE9	;第一次铃声
	CRING_OK	.EQU	0XEA
	CRING_IN	.EQU	0XEB
	CRING_FAIL	.EQU	0XEC
;-------------------------------------------------------------------------------
CTAG_ICM	.EQU		120
CTAG_MEMO	.EQU		121

.END
