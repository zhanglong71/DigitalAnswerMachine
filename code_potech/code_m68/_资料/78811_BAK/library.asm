
ORG	0x0400

/*************************************************
LibPushStack
input:	acc	-- Ҫѹջ������
output:	acc	-- ѹջ������
˵����	���ѹջ������ block 9(���һ��block)����
*************************************************/
LibPushProgram:
	BS	sys_flag,PROGRAMINIT
	CLR	program
LibPushStack:
	CALL	LibStoreStack
	
	INC	_RD
	MOV	_RC,_RD
	MOV	_RD,int_acc
	
	CALL	LibResumeStack
	RET

/*************************************************
LibPopStack
input:	none	-- ��ջ1��
output:	acc	-- ��ջ��ֵ
˵����	�����ջ������ block 9(���һ��block)����
*************************************************/
LibPopProgram:
	BS	sys_flag,PROGRAMREIN
	CLR	program
LibPopStack:
	CALL	LibStoreStack
	
	CLR	int_acc
	MOV	A,_RD
	JPZ	LibPopStack_1
	MOV	_RC,A
	MOV	int_acc,_RD
	CLR	_RC
	DEC	_RD
LibPopStack_1:
	CALL	LibResumeStack
	RET

/*************************************************
LibGetStack
input:	acc	-- Ҫ��ȡ�Ķ�ջλ�� (�����ջ����0Ϊջ��)
output:	acc	-- ջ����
˵����	���ջֵ������ block 9(���һ��block)����
*************************************************/
LibGetStack:
	CALL	LibStoreStack
	
	SUBA	_RD,int_acc
	MOV	_RC,A
	MOV	int_acc,_RD
	
	CALL	LibResumeStack
	RET

LibClearStack:
	CALL	LibStoreStack
	CLR	_RD
	CALL	LibResumeStack
	RET
/*************************************************
LibStoreStack LibResumeStack
˵����	ר��LibPushStack��LibPopStack��LibGetStack����
*************************************************/
LibStoreStack:
	DISI
	MOV	int_acc,A
	MOV	int_status,_RC
	IOR	_IOCA
	AND	A,@(0x1e)
	MOV	int_rsr,A
	BLOCK	9
	CLR	_RC
	RET
LibResumeStack:
	IOR	_IOCA
	AND	A,@(0xe1)
	OR	A,int_rsr
	IOW	_IOCA
	MOV	_RC,int_status
	MOV	A,int_acc
	RETI


/*************************************************
LibMathHexToBcd
input:	ax
output:	ax,exa
˵����	ʮ������תʮ���ƣ�Ӱ�죺ax,exa,cnt,bx,exb
*************************************************/
LibMathHexToBcd:
	CLR	bx
	CLR	exa
	MOV	cnt,@(8)

LibMathHexToBcd_loop:
	ADDA	bx,@(0x03)
	MOV	exb,A
	JPNB	exb,3,$+2
	MOV	bx,A
	
	ADDA	bx,@(0x30)
	MOV	exb,A
	JPNB	exb,7,$+2
	MOV	bx,A
	
	CLRC
	RLC	ax
	RLC	bx
	RLC	exa
	
	DJZ	cnt
	JMP	LibMathHexToBcd_loop
	MOV	ax,bx
	RET

/*************************************************
LibMathBcdToHex
input:	ax
output:	ax,exa
˵����	ʮ����תʮ�����ƣ�Ӱ�죺ax,exa,cnt,bx,exb
*************************************************/
LibMathBcdToHex:
	CLR	bx
	MOV	cnt,@(8)

LibMathBcdToHex_loop:
	CLRC
	RRC	ax
	RRC	bx
	
	JPNB	ax,3,$+3
	SUB	ax,@(0x03)
	JPNB	ax,7,$+3
	SUB	ax,@(0x30)
	
	DJZ	cnt
	JMP	LibMathBcdToHex_loop
	MOV	ax,bx
	RET

/*************************************************
LibMathHexMul
input:	ax,exa
output:	ax,exa
˵����	ʮ�����Ƴ˷���Ӱ�죺ax,exa,cnt,bx,exb
*************************************************/
LibMathHexMul:
	CLR	bx
	CLR	exb
	MOV	cnt,@(8)
LibMathHexMul_loop:
	RLC	bx
	RLC	exb
	RLC	exa
	JPNC	$+6
	ADD	bx,ax
	JPNC	$+2
	INC	exb
	DJZ	cnt
	JMP	LibMathHexMul_loop
	MOV	ax,bx
	MOV	exa,exb
	RET
	
	RET



/*************************************************
LibStoreCursor	�ı䲢������
*************************************************/

LibStoreCursor:
	;OR	A,@(0x80)
	MOV	ax,A
	MOV	exa,cursor
	MOV	cursor,ax
	MOV	tmr_cursor,@(600/4)
	
	SWAPA	exa
	AND	A,@(0x03)
	JPZ	LibStoreCursor_ret
	LJMP	LcdDraw
LibStoreCursor_ret:
	RET


/*************************************************
LibLcdContrast	�ı�LCD�Աȶ�
*************************************************/
LibLcdContrast:
IF	OTP == 1
	ADD	A,@(256-1)
ELSE
	ADD	A,@(256-2)
ENDIF
	MOV	ax,A
	RLC	ax
	RLC	ax
	AND	ax,@(0x1c)
	DISI
	IOR	_IOCE
	AND	A,@(0xe3)
	OR	A,ax
	IOW	_IOCE
	RETI


LibInitDialType:
	BLOCK	3
	CLR	_RC
	JPNB	sys_flag,DIALTYPE,$+2
	BS	_RD,5
	RET

/*************************************************
LibStoreDialNumber	�����������
input:	acch	-- dial number(ASCII)
output:	acch	-- 0	error
		   !0	ok
affect: ax, block 3, _RC
note:
	����������룬���������ASCIIֵ����������ֵУ�顣
	���ȼ�黺�����Ƿ������������������ֵ��������0��
	������ֵ���뵱ǰ���Ŵ�ָ��ָ���λ�ã�����ָ��+1��
*************************************************/

LibStoreDialNumber:
	MOV	ax,A
	MOV	A,ax
	JPZ	LibStoreDialNumber_ret
	BLOCK	3
	
	CLR	_RC
	BS	_RD,7
	
	MOV	_RC,@(1)
	SUBA	_RD,@(64)
	JPC	LibStoreDialNumber_full
	INC	_RD
	ADDA	_RD,@(2-1)
	MOV	_RC,A
	MOV	_RD,ax				; ��������벦����
		
	MOV	_RC,@(66)
	SUBA	_RD,@(32)			; ����ز��������ĳ���
	JPC	LibStoreDialNumber_1		; ��32λ�����ٱ������ز�������
	INC	_RD
	ADD	_RC,_RD
	MOV	_RD,ax

LibStoreDialNumber_1:
	MOV	A,ax
	JMP	LibStoreDialNumber_ret
LibStoreDialNumber_full:
	MOV	A,@(0)
LibStoreDialNumber_ret:
	RET

/*************************************************
LibStoreRedialNumber	�����ز�����
input:	none
output:	none
affect: ax, block 3, _RC
note:
	ֻ�����ڹһ�����flashʱ�ſ��Խ��ز����档
	����֮ǰ���뽫��������0��
����:
	�������֮���ʼ���ز����Ͳ�����
*************************************************/
LibStoreRedialNumber:
	BLOCK	3
	MOV	_RC,@(66)
	MOV	A,_RD
	JPZ	LibStoreRedialNumber_ret	; �ز�����Ϊ�գ����ı��ز����롣
	MOV	_RC,@(99)
	MOV	cnt,@(32)
	CLR	ax
	CALL	LibClearRam
	MOV	ax,@(67)
	MOV	bx,@(99)
	MOV	_RC,@(66)
	MOV	cnt,_RD
	CALL	LibCopyRam
LibStoreRedialNumber_ret:
	CLR	_RC
	CLR	_RD				; ����״̬��0
	INC	_RC
	CLR	_RD				; ����ָ����0
	MOV	_RC,@(66)
	CLR	_RD				; �ز�ָ����0
	RET

	

LibHookCheck:			; ֻ�����ڹһ�״̬����
	XORA	sys_msg,@(WM_HANDSET)
	JPZ	LibHookCheck_handset
	JPNB	hardware,DTAMPOWER,LibHookCheck_ret
	XORA	sys_msg,@(WM_KEYPRESS)
	JPZ	LibHookCheck_key
LibHookCheck_ret:
	RETL	@(0)
LibHookCheck_handset:
	XORA	sys_data,@(HANDSET_OFF)
	JPNZ	LibHookCheck_ret
	RETL	@(1)
LibHookCheck_key:
	XORA	sys_data,@(KEY_SPK)
	JPNZ	LibHookCheck_ret
	BS	sys_flag,SPKPHONE
	RETL	@(1)



LibDisplayDialingStatus:			; ��ʾ���ŵ�״̬������ֻ�ڲ���״̬�����ı�ʱ���á�
	BANK	2
	
	BC	r2_stamp1,6
	BC	r2_stamp1,7
	JPB	hardware,HANDSET,$+2
	BS	r2_stamp1,7
	JPNB	sys_flag,SPKPHONE,$+2
	BS	r2_stamp1,6
	BS	sys_flag,STAMP
	
	BLOCK	3
	CLR	_RC
	JPNB	_RD,4,$+6
	MOV	r2_ax,@(STR_MUTE)
	MOV	r2_bx,@(0x02)
	JMP	$+5
	MOV	r2_ax,@(STR_BLANK)
	MOV	r2_bx,@(0x01)
	JPB	sys_flag,SPKPHONE,$+2
	CLR	r2_bx
	
	PAGE	#(VGA)
	
	MOV	A,@(STYLE_LEFT)
	CALL	VgaChar
	MOV	A,r2_ax
	CALL	VgaString
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	
	PAGE	#(IIC)
	MOV	A,@(0x50)
	CALL	IicSendData
	MOV	A,r2_bx
	CALL	IicSendData
	CALL	IicSer
	PAGE	#($)
	RET





/*************************************************
ax:	����ֵ
cnt:	����
_RC:	��ʼ��ַ
*************************************************/
LibClearRam:
	MOV	A,cnt
	JPZ	LibClearRam_ret
	MOV	_RD,ax
	INC	_RC
	DEC	cnt
	JMP	LibClearRam
LibClearRam_ret:
	RET

/*************************************************
ax:	Դ��ַ
bx:	Ŀ���ַ
cnt:	����
*************************************************/
LibCopyRam:
	MOV	A,cnt
	JPZ	LibCopyRam_ret
	SUBA	ax,bx
	JPZ	LibCopyRam_ret
	JPC	LibCopyRam_2
LibCopyRam_1:				; Դ��ַС��Ŀ���ַ
	DEC	cnt
	ADDA	ax,cnt
	MOV	_RC,A
	MOV	exa,_RD
	ADDA	bx,cnt
	MOV	_RC,A
	MOV	_RD,exa
	MOV	A,cnt
	JPNZ	LibCopyRam_1
	JMP	LibCopyRam_ret
LibCopyRam_2:				; Դ��ַ����Ŀ���ַ
	DEC	cnt
	MOV	_RC,ax
	MOV	exa,_RD
	MOV	_RC,bx
	MOV	_RD,exa
	INC	ax
	INC	bx
	MOV	A,cnt
	JPNZ	LibCopyRam_2
LibCopyRam_ret:
	RET

LibDisplayStamp:
	BANK	2
	ANDA	r2_stamp1,@(0x3c)
	MOV	ax,A
	
	BANK	3
	MOV	A,r3_newcall
	JPZ	$+2
	BS	ax,0
	
	CLR	exa
	JPB	r3_ogm,7,$+2			; DAM status
	BS	exa,7
	JPNB	r3_ogm,6,$+2			; memory full
	BS	exa,6
	MOV	A,r3_ringvolume
	JPNZ	$+2
	BS	exa,2
	
	BANK	2
	MOV	r2_stamp1,ax
	MOV	r2_stamp2,exa
	CLR	r2_stamp3
	BS	sys_flag,STAMP
	RETL	@(0)

LibDisplayIdle:
	BANK	3
	JPNB	r3_display,0,LibDisplayIdle_3

	CALL	LibDisplayStamp

	BANK	3
LibDisplayIdle_3:
	JPNB	r3_display,3,LibDisplayIdle_4
	MOV	A,@(STYLE_RIGHT)
	LCALL	VgaNum1
	MOV	A,@(32)
	LCALL	VgaNum1
	MOV	A,@(0)
	LCALL	VgaNum1
	LCALL	VgaDrawNum1
LibDisplayIdle_4:
	JPNB	r3_display,4,LibDisplayIdle_5
	LCALL	VgaBlankNum2
LibDisplayIdle_5:
	JPNB	r3_display,5,LibDisplayIdle_6
	
	PAGE	#(LibMathHexToBcd)
	MOV	ax,r3_totalcall
	CALL	LibMathHexToBcd
	MOV	r3_ax,ax
	MOV	ax,r3_newcall
	CALL	LibMathHexToBcd
	MOV	r3_bx,ax
	
	PAGE	#(VGA)
	CALL	VgaBlankChar
	
	MOV	A,@(STYLE_LEFT)
	CALL	VgaChar
	MOV	A,@(STR_Total)
	CALL	VgaString
	MOV	A,@(58)
	CALL	VgaChar
	SWAPA	r3_ax
	AND	A,@(0x0f)
	ADD	A,@(48)
	CALL	VgaChar
	ANDA	r3_ax,@(0x0f)
	ADD	A,@(48)
	CALL	VgaChar
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	
	MOV	A,@(STYLE_RIGHT)
	CALL	VgaChar
	MOV	A,@(STR_New)
	CALL	VgaString
	MOV	A,@(58)
	CALL	VgaChar
	SWAPA	r3_bx
	AND	A,@(0x0f)
	ADD	A,@(48)
	CALL	VgaChar
	ANDA	r3_bx,@(0x0f)
	ADD	A,@(48)
	CALL	VgaChar
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)
LibDisplayIdle_6:
	RET



LibInitTimer:
	BANK	2
	CLR	r2_msec
	CLR	r2_second
	CLR	r2_minute
	CLR	r2_hour
	RETL	@(1)

LibUpdateTimer:
	BANK	2
	XORA	sys_msg,@(WM_TIME)
	JPNZ	LibUpdateTimer_ret
	ADD	r2_msec,sys_data
	SUBA	r2_msec,@(100)
	JPNC	LibUpdateTimer_ret
	MOV	r2_msec,A
	INC	r2_second
	SUBA	r2_second,@(60)
	JPNZ	LibUpdateTimer_display
	CLR	r2_second
	INC	r2_minute
	SUBA	r2_minute,@(60)
	JPNZ	LibUpdateTimer_display
	CLR	r2_minute
	INC	r2_hour
	SUBA	r2_hour,@(200)
	JPNZ	LibUpdateTimer_display
	MOV	r2_hour,@(100)
LibUpdateTimer_display:
	RETL	@(1)
LibUpdateTimer_ret:
	RETL	@(0)

LibDisplayTimer:
	ADD	A,@(0)
	JPZ	LibDisplayTimer_ret
	BANK	2
	MOV	A,@(STYLE_RIGHT)
	LCALL	VgaChar
	MOV	A,r2_hour
	JPZ	LibDisplayTimer_1
	CALL	UpdateTime
	MOV	A,@(58)
	LCALL	VgaChar
LibDisplayTimer_1:
	MOV	A,r2_minute
	CALL	UpdateTime
	MOV	A,@(58)
	LCALL	VgaChar
	MOV	A,r2_second
	CALL	UpdateTime
	PAGE	#(VGA)
	MOV	A,@(0)
	CALL	VgaChar
	CALL	VgaDrawChar
	PAGE	#($)
LibDisplayTimer_ret:
	RETL	@(0)
	

UpdateTime:
	MOV	ax,A
	LCALL	LibMathHexToBcd
	MOV	r2_ax,ax
	SWAPA	r2_ax
	AND	A,@(0x0f)
	ADD	A,@(48)
	LCALL	VgaChar
	ANDA	r2_ax,@(0x0f)
	ADD	A,@(48)
	LCALL	VgaChar
	RET
	

; ������ּ��Ƿ��¡�
LibNumberCheck:
	XORA	sys_data,@(KEY_0)
	JPZ	LibNumberCheck_0
	XORA	sys_data,@(KEY_1)
	JPZ	LibNumberCheck_1
	XORA	sys_data,@(KEY_2)
	JPZ	LibNumberCheck_2
	XORA	sys_data,@(KEY_3)
	JPZ	LibNumberCheck_3
	XORA	sys_data,@(KEY_4)
	JPZ	LibNumberCheck_4
	XORA	sys_data,@(KEY_5)
	JPZ	LibNumberCheck_5
	XORA	sys_data,@(KEY_6)
	JPZ	LibNumberCheck_6
	XORA	sys_data,@(KEY_7)
	JPZ	LibNumberCheck_7
	XORA	sys_data,@(KEY_8)
	JPZ	LibNumberCheck_8
	XORA	sys_data,@(KEY_9)
	JPZ	LibNumberCheck_9
LibNumberCheck_ret:
	RETL	@(0)
LibNumberCheck_0:
	RETL	@(48)
LibNumberCheck_1:
	RETL	@(49)
LibNumberCheck_2:
	RETL	@(50)
LibNumberCheck_3:
	RETL	@(51)
LibNumberCheck_4:
	RETL	@(52)
LibNumberCheck_5:
	RETL	@(53)
LibNumberCheck_6:
	RETL	@(54)
LibNumberCheck_7:
	RETL	@(55)
LibNumberCheck_8:
	RETL	@(56)
LibNumberCheck_9:
	RETL	@(57)

; �����ĸ���Ƿ���
LibCharNumCheck:
	XORA	sys_data,@(KEY_STAR)
	JPZ	LibDialNumCheck_star
	XORA	sys_data,@(KEY_HASH)
	JPZ	LibDialNumCheck_hash
	JMP	LibNumberCheck
LibDialNumCheck_star:
	RETL	@(42)
LibDialNumCheck_hash:
	RETL	@(35)

; ��鲦�ż��Ƿ���
LibDialNumCheck:
	XORA	sys_data,@(KEY_REDIAL)
	JPZ	LibDialNumCheck_pause
	JMP	LibCharNumCheck
LibDialNumCheck_pause:
	RETL	@(112)




LibNumTone:
	ADD	A,@(256-112)
	JPZ	LibNumTone_p
	ADD	A,@(112-100)
	JPZ	LibNumTone_d
	ADD	A,@(100-99)
	JPZ	LibNumTone_c
	ADD	A,@(99-98)
	JPZ	LibNumTone_b
	ADD	A,@(98-97)
	JPZ	LibNumTone_a
	ADD	A,@(97-80)
	JPZ	LibNumTone_p
	ADD	A,@(80-68)
	JPZ	LibNumTone_d
	ADD	A,@(68-67)
	JPZ	LibNumTone_c
	ADD	A,@(67-66)
	JPZ	LibNumTone_b
	ADD	A,@(66-65)
	JPZ	LibNumTone_a
	ADD	A,@(65-57)
	JPZ	LibNumTone_9
	ADD	A,@(57-56)
	JPZ	LibNumTone_8
	ADD	A,@(56-55)
	JPZ	LibNumTone_7
	ADD	A,@(55-54)
	JPZ	LibNumTone_6
	ADD	A,@(54-53)
	JPZ	LibNumTone_5
	ADD	A,@(53-52)
	JPZ	LibNumTone_4
	ADD	A,@(52-51)
	JPZ	LibNumTone_3
	ADD	A,@(51-50)
	JPZ	LibNumTone_2
	ADD	A,@(50-49)
	JPZ	LibNumTone_1
	ADD	A,@(49-48)
	JPZ	LibNumTone_0
	ADD	A,@(48-42)
	JPZ	LibNumTone_star
	ADD	A,@(42-35)
	JPZ	LibNumTone_hash
	RETL	@(0)
LibNumTone_p:
	RETL	@(0xff)
LibNumTone_d:
	RETL	@(0x77)
LibNumTone_c:
	RETL	@(0x7b)
LibNumTone_b:
	RETL	@(0x7d)
LibNumTone_a:
	RETL	@(0x7e)
LibNumTone_hash:
	RETL	@(0xb7)
LibNumTone_9:
	RETL	@(0xbb)
LibNumTone_6:
	RETL	@(0xbd)
LibNumTone_3:
	RETL	@(0xbe)
LibNumTone_0:
	RETL	@(0xd7)
LibNumTone_8:
	RETL	@(0xdb)
LibNumTone_5:
	RETL	@(0xdd)
LibNumTone_2:
	RETL	@(0xde)
LibNumTone_star:
	RETL	@(0xe7)
LibNumTone_7:
	RETL	@(0xeb)
LibNumTone_4:
	RETL	@(0xed)
LibNumTone_1:
	RETL	@(0xee)




LibSendOneCommand:
	PAGE	#(IIC)
	CALL	IicSendData
	MOV	A,@(0x00)
	CALL	IicSendData
	CALL	IicSer
	PAGE	#($)
	RETL	@(0)

LibGetCommand:
	ADD	A,@(63)
	MOV	_RC,A
	BLOCK	4
	MOV	A,_RD
	RET


; ��ȡ��Ч���ݵĳ��ȣ����32λ
LibGetValidLength32:
	CLR	cnt
LibGetValidLength32_loop:
	MOV	A,_RD
	JPZ	LibGetValidLength32_ret
	SUBA	cnt,@(32)
	JPC	LibGetValidLength32_ret
	INC	cnt
	INC	_RC
	JMP	LibGetValidLength32_loop
LibGetValidLength32_ret:
	MOV	A,cnt
	RET


; ��ȡ��Ч���ݵĳ��ȣ����16λ
LibGetValidLength:
	CLR	cnt
LibGetValidLength_loop:
	MOV	A,_RD
	JPZ	LibGetValidLength_ret
	SUBA	cnt,@(16)
	JPC	LibGetValidLength_ret
	INC	cnt
	INC	_RC
	JMP	LibGetValidLength_loop
LibGetValidLength_ret:
	MOV	A,cnt
	RET

LibPromptBeep:
	MOV	bx,A
	PAGE	#(IIC)
	MOV	A,@(0x60)
	CALL	IicSendData
	MOV	A,bx
	CALL	IicSendData
	CALL	IicSer
	RETL	@(0)

/*************************************************
ͨ�����ڼ�������
������
1. 400��һ�����ڡ���0��1��0��Ϊ��׼�㡣
2. ÿ�갴�������㣬365�죬�պ�52��+1�죬�������׼�������a��
3. �����ڵ����꾭����������b��ע��0��Ϊ���꣬ͬʱ���㱾�ꡣ
4. ���·ݶ����ڱ�õ���c��
5. ����d��
6. �������Ϊ���겢���·���3�����ڣ�����b��e=1��
7. ����ֵf��
8. ���Ϊ��= a+b+c+d-e+f��
*************************************************/
LibWeekCheck:
	ANDA	r1_century,@(0x03)
	CALL	WeekCentury		; 100������ڵı�
	ADD	A,r1_year		; +�����
	MOV	ax,A
	
	MOV	bx,r1_year
	RRC	bx
	RRC	bx
	AND	bx,@(0x3f)		; 100�����ܱ�4��������ݸ������������ܱ�100��������ݡ�
	
	ANDA	r1_century,@(0x03)
	TBL
	JMP	LibWeekCheck_0
	JMP	LibWeekCheck_1
	JMP	LibWeekCheck_2
	JMP	LibWeekCheck_3
LibWeekCheck_3:
	ADD	bx,@(24)
LibWeekCheck_2:
	ADD	bx,@(24)
LibWeekCheck_1:
	ADD	bx,@(24)
LibWeekCheck_0:				; 400���ڱ�4������������
	INC	bx			; 0�������ꡣ
	ADD	ax,bx
	
	SUBA	r1_month,@(1)
	CALL	WeekMonth		; �·ݶ����ڵı�
	ADD	ax,A
	
	ADD	ax,r1_day		; ��
	
	SUBA	r1_month,@(3)
	JPC	LibWeekCheck_4
	CALL	LibLeapYear
	ADD	A,@(0)
	JPZ	LibWeekCheck_4
	DEC	ax			; 3����ǰ�����ҵ���Ϊ���꣬����һ�졣
	
LibWeekCheck_4:
	ADD	ax,@(5)			; +����ֵ
LibWeekCheck_5:
	SUBA	ax,@(7)
	JPNC	LibWeekCheck_ret
	MOV	ax,A
	JMP	LibWeekCheck_5
LibWeekCheck_ret:
	MOV	r1_week,ax
	RET
	


WeekCentury:
	TBL
	RETL	@(0)
	RETL	@(2)
	RETL	@(4)
	RETL	@(6)

WeekMonth:
	TBL
	RETL	@(0)
	RETL	@(3)
	RETL	@(3)
	RETL	@(6)
	RETL	@(1)
	RETL	@(4)
	RETL	@(6)
	RETL	@(2)
	RETL	@(5)
	RETL	@(0)
	RETL	@(3)
	RETL	@(5)



LibLeapYear:
	ANDA	r1_year,@(0x03)
	JPNZ	LibLeapYear_false
	MOV	A,r1_year
	JPNZ	LibLeapYear_true
	ANDA	r1_century,@(0x03)
	JPNZ	LibLeapYear_false
LibLeapYear_true:
	RETL	@(1)
LibLeapYear_false:
	RETL	@(0)


LibVolAdjust:
	XORA	sys_data,@(KEY_VOLA)
	JPZ	LibVolAdjust_vola
	XORA	sys_data,@(KEY_VOLS)
	JPZ	LibVolAdjust_vols
	RETL	@(0)
LibVolAdjust_vola:
	MOV	A,@(0x01)
	JMP	LibVolAdjust_1
LibVolAdjust_vols:
	MOV	A,@(0x00)
LibVolAdjust_1:
	MOV	bx,A
	PAGE	#(IIC)
	MOV	A,@(0x4f)
	CALL	IicSendData
	MOV	A,bx
	CALL	IicSendData
	CALL	IicSer
	PAGE	#($)
	RETL	@(0)

LibClearDisplaySerialNumber:
	PAGE	#(VGA)
	MOV	A,@(STYLE_RIGHT)
	CALL	VgaNum1
	MOV	A,@(32)
	CALL	VgaNum1
	MOV	A,@(32)
	CALL	VgaNum1
	MOV	A,@(0)
	CALL	VgaNum1
	CALL	VgaDrawNum1
	PAGE	#($)
	RETL	@(0)


LibDefaultSetting:
	BANK	3
	MOV	r3_ringmelody,@(DEFAULT_ringmelody)
	MOV	r3_ringvolume,@(DEFAULT_ringvolume)
	MOV	r3_flashtime,@(DEFAULT_flashtime)
	MOV	r3_pausetime,@(DEFAULT_pausetime)
	MOV	r3_contrast,@(DEFAULT_contrast)
	MOV	r3_ogm,@(DEFAULT_ogm)
	MOV	r3_remotecode1,@(DEFAULT_remotecode1)
	MOV	r3_remotecode2,@(DEFAULT_remotecode2)
	MOV	r3_areacode1,@(DEFAULT_areacode1)
	MOV	r3_areacode2,@(DEFAULT_areacode2)
	MOV	r3_language,@(DEFAULT_language)
	MOV	r3_ringdelay,@(DEFAULT_ringdelay)
	MOV	r3_rate,@(DEFAULT_rate)
	
	RETL	@(0)
