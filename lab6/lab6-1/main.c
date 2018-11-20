#include <stdio.h>
#include <stdlib.h>
//These functions inside the asm file
extern void GPIO_init();
extern void max7219_init();
extern void max7219_send(unsigned char address, unsigned char data);
/**
* TODO: Show data on 7-seg via max7219_send
* Input:
* data: decimal value
* num_digs: number of digits will show on 7-seg
* Return:
*  0: success
* -1: illegal data range(out of 8 digits range) */
int display(int data, int num_digs)
{
	int i=0, tmp;
	for(i=1;i<=num_digs;i++){
		max7219_send(i, data%10);//send last number
		tmp = data%10;
		data = data/10;
		if(i == num_digs){
			max7219_send(i, 0);//send 0
		}
	}
	if(data>99999999 || data<-9999999){//out of range
		return -1;
	}else{
		return 0;
	}
}
int display_clear(int num_digs)
{
	for(int i=1;i<=num_digs;i++)
	{
		max7219_send(i,0xF);
	}
	return 0;
}

int main()
{
   int student_id = 516059;
   GPIO_init();
   max7219_init();
   //display_clear(8);
   display(student_id, 7);
   return 0;
}
