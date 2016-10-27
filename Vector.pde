class Vector {
  public float x;
  public float y;
  
  public Vector (float x, float y) {
    this.x = x;
    this.y = y;
  }
}

float vector_distance(Vector a, Vector b) {
  float t1 = (a.x - b.x);
  float t2 = (a.y - b.y);
  return sqrt(t1*t1 + t2*t2);
}
