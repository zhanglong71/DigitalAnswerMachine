.LIST
;-------------------------------------------------------------------------------
;       Function : SEND_PBOOK
;	
;	the number of phonebook
;       Input  : ACCH
;       Output : no
;-------------------------------------------------------------------------------
SEND_PBOOK:
	SAH	SYSTMP0
	
	LACK	CMDT_PhoneBook
	CALL	SEND_DAT
	LAC	SYSTMP0
	CALL	SEND_DAT
	
	RET

;-------------------------------------------------------------------------------
.END
