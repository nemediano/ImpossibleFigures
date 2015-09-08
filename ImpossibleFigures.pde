Figure testFigure[];
Figure jorge;
int customType;
boolean single;
boolean graph;
float customRadius;

void setup () {
  size(800, 800);
  background(0);
  noFill();
  smooth(8);
  /* Change to radious mode is easier for us to make calculations on it */
  ellipseMode(RADIUS);
  recreateFigures();
  single = true;
  graph = false;
  customType = 0;
  customRadius = 50.0;
}

void draw () {
   background(0);
   if (single) {
     if (graph) {
        jorge.renderAsGraph();
     } else { 
        jorge.render();
     }
   } else {
     for (int i = 0; i < testFigure.length; i++) {
       testFigure[i].render();
     }
   }
}

void recreateFigures() {
  jorge = new  Figure(4);
  jorge.setPosition(new PVector(400, 400));
  jorge.setInnerRadio(200);
  jorge.setOutterRadio(300);
  jorge.moveVertex(2, new PVector(400, 350));
  
  testFigure = new Figure[4];
  for (int i = 0; i < testFigure.length; i++) {
    testFigure[i] = new Figure(3 + i);
    testFigure[i].setInnerRadio(100);
    testFigure[i].setOutterRadio(140);  
  }
  
  testFigure[0].setPosition(new PVector(200, 200));
  testFigure[1].setPosition(new PVector(600, 200));
  testFigure[2].setPosition(new PVector(200, 600));
  testFigure[3].setPosition(new PVector(600, 600));
}

void mousePressed() {
  recreateFigures(); 
}

void keyPressed() {
  if (key == 's' || key == 'S') {
    single = !single;
  } else if (key == 'x' || key == 'X') {
    jorge.changeVertexType(2, customType);
    customType++;
    customType %= 4;
    println("The new type: " + customType);
  } else if (key == ',' || key == '<') {
    customRadius -= 10.0;
    jorge.changeVertexRadius(2, customRadius);
  } else if (key == '.' || key == '>') {
    customRadius += 10.0;
    jorge.changeVertexRadius(2, customRadius);
  } else if (key == 'g' || key == 'G') {
    graph = (!graph);
  }
}