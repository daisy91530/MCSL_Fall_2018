	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	X: .word 5. //因長度須為4byte因此使用word
	Y: .word 10
	Z: .word 0
.text
	.global main
main:
	ldr r1, =X //把X的位址存到r1
	ldr r2, [r1] //再用r2來存放X的值
	ldr r3, =Y
	ldr r4, [r3]
	ldr r5, =Z
	ldr r6, [r5]
	movs r7, #10 //r7則是用來存放常數10的暫存器
	muls r2, r2, r7 
	adds r2, r2, r4
	subs r6, r4, r2
	str r2, [r1]
	str r6, [r5]
L: B L
