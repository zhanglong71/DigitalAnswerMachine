
;��һ����ĸC��д;;;;
;---KEY---
	Ckey_0		equ	0x29
	Ckey_1		equ	0x08
	Ckey_2		equ	0x10
	Ckey_3		equ	0x18
	Ckey_4		equ	0x20
	Ckey_5		equ	0x28
	Ckey_6		equ	0x30
	Ckey_7		equ	0x01
	Ckey_8		equ	0x11
	Ckey_9		equ	0x19
	Ckey_e		equ	0x21	;'*'
	Ckey_f		equ	0x31	;'#'
	
	Ckey_edit	equ	0x34
	Ckey_time	equ	0x13
	Ckey_stop	equ	0x1c
	Ckey_rep	equ	0x0a
	
	Ckey_enter	equ	0x33
	Ckey_mute	equ	0x23
	Ckey_flash	equ	0x03
	Ckey_2way	equ	0x14
	
	Ckey_speak	equ	0x32
	Ckey_redial	equ	0x1a
	Ckey_menu	equ	0x04
	Ckey_play	equ	0x0c
	
	Ckey_sub	equ	0x2a
	Ckey_add	equ	0x22
	Ckey_del	equ	0x2b
	Ckey_book	equ	0x2c
;----������ֵ���۵�0X3f,һ��56������
	Cmsg_init	equ	0x40	;��ʼ��
	Cmsg_exit	equ	0x41
	
	Cmsg_hookup	equ	0x50	;����
	Cmsg_hookdown	equ	0x51	;����
	
;-------
	Ctmr_sec	equ	0x60	;��
	Ctmr_min	equ	0x61	;��
	Ctmr_day	equ	0x62	;��
	Ctmr_timer	equ	0x63	;��ʱ��
;-------
	CMSG_TMR	equ	0x64	;��ʱ��
	CMSG_BLINK	equ	0x65	;ʱ����˸
	
	
	Cmsg_dtmf	equ	0x71	;dtmfֹͣ��Ϣ
	Cmsg_dtmf_end	equ	0x72
	Cmsg_fsk	equ	0x73
;-------------------------------------------------------------------------------