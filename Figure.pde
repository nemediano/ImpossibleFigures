/**
   This class represents the Impossible Figure
   It´s bacially a cycle Digraph, where the Edges are the Invariables
   and the vertexes are the Variables.
   It generates the vertexes in a circle-fashions positions.
*/
class Figure {
  /* Variables that control the logic of the figure */
  
  /* The variables (vertexes) */
  private Variable[] vertexes;
  /* The invariables (edges) */
  private Invariables[] edges;
  /* Number of vertexes */
  private int order;
  /* Number of edges */
  private int size;
  
  /* Variables that control the presentation of the figure */
  /* Unused: It will be only used on solid rendering */
  private color[] solidColors;
  
  /* Inner radious of the Torus (ring) inside which we arrange the vertex in a cycle */
  private float innerRadius;
  /* Outer radious of the same */
  private float outterRadius;
  /* Courrently not used, it keeps the roatation of the figure */
  private float orientationAngle;
  /* Position of the center of the figure */
  private PVector position;
  
  /* Adjacence matrix of the graph. To quickly determine the
     adjacent vertex to a given one */
  private boolean[][] adjacenceMatrix; 
  
  /* Operational methods */
  
  /* 
     This method is in charge of rendering the Figure.
     Very simple: first render the Invariables and then
     the Variables. 
     Courrently the first and second color are the same 
  */
  public void render() {
    stroke(color(255, 255, 255));
    for (int i = 0; i < size; ++i) {
      this.edges[i].render();
    }
    
    for (int i = 0; i < order; ++i) {
     this.vertexes[i].render();
    }
    //this.vertexes[2].renderPoints();
  }
  
  public void renderAsGraph() {
    stroke(this.solidColors[0]);
    for (int i = 0; i < size; ++i) {
      this.edges[i].renderAsGraph();
    }
    
    for (int i = 0; i < order; ++i) {
      this.vertexes[i].renderAsGraph();
    }
  }
  
  public void renderSolid() {
    //Factor out the three colors calculation
    //Now I need to walk all the edges, draw two polygons at each
    //Edge, and change the color on certain transitions.
    //Need to discover the transitions rules.
    
    //Temporary for debug
    color out = this.solidColors[0];
    color in = this.solidColors[1];
    color unused = this.solidColors[2];
    
    
    for (int i = 0; i < this.size; ++i) {
      int secondType = this.edges[i].getSecond().getType();
      this.edges[i].renderSolid(in, unused);
      //Determine if we change color according to type
      switch (secondType) {
        //Make swaping of the colors using 
        //The type of the second variable
        case 0:
          /*Swap out and unused*/
          color tmp = unused;
          unused = out;
          out = tmp;
        break;
        
        case 1:
          /*Swap in and unused*/
          tmp = unused;
          unused = in;
          in = tmp;
        break;
        
        case 2:
          /* Out becomes in.
             in is unused
             new out is prevois unused */
          tmp = in;
          in = out;
          out = unused;
          unused = tmp;
        break;
        
        case 3:
          /* Out becomes unused.
             in becomes out
             unuses is prevoius out */
          tmp = out;
          out = in;
          in = unused;
          unused = tmp;
        break;
      }
    }
    
  }
  
  /* 
    Only constructor, since we are dealing with cycles
    the only paremeter is the number of vertex (variables)
  */
  public Figure (int order) {
    /* The smalles possible cycle is the triangle */
    if (order > 2) {
      this.order = order;
    } else {
      this.order = 3;
    }
    /* Since we are a cylce we have the smae number of vertex and edges */
    this.size = order;
    this.vertexes = new Variable[this.order];
    this.edges = new Invariables[this.size];
    
    this.adjacenceMatrix = new boolean[this.order][this.order];
    /* Default color, radious and position */
    this.solidColors = new color[3];
    this.setOneColor(color(255, 255, 255));
    this.outterRadius = 100.0f;
    this.innerRadius = 0.60 * this.outterRadius;
    this.orientationAngle = 0.0f;
    this.position = new PVector(0, 0);
    
    /* Crete the Topology (connection of the figure) */
    /* First, span the vertex */
    this.createRoundVertices();
    /* Then, make connections to create the cycle */
    this.connectEdges();
    
    /* Calculate the 9 intersection points 
       for each vertex (Variable) */
    for (int i = 0; i < this.size; ++i) {
      intersectionPoints(i);
    }
  }
  
  /* Setters and getters */
  
  /* Get the color */
  public color getFirstColor(int index) {
    if (index < 0 || index >= 3) {
      println("Requested an ilegal color index");
      return color(0);
    }
    return this.solidColors[index];
  }
  /* Set the colors using one color */
  public void setOneColor(color c) {
      colorMode(RGB, 1.0);
      this.solidColors[0] = c;
      float redC = red(c);
      float greenC = green(c);
      float blueC = blue(c);
      //Calculate the other two colors linear interpolating
      this.solidColors[1] = color(0.66 * redC, 0.66 * greenC, 0.66 * blueC);
      this.solidColors[2] = color(0.33 * redC, 0.33 * greenC, 0.33 * blueC);
  }
  /* Set the colors using two colors */
  public void setTwoColors(color c_1, color c_2) {  
      colorMode(RGB, 1.0);
      this.solidColors[0] = c_1;
      this.solidColors[2] = c_2;
      //Calculate the missing color linear interpolating
      this.solidColors[1] = color((red(c_1) + red(c_2)) / 2, (green(c_1) + green(c_2)) / 2, (blue(c_1) + blue(c_2)) / 2);
  }
  /* Set the colors using three colors */
  public void setThreeColors(color c_1, color c_2, color c_3) {  
      this.solidColors[0] = c_1;
      this.solidColors[1] = c_2;
      this.solidColors[2] = c_3;
  }
  
  /* Get the coordinates of the center of the Figure */
  public PVector getPosition() {
    return this.position.copy();
  }
  /* Set the coordinates of the center of the Figure */
  public void setPosition(PVector position) {
    if (position != null) {
      /* We need to adjust the position of all our vertexes */
      for (int i = 0; i < this.order; ++i) {
        PVector currentVertexAbsolutePosition = this.vertexes[i].getPosition();
        /* Return to relative coordinates */
        currentVertexAbsolutePosition.sub(this.position);
        /* Return to absolute coordinates with the new position */
        currentVertexAbsolutePosition.add(position);
        this.vertexes[i].setPosition(currentVertexAbsolutePosition);
      }
      /* Update the center of this figure */
      this.position = position;
    } else {
      println("Attempt to assign a null vector as position to this figure!");
    }
  }
  /* Get the inner radious */
  public float getInnerRadio() {
    return this.innerRadius;
  }
  /* Set the inner radious */
  public void setInnerRadio(float radius) {
    if (radius > 0.0f) {
      this.innerRadius = radius;
      /* Propagate the change */
      for (int i = 0; i < this.size; ++i) {
         float vertexRadius = (this.outterRadius - this.innerRadius) / 2.0f;
         this.vertexes[i].setRadius(vertexRadius);
      }
      this.updateVertexPosition();
      /* Recalculate the intersection points */
      for (int i = 0; i < this.size; ++i) {
         intersectionPoints(i);
      }
    }
  }
  /* Get the outter radious */
  public float getOutterRadio() {
    return this.outterRadius;
  }
  /* Set the outter radious */
  public void setOutterRadio(float radius) {
    if (radius > 0.0f) {
      this.outterRadius = radius;
      /*Propagate the change */
      for (int i = 0; i < this.size; ++i) {
         float vertexRadius = (this.outterRadius - this.innerRadius) / 2.0f;
         this.vertexes[i].setRadius(vertexRadius);
      }
      this.updateVertexPosition();
      /* Recalculate the intersection points */
      for (int i = 0; i < this.size; ++i) {
         intersectionPoints(i);
      }
    }
  }
  
  /* Private helper methods */
  
  /* Update a Vertex in case we changed inner or outter radius */
  private void updateVertexPosition() {
    for (int i = 0; i < this.order; ++i) {
      float radialDistance = this.innerRadius + this.vertexes[i].getRadius();
      PVector p = this.vertexes[i].getPosition();
      PVector direction = PVector.sub(p, this.position);
      direction.normalize();
      direction.mult(radialDistance);
      this.vertexes[i].setPosition(PVector.add(direction, this.position));
    }
  }
  
  /* Get the angle of the figure. (Unused always return zero) */
  public float getOrientationAngle() {
    return this.orientationAngle;
  }
  /* Set the angle of rotation, Not implemented yet */
  public void setOrientationAngle(float angleInRadians) {
    if (angleInRadians >= 0.0f && angleInRadians < TAU) {
      this.orientationAngle = angleInRadians;
    }
  }
  
  /* 
    Span the vertexes:
    So far we are only creating the vertex around a circle 
  */
  private void createRoundVertices() {
    /* First vertex is in the north pole */
    float angle = TAU / 4.0f;
    float deltaAngle = TAU / this.order;

    for (int i = 0; i < this.order; ++i, angle += deltaAngle) {
      float radius = (this.outterRadius - this.innerRadius) / 2.0f;
      float x = (this.innerRadius + radius) * cos(angle);
      float y = (this.innerRadius + radius) * sin(angle);
      PVector vertexPosition = new PVector(x, y);
      vertexPosition.add(this.position);
      /* The type (case) of the vertex is picked at random*/
      this.vertexes[i] = new Variable(int(random(4)), vertexPosition, radius);
    }    
  }
  /* 
     Create the topology, conect each veterx with his two neighbours.
     Remember they are Digraphs (order matters)
  */
  public void connectEdges() {
    /* First connect each vertex (except the last one), whit his sucessor */
    for (int i = 0; i < (size - 1); ++i) {
      this.edges[i] = new Invariables(this.vertexes[i], this.vertexes[i + 1]);
      this.adjacenceMatrix[i][i + 1] = true;
      this.adjacenceMatrix[i + 1][i] = true;
    }
    /* The last one is conected with the first one */
    this.edges[size - 1] = new Invariables(this.vertexes[size - 1], this.vertexes[0]);
    this.adjacenceMatrix[size - 1][0] = true;
    this.adjacenceMatrix[0][size - 1] = true;
  }
  /* 
     Helper method given two lines, return the intersection point or null if they dont intersect 
     The lines are in the form L_1(t) = u * t + p_0 and L_2(t) = v * t + p_1 
  */
  private PVector lineIntersection(PVector u, PVector p_0, PVector v, PVector p_1) {
    /* Solve a linear system to get the intersection */
    float determinant = u.x * v.y - u.y * v.x;
    PVector intersection = new PVector();
    /* If they don't intersect return null vector */
    if (abs(determinant) < EPSILON) {
      intersection = null;
    }
    /* Solve the system using Kramer's rule */
    float tCritical = ((p_1.x - p_0.x) * v.y - (p_1.y - p_0.y) * v.x) / determinant;
    // This is (was) a bug on ProcessingJS, that is why I don't use
    // PVectror corresponding methods
    intersection.x = u.x * tCritical + p_0.x;
    intersection.y = u.y * tCritical + p_0.y;
    intersection.z = u.z * tCritical + p_0.z;
        
    return intersection;
  }
  
  
  /* For a given vertex calculate his 9 points of intersecction */
  private void intersectionPoints (int index) {
    /* Validate the index of the vertex */
    if (index < 0 || index >= this.order) {
      println("Invalid vertex to calculate the 9 points");
      return;
    }
    /* Get the index of the two adjacent vertexes to this one */
    int first = -1;
    int second = -1;
    for (int i = 0; i < this.size; ++i) {
      if (this.adjacenceMatrix[index][i] && first == -1) {
        first = i;
      } else if (this.adjacenceMatrix[index][i]) {
        second = i;
      }
    }    
    /* If this is the first or last vertex swap indexes */
    if (index == 0 || index == (this.order - 1)) {
      int tmp = first;
      first = second;
      second = tmp;
    }
    
    /*Now lets start making calculations*/
    PVector[] u = new PVector[3];
    PVector[] v = new PVector[3];
    PVector[] p_0 = new PVector[3];
    PVector[] p_1 = new PVector[3];
    
    PVector p = this.vertexes[index].getPosition();
    PVector pFirst = this.vertexes[first].getPosition();
    PVector pSecond = this.vertexes[second].getPosition();
        
    /*Calculate three lines from first to this vertex*/
    u[1] = PVector.sub(pFirst, p);
    u[1].normalize();
    p_0[1] = pFirst;
    /* Get unary vector orthogonal to direction */
    PVector othogonalToDirection = new PVector(u[1].y, -u[1].x);
    p_0[0] = PVector.add(pFirst, PVector.mult(othogonalToDirection,  this.vertexes[first].getRadius()));
    p_0[2] = PVector.add(pFirst, PVector.mult(othogonalToDirection, -this.vertexes[first].getRadius()));
    /* Calculate points in this vertex due to lines from first */
    u[0] = PVector.sub(p_0[0], PVector.add(p, PVector.mult(othogonalToDirection,  this.vertexes[index].getRadius())));
    u[2] = PVector.sub(p_0[2], PVector.add(p, PVector.mult(othogonalToDirection, -this.vertexes[index].getRadius())));
    u[0].normalize();
    u[2].normalize();
   
    /*Calculate three lines from second to this vertex*/
    v[1] = PVector.sub(pSecond, p);
    v[1].normalize();
    p_1[1] = pSecond;
    /* Get unary vector orthogonal to direction */
    othogonalToDirection = new PVector(v[1].y, -v[1].x);
    p_1[0] = PVector.add(pSecond, PVector.mult(othogonalToDirection, -this.vertexes[second].getRadius()));
    p_1[2] = PVector.add(pSecond, PVector.mult(othogonalToDirection,  this.vertexes[second].getRadius()));
    /* Calculate points in this vertex due to lines from first */
    v[0] = PVector.sub(p_1[0], PVector.add(p, PVector.mult(othogonalToDirection, -this.vertexes[index].getRadius())));
    v[2] = PVector.sub(p_1[2], PVector.add(p, PVector.mult(othogonalToDirection,  this.vertexes[index].getRadius())));
    v[0].normalize();
    v[2].normalize();
     
    /* Using the six lines to compute the nine points */
    PVector point;
     for (int i = 0; i < 3; ++i) {
      for (int j = 0; j < 3; ++j) {
        point = lineIntersection(u[i], p_0[i], v[j], p_1[j]);
        this.vertexes[index].setIntersection(i, j, point);
      }
    }
    
  }
  
  public void moveVertex(int index, PVector newPosition) {
    /* Validate input parameters */
    if (index < 0 || index >= this.order) {
      println("Invalid index to move a Variable");
      return;
    }
    if (newPosition == null) {
      println("Invalid position to move a Variable");
      return;
    }
    
    /* Get the index of the two adjacent vertexes to this one */
    int first = -1;
    int second = -1;  
    for (int i = 0; i < this.size; ++i) {
      if (this.adjacenceMatrix[index][i] && first == -1) {
        first = i;
      } else if (this.adjacenceMatrix[index][i]) {
        second = i;
      }
    }
    if (index == 0 || index == (this.order - 1)) {
      int tmp = first;
      first = second;
      second = tmp;
    }
    PVector pFirst = this.vertexes[first].getPosition();
    PVector pSecond = this.vertexes[second].getPosition();
      
    /* Make sure the new position is different enough 
      and make also sure that we don't loos the general position condition  */  
    PVector diff = PVector.sub(this.vertexes[index].getPosition(), newPosition);
    boolean colinear = abs((pFirst.y - pSecond.y) * (pFirst.x - newPosition.x) - (pFirst.y - newPosition.y) * (pFirst.x - pSecond.x)) < EPSILON;
    if (diff.magSq() > EPSILON && !colinear) {
      this.vertexes[index].setPosition(newPosition);
      /* Recalculate the intersection points */
      for (int i = 0; i < this.size; ++i) {
         intersectionPoints(i);
      }
    } else {
      println("Impossible position to move a Variable");
      return;
    }
    
  }
  
  public void changeVertexType(int index, int type) {
    /* Validate input parameters */
    if (index < 0 || index >= this.order) {
      println("Invalid index to change a Variable");
      return;
    }
    if (type < 0 || type >= 4) {
      println("Invalid type to assign as a Variable");
      return;
    }
    
    /* Change the vertex type */
    if (type != this.vertexes[index].getType()) {
      this.vertexes[index].setType(type);
    }
  }
  
  public void changeVertexRadius(int index, float newRadius) {
    /* Validate input parameters */
    if (index < 0 || index >= this.order) {
      println("Invalid index to change a Variable's radius");
      return;
    }
    if (newRadius < EPSILON) {
      println("Invalid radius to assign as a Variable");
      return;
    }
    
    this.vertexes[index].setRadius(newRadius);
    /* Recalculate the intersection points */
    for (int i = 0; i < this.size; ++i) {
      intersectionPoints(i);
    }
    
  }
  
  private static final float EPSILON = 0.0001; 
  
}