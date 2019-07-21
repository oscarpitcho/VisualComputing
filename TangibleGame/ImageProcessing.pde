import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;
import java.util.Map;
import java.lang.Math;
import processing.video.*;
import gab.opencv.*;

class ImageProcessing extends PApplet {

  Capture cam;
  Movie movie;
  PImage img;
  QuadGraph corners;
  OpenCV opencv;
  TwoDThreeD twoToThree;
  BlobDetection blobs;

  PVector rotation = new PVector(0, 0, 0);

  final static float discretizationStepsPhi = 0.06f;         
  final static float discretizationStepsR = 2.5f;  
  final static int phiDim = (int) (Math.PI / discretizationStepsPhi +1);
  int minVotes=50;

  // pre-compute the sin and cos values
  public float[] tabSin = new float[phiDim];
  public float[] tabCos = new float[phiDim];
  float ang = 0;
  float inverseR = 1.f / discretizationStepsR;

  void settings() {
    size(1333, 400);
  }

  void setup() {
    frameRate(48);

    for (int accPhi = 0; accPhi < phiDim; ang += discretizationStepsPhi, accPhi++) {
      // we can also pre-multiply by (1/discretizationStepsR) since we need it in the Hough loop
      tabSin[accPhi] = (float) (Math.sin(ang) * inverseR);
      tabCos[accPhi] = (float) (Math.cos(ang) * inverseR);
    }


    movie = new Movie(this, "/Users/louisjacquesvulongleclair/prettypictures/Game/testvideo.avi");
    movie.loop();

    blobs = new BlobDetection();
    corners = new QuadGraph();
    opencv = new OpenCV(this, 100, 100);
    twoToThree = new TwoDThreeD(movie.width, movie.height, 0);
  }

  void draw() {
    if (movie.available() == true) {
      movie.read();
    }
    img = movie.get();
    if (img != null) {
      img.resize(533, 400);
      PImage test = thresholdHSB(img, 100, 140, 80, 255, 10, 170);
      test = blobs.findConnectedComponents(test, true);
      test = convolute(test);
      test = scharr(test);
      test = threshold(test, 100);
      List<PVector> testList = hough(test, 4);

      for (PVector corner : testList) {
        corner.set(corner.x, corner.y, 1);
      }
      PVector angles = twoToThree.get3DRotations(testList);
      rotation = angles;
      angles.set(angles.x/PI * 180, angles.y /PI * 180, angles.z /PI * 180);
      println(angles);

      PImage img2 = thresholdHSB(img.copy(), 100, 140, 80, 255, 10, 170);
      PImage img3 = blobs.findConnectedComponents(img2, true);
      PImage img4 = threshold(convolute(convolute(convolute(convolute(convolute(convolute(convolute(convolute(convolute(convolute(convolute(convolute(convolute(convolute(img3)))))))))))))), 100);
      img4 = threshold(convolute(convolute(convolute(convolute(convolute(convolute(convolute(convolute(convolute(convolute(convolute(convolute(convolute(convolute(img3)))))))))))))), 40);
      PImage copy4 = img4;
      PImage img5 = scharr(img4);
      PImage img6 = threshold(img5, 100);
      PImage copy6 = img6;
      //image(img6, 0,0);
      //hough(img6, 6);
      List<PVector> corner = corners.findBestQuad(testList, img.width, img.height, (img.width*img.height), 0, true);
      image(img, 0, 0);
      copy4.resize(400, 400);
      copy6.resize(400, 400);
      image(copy6, img.width, 0);
      image(copy4, img.width+copy4.width, 0);
      plot(testList, img);
      for (PVector angle : corner) {
        pushMatrix();
        stroke(0);
        fill(255);
        circle(angle.x, angle.y, 20);
        popMatrix();
      }
    }
  }

  PVector getRotation() {
    PVector goodRot = new PVector(rotation.x > PI/2 ? rotation.x - PI : (rotation.x < -PI/2 ? rotation.x + PI : rotation.x), rotation.y > PI/2 ? rotation.y - PI : (rotation.y < -PI/2 ? rotation.y + PI : rotation.y), rotation.z > PI/2 ? rotation.z - PI : (rotation.z < -PI/2 ? rotation.z + PI : rotation.z));
    return goodRot;
  }



  //====================================================



  //========================HSB====================

  PImage threshold(PImage img, int threshold) {
    PImage result = createImage(img.width, img.height, RGB);
    for (int i = 0; i < img.width * img.height; i++) {
      // do something with the pixel img.pixels[i]
      if (brightness(img.pixels[i]) < threshold) {
        result.pixels[i] = color(0);
      } else {
        result.pixels[i] = color(255);
      }
    }
    return result;
  }

  PImage thresholdHSB(PImage img, int minH, int maxH, int minS, int maxS, int minB, int maxB) {
    PImage result = createImage(img.width, img.height, RGB);
    for (int i = 0; i < img.width * img.height; i++) {
      color c = color(img.pixels[i]);
      if ((int)hue(c) >= minH && (int)hue(c) <= maxH && (int)saturation(c) <= maxS && (int)saturation(c) >= minS && (int)brightness(c) <= maxB && (int)brightness(c) >= minB) {
        result.pixels[i] = Integer.MAX_VALUE;
      } else {
        result.pixels[i] = 0;
      }
    }
    return result;
  }

  boolean imagesEqual(PImage img1, PImage img2) {
    if (img1.width != img2.width || img1.height != img2.height)
      return false;
    for (int i = 0; i < img1.width*img1.height; i++)
      //assuming that all the three channels have the same value
      if (alpha(img1.pixels[i]) != alpha(img2.pixels[i]))
        return false;
    return true;
  }

  //=============================Edges====================================

  PImage convolute(PImage img) {
    float[][] kernel = {{ 9, 12, 9 }, 
      { 12, 15, 12 }, 
      { 9, 12, 9 }};

    float normFactor = 99.f;
    PImage result = createImage(img.width, img.height, ALPHA);
    result.loadPixels();
    int N = 3;
    float acc;

    for (int x = 1; x < img.width-1; ++x) {
      for (int y = 1; y < img.height-1; ++y) {
        acc = 0;
        for (int i =0; i<N; ++i) {
          for (int j=0; j<N; ++j) {
            acc+= kernel[i][j]*brightness(img.pixels[x - N/2 + i + img.width * (y - N/2 + j)]);
          }
        }
        float change = (int)((float)acc/normFactor);
        result.pixels[y * img.width + x] = color(change);
      }
    }
    for (int x = 0; x < img.width; x++) {
      result.pixels[x] = color(0);
      result.pixels[x + (img.height - 1) *img.width] = color(0);
    }

    for (int y = 0; y < img.height; y++) {
      result.pixels[y * img.width] = color(0);
      result.pixels[img.width - 1 + y*img.width] = color(0);
    }

    result.updatePixels();
    return result;
  }

  PImage scharr(PImage img) {
    float[][] vKernel = {
      { 3, 0, -3 }, 
      { 10, 0, -10 }, 
      { 3, 0, -3 } };

    float[][] hKernel = {
      { 3, 10, 3 }, 
      { 0, 0, 0 }, 
      { -3, -10, -3 } };
    PImage result = createImage(img.width, img.height, ALPHA);
    // clear the image
    for (int i = 0; i < img.width * img.height; i++) {
      result.pixels[i] = color(0);
    }
    float max=0;
    float[] buffer = new float[img.width * img.height];
    int N = 3;
    float normFactor = 1;
    int sum_h = 0;
    int sum_v = 0;
    int sum = 0;

    for (int x = 1; x < img.width-1; ++x) {
      for (int y = 1; y < img.height-1; ++y) {
        sum_h = 0;
        sum_v = 0;
        sum = 0;
        for (int i = 0; i < N; ++i) {
          for (int j = 0; j < N; ++j) { 
            float br = brightness(img.pixels[x - N/2 + j + (y - N/2 + i) * img.width]);
            sum_h += (hKernel[i][j])* br;
            sum_v += (vKernel[i][j])* br;
          }
        }
        sum_h = (int)(sum_h/normFactor);
        sum_v = (int)(sum_v/normFactor);
        sum= (int)sqrt(pow(sum_h, 2) + pow(sum_v, 2));
        buffer[y * img.width + x] = sum;
        if (sum > max) {
          max = sum;
        }
      }
    }

    for (int y = 1; y < img.height - 1; y++) { // Skip top and bottom edges 
      for (int x = 1; x < img.width - 1; x++) { // Skip left and right
        int val=(int)((buffer[y * img.width + x] / max)*255);
        result.pixels[y * img.width + x] = color(val);
      }
    }
    return result;
  }


  //===================HoughTransform==========================

  List<PVector> hough(PImage edgeImg, int nLines) {

    //The max radius is the image diagonal, but it can be also negative
    final int rDim = (int) ((sqrt((edgeImg.width)*(edgeImg.width) +
      (edgeImg.height)*(edgeImg.height) )) *2 / discretizationStepsR +1);

    // our accumulator
    int[] accumulator = new int[phiDim * rDim];

    // Fill the accumulator: on edge points (ie, white pixels of the edge
    // image), store all possible (r, phi) pairs describing lines going
    // through the point.
    for (int y = 0; y < edgeImg.height; y++) {
      for (int x = 0; x < edgeImg.width; x++) {
        // Are we on an edge?
        if (brightness(edgeImg.pixels[y * edgeImg.width + x]) != 0) {
          for (int phi = 0; phi < phiDim; ++phi) {
            int r = Math.round((tabCos[phi]*x + tabSin[phi]*y)+ rDim/2);
            accumulator[phi * rDim + r] += 1;
          }
        }
      }
    }

    ArrayList<Integer> bestCandidates = new ArrayList<Integer>();

    int regionSize = 10;
    for (int i = 0; i < accumulator.length; i++) {
      if (accumulator[i] > minVotes) {
        boolean bestAdd = true;
        for (int j = i - regionSize; j < i + regionSize; j++) {
          if ((j >= 0) && (j < accumulator.length) &&  (j != 1)) {
            if (accumulator[j] > accumulator[i]) {
              bestAdd = false;
            }
          }
        }
        if (bestAdd) {
          bestCandidates.add(i);
        }
      }
    }

    Collections.sort(bestCandidates, new HoughComparator(accumulator));

    ArrayList<PVector> lines=new ArrayList<PVector>();

    for (int i : bestCandidates.subList(0, Math.min(bestCandidates.size(), nLines))) {
      int accPhi = (int) (i / (rDim));
      int accR = i - (accPhi) * (rDim);
      float r = (accR - (rDim) * 0.5f) * discretizationStepsR;
      float phi = accPhi * discretizationStepsPhi;
      lines.add(new PVector(r, phi));
    }


    return lines;
  }

  void plot(List<PVector> lines, PImage edgeImg) {
    for (int idx = 0; idx < lines.size(); idx++) {
      PVector line=lines.get(idx);
      float r = line.x;
      float phi = line.y;
      // Cartesian equation of a line: y = ax + b
      // in polar, y = (-cos(phi)/sin(phi))x + (r/sin(phi))
      // => y = 0 : x = r / cos(phi)
      // => x = 0 : y = r / sin(phi)
      // compute the intersection of this line with the 4 borders of
      // the image
      int x0 = 0;
      int y0 = (int) (r / sin(phi));
      int x1 = (int) (r / cos(phi));
      int y1 = 0;
      int x2 = edgeImg.width;
      int y2 = (int) (-cos(phi) / sin(phi) * x2 + r / sin(phi));
      int y3 = edgeImg.width;
      int x3 = (int) (-(y3 - r / sin(phi)) * (sin(phi) / cos(phi)));
      // Finally, plot the lines
      stroke(204, 102, 0); 
      if ((y0 > 0) && (y0 <= edgeImg.height)) {
        if ((x1 > 0) && (x1 <= edgeImg.width))
          line(x0, y0, x1, y1);
        else if ((y2 > 0) && (y2 <= edgeImg.height))
          line(x0, y0, x2, y2);
        else
          line(x0, y0, x3, y3);
      } else {
        if ((x1 > 0) && (x1 <= edgeImg.width)) {
          if ((y2 > 0) && (y2 <= edgeImg.height))
            line(x1, y1, x2, y2); 
          else
            line(x1, y1, x3, y3);
        } else
          line(x2, y2, x3, y3);
      }
    }
  }

  //===================BLOB=======================

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

  //====================HoughComparator======================
  class HoughComparator implements java.util.Comparator<Integer> {
    int[] accumulator;
    public HoughComparator(int[] accumulator) {
      this.accumulator = accumulator;
    }
    @Override
      public int compare(Integer l1, Integer l2) {
      if (accumulator[l1] > accumulator[l2]
        || (accumulator[l1] == accumulator[l2] && l1 < l2)) return -1;
      return 1;
    }
  }
}
