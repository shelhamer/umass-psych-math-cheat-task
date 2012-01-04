import controlP5.*;

/* =Interface
-------------------------------*/

ControlP5 cp5;

Textlabel eqLabel;
Textlabel rightLabel;
Textlabel wrongLabel;

Textfield answerText;
Button submitButton;

public color BG_COLOR = color(250, 250, 250);
public color RIGHT_COLOR = color(31, 95, 31);
public color WRONG_COLOR = color(255, 0, 0);
public color IF_BG = color(236, 236, 236);
public color IF_FG = color(220, 220, 220);
public color IF_LABEL = color(0, 0, 0);
public color IF_VALUE = color(0, 0, 0);
public color IF_ACTIVE = color(232, 47, 47);

/* =Experiment
-------------------------------*/

void setup() {
  // set up app window
  size(600, 600);
  frameRate(25);

  // create interface
  cp5 = new ControlP5(this);

  eqLabel = cp5.addTextlabel("equation", "++++", 200, 240);
  rightLabel = cp5.addTextlabel("right", "Correct", 290, 180);
  wrongLabel = cp5.addTextlabel("wrong", "Incorrect - Please Try Again", 230, 180);

  answerText = cp5.addTextfield("answer", 260, 280, 35, 20);
  submitButton = cp5.addButton("submit", 0, 310, 280, 50, 20);

  cp5.setColorForeground(IF_FG);
  cp5.setColorBackground(IF_BG);
  cp5.setColorLabel(IF_LABEL);
  cp5.setColorValue(IF_VALUE);
  cp5.setColorActive(IF_ACTIVE);

  rightLabel.setColorValue(RIGHT_COLOR);
  wrongLabel.setColorValue(WRONG_COLOR);

  // rightLabel.setVisible(false);
  // wrongLabel.setVisible(false);
}

void draw() {
  background(BG_COLOR);
}

// answer textfield event handler
// check submitted answer, inform subject, continue or repeat if right/wrong
public void textAnswer(String val) {
  println("answer submitted : "+ val);
}

// cheat keypress handler
// show answer once space bar is pressed
public void keyPressed() {
  if (key == ' ') {
    println("space pressed");
  }
}