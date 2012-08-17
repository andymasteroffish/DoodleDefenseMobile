#pragma once


#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"

#include "Foe.h"
#include "NormFoe.h"
#include "FastFoe.h"
#include "StealthFoe.h"
#include "ImmuneRedFoe.h"
#include "HeavyFoe.h"

#include "Tower.h"
#include "HitTower.h"
#include "FreezeTower.h"
#include "BombTower.h"

#include "BombAnimation.h"

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
    
    void brushDown(float touchX, float touchY);
    
    void convertDrawingToGame();    //takes the pixels and reads the game values from them
    bool findPathsForFoes();
    void setMazeBorders();
    void thickenWallImage();    //KILL THIS
    
    void spawnFoe(string name, int level);
    void killFoe(int num);
    void checkTowers(string type);
    
    void takeDamage(int damage);
    
    //delaing with the waves
    void startNextWave();
    void endWave();
    float getInkFromWaves(int num);
    
    //hardware
    bool retina;
    
    //size of the openCV image the game data is taken from
    #define FIELD_W 80
    #define FIELD_H 60
    int fieldW;
    int fieldH;
    //size of the image show to the player
    int boardW;
    int boardH;
    
    float fieldScale; //how much to blow up the wall image
    float boardScale;   //how much to blow up the display image
    
    //maze borders in field units
    int mazeTop;
    int mazeBottom;
    int mazeLeft;
    int mazeRight;
    int inkRefund;  //the ink used on the border is given back to the player
    
    int blackThreshold; //thresholding to get the black marker
    int colorThreshold; //past this threshold, the pixel counts as being used
    
    //images as lists of pixels showing where the marker is
    //walls
    //images that get drawn in
    ofxCvGrayscaleImage		blackImg;
    unsigned char *			blackPixels;
    //thresholded images to actually mark off walls
    ofxCvGrayscaleImage 	wallImage;  
    unsigned char *			wallPixels;
    
    //colored towers   
    //images that get drawn in
    ofxCvGrayscaleImage     colorImgs[3];
    unsigned char *			colorPixels[3];
    
    //display images - taking the CV images and showing them on screen
    unsigned char * colorDispPixels[3];
    ofTexture colorDispTex[3];
    unsigned char * wallDispPixels;
    ofTexture wallDispTex;
    ofColor dispColor[3];   //what color to actually tint each color image
    
    ofPoint boardOffset;    //where the gameboard is placed on screen
    
    bool needToConvertDrawingToGame;    //flag for when a pixel in one of the images has changed
    
    int curBrushColor;  //3 for black

    //selecting color
    ofRectangle colorButtons[5];
    ofImage colorButtonPics[5];
    
    //debug switching between views
    ofRectangle viewButtons[5];
    int curView;
    
    //game buttons
    ofImage pauseButtonPic;
    ofRectangle pauseButton;
    ofImage fastForwardButtonPic;
    ofRectangle fastForwardButton;
    
    
    //images to display as the boarders
    ofImage borderPics[2];
    
    ofxCvContourFinder 	contourFinder;  //for finding the blobs of color
    
    //resons the game might be paused   SOME OF THESE DON'T APPLY IN THE IPAD VERSION
    bool paused;        //global pause. If any reason is true, this is true
    bool playerPause;   //player pauses the game
    bool noPath;        //becomes true if any foe can't reach the end
    //bool tooMuchInk;    //pauses the game when the player has used more ink than they have
    bool gameStarted;   //the camera must have taken at least one image to play the game
    bool fingerDown;
    
    bool fastForward;
    
    //showing a warning on screen if the player is out of ink
    float outOfInkBannerTimer;
    float outOfInkBannerTime;
    
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
    
    //optimizing pathfinding by finding the best route from the start to the exit and seeing which foes can hop on board
    ofPoint routeFromLeftGrid[FIELD_W][FIELD_H];
    ofPoint routeFromTopGrid[FIELD_W][FIELD_H];
    
    //explosions and poofs from hitting foes
    ofImage explosionPic;
    vector <Explosion> explosions;
    
    //getting ink
    vector <particle> inkParticles;
    
    //ink ussage - how much each pixel costs
    float blackInkValue;
    float colorInkValue[3];
    
    //getting ink back when a wall is erased
    float wallRefund;
    
    //towers - the point of the damn game
    vector <Tower *> towers;
    vector <TowerInfo> lastSafeTowerSet;  //all the locaitons of the towers when no problem was encounterred
    int towerID;    //goes up each time a tower is made so they each have a unique ID number
    float towerRefund;  //percentage of the value of the tower that the user gets back if they erase one
    float maxCompactness;   //how far the blob can be from being a circle and still be counted
    
    ofImage bulletPic;
    
    //vector to hold the bomb animations
    vector<BombAnimation> bombAnimations;
    
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
    float waveInfoDistToFadeOut;    //how far from the bottom the box can be before daing completely
#define NUM_WAVE_INFO_BOX_PICS 3
    ofImage waveInfoPics[NUM_WAVE_INFO_BOX_PICS];        //images for the boxes
    
    //banners
    ofImage banners[6];
    ofImage bannerBacks[6];
    ofImage titleBig;
    ofImage playerHitPic;
    
    //pause screen buttons
    ofRectangle pauseScreenButtons[3];
    ofImage pauseScreenButtonPics[3];
    
    //background pic
    ofImage backgroundPic;
    
    //fonts
	ofTrueTypeFont infoFontSmall;
    ofTrueTypeFont infoFont;
    ofTrueTypeFont infoFontBig;
    ofTrueTypeFont infoFontHuge;
    
    //sounds
    SoundManager SM;
    
    //debug
    bool showAllInfo;   //shows all of the bullshit lines and data
    
    //timing
    float prevFrameTime;
    float deltaTime;
    
    //tetsing
    int lastX;
    int lastY;

};
