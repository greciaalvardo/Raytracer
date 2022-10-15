class RayHit
{
     float t;
     PVector location;
     PVector normal;
     boolean entry;
     Material material;
     float u = 0,
           v = 0;
           
      void setT(float t)
      {
        this.t = t;
      }
      
      void setL(PVector location)
      {
        this.location = location;
      }
      
      void setN(PVector normal)
      {
        this.normal = normal;
      }
      
      void setE(boolean entry)
      {
        this.entry = entry;
      }
      
      void setM(Material material)
      {
        this.material = material;
      }
      
      void setU(float u)
      {
        this.u = u;
      }
      
      void setV(float v)
      {
        this.v = v;
      }
}
interface SceneObject
{
   ArrayList<RayHit> intersect(Ray r);
}

class Scene
{
   LightingModel lighting;
   SceneObject root;
   int reflections;
   color background;
   PVector camera;
   PVector view;
   float fov;
}
