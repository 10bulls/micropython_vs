#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include <Arduino.h>

#include <HardwareSerial.h>

#include <QTRSensors.h>
#include <ZumoReflectanceSensorArray.h>


unsigned char sensorPins[] = { A7, A3, A8, A0, A2, 6 };

ZumoReflectanceSensorArray reflectanceSensors;
// Define an array for holding sensor values.
#define NUM_SENSORS 6
unsigned int sensorValues[NUM_SENSORS];


extern "C" 
{
int py_main(void);
}

char write_buff[30];

void reflectance_test()
{
	reflectanceSensors.read(sensorValues);
	for (byte i = 0; i < NUM_SENSORS; i++)
    {
//		sensorValues[i] = i+1;
		Serial3.print( sensorValues[i] );
//		Serial3.print(ultoa((unsigned long)sensorValues[i], write_buff, 10));
		Serial3.print( " " );
	}
	Serial3.println( " " );
}


void malloc_test()
{
	Serial3.print("malloc...");
	char * m = (char*)malloc(10);

	if (m)
	{
		Serial3.println("OK");
		free(m);
	}
	else
	{
		Serial3.println("FAIL");
	}
}

#define RAM_START (0x1FFF8000) // fixed for chip
#define HEAP_END  (0x20006000) // tunable
#define RAM_END   (0x20008000) // fixed for chip

extern "C" {
	extern uint32_t _heap_start;
	void gc_init(void *start, void *end);
}

int main(void) 
{
	pinMode(LED_BUILTIN,OUTPUT);

	gc_init(&_heap_start, (void*)HEAP_END);

	Serial.begin(115200);
	Serial3.begin(115200);



	delay(200);

	malloc_test();

	reflectanceSensors.init(sensorPins, sizeof(sensorPins), 2000, QTR_NO_EMITTER_PIN );

//	for(int i=0; i<50;i++)
	for(int i=0; i<1000;i++)
	{
		delay(50);

		digitalWrite(LED_BUILTIN,1);
		// printf("ON\n");
		Serial.println("ON");
		Serial3.println("ON");
// 		Serial.write('O');

		reflectance_test();

		delay(1000);

		digitalWrite(LED_BUILTIN,0);
//		printf("OFF\n");

	}

	// py_main();

	return 0;
}