.LIST
;-------------------------------------------------------------------------------
;	OGM_SELECT
;	check weather the current OGMx exist?
;	input : ACCH = 	OGMx
;	output: ACCH = 	MSG_ID(OGMx对应的ID号)
;			0/~0 ---无对应OGM/OGMx对应的ID号
;
;		MSG_ID		= index NO.in current MBOX in current MSG type(OGM)
;		MSG_N = 101/102	= the current OGM index(USR INDEX DATA0)
;-------------------------------------------------------------------------------
OGM_SELECT:			;用于录音/放音时确定OGM_ID(非接线时用)
	LACK	COGM2_ID

	BIT	EVENT,8		;answer only?
	BS	TB,OGM_SELECT_1
	
	LACK	COGM1_ID
OGM_SELECT_1:
	SAH	MSG_N
	CALL	OGM_STATUS1
	
	RET
;-------------------------------------------------------------------------------
;	OGM_STATUS
;	check weather the current OGMx exist?
;	input : EVENT.8		= 0/1---answer ICM/answer only
;		EVENT.9		= 0/1---answer on/off
;		ANN_FG.13	= 0/1---not/memoful
;	output: ACCH = 1/0 --- the OGM exist/no OGM
;
;		MSG_ID		= index NO.in current MBOX in current MSG type(OGM)(0..MSG_T)
;		MSG_N = 101/102 = the current OGM index(USR INDEX DATA0)
;-------------------------------------------------------------------------------
OGM_STATUS:			;接线时用
	LACK	COGM1_ID
	SAH	MSG_N

	BIT	EVENT,8		;answer only?
	BS	TB,OGM_STATUS0
	BIT	EVENT,9		;answer off?
	BS	TB,OGM_STATUS0
	BIT	ANN_FG,13	;memoful?
	BS	TB,OGM_STATUS0
	BS	B1,OGM_STATUS1
OGM_STATUS0:	
	LACK	COGM2_ID
	SAH	MSG_N		;answer only(OGM5)
OGM_STATUS1:
	LACL	0XD000
	CALL	DAM_BIOSFUNC
	
	LACL	0XD201
	CALL	DAM_BIOSFUNC	;OGM1
	
	LAC	MSG_N
	SBHK	COGM1_ID
	BS	ACZ,OGM_STATUS1_1
	
	LACL	0XD202
	CALL	DAM_BIOSFUNC	;OGM2
OGM_STATUS1_1:

	LACL	0X3000
	CALL	DAM_BIOSFUNC
	SAH	MSG_ID		;OGMx exist/not
	
        RET

;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
.END
