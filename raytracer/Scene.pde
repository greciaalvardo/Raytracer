class RayHit
{
     float t;
     PVector location;
     PVector normal;
     boolean entry;
     Material material;
     float u = 0,
           v = 0;
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
