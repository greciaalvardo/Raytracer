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
        /*
        RayHit entry = new RayHit();
        RayHit exit = new RayHit();
     
        
 //Finding t
 
        PVector cminusr = PVector.sub(r.origin, center);
        float multdir = cminusr.dot(normal);
        PVector planedir = r.direction;
        float denom = planedir.dot(normal); 
        float t = multdir/denom; 
 //determing if and where a ray y hits a plane
        PVector yoft = PVector.add(r.origin, PVector.mult(r.direction, t));
        println(yoft);
     
      entry.setL(yoft);
      if (multdir <= 0 && t < 0){
        entry.setE(false);
      }
      else{
        entry.setE(true); 
      }
      entry.setM(material);
      entry.setN(normal);
      entry.setU(0.0);
      entry.setV(0.0);
        
      exit.setL(  
      exit.setM(material);
         
        */
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
       throw new NotImplementedException("Triangles not implemented yet");
    }
    
    ArrayList<RayHit> intersect(Ray r)
    {
        ArrayList<RayHit> result = new ArrayList<RayHit>();
        
        //im assuming we find the point first, but idk what or how or when why what?? :'(
        // and then instead of ray r probably pass in that point
        
        // call point in triangle here after getting that point?? maybe??
        // idk yet if we'll need u and v again, in that case probably call sameside too to get them??
        
        // and then if pointintriangle is true, put the point(s?) in result and return it??
        // and if not just leave it empty?? :(
        return result;
    }
    
    ArrayList<Float> SameSide(PVector a, PVector b, PVector c, Ray r)
    {
      ArrayList<Float> UandV = new ArrayList<Float>();
      PVector e = PVector.sub(b, a);
      PVector reverseg = PVector.sub(c,a);
      PVector d = PVector.sub(r.origin, a);
      
      // Dot products
      float dotE = e.dot(e);
      float dotReverseG = reverseg.dot(reverseg);
      float EdotReverseG = e.dot(reverseg);
      float ReverseGdotE = reverseg.dot(e);
      
      float denom = (dotE * dotReverseG) - (EdotReverseG * ReverseGdotE);
      
      // Calculate u and v
      float u = ((dotReverseG * d.dot(e)) - (EdotReverseG * d.dot(reverseg))) / denom;
      float v = ((dotE * d.dot(reverseg)) - (EdotReverseG * d.dot(e))) / denom;
      
      UandV.add(u);
      UandV.add(v);
      
      return UandV;
    }
    
    boolean PointInTriangle(PVector a, PVector b, PVector c, Ray r)
    {
      ArrayList<Float> uandv = SameSide(a, b ,c, r);
      float u = uandv.get(0);
      float v = uandv.get(1);
      
      return u >= 0 && v >= 0 && (u+v) <= 1;
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
