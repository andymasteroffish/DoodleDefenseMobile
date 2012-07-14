#pragma once


#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"

#include "Foe.h"
#include "NormFoe.h"
//#include "FastFoe.h"
//#include "StealthFoe.h"
//#include "ImmuneRedFoe.h"
//#include "HeavyFoe.h"

#include "vectorField.h"
#include "tile.h"
#include "Wave.h"
#include "WaveInfoBox.h"

#include "Explosion.h"
#include "SoundManager.h"


//ON IPHONE NOTE INCLUDE THIS BEFORE ANYTHING ELSE
#include "ofxOpenCv.h"

//warning video player doesn't currently work - use live video only
//#define _USE_LIVE_VIDEO

class testApp : public ofxiPhoneApp{
	
	public:
		
		void setup();
        void loadFromText();
		void update();
		void draw();
        void drawGame();
        void drawPlayerInfo();
        void drawWaveCompleteAnimation();
        void exit();
    
        void touchDown(ofTouchEventArgs & touch);
        void touchMoved(ofTouchEventArgs & touch);
        void touchUp(ofTouchEventArgs & touch);
        void touchDoubleTap(ofTouchEventArgs & touch);
        void touchCancelled(ofTouchEventArgs & touch);
	
        void lostFocus();
        void gotFocus();
        void gotMemoryWarning();
        void deviceOrientationChanged(int newOrientation);
    
    //game functions
    void reset();
    void convertDrawingToGame();    //takes the pixels and reads the game values from them
    void setMazeBorders();
    void thickenWallImage();
    
    void spawnFoe(string name, int level);
    void killFoe(int num);
    void checkTowers(string type);
    
    void takeDamage(int damage);
    
    //delaing with the waves
    void startNextWave();
    void endWave();
    float getInkFromWaves(int num);
    
    //size of the openCV image the game data is taken from
    int fieldW;
    int fieldH;
    //size of the image show to the player
    int boardW;
    int boardH;
    
    float fieldScale; //how much to blow up the wall image
    float boardScale;   //how much to blow up the display image
    
    //walls
    ofxCvGrayscaleImage		blackImg;
    unsigned char *			blackPixels;
    
    //maze borders in field units
    int mazeTop;
    int mazeBottom;
    int mazeLeft;
    int mazeRight;
    int inkRefund;  //the ink used on the border is given back to the player
    
    int blackThreshold; //thresholding to get the black marker (along with all other colored markers)
    
    //images as lists of pixels showing where the marker is
    ofxCvGrayscaleImage 	wallImage;  
    unsigned char *			wallPixels;
    
    //colored towers    
    ofxCvGrayscaleImage     colorImgs[3];
    unsigned char *			colorPixels[3];
    
    //combined image
    ofxCvColorImage         combinedImg;
    unsigned char *			combinedPixels;
    
    ofPoint boardOffset;    //where the gameboard is placed on screen
    
    bool needToConvertDrawingToGame;    //flag for when a pixel in one of the images has changed
    
    int curBrushColor;  //3 for black

    //selecting color
    ofRectangle colorButtons[5];
    
    //debug switching between views
    ofRectangle viewButtons[5];
    int curView;
    
    //resons the game might be paused   SOME OF THESE DON'T APPLY IN THE IPAD VERSION
    bool paused;        //global pause. If any reason is true, this is true
    bool playerPause;   //player pauses the game
    bool noPath;        //becomes true if any foe can't reach the end
    bool tooMuchInk;    //pauses the game when the player has used more ink than they have
    bool gameStarted;   //the camera must have taken at least one image to play the game
    bool fingerDown;
    
    bool fastForward;
    
    //vector field
	vectorField VF;
    
    //the player
    int score;
    int healthStart;
    int health;
    float startInk;
    float totalInk;
    float inkUsed;
    
    int damageFlashTime;
    int damageFlashTimer;   //how long to flash red when hit
    
    //images for displaying player info
    ofImage healthPicFull[15];
    ofImage healthPicEmpty[15];
    
    //the foes
    vector <Foe *> foes;
    int startX[2], startY[2];   //multiple entrances
    int goalX[2], goalY[2];
    int numEntrances;           //how many entrance are being used
    int nextEntrance;           //alternate which gate foes are coming out of if there are more than one
    //pics for the foes (outline and fill)
    #define NUM_FOE_FRAMES 5
    ofImage normFoePic[2][NUM_FOE_FRAMES]; 
    ofImage fastFoePic[2][NUM_FOE_FRAMES]; 
    ofImage heavyFoePic[2][NUM_FOE_FRAMES]; 
    ofImage stealthFoePic[2][NUM_FOE_FRAMES]; 
    ofImage immuneRedFoePic[2][NUM_FOE_FRAMES]; 
    
    //explosions and poofs from hitting foes
    ofImage explosionPic;
    vector <Explosion> explosions;
    
    //waves of foes
    vector<Wave> waves;
    int curWave;
    bool wavesDone; //game over, man
    bool waveComplete;
    float waveAnimationTime;
    float waveAnimationStart;
    
    //the boxes to show the details for each wave
    vector <WaveInfoBox> waveInfoBoxes;
    float waveInfoBottom;   //line where the boxes want to fall to
    float waveInfoX;
    float waveInfoDistToFadeOut;    //how far from the bottom the box can be before daing completely
#define NUM_WAVE_INFO_BOX_PICS 3
    ofImage waveInfoPics[NUM_WAVE_INFO_BOX_PICS];        //images for the boxes
    
    //fonts
	ofTrueTypeFont infoFontSmall;
    ofTrueTypeFont infoFont;
    ofTrueTypeFont infoFontBig;
    ofTrueTypeFont infoFontHuge;
    
    //sounds
    SoundManager SM;
    
    //debug
    bool showAllInfo;   //shows all of the bullshit lines and data

};
