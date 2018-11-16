//必須利用push, pop操作stack完成postfix expression
//並將結果存進expr_result變數中 r4可看答案
//"-100 10 20 + - 10 +" = -120
//"2 3 1 + + 9 -" = -3
	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	user_stack: .zero 128 
	expr_result: .word 0

.text
	.global main
	postfix_expr: .asciz "-100 10 20 + - 10 +"

main:
	LDR R0, =postfix_expr //把題目load 到r0
	ldr sp, =user_stack //把stack之位址指向stack pointer
	add sp, sp, #128
	mov r10, #0   //neg_flag = 0
	b check  //r1=strlen
	finish_all:
		pop {r4}
		ldr r5, =expr_result
		str r4, [r5]
		b program_end


check:
	mov r2, #0  //r2=i
	loop:
		//cmp r2, r1
		//bge finish_all
		mov r3, r0  //r3=string address
		add r3, r3, r2
		ldrb r3, [r3]
		cmp r3, #32
		beq space
		cmp r3, #32
		bne not_space

		space:
			add r2, r2, #1
			b loop

		not_space:
			cmp r3, #48
			bge integer
			cmp r3, #45
			beq neg
			cmp r3 ,#43
			beq plus

		integer:
			b atoi

		neg:
			mov r3, r0
			add r2, r2, #1
			add r3, r3, r2
			ldrb r6, [r3]
			cmp r6, #48
			bge flag_set
			pop {r4, r5}
			sub r4, r5, r4
			push {r4}
			cmp r6, #0
			beq finish_all
			add r2, r2, #1
			b loop

		plus:
			mov r3, r0
			add r2, r2, #1
			add r3, r3, r2
			ldrb r6, [r3]
			pop {r4, r5}
			add r4, r4, r5
			push {r4}
			cmp r6, #0
			beq finish_all
			add r2, r2, #1
			b loop




flag_set:
	mov r10, #1
	b atoi


program_end:
	B program_end



atoi:
	mov r9, #1 //r9=i
	atoi_loop:
		mov r3, r0
		add r3, r3, r2
		add r3, r3, r9
		ldrb r3, [r3]
		cmp r3, #32
		beq compute
		add r9, r9, #1
		b atoi_loop


compute:
	mov r4, #10
	mov r7, #0
	mov r5, r9
	compute_loop:
		mov r3, r0
		add r3, r3, r9
		add r3, r3, r2
		cmp r5, #0
		beq stack
		sub r8 ,r3, r5
		ldrb r8, [r8]
		sub r8, r8, #48
		mul r7, r7, r4
		add r7, r7, r8
		sub r5, r5, #1
		b compute_loop


stack:
	cmp r10, #1
	beq negstack
	cmp r10, #0
	beq posstack

	negstack:
		mov r10, #0
		mov r5, #0
		sub r5, r5, #1
		mul r7, r7, r5
		push {r7}
		add r2, r2, r9
		add r2, r2, #1
		b loop
	posstack:
		push {r7}
		add r2, r2, r9
		add r2, r2, #1
		b loop
