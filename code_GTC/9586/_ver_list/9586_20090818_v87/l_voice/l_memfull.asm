.LIST
;---------------
;	input : no
;	output: no
;---------------
VP_MemoryIsFull:
	CALL	GET_LANGUAGE
	BS	ACZ,VP_MemoryIsFull_0
	SBHK	1
	BS	ACZ,VP_MemoryIsFull_French
	SBHK	1
	BS	ACZ,VP_MemoryIsFull_Spanish
VP_MemoryIsFull_0:	;English
	LACL	0XFF00|52
	CALL	STOR_VP
	RET
VP_MemoryIsFull_Spanish:	;Spanish
	LACL	0XFF00|111
	CALL	STOR_VP
	RET
VP_MemoryIsFull_French:	;French
	LACL	0XFF00|175
	CALL	STOR_VP
	RET
;-------------------------------------------------------------------------------

.END
	