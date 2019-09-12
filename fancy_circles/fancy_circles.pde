//based on the Nothing But Requiem logo
public class Vector {
  public float x;
  public float y;
  public Vector(float x, float y) {
    this.x=x;
    this.y=y;
  }
  public Vector(Vector vec) {
    this.x=vec.x;
    this.y=vec.y;
  }
  public void addVec(Vector vec) {
    x+=vec.x;
    y+=vec.y;
  }
  public void subVec(Vector vec) {
    x-=vec.x;
    y-=vec.y;
  }
  public void sclVec(float scale) {
    x*=scale;
    y*=scale;
  }
  public void nrmVec(){
    sclVec(1/getMag());
  }
  public void nrmVec(float mag){
    sclVec(mag/getMag());
  }
  public void limVec(float lim){
    float mag=getMag();
    if(mag>lim){
      sclVec(lim/mag);
    }
  }
  public float getAng() {
    return atan2(y, x);
  }
  public float getAng(Vector vec) {
    return atan2(vec.y-y, vec.y-x);
  }
  public float getMag() {
    return sqrt(sq(x)+sq(y));
  }
  public float getMag(Vector vec) {
    return sqrt(sq(vec.x-x)+sq(vec.y-y));
  }
  public void rotVec(float rot){
    float mag=getMag();
    float ang=getAng();
    ang+=rot;
    x=cos(ang)*mag;
    y=sin(ang)*mag;
  }
}

class Node{
  Vector pos;
  float rot;
  Circle target;
  Node(Vector p,Circle t,float r){
    pos=new Vector(p);
    target=t;
    rot=r;
  }
  void display(Vector offset,float offRot){
    if(target!=null){
      Vector rotPos=new Vector(pos);
      rotPos.rotVec(offRot);
      Vector realPos=new Vector(rotPos);
      realPos.addVec(offset);
      target.display(realPos,offRot+rot,true);
    }
  }
}
class Line{
  //connections
  Node c1;
  Node c2;
  float thickness;
  Line(Node tc1,Node tc2, float th){
    c1=tc1;
    c2=tc2;
    thickness=th;
  }
  void display(Vector offset,float offRot){
    Vector rotPos1=new Vector(c1.pos);
    rotPos1.rotVec(offRot);
    Vector realPos1=new Vector(rotPos1);
    realPos1.addVec(offset);
    
    Vector rotPos2=new Vector(c2.pos);
    rotPos2.rotVec(offRot);
    Vector realPos2=new Vector(rotPos2);
    realPos2.addVec(offset);
    
    strokeWeight(thickness*zoom);
    line(realPos1.x*zoom,realPos1.y*zoom,realPos2.x*zoom,realPos2.y*zoom);
  }
}
class Circle{
  Vector pos;
  float size;
  float thickness;
  ArrayList<Circle> children;//holds real data of children
  float rot;
  float spin;
  boolean visible;
  
  ArrayList<Node> special;//holds structural data about children;
  ArrayList<Line> lines;
  
  float cornerWide;
  Circle(Vector p, float s, float th,float sp){
    children=new ArrayList<Circle>();
    special=new ArrayList<Node>();
    lines=new ArrayList<Line>();
    pos=new Vector(p);
    size=s;
    thickness=th;
    spin=sp;
    
    visible=true;
  }
  Circle(Vector p, float s, float th,float sp,boolean vis){
    children=new ArrayList<Circle>();
    special=new ArrayList<Node>();
    lines=new ArrayList<Line>();
    pos=new Vector(p);
    size=s;
    thickness=th;
    spin=sp;
    
    visible=vis;
  }
  void move(){
    rot+=spin;
    for(Circle child: children){
      child.move();
    }
  }
  void display(Vector offset,float offRot){
    display(offset,offRot,visible);
  }
  void display(Vector offset,float offRot,boolean vis){
    if(vis){
      Vector rotPos=new Vector(pos);
      rotPos.rotVec(offRot);
      Vector realPos=new Vector(rotPos);
      realPos.addVec(offset);
      strokeWeight(thickness*zoom);
      ellipse(realPos.x*zoom,realPos.y*zoom,size*zoom,size*zoom);
      for(Circle child: children){
        child.display(realPos,rot+offRot);
      }
      for(Node child: special){
        child.display(realPos,rot+offRot);
      }
      for(Line ln: lines){
        ln.display(realPos,rot+offRot);
      }
    }
  }
  void generate(int depth,boolean limited){
    if(size<100){
      return;
    }
    Circle centerSmall=null;
    float chance=0;
    if(size>channel*2){
      boolean birth=false;
      if(depth==1){
        chance=0.9;
      }else if(depth==2){
        chance=0.5;
      }else{
        chance=0.4;
      }
      if(random(0,1)<chance){
        if(size>200){
          if(limited){
            children.add(new Circle(new Vector(0,0),size-channel,3,spin));
          }else{
            children.add(new Circle(new Vector(0,0),size-channel,5,spin));
          }
          birth=true;
        }
      }
      if(depth==1){
        chance=0.9;
      }else if(depth==2){
        chance=0.8;
      }else{
        chance=0.4;
      }
      if(random(0,1)<chance){
        if(limited){
          children.add(new Circle(new Vector(0,0),random((size-channel*2)*0.5,(size-channel*2)*0.8),1.5,spin));
        }else{
          children.add(new Circle(new Vector(0,0),random((size-channel*2)*0.5,(size-channel*2)*0.8),2,spin));
        }
        centerSmall=lastChild();
        birth=true;
      }
      if(birth){
        genLast(depth,limited);
      }
    }
    
    if(limited){
      return;
    }
    
    
    if(depth==1){
      chance=1;
    }else if(depth==2){
      chance=0.1;
    }else{
      chance=0.3;
    }
    
    if(random(0,1)<chance){
      float newThick=1.5;
      
      int nodes=(int)random(4,8);
      float rad=size/2;
      float sizeMax=sqrt(2*(1-cos(TWO_PI/nodes)))*rad;
      
      //this is now the last child which will be used
      cornerWide=random(0.2,0.4)*sizeMax;
      if(size>300){
        children.add(new Circle(new Vector(0,0),cornerWide,2,spin,true));
        genLast(depth,true);
      }else{
        children.add(new Circle(new Vector(0,0),0,0,spin,false));
      }
      
      Node lastAdd=null;
      Node firstAdd=null;
      for(int i=0;i<nodes;i++){
        float tAng=TWO_PI*i/nodes;
        Node newAdd=new Node(new Vector(cos(tAng)*rad,sin(tAng)*rad),lastChild(),tAng);
        special.add(newAdd);
        if(lastAdd!=null){
          lines.add(new Line(lastAdd,newAdd,newThick));
        }else{
          firstAdd=newAdd;
        }
        lastAdd=newAdd;
      }
      lines.add(new Line(firstAdd,lastAdd,newThick));
      if(centerSmall!=null){
        if(depth==1){
          chance=1;
        }else{
          chance=0.8;
        }
        boolean sideChannel=random(0,1)<chance;
        if(depth==1){
          chance=0.8;
        }else{
          if(nodes%2==1){
            chance=0.5;
          }else{
            chance=0;
          }
        }
        if(nodes==4){
          chance=0;
        }
        boolean centerChannel=random(0,1)<chance;
        
        if(sideChannel||centerChannel){
          float tRad=centerSmall.size/2;
          for(int i=0;i<nodes;i++){
            float tAng=TWO_PI*(i+0.5)/nodes;
            Node newAdd=new Node(new Vector(cos(tAng)*tRad,sin(tAng)*tRad),null,tAng);
            special.add(newAdd);
            //lines.add(new Line(special.get(i),newAdd,thickness));
            if(sideChannel){
              lines.add(new Line(special.get(i),newAdd,newThick));
              lines.add(new Line(special.get((i+1)%nodes),newAdd,newThick));
            }
            if(centerChannel){
              lines.add(new Line(special.get((i+ceil(nodes/2f))%nodes),newAdd,newThick));
            }
          }
        }
      }
    }
    if(depth==1){
      chance=1;
    }else{
      chance=0;
    }
    if(random(0,1)<chance){
      float randomCircles=(int)random(3,6);
      float ang=random(0,TWO_PI);
      float wide=size+cornerWide;
      
      for(int i=0;i<randomCircles;i++){
        ang+=TWO_PI/randomCircles*random(0.4,1.6);
        float mag=random(wide/2*0.5,wide/2*0.7);
        float newSize=random(0.6,1)*(wide/2-mag)*2;
        
        children.add(new Circle(new Vector(cos(ang)*mag,sin(ang)*mag),newSize,1.5,spin,true));
        genLast(depth,true);
      }
      
      
    }
  }
  void contain(){
    float wide=size+cornerWide;
    children.add(new Circle(new Vector(0,0),wide,2,spin));
    children.add(new Circle(new Vector(0,0),wide-channel/2,5,spin));
  }
  Circle lastChild(){
    return children.get(children.size()-1);
  }
  void genLast(int depth,boolean limited){
    children.get(children.size()-1).generate(depth+1,limited);
  }
}
float channel=40;
Circle seed= new Circle(new Vector(0,0),600,2,0);
float zoom=0.25;
void setup(){
  size(800,1000);
  noFill();
  background(255);
}
float x=400;
float y=400;
void draw(){
  if(x*zoom>800){
    x=400;
    y+=800;
  }
  //background(255);
  seed= new Circle(new Vector(0,0),600,2,0);
  seed.generate(1,false);
  seed.contain();
  
  seed.move();
  seed.display(new Vector(x,y),0);
  x+=800;
}
