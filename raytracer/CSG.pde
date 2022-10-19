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
     //check for alternating 
     /*for (int i = 0; i < union.size(); i++){
       if(union.get(i).entry == true && union.get(i+1).entry == false){
         alternating = true;
         println(alternating);
       }
       else{
        println("not"); 
       }
     }*/
     
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
     Boolean alternating = false;
     for (SceneObject sc : elements)
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
     
     ArrayList<RayHit> intersection = new ArrayList<RayHit>();
     
     /*for(RayHit hit : hits)
     {
       if(enter == elements.length - 1){
        if(enter == elements.length){
          intersection.add(hit);
          enter++;
        }
       }
      else if(enter == elements.length){
        intersection.add(hit);
        enter--;
       
      }
     }*/
     
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
     
     //test for alternating 
     /*for (int i = 0; i < intersection.size(); i++){
       if(intersection.get(i).entry == true && intersection.get(i+1).entry == false){
         alternating = true;
         println(alternating);
       }
       else{
        println("not"); 
       }
     }*/
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
     
     ArrayList<RayHit> hitsA = new ArrayList<RayHit>();
     ArrayList<RayHit> hitsB = new ArrayList<RayHit>();
     

       hitsA.addAll(a.intersect(r));
       hitsB.addAll(b.intersect(r));
       hitsA.sort(new HitCompare());
       hitsB.sort(new HitCompare());
     
     ArrayList<RayHit> difference = new ArrayList<RayHit>();
     //boolean insideDifference = false;
     
     
    /*
     for(int i=0; i<hitsA.size(); i++)
     {
       if(hitsA.get(i).entry==true && hitsB.get(i).entry==false)
       {
         difference.add(hitsA.get(i));
         insideDifference = true;
       }
       if(hitsA.get(i).entry==false && hitsB.get(i).entry==false) // maybe also add if insideDifference
       {
         difference.add(hitsA.get(i));
         insideDifference = false;
       }
       if(hitsA.get(i).entry==true && hitsB.get(i).entry==true)
       {
         hitsB.get(i).setE(false);
         hitsB.get(i).setN(hitsB.get(i).normal.rotate(180)); //idk ab this one -- my attempt to flip
         difference.add(hitsB.get(i));
       }
     }*/
     //return hits;
     return difference;
  }
  
}
