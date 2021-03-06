#include "stm32l476xx.h"
#include <stdio.h>
#include <stdlib.h>
 //TODO: define your gpio pin
#define keypad_row_max 4
#define keypad_col_max 4
unsigned int keypad_value[4][4] ={{1,2,3,10},
                            {4,5,6,11},
                            {7,8,9,12},
                            {15,0,14,13}};
 /* TODO: initial keypad gpio pin, X as output and Y as input
 */
 extern void GPIO_init();
 extern void max7219_send(unsigned char address, unsigned char data);
 extern void max7219_init();
 void keypad_init()
 {
	 GPIO_init(); //have initialized in arm
	 RCC->AHB2ENR   |= 0b00000000000000000000000000000111; //safely initialize again
	 GPIOC->MODER   &= 0b11111111111111111111111100000000;
	 GPIOC->MODER   |= 0b00000000000000000000000001010101; //use pc 3210 for X output=01
     GPIOC->PUPDR   &= 0b11111111111111111111111100000000; //pull-up=01
     GPIOC->PUPDR   |= 0b00000000000000000000000001010101; //since we want 1 to be sent high level voltage
     GPIOC->OSPEEDR &= 0b11111111111111111111111100000000;
     GPIOC->OSPEEDR |= 0b00000000000000000000000001010101;
     GPIOC->ODR     |= 0b00000000000000000000000011110000;

     GPIOB->MODER   &= 0b11111111111111111111111100000000; //use pb 3210 for Y input=00
     GPIOB->PUPDR   &= 0b11111111111111111111111100000000; //pull-down =10
     GPIOB->PUPDR   |= 0b00000000000000000000000010101010; //clear and set input as pdown mode
}
int display_clr(int num_digs)
{
 	for(int i=1;i<=num_digs;i++)
 	{
 		max7219_send(i,0xF);
 	}
 	return 0;
}
 int display(int data, int num_digs)
 {
     //getting the value from LSB to MSB which is right to left
     //7 seg panel from 1 to 7 (not zero base)
     int i=0,dig=0;
     for(i=1;i<=num_digs;i++)
     {
         max7219_send(i,data%10);
         dig=data%10;
         data/=10; //get the next digit
     }
     if(data>99999999 || data<-9999999)
         return -1; //out of range error
     else
         return 0; //end this function
 }

 char keypad_scan(){
	 //if pressed , keypad return the value of that key, otherwise, return 255 for no pressed (unsigned char)
	     int keypad_row=0,keypad_col=0;
	     char key_val=-1;
	     while(1)
	     {
	         for(keypad_col=0;keypad_col<4;keypad_col++) //output data from 1st row
	         {
	             for(keypad_row=0;keypad_row<4;keypad_row++) //read input data from 1st col
	             {
	                 /*use pc 3210 for X output row
	                 use pb 3210 for Y input col*/
	             	GPIOC->ODR&=0; //clear the output value
	                 GPIOC->ODR|=(1<<keypad_col);//shift the value to send data for that row, data set
	                 int masked_value=GPIOB->IDR&0xf, is_pressed=(masked_value>>keypad_row)&1;
	                 if(is_pressed) //key is pressed
	                 {
	                     key_val=keypad_value[keypad_row][keypad_col];
	                     display(keypad_value[keypad_row][keypad_col],(key_val>=10?2:1));
	                 }
	                 else
	                 {
	                 	display_clr(2);//if not pressed, just clear the screen
	                 }
	             }
	         }
	     }
	     return key_val;
 }

 int main()
 {
     GPIO_init();
     max7219_init();
     display_clr(8);
     keypad_init();
     keypad_scan();
     return 0;
 }
