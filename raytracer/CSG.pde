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
     ArrayList<RayHit> hitisa = new ArrayList<RayHit>();
                       //hitisa = a.intersect(r);
     ArrayList<RayHit> hitisb = new ArrayList<RayHit>();
                       //hitisb = b.intersect(r);
     ArrayList<RayHit> difference = new ArrayList<RayHit>();
     
     
     boolean ina = false;
     boolean inb = false;
     int a_ = 0;
     int b_ = 0;
     int in_a = 0;
     int in_b = 0;
     
     hitisa.addAll(a.intersect(r));
     hitisb.addAll(b.intersect(r));
     hitisa.sort(new HitCompare());
     hitisb.sort(new HitCompare());
     
     //counting the amount its in side a and b
     /** for(int i = 0; i < hitisa.size(); i++){
       if(hitisa.get(i).entry == true){
         ina = true;
         in_a++;
       }
       else{
         ina = false;
       }
     } */
     
     for(RayHit hit : hitisa){
       if(hit.entry == true){
         ina = true;
         in_a++;
       }
       else{
         ina = false;
       }
     }
     
       
     /** for(int j = 1; j < hitisb.size(); j++){
      if(hitisb.get(j).entry == true){
         inb = true; 
         in_b++;
       }
       else{
         inb = false;
       }
     } */
     
     int j = 0;
     for(RayHit hit : hitisb){
       if(j>0)
       {
         if(hit.entry == true){
         inb = true; 
         in_b++;
       }
       else{
         inb = false;
       }
       }
       j++;
     }
     
   /** for (int k = 0; k < hitisa.size(); k++){
      if(ina == true && inb == false){
        if(a_ == k+1){
          difference.add(hitisa.get(k));
        }
        a_++;
      }
      if(ina && !inb == true){
        if(b_ == k+1){
          hitisb.get(k).setE(false);
          hitisb.get(k).setN(hitisb.get(k).normal.rotate(180));
          difference.add(hitisb.get(k)); 
        }
        b_++; 
      }
    } */
    
    //int
    for (int k = 0; k < hitisa.size(); k++){
      if(ina == true && inb == false){
        if(a_ == k+1){
          difference.add(hitisa.get(k));
        }
        a_++;
      }
      if(ina && !inb == true){
        if(b_ == k+1){
          hitisb.get(k).setE(false);
          hitisb.get(k).setN(hitisb.get(k).normal.rotate(180));
          difference.add(hitisb.get(k)); 
        }
        b_++; 
      }
    }
    
    
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
     
      // latest attempt:
     ArrayList<RayHit> aAndb = new ArrayList<RayHit>();
     ArrayList<RayHit> diff = new ArrayList<RayHit>();
     for(RayHit hit : hitisa){
       hit.setIsObja(true);
       aAndb.add(hit);
     }
     
     for(RayHit hit : hitisb){
       println("test");
       aAndb.add(hit);
     }
     aAndb.sort(new HitCompare());
     
     int counter = 0;
     boolean aStart = false;
     boolean bStart = false;
     
     boolean inA = false;
     boolean inB = false;

       for(RayHit hit : aAndb)
       {
         if(counter == 0 && hit.isObja == true)
         {
           aStart = true;
           diff.add(hit);
           //inA = true;
         }
         else
         {
           bStart = true;
           inB = true; //??
         }
           
         if(counter > 0 && aStart)
         {
           if(hit.isObja == true)
           {
             diff.add(hit); // this one feels wrong but its not doing anything to the test case
           }
            if(hit.isObja == false)
            {
              if(hit.entry == true)
              {
                hit.setE(false);
                hit.setN(PVector.mult(hit.normal, -1));
                diff.add(hit); //hmm not doing anything so far
               }
            }
         }
         else if(counter > 0 && bStart)
         {
           if(hit.isObja == true && hit.entry == true)
             inA = true;
             
           if(hit.isObja == true && hit.entry == false)
             inA = false;
             
           if(hit.isObja == false && hit.entry == true)
             inB = true;
             
           if(hit.isObja == false && hit.entry == false)
             inB = false;
             
             if(inA == true && hit.isObja == false && hit.entry == false)
             {
               hit.setE(true);
               hit.setN(PVector.mult(hit.normal, -1));
               diff.add(hit);
               inB = false;
             }
             
             //if(inA == true && inb == false)
               //diff.add(hit);
             if(hit.isObja == true && hit.entry == false && inA == false) // this lines causing the black part
             diff.add(hit);
           
         }
           counter++;
       }
     
     return diff;
  }
  
}
