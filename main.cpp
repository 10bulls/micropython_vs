#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <Arduino.h>

extern "C" {
int py_main(void);
}

int main(void) {

	pinMode(LED_BUILTIN,OUTPUT);

	delay(1000);

	Serial.begin(115200);

	for(int i=0; i<50;i++)
	{
		delay(50);

		digitalWrite(LED_BUILTIN,1);
		// printf("ON\n");
		Serial.println("ON");
// 		Serial.write('O');

		delay(50);

		digitalWrite(LED_BUILTIN,0);
//		printf("OFF\n");

	}

	py_main();

	return 0;
}