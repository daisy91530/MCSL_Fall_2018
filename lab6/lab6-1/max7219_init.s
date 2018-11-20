	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	arr: .byte 0x0, 0x5, 0x1, 0x6, 0x0, 0x5, 0x9

.text
.global GPIO_init
.global max7219_send
.global max7219_init
	//GPIO
	.equ	RCC_AHB2ENR,	0x4002104C
	.equ	GPIOA_MODER,	0x48000000
	.equ	GPIOA_OTYPER,	0x48000004
	.equ	GPIOA_OSPEEDER,	0x48000008
	.equ	GPIOA_PUPDR,	0x4800000C
	.equ	GPIOA_IDR,		0x48000010
	.equ	GPIOA_ODR,		0x48000014  //PA5 6 7 output mode
	.equ	GPIOA_BSRR,		0x48000018 //set bit -> 1
	.equ	GPIOA_BRR,		0x48000028 //clear bit -> 0

	//Din, CS, CLK offset
	.equ 	DIN,	0b100000 	//PA5
	.equ	CS,		0b1000000	//PA6
	.equ	CLK,	0b10000000	//PA7

	//max7219
	.equ	DECODE,			0x19 //decode control
	.equ	INTENSITY,		0x1A //brightness
	.equ	SCAN_LIMIT,		0x1B //how many digits to display
	.equ	SHUT_DOWN,		0x1C //shut down -- we did't use this
	.equ	DISPLAY_TEST,	0x1F //display test -- we did' use this

	//timer
	.equ	one_sec,		1000000 //try and error

max7219_init:
	//TODO: Initialize max7219 registers
	push {r0, r1, LR}
	ldr r0, =DECODE
	ldr r1, =0xFF
	bl max7219_send

	ldr r0, =DISPLAY_TEST
	ldr r1, =0x0 //normal operation
	bl max7219_send

	ldr r0, =INTENSITY
	ldr r1, =0xA // 21/32 (brightness)
	bl max7219_send

	ldr r0, =SCAN_LIMIT
	ldr r1, =0x6
	bl max7219_send

	ldr r0, =SHUT_DOWN
	ldr r1, =0x1 //normal operation
	bl max7219_send

	pop {r0, r1, PC}
	BX LR
