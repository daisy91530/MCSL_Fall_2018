//做兩個8數字array的bubble_sort，注意要用ldrb(byte)
//越排越大 可由r0看位址 去mem找
	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	arr1: .byte 0x19, 0x34, 0x14, 0x32, 0x52, 0x23, 0x61, 0x29
	arr2: .byte 0x18, 0x17, 0x33, 0x16, 0xFA, 0x20, 0x55, 0xAC
.text
	.global main
do_sort:
//TODO
	movs r1, #7 //r1 = len-1
	movs r2, #0 //r2 = i
	sub r2, r2, #1 //r2 = i - 1
	movs r3, #0 //r3 = j
	outerloop:
		add r2, r2, #1 // 一開始i=0 i ++ 
		movs r3, #0 //j = 0
		cmp r2, r1  
		blt innerloop //i<leng - 1
		bge return
	innerloop:
		add r6, r0, r3 //r6 = arr1位址加上j
		ldrb r4, [r6] //load進r4 arr[j]
		add r6, r6, #1 
		ldrb r5, [r6] //load進r5 arr[j+1]
		cmp r4, r5
		bgt swap //arr[j]>arr[j+1]則swap
		add r3, r3, #1 //j++
		sub r7, r1, r2 //len-1 - i
		cmp r3, r7 
		blt innerloop // j<len-1-i 則繼續innerloop
		bge outerloop 
	swap:
		movs r9, r4 //arr[j] mov進r9(temp)
		movs r4, r5 //arr[j+1] mov進r4
		movs r5, r9 //r9(temp) mov進入 r5，交換完成，把值store回去，小心！
		strb r5, [r6]  //store回到a[j+1]
		sub r6, r6, #1
		strb r4, [r6] //store回到a[j]
		add r3, r3, #1 //j++;
		sub r7, r1, r2 //len-1 - i
		cmp r3, r7
		blt innerloop // j<len-1-i 則繼續innerloop
		bge outerloop
	return:
		bx lr
main:
	ldr r0, =arr1 //arr1位址ld到r0
	bl do_sort
	ldr r0, =arr2
	bl do_sort
L: b L

/***************
Void bubble_sort ( int arr[], int len)
{
	int I, j, temp;
	for( i = 0; i < len-1; i++)
		for ( j = 0; j < len -1 -i; j++)
			if ( arr[j] > arr[j+1])
			{
				temp = arr[j];
				arr[j] = arr[j+1];
				arr[j+1] = temp;
			}
}
*****************/
