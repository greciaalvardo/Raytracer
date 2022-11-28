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
        
        //trying with dot product
        PVector cSubo = PVector.sub(center, r.origin);

        float tp = cSubo.dot(r.direction);

        float x = PVector.sub(PVector.add(r.origin, PVector.mult(r.direction, tp)), center).mag(); // x = |(o + tp*d - c)|

        if(x < radius){
            entry.setT(tp - sqrt( pow(radius, 2) - pow(x, 2)));
            exit.setT(tp + sqrt( pow(radius, 2) - pow(x, 2)));
            
            entry.setL(PVector.add(r.origin, PVector.mult(r.direction, entry.t)));
            entry.setE(true);
            entry.setN(PVector.sub(entry.location, center).normalize());
            entry.setM(material);
            PVector entryLocal = PVector.sub(entry.location, center).normalize();
            entry.setU(0.5 + (atan2(entryLocal.y, entryLocal.x)/(2*PI)));
            entry.setV(0.5 + (asin(entryLocal.z*-1)/(PI)));
            
            exit.setL(PVector.add(r.origin, PVector.mult(r.direction, exit.t)));
            exit.setE(false);
            exit.setN(PVector.sub(exit.location, center).normalize());
            exit.setM(material);
            PVector exitLocal = PVector.sub(exit.location, center).normalize();
            exit.setU(0.5 + (atan2(exitLocal.y, exitLocal.x)/(2*PI)));
            exit.setV(0.5 + (asin(exitLocal.z*-1)/(PI)));
            
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
       
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        
        RayHit entry = new RayHit();
        RayHit exit = new RayHit();
     
         
        //Finding t
        PVector cminusr = PVector.sub(center, r.origin);
        float multdir = cminusr.dot(normal);
        PVector planedir = r.direction;
        float denom = planedir.dot(normal); 

        //determing if and where a ray y hits a plane
        float t = multdir/denom;
        PVector yoft = PVector.add(r.origin, PVector.mult(r.direction, t));
        
        //texture 
        PVector forward = normal;
        PVector z; 
        PVector y;
        z = new PVector (0,0,1);
        y = new PVector (0,1,0);
        PVector d = yoft.sub(center);
        if(forward != z){
          PVector right = z.cross(forward).normalize();
          PVector up = right.cross(forward).normalize();
          float x = d.dot(right)/scale;
          float yp = d.dot(up)/scale;
          entry.setU(x - floor(x));
          entry.setV((yp * 1) - floor(yp * 1)); //took away negatives and it worked hmmmm
          
          exit.setU(x - floor(x));
          exit.setV((yp * -1) - floor(yp * -1));
          
          
        }
        else{
          z = y;
          PVector right = z.cross(forward).normalize();
          PVector up = right.cross(forward).normalize();
          float x = d.dot(right)/scale;
          float yp = d.dot(up)/scale;
          entry.setU(x - floor(x));
          entry.setV((yp * -1) - floor(yp * -1));
          
          exit.setU(x - floor(x));
          exit.setV((yp * -1) - floor(yp * -1));
        }
        //
        entry.setT(t);
        entry.setM(material);
        //entry.setU(0.0);
        //entry.setV(0.0);
        exit.setM(material);
        //exit.setU(0.0);
        //exit.setV(0.0);
        
        // orthogonal, will never hit sphere
        if(denom == 0){
          return result;
        }
        else
        {
        
        if(t < 0){
          if(denom < 0){
              entry.setT(Float.POSITIVE_INFINITY);
              entry.setL(new PVector(0,0,0));
              entry.setN(normal);
              entry.setE(false);
              result.add(entry); 
          }
          return result;
        } 
        
        if(t > 0){
          
          if(denom < 0)
          {
            entry.setT(t);
            entry.setN(normal);
            entry.setL(yoft);
            entry.setE(true);
            result.add(entry);
          }
          else if (denom > 0)
          {
            exit.setT(t);
            exit.setN(normal);
            exit.setL(yoft);
            exit.setE(false);
            result.add(exit);
          }
          
        }
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
       //this.normal = PVector.sub(v2, v1).cross(PVector.sub(v3, v1)).normalize();
       this.normal = PVector.sub(v3, v2).cross(PVector.sub(v1, v2)).normalize(); //not sure if this will make a difference?? :O
       this.material = material;
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
          //texture
          float[] uv = SameSide(v1, v2, v3, triyoft);
          float u = uv[0];
          float v = uv[1];
          float theta = u;
          float phi = v;
          float psi = 1 - (theta + phi);
          //
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
          
          boolean pit = PointInTriangle(v1, v2, v3, triyoft);
          if(pit){
              result.add(entry);
              return result;
          }
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
