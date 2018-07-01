.NOLIST
.INCLUDE	include/REG_D22.inc
.INCLUDE	include/MD22U.inc
.INCLUDE	include/CONST.inc
.LIST
;-------------------------------------------------------------------------------
.GLOBAL	INT_CPC_DET
.EXTERN	INT_STOR_MSG
;-------------------------------------------------------------------------------
.ORG	ADDR_SECOND
;-------------------------------------------------------------------------------
;	Function : SET_DTMFTYPE
;	input : ACCH(0..F)
;	output: ACCH
;-------------------------------------------------------------------------------
INT_CPC_DET:
	LAC	TMR_CPC
	SBHL	CPC_TLEN
	BZ	SGN,INT_CPC_DET4
	
	LIPK	8
	IN	INT_TTMP1,GPBD
	BIT	INT_TTMP1,CbCPC
	;BZ	TB,INT_CPC_DET2		;Detect High Pulse
	BS	TB,INT_CPC_DET2		;Detect Low Pulse

	BIT	INT_TTMP1,CbLIN		;Request Line=high(when CPC detect)
	BZ	TB,INT_CPC_DET2
INT_CPC_DET1:
	LAC     TMR_CPC
        SBHK    1
        SAH     TMR_CPC
        BS	ACZ,INT_CPC_DET3
	BS	B1,INT_CPC_DET_END
INT_CPC_DET2:
	LACK	CPC_TLEN
	SAH	TMR_CPC

	BS	B1,INT_CPC_DET_END
INT_CPC_DET3:	
	LACL	CMSG_CPC
	CALL	INT_STOR_MSG
	BS	B1,INT_CPC_DET_END
INT_CPC_DET4:
	LAC	TMR_CPC
	SBHK	1
	SAH	TMR_CPC		
	;BS	B1,INT_CPC_DET_END
	
INT_CPC_DET_END:
	RET
;-------------------------------------------------------------------------------
.END
