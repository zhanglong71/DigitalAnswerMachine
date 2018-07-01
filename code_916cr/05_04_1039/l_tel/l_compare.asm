.LIST

;###############################################################################
;       Function : COMP_ONETELNUM
;将放在地址(ADDR_S/OFFSET_S)处,长度为COUNT的数据与指定TEL_ID的数据进行比较
;
;	input  : ACCH = TEL_ID
;		 COUNT = 比较数据的长度
;		 ADDR_S = 参与比较号码所在地址的基地址
;		 OFFSET_S = 参与比较号码所在起始偏移地址
;	OUTPUT : ACCH = 0/1 ---不相等/相等
;
;	variable:,SYSTMP1,SYSTMP2,COUNT,OFFSET_D
;###############################################################################
COMP_ONETELNUM:
	
	PSH	SYSTMP1
	PSH	SYSTMP2
	PSH	COUNT
	
	SAH	SYSTMP2		;save TEL_ID

	MAR	+0,1
	LAR	ADDR_S,1

	LACK	0
	SAH	OFFSET_D
COMP_ONETELNUM_0:		;先调整到对应的比较位
	LAC	OFFSET_S
	SBH	OFFSET_D
	BS	ACZ,COMP_ONETELNUM_LOOP
	
	LAC	SYSTMP2
	CALL	DAT_READ
	BS	ACZ,COMP_ONETELNUM_ENDNO	;无效数据,退出

	LAC	OFFSET_D
	ADHK	1
	SAH	OFFSET_D	;下一个要取得的数据的偏移
	BS	B1,COMP_ONETELNUM_0

COMP_ONETELNUM_LOOP:
	LAC	SYSTMP2
	CALL	DAT_READ
	BS	ACZ,COMP_ONETELNUM_ENDNO	;无效数据,退出

	CALL	GETBYTE_DAT
	SBH	SYSTMP1
	BZ	ACZ,COMP_ONETELNUM_ENDNO	;有一个不相等,退出

	LAC	OFFSET_D
	ADHK	1
	SAH	OFFSET_D

	;LAC	OFFSET_S
	;ADHK	1
	;SAH	OFFSET_S

	LAC	COUNT
	SBHK	1
	SAH	COUNT
	BS	SGN,COMP_ONETELNUM_ENDYES
	BZ	ACZ,COMP_ONETELNUM_LOOP	

COMP_ONETELNUM_ENDYES:		;比较完毕,没找到不相等的数据
	POP	COUNT
	POP	SYSTMP2
	POP	SYSTMP1
	
	LACK	1
	
	RET
COMP_ONETELNUM_ENDNO:

	POP	COUNT
	POP	SYSTMP2
	POP	SYSTMP1

	LACK	0	;
	RET

;############################################################################
;       Function : COMP_ALLDAT
;从当前Group读出电话号码并与已有号码比较.若相同就返回ACCH = TEL_ID/0
;
;	input  : ADDR_S = 参与比较数据的所在地址的基地址
;		 OFFSET_S = 参与比较数据的所在地址的偏移
;		 COUNT = 参与比较号码长度
;	OUTPUT : ACCH = 0/!0 --没找到/找到的号码的序号
;
;	variable:,SYSTMP1,SYSTMP2,SYSTMP3,COUNT
;############################################################################
COMP_ALLDAT:
	CALL	GET_TELT
	ADHK	1
	SAH	SYSTMP2

COMP_ALLDAT_LOOP_1:
	LAC	SYSTMP2
	SBHK	1
	SAH	SYSTMP2		;TEL_ID
	BS	ACZ,COMP_ALLDAT_END	;find fail

	LAC	SYSTMP2
	CALL	COMP_ONETELNUM
	BZ	ACZ,COMP_ALLDAT_END	;find ok
	
	CALL	DAT_READ_STOP
	BS	B1,COMP_ALLDAT_LOOP_1	;next one
COMP_ALLDAT_END:
	LAC	SYSTMP2

	RET
;############################################################################
;       Function : COMP_ALLTELNUM
;从当前Group读出电话号码并与已有"号码"比较.若相同就返回ACCH = TEL_ID/0
;
;	input  : ADDR_S = 参与比较号码的所在地址的基地址
;	OUTPUT : ACCH = 0/!0 --没找到/找到的号码的序号
;
;!!!----Note : Num
;
;	variable:,SYSTMP1,SYSTMP2,SYSTMP3,COUNT
;############################################################################
COMP_ALLTELNUM:
	CALL	GET_TELT
	ADHK	1
	SAH	SYSTMP2
COMP_ALLTELNUM_LOOP_1:			;先比较号码长度
	LACK	5
	SAH	OFFSET_S
	SAH	OFFSET_D		;specific offset(对应号码长度)

	LAC	SYSTMP2
	SBHK	1
	SAH	SYSTMP2			;TEL_ID
	BS	ACZ,COMP_ALLTELNUM_END	;find fail
	CALL	READ_BYTEDAT
	BS	ACZ,COMP_ALLTELNUM_LOOP_1	;无效数据(查下一条)
	LAC	SYSTMP0
	SAH	COUNT			;要比较的号码的长度

	CALL	GETBYTE_DAT
	SBH	COUNT	
	BZ	ACZ,COMP_ALLTELNUM_LOOP_1	;号码长度不相等(查下一条)
	CALL	DAT_READ_STOP
;---开始比较号码
	LACK	6
	SAH	OFFSET_S		;起始偏移值

	LAC	SYSTMP2
	CALL	COMP_ONETELNUM
	BZ	ACZ,COMP_ALLTELNUM_END
	
	CALL	DAT_READ_STOP
	BS	B1,COMP_ALLTELNUM_LOOP_1	;号码内容不相等(查下一条)
COMP_ALLTELNUM_END:
	CALL	DAT_READ_STOP
	LAC	SYSTMP2

	RET
;############################################################################
;       Function : COMP_ALLTEL
;从当前Group读出电话号码及姓名与已有"号码及姓名"比较.若相同就返回ACCH = TEL_ID/0
;
;	input  : ADDR_S = 参与比较号码的所在地址的基地址
;	OUTPUT : ACCH = 0/!0 --没找到/找到的号码的序号
;
;!!!---Note : Num+Name
;
;	variable:,SYSTMP1,SYSTMP2,SYSTMP3,COUNT
;############################################################################
COMP_ALLTEL:
	CALL	GET_TELT
	ADHK	1
	SAH	SYSTMP2
COMP_ALLTEL_LOOP_1:		;先比较号码长度
	LACK	5
	SAH	OFFSET_S
	SAH	OFFSET_D		;specific offset(对应号码长度)

	LAC	SYSTMP2
	SBHK	1
	SAH	SYSTMP2			;TEL_ID
	BS	ACZ,COMP_ALLTEL_END	;find fail
	CALL	READ_BYTEDAT
	BS	ACZ,COMP_ALLTEL_LOOP_1	;无效数据(查下一条)
	LAC	SYSTMP0
	SAH	COUNT		;要比较的号码的长度

	CALL	GETBYTE_DAT
	SBH	COUNT	
	BZ	ACZ,COMP_ALLTEL_LOOP_1	;号码长度不相等(查下一条)
	CALL	DAT_READ_STOP
;---开始比较号码
	LACK	6
	SAH	OFFSET_S

	LAC	SYSTMP2
	CALL	COMP_ONETELNUM
	BZ	ACZ,COMP_ALLTEL_1
	
	CALL	DAT_READ_STOP
	BS	B1,COMP_ALLTEL_LOOP_1	;号码内容不相等(查下一条)
COMP_ALLTEL_1:		;号码比较成功完毕,开始姓名部分的比较	
	CALL	DAT_READ_STOP

	LACK	38
	SAH	OFFSET_S
	SAH	OFFSET_D		;specific offset(对应姓名长度)

	LAC	SYSTMP2
	CALL	READ_BYTEDAT
	BS	ACZ,COMP_ALLTEL_LOOP_1	;无效数据(查下一条)
	LAC	SYSTMP0
	SAH	COUNT		;要比较的姓名的长度

	CALL	GETBYTE_DAT
	SBH	COUNT	
	BZ	ACZ,COMP_ALLTEL_LOOP_1	;姓名长度不相等(查下一条)
	CALL	DAT_READ_STOP
;---开始比较姓名内容
;COMP_ALLTEL_LOOP_2:		
	LACK	39
	SAH	OFFSET_S

	LAC	SYSTMP2
	CALL	COMP_ONETELNUM
	BZ	ACZ,COMP_ALLTEL_END	;find ok
	
	CALL	DAT_READ_STOP
	BS	B1,COMP_ALLTEL_LOOP_1	;姓名内容不相等(查下一条)
	
COMP_ALLTEL_END:
	CALL	DAT_READ_STOP
	LAC	SYSTMP2

	RET
;###############################################################################
;       Function : READ_BYTEDAT
;	根据得到的TEL_ID从当前Group读出电话号码的第COUNT(从零开始)个字节
;
;	input  : ACCH = TEL_ID
;		 OFFSET_D = 要读的数据的序号
;	OUTPUT : ACCH = 1/0---读出的结果是/否有效
;		 SYSTEMP0 = 读出的结果 
;
;
;
;###############################################################################
READ_BYTEDAT:

	PSH	SYSTMP1
	PSH	OFFSET_D
	
	ANDL	0X0FF
	BS	ACZ,READ_BYTEDAT_END
	SAH	SYSTMP1
READ_BYTEDAT_LOOP:	
	LAC	SYSTMP1
	CALL	DAT_READ
	BS	ACZ,READ_BYTEDAT_END
	
	LAC	OFFSET_D
	SBHK	1
	SAH	OFFSET_D
	BZ	SGN,READ_BYTEDAT_LOOP
	
	CALL	DAT_READ_STOP
	
	POP	OFFSET_D
	POP	SYSTMP1
	LACK	1		;得到预期的DATA
	RET
READ_BYTEDAT_END:
	POP	OFFSET_D
	POP	SYSTMP1
       	LACK	0		;读出结果无效
;-----------------------------------------

	RET
;-------------------------------------------------------------------------------
.END
