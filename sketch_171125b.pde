// Global variables
//import gifAnimation.*;

ArrayList<Particle> particles = new ArrayList<Particle>();
int pixelSteps = 6; // Amount of pixels to skip
boolean drawAsPoints = false;
ArrayList<String> words = new ArrayList<String>();
int wordIndex = 0;
color bgColor = color(255, 100);
String fontName = "Sans Sarif";
private static final float IDEAL_FRAME_RATE = 30f;
int count = 0;


class Particle {
  PVector pos = new PVector(0, 0);
  PVector vel = new PVector(0, 0);
  PVector acc = new PVector(0, 0);
  PVector target = new PVector(0, 0);

  float closeEnoughTarget = 50;
  float maxSpeed = 4.0;
  float maxForce = 0.1;
  float particleSize = 5;
  boolean isKilled = false;

  color startColor = color(0);
  color targetColor = color(0);
  float colorWeight = 0;
  float colorBlendRate = 0.025;

  void move() {
    // Check if particle is close enough to its target to slow down
    float proximityMult = 1.0;
    float distance = dist(this.pos.x, this.pos.y, this.target.x, this.target.y);
    if (distance < this.closeEnoughTarget) {
      proximityMult = distance/this.closeEnoughTarget;
    }

    // Add force towards target
    PVector towardsTarget = new PVector(this.target.x, this.target.y);
    towardsTarget.sub(this.pos);
    towardsTarget.normalize();
    towardsTarget.mult(this.maxSpeed*proximityMult);

    PVector steer = new PVector(towardsTarget.x, towardsTarget.y);
    steer.sub(this.vel);
    steer.normalize();
    steer.mult(this.maxForce);
    this.acc.add(steer);

    // Move particle
    this.vel.add(this.acc);
    this.pos.add(this.vel);
    this.acc.mult(0);
  }

  void draw() {
    // Draw particle
    color currentColor = lerpColor(this.startColor, this.targetColor, this.colorWeight);
    if (drawAsPoints) {
      stroke(currentColor);
      point(this.pos.x, this.pos.y);
    } else {
      noStroke();
      fill(currentColor);
      ellipse(this.pos.x, this.pos.y, this.particleSize, this.particleSize);
    }

    // Blend towards its target color
    if (this.colorWeight < 1.0) {
      this.colorWeight = min(this.colorWeight+this.colorBlendRate, 1.0);
    }
  }

  void kill() {
    if (! this.isKilled) {
      // Set its target outside the scene
      PVector randomPos = generateRandomPos(width/2, height/2, (width+height)/2);
      this.target.x = randomPos.x;
      this.target.y = randomPos.y;

      // Begin blending its color to black
      this.startColor = lerpColor(this.startColor, this.targetColor, this.colorWeight);
      this.targetColor = color(0);
      this.colorWeight = 0;

      this.isKilled = true;
    }
  }
}


// Picks a random position from a point's radius
PVector generateRandomPos(int x, int y, float mag) {
  PVector randomDir = new PVector(random(0, width), random(0, height));
  
  PVector pos = new PVector(x, y);
  pos.sub(randomDir);
  pos.normalize();
  pos.mult(mag);
  pos.add(x, y);
  
  return pos;
}


// Makes all particles draw the next word
void nextWord(String word) {
  // Draw word in memory
  PGraphics pg = createGraphics(width, height);
  pg.beginDraw();
  pg.fill(0);
  pg.textSize(100);
  pg.textAlign(CENTER);
  PFont font = createFont(fontName, 100);
  pg.textFont(font);
  pg.text(word, width/2, height/2);
  pg.endDraw();
  pg.loadPixels();

  // Next color for all pixels to change to
  color newColor;

  int particleCount = particles.size();
  int particleIndex = 0;

  // Collect coordinates as indexes into an array
  // This is so we can randomly pick them to get a more fluid motion
  ArrayList<Integer> coordsIndexes = new ArrayList<Integer>();
  for (int i = 0; i < (width*height)-1; i+= pixelSteps) {
    coordsIndexes.add(i);
  }
if(wordIndex%2==0){// one particle
  for (int i = 0; i < coordsIndexes.size (); i++) {
    // Pick a random coordinate
    int randomIndex = (int)random(0, coordsIndexes.size());
    int coordIndex = coordsIndexes.get(randomIndex);
    coordsIndexes.remove(randomIndex);
    
    // Only continue if the pixel is not blank
    if (pg.pixels[coordIndex] != 0) {
      // Convert index to its coordinates
      int x = coordIndex % width;
      int y = coordIndex / width;

      Particle newParticle;

      if (particleIndex < particleCount) {
        // Use a particle that's already on the screen 
        newParticle = particles.get(particleIndex);
        newParticle.isKilled = false;
        particleIndex += 1;
      } else {
        // Create a new particle
        newParticle = new Particle();
        
        PVector randomPos = generateRandomPos(width/2, height/2, (width+height)/2);
        newParticle.pos.x = randomPos.x;
        newParticle.pos.y = randomPos.y;
        
        newParticle.maxSpeed = random(5.0, 10.0);
        newParticle.maxForce = newParticle.maxSpeed*0.025;
        newParticle.particleSize = random(3, 6);
        newParticle.colorBlendRate = random(0.0025, 0.03);
        
        particles.add(newParticle);
      }
      
     
      // Blend it from its current color
     
       newColor = color(0,0,0);
        if(wordIndex==0)
        { newColor = color(264,83,20);
       
        }
        else if(wordIndex==1)
        {
          newColor = color(264,83,20);
        }
        else if(wordIndex==2||wordIndex==3)
        {
          newColor = color(124,187,0);
           
        }
        else if(wordIndex==4 || wordIndex==5)
        {
          newColor = color(0,161,241);
        }
        else 
        {
          newColor = color(255,187,0);
        }
     
        newParticle.startColor = lerpColor(newParticle.startColor, newParticle.targetColor, newParticle.colorWeight);
      newParticle.targetColor = newColor;
      newParticle.colorWeight = 0;
      
      // Assign the particle's new target to seek
      newParticle.target.x = x;
      newParticle.target.y = y;

    }
  }

  // Kill off any left over particles
  if (particleIndex < particleCount) {
    for (int i = particleIndex; i < particleCount; i++) {
      Particle particle = particles.get(i);
      particle.kill();
    }
  }
}
else{
  for (int i = 0; i < coordsIndexes.size (); i++) {
    // Pick a random coordinate
    int randomIndex = (int)random(0, coordsIndexes.size());
    int coordIndex = coordsIndexes.get(randomIndex);
    coordsIndexes.remove(randomIndex);
    
    // Only continue if the pixel is not blank
    if (pg.pixels[coordIndex] != 0) {
      // Convert index to its coordinates
      int x = coordIndex % width;
      int y = coordIndex / width;

      Particle newParticle;
      Particle newParticle2;
      Particle newParticle3;
      Particle newParticle4;


        // Create a new particle
        newParticle = new Particle();
        
        PVector randomPos = generateRandomPos(width/2, height/2, (width+height)/2);
        newParticle.pos.x = randomPos.x;
        newParticle.pos.y = randomPos.y;
        
        newParticle.maxSpeed = random(5.0, 10.0);
        newParticle.maxForce = newParticle.maxSpeed*0.025;
        newParticle.particleSize = random(3, 6);
        newParticle.colorBlendRate = random(0.0025, 0.03);
        
        particles.add(newParticle);
        newParticle2 = new Particle();
        
        newParticle2.pos.x = randomPos.x;
        newParticle2.pos.y = randomPos.y;
        
        newParticle2.maxSpeed = random(5.0, 10.0);
        newParticle2.maxForce = newParticle.maxSpeed*0.025;
        newParticle2.particleSize = random(3, 6);
        newParticle2.colorBlendRate = random(0.0025, 0.03);
        if(wordIndex>2)
        particles.add(newParticle2);
        newParticle3 = new Particle();
        
        newParticle3.pos.x = randomPos.x;
        newParticle3.pos.y = randomPos.y;
        
        newParticle3.maxSpeed = random(5.0, 10.0);
        newParticle3.maxForce = newParticle.maxSpeed*0.025;
        newParticle3.particleSize = random(3, 6);
        newParticle3.colorBlendRate = random(0.0025, 0.03);
        if(wordIndex>4)
        particles.add(newParticle3);
        newParticle4 = new Particle();
        
        newParticle4.pos.x = randomPos.x;
        newParticle4.pos.y = randomPos.y;
        
        newParticle4.maxSpeed = random(5.0, 10.0);
        newParticle4.maxForce = newParticle.maxSpeed*0.025;
        newParticle4.particleSize = random(3, 6);
        newParticle4.colorBlendRate = random(0.0025, 0.03);
        if(wordIndex>6)
        particles.add(newParticle4);
      
      
     
      // Blend it from its current color
     

     
        newParticle.startColor = lerpColor(newParticle.startColor, newParticle.targetColor, newParticle.colorWeight);
      newParticle.targetColor = color(246,83,20);
      newParticle.colorWeight = 0;
      newParticle2.startColor = lerpColor(newParticle.startColor, newParticle.targetColor, newParticle.colorWeight);
      newParticle2.targetColor = color(124,187,0);
      newParticle2.colorWeight = 0;
      newParticle3.startColor = lerpColor(newParticle.startColor, newParticle.targetColor, newParticle.colorWeight);
      newParticle3.targetColor = color(0,161,241);
      newParticle3.colorWeight = 0;
      newParticle4.startColor = lerpColor(newParticle.startColor, newParticle.targetColor, newParticle.colorWeight);
      newParticle4.targetColor = color(255,187,0);
      newParticle4.colorWeight = 0;
      
      // Assign the particle's new target to seek
      newParticle.target.x = x-55;
      newParticle.target.y = y-55;
      newParticle2.target.x = x+55;
      newParticle2.target.y = y-55;
      newParticle3.target.x = x-55;
      newParticle3.target.y = y+55;
      newParticle4.target.x = x+55;
      newParticle4.target.y = y+55;

    }
  }

  // Kill off any left over particles
  if (particleIndex < particleCount) {
    for (int i = particleIndex; i < particleCount; i++) {
      Particle particle = particles.get(i);
      particle.kill();
    }
  }
}
}



void setup() {
  size(1200, 630);
  background(255);
  

  words.add("MSP Class of 2018");
  words.add("\u2588");
  words.add("Technology");
words.add("\u2588");
  words.add("Innovation");
 words.add("\u2588");
  words.add("Entrepreneurship");
 words.add("\u2588"); 
  

  nextWord(words.get(wordIndex));
}


void draw() {
  // Background & motion blur
  fill(bgColor);
  noStroke();
  rect(0, 0, width*2, height*2);

  for (int x = particles.size ()-1; x > -1; x--) {
    // Simulate and draw pixels
    Particle particle = particles.get(x);
    particle.move();
    particle.draw();

    // Remove any dead pixels out of bounds
    if (particle.isKilled) {
      if (particle.pos.x < 0 || particle.pos.x > width || particle.pos.y < 0 || particle.pos.y > height) {
        particles.remove(particle);
      }
    }
  }

  // Display control tips
  fill(255-red(bgColor));
  textSize(9);
 
}


// Show next word
void mousePressed() {
  if (mouseButton == LEFT) {
    wordIndex += 1;
    if (wordIndex > words.size()-1) { 
      wordIndex = 0;
    }
    nextWord(words.get(wordIndex));
  }
}


// Kill pixels that are in range
void mouseDragged() {
  if (mouseButton == RIGHT) {
    for (Particle particle : particles) {
      if (dist(particle.pos.x, particle.pos.y, mouseX, mouseY) < 50) {
        particle.kill();
      }
    }
  }
}


// Toggle draw modes
void keyPressed() {
  drawAsPoints = (! drawAsPoints);
  if (drawAsPoints) {
    background(0);
    bgColor = color(0, 40);
  } else {
    background(255);
    bgColor = color(255, 100);
  }
}