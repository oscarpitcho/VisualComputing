class Ball { //<>// //<>//
  private PVector location; 
  private PVector velocity; 

  private PVector force;
  private float ballRadius;




  private final float MU = 0.01f;
  private final float ELASTICITY = 0.5f; // Rebound coefficient.
  private final float FRICTION_MAGNITUDE = 0.1; 


  Ball() {
    ballRadius = 30f; 
    force = new PVector(0, 0, 0);
    location = new PVector(0, - (ballRadius + height/2), 1);
    velocity = new PVector(0, 0, 0);
  }


  void update() {
    //System.out.println("Ball location = " + location.toString());
    force.x = sin(angleX) * GRAVITY;
    force.z = -sin(angleZ) * GRAVITY;
    float normalForce = 1;
    float frictionMagnitude = normalForce * MU;
    PVector friction = velocity.copy();
    friction.mult(-1);
    friction.normalize();
    friction.mult(frictionMagnitude);
    location.add(velocity.add(force.add(friction)));
    ArrayList<Cylinder> deletedCyls = new ArrayList<Cylinder>();
    if (partSys != null) {
      for (int i = 0; i < (partSys == null ? 0 : partSys.particles.size()); i++) {
        Cylinder c = partSys.particles.get(i);
        if (contact(c)) {
          if (i == 0) {
            partSys = null;
            PVector bLocation = correctBall(location);
            PVector cLocation = correctCylinder(c.location());
            // System.out.println("cLocation = " + cLocation);
            // System.out.println("bLocation = " + bLocation);
            PVector n = new PVector(bLocation.x - cLocation.x, bLocation.y - cLocation.y).normalize();
            //System.out.println("n = " + n);        
            location = n.copy().mult(cylinderBaseSize + ballRadius).add(cLocation);
            location.z = location.y;
            location.y = 0;
            velocity.sub(n.mult(2*velocity.dot(n))).mult(0.9);
          } else {
            PVector bLocation = correctBall(location);
            PVector cLocation = correctCylinder(c.location());
            //System.out.println("cLocation = " + cLocation);
            //System.out.println("bLocation = " + bLocation);
            PVector n = new PVector(bLocation.x - cLocation.x, bLocation.y - cLocation.y).normalize();
            //System.out.println("n = " + n);        
            location = n.copy().mult(cylinderBaseSize + ballRadius).add(cLocation);
            location.z = location.y;
            location.y = 0;
            velocity.sub(n.mult(2*velocity.dot(n))).mult(1.1);
            deletedCyls.add(c);
          }
        }
      }
      if (partSys != null)
        partSys.particles.removeAll(deletedCyls);
    }
  }

  void display() {
    gameSurface.pushMatrix();
    if (shiftPressed) {
      gameSurface.translate(location.x, -(ballRadius + BOARD_HEIGHT/2), location.z);
      gameSurface.sphere(ballRadius);
    } else {
      gameSurface.translate(location.x, -40, location.z); 
      gameSurface.sphere(ballRadius);
    }
    gameSurface.stroke(0);
    gameSurface.strokeWeight(2);
    gameSurface.fill(GREY_SHADE);
    gameSurface.popMatrix();
  }
  void checkEdges() {
    if (location.x + ballRadius > BOARD_WIDTH/2) {
      location.x = BOARD_WIDTH/2 - ballRadius;
      rebound(true);
    } else if (location.x - ballRadius < -BOARD_WIDTH/2) {
      location.x = -BOARD_WIDTH/2 + ballRadius;
      rebound(true);
    }
    if (location.z + ballRadius > BOARD_LENGTH/2) {
      location.z = BOARD_LENGTH/2 - ballRadius;
      rebound(false);
    } else if (location.z - ballRadius < -BOARD_LENGTH/2) {
      location.z = -BOARD_LENGTH/2 + ballRadius;
      rebound(false);
    }
  }

  public boolean contact(Cylinder that) {
    //System.out.println("Ball location: " + correctBall(this.location));
    //System.out.println("Cylinder location: " + correctCylinder(that.location()));
    PVector correctCylinder = correctCylinder(that.location());
    PVector correctBall = correctBall(this.location);
    changeScore(velocity.mag());
    return correctCylinder.dist(correctBall) < that.radius() + ballRadius;
  }

  public void setVelocity(PVector vect) {
    velocity = vect;
  }

  public void setVelocity(float x, float y, float z) {
    setVelocity(new PVector(x, y, z));
  }

  public float radius() {
    return ballRadius;
  }
  //void collisionCylinder(Cylinder cylinder) {
  //  PVector Vdist = new PVector(location.x - cylinder.location.x, location.z - cylinder.location.z);
  //  float distance = Vdist.mag();
  //  if (distance <= ballRadius + cylinder.cylinderRadius) {
  //    location.x = location.x + Vdist.x  / (ballRadius+cylinder.cylinderRadius);
  //    location.z = location.z + Vdist.z / (ballRadius+cylinder.cylinderRadius);
  //    PVector normal = new PVector(location.x - cylinder.location.x, 0, location.z - cylinder.location.z).normalize();
  //    velocity = PVector.sub(velocity, normal.mult(PVector.dot(velocity, normal) * 2));
  //  }
  //}






  private void rebound(boolean bounceOnX) {
    if (bounceOnX) {
      velocity.x = velocity.x * -ELASTICITY;
    } else {
      velocity.z = velocity.z * -ELASTICITY;
    }
  }
}
