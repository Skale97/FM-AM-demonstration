import processing.sound.*;
SinOsc osc;

void setup(){
  size(200, 200);
  background(0);
  
  osc = new SinOsc(this);
  osc.play();
}

void draw(){
  osc.amp((height-mouseY)*1.0/height);
  osc.freq(3000.0+mouseX*20.0);
  println(mouseY*1.0/height);
}