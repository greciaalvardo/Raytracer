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
     
     
    
     
     for(RayHit hit : hitisa){
       if(hit.entry == true){
         ina = true;
         in_a++;
       }
       else{
         ina = false;
       }
     }
     
     
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
    
     
      // latest attempt:
     ArrayList<RayHit> aAndb = new ArrayList<RayHit>();
     ArrayList<RayHit> diff = new ArrayList<RayHit>();
     for(RayHit hit : hitisa){
       hit.setIsObja(true);
       aAndb.add(hit);
     }
     
     for(RayHit hit : hitisb){
       //println("test");
       aAndb.add(hit);
     }
     aAndb.sort(new HitCompare());
     
     int counter = 0;
     boolean aStart = false;
     boolean bStart = false;
     
     boolean inA = false;
     boolean inB = false;
     
     int aCount = 0;
     int bCount = 0;
     RayHit safecopy;

       for(RayHit hit : aAndb)
       {
         if(counter == 0 && hit.isObja == true)
         {
           diff.add(hit);
           
           if(hit.entry == false) //started inside of a
           inA = true;

         }
         else if(counter == 0 && hit.isObja == false)
         {
           
           if(hit.entry ==false) //started inside of b
           inB = true; //??
         }
           
        /** if(counter > 0)
         {
           if(hit.isObja == true)
           {
             diff.add(hit); // this one feels wrong but its not doing anything to the test case
           }
            if(hit.isObja == false)
            {
              if(hit.entry == true)
              {
                safecopy = hit;
                inA = true;
                safecopy.setE(false);
                safecopy.setN(PVector.mult(safecopy.normal, -1));
                diff.add(hit); //hmm not doing anything so far
               }
            }
         } */
         if(counter > 0)
         {
           if(hit.isObja == true && hit.entry == true) // if you add a hit here, entire red appears?? hmm
             inA = true;
             
             
           if(hit.isObja == true && hit.entry == false) //if you add a hit here, the black appears
             inA = false;
             
           if(hit.isObja == false && hit.entry == true) //if you add a hit here, unecessary b appears
             inB = true;
             
           if(hit.isObja == false && hit.entry == false) //if you add a hit here, unecessary b appears too
             inB = false;
             
             
             if(inA == true && hit.isObja == false && hit.entry == false)
             {
               safecopy = hit;
               safecopy.setE(true);
               safecopy.setN(PVector.mult(safecopy.normal, -1));
               diff.add(hit); //if you dont add this, none of b appears
               inB = false;
             }
             
             //if(hit.isObja)
             if(inA == true && inb == false) //somewhere here either makes the entire red sphere appear or the half disappear
             {
               if(hit.entry == false)
               {
               diff.add(hit); //does nothing it seems
               inA = false;
               }
             }
             //if(hit.isObja == true && hit.entry == false && inA == false) // this lines causing the black part
             //diff.add(hit);
           
         } 
           counter++;
       }
       
     /**  RayHit safecopy;
       
       // this one didn't make anything appear :(((
       for(RayHit hit : aAndb)
       {
         
         if(aCount == hitisa.size())
           inA = false;
         else if(bCount == hitisb.size())
           inB = false;
           
         if(counter == 0 && hit.isObja == true)
         {
            
           aCount++;
           if(hit.entry == false)
           inA = true; //we started in a

         }
         else if(counter == 0 && hit.isObja == false)
         {
           bCount++;
           if(hit.entry ==false)
           inB = true; //we started in b
         }
           
         if(counter > 0)
         {
           if(hit.entry == false)
           {
           if(inA == true && inb == true)
           {
             if(hit.isObja == true && hit.entry == false)
             {
               inA = false;
               counter++;
               continue;
             }
             
             safecopy = hit;
             safecopy.setE(false);
             safecopy.setN(PVector.mult(hit.normal, -1));
             diff.add(safecopy); //hmm not doing anything so far
             inB = false;
             
           }
           else if(inA == true && inB == false)
           {
             diff.add(hit);
             inA = false;
           }
           else
           {
             inB = false;
           }
           } else if(hit.entry == true)
           {
             if(inA == false && inB == false)
             {
               if(hit.isObja == true)
               {
                 inA = true;
                 diff.add(hit);
               }
               else if(hit.isObja == false)
               {
                 inB = true;
               }
           } else if(inA == false && inB == true)
           {
             inA = true;
           }
           else
           {
             safecopy = hit;
             safecopy.setE(false);
             safecopy.setN(PVector.mult(hit.normal, -1));
             diff.add(safecopy); //hmm not doing anything so far
             inB = true;
           }
        
 
         }
           counter++;
       }
       } */
     
     return diff;
  }
  
}
