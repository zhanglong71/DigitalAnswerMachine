.NOLIST
AR0	.EQU	0
AR1	.EQU	1
AR2	.EQU	2
AR3	.EQU	3
AR4	.EQU	4
AR5	.EQU	5
AR6	.EQU	6
AR7	.EQU	7

ar0	.EQU	0
ar1	.EQU	1
ar2	.EQU	2
ar3	.EQU	3
ar4	.EQU	4
ar5	.EQU	5
ar6	.EQU	6
ar7	.EQU	7

DAM_BIOS  	.EQU   		0X10
; ---------------------------- branch define -------------------------
B1	.EQU	0X0F
ARZ	.EQU	0X0E
SGN	.EQU	0X0D
OV	.EQU	0X0C
ACZ	.EQU	0X0B
TB	.EQU	0X0A
OVM	.EQU	0X09

b1	.EQU	0X0F
arz	.EQU	0X0E
sgn	.EQU	0X0D
ov	.EQU	0X0C
acz	.EQU	0X0B
tb	.EQU	0X0A
ovm	.EQU	0X09
;----------------------------- io define -----------------------------
;-------page 0
CTLR1		.EQU	0X01	;0x0 = 0
SHFCR		.EQU	0X04	;0x4 = 4
;-------page 1
RCR		.EQU	0X00	;0x8 = 8
MODR		.EQU	0X01	;0x9 = 9
XR		.EQU	0X02	;0xa = 10
SPR		.EQU	0X03	;0xb = 11
PRODLR		.EQU	0X04	;0xc = 12
PRODHR		.EQU	0X05	;0xd = 13
;-------page 4
SPID0		.EQU	0X00	;0x20 = 32
SPID1		.EQU	0X01	;0x21 = 33
SPID2		.EQU	0X02	;0x22 =  34
SPIFWC		.EQU	0X03	;0x23 =  35
SPIFMA		.EQU	0X04	;0x24 =  36
SPIFST		.EQU	0X05	;0x25 =  37
SPIFSD1		.EQU	0X06	;0x26 =  38
SPIFSD2		.EQU	0X07	;0x27 =  39
;-------page 5
IICCR		.EQU	0X00	;0x28 = 40
IICSR		.EQU	0X01	;0x29 = 41
IICDR		.EQU	0X02	;0x2a = 42
IICAR		.EQU	0X03	;0x2b = 43
IICTR		.EQU	0X04	;0x2c = 44
IICPW		.EQU	0X05	;0x2d = 45
;-------page 6
ANAPWR		.EQU	0X00	;0x30 = 48
AGC		.EQU	0X01	;0x31 = 49
LOUTSPK		.EQU	0X02	;0x32 = 50
MUTE		.EQU	0X03	;0x33 = 51
SWITCH		.EQU	0X04	;0x34 = 52
SYSCLK		.EQU	0X05	;0x35 = 53
WDTFSS		.EQU	0X06	;0x36 = 54
WDTCTL		.EQU	0X07	;0x37 = 55
;-------page 7
DACDL		.EQU	0X00	;0x38 = 56
DACDS		.EQU	0X01	;0x39 = 57
ADCDL		.EQU	0X02	;0x3a = 58
ADCDM		.EQU	0X03	;0x3b = 59
DSPINTEN	.EQU	0X04	;0x3c = 60
;-------page 8
GPAD		.EQU	0X00	;0x40 = 64
GPAC		.EQU	0X01	;0x41 = 65
GPBD		.EQU	0X02	;0x42 = 66
GPBC		.EQU	0X03	;0x43 = 67
GPAIEN		.EQU	0X04	;0x44 = 68
GPAITP		.EQU	0X05	;0x45 = 69
GPAIF		.EQU	0X06	;0x46 = 70
GPBIEN		.EQU	0X07	;0x47 = 71
;-------page 9
GPBITP		.EQU	0X00	;0x48 = 72
GPBIF		.EQU	0X01	;0x49 = 73
RTCMS		.EQU	0X02	;0x4a = 74
RTCWH		.EQU	0X03	;0x4b = 75
RTCMD		.EQU	0X04	;0x4c = 76
RTCCY		.EQU	0X05	;0x4d = 77
;-------page 10
OPMOD		.EQU	0X00	;0x50 = 80
;DEBUG_IF_REG    .EQU    0x01    ;0x51 = 81
;-------page 19
DPR		.EQU	0X01	; 153
PCR		.EQU	0X02	; 154
ACCLR		.EQU	0X03	; 155
ACCHR		.EQU	0X04	; 156
SSR		.EQU	0X05	; 157
;-------page 20
; AR0~AR7
;-------------------------------------------------------------------------------

;--------------------------------------

.END

