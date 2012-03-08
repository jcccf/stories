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
  frameRate(15);
  stroke(255,114,0);
  strokeWeight(2);
  fill(0);
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

void mouseClicked() {
  //points.add(new Point(mouseX,mouseY));
  redraw();
  alert(mouseX+" "+mouseY+"hello!");
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
      r += 2;
      node.rdist = r;
      x = int(origin.x + r * cos(theta));
      y = int(origin.y + r * sin(theta));
      console.log(origin.x);
      console.log(origin.y);
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
    
    // TODO discover angles which you shouldn't use
    for (int i = 0; i < total_num; i++) {
      TextNode child_node = node.next_lines().get(i);
      float angle = angle_offset + (i+index_offset) * (2*PI/total_num);
      if (angle > 2*PI) {
        angle -= 2*PI;
      }
      float radius = node.get_radius() + child_node.get_radius();
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
  
  TextNode(String line_text) { 
    this.line_text = line_text;
    this.nexts = new ArrayList();
    location = null; 
    stroke_color = color(random(255), random(255), random(255));
    stroke_weight = 2;
    arc_start = PI*random(-1, 1);
    arc_end = PI*random(-1, 1);
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
    int num_chars = 1;
    String[] words = split(this.line_text, " ");
    String tempString = this.line_text.substring(0, num_chars);
    while (textWidth(tempString) < 1.6 * 24 * ceil(this.line_text.length()/(num_chars-0.0))) {
      num_chars++;
      tempString = this.line_text.substring(0, num_chars);
    }
    this.num_chars = num_chars;
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
      this.twidth = max(this.twidth, textWidth(s));
      this.line_text_splits.add(s);
      line_num++;
      start_index += num_chars + num_extra;
    }

    this.num_lines = line_num;
    this.theight = this.num_lines * 24;
    this.diameter = sqrt(this.twidth*this.twidth + this.theight*this.theight)+8;
    this.radius = this.diameter/2;
  }
  
  void draw(int x, int y) {
    this.location = new Point(x, y);
    draw();
  }
  
  void draw_line_from(Point origin) {
    stroke(this.stroke_color);
    strokeWeight(this.stroke_weight);
    line(origin.x, origin.y, location.x, location.y);
  }

  void draw() {
    int x = this.location.x;
    int y = this.location.y;
    
    int start_index = 0;
    int line_num = 0;
    
    fill(277, 277, 277);
    stroke(this.stroke_color);
    strokeWeight(this.stroke_weight*4);
    arc(x, y, this.diameter, this.diameter, arc_start, arc_end);
    strokeWeight(this.stroke_weight);
    ellipse(x, y, this.diameter, this.diameter);
    
    
    fill(0, 0, 0);
    for (int i = 0; i < this.line_text_splits.size(); i++) {
      text(this.line_text_splits.get(i), x-this.twidth/2, y+(i+1)*24-(this.theight/2));      
    }
  }
  
  void move_further() {
    if (this.parent != null && this.parent.get_location() != null) {
      Point par_loc = this.parent.get_location();
      rdist += 4;
      this.location.x = int(par_loc.x + rdist * cos(theta));
      this.location.y = int(par_loc.y + rdist * sin(theta));
    }
  }
}
