AGSScriptModule        Mt  // new module script

#region MATHS_EXTENSIONS
// ---- START OF MATHS EXTENSIONS ----------------------------------------------
float Abs(float f){
  if(f<0.0) return -f;
  return f;
}

// ---- END OF MATHS EXTENSIONS ------------------------------------------------
#endregion //MATHS_EXTENSIONS

#region STRING_EXTENSIONS
// ---- START OF STRING EXTENSIONS ---------------------------------------------
int CountToken(this String*, String token){
  String sub = this.Copy();
  int count = 0;
  int cur = 0;
  int next = 0;

  while(sub.Length > 0){
    if(sub.IndexOf(token)==-1){
      return count;
    }

    sub = sub.Substring(sub.IndexOf(token)+token.Length, sub.Length);
    count++;
  }
  return count;
}

String[] Split(this String*, String token){
  int count = this.CountToken(token);

  if(count<=0){
    String r[] = new String[1];
    r[0] = null;
    return r;
  }

  String r[] = new String[count+2];
  String sub = this.Copy();

  int i = 0;
  int cur = 0;

  while(i < count){
    cur = sub.IndexOf(token);
    if(cur==-1) cur=sub.Length;

    r[i] = sub.Substring(0, cur);

    sub = sub.Substring(sub.IndexOf(token)+token.Length, sub.Length);

    i++;
  }
  r[i] = sub.Substring(0, sub.Length);
  i++;
  r[i] = null;
  return  r;
}

// ---- END OF STRING EXTENSIONS -----------------------------------------------
#endregion //STRING_EXTENSIONS



Vec3* Quat::get_AsVec3(){
  Vec3* v = new Vec3;
  v.x = this.x;
  v.y = this.y;
  v.z = this.z;
  return v;
}

Quat* Vec3::get_AsQuat(){
  Quat* q = new Quat;
  q.x = this.x;
  q.y = this.y;
  q.z = this.z;
  return q;
}

#region VEC3_METHODS
// ---- START OF VEC3 METHODS --------------------------------------------------

static Vec3* Vec3::Create(float x, float y, float  z){
  Vec3* v = new Vec3;
  v.x = x;
  v.y = y;
  v.z = z;
  return v;
}

String Vec3::get_AsString(){
  return String.Format("(%f, %f, %f)", this.x,this.y,this.z);
}

Vec3* Vec3::Set(float x, float y, float  z){
  this.x = x;
  this.y = y;
  this.z = z;
  return this;
}

Vec3* Vec3::Clone(){
  Vec3* v = new Vec3;
  v.x = this.x;
  v.y = this.y;
  v.z = this.z;
  return v;
}

Vec3* Vec3::Add(Vec3* v){
  Vec3* u = new Vec3;
  u.x = this.x + v.x;
  u.y = this.y + v.y;
  u.z = this.z + v.z;
  return u;
}

Vec3* Vec3::AddQuat(Quat* q){
  Vec3* u = new Vec3;
  u.x = this.x + q.x;
  u.y = this.y + q.y;
  u.z = this.z + q.z;
  return u;
}

Vec3* Vec3::Sub(Vec3* v){
  Vec3* u = new Vec3;
  u.x = this.x - v.x;
  u.y = this.y - v.y;
  u.z = this.z - v.z;
  return u;
}

Vec3* Vec3::SubQuat(Quat* q){
  Vec3* u = new Vec3;
  u.x = this.x - q.x;
  u.y = this.y - q.y;
  u.z = this.z - q.z;
  return u;
}

Vec3* Vec3::Mul(Vec3* v){
  Vec3* u = new Vec3;
  u.x = this.x * v.x;
  u.y = this.y * v.y;
  u.z = this.z * v.z;
  return u;
}

Vec3* Vec3::MulQuat(Quat* q){
  Vec3* u = new Vec3;
  u.x = this.x * q.x;
  u.y = this.y * q.y;
  u.z = this.z * q.z;
  return u;
}

Vec3* Vec3::Div(Vec3* v){
  Vec3* u = new Vec3;
  u.x = this.x / v.x;
  u.y = this.y / v.y;
  u.z = this.z / v.z;
  return u;
}

Vec3* Vec3::DivQuat(Quat* q){
  Vec3* u = new Vec3;
  u.x = this.x / q.x;
  u.y = this.y / q.y;
  u.z = this.z / q.z;
  return u;
}


Vec3* Vec3::Scale(float s){
  Vec3* u = new Vec3;
  u.x = this.x * s;
  u.y = this.y * s;
  u.z = this.z * s;
  return u;
}

float Vec3::get_Length(){
  return Maths.Sqrt(this.x * this.x + this.y * this.y + this.z * this.z);
}

Vec3* Vec3::get_Normalize(){
  return this.Scale(1.0/this.get_Length());
}

float Vec3::Distance(Vec3* v){
  Vec3* u = this.Sub(v);
  return u.get_Length();
}

float Vec3::DistanceQuat(Quat* q){
  Vec3* u = this.SubQuat(q);
  return u.get_Length();
}

float Vec3::Dot(Vec3* v){
  return this.x * v.x + this.y * v.y + this.z * v.z;
}

float Vec3::DotQuat(Quat* q){
  return this.x * q.x + this.y * q.y + this.z * q.z;
}

float Vec3::Angle(Vec3* v){
  return Maths.ArcCos(this.Dot(v) / (this.get_Length() + v.get_Length()));
}

float Vec3::AngleQuat(Quat* q){
  return Maths.ArcCos(this.DotQuat(q) / (this.get_Length() + q.AsVec3.get_Length()));
}

Vec3* Vec3::Cross(Vec3* v){
  Vec3* u = new Vec3;

  float a,b,c;
  a=this.x;
  b=this.y;
  c=this.z;

  u.x = b * v.z - c * v.y;
  u.y = c * v.x - a * v.z;
  u.z = a * v.y - b * v.x;

  return u;
}

Vec3* Vec3::CrossQuat(Quat* q){
  Vec3* u = new Vec3;

  float a,b,c;
  a=this.x;
  b=this.y;
  c=this.z;

  u.x = b * q.z - c * q.y;
  u.y = c * q.x - a * q.z;
  u.z = a * q.y - b * q.x;

  return u;
}

Vec3* Vec3::Lerp(Vec3* v,  float t){
  Vec3* u = new Vec3;
  u.x = this.x + (v.x - this.x) * t;
  u.y = this.y + (v.y - this.y) * t;
  u.z = this.z + (v.z - this.z) * t;
  return u;
}

Vec3* Vec3::Project(Vec3* v){
  Vec3* vnorm = v.Normalize;
  float dot = this.Dot(vnorm);
  Vec3* u = new Vec3;
  u.x = vnorm.x * dot;
  u.y = vnorm.y * dot;
  u.z = vnorm.z * dot;
  return u;
}

Vec3* Vec3::Rotate(Quat* q){
  Vec3* u, o, c;

  u = Vec3.Create(q.x, q.y, q.z);
  o=this.Clone();
  c=u.Cross(this);
  float uu = u.Dot(u);
  float uthis = u.Dot(this);
  o=o.Scale(q.w * q.w - uu);
  u=u.Scale(2.0 * uthis);
  c=c.Scale(2.0 * q.w);
  return o.Add(u.Add(c));
}

// ---- END OF VEC3 METHODS ----------------------------------------------------
#endregion //VEC3_METHODS

#region QUAT_METHODS
// ---- START OF QUAT METHODS --------------------------------------------------

static Quat* Quat::Create(float x, float y, float  z, float  w){
  Quat* v = new Quat;
  v.x = x;
  v.y = y;
  v.z = z;
  v.w = w;
  return v;
}

String Quat::get_AsString(){
  return String.Format("(%f, %f, %f, %f)", this.x,this.y,this.z,this.w);
}

Quat* Quat::Set(float x, float y, float  z, float  w){
  this.x = x;
  this.y = y;
  this.z = z;
  this.w = w;
  return this;
}

Quat* Quat::Clone(){
  Quat* v = new Quat;
  v.x = this.x;
  v.y = this.y;
  v.z = this.z;
  v.w = this.w;
  return v;
}

Quat* Quat::Add(Quat* q){
  Quat* u = new Quat;
  u.x = this.x + q.x;
  u.y = this.y + q.y;
  u.z = this.z + q.z;
  u.w = this.w + q.w;
  return u;
}

Quat* Quat::AddVec3(Vec3* v){
  Quat* u = new Quat;
  u.x = this.x + v.x;
  u.y = this.y + v.y;
  u.z = this.z + v.z;
  u.w = this.w;
  return u;
}

Quat* Quat::Sub(Quat* q){
  Quat* u = new Quat;
  u.x = this.x - q.x;
  u.y = this.y - q.y;
  u.z = this.z - q.z;
  u.w = this.w - q.w;
  return u;
}

Quat* Quat::SubVec3(Vec3* v){
  Quat* u = new Quat;
  u.x = this.x - v.x;
  u.y = this.y - v.y;
  u.z = this.z - v.z;
  u.w = this.w;
  return u;
}

Quat* Quat::Mul(Quat* q){
  Quat* u = new Quat;
  float qx,  qy, qz, qw;
  float rx,  ry, rz, rw;
  qx=this.x;
  qy=this.y;
  qz=this.z;
  qw=this.w;
  rx=q.x;
  ry=q.y;
  rz=q.z;
  rw=q.w;

  u.x = qx * rw + qw * rx + qy * rz - qz * ry;
  u.y = qy * rw + qw * ry + qz * rx - qx * rz;
  u.z = qz * rw + qw * rz + qx * ry - qy * rx;
  u.w = qw * rw - qx * rx - qy * ry - qz * rz;

  return u;
}

Quat* Quat::MulVec3(Vec3* v){
  Quat* u = new Quat;
  float qx,  qy, qz, qw;
  float rx,  ry, rz, rw;
  qx=this.x;
  qy=this.y;
  qz=this.z;
  qw=this.w;
  rx=v.x;
  ry=v.y;
  rz=v.z;

  u.x = qx * rw + qw * rx + qy * rz - qz * ry;
  u.y = qy * rw + qw * ry + qz * rx - qx * rz;
  u.z = qz * rw + qw * rz + qx * ry - qy * rx;
  u.w = qw * rw - qx * rx - qy * ry - qz * rz;

  return u;
}

Quat* Quat::Scale(float s){
  Quat* u = new Quat;
  u.x = this.x * s;
  u.y = this.y * s;
  u.z = this.z * s;
  u.w = this.w * s;
  return u;
}

float Quat::get_Length(){
  return Maths.Sqrt(this.x * this.x + this.y * this.y + this.z * this.z);
}

Quat* Quat::get_Normalize(){
  return this.Scale(1.0/this.get_Length());
}

float Quat::Distance(Quat* q){
  Quat* u = this.Sub(q);
  return u.get_Length();
}

float Quat::DistanceVec3(Vec3* v){
  Quat* u = this.SubVec3(v);
  return u.get_Length();
}

float Quat::Dot(Quat* q){
  return this.x * q.x + this.y * q.y + this.z * q.z + this.w * q.w;
}

float Quat::DotVec3(Vec3* v){
  return this.x * v.x + this.y * v.y + this.z * v.z ;
}

float Quat::Angle(Quat* q){
  return Maths.ArcCos(this.Dot(q) / (this.get_Length() + q.get_Length()));
}

float Quat::AngleVec3(Vec3* v){
  return Maths.ArcCos(this.DotVec3(v) / (this.get_Length() + v.get_Length()));
}

Quat* Quat::Lerp(Quat* q,  float t){
  Quat* u = new Quat;
  u.x = this.x + (q.x - this.x) * t;
  u.y = this.y + (q.y - this.y) * t;
  u.z = this.z + (q.z - this.z) * t;
  u.w = this.w + (q.w - this.w) * t;
  return u;
}

Quat* Quat::LerpVec3(Vec3* v,  float t){
  Quat* u = new Quat;
  u.x = this.x + (v.x - this.x) * t;
  u.y = this.y + (v.y - this.y) * t;
  u.z = this.z + (v.z - this.z) * t;
  u.w = this.w;
  return u;
}

Quat* Quat::setAngleAxis(float angle){
  float s = Maths.Sin(angle * 0.5);
  float c = Maths.Cos(angle * 0.5);
  Quat* q = this.Clone();
  q.x = q.x*s;
  q.y = q.y*s;
  q.z = q.z*s;
  q.w = c;
  return q;
}

Quat* Quat::getAngleAxis(){
  Quat* q;

  if(this.w > 1.0 || this.w < -1.0)
    q = this.Normalize;

  float s = Maths.Sqrt(1.0 - q.w * q.w);
  if(s<0.0001){
    s = 1.0;
  } else {
    s = 1.0/s;
  }

  Quat* rq = new Quat;

  rq.x  = 2.0 * Maths.ArcCos(q.w);
  rq.y = q.x * s;
  rq.z = q.y * s;
  rq.w = q.z * s;

  return rq;
}

// ---- END OF QUAT METHODS ----------------------------------------------------
#endregion //QUAT_METHODS

#region MATRIX_METHODS
// ---- START OF MATRIX METHODS ------------------------------------------------

Matrix* r1;
Matrix* r2;
Matrix* r3;

Matrix* tT;
Matrix* tS;
Matrix* tR;

Matrix* Matrix::Set(int row, int column, float value){
  if(row>=0 && row<this.row_count &&
     column>=0 && column<this.column_count) {

    this.v[row*this.column_count+column] = value;

    return this;
  }
}

float Matrix::Get(int row, int column){
  return this.v[row*this.column_count+column];
}

static Matrix* Matrix::Create(int rows,  int columns,  MatrixType type,  float value){
  Matrix* m = new Matrix;

  m.row_count = rows;
  m.column_count = columns;
  m.cell_count = rows * columns;

  if(type== eMT_Identity){
    for(int i=0; i<m.row_count; i++){
      for(int j=0; j<m.column_count; j++){
        if(i==j){
          m.Set(i, j, 1.0);
        } else {
          m.Set(i, j, 0.0);
        }
      }
    }
  } else {
    for(int i=0; i<m.row_count; i++){
      for(int j=0; j<m.column_count; j++){
        m.Set(i, j, value);
      }
    }
  }

  return m;
}

static Matrix* Matrix::CreateFromString(String s){
  if(s == null) return null;
  if(s.Length<=3) return null;
  if(!(s.StartsWith("{") && s.EndsWith("}"))) return null;

  s = s.Replace("{","");
  s = s.Substring(0, s.Length-2);

  String s1[]=s.Split("},");

  int row_count=0;
  while(s1[row_count] != null) row_count++;

  s = s.Replace("}","");
  s = s.Replace(" ","");

  String s2[]=s.Split(",");

  int cell_count=0;
  while(s2[cell_count] != null) cell_count++;

  int column_count = cell_count/row_count;

  Matrix* m = new Matrix;

  m.row_count = row_count;
  m.column_count = column_count;
  m.cell_count = cell_count;

  //Display("rc=%d [cc=%d [cells=%d[", row_count, column_count, cell_count);

  for(int i=0; i<m.row_count; i++){
    for(int j=0; j<m.column_count; j++){
      //Display("i=%d, j=%d", i, j);
      //Display("%s[[ %f",s ,s2[i*column_count+j].AsFloat);
      m.Set(i, j, s2[i*column_count+j].AsFloat);
    }
  }

  return m;
}

static Matrix* Matrix::CreateM44(){
  Matrix* m = new Matrix;

  m.row_count = 4;
  m.column_count = 4;
  m.cell_count = 16;

  for(int i=0; i<m.row_count; i++){
    for(int j=0; j<m.column_count; j++){
      if(i==j){
        m.Set(i, j, 1.0);
      } else {
        m.Set(i, j, 0.0);
      }
    }
  }

  return m;
}

String Matrix::get_AsString(){
  String s = "";

  for(int i=0; i<this.row_count; i++){
    s = s.Append("{");
    for(int j=0; j<this.column_count; j++){
      s = s.Append(String.Format("%f",this.Get(i, j)));
      if(j<this.column_count-1) s = s.Append(",");
    }
    if(i<this.row_count-1) s = s.Append("},[");
    else s = s.Append("}");
  }
  s = s.Append("");

  return s;
}

Matrix* Matrix::Clone() {
  Matrix* m = new Matrix;

  m.row_count = this.row_count;
  m.column_count = this.column_count;
  m.cell_count = this.cell_count;

  for(int i=0; i<m.cell_count; i++){
    m.v[i] = this.v[i];
  }

  return m;
}

bool Matrix::isEqual(Matrix* m){
  if(m.row_count != this.row_count) return false;
  if(m.column_count != this.column_count) return false;
  if(m.cell_count != this.cell_count) return false;
  for(int i=0; i<m.row_count; i++){
    for(int j=0; j<m.column_count; j++){
      if(m.Get(i, j)!=this.Get(i, j)) return false;
    }
  }
  return true;
}

Matrix* Matrix::Add(Matrix* m){
  if(m.row_count == this.row_count && m.column_count == this.column_count){
    Matrix* r = new Matrix;
    r.row_count = m.row_count;
    r.column_count = m.column_count;
    r.cell_count = m.cell_count;

    for(int i=0; i<m.row_count; i++){
      for(int j=0; j<m.column_count; j++){
         r.Set(i, j, this.Get(i, j) + m.Get(i, j));
      }
    }

    return r;
  }
  return null;
}

Matrix* Matrix::Sub(Matrix* m){
  if(m.row_count == this.row_count && m.column_count == this.column_count){
    Matrix* r = new Matrix;
    r.row_count = m.row_count;
    r.column_count = m.column_count;
    r.cell_count = m.cell_count;

    for(int i=0; i<m.row_count; i++){
      for(int j=0; j<m.column_count; j++){
         r.Set(i, j, this.Get(i, j) - m.Get(i, j));
      }
    }

    return r;
  }
  return null;
}

Matrix* Matrix::Mul(Matrix* m){
  if(this.column_count == m.row_count){
    Matrix* r = new Matrix;
    r.row_count = this.row_count;
    r.column_count = m.column_count;
    r.cell_count = r.row_count*r.column_count;

    for(int i=0; i<r.row_count; i++){
      for(int j=0; j<r.column_count; j++){
        float cell=0.0;
        for(int k=0; k<m.row_count; k++){
          cell+=this.Get(i, k)*m.Get(k, j);
        }

        r.Set(i, j, cell);
      }
    }
    return r;
  }
  return null;
}

Matrix* Matrix::MulNum(float f) {
  Matrix* r = this.Clone();

  for(int i=0; i<r.cell_count; i++){
    r.v[i] = r.v[i]*f;
  }
  return r;
}

Matrix* Matrix::DivNum(float f) {
  Matrix* r = this.Clone();

  for(int i=0; i<r.cell_count; i++){
    r.v[i] = r.v[i]/f;
  }
  return r;
}

Matrix* Matrix::Pow(int n){
  if(this.row_count != this.column_count){
    return null;
  }

  Matrix* m = this.Clone();
  for(int i=1; i<n; i++){
    m = m.Mul(m);
  }
  return m;
}

float Matrix::MaxCell() {
  float r = this.v[0];

  for(int i=0; i<this.cell_count; i++){
    if(this.v[i]>r) r=this.v[i];
  }

  return r;
}

float Matrix::MinCell() {
  float r = this.v[0];

  for(int i=0; i<this.cell_count; i++){
    if(this.v[i]<r) r=this.v[i];
  }

  return r;
}

float Matrix::Determinant(){
  if(this.row_count != this.column_count){
    return 0.0;
  }

  if(this.row_count == 1) {
    return this.Get(0, 0);
  } else if(this.row_count == 2) {
    return (this.Get(0,0) * this.Get(1,1)) - (this.Get(0,1) * this.Get(1,0));
  } else if(this.row_count == 3) {
    float r=0.0;
    r = r + this.Get(0, 0) * (this.Get(1, 1) * this.Get(2, 2) - this.Get(2, 1) * this.Get(1, 2));
    r = r - this.Get(0, 1) * (this.Get(1, 0) * this.Get(2, 2) - this.Get(1, 2) * this.Get(2, 0));
    r = r + this.Get(0, 2) * (this.Get(1, 0) * this.Get(2, 1) - this.Get(1, 1) * this.Get(2, 0));
    return r;
  } else if(this.row_count == 4){
    float r=0.0;
    r = r + this.Get(0,3) * this.Get(1,2) * this.Get(2,1) * this.Get(3,0) - this.Get(0,2) * this.Get(1,3) * this.Get(2,1) * this.Get(3,0);
    r = r - this.Get(0,3) * this.Get(1,1) * this.Get(2,2) * this.Get(3,0) + this.Get(0,1) * this.Get(1,3) * this.Get(2,2) * this.Get(3,0);
    r = r + this.Get(0,2) * this.Get(1,1) * this.Get(2,3) * this.Get(3,0) - this.Get(0,1) * this.Get(1,2) * this.Get(2,3) * this.Get(3,0);
    r = r - this.Get(0,3) * this.Get(1,2) * this.Get(2,0) * this.Get(3,1) + this.Get(0,2) * this.Get(1,3) * this.Get(2,0) * this.Get(3,1);
    r = r + this.Get(0,3) * this.Get(1,0) * this.Get(2,2) * this.Get(3,1) - this.Get(0,0) * this.Get(1,3) * this.Get(2,2) * this.Get(3,1);
    r = r - this.Get(0,2) * this.Get(1,0) * this.Get(2,3) * this.Get(3,1) + this.Get(0,0) * this.Get(1,2) * this.Get(2,3) * this.Get(3,1);
    r = r + this.Get(0,3) * this.Get(1,1) * this.Get(2,0) * this.Get(3,2) - this.Get(0,1) * this.Get(1,3) * this.Get(2,0) * this.Get(3,2);
    r = r - this.Get(0,3) * this.Get(1,0) * this.Get(2,1) * this.Get(3,2) + this.Get(0,0) * this.Get(1,3) * this.Get(2,1) * this.Get(3,2);
    r = r + this.Get(0,1) * this.Get(1,0) * this.Get(2,3) * this.Get(3,2) - this.Get(0,0) * this.Get(1,1) * this.Get(2,3) * this.Get(3,2);
    r = r - this.Get(0,2) * this.Get(1,1) * this.Get(2,0) * this.Get(3,3) + this.Get(0,1) * this.Get(1,2) * this.Get(2,0) * this.Get(3,3);
    r = r + this.Get(0,2) * this.Get(1,0) * this.Get(2,1) * this.Get(3,3) - this.Get(0,0) * this.Get(1,2) * this.Get(2,1) * this.Get(3,3);
    r = r - this.Get(0,1) * this.Get(1,0) * this.Get(2,2) * this.Get(3,3) + this.Get(0,0) * this.Get(1,1) * this.Get(2,2) * this.Get(3,3);
    return r;
  } else {
    float determinant1, determinant2;
    for (int i = 0; i < this.row_count; i++) {
      float temp = 1.0;
      float temp2 = 1.0;
      for (int j = 0; j < this.column_count; j++) {
          temp *= this.Get((i + j) % this.column_count, j);
          temp2 *= this.Get((i + j) % this.column_count, this.row_count - 1 - j);
      }

      determinant1 += temp;
      determinant2 += temp2;
    }

    return determinant1 - determinant2;
  }
  return 0.0;
}

Quat* Matrix::M44_DoTransform(float px, float py, float pz, float pw){
  float x = px * this.Get(0,0) + py * this.Get(1,0) + pz * this.Get(2,0) + pw * this.Get(3,0);
  float y = px * this.Get(0,1) + py * this.Get(1,1) + pz * this.Get(2,1) + pw * this.Get(3,1);
  float z = px * this.Get(0,2) + py * this.Get(1,2) + pz * this.Get(2,2) + pw * this.Get(3,2);
  float w = px * this.Get(0,3) + py * this.Get(1,3) + pz * this.Get(2,3) + pw * this.Get(3,3);
  return Quat.Create(x, y, z, w);
}

Quat* Matrix::M44_DoTransformQuat(Quat* q){
  return this.M44_DoTransform(q.x, q.y, q.z, q.w);
}

Matrix* Matrix::M44_Invert(){
  float inv[16];
  float m[16];
  float det;
  int i;

  for (i = 0; i < 16; i++) m[i] = this.v[i];

  inv[0] = m[5]  * m[10] * m[15] -
         m[5]  * m[11] * m[14] -
         m[9]  * m[6]  * m[15] +
         m[9]  * m[7]  * m[14] +
         m[13] * m[6]  * m[11] -
         m[13] * m[7]  * m[10];

  inv[4] = -m[4]  * m[10] * m[15] +
            m[4]  * m[11] * m[14] +
            m[8]  * m[6]  * m[15] -
            m[8]  * m[7]  * m[14] -
            m[12] * m[6]  * m[11] +
            m[12] * m[7]  * m[10];

  inv[8] = m[4]  * m[9] * m[15] -
           m[4]  * m[11] * m[13] -
           m[8]  * m[5] * m[15] +
           m[8]  * m[7] * m[13] +
           m[12] * m[5] * m[11] -
           m[12] * m[7] * m[9];

  inv[12] = -m[4]  * m[9] * m[14] +
             m[4]  * m[10] * m[13] +
             m[8]  * m[5] * m[14] -
             m[8]  * m[6] * m[13] -
             m[12] * m[5] * m[10] +
             m[12] * m[6] * m[9];

  inv[1] = -m[1]  * m[10] * m[15] +
            m[1]  * m[11] * m[14] +
            m[9]  * m[2] * m[15] -
            m[9]  * m[3] * m[14] -
            m[13] * m[2] * m[11] +
            m[13] * m[3] * m[10];

  inv[5] = m[0]  * m[10] * m[15] -
           m[0]  * m[11] * m[14] -
           m[8]  * m[2] * m[15] +
           m[8]  * m[3] * m[14] +
           m[12] * m[2] * m[11] -
           m[12] * m[3] * m[10];

  inv[9] = -m[0]  * m[9] * m[15] +
            m[0]  * m[11] * m[13] +
            m[8]  * m[1] * m[15] -
            m[8]  * m[3] * m[13] -
            m[12] * m[1] * m[11] +
            m[12] * m[3] * m[9];

  inv[13] = m[0]  * m[9] * m[14] -
            m[0]  * m[10] * m[13] -
            m[8]  * m[1] * m[14] +
            m[8]  * m[2] * m[13] +
            m[12] * m[1] * m[10] -
            m[12] * m[2] * m[9];

  inv[2] = m[1]  * m[6] * m[15] -
           m[1]  * m[7] * m[14] -
           m[5]  * m[2] * m[15] +
           m[5]  * m[3] * m[14] +
           m[13] * m[2] * m[7] -
           m[13] * m[3] * m[6];

  inv[6] = -m[0]  * m[6] * m[15] +
            m[0]  * m[7] * m[14] +
            m[4]  * m[2] * m[15] -
            m[4]  * m[3] * m[14] -
            m[12] * m[2] * m[7] +
            m[12] * m[3] * m[6];

  inv[10] = m[0]  * m[5] * m[15] -
            m[0]  * m[7] * m[13] -
            m[4]  * m[1] * m[15] +
            m[4]  * m[3] * m[13] +
            m[12] * m[1] * m[7] -
            m[12] * m[3] * m[5];

  inv[14] = -m[0]  * m[5] * m[14] +
             m[0]  * m[6] * m[13] +
             m[4]  * m[1] * m[14] -
             m[4]  * m[2] * m[13] -
             m[12] * m[1] * m[6] +
             m[12] * m[2] * m[5];

  inv[3] = -m[1] * m[6] * m[11] +
            m[1] * m[7] * m[10] +
            m[5] * m[2] * m[11] -
            m[5] * m[3] * m[10] -
            m[9] * m[2] * m[7] +
            m[9] * m[3] * m[6];

  inv[7] = m[0] * m[6] * m[11] -
           m[0] * m[7] * m[10] -
           m[4] * m[2] * m[11] +
           m[4] * m[3] * m[10] +
           m[8] * m[2] * m[7] -
           m[8] * m[3] * m[6];

  inv[11] = -m[0] * m[5] * m[11] +
             m[0] * m[7] * m[9] +
             m[4] * m[1] * m[11] -
             m[4] * m[3] * m[9] -
             m[8] * m[1] * m[7] +
             m[8] * m[3] * m[5];

  inv[15] = m[0] * m[5] * m[10] -
            m[0] * m[6] * m[9] -
            m[4] * m[1] * m[10] +
            m[4] * m[2] * m[9] +
            m[8] * m[1] * m[6] -
            m[8] * m[2] * m[5];

  det = m[0] * inv[0] + m[1] * inv[4] + m[2] * inv[8] + m[3] * inv[12];

  if (det == 0.0)
        return null;

  det = 1.0 / det;

  Matrix* res = new Matrix;

  res.row_count = 4;
  res.column_count = 4;
  res.cell_count = 16;

  for (i = 0; i < 16; i++)
        res.v[i] = inv[i] * det;

  return res;
}

Matrix* Matrix::M44_SetIdentity(){
  Matrix* m = this.Clone();

  for(int i=0; i<m.row_count; i++){
    for(int j=0; j<m.column_count; j++){
      if(i==j){
        m.Set(i, j, 1.0);
      } else {
        m.Set(i, j, 0.0);
      }
    }
  }

  return m;
}

Matrix* Matrix::M44_SetTranslate(float x, float y, float z){
  Matrix* m = this.Clone();

  m.Set(3, 0, x);
  m.Set(3, 1, y);
  m.Set(3, 2, z);

  return m;
}

Matrix* Matrix::M44_SetScale(float x, float y, float z){
  Matrix* m = this.Clone();

  m.Set(0, 0, x);
  m.Set(1, 1, y);
  m.Set(2, 2, z);

  return m;
}

Matrix* Matrix::M44_SetRotateEuler(float x, float y, float z){
  Matrix* m = this.Clone();

  r1.Set(0, 0, 1.0 );
  r1.Set(0, 1, 0.0 );
  r1.Set(0, 2, 0.0 );
  r1.Set(1, 0, 0.0 );
  r1.Set(1, 1, Maths.Cos(x) );
  r1.Set(1, 2, -Maths.Sin(x) );
  r1.Set(2, 0, 0.0 );
  r1.Set(2, 1, Maths.Sin(x) );
  r1.Set(2, 2, Maths.Cos(x) );

  r2.Set(0, 0, Maths.Cos(y) );
  r2.Set(0, 1,  0.0 );
  r2.Set(0, 2, Maths.Sin(y) );
  r2.Set(1, 0,  0.0 );
  r2.Set(1, 1,  1.0 );
  r2.Set(1, 2,  0.0 );
  r2.Set(2, 0, -Maths.Sin(y) );
  r2.Set(2, 1,  0.0 );
  r2.Set(2, 2, Maths.Cos(y) );

  r3.Set(0, 0, Maths.Cos(z) );
  r3.Set(0, 1, -Maths.Sin(z) );
  r3.Set(0, 2, 0.0 );
  r3.Set(1, 0, Maths.Sin(z) );
  r3.Set(1, 1, Maths.Cos(z) );
  r3.Set(1, 2, 0.0 );
  r3.Set(2, 0, 0.0 );
  r3.Set(2, 1, 0.0 );
  r3.Set(2, 2, 1.0 );

  Matrix* rR_1x2 = r1.Mul(r2);
  Matrix* rR = rR_1x2.Mul(r3);

  for(int i=0; i<2; i++){
    for(int j=0; j<2; j++){
       m.Set(i, j, rR.Get(i, j));
    }
  }

  m.Set(0, 3, 0.0 );
  m.Set(1, 3, 0.0 );
  m.Set(2, 3, 0.0 );
  m.Set(3, 0, 0.0 );
  m.Set(3, 1, 0.0 );
  m.Set(3, 2, 0.0 );
  m.Set(3, 3, 1.0 );

  return m;
}

Matrix* Matrix::M44_SetFullTransform(float x, float y, float z, float sx, float sy, float sz, float rx, float ry, float rz){
  tT = tT.M44_SetTranslate(x, y, z);
  tS = tS.M44_SetScale(sx, sy, sz);
  tR = tR.M44_SetRotateEuler(rx, ry, rz);

  Matrix* t1 = tR.Mul(tS);
  t1 = t1.Mul(tT);

  return t1;
}

Matrix* Matrix::M44_SetOrthographicProjection(float left, float right, float bottom, float top, float near, float far){
  Matrix* m = this.Clone();

  for(int i=0; i<m.row_count; i++){
    for(int j=0; j<m.column_count; j++){
      m.Set(i, j, 0.0);
    }
  }

  m.Set(0, 0, 2.0 / (right - left) );
  m.Set(1, 1, 2.0 / (top - bottom) );
  m.Set(2, 2, -(2.0 / (far - near)) );
  m.Set(3, 0, -(right + left) / (right - left) );
  m.Set(3, 1, -(top + bottom) / (top - bottom) );
  m.Set(3, 2, -(far + near) / (far - near) );
  m.Set(3, 3, -1.0 );

  return m;
}

Matrix* Matrix::M44_SetPerspectiveProjection(float fovx, float fovy, float near, float far){
  Matrix* m = this.Clone();

  for(int i=0; i<m.row_count; i++){
    for(int j=0; j<m.column_count; j++){
      m.Set(i, j, 0.0);
    }
  }

  m.Set(0, 0, 1.0 / Maths.Tan(fovx / 2.0) );
  m.Set(1, 1, 1.0 / Maths.Tan(fovy / 2.0) );
  m.Set(2, 2, -(far / (far - near)) );
  m.Set(2, 3, -1.0 );
  m.Set(3, 2, -((far * near) / (far - near)) );

  return m;
}

// ---- END OF MATRIX METHODS --------------------------------------------------
#endregion //MATRIX_METHODS


#region TRANSFORM3D_METHODS
// ---- START OF TRANSFORM3D METHODS -------------------------------------------

void Transform3D::Init(){
  this.X = 0;
  this.Y = 0;
  this.Width = 320;
  this.Height = 180;
  this.CamToWorld = Matrix.CreateM44();
  this.ProjectMtx = Matrix.CreateM44();
  this.WorldToCam = Matrix.CreateM44();
  this.frustrum_near = 1.0;
  this.frustrum_far = 1000.0;
  this.ndcSize_w = 2.0;
  this.ndcSize_h = 2.0;
  this.surfsize_w = 1.0;
  this.surfsize_h = 1.0;
}

void Transform3D::SetPosition( int x, int y, int  width, int height){
  this.X = x;
  this.Y = y;
  this.Width = width;
  this.Height = height;
}

void Transform3D::SetCameraTransform( Vec3* cam_pos, Vec3* cam_scale, Vec3* cam_rot){
  if(this.CamToWorld == null) this.CamToWorld = Matrix.CreateM44();

  this.CamToWorld = this.CamToWorld.M44_SetFullTransform(
    cam_pos.x, cam_pos.y, cam_pos.z,
    cam_scale.x,  cam_scale.y,  cam_scale.z,
    cam_rot.x, cam_rot.y, cam_rot.z);

  this.WorldToCam = this.CamToWorld.M44_Invert();
}

void Transform3D::SetOrthoProjection(float width, float height, float near, float far){
  if(this.ProjectMtx == null) this.ProjectMtx = Matrix.CreateM44();

  this.frustrum_near = near; //good default is 1
  this.frustrum_far = far; //good default is 1000

  this.ProjectMtx.M44_SetOrthographicProjection(
    -width/2.0, width/2.0, -height/2.0, height/2.0,
    this.frustrum_near, this.frustrum_far);
}

void Transform3D::SetPerspectiveProjection(float fov, float near, float far){
  if(this.ProjectMtx == null) this.ProjectMtx = Matrix.CreateM44();

  float _fov = Maths.DegreesToRadians(fov);
  this.frustrum_near = near; //good default is 1
  this.frustrum_far = far; //good default is 1000

  this.ProjectMtx.M44_SetPerspectiveProjection(fov, fov, this.frustrum_near, this.frustrum_far);
}

void Transform3D::SetSurfaceSize(float width, float height){
  this.surfsize_w = width;
  this.surfsize_h = height;
}

ScreenPoint* Transform3D::WorldToScreen(float x, float y, float z){

  float w = 1.0;

  // world -> view space (camera)
  Quat* view_space = this.WorldToCam.M44_DoTransform( x, y, z, w);

  bool is_visible = (z >= this.frustrum_near && z <= this.frustrum_far);

  // view space -> projection space
  Quat* projection_space = this.ProjectMtx.M44_DoTransformQuat(view_space);

  // at this point if Abs[v.x] > Abs[v.w] or Abs[v.y] > Abs[v.w], then point is outside projection cone
  is_visible = is_visible &&
    (Abs(projection_space.x) > Abs(projection_space.w) ||
     Abs(projection_space.y) > Abs(projection_space.w));

  x = projection_space.x;
  y = projection_space.y;
  z = projection_space.z;
  w = projection_space.w;

  float muldiv = 0.0;
  if(Abs(w) != 0.0) muldiv = 1.0/w;

  x = x * muldiv;
  y = y * muldiv;
  z = z * muldiv;

  // NOTE: at this point visible vertexes lie inside x,y [-1 : 1].
  // NDC Space [0,1] normalized coordinates

  x = (x + this.ndcSize_w * 0.5) / this.ndcSize_w;
  y = (y + this.ndcSize_h * 0.5) / this.ndcSize_h;

  // NDC Space ===> Raster space.
  // Finally convert to pixel coordinates. Don't forget to invert the y coordinate

  ScreenPoint* res = new ScreenPoint;

  res.x = FloatToInt(x * this.surfsize_w);
  res.y = FloatToInt((1.0 - y) * this.surfsize_h);
  res.z = z;
  res.w = w;
  res.is_visible = is_visible;

  return res;
}

// ---- END OF TRANSFORM3D METHODS ---------------------------------------------
#endregion //TRANSFORM3D_METHODS

void game_start() {
  r1 = Matrix.Create(3, 3, eMT_Identity);
  r2 = Matrix.Create(3, 3, eMT_Identity);
  r3 = Matrix.Create(3, 3, eMT_Identity);

  tT = Matrix.CreateM44();
  tS = Matrix.CreateM44();
  tR = Matrix.CreateM44();
}
 <5  // new module header
#define MAX_CELL_COUNT 16

enum MatrixType {
  eMT_None=0,
  eMT_Identity=1,
};

import float Abs(float f);
import String[] Split(this String*, String token);
import int CountToken(this String*, String token);

managed struct Vec3;

managed struct Quat {

  /// x of the quaternion (x,y,z,w).
  float x;

  /// y of the quaternion (x,y,z,w).
  float y;

  /// z of the quaternion (x,y,z,w).
  float z;

  /// w of the quaternion (x,y,z,w).
  float w;

  /// Creates a Quaternion.
  import static Quat* Create(float x=0, float y=0, float z=0, float w=0);

  /// Returns a string "(x, y, z, w)" for printing purposes.
  import readonly attribute String AsString;

  import String get_AsString(); // $AUTOCOMPLETEIGNORE$

  /// Returns a Vec3 representation of the Quaternion.
  import readonly attribute Vec3* AsVec3;

  /// Sets manually the values of the quaternion.
  import Quat* Set(float x=0, float y=0, float  z=0, float  w=0);

  /// Creates a new quaternion that is a copy of the cloned one.
  import Quat* Clone();

  /// Returns a new quaternion which is the sum of this quaternion with quaternion q.
  import Quat* Add(Quat* q);

  /// Returns a new quaternion which is the subtraction of this quaternion with quaternion q.
  import Quat* Sub(Quat* q);

  /// Returns a new quaternion which is the multiplication of this quaternion with quaternion q.
  import Quat* Mul(Quat* q);

  /// Returns a new quaternion which is the multiplication of this quaternion by a scalar s.
  import Quat* Scale(float s);

  /// Returns the Euclidean length of the quaternion.
  import readonly attribute float Length;

  import float get_Length(); // $AUTOCOMPLETEIGNORE$

  /// Returns a normalized copy of this quaternion. Normalize quaternion has length 1 but the same rotation.
  import readonly attribute Quat* Normalize;

  import Quat* get_Normalize(); // $AUTOCOMPLETEIGNORE$

  /// Returns the distance between this quaternion with quaternion q.
  import float Distance(Quat* q);

  /// Returns the dot multiplication of this quaternion with quaternion q.
  import float Dot(Quat* q);

  /// Returns the angle between this quaternion and quaternion q in radians.
  import float Angle(Quat* q);

  /// Linear interpolation by t percent of this quaternion and quaternion q.
  import Quat* Lerp(Quat* q,  float t);

  /// Returns a new quaternion with specified angle, maintaining axis.
  import Quat* setAngleAxis(float angle);

  /// Returns a new quaternion that is a copy of the current, normalized with x set to angle.
  import Quat* getAngleAxis();
};

managed struct Matrix {

  /// Don't modify this number directly. Each element of a matrix.
  float v[MAX_CELL_COUNT];

  /// Don't modify this number directly. The number of rows of a matrix.
  int row_count;

  /// Don't modify this number directly. The number of columns of a matrix.
  int column_count;

  /// Don't modify this number directly. The number of elements of a matrix.
  int cell_count;

  /// Sets the value of a specific row and column (y,x). This function modifyies the matrix you apply it directly.
  import Matrix* Set(int row, int column, float value);

  /// Returns the value of a specific row and column (similar to y,x position of a cell).
  import float Get(int row, int column);

  /// Returns a new matrix with defined rows and columns. You can set a value for all elements or make this matrix identity.
  import static Matrix* Create(int rows,  int columns,  MatrixType type=0,  float value=0);

  /// Returns a new 4x4 identity matrix. Functions preceeded with M44 require a matrix created with this method.
  import static Matrix* CreateM44();

  /// Reads a matrix as a string for printing purposes.
  import readonly attribute String AsString;

  import String get_AsString(); // $AUTOCOMPLETEIGNORE$

  /// Creates a matrix from a string like "{{0,4},{5,2}}".
  import static Matrix* CreateFromString(String s);

  /// Returns a new matrix that is a copy of this one.
  import Matrix* Clone();

  /// Returns true if all elements of the matrix m are equal to this one.
  import bool isEqual(Matrix* m);

  /// Returns a new matrix that is the sum of this matrix with a matrix m.
  import Matrix* Add(Matrix* m);

  /// Returns a new matrix that is the subtraction of this matrix with a matrix m.
  import Matrix* Sub(Matrix* m);

  /// Returns a new matrix that is the multiplication of this matrix with a matrix m.
  import Matrix* Mul(Matrix* m);

  /// Returns a new matrix that is the multiplication of this matrix with a scalar f.
  import Matrix* MulNum(float f);

  /// Returns a new matrix that is the division of this matrix with a scalar f.
  import Matrix* DivNum(float f);

  /// Returns a new matrix that is this matrix multiplied by itself n times. Matrix must be square.
  import Matrix* Pow(int n);

  /// Returns a the determinant of this matrix.
  import float Determinant();

  /// Returns the value of the biggest element of the matrix.
  import float MaxCell();

  /// Returns the value of the smallest element of the matrix.
  import float MinCell();

  /// Returns a point in homogeneous coordinates transformed. Has to be a 4x4 matrix. 
  import Quat* M44_DoTransform(float px, float py, float pz, float pw);

  /// Returns a point in homogeneous coordinates transformed. Has to be a 4x4 matrix. 
  import Quat* M44_DoTransformQuat(Quat* q);

  /// Returns the inverse of this matrix, as a new matrix. Has to be a 4x4 matrix. 
  import Matrix* M44_Invert();

  /// Returns a identity matrix, as a new matrix. Has to be a 4x4 matrix. 
  import Matrix* M44_SetIdentity();

  /// Returns copy of current matrix with translate set to passed position. Has to be a 4x4 matrix. 
  import Matrix* M44_SetTranslate(float x, float y, float z);

  /// Returns copy current matrix with set scaling. Has to be a 4x4 matrix. 
  import Matrix* M44_SetScale(float x, float y, float z);

  /// Returns copy current matrix with rotate set as passed. Has to be a 4x4 matrix. 
  import Matrix* M44_SetRotateEuler(float x, float y, float z);

  /// Returns copy current matrix with translate, rotate and scale set as passed. Has to be a 4x4 matrix. 
  import Matrix* M44_SetFullTransform(float x, float y, float z, float sx, float sy, float sz, float rx, float ry, float rz);

  /// Returns orthographic projection matrix with passed parameters. Has to be a 4x4 matrix.
  import Matrix* M44_SetOrthographicProjection(float left, float right, float bottom, float top, float near, float far);

  /// Returns perspective projection matrix with passed parameters. Has to be a 4x4 matrix.
  import Matrix* M44_SetPerspectiveProjection(float fovx, float fovy, float near, float far);
};


managed struct Vec3 {

  /// x of the triplet (x,y,z).
  float x;

  /// y of the triplet (x,y,z).
  float y;

  /// z of the triplet (x,y,z).
  float z;

  /// Creates a triplet (x,y,z) vector.
  import static Vec3* Create(float x=0, float y=0, float z=0);

  /// Returns a string "(x, y, z)" for printing purposes.
  import readonly attribute String AsString;

  import String get_AsString(); // $AUTOCOMPLETEIGNORE$

  /// Casts this triplet as a quaternion (w=1).
  import readonly attribute Quat* AsQuat;

  /// Set the values of the triplet.
  import Vec3* Set(float x=0, float y=0, float  z=0);

  /// Creates a new vector triplet that is a copy of the cloned one.
  import Vec3* Clone();

  /// Returns a new vector triplet which is the sum of this vector with a vector v.
  import Vec3* Add(Vec3* v);

  /// Returns a new vector triplet which is the sum of this vector with a quaternion q.
  import Vec3* AddQuat(Quat* q);

  /// Returns a new vector triplet which is the subtraction of this vector with a vector v.
  import Vec3* Sub(Vec3* v);

  /// Returns a new vector triplet which is the subtraction of this vector with a quaternion q.
  import Vec3* SubQuat(Quat* q);

  /// Returns a new vector triplet which is the multiplication of this vector with a vector v.
  import Vec3* Mul(Vec3* v);

  /// Returns a new vector triplet which is the multiplication of this vector with a quaternion q.
  import Vec3* MulQuat(Quat* q);

  /// Returns a new vector triplet which is the division of this vector with a vector v.
  import Vec3* Div(Vec3* v);

  /// Returns a new vector triplet which is the division of this vector with a quaternion q.
  import Vec3* DivQuat(Quat* q);

  /// Returns a new quaternion which is the multiplication of this quaternion by a scalar s.
  import Vec3* Scale(float s);

  /// Returns the length (distance to origin) of this vector.  
  import readonly attribute float Length;

  import float get_Length(); // $AUTOCOMPLETEIGNORE$

  /// Returns a copy of this vector, normalized.
  import readonly attribute Vec3* Normalize;

  import Vec3* get_Normalize(); // $AUTOCOMPLETEIGNORE$

  /// Returns the distance between this vector and a vector v.
  import float Distance(Vec3* v);

  /// Returns the distance between this vector and a quaternion q.
  import float DistanceQuat(Quat* q);

  /// Returns the dot multiplication of this vector and a vector v.
  import float Dot(Vec3* v);

  /// Returns the dot multiplication of this vector and a quaternion q.
  import float DotQuat(Quat* v);

  /// Returns the angle between this vector and a vector v.
  import float Angle(Vec3* v);

  /// Returns the angle between this vector and a quaternion q.
  import float AngleQuat(Quat* q);

  /// Returns a vector which is the cross multiplication of this vector with a vector v.
  import Vec3* Cross(Vec3* v);

  /// Returns a vector which is the cross multiplication of this vector with a quaternion q.
  import Vec3* CrossQuat(Quat* q);

  /// Returns a new vector which is the interpolation of percent t between this vector and a vector v.
  import Vec3* Lerp(Vec3* v,  float t);

  /// Returns a new vector that is equivalent of the projection of this vector on a vector v.
  import Vec3* Project(Vec3* v);

  /// Returns a new vector which is the rotate vector of this by a quaternion q.
  import Vec3* Rotate(Quat* q);
};

/// Casts a quaternion to a Vec3. You almost never wants to do this.
import Vec3* get_AsVec3(this Quat*);

/// Casts a Vec3 to quaternion. You almost never wants to do this.
import Quat* get_AsQuat(this Vec3*);

/// Sums a Vec3 from this quaternion. You almost never wants to do this.
import Quat* AddVec3(this Quat*, Vec3* v);

/// Subtracts a Vec3 from this quaternion. You almost never wants to do this.
import Quat* SubVec3(this Quat*, Vec3* v);

/// Multiplies this quaternion by a Vec3. You almost never wants to do this.
import Quat* MulVec3(this Quat*, Vec3* v);

/// Returns distance from this quaternion to a Vec3. You almost never wants to do this.
import float DistanceVec3(this Quat*, Vec3* v);

/// Returns distance the dot product between this quaternion and a Vec3. You almost never wants to do this.
import float DotVec3(this Quat*, Vec3* v);

/// Returns distance the angle between this quaternion and a Vec3. You almost never wants to do this.
import float AngleVec3(this Quat*, Vec3* v);

/// Returns interpolation between this quaternion and a Vec3. You almost never wants to do this.
import Quat* LerpVec3(this Quat*, Vec3* v,  float t);

managed struct ScreenPoint{
  int x;
  int y;
  float z;
  float w;
  bool is_visible;
};


struct Transform3D {

  int X;
  int Y;
  int Width;
  int Height;

  /// The height to section the top of the frustum geometric shape. Default is 1.0.
  float frustrum_near;

  /// The height to section the base of the frustum geometric shape. Default is 1000.0.
  float frustrum_far;

  /// The surface size height. Usually matches final viewport height.
  float surfsize_h;

  /// The surface size width. Usually matches final viewport width.
  float surfsize_w;

  /// The normalized device coordinates height. Default is 2.0.
  float ndcSize_h;

  /// The normalized device coordinates width. Default is 2.0.
  float ndcSize_w;

  /// The camera to world coordinates tranformation matrix.
  Matrix* CamToWorld;

  /// The world to camera coordinates tranformation matrix.
  Matrix* WorldToCam;

  /// The projection matrix.
  Matrix* ProjectMtx;

  /// Initialize a Transform3D object with default values. Call this after istanciating.
  import void Init();

  /// Sets the position of the viewport on screen.
  import void SetPosition( int x, int y, int  width, int height);

  /// Configures the camera transform, positioning the camera, scaling and rotating it.
  import void SetCameraTransform( Vec3* cam_pos, Vec3* cam_scale, Vec3* cam_rot);

  /// Sets the projection matrix for orthogonal projection.
  import void SetOrthoProjection(float width, float height, float near, float far);

  /// Sets the projection matrix for perspective projection. Field of View is in angle and specifies the frustum.
  import void SetPerspectiveProjection(float fov, float near, float far);

  /// Sets the surface size for the view used. This should match the viewport to avoid stretching the resulting image.
  import void SetSurfaceSize(float width, float height);

  /// Returns a world point converted to screen coordinates.
  import ScreenPoint* WorldToScreen(float x, float y, float z);

  //ScreenToWorld(x, y, z, result);
};

 ��f        ej��