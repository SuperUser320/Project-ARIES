/////////////////////
// LIBRARY IMPORTS //
/////////////////////
import processing.net.*;  // Network lib
import ipcapture.*;       // MJPEG lib

///////////////////////////
// OBJECT INSTANTIATIONS //
///////////////////////////
// CAMERAS
IPCapture camA;
IPCapture camB;

// GUI ELEMENTS
Button stateToggle;

////////////////////
// PORT CONSTANTS //
////////////////////
final String ip = "192.168.1.131";
//final String ip = "10.2.45.3";
final int comPort = 8990;
final int camPortA = 8090;
final int camPortB = 8091;
final String camUrl = "/?action=stream.mjpg";
//////////////////////////
// CONNECTION VARIABLES //
//////////////////////////
Client c;
int data[];
int connectTime = 0;

///////////////////
// GUI VARIABLES //
///////////////////
final byte imageScale = 1;
final byte imgBorder = 10; // 10 pixels

///////////////////////
// CONTROL VARIABLES //
///////////////////////
int speed;  // (-100, 100)
int turn;   // (-100, 100)

void setup() 
{
  // Setup window
  size(1000, 650);
  background(49);
  frameRate(20);

  // Connect to com port
  c = new Client(this, ip, comPort);
  // Connect to cameras
  camA = new IPCapture(this, "http://" + ip + ":" + camPortA + camUrl, "", "");
  camB = new IPCapture(this, "http://" + ip + ":" + camPortB + camUrl, "", "");
  // Start camera streams
  camA.start();
  camB.start();

  ////////////////////////////////////
  // GUI elements
  stateToggle = new Button(100, 400, 200, 50, "Disabled", "Enabled", true);
}

void draw() 
{
  updateKeys();
  updateGui();
  drawCameras();
  
  int time = millis() - connectTime;
  if (time > 100) {
    println(time);
    sendData();
    getData();
  }
  if (time > 1000) {
    delay(1000);
    rebindSocket();
  }
}

////////////////////////
// Draw Cameras
void drawCameras() {
  // Draw background box
  noStroke();
  fill(100);
  rect(0, 0, camA.width + camB.width + camB.width + imgBorder * 4, camA.height + imgBorder * 2);
  // Draw MJPEG streams
  if (camA.isAvailable()) {
    camA.read();
  }
  image(camA, imgBorder, imgBorder, camA.width * imageScale, camA.height * imageScale);

  if (camB.isAvailable()) {
    camB.read();
  }
  image(camB, camA.width * imageScale + imgBorder * 2, imgBorder, camB.width * imageScale, camB.height * imageScale);

  // Draw disparity map
  if (true) {
    fill(255);
    rect((camA.width * imageScale) + (camB.width * imageScale) + imgBorder * 3, imgBorder, camA.width, camA.height);
  }
}

////////////////////////
// Network Operations
void rebindSocket() {
  c.stop();
  c = new Client(this, ip, comPort);
}

void sendData() {
  /*if (stateToggle.getState())
    c.write("0,1:");
  else
    c.write("0,0:"); 
  */
  c.write("0,0:" + "1," + nf(turn, 3) + ":" + "2," + nf(speed, 3) + ":");
}

void getData() {
  if (c.available() > 0) {
    fill(50);
    noStroke();
    rect(100, 500, 200, -20);
    fill(255);
    text(c.readString(), 100, 500);
    rebindSocket();
    connectTime = millis();
  }
}

////////////////////////
// GUI Operations
void updateGui() {
  stateToggle.update();
  if (stateToggle.buttonPressed()) stateToggle.toggle();
}
