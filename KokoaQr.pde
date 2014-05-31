// Librerias a usar
import java.io.*; // for the loadPatternFilenames() function
import processing.opengl.*;
//import processing.video.*; // para windows
import codeanticode.gsvideo.*; // para linux
import jp.nyatla.nyar4psg.*;
import javax.swing.*;
import java.util.*;



// Imagenes a usar
PImage imgLogoBlender;
PImage imgLogoOpenSuse;
PImage imgLogoUbuntu;
PImage imgLogoDebian;
PImage imgNuMascota;
PImage imgTuxHomero;
PImage imgTuxIronman;
PImage imgTuxGoku;
PImage imgTuxMarioBros;
PImage imgTuxSuperMan;
PImage imgTuxSlash;
PImage imgTuxMagneto;

PImage imgFondo, imgFondoError;


//Variables



//dimensiones de la pantalla
int winWidth=1024, winHeight=768; //Cambia Dimensiones de la ventana

// dimensiones de la camara
int capWidth = 640, capHeight = 480;
// the dimensions at which the AR will take place.
int arWidth = 640;
int arHeight = 480; //480 360

int tiempoInicial;   //  Tiempo de captura inicial
boolean seTomaFoto;  // indica si se toma foto
//PFont fuente;        //Tipo de fuente
int fontSize = 160;
PImage imgCaptada; //Imagen final
PImage imgNueva;
String mensaje = "";

String rutaArchivo = "";
String nombreArchivo = "captura_ar.jpg";

// Make sure to change both the camPara and the patternPath String to where the files are on YOUR computer
// the full path to the camera_para.dat file
String camPara = "camera_para.dat";
// the full path to the .patt pattern files

//Patrones
String proyectPath = sketchPath("/home/fzzio/sketchbook/proyectos/KokoaQr/");
String patronesPath = proyectPath + "data/patrones";
String imagenesPath = proyectPath + "data/img";

boolean finDelJuego = false;
int numPixels;

//Capture videoC; // para windows
GSCapture videoC; // para linux
PImage video; // en esta variable mostramos el video invertido

//********NYARTOOL ********
MultiMarker nya;
int numMarkers = 8;
float displayScale;
color[] colors = new color[numMarkers];
float[] scaler = new float[numMarkers];
PImage[] imagenesArr = new PImage[numMarkers];



String[] nombresPatrones = new String[numMarkers];
String[] nombresImagenes = new String[numMarkers];


void setup() {
  // inicializacion de los fondos que se mostraran
  ///imgFondo = loadImage("fondos/fondo-3.jpg");
  ///imgFondoError = loadImage("fondos/fondo-1.jpg");
  
  // configuracion de la camara  
  size(winWidth, winHeight, P3D);
  //size(winWidth,winHeight,OPENGL);//tamaños de la pantalla
  frameRate(90);// para mejorar la velocidad de la imagen por cuadro  o 30
  
  //fuente = createFont("Arial", fontSize, true);
  
  
  // Marcador de Nyartoolkit
  nya = new MultiMarker(this, arWidth, arHeight, camPara, NyAR4PsgConfig.CONFIG_PSG);
  // set the delay after which a lost marker is no longer displayed. by default set to something higher, but here manually set to immediate.
  nya.setLostDelay(1);

  
  
  nombresPatrones = loadPatternFilenames(patronesPath);
  nombresImagenes = loadPatternFilenames(imagenesPath);  
  for (int i=0; i<numMarkers; i++){
    nya.addARMarker(patronesPath + "/" + nombresPatrones[i], 80); //agregamos los patrones    
    imagenesArr[i] = loadImage(imagenesPath + "/" + nombresImagenes[i]);
    
    colors[i] = color(random(255), random(255), random(255), 160); // random color, always at a transparency of 160
    scaler[i] = random(0.5, 1.9); // scaled at half to double size
  }

  // to correct for the scale difference between the AR detection coordinates and the size at which the result is displayed
  displayScale = (float) winWidth / arWidth;
  
  
  //video = new Capture(this,capWidth,capHeight,15); // para windows
  //videoC = new GSCapture(this, capWidth, capHeight, "/dev/video0"); // para linux
  videoC = new GSCapture(this, capWidth, capHeight, "/dev/video1"); // segunda webcam
  videoC.start();
  
  println("\nResoluciones soportadas por la webcam");
  int[][] res = videoC.resolutions();
  for (int i = 0; i < res.length; i++) {
    println(res[i][0] + "x" + res[i][1]);
  }
  
  println("\nFramerates soportados por la camara");
  String[] fps = videoC.framerates();
  for (int i = 0; i < fps.length; i++) {
    println(fps[i]);
  }
  
  
  
  video = createImage(videoC.width, videoC.height, RGB);
  numPixels = videoC.width * videoC.height;
  
 
  
}


void stop(){
  // Stop the GSVideo webcam capture
  videoC.stop();
  // Stop the sketch
  this.stop();
}



void draw()
{
  
  // Caragamos datos de la camara
  if (videoC.available()) {
    background(0);
    videoC.read();
    
    loadPixels();
    videoC.loadPixels();
    video = mirrorImage(videoC);
    
    hint(DISABLE_DEPTH_TEST); // variables de Nayrtoolkit
      //image(video, (winWidth - capWidth)/2 , (winHeight - capHeight)/2  );
      image(video, 0, 0, winWidth, winHeight);
    hint(ENABLE_DEPTH_TEST);
    
    PImage cSmall = video.get();
    cSmall.resize(arWidth, arHeight);
    nya.detect(cSmall); // detect markers in the image
    
    //drawMarkers(); // draw the coordinates of the detected markers (2D)
    //drawBoxes();
    
    dibujarElementos();
    
  }
}


void dibujarElementos(){
  nya.setARPerspective();
  textAlign(CENTER, CENTER);
  //scale(displayScale);
  for (int i=0; i < numMarkers; i++ ) {
    if ((!nya.isExistMarker(i))) { continue; }
    pushMatrix();
      setMatrix(nya.getMarkerMatrix(i));
      pushMatrix();
        scale(1, 1, 0.10);
        //scale(scaler[i]);
        translate(0, 0, 20);
        lights();
        stroke(0);
        fill(colors[i]);
        box(80);
        noLights();
      popMatrix();
      pushMatrix();
        loadPixels();        
          scale(1, -1);
          translate(0, 0, 10.1);
          image(imagenesArr[i], -60, -60, 120, 120);
        updatePixels();
       popMatrix();
    popMatrix();
  }
  perspective();
}

void drawMarkers() {
  textAlign(LEFT, TOP);
  textSize(10);
  noStroke();
  scale(displayScale);
  for (int i=0; i < numMarkers; i++ ) {
    PVector[] pos2d = nya.getMarkerVertex2D(i);
    for (int j=0; j < pos2d.length; j++ ){
      String s = "(" + int(pos2d[j].x) + "," + int(pos2d[j].y) + ")";
      pushMatrix();
        fill(255);
        rect(pos2d[j].x, pos2d[j].y, textWidth(s) + 3, textAscent() + textDescent() + 3);
        fill(0);
        text(s, pos2d[j].x + 2, pos2d[j].y + 2);
        fill(255, 0, 0);
        ellipse(pos2d[j].x, pos2d[j].y, 5, 5);
      popMatrix();
    }
  }
}

void drawBoxes() {
  nya.setARPerspective();
  textAlign(CENTER, CENTER);
  textSize(20);
  for (int i=0; i < numMarkers; i++ ) {
    if ((!nya.isExistMarker(i))) { continue; }
    pushMatrix();
      setMatrix(nya.getMarkerMatrix(i));
      scale(1, 1);
      //scale(scaler[i]);
      translate(0, 0, 20);
      lights();
      stroke(0);
      fill(colors[i]);
      box(40);
      noLights();
      translate(0, 0, 20.1);
      noStroke();
      fill(255, 50);
      rect(-20, -20, 40, 40);
      translate(0, 0, 0.1);
      fill(0);
      text("" + i, -20, -20, 40, 40);
    popMatrix();
  }
  perspective();
}




// this function loads .patt filenames into a list of Strings based on a full path to a directory (relies on java.io)
String[] loadPatternFilenames(String path) {
  File folder = new File(path);
  String[] lista = folder.list();
  if (lista == null) {
    println("La carpeta '" + path + "' no puede ser accesada.");
    return null;
  }else {
    for (int i=0; i< lista.length; i++){
      if(lista[i].equals(".directory")){
        println("Borrar archivo '.directory' en " + path);
      }
    }
    return lista;
  }
}



PImage mirrorImage(PImage source){
  // Create new storage for the result RGB image 
  
  PImage response = createImage(source.width, source.height, RGB);
  
  // Load the pixels data from the source and destination images
  
  source.loadPixels();
  
  response.loadPixels();  
    
  // Walk thru each pixel of the source image
  
  for (int x=0; x<source.width; x++) 
  {
    for (int y=0; y<source.height; y++) 
    {
      // Calculate the inverted X (loc) for the current X
      
      int loc = (source.width - x - 1) + y * source.width;

      // Get the color (brightness for B/W images) for 
      // the inverted-X pixel
      
      color c = source.pixels[loc];
      
      // Store the inverted-X pixel color information 
      // on the destination image
      
      response.pixels[x + y * source.width] = c;
    }
  }
  
  // Return the result image with the pixels inverted
  // over the x axis 
  
  return response;
}
