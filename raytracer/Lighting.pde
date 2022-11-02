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
      
      // remove this line when you implement phong lighting
      //throw new NotImplementedException("Phong Lighting Model not implemented yet");
    }
    color getColor(RayHit hit, Scene sc, PVector viewer)
    {
      //ambient 
       color c = hit.material.getColor(hit.u,hit.v);
       color ambientterm = multColor(scaleColor(c, ambient), hit.material.properties.ka);
      
       //diffuse & specular
       PVector L;
       PVector N = hit.normal;
       color diffuse;
       color initColor = color(0);
       
       PVector R;
       PVector V;
       color specular;
       
       color diffAndSpecSum = color(0);
       
       
       for(int i = 0; i < lights.size(); i++){
         
         //diffuse
         L = lights.get(i).position.normalize(); //Lm
         diffuse = multColor(scaleColor(c, lights.get(i).diffuse), hit.material.properties.kd * (L.dot(N))); // (lm.N)*id
         diffuse = multColor(diffuse, hit.material.properties.kd); // kd * above^
         
         R = PVector.mult(PVector.sub(N, L), 2 * L.dot(N)).normalize();
         //V = lights.get(i).position; //this ones wrong and throwing it off
         //V = hit.location; //wrong
         V = PVector.sub(lights.get(i).position, hit.location).normalize(); //this has been the closest so far
         specular = multColor(scaleColor(c, lights.get(i).specular), pow(R.dot(V), hit.material.properties.alpha));
         specular = multColor(specular, hit.material.properties.ks);
         
         // sum
         if(i == 0)
         {
         diffAndSpecSum = addColors(diffuse, specular);
         }
         else if(i > 0)
         {
         diffAndSpecSum = addColors(diffAndSpecSum, diffuse);
         diffAndSpecSum = addColors(diffAndSpecSum, specular);
         }
         
         //these gave just ambient + diffuse
         //if(i == 0)
         //  initColor = diffuse;
         
         //if(i == 1)
         //  diffAndSpecSum = addColors(initColor, diffuse);
         
         //if(i > 1)
         //  diffAndSpecSum =  addColors(diffAndSpecSum, diffuse);
         
         
         
       }
       
      
      //return hit.material.getColor(hit.u, hit.v);
      return addColors(ambientterm, diffAndSpecSum);
    }
  
}
