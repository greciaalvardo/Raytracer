import java.util.Comparator;

class HitCompare implements Comparator<RayHit>
{
  int compare(RayHit a, RayHit b)
  {
     if (a.t < b.t) return -1;
     if (a.t > b.t) return 1;
     if (a.entry) return -1;
     if (b.entry) return 1;
     return 0;
  }
}

class Union implements SceneObject
{
  SceneObject[] children;
  Union(SceneObject[] children)
  {
    this.children = children;
  }

  ArrayList<RayHit> intersect(Ray r)
  {
     
     ArrayList<RayHit> hits = new ArrayList<RayHit>();
     int enter = 0;
     Boolean alternating;
     ArrayList<RayHit> childexithit = new ArrayList<RayHit>();
     for (SceneObject sc : children)
     {
       //corner case
       childexithit = sc.intersect(r);
       //println(childexithit);
       if(childexithit.size() > 0){
         if(childexithit.get(0).entry == false){
            enter ++;
         }
       }
       hits.addAll(sc.intersect(r));
     }
     hits.sort(new HitCompare());
     
     ArrayList<RayHit> union = new ArrayList<RayHit>();
     for(RayHit hit : hits)
     {
       if(hit.entry == true)
       {
         if(enter == 0)
         union.add(hit);
 
         
         enter++;
       }
       else if(hit.entry == false)
       {
         if(enter == 1)
         union.add(hit);
         
         enter--;
       }
     }
     
     return union;
  }
  
}

class Intersection implements SceneObject
{
  SceneObject[] elements;
  Intersection(SceneObject[] elements)
  {
    this.elements = elements;
    
  }
  
  ArrayList<RayHit> intersect(Ray r)
  {
     ArrayList<RayHit> hits = new ArrayList<RayHit>();
     int enter = 0;
     ArrayList<RayHit> childexithit = new ArrayList<RayHit>();
     
     for (SceneObject sc : elements)
     {
       //corner case
       childexithit = sc.intersect(r);
       if(childexithit.size() > 0){
         if(childexithit.get(0).entry == false){
            enter ++;
         }
       }
       hits.addAll(childexithit);
     }
     hits.sort(new HitCompare());
     
     ArrayList<RayHit> intersection = new ArrayList<RayHit>();
     
     
     for(RayHit hit : hits)
     {
       if(hit.entry == true)
       {
         if(enter == elements.length-1){
           intersection.add(hit);
           enter++;
         }
      
         
         enter++;
       }
       else if(hit.entry == false)
       {
         if(enter == elements.length){
           intersection.add(hit);
           enter--;
         }
         
         
         enter--;
       }
     }
     
     return intersection;
  }
  
}


class Difference implements SceneObject
{
  SceneObject a;
  SceneObject b;
  Difference(SceneObject a, SceneObject b)
  {
    this.a = a;
    this.b = b;
  }
  
  ArrayList<RayHit> intersect(Ray r)
  {
     ArrayList<RayHit> hitisa = new ArrayList<RayHit>();
     ArrayList<RayHit> hitisb = new ArrayList<RayHit>();
     RayHit safecopy = new RayHit();
     ArrayList<RayHit> aAndb = new ArrayList<RayHit>();
     ArrayList<RayHit> diff = new ArrayList<RayHit>();
     boolean inA = false;
     boolean inB = false;
     hitisa.addAll(a.intersect(r));
     hitisb.addAll(b.intersect(r));
     hitisa.sort(new HitCompare());
     hitisb.sort(new HitCompare());
     
     for(RayHit hit : hitisa){
       if(hitisa.get(0).entry == false){
         inA = true;
       }
       else{
         inA = false;
       }
       hit.setIsObja(true);
       aAndb.add(hit);
     }
     
     for(RayHit hit : hitisb){
       if(hitisb.get(0).entry == false){
         inB = true;
       }
       else{
         inB = false; 
       }
       hit.setIsObja(false);
       aAndb.add(hit);
     }
     
     aAndb.sort(new HitCompare());
     
     for(RayHit hit : aAndb){
       if(hit.entry == false){
         if(inA && inB){
           if(hit.isObja){
              inA = false; 
           }
           else{
              safecopy = hit; 
              safecopy.setE(false);
              safecopy.setN(PVector.mult(safecopy.normal, -1));
              diff.add(safecopy);
              inB = false;
           }
         }
         else if(inA && !inB){
           diff.add(hit);
           inA = false;
         }
         else{
           inB = false; 
         }
       }
       else{
          if(!inA && !inB){
             if(hit.isObja){
                diff.add(hit);
                inA = true;
             }
             else{
               inB = true; 
             }
          }
          else if(inB && !inA){
            inA = true; 
          }
          else{
              safecopy = hit; 
              safecopy.setE(false);
              safecopy.setN(PVector.mult(safecopy.normal, -1));
              diff.add(safecopy);
              inB = true;
          }
       }
     }
     return diff;
  }
}
