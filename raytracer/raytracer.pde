String input =  "data/tests/milestone4/test3.json";
String output = "data/tests/milestone4/test3.png";
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
      ArrayList<RayHit> rhits = hits;
      ArrayList<RayHit> oldHits;
      Ray safeCopy = ray;
      
       
      if(rhits.size() > 0)
      {
        if (scene.reflections > 0)
        {
          
          color oldColor = scene.lighting.getColor(rhits.get(0), scene, safeCopy.origin);
          color newColor = oldColor;
          int reflections = scene.reflections;
          //getReflectionColor(reflColor, safeCopy, hits, reflections, scene);
          
          
          while(scene.reflections>=reflections)
          {
            
            PVector N = rhits.get(0).normal;
            PVector V = PVector.sub(safeCopy.origin, rhits.get(0).location).normalize();
            
         // PVector L = hits.get(0).scene.lighting.lights.position;//i keep getting errors tryna use stuff from lighting -- i think bc the rayhit class doesnt have a scene object
          PVector L = scene.lighting.lights.get(0).position;
                  L = PVector.sub(L, hits.get(0).location).normalize();

          
            PVector R = PVector.mult(N, (2 * PVector.dot(N,V)));
                    R = PVector.sub(R,V).normalize(); //v?? instead of l??
                    
            PVector Q = PVector.mult(R,-1);
            float dotprod = Q.dot(N);
                dotprod = 2* dotprod;
                Q = PVector.mult(N, dotprod);
                Q = PVector.add(Q, R);
            oldHits = rhits;
            
            safeCopy = new Ray(PVector.add(rhits.get(0).location, PVector.mult(R, EPS)), R); //tried r instead of q and it worked??
            rhits = scene.root.intersect(safeCopy);
            
            if(oldHits.get(0).material.properties.reflectiveness > 0)
            {
              if(rhits.size() >0)
              newColor = lerpColor(oldColor,scene.lighting.getColor(rhits.get(0), scene, safeCopy.origin), oldHits.get(0).material.properties.reflectiveness);
              else
              break;
            } else
            {
              break;
            }
            
            reflections--;
          }
          
          return newColor;
        }
        
        return scene.lighting.getColor(hits.get(0), scene, ray.origin);
        
      }
      
      return scene.background;
      
    }
    
    void getReflectionColor(color oldColor, Ray reflection, ArrayList<RayHit> rhits, int depth, Scene scene) //didnt work but maybe it was a pass-by-value problem??? bc it worked directly in getcolor??
    {
      //color newColor = oldColor;
      
      // Base case
      if(depth <= scene.reflections)
        return;
        
        //manipulate oldColor
        if(rhits.size()>0)
        {
          PVector N = rhits.get(0).normal;
          PVector V = PVector.sub(reflection.origin, rhits.get(0).location).normalize();
          
          PVector R = PVector.mult(N, (2 * PVector.dot(N,V)));
                  R = PVector.sub(R,V).normalize(); //v?? instead of l??
          

          Ray reflectr = new Ray(PVector.add(rhits.get(0).location, PVector.mult(R,EPS)), R); //put Q instead of direction not sure if it's right
          ArrayList<RayHit> newRhits = scene.root.intersect(reflectr);
          
          //print("reflection hits size: " + newRhits.size() + " ");
          if(rhits.get(0).material.properties.reflectiveness > 0) //it's literally reading this what's the problem???? :'((
          {
            //print("reflection!"); // it reads??? what's wrong??
            if(newRhits.size() >0)
            {
            oldColor = lerpColor(oldColor, scene.lighting.getColor(newRhits.get(0), scene, reflectr.origin), rhits.get(0).material.properties.reflectiveness);
            getReflectionColor(oldColor, reflectr, newRhits, --depth,scene);
            } else
            {
              return;
            }
            
          } else
          {
            //print("no reflection >:| ");
            return;
          }
        } else
          {
            print("hi");
            return;
          }
          
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
    
           //while(hits.get(0).material.properties.reflectiveness > 0){ //im confused bc would this come after the intersect method in line 175 :(( just a thought im prob wrong
          //as said in project description, the method we used in phone lighting is what we use to find Phong lighting
          //if(hits.size() >0)
                    //for(RayHit hit : hits)
          //{
          //  hit.material.col = shootRay(reflectr);
         // }
         

         // Ray reflectr = new Ray(PVector.add(origin, PVector.mult(Q,EPS)), V); //put Q instead of direction not sure if it's right
          
         // ArrayList<RayHit> rhits = scene.root.intersect(reflectr);
          
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
