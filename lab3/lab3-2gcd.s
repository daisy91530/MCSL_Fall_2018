//0x5e, 0x60 = 2(r5, gcd), 12(r0, max stack size)
//0x39, 0x260 = 19, 7
	.syntax unified
	.cpu cortex-m4
	.thumb
.data
   result: .word  0
   max_size:  .word  0
.text
   m: .word  0x39 //94
   n: .word  0x260 //96
   .global main

main:
	ldr r0, m
	ldr r1, n
	push {r0, r1} //stack bottom->m->n
	mov r6, #0
	mov r5, #0
	bl GCD
	//r4 = result, r5 = max_size, r6 = <<n times
	lsl r4, r6 //shift left
	ldr r0, =result
	ldr r1, =max_size
	str r4, [r0]
	str r5, [r1]
L: B L

GCD:
	//
	pop {r1, r0} //r1=n, r0=m
	push {lr}
	// if m == n, return m
	cmp r1, r0
	beq return_m
	// if m == 0, return n
	cmp r0, #0
	beq return_n
	// if n == 0 , return m
	cmp r1, #0
	beq return_m
	// if m is even ( and one == 0 is even )
	and r3, r0, #1
	cmp r3, #0
	bne m_odd
	and r3, r1, #1
	cmp r3, #0
	bne m_even_n_odd //m is even, n is odd
	b both_even      //m, n both even
	compare_greater:
		// if m > n
		cmp r0, r1
		bgt m_greater
		//else m < n
		b n_greater

m_odd:
	and r3, r1, #1
	cmp r3, #0
	beq m_odd_n_even
	//m, n both odd
	b compare_greater
m_even_n_odd:
	//gcd(m>>1, n)
	lsr r0, #1
	b recursive
m_odd_n_even:
	//gcd(m,n>>1)
	lsr r1, #1
	b recursive
both_even:
	//gcd(m>>1, n>>1)<<1
	lsr r0, #1
	lsr r1, #1
	add r6, r6, #1 //r6=shift left n times
	b recursive
return_m:
	mov r4, r0
	bx lr
return_n:
	mov r4, r1
	bx lr
m_greater:
	//gcd((m-n)>>1,n)
	sub r0, r0, r1 // m-n
	lsr r0, #1 // (m-n)>>1
	b recursive
n_greater:
 	//gcd(m,(n-m)>>1)
	sub r1, r1, r0 //n-m
	lsr r1, #1 //logical shift right, (n-m)>>1
	b recursive
recursive:
	//
	push {r0, r1}
	bl GCD
	add r5, r5, #1 //stack size ++
	pop {lr}
	bx lr
