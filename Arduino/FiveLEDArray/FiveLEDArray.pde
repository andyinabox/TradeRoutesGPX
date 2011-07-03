/*
  Take a byte-based serial input and display on a range of 5 LEDs
 */

// These constants won't change.  They're used to give names
// to the pins used:
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

char buff[]= "0000000000";
int masterValue;

void setup() {
  // initialize serial communications at 9600 bps:
  Serial.begin(9600); 
	masterValue = 0;
}

void loop() {
	// Serial.println(masterValue);
	displayRange(masterValue, -128, 127);
	
	//wait for serial communication
	while(Serial.available()>0) {
		for (int i=0; i<10; i++) {
     buff[i]=buff[i+1];
    }
		buff[10] = Serial.read();
		masterValue = int(buff[10]);
	}
	
	delay(100);
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
	int value = map(theValue, lowerLimit, upperLimit, 0, 2275);
	
	Serial.println(theValue);
	Serial.println(value);
	
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
	

