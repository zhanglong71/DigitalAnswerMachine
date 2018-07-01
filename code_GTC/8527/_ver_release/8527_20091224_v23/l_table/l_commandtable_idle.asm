.LIST
;-------------------------------------------------------------------------------
RESERVED	.EQU	0
;---------------------------------------
COMMAND_TAB:

.data	SYS_MSG_YES			;0x40-----------------------------------
.data	SYS_MSG_YES			;0x41-Set RING_NUM_TO_ANS
.data	SYS_MSG_YES			;0x42-set PASSWORD(11..8)
.data	SYS_MSG_YES			;0x43-Set PASSWORD(7..0)
.data	SYS_MSG_YES			;0X44
.data	SYS_MSG_YES			;0x45-Set CompressRate
.data	SYS_MSG_YES			;0X46
.data	SYS_MSG_YES			;0X47
.data	SYS_MSG_YES			;0X48
.data	SYS_MSG_YES			;0X49
.data	SYS_SER_RUN_SETVOL		;0X4A-Set volum
.data	SYS_MSG_YES			;0X4B
.data	SYS_MSG_YES			;0X4C
.data	SYS_SER_RUN_SetMenuVOP		;0x4D-Talk_setup_menu
.data	SYS_SER_RUN_SetWeek		;0x4E-set_ITAD_clock(week)
.data	SYS_SER_RUN_SetMDHM		;0X4F-set_ITAD_clock
.data	SYS_MSG_YES			;0X50-----------------------------------
.data	SYS_SER_RUN_0X51		;0X51-OGM Select
.data	SYS_SER_RUN_0X52		;0X52-play OGM
.data	SYS_SER_RUN_0X53		;0X53-record OGM
.data	SYS_SER_RUN_0X54		;0X54-play message
.data	SYS_MSG_YES			;0X55
.data	SYS_MSG_YES			;0X56
.data	SYS_MSG_YES			;0X57
.data	SYS_SER_RUN_0X58		;0X58-play memo help
.data	SYS_SER_RUN_0X59		;0X59-record memo/2WAY
.data	SYS_SER_RUN_0X5A		;0X5A-stop
.data	SYS_MSG_YES			;0X5B
.data	SYS_SER_RUN_0X5C		;0X5C-all old message delete
.data	SYS_MSG_YES			;0X5D
.data	SYS_SER_RUN_0X5E		;0X5E-speakerphone
.data	SYS_MSG_YES			;0X5F
.data	SYS_SER_RUN_0X60		;0X60-Handset on/off HOOK---------------
.data	SYS_SER_RUN_0X61		;0X61
.data	SYS_MSG_YES			;0X62
.data	SYS_MSG_YES			;0X63
.data	SYS_SER_RUN_0X64		;0X64-SPK on/off
.data	SYS_SER_RUN_0X65		;0X65-DAM-enable/disable
.data	SYS_MSG_YES			;0X66
.data	SYS_MSG_YES			;0X67
.data	SYS_MSG_YES			;0X68
.data	SYS_MSG_YES			;0X69
.data	SYS_SER_RUN_0X6A		;0X6A
.data	SYS_SER_RUN_0X6B		;0X6B
.data	SYS_MSG_YES			;0X6C
.data	SYS_MSG_YES			;0X6D
.data	SYS_MSG_YES			;0X6E
.data	SYS_SER_RUN_0X6F		;0X6F
.data	SYS_SER_RUN_0X70		;0X70-MCU925 receive error message information and give back decision(delete all or not)
.data	SYS_MSG_YES			;0X71
.data	SYS_MSG_YES			;0X72
.data	SYS_MSG_YES			;0X73
.data	SYS_MSG_YES			;0X74
.data	SYS_MSG_YES			;0X75
.data	SYS_MSG_YES			;0X76
.data	SYS_MSG_YES			;0X77
.data	SYS_MSG_YES			;0X78
.data	SYS_MSG_YES			;0X79
.data	SYS_MSG_YES			;0X7A
.data	SYS_MSG_YES			;0X7B
.data	SYS_MSG_YES			;0X7C
.data	SYS_MSG_YES			;0X7D
.data	SYS_MSG_YES			;0X7E
.data	SYS_MSG_YES			;0X7F
.data	SYS_SER_RUN_0X80		;0x80-----------------------------------
.data	SYS_SER_RUN_0X81		;0x81
.data	SYS_SER_RUN_0X82		;0x82
.data	SYS_SER_RUN_0X83		;0x83
.data	SYS_MSG_YES			;0x84
.data	SYS_MSG_YES			;0x85
.data	SYS_MSG_YES			;0x86
.data	SYS_MSG_YES			;0x87
.data	SYS_MSG_YES			;0x88
.data	SYS_MSG_YES			;0x89
.data	SYS_MSG_YES			;0x8A
.data	SYS_MSG_YES			;0x8B
.data	SYS_MSG_YES			;0x8C
.data	SYS_MSG_YES			;0x8D
.data	SYS_MSG_YES			;0x8E
.data	SYS_MSG_YES			;0x8F

;-------------------------------------------------------------------------------
.END
