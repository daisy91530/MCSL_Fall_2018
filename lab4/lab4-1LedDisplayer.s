.syntax unified
.cpu cortex-m4
.thumb
.data
	leds: .byte 0
.text
	.global main
	.equ RCC_AHB2ENR  , 0x4002104C
	.equ GPIOB_MODER  , 0x48000400
	.equ GPIOB_OTYPER , 0x48000404
	.equ GPIOB_OSPEEDR, 0x48000408
	.equ GPIOB_PUPDR  , 0x4800040C
	.equ GPIOB_ODR    , 0x48000414
	//只要每個led要亮多久
	.equ onesec, 800000 //ARM cortex-m4 : 80M Hz frequency

main:
	BL GPIO_init
	MOVS R1, #1
	LDR R0, =leds
	STRB R1, [R0]
Loop:
	//TODO: Write the display pattern into leds variable
	BL DisplayLED
	switch_left:
	mov r4, 0x0
	b goleft
	switch_right:
	mov r5, 0x0
	b goright
	B		Loop

GPIO_init:
	//TODO: Initial LED GPIO pins as output
	ldr r0, =RCC_AHB2ENR
	ldr r1, [r0]
	mov r1, 0x00000002 // 1 enables port b
	str r1, [r0]

	ldr r0, =GPIOB_MODER
	ldr r1, [r0] //initilized value 0xFFFF FEBF
	mov r1, 0xFFFFD57F
	str r1,[r0]

	//otype is default to push pull , no need to change

	//set the speed , defulat value is 0x00000000 low speed, now use high speed
	ldr r0, =GPIOB_OSPEEDR
	mov r1, 0x00002A80  //0010 1010 1000 0000
	str r1, [r0]
	//usage r2 for led data output value address in the future
	ldr r2, =GPIOB_ODR
  	BX LR

goleft:
	ldr r3, =onesec
	bl Delay
	lsl r1, r1, #1
	/*cmp r1, 0xffffff38cmp r1, 0b11111111111111111111111100111000 //leftboundary*/
 	cmp r4, #3
 	it eq
 	moveq r1,0xff3f //special case of shift logic

 	strh r1,[r2] //srote to output value

	add r4, r4, #1
	cmp r4,#4
	beq switch_right
	bne goleft
goright:
	ldr r3, =onesec
	bl Delay
	lsr r1, r1, #1
	/*cmp r1, 0xffffff38cmp r1, 0b11111111111111111111111100111000 //leftboundary*/
	strh r1,[r2] //srote to output value

	add r5, r5, #1
	cmp r5,#4
	beq switch_left
	bne goright
DisplayLED:
	//TODO: Display LED by leds
	mov r1, 0xfff3 //0000| 1111 1111 1111 0011
	strh r1, [r2] //store half byte
	BX LR
Delay:
	//TODO: Write a delay 1 sec function
	sub r3, r3, #1
	cmp r3, #0
	bne Delay
	bx lr
