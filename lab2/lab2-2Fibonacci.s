//計算Fib(N), 1<=N<=100, 若fib(N)overflow回傳-2, N超過範圍回傳-1
//test case f(46) = 1836311903
//test case f(47) = -2
//test case f(200) = -1
//test case f(12) = 144
//不能加上前面的 會錯
.text
	.global main
	.equ N, 12
fib:
//TODO
	cmp R0, #100 //如果Ｎ不在範圍內 則return -1
	bgt outofrange
	cmp R0, #0  
	blt outofrange
	cmp R0, #1 //若N為1, 2則設定初始值
	beq oneortwo
	cmp R0, #2
	beq oneortwo
	loop:     
		adds R1, R1, R2 //R1+R2放到R1
		bvs overflow  //bvs:branch if overflow
		add R4, R1, #0  //剛剛的答案R1值移到R4
		sub R0, R0, #1  //N--
		cmp R0, #2	//因從F3開始比
		beq return //如果一樣則直接return


		adds R2, R1, R2 //R1+R2放到R2
		bvs overflow
		add R4, R2, #0 //剛剛的答案R2值移到R4
		sub R0, R0, #1 //N--
		cmp R0, #2
		beq return
		b loop
	return:
		bx lr

	outofrange: //return -1
		movs R4, #0 //把0mov進r4
		sub R4, R4, #1 //變成-1
		b return 
	oneortwo:   //return 1
		movs R4, #1
		b return
	overflow:   //return -2
		movs R4, #0
		sub R4, R4, #2
		b return
main:
	movs R0, #N //用equ宣告要用#取值，mov到R0
	movs R1, #1 //用mov將R1設為1
	movs R2, #1 
	bl fib      
L: b L
