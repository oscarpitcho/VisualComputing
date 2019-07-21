class Mover {
  private Ball ball;

  Mover(Ball ball) {
    this.ball = ball;
  }
  void update() {
   ball.update();
  }
  
  void display() {
    ball.display();
    
  }
  
  void checkEdges() {
    ball.checkEdges();
  }
}
