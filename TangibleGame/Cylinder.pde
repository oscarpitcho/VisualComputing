class Cylinder {
  private PVector location;
  private final float cylinderRadius = 50; // Cylinder radius.
  private final float cylinderHeight = 50; // Cylinder height.
  private final int CYLINDER_RESOLUTION = 40;
  private float angle;
  private PShape cylinder;

  private float[] x;
  private float[] y;
  boolean dead;

  Cylinder(float xPos, float yPos, float zPos) {
    location = new PVector(xPos - width/2, yPos, zPos - height/2);
    x = new float[cylinderResolution + 1];
    y = new float[cylinderResolution + 1];
    //get the x and y position on a circle for all the sides
    for (int i = 0; i < x.length; i++) {
      angle = (TWO_PI / CYLINDER_RESOLUTION) * i;
      x[i] = sin(angle) * cylinderBaseSize;
      y[i] = cos(angle) * cylinderBaseSize;
    }
    PShape openCylinder = createShape();
    openCylinder.beginShape(QUAD_STRIP);
    //draw the border of the cylinder
    for (int i = 0; i < x.length; i++) {
      openCylinder.vertex(x[i], y[i], 0);
      openCylinder.vertex(x[i], y[i], cylinderHeight);
    }
    openCylinder.endShape();

    PShape topAndBotDisks = createShape();
    topAndBotDisks.beginShape(TRIANGLE);
    for (int i = 0; i < x.length - 1; i++) {
      topAndBotDisks.vertex(x[i], y[i], cylinderHeight);
      topAndBotDisks.vertex(x[i+1], y[i+1], cylinderHeight);
      topAndBotDisks.vertex(0, 0, cylinderHeight);
      topAndBotDisks.vertex(x[i], y[i], 0);
      topAndBotDisks.vertex(x[i+1], y[i+1], 0);
      topAndBotDisks.vertex(0, 0, 0);
    }
    topAndBotDisks.endShape();
    cylinder = createShape(GROUP);
    cylinder.addChild(topAndBotDisks);
    cylinder.addChild(openCylinder);
  }

  void run(boolean isFirst) {
    display();
    if (isFirst) {
      gameSurface.translate(0, 0, 50);  
      gameSurface.rotateZ(PI);

      gameSurface.rotateX(PI/2);
      gameSurface.scale(100);
      gameSurface.shape(eggman);
      
    }
  }

  //Default constructor initiates at 0, 0, 0
  Cylinder() {
    this(0f, 0f, 0f);
  }

  Cylinder(PVector vect) {
    this(vect.x, vect.y, vect.z);
    this.dead = false;
  }

  public PShape pShape() {
    return cylinder;
  }

  public PVector location() {
    return this.location.copy();
  }

  public float radius() {
    return cylinderRadius;
  }

  void display() {
    gameSurface.stroke(0);
    gameSurface.strokeWeight(2);
    gameSurface.fill(GREY_SHADE);
    gameSurface.shape(cylinder);
  }
}
