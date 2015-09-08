/**
 This class represent a Variable (or a vertex in graph theory notation).
 Semantically only needs to have the vertex case type (A, B, C or D)
 and the vertex position.
 However, it also include the vertex radius, to facilitate the calculations
 and for possible extension on the future.
*/
class Variable {
  
  /* Which of the four cases is this variable */
  private int type;
  /* Position of the center of this Variable. It is on absolute coordinates */
  private PVector position;
  /* Radious of the circuncirlce of the variable.
  Usefull for point intersection calculations */
  private float radius;
  
  /* The position of the nine intersection points. It is also absolute */
  private PVector[][] intersectionPoints; 

  /* This method return a copy of one of the nine intersecion points
     identified by index i and j (it is a two dinesional array).
     For example getIntersection(2, 0). means the intersection of the third 
     line from the previous variable with the first line of the next variable */
  public PVector getIntersection(int i, int j) {
    if (i < 0 || i >= 3 || j < 0 || j >= 3) {
      println("Attempt to get a non valid intersection!");
      return null;
    }
    return intersectionPoints[i][j].copy();
  }
  
  /* The setter of the intersection points of this varibale at indexes
  i and j. It need to be given to us, we cannot calculated only the Figure can */
  public void setIntersection(int i, int j, PVector point) {
    if (i >= 0 && i < 3 && j >= 0 && j < 3) {
      intersectionPoints[i][j] = point;
    }
  }

  /* Render the line corresponding to this case using the nine intersection points */
  public void render() {
    switch(this.type) {
      case 0:
        line(intersectionPoints[2][2].x, intersectionPoints[2][2].y, 
             intersectionPoints[1][1].x, intersectionPoints[1][1].y);
      break;
      
      case 1:
        line(intersectionPoints[1][1].x, intersectionPoints[1][1].y, 
             intersectionPoints[0][0].x, intersectionPoints[0][0].y);
      break;
      
      case 2:
        line(intersectionPoints[2][1].x, intersectionPoints[2][1].y,
             intersectionPoints[1][2].x, intersectionPoints[1][2].y);
      break;
      
      case 3:
        line(intersectionPoints[2][1].x, intersectionPoints[2][1].y,
             intersectionPoints[1][2].x, intersectionPoints[1][2].y);
      break;
    }
  }
  
  
  public void renderAsGraph() {
    ellipse(this.position.x, this.position.y, this.radius, this.radius);
    char c = ' ';
    switch(this.type) {  
      case 0:
        c = 'A';
      break;
      
      case 1:
        c = 'B';
      break;
      
      case 2:
        c = 'C';
      break;
    
      case 3:
        c = 'D';
      break;
    }
    textSize(20);
    text(c, this.position.x - 5.0, this.position.y + 5.0);
  }
  
  /* It renders the nine intersection points. Not used anymore.
  It is here for debuging porpouses and to generate one of the
  figures for the paper */
  public void renderPoints() {
    for (int i = 0; i < 3; ++i) {
      for (int j = 0; j < 3; j++) {
        if (i == 2 && j == 0) {
          fill(255, 0, 0);
        } else {
          fill(0, 255, 0);
        }
        ellipse(this.intersectionPoints[i][j].x, this.intersectionPoints[i][j].y, 3, 3);
      }
    }
    noFill();
  }
  
  /* Empthy contsructor, not used */
  public Variable () {
    this.setType(1);
    this.position = new PVector(0.0, 0.0);
    this.setRadius(1.0);
    this.intersectionPoints = new PVector[3][3];
    for (int i = 0; i < 3; ++i) {
      for (int j = 0; j < 3; ++j) {
        intersectionPoints[i][j] = new PVector(0.0, 0.0);
      }
    }
  }
  
  /* Constructor that only ask for the case of this variable. Not used */
  public Variable (int type) {
    this.setType(type);
    this.position = new PVector(0.0, 0.0);
    this.setRadius(1.0);
    this.intersectionPoints = new PVector[3][3];
    for (int i = 0; i < 3; ++i) {
      for (int j = 0; j < 3; ++j) {
        intersectionPoints[i][j] = new PVector(0.0, 0.0);
      }
    }
  }
  
  /* Constructor that give us a case and a postion. Not used */
  public Variable (int type, PVector postion) {
    this.setType(type);
    this.position = position.copy();
    this.setRadius(1.0);
    this.intersectionPoints = new PVector[3][3];
    for (int i = 0; i < 3; ++i) {
      for (int j = 0; j < 3; ++j) {
        intersectionPoints[i][j] = new PVector(position.x, position.y, position.z);
      }
    }
  }
  
  /* Constructos that needs the type, the posiction and the radious */
  public Variable (int type, PVector position, float radius) {
    this.setType(type);
    this.position = position;
    this.setRadius(radius);
    this.intersectionPoints = new PVector[3][3];
    for (int i = 0; i < 3; ++i) {
      for (int j = 0; j < 3; ++j) {
        intersectionPoints[i][j] = new PVector(position.x, position.y, position.z);
      }
    }
    
  }
  
  /* Setter of the type of the variable. It is used to generate a different 
  Impossible Figures */
  public void setType(int type) {
      if (type >= 0 && type < 4) {
         this.type = type;
      }
  }
  
  /* Getter of this type (case) */
  public int getType() {
    return this.type;
  }
  
  /* Getter of the radious. Used for finding 
     the intersection points */
  public float getRadius() {
    return this.radius;
  }
 
  /* Setter of the radius. */
  public void setRadius(float radius) {
    if (radius > 0.0) {
      this.radius = radius;
    }
  }
 
  /* Getter of the position */
  public PVector getPosition() {
    return this.position.copy();
  }
 
  /* Setter of the position. 
     If the position changes, then so do the intersection points */
  public void setPosition(PVector position) {
      if (position != null) {
        /* Proagate the change */
        /* We need to adjust the position of all our vertexes */
        for (int i = 0; i < 3; ++i) {
           for (int j = 0; j < 3; j++) {
              PVector currentVertexAbsolutePosition = this.intersectionPoints[i][j];
              /* Return to relative */
              currentVertexAbsolutePosition.sub(this.position);
              /* Return to absolute in new coordinates */
              currentVertexAbsolutePosition.add(position);
              this.intersectionPoints[i][j] = currentVertexAbsolutePosition;
           }
        }
        this.position = position;
      } else {
        println("Attempt to assign a null vector as position!");
      }  
  }
    
}