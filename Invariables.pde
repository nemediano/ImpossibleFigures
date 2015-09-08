/* 
   This class represent an Invariable (or edge in Graph Theory terminology)
   The only data that needs are the two Variables thata is joinin. 
   However, it is very impotant, since it is in charge of most of the rendering.
*/
class Invariables {
  /*The two Variables this Invariable join */
  private Variable first;
  private Variable second;
  
  /* 
     The most impostnat methos of this class. It renders the three paralell lines.
     To avoid airtifacts in the rendering the end point of the lines are calculated
     using the specific case of the variables that we join. This makes the lines
     not broken into smaller pieces. 
  */
  public void render () {
    /* To store the three end lines on the first variable */
    PVector p[] = new PVector[3];
    /* To store the three end lines on the second variable */
    PVector q[] = new PVector[3];
    /* According to this type, get the three endpoints */
    switch(this.first.getType()) {
      case 0:
      case 1:
        p[0] = this.first.getIntersection(0, 0);
        p[1] = this.first.getIntersection(1, 1);
        p[2] = this.first.getIntersection(2, 2);
      break;
      
      case 2:
        p[0] = this.first.getIntersection(1, 0);
        p[1] = this.first.getIntersection(2, 1);
        p[2] = this.first.getIntersection(1, 2);
      break;
      
      case 3:
        p[0] = this.first.getIntersection(0, 0);
        p[1] = this.first.getIntersection(0, 1);
        p[2] = this.first.getIntersection(1, 2);
      break;
    }
    /* Same with the second variable*/
    switch(this.second.getType()) {
      case 0:
      case 1:
        q[0] = this.second.getIntersection(0, 0);
        q[1] = this.second.getIntersection(1, 1);
        q[2] = this.second.getIntersection(2, 2);
      break;
      
      case 2:
        q[0] = this.second.getIntersection(0, 0);
        q[1] = this.second.getIntersection(1, 0);
        q[2] = this.second.getIntersection(2, 1);
      break;
      
      case 3:
        q[0] = this.second.getIntersection(0, 1);
        q[1] = this.second.getIntersection(1, 2);
        q[2] = this.second.getIntersection(2, 1);
      break;
    }
    /* Now that you have the six endpoints. Draw three lines */
    for (int i = 0; i < p.length; i++) {
      line(p[i].x, p[i].y, q[i].x, q[i].y);
    }
  }
  
  public void renderAsGraph() {
    PVector p_1;
    PVector p_2;
    
    p_1 = this.first.getPosition();
    p_2 = this.second.getPosition();
    
    PVector direction = PVector.sub(p_2, p_1);
    direction.normalize();
    
    p_1.add(PVector.mult(direction, this.first.getRadius()));
    p_2.sub(PVector.mult(direction, this.second.getRadius()));
    //Draw the arc joining the two nodes
    line(p_1.x, p_1.y, p_2.x, p_2.y);
    
    //Add a small arrowhead
    PVector v_1 = PVector.add(PVector.mult(direction, -10.0), p_2);
    PVector v_2 = PVector.add(PVector.mult(direction, -10.0), p_2);
    v_1.add( 5.0 * direction.y, -5.0 * direction.x, 0.0);
    v_2.add(-5.0 * direction.y,  5.0 * direction.x, 0.0);
    
    triangle(v_1.x, v_1.y, v_2.x, v_2.y, p_2.x, p_2.y);
  }
  
  public void renderSolid(color outColor, color inColor) {
    
  }
  
  public Variable getFirst() {
    return this.first;
  }
  
  public Variable getSecond() {
    return this.second;
  }
  
  /*
     Only constructos of the class ask for a reference of the two
     variables we join
  */
  public Invariables (Variable first, Variable second) {
    if (first != null) {
      this.first = first;
    } else {
      println("Attempt to assign a null vertex to an edge!");
    }
    
    if (second != null) {
      this.second = second;
    } else {
      println("Attempt to assign a null vertex to an edge!");
    }
  }
  
  /* 
    Just for debug, not used anymore. Mark which variable is the first
    and which is the second. Since we are using Digraphs this is relevant 
   */
  public void markFirstSecond() {
    PVector pFirst = this.first.getPosition();
    PVector pSecond = this.second.getPosition();
    noFill();
    stroke(0, 0, 255);
    ellipse(pFirst.x, pFirst.y, 10, 10);
    stroke(0, 255, 255);
    ellipse(pSecond.x, pSecond.y, 10, 10);
  }
  
}