import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;


class BlobDetection {
  PImage findConnectedComponents(PImage input, boolean onlyBiggest) {
    PImage img = input.copy();
    int [] labels= new int [img.width*img.height];
    List<TreeSet<Integer>> labelsEquivalences= new ArrayList<TreeSet<Integer>>();
    int currentLabel=0;
    
    ArrayList<Integer> inc = new ArrayList<Integer>();

    for (int y = 0; y <  img.height; ++y) {
      TreeSet<Integer> neighbors = new TreeSet<Integer>();

      for (int x = 0; x < img.width; ++x) {
        if (brightness(img.pixels[y*img.width + x]) == 255) {
          neighbors.clear();
          if (y != 0) {
            for (int i = x-1; i < x+1; i++) {
              if (0<=i && i <img.width && labels[(y - 1)*img.width+i] != 0) {
                neighbors.add(labels[(y - 1)*img.width+i]);
              }
            }
          }
          if (x != 0) {
            if (labels[y*img.width+x-1] != 0) {
              neighbors.add(labels[y*img.width+x-1]);
            }
          }
          if (neighbors.isEmpty()) {
            TreeSet<Integer> lab = new TreeSet<Integer>();
            lab.add(++currentLabel);
            labelsEquivalences.add(lab); 
            inc.add(1);
            labels[x + y * img.width] = currentLabel;
          } else {
            if (neighbors.size()>1) {
              for (int l : neighbors) {
                labelsEquivalences.get(l-1).addAll(neighbors);
              }
            }
            int fst = neighbors.first();
            inc.set(fst-1, inc.get(fst-1)+1);
            labels[x + y * img.width] = fst;
          }
        }
      }
    }

    for (int i = 0; i < labelsEquivalences.size(); i++) {
      TreeSet<Integer> tmp=labelsEquivalences.get(i);
      if (tmp.size()>1) {
        TreeSet<Integer> acc1 =new TreeSet<Integer>();
        for (Integer j : tmp) {
          TreeSet<Integer> acc2 =labelsEquivalences.get(j-1);
          if (tmp!=acc2) { 
            acc1.addAll(acc2);
          }
        }
        tmp.addAll(acc1);
        for (Integer j : tmp) {
          labelsEquivalences.set(j-1, tmp);
        }
      }
    }

    int[] size = new int[labelsEquivalences.size()];
    for (int i=0; i<labelsEquivalences.size(); ++i) {
      TreeSet<Integer> tmp=labelsEquivalences.get(i);
      int total=0;
      for (Integer j : tmp) {
        total+=inc.get(j-1);
      }
      size[i]=total;
    }

    int[] colors =new int[size.length];
    if (onlyBiggest) {
      int max =-1;
      for (int i=0; i < size.length; i++) {
        max=max(max, size[i]);
      }
      for (int i=0; i < size.length; i++) {
        colors[i]= (size[i] == max ? color(255) : color(0));
      }
    } else {
      for (TreeSet<Integer> tmp : labelsEquivalences) {
        int rndCol=color(random(255), 255, 200);
        for (Integer i : tmp) {
          colors[i-1] = rndCol;
        }
      }
    }
    for (int i=0; i < img.width*img.height; ++i) {
      if (labels[i]!=0) {
        img.pixels[i] = colors[labels[i]-1];
      }
    }
    return img;
  }
}
