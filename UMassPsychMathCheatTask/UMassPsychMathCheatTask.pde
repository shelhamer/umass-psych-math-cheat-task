import controlP5.*; // ControlP5 0.6.12 (prerelease)

/* =Interface
-------------------------------*/

ControlP5 cp5;

ControlGroup introG;
ControlGroup trialG;
ControlGroup blockG;
ControlGroup doneG;

Textarea introText;
Textarea practiceText;
Textarea blockText;
Textarea doneText;

Textlabel eqLabel;
Textlabel answerLabel;
Textlabel rightLabel;
Textlabel wrongLabel;

Textfield answerText;
Button submitButton;

color BG_COLOR = color(250, 250, 250);
color RIGHT_COLOR = color(31, 127, 31);
color WRONG_COLOR = color(255, 0, 0);
color IF_BG = color(236, 236, 236);
color IF_FG = color(220, 220, 220);
color IF_LABEL = color(0, 0, 0);
color IF_VALUE = color(0, 0, 0);
color IF_ACTIVE = color(232, 47, 47);

/* =Experiment
-------------------------------*/

// Application states
final int INTRO = 0;
final int PRACTICE = 1;
final int EXPERIMENT = 2;
final int BLOCK = 3;
final int DONE = 4;
int thisState = INTRO;

boolean nextTrial = false;
float trialEnd;
float TRIAL_PAUSE = 1000;

final int BLOCK_SIZE = 10;

// Questions and answers
ArrayList questions, answers;
String question, answer;

// Response fields
int trialAttempts;
float trialStart, lastStart, trialTime;
float answerTime;
float cheatTime;

// Experiment data collection output
String dataFilePath;
PrintWriter out;

// Prompts
final String INTRO_PROMPT = "The following task is a classic cognitive " +
"experiment that looks at mathematical skills. You will be presented with an " +
"equation that we would like you to solve. It consists of 10 numbers between 1 " +
"and 20 that are to be added or subtracted. The equation will appear on screen " +
"with a response box. Please calculate the correct response as fast as you can, " +
"and enter it into the response box. Hit enter when you are done. You will be " +
"informed whether your answer is correct or incorrect. If it is incorrect, you " +
"will be given the opportunity to respond again until your answer is correct. " +
"Shortly after you answer correctly, the next equation will appear. Altogether " +
"there are 20 such equations, presented in two blocks of ten equations each." +
"\n\n" +
"If you have any questions before you begin, or if any problems arise " +
"throughout the research, alert the experimenter." +
"\n\n" +
"                                         " +
"Please press the SPACE BAR to continue.";

final String PRACTICE_PROMPT = "This is a practice trial. Please enter the " +
"solution to the equation shown. Try submitting a correct and incorrect " +
"answer to see how the feedback changes." +
"\n\n" +
"                     " +
"When satisified with the practice, please press the SPACE BAR to continue" +
"\n" +
"                                                 " +
"and begin the experiment.";

final String BLOCK_PROMPT = "You have completed the first block of " +
"equations." +
"\n\n" +
"Please press the SPACE BAR when you are ready to continue" +
"\n" +
"and complete the second block of equations.";

final String DONE_PROMPT = "Thank you for completing our math task! The " +
"experimenter will now provide you with additional instructions.";

void setup() {
  // set up app window for full screen
  size(screen.width, screen.height);
  frameRate(25);
  frame.setTitle("UMass Amherst Social Psychology Experiment");

  // create interface
  cp5 = new ControlP5(this);

  int groupSize = 600;
  int centerX = Math.round(screen.width / 2.0 - groupSize / 2.0);
  int centerY = Math.round(screen.height / 2.0 - groupSize / 2.0);

  introG = cp5.addGroup("intro", centerX, centerY, groupSize);
  introText = cp5.addTextarea("introText", INTRO_PROMPT, 0, 0, groupSize, groupSize);
  introText.setGroup("intro");

  trialG = cp5.addGroup("trial", centerX, centerY, groupSize);
  practiceText = cp5.addTextarea("pracText", PRACTICE_PROMPT, 0, 200, groupSize, groupSize);
  eqLabel = cp5.addTextlabel("equation", "++++++++++", 10, 40);
  answerLabel = cp5.addTextlabel("answerLabel", "++++++++++", 10, 132);
  rightLabel = cp5.addTextlabel("right", "Correct", 10, 16);
  wrongLabel = cp5.addTextlabel("wrong", "Incorrect - Please Try Again", 10, 16);
  answerText = cp5.addTextfield("answer", 10, 80, 35, 20);
  submitButton = cp5.addButton("submitButton", 10, 50, 80, 50, 20);
  submitButton.setCaptionLabel("Submit");

  answerText.keepFocus(true);
  eqLabel.setGroup("trial");
  answerLabel.setGroup("trial");
  rightLabel.setGroup("trial");
  wrongLabel.setGroup("trial");
  answerText.setGroup("trial");
  submitButton.setGroup("trial");
  practiceText.setGroup("trial");

  blockG = cp5.addGroup("block", centerX, centerY, groupSize);
  blockText = cp5.addTextarea("blockText", BLOCK_PROMPT, 0, 0, groupSize, groupSize);
  blockText.setGroup("block");

  doneG = cp5.addGroup("done", centerX, centerY, groupSize);
  doneText = cp5.addTextarea("doneText", DONE_PROMPT, 0, 0, groupSize, groupSize);
  doneText.setGroup("done");

  PFont pfont = createFont("Verdana", 24, true);
  ControlFont cfont = new ControlFont(pfont);

  introText.valueLabel().setControlFont(cfont);
  practiceText.valueLabel().setControlFont(cfont);
  blockText.valueLabel().setControlFont(cfont);
  doneText.valueLabel().setControlFont(cfont);
  eqLabel.valueLabel().setControlFont(cfont);
  answerLabel.valueLabel().setControlFont(cfont);
  rightLabel.valueLabel().setControlFont(cfont);
  wrongLabel.valueLabel().setControlFont(cfont);
  introText.valueLabel().setControlFontSize(12);
  practiceText.valueLabel().setControlFontSize(12);
  blockText.valueLabel().setControlFontSize(12);
  doneText.valueLabel().setControlFontSize(12);
  eqLabel.valueLabel().setControlFontSize(14);
  answerLabel.valueLabel().setControlFontSize(14);
  rightLabel.valueLabel().setControlFontSize(12);
  wrongLabel.valueLabel().setControlFontSize(12);

  cp5.setColorForeground(IF_FG);
  cp5.setColorBackground(IF_BG);
  cp5.setColorLabel(IF_LABEL);
  cp5.setColorValue(IF_VALUE);
  cp5.setColorActive(IF_ACTIVE);

  introText.setColorBackground(BG_COLOR);
  practiceText.setColorBackground(BG_COLOR);
  blockText.setColorBackground(BG_COLOR);
  doneText.setColorBackground(BG_COLOR);

  rightLabel.setColorValue(RIGHT_COLOR);
  wrongLabel.setColorValue(WRONG_COLOR);

  // start intro interface
  doIntro();
}

void draw() {
  background(BG_COLOR);

  // advance to next trial when necessary
  if (thisState == EXPERIMENT
      && nextTrial
      && (millis() - trialEnd > TRIAL_PAUSE)) {
    nextTrial = false;

    // prepare & display interface
    question = (String) questions.remove(0);
    answer = (String) answers.remove(0);
    showTrial();

    // init response fields
    trialAttempts = 0;
    trialStart = millis(); lastStart = trialStart;
    answerTime = 0; cheatTime = 0;
  }
}

// answer textfield event handler
// check submitted answer, inform subject, continue or repeat if right/wrong
void answer(String val) {
  if (thisState == EXPERIMENT) {
    trialAttempts++;

    if (answer.equals(val)) {
      // right: show subject, pause, then continue
      rightLabel.show();
      wrongLabel.hide();

      if (questions.size() > 0) {
        // advance to next trial as long as there are more
        // or block intermission if 1st block is complete
        nextTrial = true;

        // calculate completion times
        trialEnd = millis();
        trialTime = trialEnd - trialStart;
        answerTime = trialEnd - lastStart;

        // record this trial
        String record = String.format("%.0f,%d,%.0f,%.0f", trialTime, trialAttempts, answerTime, cheatTime);
        out.println(record);
        out.flush();

        // switch to block intermission if block has been completed
        if (questions.size() == BLOCK_SIZE) {
          doBlock();
        }
      } else {
        // conclude experiment when trials are exhausted
        doConclusion();
      }
    } else {
      // wrong: show subject, and allow repeat
      wrongLabel.show();
      rightLabel.hide();

      lastStart = millis();
    }
  }
  else if (thisState == PRACTICE) {
    // show subject right/wrong feedback
    if (answer.equals(val)) {
      rightLabel.show();
      wrongLabel.hide();
    } else {
      wrongLabel.show();
      rightLabel.hide();
    }
  }
}

// submit button event handler
// trigger answer textfield handler
void submitButton(int val) {
  answerText.submit();
}

// keypress handler
// advance through states when space is pressed
void keyPressed() {
  switch (thisState) {
    case INTRO:
      if (key == ' ') {
        doPractice();
      }
      break;

    case PRACTICE:
      if (key == ' ') {
        practiceText.hide(); // end practice by hiding prompt
        doExperiment();
      }
      break;

    case BLOCK:
      if (key == ' ') {
        blockG.hide(); // end block intermission by hiding prompt
        doExperiment();
      }
      break;

    case DONE:
      if (key == ' ') {
        out.close();
        exit();
      }
      break;
  }
}

// mousepress handler
// allow cheating during practice & experiment by pressing mouse
void mousePressed() {
  if (thisState == PRACTICE || thisState == EXPERIMENT) {
    if (mouseButton == RIGHT) {
      cheatTime = millis() - lastStart;
      answerLabel.show();
    }
  }
}

// do intro
void doIntro() {
  // select output file for experiment data
  dataFilePath = selectOutput();
  if (dataFilePath == null)
    exit();
  else
    out = createWriter(dataFilePath);

  // start intro
  showIntro();
  thisState = INTRO;
}

// do practice
void doPractice() {
  thisState = PRACTICE;

  question = "1+2+3+4+5";
  answer = "15";

  practiceText.show();
  showTrial();
}

// do experiment
void doExperiment() {
  thisState = EXPERIMENT;

  // load questions & answers from text file (on first call)
  if (questions == null) {
    questions = new ArrayList();
    answers = new ArrayList();
    BufferedReader reader = createReader("data/questions-answers.txt");
    try {
      String line;
      while ((line = reader.readLine()) != null) {
        String[] parts = line.split("=");
        questions.add(parts[0]);
        answers.add(parts[1]);
      }
    } catch (IOException e) {
    }
  }

  // trigger trial
  nextTrial = true;
}

// do block intermission
void doBlock() {
  // hold next trial and transition state
  nextTrial = false;
  thisState = BLOCK;

  showBlock();
}

// do conclusion
void doConclusion() {
  showConclusion();
  thisState = DONE;
}

// show intro
void showIntro() {
  introG.show();
  trialG.hide();
  blockG.hide();
  doneG.hide();
}

// prepare & show answer interface
void showTrial() {
  eqLabel.setValue(question);
  answerLabel.setValue(answer);
  answerText.clear();

  answerLabel.hide();
  rightLabel.hide();
  wrongLabel.hide();

  introG.hide();
  trialG.show();
}

// show block intermission
void showBlock() {
  trialG.hide();
  blockG.show();
}

// show conclusion
void showConclusion() {
  trialG.hide();
  doneG.show();
}