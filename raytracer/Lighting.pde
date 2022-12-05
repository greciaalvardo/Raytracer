class Light
{
   PVector position;
   color diffuse;
   color specular;
   Light(PVector position, color col)
   {
     this.position = position;
     this.diffuse = col;
     this.specular = col;
   }
   
   Light(PVector position, color diffuse, color specular)
   {
     this.position = position;
     this.diffuse = diffuse;
     this.specular = specular;
   }
   
   color shine(color col)
   {
       return scaleColor(col, this.diffuse);
   }
   
   color spec(color col)
   {
       return scaleColor(col, this.specular);
   }
}

class LightingModel
{
    ArrayList<Light> lights;
    LightingModel(ArrayList<Light> lights)
    {
      this.lights = lights;
    }
    color getColor(RayHit hit, Scene sc, PVector viewer)
    {
      color hitcolor = hit.material.getColor(hit.u, hit.v);
      color surfacecol = lights.get(0).shine(hitcolor);
      PVector tolight = PVector.sub(lights.get(0).position, hit.location).normalize();
      float intensity = PVector.dot(tolight, hit.normal);
      return lerpColor(color(0), surfacecol, intensity);
    }
  
}

class PhongLightingModel extends LightingModel
{
    color ambient;
    boolean withshadow;
    PhongLightingModel(ArrayList<Light> lights, boolean withshadow, color ambient)
    {
      super(lights);
      this.withshadow = withshadow;
      this.ambient = ambient;
    }
    color getColor(RayHit hit, Scene sc, PVector viewer)
    {
      ///ambient 
       color c = hit.material.getColor(hit.u,hit.v);
       color ambientterm = multColor(scaleColor(c, ambient), hit.material.properties.ka);
      
       //diffuse & specular
       PVector L;
       PVector N = hit.normal;
       color diffuse;
       
       PVector R;
       PVector V = PVector.sub(viewer, hit.location).normalize();
       color specular;
       color diffAndSpecSum = color(0);
       ArrayList<RayHit> shadows = new ArrayList<RayHit>();


       for(int i = 0; i < lights.size(); i++){
         
         //diffuse
         L = lights.get(i).position;
         L = PVector.sub(L, hit.location).normalize();
         diffuse = multColor(scaleColor(c, lights.get(i).diffuse), hit.material.properties.kd * (L.dot(N))); // (lm.N)*id
         
         R = PVector.mult(N, (2 * PVector.dot(N,L)));
         R = PVector.sub(R,L).normalize();
         specular = multColor(scaleColor(c, lights.get(i).specular), pow(R.dot(V), hit.material.properties.alpha));
         specular = multColor(specular, hit.material.properties.ks);

         //Shadow ray stuff 
         Ray shadowRay = new Ray(PVector.add(hit.location, PVector.mult(L,EPS)),L);  //didn't multiply by negative this time bc shadow ray and light ray face the same way i think
         shadows = sc.root.intersect(shadowRay);
        
         if(withshadow)
         {       
           if(shadows.size() == 0)
           {
             diffAndSpecSum = addColors(diffAndSpecSum, diffuse);
             diffAndSpecSum = addColors(diffAndSpecSum, specular);
           }
           else if(shadows.size() > 0 && PVector.sub(shadows.get(0).location,hit.location).mag() > PVector.sub(lights.get(i).position, hit.location).mag())
           {
             diffAndSpecSum = addColors(diffAndSpecSum, diffuse);
             diffAndSpecSum = addColors(diffAndSpecSum, specular);
           }
           else
             continue;
         }
         else if(!withshadow)
         {
            diffAndSpecSum = addColors(diffAndSpecSum, diffuse);
            diffAndSpecSum = addColors(diffAndSpecSum, specular);
         }
         
          
       }
       
      return addColors(ambientterm, diffAndSpecSum);
      
    }
  
}
