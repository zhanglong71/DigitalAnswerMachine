.LIST

;############################################################################
;
;	Function : TELNUM_WRITE
;	save the telephone number in working group
;
;	将以ADDR_S为起始地址,以OFFSET_S为起始偏移,总数为COUNT的数据,写入FLASH(以BYTE为单位)
;	input  : ADDR_S = the base address of the TEL_NUM
;		 OFFSET_S = the offset of the first data
;		 COUNT = the count of data	 
;	output : ACCH = 0/!0---success/error
;
;############################################################################
TELNUM_WRITE:
	CALL	GETBYTE_DAT
	ORL	0XE000
	CALL	DAM_BIOSFUNC
	SFR	8
	BZ	ACZ,TELNUM_WRITE_EXIT	;没问题继续/有故障结束

	LAC	OFFSET_S
	ADHK	1
	SAH	OFFSET_S	;the next byte
	
	LAC	COUNT
	SBHK	1
	SAH	COUNT		;the remain bytes of data
	BS	ACZ,TELNUM_WRITE_EXIT
	BZ	SGN,TELNUM_WRITE
TELNUM_WRITE_EXIT:

	RET
;############################################################################
;       Function : TELNUM_READ
;	Read the TEL-data with specifyed TEL_ID
;	根据TEL_ID从当前Group读出电话号码(此条目的全部)
;
;	从flash中读出数据并保存在以ADDR_D为起始基地址,以OFFSET_D为起始偏移的位置(以BYTE为单位)
;	input  : ACCH = TEL_ID
;		 ADDR_D = the base address of the TEL_NUM
;		 OFFSET_D = the offset of the first data
;		 
;	output : ACCH =  COUNT = the count of data
;
;	variable:SYSTMP1,SYSTMP2,COUMT
;############################################################################
TELNUM_READ:

	PSH	SYSTMP1
	PSH	SYSTMP2
;-----------------------------
	SAH	SYSTMP2
	
	LACK	0
	SAH	COUNT
TELNUM_READ_LOOP:
	LAC	SYSTMP2
	ORL	0XE200		;1 byte
       	CALL    DAM_BIOSFUNC
       	SAH	SYSTMP1
       	SFR     8
	BZ	ACZ,TELNUM_READ_EXIT
	LAC	SYSTMP1
	CALL	STORBYTE_DAT
	
	LAC	OFFSET_D
	ADHK	1
	SAH	OFFSET_D
	
	LAC	COUNT
	ADHK	1
	SAH	COUNT
	BS	B1,TELNUM_READ_LOOP
TELNUM_READ_EXIT:
	LACL	0XE300
       	CALL    DAM_BIOSFUNC
	
	LAC	COUNT
;-----------------------------
	POP	SYSTMP2
	POP	SYSTMP1

	RET

;-------------------------------------------------------------------------------
	
.END
