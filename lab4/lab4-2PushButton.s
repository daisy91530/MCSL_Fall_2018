/*gpio reference http://www.nimblemachines.com/stm32-gpio/*/
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

	//需要led每次亮一秒onesec，shift的間隔時間interval_cnt
	.equ onesec, 800000
	.equ interval_cnt, 200000
	/*GPIOC*/
	.equ GPIOC_MODER  , 0x48000800
	.equ GPIOC_OTYPER ,	0x48000804
	.equ GPIOC_OSPEEDR,	0x48000808
	.equ GPIOC_PUPDR  ,	0x4800080c
	.equ GPIOC_IDR    , 0x48000810
//先去gio_init設定
//再去DisplayLED設一開始最右邊亮，再跳回來
//開始switch_left，先把r9leftcounter設成0 去goleft
//[goleft]:要先delay(threshold--(r3)再去check_button)
//check_button會看button是否有按，還要處理debouncing(有按r6=1) 做完去check_end
//check_end 看threshold(r3)是否減到0，如果不是則繼續delay(threshold--再check_button)，不然就bxlr回到goleft
//goleft繼續，如果r6=0(按一次)則(跳過正常的leftshift後檢查r9是否到3 只剩左邊亮)，直接到stop_move_left
//stop_move_left (store r1回去 用r9leftcounter是否到4 轉換成右邊，若不用則跳回goleft)
//重複[goleft] 直到check_button r6=1不用停，檢查r9=4 跳去switch_right(r10當rightcounter)
main:
    BL GPIO_init //先去init
	MOVS	R1, #1
	LDR	R0, =leds
	STRB	R1, [R0] //把led 設為1
	mov r6, #1 //r6 設為1
Loop:
	BL DisplayLED //最初顯示 最右邊的led 再跳回來
	switch_left:  //往左
	mov r9, 0x0 //r9=0，再去goleft
	b goleft
	switch_right:
	mov r10, 0x0
	b goright
	B		Loop

GPIO_init:
//portb led 設moder/speeder
//portc button設 moder
	//enable the gpio port b and c to do the tasks
	ldr r0, =RCC_AHB2ENR
	mov r1, 0b110
	str r1, [r0]

	//enable the port b GPIOB_MODER for output mode
	ldr r0, =GPIOB_MODER
	ldr r1, [r0] //get originally initilized reset value 0xFFFFFEBF
	mov r1, 0xFFFFD57F
	str r1,	[r0]

	//otype is default to pp , no need to change

	//set the speed , defulat value is 0x00000000 low speed, now use high speed
	mov r1, 0x00002A80
	ldr r0, =GPIOB_OSPEEDR
	str r1, [r0]

	//enable the port c GPIOC_MODER for input mode
	ldr r0, =GPIOC_MODER
	ldr r1, [r0]
	//clear pc13 to zero
	and r1, r1, 0xf3ffffff
	str r1,	[r0]

	//otype is default to pp , no need to change


	ldr r2, =GPIOB_ODR
	ldr r4, =GPIOC_IDR //r4:button input的位址
  	BX LR
DisplayLED:
	mov r1, 0xfff3 //fff 0(3 on)011
	strh r1, [r2] //r2為led output位址
	bx lr
goleft:
	ldr r3, =interval_cnt
	mov r0, #0 //thresholdr0 先歸零
	bl delay //跳去delay, 把interval_cnt--再跳去check_botton

	cmp r6, #0 //1 move 0 stop_move_left
	beq stop_move_left

	lsl r1, r1, #1 /*cmp r1, 0xffffff38cmp r1, 0b11111111111111111111111100111000 //leftboundary*/

 	cmp r9, #3 //special case of shift logic
 	it eq
 	moveq r1,0xff3f //special case of shift logic
	add r9, r9, #1 //move_left_counter++
	stop_move_left:
 	strh r1,[r2] //store to output value

	cmp r9,#4 //cmp if need to switch direction
	beq switch_right
	bne goleft
goright:

	ldr r3, =interval_cnt
	mov r0, #0 //threshold 1000 stable 1000 secs
	bl delay

	cmp r6, #0 //1 move 0 stop_move_right
	beq stop_move_right

	lsr r1, r1, #1 /*cmp r1, 0xffffff38cmp r1, 0b11111111111111111111111111110000 //rightboundary*/

	add r10, r10, #1
	stop_move_right:
	strh r1,[r2] //srote to output value

	cmp r10,#4 //cmp if need to switch direction
	beq switch_left
	bne goright

delay:
   //TODO: Write a delay 1sec function
	sub r3, r3, #1
	b check_button
check_end:
	cmp r3, #0
	bne delay
	bx lr

check_button: //check every cycle, and accumulate 1
	ldr r7, [r4] //fetch the data from button
	lsr r7, r7, #13
	and r7, r7, 0x1 //filter the signal
	cmp r7, #0 //FUCK DONT KNOW WHY THE PRESSED SIGNAL IS 0
	it eq
	addeq r0, r0 ,#1 //accumulate until the threshold

	cmp r7, #1 //not stable, go back to accumulate again
	it eq
	moveq r0, #1

	cmp r0, #1000 //threshold achieved BREAKDOWN!
	it eq
	eoreq r6, r6, #1 //r6^=1

	b check_end

