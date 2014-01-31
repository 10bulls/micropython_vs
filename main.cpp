#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <Arduino.h>

int main(void) {

	pinMode(LED_BUILTIN,OUTPUT);

	delay(1000);

	for(;;)
	{
		delay(1000);

		digitalWrite(LED_BUILTIN,1);
		// printf("ON\n");
		Serial.printf("ON\n");

		delay(1000);

		digitalWrite(LED_BUILTIN,0);
//		printf("OFF\n");

	}


	/*
	for(;;)
	{
		delay(50);

		digitalWrite(LED_BUILTIN,1);

		delay(50);

		digitalWrite(LED_BUILTIN,0);
	

	}
	*/

	return 0;
}