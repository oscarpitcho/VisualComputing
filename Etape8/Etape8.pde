PImage img;
PImage imgTest;
HScrollbar thresholdBar;
HScrollbar thresholdBar2;

void settings() {
  size(1600, 600);
}

void setup() {
  img = loadImage("board1.jpg");
  imgTest = loadImage("board1Scharr.bmp");

  thresholdBar = new HScrollbar(0, 580, 600, 20);
  thresholdBar2 = new HScrollbar(0, 560, 00, 20);

  noLoop();
}

void draw() {
  //image(img, 0, 0); //show image
  //PImage img2 = thresholdHSB(img, 100, 200, 100, 255, 45, 100); threshold test 
  //PImage img2 = convolute(convolute(threshold(scharr(thresholdHSB(img, 100, 150, 70, 255, 0, 200)), 100)));
  PImage img2 = scharr(img);
  imgTest.loadPixels();
  img2.loadPixels();

  image(img2, 0, 0);
  image(imgTest, img.width, 0);


  if (imagesEqual(img2, imgTest))
    println("true");
  else
    println("faux");

  /*
  thresholdBar.display();
   thresholdBar.update();
   
   thresholdBar2.display();
   thresholdBar2.update();
   println(thresholdBar.getPos()); // getPos() returns a value between 0 and 1
   */
}

PImage threshold(PImage img, int threshold) {
  // create a new, initially transparent, 'result' image
  PImage result = createImage(img.width, img.height, RGB);
  result.loadPixels();
  img.loadPixels();

  for (int i = 0; i < img.width * img.height; i++) {
    // do something with the pixel img.pixels[i]
    if (brightness(img.pixels[i]) < threshold)
      result.pixels[i] = color(0);
    else
      result.pixels[i] = color(255);
  }
  return result;
}

/*
PImage HueMap(PImage img) {
 PImage result = createImage(img.width, img.height, RGB);
 result.loadPixels();
 for (int i = 0; i < img.width * img.height; i++) {
 color c = color(img.pixels[i]);
 result.pixels[i] = color((int)hue(c));
 }
 return result;
 }
 
 int hueScrollbarValue(HScrollbar scroll) {
 return (int)(scroll.getPos() * 255);
 }
 
 PImage displayHueRange(PImage img, int infThreshold, int supThreshold) {
 PImage result = createImage(img.width, img.height, RGB);
 result.loadPixels();
 img.loadPixels();
 for (int i = 0; i < img.width * img.height; i++) {
 color c1 = color(img.pixels[i]);
 if ((int)hue(c1) >= infThreshold && (int)hue(c1) <= supThreshold) {
 result.pixels[i] = img.pixels[i];
 } else {
 result.pixels[i] = color(0);
 }
 }
 return result;
 }
 */

PImage thresholdHSB(PImage img, int minH, int maxH, int minS, int maxS, int minB, int maxB) {
  PImage result = createImage(img.width, img.height, RGB);
  img.loadPixels();
  result.loadPixels();
  for (int i = 0; i < img.width * img.height; i++) {
    color c = color(img.pixels[i]);
    if ((int)hue(c) >= minH && (int)hue(c) <= maxH && (int)saturation(c) <= maxS && (int)saturation(c) >= minS && (int)brightness(c) <= maxB && (int)brightness(c) >= minB) {
      result.pixels[i] = color(255);
    } else {
      result.pixels[i] = color(0);
    }
  }
  return result;
}

boolean imagesEqual(PImage img1, PImage img2) {
  if (img1.width != img2.width || img1.height != img2.height)
    return false;
  for (int i = 0; i < img1.width*img1.height; i++)
    //assuming that all the three channels have the same value
    if (red(img1.pixels[i]) != red(img2.pixels[i])) {
      println("pixel number : " + i);
      println("pixel value : " + Integer.toHexString(img1.pixels[i]));
      println("pixel value : " + Integer.toHexString(img2.pixels[i]));
      return false;
    }
  return true;
}

PImage convolute(PImage img) {
  float[][] kernel = { { 9, 12, 9 }, 
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
  // *************************************
  // Implement here the double convolution
  // *************************************
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
      if (y * img.width + x == 801)
        println("##Buffer " + buffer[801]);
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
