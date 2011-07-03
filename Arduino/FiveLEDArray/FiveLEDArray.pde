/*
  Take a byte-based serial input and display on a range of 5 LEDs
	
	Messages are recieved in 3-byte chunks, with a header, tag, and byte value.

 */


#define HEADER		'|' // header for message
#define ELEVATION	'E' // tag identifying elevation data
#define ALL_ON	'X' // tag identifying elevation data
#define MESSAGE_BYTES	3 // total bytes in a single message

const int analogInPin = A0;  // Analog input pin that the potentiometer is attached to

const int analogOutPin1 = 3;
const int analogOutPin2 = 5;
const int analogOutPin3 = 6;
const int analogOutPin4 = 9;
const int analogOutPin5 = 10;

int outputValue1 = 0;       
int outputValue2 = 0;        
int outputValue3 = 0;       
int outputValue4 = 0;     
int outputValue5 = 0;    



void setup() { Serial.begin(9600); }

void loop() {
	
	// make sure we've recieved the entire packet
	if(Serial.available() >= MESSAGE_BYTES) {
		// check for the header
		if(Serial.read() == HEADER) {
			// grab the tag
			char tag = Serial.read();
			if(tag == ELEVATION) {
				// set the value
				int value = Serial.read();
				// Serial.print("R: ");
				// Serial.println(value);
				// Serial.println();
				// display the value using LEDs
				displayRange(value, 0, 255);
			// for debugging
			} else if (tag == ALL_ON) {
				// If 'X' character is sent, all are turned on
				writeAllLEDs(255);
			}
		}
	}

	Serial.println(analogRead(analogInPin));
	delay(10);
}

void writeAllLEDs(int value) {
	analogWrite(analogOutPin1, value);
	analogWrite(analogOutPin2, value);
	analogWrite(analogOutPin3, value);
	analogWrite(analogOutPin4, value);
	analogWrite(analogOutPin5, value);
}

void displayRange (int theValue, int lowerLimit, int upperLimit) {
	
	// essentially multiplying by 5, to make the range work with code below
	int value = map(theValue, lowerLimit, upperLimit, 0, 1275);
	
	// Serial.print("T: ");
	// Serial.println(value);
		
	// LED 1
	if(value <= 255) {
		outputValue1 = value;
	} else {
		outputValue1 = 255;
	}
	analogWrite(analogOutPin1, outputValue1);
	
	// LED 2
	if(value > 255 && value <= 510 ) {
		outputValue2 = value-255;
	} else if(value > 510) {
		outputValue2 = 255;
	} else { outputValue2 = 0; }
	analogWrite(analogOutPin2, outputValue2);
	
	// LED 3
	if(value > 510 && value <= 765 ) {
		outputValue3 = value-510;
	} else if(value > 765){
		outputValue3 = 255;
	} else { outputValue3 = 0; }
	analogWrite(analogOutPin3, outputValue3);
	
	// LED 4
	if(value > 765 && value <= 1020 ) {
		outputValue4 = value-765;
	} else if(value>1020) {
		outputValue4 = 255;
	} else {
		outputValue4 = 0	;
	}
	analogWrite(analogOutPin4, outputValue4);
	
	// LED 5
	if(value > 1020 && value <= 1275 ) {
		outputValue5 = value-1020;
	} else {
		outputValue5 = 0	;
	}
	analogWrite(analogOutPin5, outputValue5);
}
	

