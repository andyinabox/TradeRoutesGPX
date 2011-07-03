import processing.serial.*;
import tomc.gpx.*;

GPX gpx;
Serial port;

// for sending messages
public static final char HEADER = '|';
public static final char ELEVATION = 'E';
public static final int maxDelay = 1000;

// 2D array
// 0 = elevation
// 1 = latitude
// 2 = longitude
float[][] points;
float maxEle, minEle;
float PAD;
float leftBound,rightBound,topBound,bottomBound;

int currentPointIndex;

int currentDelay = 0;

void setup() {
	
	size(1000, 600);
	smooth();
	
	PAD = width*.1;
	
	port = new Serial(this, Serial.list()[0], 9600);  
 
	
  //initialise the GPX object
  gpx = new GPX(this);
  // parse test.gpx from the sketch data folder
  gpx.parse("2011-07-02.gpx"); // or a URL

	points = processGPXData(gpx);
	maxEle = max(points[0]);
	minEle = min(points[0]);
	println("Max: "+maxEle);
	println("Min: "+minEle);

	// bounding box
	leftBound = PAD;
	rightBound = width-PAD;
	topBound = PAD;
	bottomBound = (height-PAD);


	currentPointIndex = 0;

	drawBackdrop();

}


void draw() {

	// print elevations
	if(currentPointIndex < points[0].length) {
		/*println(points[0][currentPointIndex]);*/
		float x = map(currentPointIndex, 0, points[0].length, leftBound, rightBound);
		float y = map(points[0][currentPointIndex], minEle, maxEle, bottomBound, topBound);
		point(x, y);
		int serialOutput = int(map(points[0][currentPointIndex], minEle, maxEle, 0, 255));
		println(serialOutput);
		sendMessage(ELEVATION, serialOutput);
		currentPointIndex++;
		delay(currentDelay);
		} else {
			currentPointIndex = 0;
			drawBackdrop();
		}
	
}


float[][] processGPXData(GPX gpx) {
	int totalPoints = 0;
	
	for (int i = 0; i < gpx.getTrackCount(); i++) {
		GPXTrack trk = gpx.getTrack(i);
		for (int j = 0; j < trk.size(); j++) {
			GPXTrackSeg trkseg = trk.getTrackSeg(j);
	    for (int k = 0; k < trkseg.size(); k++) {
				totalPoints++;
	    }
	  }
	}
	
	float[][] p = new float[3][totalPoints];
	
	int currentPoint = 0;
	
	for (int i = 0; i < gpx.getTrackCount(); i++) {
	  GPXTrack trk = gpx.getTrack(i);
	  for (int j = 0; j < trk.size(); j++) {
	    GPXTrackSeg trkseg = trk.getTrackSeg(j);
	    for (int k = 0; k < trkseg.size(); k++) {
	      GPXPoint pt = trkseg.getPoint(k);
				
				// this hack avoids the erronious zero value
				if(pt.ele != (double)0){
					p[0][currentPoint] = (float)pt.ele;
					p[1][currentPoint] = (float)pt.lat;
					p[2][currentPoint] = (float)pt.lon;
					currentPoint++;
				}
	    }
	  }
	}
	
	// if there were zero elevation points, there may be extra array values
	// check to make sure there aren't any extra spots
	// println(currentPoint);
	// println(totalPoints);
	// println(p[0].length);
	while(currentPoint < p[0].length) {
		p[0] = shorten(p[0]);
		p[1] = shorten(p[1]);
		p[2] = shorten(p[2]);
		// println(p[0].length);
	}
	
	return p;
}




void drawBackdrop() {
	background(5);
	stroke(200);
	line(leftBound, topBound, leftBound, bottomBound);
	line(leftBound, bottomBound, rightBound, bottomBound);
	line(rightBound, bottomBound, rightBound, topBound);
}

void serialEvent (Serial myPort) {
	// get the ASCII string:
	String inString = myPort.readStringUntil('\n');

	if (inString != null) {
		// trim off any whitespace:
		inString = trim(inString);
		// convert to an int and map to the screen height:
		int inByte = int(inString); 
		currentDelay = int(map(inByte, 0, 1023, 0, maxDelay));
		println("Updated delay: "+currentDelay);
	}
}

void sendMessage(char tag, int value){
  port.write(HEADER);
  port.write(tag);
  port.write(value);
}
