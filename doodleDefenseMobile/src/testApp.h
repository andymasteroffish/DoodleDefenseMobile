#pragma once


#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"


//ON IPHONE NOTE INCLUDE THIS BEFORE ANYTHING ELSE
#include "ofxOpenCv.h"

//warning video player doesn't currently work - use live video only
//#define _USE_LIVE_VIDEO

class testApp : public ofxiPhoneApp{
	
	public:
		
		void setup();
		void update();
		void draw();
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

    //size of the openCV image the game data is taken from
    int fieldW;
    int fieldH;
    
    float fieldScale; //how much to blow up the image
    
    //walls
    ofxCvGrayscaleImage		blackImg;
    unsigned char *			blackPixels;
    
    //colored towers    
    ofxCvGrayscaleImage     colorImgs[3];
    unsigned char *			colorPixels[3];
    
    //combined image
    ofxCvColorImage         combinedImg;
    unsigned char *			combinedPixels;
    
    ofPoint boardOffset;    //where the gameboard is placed on screen
    
    int curBrushColor;  //3 for black

    //selecting color
    ofRectangle colorButtons[5];
    
    //debug switching between views
    ofRectangle viewButtons[5];
    int curView;

};
