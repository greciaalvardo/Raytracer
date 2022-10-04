class Sphere implements SceneObject
{
    PVector center;
    float radius;
    Material material;
    
    Sphere(PVector center, float radius, Material material)
    {
       this.center = center;
       this.radius = radius;
       this.material = material;
    }
 
    ArrayList<RayHit> intersect(Ray r)
    {
      
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        
        //Create entry and exit RayHit objects
        RayHit entry = new RayHit();
        RayHit exit = new RayHit();
        
        //println(material);
        //trying with dot product
        PVector cSubo = PVector.sub(center, r.origin);
        //println(cSubo);
        float tp = cSubo.dot(r.direction);
        //println(tp);
        float x = PVector.sub(PVector.add(r.origin, PVector.mult(r.direction, tp)), center).mag(); // x = |(o + tp*d - c)|
        //println(r.direction);
        if(x < radius){
            entry.setT(tp - sqrt( pow(radius, 2) - pow(x, 2)));
            exit.setT(tp + sqrt( pow(radius, 2) - pow(x, 2)));
            
            entry.setL(PVector.add(r.origin, PVector.mult(r.direction, entry.t)));
            entry.setE(true);
            entry.setN(PVector.sub(entry.location, center).normalize());
            entry.setM(material);
            entry.setU(0.0);
            entry.setV(0.0);
            
            exit.setL(PVector.add(r.origin, PVector.mult(r.direction, exit.t)));
            exit.setE(false);
            exit.setN(PVector.sub(exit.location, center).normalize());
            exit.setM(material);
            exit.setU(0.0);
            exit.setV(0.0);
            
            if(entry.t > 0 && exit.t > 0)
            {
              if(entry.t > exit.t)
              {
                result.add(exit);
                result.add(entry);
              }
              else
              {
                result.add(entry);
                result.add(exit);
              }
            }
        }
        return result;
    }
}

class Plane implements SceneObject

{
    PVector center;
    PVector normal;
    float scale;
    Material material;
    PVector left;
    PVector up;
    
    Plane(PVector center, PVector normal, Material material, float scale)
    {
       this.center = center;
       this.normal = normal.normalize();
       this.material = material;
       this.scale = scale;
       
       // remove this line when you implement planes
       //throw new NotImplementedException("Planes not implemented yet");
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        
        RayHit entry = new RayHit();
        RayHit exit = new RayHit();
     
         
        //Finding t
        PVector cminusr = PVector.sub(r.origin, center);
        float multdir = cminusr.dot(normal);
        PVector planedir = r.direction;
        float denom = planedir.dot(normal); 
        //determing if and where a ray y hits a plane
        float t = multdir/denom; 
        PVector yoft = PVector.add(r.origin, PVector.mult(r.direction, t));
        entry.setT(t);
       
        entry.setL(yoft);
        if (multdir != 0){
          entry.setE(true);
        }
        else{
          entry.setE(false);
        }
        entry.setT(t);
        entry.setM(material);
        entry.setN(normal);
        entry.setU(0.0);
        entry.setV(0.0);
      
        exit.setT(t);
        exit.setL(yoft);
        exit.setE(false);
        exit.setM(material);
        exit.setN(normal);
        exit.setU(0.0);
        exit.setV(0.0);
          
        if (t > 0){
          if(denom < 0){
            result.add(exit);
            result.add(entry);
          }
        }
        else{
          result.add(entry);
          result.add(exit);
       }
      
        return result;
    }
   
}

class Triangle implements SceneObject
{
    PVector v1;
    PVector v2;
    PVector v3;
    PVector normal;
    PVector tex1;
    PVector tex2;
    PVector tex3;
    Material material;
    
    Triangle(PVector v1, PVector v2, PVector v3, PVector tex1, PVector tex2, PVector tex3, Material material)
    {
       this.v1 = v1;
       this.v2 = v2;
       this.v3 = v3;
       this.tex1 = tex1;
       this.tex2 = tex2;
       this.tex3 = tex3;
       this.normal = PVector.sub(v2, v1).cross(PVector.sub(v3, v1)).normalize();
       this.material = material;
       
       // remove this line when you implement triangles
       //throw new NotImplementedException("Triangles not implemented yet");
    }
    
    float[] SameSide(PVector a, PVector b, PVector c, PVector p)
    {
       float[] UandV = new float[2];
        
       PVector e = PVector.sub(b,a);
       PVector rg = PVector.sub(c,a);
       PVector d = PVector.sub(p,a);
       
       //dot products
       float dotE = e.dot(e);
       float dotRG = rg.dot(rg);
       float EdotRG = e.dot(rg);
       float RGdotE = rg.dot(e);
       float denom = (dotE * dotRG) - (EdotRG * RGdotE);
       
       //calculate u and v
       UandV[0] = ((dotRG * d.dot(e)) - (EdotRG * d.dot(rg))) / denom;
       UandV[1] = ((dotE * d.dot(rg)) - (EdotRG * d.dot(e))) / denom;
       
       //UandV.add(u);
       //UandV.add(v);
     
       return UandV;
    }
    
    boolean PointInTriangle(PVector a, PVector b, PVector c, PVector p)
    {
      float u = SameSide(a, b, c, p)[0];
      float v = SameSide(a, b, c, p)[1];
      
      if( u >= 0 && (v >= 0) && u+v <= 1)
      {
       return true;
      }
      return false;
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        RayHit entry = new RayHit();
        RayHit exit = new RayHit();
        
        //finding t
        float tnum = PVector.dot(PVector.sub(v1, r.origin), normal);
        float tdenom = PVector.dot(r.direction, normal);
        float t = tnum / tdenom;
        
        if(t > 0 &&  tdenom != 0){
          //where ray y hits a plane 
          PVector triyoft = PVector.add(r.origin, PVector.mult(r.direction, t));
          if(tdenom <= 0)
          {
            entry.setT(t);
            entry.setL(triyoft);
            entry.setE(true);
            entry.setN(normal);
            entry.setM(material);
            entry.setU(0.0);
            entry.setV(0.0);
          }
          else{
            exit.setT(t);
            exit.setL(triyoft);
            exit.setE(false);
            exit.setN(normal);
            exit.setM(material);
            exit.setU(0.0);
            exit.setV(0.0);
          } 
          float[] uv = SameSide(v1, v2, v3, triyoft);
          float u = uv[0];
          float v = uv[1];
          
          boolean pit = PointInTriangle(v1, v2, v3, triyoft);
          if(pit){
              result.add(entry);
              result.add(exit);
              return result;
          }
          
          //return result;

        }
        return result;
          
      }


}

class Cylinder implements SceneObject
{
    float radius;
    float height;
    Material material;
    float scale;
    
    Cylinder(float radius, Material mat, float scale)
    {
       this.radius = radius;
       this.height = -1;
       this.material = mat;
       this.scale = scale;
       
       // remove this line when you implement cylinders
       throw new NotImplementedException("Cylinders not implemented yet");
    }
    
    Cylinder(float radius, float height, Material mat, float scale)
    {
       this.radius = radius;
       this.height = height;
       this.material = mat;
       this.scale = scale;
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        return result;
    }
}

class Cone implements SceneObject
{
    Material material;
    float scale;
    
    Cone(Material mat, float scale)
    {
        this.material = mat;
        this.scale = scale;
        
        // remove this line when you implement cones
       throw new NotImplementedException("Cones not implemented yet");
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        return result;
    }
   
}

class Paraboloid implements SceneObject
{
    Material material;
    float scale;
    
    Paraboloid(Material mat, float scale)
    {
        this.material = mat;
        this.scale = scale;
        
        // remove this line when you implement paraboloids
       throw new NotImplementedException("Paraboloid not implemented yet");
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        return result;
    }
   
}

class HyperboloidOneSheet implements SceneObject
{
    Material material;
    float scale;
    
    HyperboloidOneSheet(Material mat, float scale)
    {
        this.material = mat;
        this.scale = scale;
        
        // remove this line when you implement one-sheet hyperboloids
        throw new NotImplementedException("Hyperboloids of one sheet not implemented yet");
    }
  
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        return result;
    }
}

class HyperboloidTwoSheet implements SceneObject
{
    Material material;
    float scale;
    
    HyperboloidTwoSheet(Material mat, float scale)
    {
        this.material = mat;
        this.scale = scale;
        
        // remove this line when you implement two-sheet hyperboloids
        throw new NotImplementedException("Hyperboloids of two sheets not implemented yet");
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        return result;
    }
}
