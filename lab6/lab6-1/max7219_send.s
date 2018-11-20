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

max7219_send:
	push {r0, r1, r2, r3, r4, r5, r6, r7, LR}
	lsl r0, r0, #8
	add r0, r0, r1
	ldr r1, =DIN
	ldr r2, =CS
	ldr r3, =CLK
	ldr r4, =GPIOA_BSRR
	ldr r5, =GPIOA_BRR
	ldr r6, =0xF

send_loop:
	mov r7, #1
	lsl r7, r7, r6
	str r3, [r5]
	tst r0, r7
	beq bit_not_set
	str r1, [r4]
	b if_done

bit_not_set:
	str r1, [r5]

if_done:
	str r3, [r4]
	sub r6, r6, #1
	cmp r6, 0
	bge send_loop
	str r2, [r5]
	str r2, [r4]
	pop {r0, r1, r2, r3, r4, r5, r6, r7, PC}
	bx lr
