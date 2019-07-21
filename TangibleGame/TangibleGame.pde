float depth = 2000; //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//

PShape eggman;
PImage eggmanImage;
Mover mover;
final float cylinderBaseSize = 50;
final float cylinderHeight = 50;
final int cylinderResolution = 40;
final int GREY_SHADE = 127;
ParticleSystem partSys;

//ArrayList<Cylinder> cylinderList = new ArrayList<Cylinder>();
Ball ball;

//Global variables
public final float GRAVITY = 1f;
public boolean shiftPressed = false;
public float angleX = 0;
public float angleZ = 0;

public float oldAngleX = 0;
public float oldAngleZ = 0;

float newAngleX;
float newAngleZ;

public float speed = 1.0;
final float BOARD_LENGTH = 500;
final float BOARD_WIDTH = 500;
final float BOARD_HEIGHT = 20;
Cylinder cylinder;

//==================================
PGraphics gameSurface;
PGraphics backBottom;
PGraphics topView;
PGraphics scoreBoard;
PGraphics scoreChart;

HScrollbar scroll;

public float newScore;
public float lastScore;
public ArrayList<Integer> displayScore;

ImageProcessing imgproc;


//==================================
void settings() {
  size(900, 800, P3D);
}

void setup() {
  frameRate(60);
  cylinder = new Cylinder();
  ball = new Ball();
  mover = new Mover(ball);
  eggman = loadShape("robotnik.obj");
  eggmanImage = loadImage("robotnik.png");
  eggman.setTexture(eggmanImage);

  gameSurface = createGraphics(width, height-150, P3D);
  backBottom = createGraphics(width, 150, P2D);
  topView = createGraphics(150, 150, P2D);
  scoreBoard = createGraphics(130, 130, P3D);
  scoreChart = createGraphics(600, 110, P3D);

  scroll = new HScrollbar(310, 770, 300, 20);

  displayScore = new ArrayList<Integer>();

  imgproc = new ImageProcessing();
  String[] args = {"Image processing window"};
  PApplet.runSketch(args, imgproc);

  // println(eggman);
}

void draw( ) {
  drawGame();
  drawBackBottom();
  drawTopView();
  drawScoreBoard();
  drawScoreChart();

  scroll.update();
  scroll.display();

  fill(0);
  text("Speed: " + speed, 10, 20);

  PVector rot = imgproc.getRotation();
  
  updateAngleFromMovie();
}

void drawBackBottom() {
  backBottom.beginDraw();
  backBottom.background(255);
  backBottom.endDraw();
  image(backBottom, 0, height-150);
}

void drawTopView() {
  topView.beginDraw();
  topView.background(0, 240, 240);
  topView.smooth();
  topView.fill(255, 0, 0);
  float factor = 0.3;
  topView.ellipse(ball.location.x*(factor) + 75, ball.location.z*(factor) + 75, 20, 20); //same here
  topView.fill(256, 256, 256);
  if (partSys != null) {
    for (Cylinder p : partSys.particles) {
      topView.ellipse(p.location.x*(factor) + 210, p.location.y*(factor) + 74, 20, 20);  //plein de magic value mais je sais pas faire autrement
      newScore -= 1;
    }
  }
  topView.endDraw();
  image(topView, 10, height-150);
}

void drawScoreBoard() {
  scoreBoard.beginDraw();
  //scoreBoard.background(64, 224, 208);
  scoreBoard.noFill();
  scoreBoard.rect(0, 0, 130, 130);
  String velocity = String.format("%.2f", ball.velocity.mag());
  String score = String.format("%.2f", newScore);
  String previousScore = String.format("%.2f", lastScore);
  text("Total score:\n " + score, 180, height-120);
  text("Velocity: \n "+ velocity, 180, height-80);
  text("Last score: \n" + previousScore, 180, height-40);
  scoreBoard.endDraw();
  image(scoreBoard, 170, height - 140);
}

void drawScoreChart() {
  scoreChart.beginDraw();
  scoreChart.noFill();
  scoreChart.rect(0, 0, 600, 110);

  float rectScoreWidth = (int) 10*scroll.getPos();
  int rectScoreHeight = 10;

  if (frameCount%30 == 0) {
    int nb = round(newScore/40);
    displayScore.add(nb);
  }

  for (int i = 0; i < displayScore.size(); ++i) {
    for (int j = 1; j <= abs(displayScore.get(i)); ++j) {
      scoreChart.stroke(50, 50, 100);
      scoreChart.fill(50, 50, 200);
      scoreChart.rect(rectScoreHeight*i, rectScoreWidth*j, rectScoreWidth, rectScoreHeight);
    }
  }
  scoreChart.endDraw(); 
  image(scoreChart, 300, height-140);
}

void drawGame() {

  //Some default settings
  gameSurface.beginDraw(); 
  gameSurface.background(200); 
  gameSurface.directionalLight(50, 100, 125, 0, -1, 0); 
  gameSurface.ambientLight(102, 102, 102); 

  //BUILD MODE

  if (shiftPressed) {

    gameSurface.pushMatrix(); 
    gameSurface.translate(width/2, height/2, 0); 

    /*
    if (partSys != null) {
     partSys.run();
     }
     */
    //for (Cylinder cylinder : cylinderList) {
    //  pushMatrix();
    //  translate(cylinder.location().x + BOARD_WIDTH - cylinderBaseSize, cylinder.location().y, 0);
    //  cylinder.display();
    //  popMatrix();
    //}

    gameSurface.rotateX(-PI/2); 
    mover.display(); 
    gameSurface.fill(0, 255, 0); 
    gameSurface.box(BOARD_LENGTH, BOARD_HEIGHT, BOARD_WIDTH); 
    ball.setVelocity(0f, 0f, 0f); 
    //axes();
    gameSurface.popMatrix();
  } else {
    //PLAY MODE
    gameSurface.pushMatrix(); 
    gameSurface.translate(width/2, height/2, 0); 

    //System.out.println("Angle x = " + angleX );

    gameSurface.rotateX(angleZ); 
    gameSurface.rotateZ(angleX); 
    gameSurface.fill(0, 255, 0); 
    gameSurface.box(BOARD_LENGTH, BOARD_HEIGHT, BOARD_WIDTH); 
    //axes();
    if (partSys != null) {
      if (frameCount%10 == 0) {
        //println("size list : " + partSys.particles.size());
        partSys.addParticle();
      }
      partSys.run();
    }

    //for (Cylinder cylinder : cylinderList) {
    //  //System.out.println("Cylinder location = " + cylinder.location().toString());
    //  pushMatrix();
    //  translate(cylinder.location().x + BOARD_LENGTH - cylinderBaseSize, -BOARD_HEIGHT/2, cylinder.location().y);
    //  rotateX(PI/2);
    //  cylinder.display();
    //  popMatrix();
    //}

    mover.update(); 
    mover.checkEdges(); 
    mover.display(); 
    gameSurface.popMatrix();
  }
  gameSurface.endDraw(); 
  image(gameSurface, 0, 0);
}

void changeScore(float ds) {
  if (ds > 1 || ds < -1) {
    newScore += ds; 
    newScore = max(0, newScore); 
    lastScore = ds;
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == SHIFT) {
      shiftPressed = true; 
      oldAngleX = angleX; 
      oldAngleZ = angleZ;
    }
  }
}

void keyReleased() {
  if (key == CODED) {
    if (keyCode == SHIFT) {
      shiftPressed = false; 
      angleX = oldAngleX; 
      angleZ = oldAngleZ;
    }
  }
}

void mousePressed() {
  if (mouseButton == LEFT && shiftPressed && checkCylinderBounds()) {
    PVector cylpos = new PVector(mouseX-(width/2), mouseY-(height/2), 1); 
    System.out.println("Mouse click at " + cylpos.toString()); 
    partSys = new ParticleSystem(cylpos);
  }
}

void mouseDragged() {
  if (!shiftPressed && mouseY < 650) {
    angleX += (mouseX - pmouseX)/100f * speed; 
    if ((angleX > PI/3)) {
      angleX = PI/3;
    } else if ((angleX < -PI/3)) {
      angleX = - PI/3;
    }
    angleZ += (mouseY - pmouseY)/100f * speed; 
    if ((angleZ > PI/3)) {
      angleZ = PI/3;
    } else if ((angleZ < -PI/3)) {
      angleZ = - PI/3;
    }
  }
}

void updateAngleFromMovie() {
  if (!shiftPressed) {
    PVector rot = imgproc.getRotation();

    newAngleX = -(rot.x % PI);
    angleX = (newAngleX-angleX)/2*0.1;

    newAngleZ = (rot.y % PI);
    angleZ = (newAngleZ-angleZ)/2*0.1;

    if (angleX > PI/3) angleX = PI/3;
    if (angleX < -PI/3) angleX = -PI/3;
    if (angleZ > PI/3) angleZ = PI/3;
    if (angleZ < -PI/3) angleZ = -PI/3;
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount(); 
  speed += e; 
  if (speed >= 1.5) {
    speed = 1.5;
  }
  if (speed <= 0.01) {
    speed = 0.01;
  }
}

private boolean checkCylinderBounds() {
  boolean minX = ((mouseX-(width/2)) > - (BOARD_LENGTH/2 - cylinderBaseSize)); 
  boolean maxX = ((mouseX-(width/2)) < ((BOARD_LENGTH/2 - cylinderBaseSize))); 
  boolean minY = ((mouseY-(height/2)) > - (BOARD_LENGTH/2 - cylinderBaseSize)); 
  boolean maxY = ((mouseY-(height/2)) < (BOARD_LENGTH/2 - cylinderBaseSize)); 
  return minX&& maxX&& minY&& maxY;
}

public PVector correctCylinder(PVector location) {
  return (new PVector(location.x + 450, location.y));
}

public PVector correctBall(PVector location) {
  return (new PVector(location.x, location.z));
}
