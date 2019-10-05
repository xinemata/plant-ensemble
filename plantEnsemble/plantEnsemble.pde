import processing.sound.*;
import processing.io.*;
MPR121 touch; // define MPR121 I2C capacitive touch sensor

// Create 5 Sine wave oscillators (1 for each electrode that acts as a separate key)
SinOsc sinOsc[] = new SinOsc[5];
SqrOsc sqrOsc[] = new SqrOsc[5];
TriOsc triOsc[] = new TriOsc[5];

// This is used for switching between oscillators: 0 - Sine, 1 - Square, 2 - Triangle oscillator
int currentMode;

// volume control
float[] volumeLevels = {0.5, 0.75, 1.0}; // possible volume levels to switch between
int currentVolumeIndex = 0;
float currentVolume = 1.0;

// pitch control
float pitchDelta = 0; 
float frequencyMultiplier = 1.0;

// Plant light animation
float cube = 2.8; 
float speed = 1;

void setup(){
  size(500,500); 
  touch = new MPR121("i2c-1", 0x5a); // Read capacitive touch from MPR121 using its default address

// initialize arrays of oscillators
  for (int i=0; i < 5; i++) {
    sinOsc[i] = new SinOsc(this);
    sqrOsc[i] = new SqrOsc(this);
    triOsc[i] = new TriOsc(this);
  }

  currentMode = 0; // set the default oscillator to Sine
  //currentMode = 1; // uncomment this to set the default oscillator to Square
  //currentMode = 2; // uncomment this to set the default oscillator to Triangle
}

void draw(){
  
  touch.update(); // get readings from the MPR121 I2C sensor
  
  //float frequency0 = map(touch.analogRead(0), 0, 200, 100.0, 1000.0);
  //float frequency1 = map(touch.analogRead(1), 0, 200, 100.0, 1000.0);
  
  // When pin 9 is not touched, don't modify the pitch
  if (!touch.touched(0)) {
    pitchDelta = 0;
  }

  // When pin 9 is touched, modify the pitch in proportion to analogRead() value
  if (touch.touched(0)) {
    pitchDelta = touch.analogRead(0) * 20;
  }
  
  // Don't modify frequency multiplier if pin 11 is not touched
  if (!touch.touched(1)) {
    frequencyMultiplier = 1.0;
  }
  
  // Increase frequency multiplier when pin 11 is touched
  if (touch.touched(1)) {
    frequencyMultiplier = 3.0; // Feel free to change this value
  }
  
  for (int i=0; i < 5; i++) {
    if (!touch.touched(i)) {
      stopNote(i);
    }
    if (touch.touched(i)) {
      if (i == 1) { 
        playNote(i, touch.analogRead(0));
      } 

      if (i == 3) { 
        // Update the circle state
        playNote(i, 700);
      }

      if (i == 4) { 
        playNote(i, 340);
      }

      if (i == 2) { 
        playNote(i, 490);
      }

      if (i == 0) { 
        playNote(i, 600);
      }
    }
  }
  
}
   
void playNote(int index, int frequency) {
  switch(currentMode) {
  case 0: 
    sinOsc[index].play(frequency * frequencyMultiplier + pitchDelta, currentVolume);
    break;
  case 1: 
    sqrOsc[index].play(frequency * frequencyMultiplier + pitchDelta, currentVolume);
    break;
  case 2:
    triOsc[index].play(frequency * frequencyMultiplier + pitchDelta, currentVolume);
    break;
  }
}  

// Stop playing the note
void stopNote(int index) {
  sinOsc[index].stop();
  sqrOsc[index].stop();
  triOsc[index].stop();
} //<>//

void plantLight(){ 
  noStroke();
   //red cube row 1
  for (float x = 0; x < 500; x+=cube*2){
     for(float y = 0; y < 500; y+=cube*2){
      fill(255,0,0);
      rect(x,y,cube,cube);
     }
  }
 
 //red cube row 2
   for (float x = cube; x < width; x+=cube*2){
     for(float y = cube; y < height; y+=cube*2){
      fill(255,0,0);
      rect(x,y,cube,cube);
     }
  }
 
 //blue cube row 1
    for (float x = cube; x < width; x+=cube*2){
     for(float y = 0; y < height; y+=cube*2){
      fill(0,0,255);
      rect(x,y,cube,cube);
     }
  }
  
  //blue cube row 2
    for (float x = 0; x < width; x+=cube*2){
     for (float y = cube; y < height; y+=cube*2){
      fill(0,0,255);
      rect(x,y,cube,cube);
     }
  }
}
