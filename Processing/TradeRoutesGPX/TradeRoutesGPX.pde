import processing.serial.*;
import tomc.gpx.*;

GPX gpx;
Serial port;

// for sending messages
public static final char HEADER = '|';
public static final char ELEVATION = 'E';

// 2D array
// 0 = elevation
// 1 = latitude
// 2 = longitude
float[][] points;
float maxEle, minEle;
float PAD;
float leftBound,rightBound,topBound,bottomBound;

int currentPointIndex;

void setup() {
	
	size(800, 600);
	smooth();
	
	PAD = width*.1;
	
	port = new Serial(this, Serial.list()[0], 9600);  
 
	
  //initialise the GPX object
  gpx = new GPX(this);
  // parse test.gpx from the sketch data folder
  gpx.parse("2011-07-02.gpx"); // or a URL


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
	
	points = new float[3][totalPoints];
	
	int currentPoint = 0;
	
	for (int i = 0; i < gpx.getTrackCount(); i++) {
	  GPXTrack trk = gpx.getTrack(i);
	  for (int j = 0; j < trk.size(); j++) {
	    GPXTrackSeg trkseg = trk.getTrackSeg(j);
	    for (int k = 0; k < trkseg.size(); k++) {
	      GPXPoint pt = trkseg.getPoint(k);
				
				// this hack avoids the erronious zero value
				if(pt.ele != (double)0){
					points[0][currentPoint] = (float)pt.ele;
					points[1][currentPoint] = (float)pt.lat;
					points[2][currentPoint] = (float)pt.lon;
					currentPoint++;
				}
	    }
	  }
	}
	
	// if there were zero elevation points, there may be extra array values
	// check to make sure there aren't any extra spots
	println(currentPoint);
	println(totalPoints);
	println(points[0].length);
	while(currentPoint < points[0].length) {
		points[0] = shorten(points[0]);
		points[1] = shorten(points[1]);
		points[2] = shorten(points[2]);
		println(points[0].length);
	}
	
	
	
	maxEle = max(points[0]);
	minEle = min(points[0]);
	println("Max: "+maxEle);
	println("Min: "+minEle);
	

	println("Last: "+points[0][points[0].length-1]);
	
	leftBound = PAD;
	rightBound = width-PAD;
	topBound = PAD;
	bottomBound = (height-PAD);

	background(255);


	point(leftBound, topBound);
	point(leftBound, bottomBound);
	point(rightBound, topBound);
	point(rightBound, bottomBound);
	line(leftBound, topBound, leftBound, bottomBound);
	line(leftBound, bottomBound, rightBound, bottomBound);
	line(rightBound, bottomBound, rightBound, topBound);

	currentPointIndex = 0;

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
		// delay(300);
		} else {
			currentPointIndex = 0;
		}
	
}

void sendMessage(char tag, int value){
  port.write(HEADER);
  port.write(tag);
  port.write(value);
}
