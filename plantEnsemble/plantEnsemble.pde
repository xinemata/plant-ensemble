import processing.sound.*;
import processing.io.*;
MPR121 touch; // define MPR121 I2C capacitive touch sensor

Shape hex;
Shape circle;
Shape triangle;
Shape square;
Shape rectangle;

SinOsc sinOsc[] = new SinOsc[5];
SqrOsc sqrOsc[] = new SqrOsc[5];
TriOsc triOsc[] = new TriOsc[5];

float[] volumeLevels = {0.5, 0.75, 1.0}; // possible volume levels to switch between
int currentVolumeIndex = 0;
float currentVolume = 1.0;

float pitchDelta = 0;
float frequencyMultiplier = 1.0;

int currentMode; // Used for switching between oscillators: 0 - Sine, 1 - Square, 2 - Triangle oscillator

void setup() {
  size(500, 300);
  // Change the color mode of the sketch to HSB
  colorMode(HSB, 360, 100, 100);
  noStroke();
  
  hex = new Shape(50, random(100, height - 100), 100, radians(random(360), "hexagon");
  circle = new Shape(150, random(100, height - 100), 100, radians(random(360), "circle");
  triangle = new Shape(250, random(100, height - 100), 100, radians(random(360), "triangle");
  rectangle = new Shape(350, random(100, height - 100), 50, radians(random(360), "rectangle");
  square = new Shape(450, random(100, height - 100), 100, radians(random(360), "square");

  touch = new MPR121("i2c-1", 0x5a); // Read capacitive touch from MPR121 using its default address
  for (int i=0; i < 5; i++) {
    sinOsc[i] = new SinOsc(this);
    sqrOsc[i] = new SqrOsc(this);
    triOsc[i] = new TriOsc(this);
  }

  currentVolume = volumeLevels[currentVolumeIndex];
  currentMode = 0; // set the default oscillator to Sine
}

void draw() {
  background(100); 

  touch.update(); // get readings from the MPR121 I2C sensor

  hex.setActiveState(false);
  circle.setActiveState(false);
  triangle.setActiveState(false);
  square.setActiveState(false);
  rectangle.setActiveState(false);

  if (touch.touched(10)) {
    currentVolumeIndex++;
    if (currentVolumeIndex > volumeLevels.length - 1) {
      currentVolumeIndex = 0;
    }
    currentVolume = volumeLevels[currentVolumeIndex];
  }

  if (!touch.touched(9)) {
    pitchDelta = 0;
  }

  if (touch.touched(9)) {
    pitchDelta = touch.analogRead(9) / 2;
  }

  if (!touch.touched(7)) {
    currentVolume = volumeLevels[currentVolumeIndex];
  }

  if (touch.touched(7)) {
    currentVolume = touch.analogRead(7) / 200.0;
  }

  if (!touch.touched(11)) {
    frequencyMultiplier = 1.0;
  }

  if (touch.touched(11)) {
    frequencyMultiplier = 3.0;
  }

  if (touch.touched(8)) {
    currentMode = 0;
  }

  if (touch.touched(5)) {
    currentMode = 1;
  }

  if (touch.touched(6)) {
    currentMode = 2;
  }

  for (int i=0; i < 5; i++) {
    if (!touch.touched(i)) {
      stopNote(i);
    }
    if (touch.touched(i)) {
      if (i == 1) { 
        hex.vibrate(440);
        playNote(i, 440);
      } 

      if (i == 3) { 
        // Update the circle state
        circle.vibrate(700);
        playNote(i, 700);
      }

      if (i == 4) { 
        triangle.vibrate(340);
        playNote(i, 340);
      }

      if (i == 2) { 
        square.vibrate(490);
        playNote(i, 490);
      }

      if (i == 0) { 
        rectangle.vibrate(600);
        playNote(i, 600);
      }
    }
  }

  hex.display();
  circle.display();
  triangle.display();
  square.display();
  rectangle.display();
}

// Play a note, using the oscillator that is currently active, with volume level established by the volume toggle switch
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

void stopNote(int index) {
  sinOsc[index].stop();
  sqrOsc[index].stop();
  triOsc[index].stop();
}
