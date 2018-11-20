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

GPIO_init:
	 //enable gpioa clock
    /*   ldr r0, =#RCC_BASE
       ldr r1, =#AHB2ENR_OFFSET
       ldr r2, =#RCC_AHB2ENR_GPIOAEN
       ldr r3, [r0, r1]//r3 = RCC->AHB2ENR
       orr r3, r3, r2
       str r3, [r0,r1]
       ldr r4, [r0,r1]
       and r4, r4, r2
       ldr r0, =#GPIO_PIN_MASK
       mvn r0, r0
       ldr r1, =#GPIOA_BASE*/

	//enable GPIO port A
	ldr r0, =RCC_AHB2ENR
	mov r1, 0b1
	str r1, [r0]

	//enable GPIO PA7,6,5 for output mode=01
	ldr r0, =GPIOA_MODER
	ldr r2, =0xABFF57FF  //0xFFFF 01 01 01 (765) 11 FF
	str r2, [r0]

	//GPIOA_OTYPER: push-pull (reset state)

	//default low speed, set to high speed=10
	ldr r0, =GPIOA_OSPEEDER
	ldr r1, =0x0000A800 //1010 10(765)00 00
	str r1, [r0]

	BX LR
