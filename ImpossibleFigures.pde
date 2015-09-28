Figure testFigure[];
Figure jorge;
int customType;
boolean single;
int renderType;
float customRadius;

void setup () {
  size(512, 512);
  noFill();
  smooth(8);
  /* Change to radious mode is easier for us to make calculations on it */
  ellipseMode(RADIUS);
  recreateFigures();
  single = true;
  renderType = 0;
  customType = 0;
  customRadius = 50.0;
}

void draw () {
   background(0.15);
   if (single) {
     switch(renderType) {
       case 0:
       jorge.render();
       break;
       case 1:
       jorge.renderAsGraph();
       break;
       case 2:
       jorge.renderSolid();
       break;
     }
   } else {
     for (int i = 0; i < testFigure.length; i++) {
       testFigure[i].render();
     }
   }
}

void recreateFigures() {
  jorge = new  Figure(4);
  jorge.setPosition(new PVector(width / 2, height / 2));
  float diameter = max(width, height);
  jorge.setInnerRadio(diameter / 6);
  jorge.setOutterRadio(diameter / 3);
  //jorge.moveVertex(2, new PVector(width / 2, height / 7));
  
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
    renderType++;
    renderType %= 3;
  }
}