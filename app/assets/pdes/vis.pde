//
// Helper Drawing Functions
//
void dashedLine(int dashWidth, int dashSpacing, float x1, float y1, float x2, float y2) {
  int steps = 200;
  int dashPeriod = dashWidth + dashSpacing;
  boolean lastDashed = false;
  float theta = atan2((y2-y1)/(x2-x1));
  for(int i = 0; i < steps; i++) {
    boolean curDashed = (i % dashPeriod) < dashWidth;
    if(curDashed && !lastDashed) {
      beginShape();
    }
    if(!curDashed && lastDashed) {
      endShape();
    }
    if(curDashed) {
      vertex(x1 + (x2-x1)* i/steps, y1 + (y2-y1) * i/steps);
    }
    lastDashed = curDashed;
  }
  if(lastDashed) {
    endShape();
  }
}

// Modified from http://openprocessing.org/sketch/28215
void dashedCircle(float radius, int dashWidth, int dashSpacing, int x, int y) {
    fill(255, 255, 255);
    strokeWeight(0.1);
    ellipse(x, y, radius*2, radius*2);
    strokeWeight(5);
    int steps = 200;
    int dashPeriod = dashWidth + dashSpacing;
    boolean lastDashed = false;
    for(int i = 0; i < steps; i++) {
      boolean curDashed = (i % dashPeriod) < dashWidth;
      if(curDashed && !lastDashed) {
        beginShape();
      }
      if(!curDashed && lastDashed) {
        endShape();
      }
      if(curDashed) {
        float theta = map(i, 0, steps, 0, TWO_PI);
        vertex(cos(theta) * radius + x, sin(theta) * radius + y);
      }
      lastDashed = curDashed;
    }
    if(lastDashed) {
      endShape();
    }
}

//
// To enable dragging
//

float x = 0; // Global offset
float y = 0; // Global offset
float x_offset_drag, y_offset_drag;
boolean locked = false;
float scaley = 1.0;


// void mouseScrolled() {
//   if (mouseScroll > 0) {
//     scaley += 0.02;
//   } else if (mouseScroll < 0) {
//     if (scaley > 0.04)
//       scaley -= 0.02;
//   }
// }

void zoom(float amount) {
  scaley += amount;
}

void moveX(float amount) {
  x += amount;
}

void moveY(float amount) {
  y += amount;
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
LayoutManager lm;

//
// Functions
//

TextNode getRoot() { return graph; }

void setup() {
  size(width,height);
  PFont fontA = loadFont("Helvetica");
  textFont(fontA, 24);
  graph = new TextNode("A soft alligator is loading this graph...");
  //noLoop();
  frameRate(20);
  stroke(255,114,0);
  strokeWeight(2);
  fill(0);
}

void mouseClicked() {
  redraw();
  float realX = (mouseX-x-width/2) / scaley;
  float realY = (mouseY-y-height/2) / scaley;
  TextNode n = find_node(new Point(realX, realY), graph);
  if (n != null) {
    editNode(n);
  }
  // alert(realX+" "+realY+"hello!");
}

// Determine if there exists a TextNode that the target point landed within and return the TextNode
TextNode find_node(Point target, TextNode n) {
  Point loc = n.get_location();
  if (sqrt(pow(loc.x-target.x, 2) + pow(loc.y-target.y, 2)) <= n.get_radius()) return n;
  for (int i = 0; i < n.next_lines().size(); i++) {
    TextNode poss_node = find_node(target, n.next_lines().get(i));
    if (poss_node != null) return poss_node;
  }
  return null;
}

void draw() {
  background(245,245,245);
  translate(width/2+x,height/2+y);
  scale(scaley);
  lm = new LayoutManager();
  lm.set_location_polar(graph, new Point(0, 0), 0, 0);
  graph.set_stroke_weight(6);
  graph.draw();
  draw_textnode(lm, graph);
}

void draw_textnode(LayoutManager lm, TextNode n) {
  lm.add_and_draw_children(n);
  for (int i = 0; i < n.next_lines().size(); i++) {
    draw_textnode(lm, n.next_lines().get(i));
  }
}

class LayoutManager {
  ArrayList nodes;
  
  LayoutManager() { this.nodes = new ArrayList(); }
  
  void set_location_polar(TextNode node, Point origin, int r, int theta) {
    
    int x = 0;
    int y = 0;
    
    if (!node.has_location()) {
      x = int(origin.x + r * cos(theta));
      y = int(origin.y + r * sin(theta));
      node.rdist = r;
      node.theta = theta;
    }
    else {
      x = node.get_location().x;
      y = node.get_location().y;
      r = node.rdist;
      theta = node.theta;
    }
    
    if (is_overlapping(x, y, node.get_radius())) {
      if (node.get_parent() != null) {
        node.get_parent().move_further();
      }
      r += 4;
      node.rdist = r;
      x = int(origin.x + r * cos(theta));
      y = int(origin.y + r * sin(theta));
    }
    
    node.set_location(x, y);
        
    for (int i = 0; i < nodes.size(); i++) {
      if (nodes.get(i) == node) {
        return;
      }
    }
    nodes.add(node);
    
  }
  
  void add_and_draw_children(TextNode node) {
    Point location = node.get_location();
    int total_num = node.next_lines().size();
    int index_offset = 0;
    float angle_offset = 0;
    
    if (node.has_parent()) {
      index_offset = 1;
      angle_offset = node.theta;
    }
    
    for (int i = 0; i < total_num; i++) {
      TextNode child_node = node.next_lines().get(i);
      float angle = PI + angle_offset + (i+index_offset) * (2*PI/(total_num+index_offset)); // + PI because we want it relative to the child, not the parent
      if (angle > 2*PI) {
        angle -= 2*PI;
      }
      float radius = node.get_radius() + child_node.get_radius() + ((i % 2) * 10 * total_num);
      set_location_polar(child_node, location, radius, angle);
      child_node.draw_line_from(location);
    }
    node.draw();
  }
  
  boolean is_overlapping(float x, float y, float radius) {
    for (int i = 0; i < nodes.size(); i++) {
      if (sqrt((x-nodes.get(i).get_location().x)*(x-nodes.get(i).get_location().x) + (y-nodes.get(i).get_location().y)*(y-nodes.get(i).get_location().y)) < radius + nodes.get(i).get_radius() + 20) {
        return true;
      }
    }
    return false;
  }
}

class Point {
  public float x,y;
  Point(float x, float y) { this.x=x; this.y=y; }
}

class TextNode {
  String line_text;
  int elapsed;
  ArrayList nexts;
  TextNode parent;
  int num_chars;
  int num_lines;
  ArrayList line_splits;
  int twidth;
  int theight;
  float diameter;
  float radius;
  Point location;
  public float theta;
  public float rdist;
  color stroke_color;
  int stroke_weight;
  float arc_start;
  float arc_end;
  boolean is_dashed;
  
  TextNode(String line_text) {
    this(line_text, 0, false);
  }
  
  TextNode(String line_text, int elapsed) {
    this(line_text, elapsed, false);
  }
  
  TextNode(String line_text, int elapsed, boolean is_dashed) { 
    this.line_text = line_text;
    this.elapsed = elapsed;
    this.is_dashed = is_dashed;
    this.nexts = new ArrayList();
    location = null; 
    stroke_color = color(random(255), random(255), random(255));
    stroke_weight = 3;
    arc_start = PI*random(-1, 1);
    arc_end = arc_start + 2*PI*(60/this.elapsed); //PI*random(-1, 1);
    if (arc_start > arc_end) {
      float temp = arc_start;
      arc_start = arc_end;
      arc_end = temp;
    }
    setup();
  }
  
  TextNode[] next_lines() { return nexts; }
  void add_next(TextNode node) { this.nexts.add(node); }
  String get_text() { return this.line_text }
  void set_text(String line) { this.line_text = line; setup() }
  boolean has_location() { return (location != null) }
  void set_location(int x, int y) { location = new Point(x, y) }
  Point get_location() { return location }
  float get_radius() { return this.radius }
  void set_parent(TextNode parent) { this.parent = parent }
  void get_parent() { return this.parent }
  boolean has_parent() { return (parent != null) }
  void set_stroke_weight(int weight) { this.stroke_weight = weight }
  void set_stroke_color(color c) { this.stroke_color = c }
  
  void setup() {
    textFont(loadFont("Helvetica"), 24);
    int num_chars = 1;
    String[] words = split(this.line_text, " ");
    String tempString = this.line_text.substring(0, num_chars);
    while (textWidth(tempString) < 1.6 * 24 * ceil(this.line_text.length()/(num_chars-0.0)) && num_chars <= this.line_text.length()) {
      num_chars++;
      tempString = this.line_text.substring(0, num_chars);
    }
    this.line_text_splits = new ArrayList(); 
    this.twidth = 0;
    
    int start_index = 0;
    int line_num = 0;
    while (start_index <= this.line_text.length()) {
      while (this.line_text.substring(start_index,start_index+1) == " ") {
        start_index++;
      }
      
      int num_extra = 0;
      while (start_index+num_chars+num_extra < this.line_text.length() && this.line_text[start_index+num_chars+num_extra-1] != " " && this.line_text[start_index+num_chars+num_extra] != " ") {
        num_extra++;
      }
      int num_less = 0;
      while (start_index+num_chars-num_less-2 > 0 && this.line_text[start_index+num_chars-num_less-2] != " " && this.line_text[start_index+num_chars-num_less-1] != " ") {
        num_less++;
      }
      if (num_less < num_extra) {
        num_extra = -1-num_less;
      }

      String s = this.line_text.substring(start_index, start_index+num_chars+num_extra);
      this.twidth = max(this.twidth, textWidth(s)); // This line relies on the text font, so don't change it!
      this.line_text_splits.add(s);
      line_num++;
      start_index += num_chars + num_extra;
    }

    this.num_lines = line_num;
    this.theight = this.num_lines * 24;
    this.diameter = sqrt(this.twidth*this.twidth + this.theight*this.theight)+8;
    this.radius = this.diameter/2;
    // console.log(num_chars);
    // console.log(this.num_lines);
    // console.log(this.theight);
    // console.log(this.twidth);
    // console.log(this.diameter);
  }
  
  void draw(int x, int y) {
    this.location = new Point(x, y);
    draw();
  }
  
  void draw_line_from(Point origin) {
    stroke(this.stroke_color);
    strokeWeight(this.stroke_weight);
    if (this.is_dashed == true) {
      dashedLine(6, 4, origin.x, origin.y, location.x, location.y);
    }
    else {
      line(origin.x, origin.y, location.x, location.y);
    }
  }

  void draw() {
    int x = this.location.x;
    int y = this.location.y;
    
    int start_index = 0;
    int line_num = 0;
    
    if (this.is_dashed == true && this.line_text_splits.size() == 1 && this.line_text_splits.get(0).length() == 1) {
      textFont(loadFont("Helvetica-Bold"), 36);
      this.radius = 24;
      this.diameter = 48;
    }
    else {
      textFont(loadFont("Helvetica"), 24);
    }
    
    if (this.is_dashed == true) {
      fill(277, 277, 277);
      strokeWeight(0.01);
      ellipse(x, y, this.diameter, this.diameter);
      stroke(this.stroke_color);
      strokeWeight(this.stroke_weight);
      dashedCircle(this.radius, 6, 8, x, y);
    }
    else {
      fill(277, 277, 277);
      stroke(this.stroke_color);
      strokeWeight(this.stroke_weight*4);
      arc(x, y, this.diameter, this.diameter, arc_start, arc_end);
      strokeWeight(this.stroke_weight);
      ellipse(x, y, this.diameter, this.diameter);
    }
    
    if (this.is_dashed == true && this.line_text_splits.size() == 1 && this.line_text_splits.get(0).length() == 1) {
      x -= 4;
      y -= 2;
    }
        
    fill(0, 0, 0);
    // text(this.theta, x, y);
    for (int i = 0; i < this.line_text_splits.size(); i++) {
      text(this.line_text_splits.get(i), x-this.twidth/2, y+(i+1)*24-(this.theight/2));      
    }
    // text(this.radius, x+10, y+10);
    // text(this.line_text, x+10, y+30);
    // text(has_parent(), x, y);
    // text(location.x, x+100, y);
    // text(location.y, x+150, y);
  }
  
  void move_further() {
    if (this.parent != null && this.parent.get_location() != null) {
      Point par_loc = this.parent.get_location();
      rdist += 8;
      this.location.x = int(par_loc.x + rdist * cos(theta));
      this.location.y = int(par_loc.y + rdist * sin(theta));
    }
  }
}