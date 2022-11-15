String input =  "data/tests/milestone2/test7.json";
String output = "data/tests/milestone2/test7.png";
//String input =  "data/tests/submission1/test9.json";
//String output = "data/tests/submission1/test9.png";
int repeat = 0;

int iteration = 0;

// If there is a procedural material in the scene,
// loop will automatically be turned on if this variable is set
boolean doAutoloop = true;

/*// Animation demo:
String input = "data/tests/milestone3/animation1/scene%03d.json";
String output = "data/tests/milestone3/animation1/frame%03d.png";
int repeat = 100;
*/


RayTracer rt;

void setup() {
  size(640, 640);
  noLoop();
  if (repeat == 0)
      rt = new RayTracer(loadScene(input));  
  
}

void draw () {
  background(255);
  if (repeat == 0)
  {
    PImage out = null;
    if (!output.equals(""))
    {
       out = createImage(width, height, RGB);
       out.loadPixels();
    }
    for (int i=0; i < width; i++)
    {
      for(int j=0; j< height; ++j)
      {
        color c = rt.getColor(i,j);
        set(i,j,c);
        if (out != null)
           out.pixels[j*width + i] = c;
      }
    }
    
    // This may be useful for debugging:
    // only draw a 3x3 grid of pixels, starting at (315,315)
    // comment out the full loop above, and use this
    // to find issues in a particular region of an image, if necessary
    /*for (int i = 0; i< 3; ++i)
    {
      for (int j = 0; j< 3; ++j)
         set(315+i,315+j, rt.getColor(315+i,315+j));
    }*/
    
    if (out != null)
    {
       out.updatePixels();
       out.save(output);
    }
    
  }
  else
  {
     // With this you can create an animation!
     // For a demo, try:
     //    input = "data/tests/milestone3/animation1/scene%03d.json"
     //    output = "data/tests/milestone3/animation1/frame%03d.png"
     //    repeat = 100
     // This will insert 0, 1, 2, ... into the input and output file names
     // You can then turn the frames into an actual video file with e.g. ffmpeg:
     //    ffmpeg -i frame%03d.png -vcodec libx264 -pix_fmt yuv420p animation.mp4
     String inputi;
     String outputi;
     for (; iteration < repeat; ++iteration)
     {
        inputi = String.format(input, iteration);
        outputi = String.format(output, iteration);
        if (rt == null)
        {
            rt = new RayTracer(loadScene(inputi));
        }
        else
        {
            rt.setScene(loadScene(inputi));
        }
        PImage out = createImage(width, height, RGB);
        out.loadPixels();
        for (int i=0; i < width; i++)
        {
          for(int j=0; j< height; ++j)
          {
            color c = rt.getColor(i,j);
            out.pixels[j*width + i] = c;
            if (iteration == repeat - 1)
               set(i,j,c);
          }
        }
        out.updatePixels();
        out.save(outputi);
     }
  }
  updatePixels();


}

class Ray
{
     Ray(PVector origin, PVector direction)
     {
        this.origin = origin;
        this.direction = direction;
     }
     PVector origin;
     PVector direction;
 
}


// TODO: Start in this class!
class RayTracer
{
    
    Scene scene;  
    
    RayTracer(Scene scene)
    {
      setScene(scene);
    }
    
    void setScene(Scene scene)
    {
       this.scene = scene;
    }
   
    /**color getColor(int x, int y)
    {
      float w = width;
      float h = height;
      float u = x*1.0/w - 0.5;
      float v = -(y*1.0/h - 0.5);
      PVector origin = scene.camera;
      PVector direction = new PVector(u*w, w/2, v*h).normalize();
      Ray ray = new Ray(origin, direction);
      ArrayList<RayHit> hits = scene.root.intersect(ray);
      
      if (scene.reflections > 0)
      {
        while(hits.get(0).material.properties.reflectiveness > 0){ //im confused bc would this come after the intersect method in line 175 :(( just a thought im prob wrong
          //as said in project description, the method we used in phone lighting is what we use to find Phong lighting
          PVector N = hits.get(0).normal;
          PVector V = PVector.sub(ray.origin, hits.get(0).location).normalize();
          
          //PVector L = hits.get(0).scene.lighting.lights.position;//i keep getting errors tryna use stuff from lighting -- i think bc the rayhit class doesnt have a scene object
          PVector L = scene.lighting.lights.get(0).position;
                  L = PVector.sub(L, hits.get(0).location).normalize();
          
          PVector R = PVector.mult(N, (2 * PVector.dot(N,L)));
                  R = PVector.sub(R,L).normalize();
          
          PVector Q = PVector.mult(R,-1);
          float dotprod = Q.dot(N);
                dotprod = 2* dotprod;
                  Q = PVector.mult(N, dotprod);
                  Q = PVector.add(Q, R);
          Ray reflectr = new Ray(PVector.add(origin, PVector.mult(Q,EPS)), L); //put Q instead of direction not sure if it's right
          ArrayList<RayHit> rhits = scene.root.intersect(reflectr);
          
          
          //if perfect mirror, reflectiveness = 1
          if(hits.get(0).material.properties.reflectiveness == 1){
            //return the calculated reflected ray
          }
          else{
           //combine the surface colors and the result of the reflection ray; use lerp color 
          }
          
        }
        
      }
       
      if(hits.size() > 0)
      {
        return scene.lighting.getColor(hits.get(0), scene, ray.origin);
      }
      return scene.background;
      
      /*if (scene.reflections > 0)
      {
          // remove this line when you implement reflection
          throw new NotImplementedException("Reflection not implemented yet");
      }*/
      
     
      
      /// this will be the fallback case
      //return this.scene.background;
   // }
   
   color getColor(int x, int y)
    {
      float w = width;
      float h = height;
      float u = x*1.0/w - 0.5;
      float v = -(y*1.0/h - 0.5);
      PVector origin = scene.camera;
      PVector direction = new PVector(u*w, w/2, v*h).normalize();

      Ray ray = new Ray(origin, direction);
      ArrayList<RayHit> hits = scene.root.intersect(ray);
      
       
      if(hits.size() > 0)
      {
        if(hits.size()>0)
      if (scene.reflections > 0)
      {
        //while(hits.get(0).material.properties.reflectiveness > 0){ //im confused bc would this come after the intersect method in line 175 :(( just a thought im prob wrong
          //as said in project description, the method we used in phone lighting is what we use to find Phong lighting
          //if(hits.size() >0)
          print(hits.size());
          PVector N = hits.get(0).normal;
          PVector V = PVector.sub(ray.origin, hits.get(0).location).normalize();
          
          //PVector L = hits.get(0).scene.lighting.lights.position;//i keep getting errors tryna use stuff from lighting -- i think bc the rayhit class doesnt have a scene object
          PVector L = scene.lighting.lights.get(0).position;
                  L = PVector.sub(L, hits.get(0).location).normalize();
          
          PVector R = PVector.mult(N, (2 * PVector.dot(N,L)));
                  R = PVector.sub(R,L).normalize();
          
          PVector Q = PVector.mult(R,-1);
          float dotprod = Q.dot(N);
                dotprod = 2* dotprod;
                  Q = PVector.mult(N, dotprod);
                  Q = PVector.add(Q, R);

          Ray reflectr = new Ray(PVector.add(origin, PVector.mult(Q,EPS)), L); //put Q instead of direction not sure if it's right
          
          ArrayList<RayHit> rhits = scene.root.intersect(reflectr);
          
          // hits.get(0).material.properties.reflectiveness -- what is this?? idk
          return getReflectionColor(scene.lighting.getColor(hits.get(0), scene, ray.origin), reflectr, hits, rhits, scene.reflections);
          //for(RayHit hit : hits)
          //{
          //  hit.material.col = shootRay(reflectr);
         // }

          
          /**for(int i = 0; i<hits.size(); i++)
          {
            if(rhits.get(i).material.properties.reflectiveness>0)
            {
              color test = scene.lighting.getColor(hits.get(0), scene, ray.origin);
              hits.get(i).material.col = getReflectionColor(test, reflectr, hits, rhits, hits.get(i).material.properties.reflectiveness);
            }
          }
          //if perfect mirror, reflectiveness = 1
          if(hits.get(0).material.properties.reflectiveness == 1){
            //return the calculated reflected ray
          }
          else{
           //combine the surface colors and the result of the reflection ray; use lerp color
          } */
          
        }
        return scene.lighting.getColor(hits.get(0), scene, ray.origin);
      }
      
      return scene.background;
      
    }
    
    color getReflectionColor(color oldColor, Ray reflection, ArrayList<RayHit> hits, ArrayList<RayHit> rhits, int depth)
    {
      color newColor = oldColor;
      
      // Base case
      if(depth <= 0)
        return newColor;
        
        if(hits.size()>0){
          print("hmm");
          PVector N = hits.get(0).normal;
          PVector V = PVector.sub(reflection.origin, hits.get(0).location).normalize();
          
          //PVector L = hits.get(0).scene.lighting.lights.position;//i keep getting errors tryna use stuff from lighting -- i think bc the rayhit class doesnt have a scene object
         // PVector L = scene.lighting.lights.get(0).position;
          //        L = PVector.sub(L, hits.get(0).location).normalize();
          
          PVector R = PVector.mult(N, (2 * PVector.dot(N,V)));
                  R = PVector.sub(R,V).normalize(); //v?? instead of l??
          
          PVector Q = PVector.mult(R,-1);
          float dotprod = Q.dot(N);
                dotprod = 2* dotprod;
                  Q = PVector.mult(N, dotprod);
                  Q = PVector.add(Q, R);

          Ray reflectr = new Ray(PVector.add(reflection.origin, PVector.mult(Q,EPS)), R); //put Q instead of direction not sure if it's right
          ArrayList<RayHit> newRhits = scene.root.intersect(reflectr);
          

          newColor = lerpColor(oldColor, scene.lighting.getColor(hits.get(0), scene, reflectr.origin), hits.get(0).material.properties.reflectiveness);
          
          return getReflectionColor(newColor, reflectr, rhits, newRhits, depth-1); }
          else{
            print("hi");
          return oldColor; }
          
    }
    
    color shootRay(Ray r)
    {
      
      ArrayList<RayHit> hits = scene.root.intersect(r);
      color sc = hits.get(0).material.col;
      color c = 0;
      print("test");
      if(scene.reflections > 0)
      {
        c = shootRay(r);
      }
      
      return lerpColor(sc, c, hits.get(0).material.properties.reflectiveness);
      
    }
}
