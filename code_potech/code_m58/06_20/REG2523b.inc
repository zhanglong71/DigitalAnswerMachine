
;+++++++++++++++ ACC STATUS REGISTER +++++++++++++++++++++++++++++++++++++++++
AR0             .EQU    0
AR1             .EQU    1
AR2             .EQU    2
AR3             .EQU    3
AR4             .EQU    4
AR5             .EQU    5
AR6             .EQU    6
AR7             .EQU    7

; ACC STATUS REGISTER +++++++++++++++++
B1      .EQU     0Xf
ARZ     .EQU     0Xe
SGN     .EQU     0Xd
OV      .EQU     0Xc
ACZ     .EQU     0Xb
TB      .EQU     0Xa
OVM     .EQU     0X9
;========================================
;2523 register's define

;+++++++++++++++ INTERNAL I/O PAGE 0 +++++++++++++++++++++++++++++++++++++++++
                OPTR    .EQU		0X0
                BIOR    .EQU		0X1
                IPTR    .EQU		0X2
                EXTOPTR .EQU		0X2
                XMCR    .EQU		0X3
                CTLR    .EQU		0X4
                SHFCR   .EQU		0X5
                SVR     .EQU		0X5  ;for 2519 program compatable
                IMR     .EQU		0X6
                SPR     .EQU		0X7
;+++++++++++++++ INTERNAL I/O PAGE 1 +++++++++++++++++++++++++++++++++++++++++
                WSTR    .EQU		0X0
                DSPAR   .EQU		0X1
                XMARL   .EQU		0X2
                XMARH   .EQU		0X3
                            		
                MMAC    .EQU		0X1  ;for 2519 program compatable
                MMAPL   .EQU		0X2  ;for 2519 program compatable
                MMAPH   .EQU		0X3  ;for 2519 program compatable
                            		
                RCR     .EQU		0X4
                FPRD    .EQU		0X5
                BLR     .EQU		0X6
                XMMR    .EQU		0X7
;+++++++++++++++ INTERNAL I/O PAGE 2 +++++++++++++++++++++++++++++++++++++++++
                CDRR0   .EQU		0X0
                CDXR0   .EQU		0X0
                CDRR1   .EQU		0X1
                CDXR1   .EQU		0X1
                PREGL   .EQU		0X2
                PREGH   .EQU		0X3
                PLLMR   .EQU		0X4
                TESTR   .EQU		0X5
                XMODR   .EQU		0X6
                XR      .EQU		0X7
;+++++++++++++++ INTERNAL I/O PAGE 3 +++++++++++++++++++++++++++++++++++++++++
                CDCTLR0 .EQU		0X0
                CDCTLR1 .EQU		0X1
                CDCTLR2 .EQU		0X2
                CDCTLR3 .EQU		0X3
                TPNR    .EQU		0X4

;--------------------------------------
;+++++++++++++++ acc status register +++++++++++++++++++++++++++++++++++++++++
                b1      .equ		0xf
                arz     .equ		0xe
                sgn     .equ		0xd
                ov      .equ		0xc
                acz     .equ		0xb
                tb      .equ		0xa
                ovm     .equ		0x9
;--------------------------------------
                ar0             .equ    0
                ar1             .equ    1
                ar2             .equ    2
                ar3             .equ    3
                ar4             .equ    4
                ar5             .equ    5
                ar6             .equ    6
                ar7             .equ    7
;--------------------------------------
;XMCR (I/O MAP 3):
DMA_RW  .EQU    15        ;READY_BUSY_STATUS
R_B     .EQU    7         ;READY_BUSY_STATUS
ALEHL   .EQU    6         ;SEQUENTIAL_ROM_ALEHL
PWD     .EQU    5         ;NAND_FLASH_WRITE_PROTECT0
WP      .EQU    5         ;NOR_FLASH_POWER_DOWN
ALE     .EQU    4         ;NAND_FLASH_ALE
CLE     .EQU    3         ;NAND_FLASH_CLE
CE3     .EQU    2         ;MASK_ROM_CE
CE2     .EQU    1         ;FLASH_CE2
CE1     .EQU    0         ;FLASH_CE1
;--------------------------------------
;--------------------------------------
;CTLR (I/O MAP 4):
FAST                    .EQU    0X1000
CODEC_PWDN              .EQU    0X0100
CHECKSUM                .EQU    6  ;bit 6
CODEC_READY             .EQU    9  ;bit 9

;--------------------------------------
;XMMR (I/O MAP 15)"
;--------------------------------------
ACCESS_GROUP_1_MEMORY   .EQU    0X1000
ACCESS_MASK_ROM         .EQU    0X2000
ACCESS_SEQUENTIAL_ROM   .EQU    0X3000
;GROUP 1 MEMORY TYPE
MEMTYPE_SDRAM           .EQU    0X0000
MEMTYPE_EDORAM          .EQU    0X0400
MEMTYPE_NOR_FLASH       .EQU    0X0800
MEMTYPE_NAND_FLASH      .EQU    0X0C00

SDARM_BITx04            .EQU    0x0040
SDARM_BITx08            .EQU    0x0080
SDARM_BITx16            .EQU    0x00c0

BFCNT0                  .EQU    0x0000
BFCNT1                  .EQU    0x0010
BFCNT2                  .EQU    0x0020
BFCNT3                  .EQU    0x0030

SDRAM_SIZE_16M          .EQU    0x0000
SDRAM_SIZE_64M          .EQU    0x0001
SDRAM_SIZE_128M         .EQU    0x0002
SDRAM_SIZE_256M         .EQU    0x0003
SDRAM_SIZE_512M         .EQU    0x0004
;--------------------------------------
;WSTR (I/O MAP 8):
;--------------------------------------
;--------------------------------------
;--------------------------------------
.END
