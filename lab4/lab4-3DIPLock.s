.syntax unified
.cpu cortex-m4
.thumb

.data
	leds: .byte 0
	password: .byte 0b1100 //1down 2down 3up 4up correct
.text
	/********GPIO Address data
	A 0x4800 0000 E 0x4800 1000
	B 0x4800 0400 F 0x4800 1400
	C 0x4800 0800 G 0x4800 1800
	D 0x4800 0C00 H 0x4800 1C00
	*****************************/
	.global main
	.equ RCC_AHB2ENR  , 0x4002104C //位址就是這個
	.equ GPIOB_MODER  , 0x48000400 //00
	.equ GPIOB_OTYPER , 0x48000404
	.equ GPIOB_OSPEEDR, 0x48000408
	.equ GPIOB_PUPDR  , 0x4800040C
	.equ GPIOB_ODR    , 0x48000414 //ODR 14

	//只要quarter_sec 每次亮跟暗多久(四分之一秒)
	.equ quarter_sec  , 250000

	//dip input C 0x4800 0800
	.equ GPIOC_MODER  , 0x48000800
	.equ GPIOC_OTYPER ,	0x48000804
	.equ GPIOC_OSPEEDR,	0x48000808
	.equ GPIOC_PUPDR  ,	0x4800080C
	.equ GPIOC_IDR    , 0x48000810 //IDR 10
	.equ LED_ALLON    , 0xff87 //1111 1111 1000 0111 (3-6開著)
	.equ LED_ALLOFF	  , 0xffff //全都1代表關
main:
    BL GPIO_init
	MOVS	R1, #1 //r1變成1
	LDR	R0, =leds //data led的位址load到r0
	STRB	R1, [R0] //把r1 store回[r0]
	mov r6, #0 //r6變成0
	ldr r1, =LED_ALLOFF //equ 的位址load到r1
	strh r1, [r2] //把r1(ledallof的位址) store到[r2] 讓開始led全暗
	mov r0, #0 //r0變成0 threshold init =0
	b Loop
//每次先看check_button有沒有按，threshold到1000後, r6 = 1設成有按
//再去check_end，如果有按(r6==1)則才要去check_lock看dip數值
//check_lock把dip數值讀進來，跟password一樣亮三下(led_blink_three)，不然一下
//led_blink_three中，每次亮 去delay_quarter_sec延遲一下 最後再去blink_end
//blink_end歸零r6，重新設沒有按，再回到loop重來
Loop:
	//每次都先check有沒有被按
	b check_button
check_end:
	cmp r6, #1 //若有被按，則r6==1，才要去check_lock看dip數值
	beq check_lock

blink_end:
	mov r6, #0 //r6再次歸零，再回到loop重來
	B		Loop

GPIO_init:
//portB led 設moder/high speed
//portC dip, button 設moder/pullup

	//enable gpio port ABC
	ldr r0, =RCC_AHB2ENR
	mov r1, 0b111 //cba
	str r1, [r0]


	//GPIOB_MODER port3-6設成output01 => input00, output01
	ldr r0, =GPIOB_MODER //把位址load到r0
	ldr r1, [r0] //用r1存取r0位址的值
	mov r1, 0xFFFFD57F //FFFF 11(01 0101 01)11 1111
	str r1,	[r0] //r1 store回去位址

	//otype default output pushpull(0) , no need to change(open-drain 1)

	//defulat 0x00000000 low speed(00), portb3-6改成high speed(10)
	mov r1, 0x00002A80 //0x0000 00(10 1010 10)00 0000
	ldr r0, =GPIOB_OSPEEDR
	str r1, [r0]

	//GPIOC_MODER 設成input(00), output(01)
	ldr r0, =GPIOC_MODER
	ldr r1, [r0]
	ldr r1, =0xf3ff00ff //0x1111 (00 c13是button)11 ff (0000 0000 c4-7接dip) ff
	str r1,	[r0]

	//otype default output pushpull(0) , no need to change(open-drain 1)

	//portc接dip，PUPDR設成pull-up(01)。 pulldown(10) ????
	ldr  r1, =GPIOC_PUPDR
	ldr  r0, [r1]
	ldr  r2, =0b01010101
	and  r0, 0xFFFFFF00 //default 0x0000 0000
	orr  r0, r2
	str  r0, [r1]

	ldr r2, =GPIOB_ODR //r2存output led 位址
	ldr r4, =GPIOC_IDR //r4存button的input 位址
	ldr r8, =GPIOC_IDR //r8存DIP的input 位址
	ldr r7, [r8] //r7可以存取dip input的值
  	BX LR

check_button: //loop每次都先check_button，看有否被按
	ldr r5, [r4] //r4存button input 位址
	lsr r5, r5, #13 //把button的值left shift 13
	and r5, r5, 0x1 //且bit mask，使其跟1 and
	cmp r5, #0 //如果有按，則值為0
	it eq
	addeq r0, r0 ,#1 //如果回傳值為0，則threshold++

	cmp r5, #1
	it eq
	moveq r0, #0 //若回傳值1，則重新累計threshold(init=0)，debouncing

	cmp r0, #1000//若threshold變成1000，則r6設成有按按鈕(1)
	it eq
	moveq r6, #1 //r6 0 not pressed, 1 pressed

	b check_end

check_lock:
	ldr  r7, [r8] //用dip input位址, 把值再次load到r7
	and  r7, 0xf0 //1111(7-4)0000
	lsr  r7, #4  //left shift四格 到最低位
	ldr  r9, =password
	ldrb r9, [r9]

	cmp r7, r9 //看dip的值跟password一不一樣
	beq led_blink_three //一樣亮三下
	b led_blink_once //不一樣一下

led_blink_three:
	ldr r1, =LED_ALLON//ff|1000|0111|
	strh r1, [r2] //store進[r2]，r2存output led 位址
	ldr r3, =quarter_sec //把r3設成四分之一秒，進入delay
	bl delay_quarter_sec

	ldr r1, =LED_ALLOFF //ff|1111|1111|
	strh r1, [r2]
	ldr r3, =quarter_sec
	bl delay_quarter_sec

	ldr r1, =LED_ALLON
	strh r1, [r2]
	ldr r3, =quarter_sec
	bl delay_quarter_sec

	ldr r1, =LED_ALLOFF
	strh r1, [r2]
	ldr r3, =quarter_sec
	bl delay_quarter_sec

	ldr r1, =LED_ALLON
	strh r1, [r2]
	ldr r3, =quarter_sec
	bl delay_quarter_sec

	ldr r1, =LED_ALLOFF
	strh r1, [r2]
	ldr r3, =quarter_sec
	bl delay_quarter_sec
	b blink_end //r6歸零(沒有按按鈕)，再回到loop重來

led_blink_once:
	ldr r1, =LED_ALLON //ff|1000|0111|
	strh r1, [r2]
	ldr r3, =quarter_sec
	bl delay_quarter_sec

	ldr r1, =LED_ALLOFF  //ff|1111|1111|
	strh r1, [r2]

	b blink_end

delay_quarter_sec: //每次都把r3減一，直到跟0一樣就跳回去
	subs r3, r3, #1
	cmp r3, #0
	bne delay_quarter_sec
	bx lr
