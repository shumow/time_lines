float min_vel = 20.0;
float max_vel = 50.0;

float min_length = 100;
float max_length = 500;

float min_chronoton_radius = 2.5;
float max_chronoton_radius = 7.5;

float delta_chronoton_radius = max_chronoton_radius - min_chronoton_radius;

float time_line_spawn_probability = 0.9;

float chronoton_spawn_probability = 0.4;

class Chronoton {
  Vector direction;
  Vector pos;
  float v;
  
  TimeLine src_tl;
  
  color c;
  
  float t;
  
  boolean off_screen;
  
  public Chronoton(TimeLine src_tl) {
    this.src_tl = src_tl;
    
    Vector src_dir = src_tl.direction();
    
    this.direction = new Vector(src_dir.x-src_dir.y, src_dir.y+src_dir.x);
    
    Vector src_pos = src_tl.position();
    
    this.pos = new Vector(src_pos.x, src_pos.y);
    
    this.v = src_tl.velocity();
    
    this.c = src_tl.get_color();
    
    this.t = 0;
    
    this.off_screen = false;
  }
  
  public void update(float dt) {
    t += dt;
    float d = v*dt;
    
    pos.x += d*direction.x;
    pos.y += d*direction.y;
    
    if ((pos.x < 0) || (width < pos.x) || (pos.y < 0) || (height < pos.y)) {
      this.off_screen = true;
    }
  }
  
  public void draw() {
    float radius = min_chronoton_radius + delta_chronoton_radius*(1+ sin(t))/2;
    pushStyle();
      noStroke();
      fill(this.source().get_color());
      ellipse(pos.x, pos.y, 2*radius, 2*radius);
    popStyle();
  }
  
  public boolean is_off_screen() {
    return this.off_screen; 
  }
  
  public Vector position() {
    return pos;
  }
  
  public TimeLine source() {
    return src_tl;
  }
}

class TimeLine {

  Vector direction;
  Vector pos;
  Vector dim;
  float v;
  float l;
  
  color c;

  boolean off_screen;
  
  Chronoton chrono;
  
  Chronoton entangled_chrono;
  
  public TimeLine(Vector dir, float v, Vector pos, color c, float l, Vector dim) {
    this.direction = dir;
    this.pos = pos;
    this.dim = dim;
    this.c = c;
    this.v = v;
    this.l = l;
    
    off_screen = false;
    
    chrono = null;
    entangled_chrono = null;
  }
  
  public void update(float dt) {
    float d = this.velocity()*dt;
    pos.x += d*direction.x;
    pos.y += d*direction.y;
  }
  
  public void draw() {
    Vector end_pos = new Vector(pos.x - l*direction.x, pos.y - l*direction.y);
    //end_pos.x = max(0, end_pos.x);
    //end_pos.y = max(0, end_pos.y);
    
    //Vector start_pos = new Vector(min(pos.x, dim.x), min(pos.y, dim.y));
    Vector start_pos = new Vector(pos.x, pos.y);
    
    //print("" + start_pos.x + " " + start_pos.y + " " + end_pos.x + " " + end_pos.y + "\n");
    
    pushStyle();
      stroke(this.get_color());
      strokeWeight(2);
      line(end_pos.x, end_pos.y, start_pos.x, start_pos.y);
    popStyle();
    
    if ((width < end_pos.x) || (height < end_pos.y)) {
      off_screen = true;
    }
  }
  
  public boolean is_off_screen() {
    return this.off_screen;
  }
  
  private color get_color(TimeLine src) {
    if ((null != this.entangled_chrono) && (src != this.entangled_chrono.source())){
      return this.entangled_chrono.source().get_color(src);
    } else {
      return this.c;
    }    
  }
  
  public color get_color() {
    return this.get_color(this);
  }
  
  public Vector direction() {
    return this.direction;
  }
  
  public Vector position() {
    return this.pos;
  }
  
  private float velocity(TimeLine src) {
    if ((null != this.entangled_chrono) && (src != this.entangled_chrono.source())) {
      return this.entangled_chrono.source().velocity(src);
    } else {
      return this.v;
    }    
  }
  
  public float velocity() {
    return this.velocity(this);
  }
  
  public Chronoton spawn_chronoton() {
    this.chrono = new Chronoton(this);
    return this.chrono;
  }
  
  public boolean has_spawned_chronoton() {
    return (this.chrono != null);
  }

  private void entangle(Chronoton c, TimeLine src) {
    if ((null != this.entangled_chrono) && (this.entangled_chrono.source() != src)) {
      this.entangled_chrono.source().entangle(c, src);
    }
    this.entangled_chrono = c;
  }
  
  public void entangle(Chronoton c) {
    this.entangle(c, this);
  }
  

}

TimeLine random_time_line(int w, int h) {
    float d = sqrt(w*w + h*h);
    Vector direction = new Vector((float)w/d,(float)h/d);
    Vector position;
    Vector dimension = new Vector(w, h);
    
    int r = (int)random(0, w+h);
    
    r = r - (r%40);
    
    if (r < w) {
      position = new Vector(r, 0);
    } else {
      position = new Vector(0, r-w);
    }
    
    float l = random(min_length, max_length);
    float v = random(min_vel, max_vel);
    
    color c = color(random(255), random(255), random(255));
    
    /*
    println("d = "  + d);
    println("direction = " + direction.x + " " + direction.y);
    println("position = " + position.x + " " + position.y);
    println("dimension = " + dimension.x + " " + dimension.y);
    println("l = " + l);
    println("v = " + v);
    println("c = " + hex(c));
    */
    return new TimeLine(direction, v, position, c, l, dimension);    
}

ArrayList<TimeLine> tls;
ArrayList<Chronoton> chronos;

int last_millis;

void setup() {
  size(800, 600, P2D);
  tls = new ArrayList<TimeLine>();
  chronos = new ArrayList<Chronoton>();
  last_millis = millis();
}

int cnt = 0;

void draw() {
  cnt++;
  pushStyle();
    fill(255);
    noStroke();
    rect(0,0,width,height);
  popStyle();
  int cur_millis = millis();
  float dt = (cur_millis - last_millis)/1000.0;
  last_millis = cur_millis;
  
  for (int i = 0; i < tls.size(); i++)
  {
    TimeLine tl = tls.get(i);
    
    tl.update(dt);
    tl.draw();
    
    if (tl.is_off_screen()) {
      tls.remove(i);
    } else {
      if (!tl.has_spawned_chronoton())
      {
        if (random(1) < dt*chronoton_spawn_probability) {
          //println("adding new chronoton.");
          Chronoton c = tl.spawn_chronoton();
          chronos.add(c);
        }
      }
    }
  }
  
  if (random(1) < (dt*time_line_spawn_probability)) {
    TimeLine tl = random_time_line(width, height);
    tls.add(tl);
    //println("count since last spawn: " + cnt);
    cnt = 0;
  }
  
  for (int i = 0; i < chronos.size(); i++)
  {
    Chronoton c = chronos.get(i);
    boolean remove = false;
    
    c.update(dt);
    c.draw();
    
    for (TimeLine tl : tls) {
      if (tl != c.source()) {
        if (vector_distance(tl.position(), c.position()) <= max_chronoton_radius) {
          //println("entangle!");
          tl.entangle(c);
          remove = true;
        }
      }
    }
    
    if (c.is_off_screen()) {
      remove = true;
    }

    if (remove) {
      chronos.remove(i);
    }    
  }
}
