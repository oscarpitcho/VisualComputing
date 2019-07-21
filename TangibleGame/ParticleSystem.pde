// A class to describe a group of Particles
class ParticleSystem {
  ArrayList<Cylinder> particles;
  PVector origin;
  ArrayList<Cylinder> death;
  //float cylinderRadius = 40;
  //float particleRadius = 10;


  ParticleSystem(PVector origin) {
    this.origin = origin.copy();
    particles = new ArrayList<Cylinder>();
    particles.add(new Cylinder(origin));
    death = new ArrayList<Cylinder>();
  }

  void addParticle() {
    PVector center;
    int numAttempts = 100;
    for (int i=0; i<numAttempts; i++) {
      // Pick a cylinder and its center.
      int index = int(random(particles.size()));
      Cylinder c = particles.get(index);
      center = correctCylinder(c.location());
      // Try to add an adjacent cylinder.
      float angle = random(TWO_PI);
      center.x += sin(angle) * 2*c.radius();
      center.y += cos(angle) * 2*c.radius();
      //println("center = " + center);
      if (checkPosition(center, c.radius())) {
        particles.add(new Cylinder(center));
        break;
      }
    }
  }
  // Check if a position is available, i.e.
  // - would not overlap with particles that are already created
  // (for each particle, call checkOverlap())
  // - is inside the board boundaries
  boolean checkPosition(PVector center, float cylinderRadius) {
    for (Cylinder p : particles) {
      if (checkOverlap(center, new PVector(p.location.x + 450, p.location.y, 0), cylinderRadius)) {
        //println("CheckOverLap");
        return false;
      }
    }
    if (center.x > BOARD_LENGTH/2 - cylinderRadius || center.x < -BOARD_LENGTH/2 + cylinderRadius || center.y > BOARD_WIDTH/2 - cylinderRadius || center.y < -BOARD_WIDTH/2 + cylinderRadius) {
      return false;
    }
    if (correctBall(ball.location).dist(center) < cylinderRadius + ball.radius())
      return false;
    //println("Check true");
    return true;
  }
  // Check if a particle with center c1
  // and another particle with center c2 overlap.
  boolean checkOverlap(PVector c1, PVector c2, float cylinderRadius) {
    //   println("C1 = " + c1);
    // println("C2 = " + c2);
    return c1.dist(c2) < 2*cylinderRadius;
  }
  // Iteratively update and display every particle,
  // and remove them from the list if their lifetime is over.
  void run() {
    for (Cylinder p : particles) {
      if (p.dead) {
        death.add(p);
      } else {
        if (shiftPressed) {
          gameSurface.pushMatrix();
          gameSurface.translate(p.location().x + BOARD_WIDTH - cylinderBaseSize, p.location().y, 0);
          if (particles.indexOf(p) == 0)
            p.run(true);
          else
            p.run(false);
          gameSurface.popMatrix();
        } else {
          gameSurface.pushMatrix();
          gameSurface.translate(p.location().x + BOARD_LENGTH - cylinderBaseSize, -BOARD_HEIGHT/2, p.location().y);
          gameSurface.rotateX(PI/2);
          if (particles.indexOf(p) == 0)
            p.run(true);
          else
            p.run(false);
          gameSurface.popMatrix();
        }
      }
      particles.removeAll(death);
      newScore = 0; //to reset the score
    }
  }
}
