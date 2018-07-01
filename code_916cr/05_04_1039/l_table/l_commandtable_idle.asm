.LIST
;-------------------------------------------------------------------------------
;RESERVED	.EQU	0
;---------------------------------------
COMMAND_TAB:

.data	IDLE_CMD_OVER			;0x40-----------------------------------
.data	IDLE_COMMAND_0X41		;0x41-play message
.data	IDLE_CMD_OVER			;0x42-(reserved in idle)Pause play
.data	IDLE_CMD_OVER			;0x43-(reserved in idle)skip message
.data	IDLE_CMD_OVER			;0X44-(reserved in idle)repeat/previous message
.data	IDLE_CMD_OVER			;0x45-play memo help
.data	IDLE_COMMAND_0X46		;0X46-record memo
.data	IDLE_COMMAND_0X47		;0X47-record 2-Way 
.data	IDLE_COMMAND_0X48		;0X48-select on/off
.data	IDLE_COMMAND_0X49		;0X49-ogm select
.data	IDLE_COMMAND_0X4A		;0X4A-Play OGM
.data	IDLE_COMMAND_0X4B		;0X4B-record OGM
.data	IDLE_CMD_OVER			;0X4C-(reserved in idle)Delte playing message/OGM
.data	IDLE_COMMAND_0X4D		;0x4D-Delete all old message
.data	IDLE_CMD_OVER			;0x4E-(reserved in idle)play speed
.data	IDLE_COMMAND_0X4F		;0X4F-vol adjust(inc/dec)
.data	IDLE_COMMAND_0X50		;0X50-HF(Speakerphone)
.data	IDLE_COMMAND_0X51		;0X51-HS
.data	IDLE_COMMAND_0X52		;0X52-New phonebook(save,cid-package)
.data	IDLE_CMD_OVER			;0x53-(reserved)music play
.data	IDLE_COMMAND_0X54		;0X54-Exit
.data	IDLE_CMD_OVER			;0X55-(reserved)test command
.data	IDLE_COMMAND_0X56		;0X56-find missed call
.data	IDLE_COMMAND_0X57		;0X57
.data	IDLE_COMMAND_0X58		;0X58
.data	IDLE_COMMAND_0X59		;0X59
.data	IDLE_COMMAND_0X5A		;0X5A
.data	IDLE_COMMAND_0X5B		;0X5B
.data	IDLE_COMMAND_0X5C		;0X5C
.data	IDLE_COMMAND_0X5D		;0X5D
.data	IDLE_COMMAND_0X5E		;0X5E
.data	IDLE_COMMAND_0X5F		;0X5F
.data	IDLE_COMMAND_0X60		;0X60
.data	IDLE_COMMAND_0X61		;0X61
.data	IDLE_COMMAND_0X62		;0X62
.data	IDLE_COMMAND_0X63		;0X63
.data	IDLE_COMMAND_0X64		;0X64
.data	IDLE_COMMAND_0X65		;0X65
.data	IDLE_COMMAND_0X66		;0X66
.data	IDLE_CMD_OVER			;0X67
.data	IDLE_CMD_OVER			;0X68
.data	IDLE_CMD_OVER			;0X69
.data	IDLE_CMD_OVER			;0X6A
.data	IDLE_COMMAND_0X6B		;0X6B
.data	IDLE_CMD_OVER			;0X6C
.data	IDLE_CMD_OVER			;0X6D
.data	IDLE_CMD_OVER			;0X6E
.data	IDLE_CMD_OVER			;0X6F
.data	IDLE_CMD_OVER			;0X70
.data	IDLE_CMD_OVER			;0X71
.data	IDLE_CMD_OVER			;0X72
.data	IDLE_CMD_OVER			;0X73
.data	IDLE_CMD_OVER			;0X74
.data	IDLE_CMD_OVER			;0X75
.data	IDLE_CMD_OVER			;0X76
.data	IDLE_CMD_OVER			;0X77
.data	IDLE_CMD_OVER			;0X78
.data	IDLE_CMD_OVER			;0X79
.data	IDLE_CMD_OVER			;0X7A
.data	IDLE_CMD_OVER			;0X7B
.data	IDLE_CMD_OVER			;0X7C
.data	IDLE_CMD_OVER			;0X7D
.data	IDLE_CMD_OVER			;0X7E
.data	IDLE_COMMAND_0X7F		;0X7F
.data	IDLE_COMMAND_0X80		;0x80-----------------------------------
;-------------------------------------------------------------------------------
.END
