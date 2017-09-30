import ddf.minim.analysis.*;
import ddf.minim.*;

Minim minim;  
AudioInput in;
FFT fftLin;

int lowestFreq = 3000, highestFreq = 7000;
float minimumDetectableValue = 0.25;
float defaultOutput = 0, outputRange = 100;
float carrierFreq = 4000;
float freqToleration = 500;
float lowBound = 0, highBound = 1;
float freq;
float max;
int pos;
boolean detected = false;
float x1, x2, y1, y2;
String currentModulation = "FM";
float output = 0;


void setup()
{
  size(640, 480);

  minim = new Minim(this);

  in = minim.getLineIn();
  fftLin = new FFT( in.bufferSize(), in.sampleRate() );
  rectMode(CORNERS);
  surface.setResizable(true);
}

void draw()
{
  drawBackground(currentModulation);

  fftLin.forward( in.mix );

  stroke(44, 130, 201);

  max = minimumDetectableValue;
  detected = false;

  for (int i = 0; i < in.bufferSize() - 1; i++)
  {
    x1 = map( i, 0, in.bufferSize(), 0, width );
    x2 = map( i+1, 0, in.bufferSize(), 0, width );
    y1 = map( in.mix.get(i), -1, 1, 0, height/2 );
    y2 = map( in.mix.get(i+1), -1, 1, 0, height/2 );
    strokeWeight(2);
    line( x1, y1, x2, y2);

    if (currentModulation == "FM") {
      if (fftLin.indexToFreq(i) >= 0.9*lowestFreq && fftLin.indexToFreq(i) <= 1.1*highestFreq) {
        if (fftLin.getBand(i) > max) {
          pos = i; 
          max = fftLin.getBand(i);
          detected = true;
        }
      }
    } else if (currentModulation == "AM") {
      if (fftLin.indexToFreq(i) <= carrierFreq + freqToleration && fftLin.indexToFreq(i) >= carrierFreq - freqToleration) {
        output = constrain(map(fftLin.getBand(i), lowBound, highBound, 0, outputRange), 0, outputRange);
      }
    } else if (currentModulation == "AM Calibration") {
     if (fftLin.indexToFreq(i) <= carrierFreq + freqToleration && fftLin.indexToFreq(i) >= carrierFreq - freqToleration) {
        output = map(fftLin.getBand(i), lowBound, highBound, 0, outputRange);
        if (fftLin.getBand(i) < lowBound) {
          lowBound = fftLin.getBand(i);
        } else if (fftLin.getBand(i) > highBound) {
          highBound = fftLin.getBand(i);
        }
      } 
    }
  }

  if (currentModulation == "FM") {
    if (detected) {
      freq = fftLin.indexToFreq(pos);
      strokeWeight(6);
      stroke(243, 121, 52);
      fill(251, 160, 38);
      rect(width*0.1, height*0.65, constrain(map(freq, lowestFreq, highestFreq, width*0.1, width*0.9), width*0.1, width*0.9), height*0.95);
      output = constrain(map(freq, lowestFreq, highestFreq, 0, outputRange), 0, outputRange);
    } else {
      textAlign(CENTER, CENTER);
      textSize(height*0.1);
      fill(243, 121, 52);
      text("Signal suviše slab", width*0.1, height*0.65, width*0.9, height*0.95);
      output = defaultOutput;
    }
  } else if (currentModulation == "AM" || currentModulation == "AM Calibration") {
    strokeWeight(6);
    stroke(243, 121, 52);
    fill(251, 160, 38);
    rect(width*0.1, height*0.65, map(output, 0, outputRange, width*0.1, width*0.9), height*0.95);
  }

  println(currentModulation, " ", output);
}

void mousePressed() {
  if (currentModulation == "FM") {
    currentModulation = "AM";
  } else if (currentModulation == "AM") {
    currentModulation = "FM";
  }
}

void keyPressed() {
  if (key == 'c' || key == 'C') {
    if (currentModulation == "AM") {
      currentModulation = "AM Calibration";
      lowBound = 1;
      highBound = 0;
    } else if (currentModulation == "AM Calibration") {
      currentModulation = "AM";
    }
  }
}

void drawBackground(String modulation) {
  background(40, 50, 78);
  stroke(243, 121, 52);
  strokeWeight(2);
  noFill();
  rect(width*0.1, height*0.65, width*0.9, height*0.95);

  line(width*0.3, height*0.65, width*0.3, height*0.68);
  line(width*0.5, height*0.65, width*0.5, height*0.71);
  line(width*0.7, height*0.65, width*0.7, height*0.68);

  line(width*0.3, height*0.95, width*0.3, height*0.92);
  line(width*0.5, height*0.95, width*0.5, height*0.89);
  line(width*0.7, height*0.95, width*0.7, height*0.92);

  textAlign(CENTER, CENTER);
  textSize(height*0.08);
  if (modulation == "AM") {
    fill(142, 68, 173);
    text("AM (Amplitudska Modulacija)", width*0.1, height*0.5, width*0.9, height*0.65);
  } else if (modulation == "FM") {
    fill(22, 160, 133);
    text("FM (Frekventna Modulacija)", width*0.1, height*0.5, width*0.9, height*0.65);
  } else if (modulation == "AM Calibration") {  
    fill(192, 57, 43);
    text("AM Kalibracija", width*0.1, height*0.5, width*0.9, height*0.65);
  }
}