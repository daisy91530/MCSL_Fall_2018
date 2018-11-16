// calc the hamming distance of two half-word(2byte), store the ans to "result"
//xor two num，look how many 1
//test case 39, 125 = 4
//test case 0x1000, 0x3f = 7
	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	result: .byte 0
.text
	.global main
	.equ X, 39 //declare half-word
	.equ Y, 125
hamm:
//TODO				//xor:same = 0, different = 1
	eor R0, R0, R1 //x exor y = r0
	add R4, R0, #0 //使R4放X eor Y 之值，也就是n
					//開始while(n)
	loop:
		cmp R4, #0 //把結果跟0比較
		beq return //如果一樣，則return回去bx lr
		//結果n 不為0的話
		movs R6, #1 //把R6 mov 為 1
		and R6, R4, R6 //結果跟1 and 放入R6，可得到最後1bit是否是1
		add R3, R3, R6 //加起來，若為1代表hamm distance++ 放入R3之後可以store回[r2]

		lsr R4, R4, #1 //n >> 1 leftshift
		b loop //回去while(n)
	return:
		bx lr
main:
	movs R0, #X //mov x's value to R0
	movs R1, #Y //  Y          R1 
	ldr R2, =result //load result's addr to R2
	ldr R3, [R2] //r3 result's value
	bl hamm
	str R3, [R2] //store r3 back to result's addr
L: b L
