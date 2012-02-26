//
// To enable dragging
//

float x = 0; // Global offset
float y = 0; // Global offset
float x_offset_drag, y_offset_drag;
boolean locked = false;
float scaley = 1.0;


void mouseScrolled() {
  if (mouseScroll > 0) {
    scaley += 0.02;
  } else if (mouseScroll < 0) {
    if (scaley > 0.04)
      scaley -= 0.02;
  }
}

void mousePressed() {
  x_offset_drag = mouseX - x;
  y_offset_drag = mouseY - y;
  locked = true;
  cursor(HAND);
}

void mouseDragged() {
  if (locked) {
    x = mouseX - x_offset_drag;
    y = mouseY - y_offset_drag;
  }
}

void mouseReleased() {
  locked = false;
  cursor(ARROW);
}

//
// Init
//

int width = 900;
int height = 544;
TextNode graph;

//
// Functions
//

TextNode getRoot() { return graph; }

void setup() {
  size(width,height);
  PFont fontA = loadFont("Helvetica");
  textFont(fontA, 24);
  graph = new TextNode("Rotten Root");
  //noLoop();
  frameRate(30);
  stroke(255,114,0);
  strokeWeight(2);
  fill(0);
}

void draw() {
  background(245,245,245);
  translate(width/2-350+x,height/2-200+y);
  scale(scaley);
  // line(pt.x,pt.y,next.x+x,next.y+y);
  ellipse(0,0,10,10);
  draw_textnode(graph, 1, 0, 0);
}

int draw_textnode(TextNode n, int level, int j, int y_offset) {
  int next_size = n.next_lines().size();
  int items_drawn = 0;
  for (int i = 0; i < next_size; i++) {
    items_drawn += draw_textnode(n.next_lines().get(i), level+1, i, items_drawn);
    float currX = 250*level;
    float currY = (y_offset+i)*100;
    float prevX = 250*(level-1);
    float prevY = j*100;
    line(prevX, prevY, currX, currY);
    fill(227,227,227);
    ellipse(currX,currY, 30, 30);
    fill(0);
    n.next_lines().get(i).draw(currX+20, currY+8);
  }
  return next_size;
}

void mouseClicked() {
  //points.add(new Point(mouseX,mouseY));
  redraw();
  alert(mouseX+" "+mouseY+"hello!");
}

class TextNode {
  String line;
  ArrayList nexts;
  TextNode(String line) { this.line = line; this.nexts = new ArrayList(); }
  TextNode[] next_lines() { return nexts; }
  void draw(int x, int y) { text(line, x, y); }
  void add_next(TextNode node) { this.nexts.add(node); }
  void set_text(String line) { this.line = line }
}