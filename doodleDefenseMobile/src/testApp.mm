#include "testApp.h"


//--------------------------------------------------------------
void testApp::setup(){	
    cout<<ofGetWidth()<<" X "<<ofGetHeight()<<endl;
	
    //orient landscape
	iPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_RIGHT);
	ofSetFrameRate(30);
    
	ofBackground(127,127,127);
    
    //size of the grid the game is played on
    fieldW=160;
    fieldH=120;
    fieldScale = 5;
    
    boardOffset.set(60,120);
    
    //black image
    blackImg.allocate(fieldW, fieldH);
    blackPixels = new unsigned char [fieldW * fieldH];
    //r,g,b images WILL PROBABLY NEED TO BE DOUBLE RESOLUTION
    for (int i=0; i<3; i++){
        colorImgs[i].allocate(fieldW, fieldH);
        colorPixels[i]= new unsigned char [fieldW * fieldH];
    }
    //combined image
    combinedImg.allocate(fieldW, fieldH);
    combinedPixels = new unsigned char [fieldW * fieldH * 3];
    
    //clear them
    for (int i=0; i<fieldW*fieldH; i++){
        blackPixels[i] = 0;
        colorPixels[0][i] = 0;
        colorPixels[1][i] = 0;
        colorPixels[2][i] = 0;
    }
    for (int i=0; i<fieldW*fieldH*3; i++){
        combinedPixels[i] = 0;
    }
    
    
    curBrushColor = 0;
    
    //color selection
    int buttonW=100;
    int buttonH=100;
    for (int i=0; i<5; i++){
        colorButtons[i].set(i*(buttonW+10),0, buttonW, buttonH);
    }
	
	//testing different views
    for (int i=0; i<5; i++){
        viewButtons[i].set(ofGetWidth()-buttonW,i*(buttonH/2+10), buttonW, buttonH/2);
    }
    curView = 4;
}

//--------------------------------------------------------------
void testApp::update(){
	
}

//--------------------------------------------------------------
void testApp::draw(){	
	ofSetColor(255);
        
    if (curView < 3)
        colorImgs[curView].draw(boardOffset.x,boardOffset.y, fieldW*fieldScale, fieldH*fieldScale);
    if (curView == 3)
        blackImg.draw(boardOffset.x,boardOffset.y, fieldW*fieldScale, fieldH*fieldScale);
    if (curView == 4)
        combinedImg.draw(boardOffset.x,boardOffset.y, fieldW*fieldScale, fieldH*fieldScale);
    
    //color selection buttons
    ofFill();
    ofSetColor(200, 10, 10);
    ofRect(colorButtons[0]);
    ofSetColor(10, 200, 10);
    ofRect(colorButtons[1]);
    ofSetColor(10, 10, 200);
    ofRect(colorButtons[2]);
    ofSetColor(10, 10, 10);
    ofRect(colorButtons[3]);
    ofSetColor(255, 255, 255);
    ofRect(colorButtons[4]);
    
    //view select buttons
    ofNoFill();
    ofSetColor(200, 10, 10);
    ofRect(viewButtons[0]);
    ofSetColor(10, 200, 10);
    ofRect(viewButtons[1]);
    ofSetColor(10, 10, 200);
    ofRect(viewButtons[2]);
    ofSetColor(10);
    ofRect(viewButtons[3]);
    ofSetColor(255);
    ofRect(viewButtons[4]);
    
    ofSetColor(200, 10, 10);
    ofRect(colorButtons[0]);
    
    ofSetColor(255,0,0);
    ofDrawBitmapString(ofToString(ofGetFrameRate()), 5,ofGetHeight()-2);
}
    
//--------------------------------------------------------------
void testApp::exit(){
        
}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs & touch){
    for (int i=0; i<5; i++){
        if (colorButtons[i].inside(touch.x,touch.y)){
            curBrushColor = i;
        }
    }
    
    for (int i=0; i<5; i++){
        if (viewButtons[i].inside(touch.x,touch.y)){
            curView = i;
        }
    }
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs & touch){
    int relativeX = touch.x-boardOffset.x;
    int relativeY = touch.y-boardOffset.y;
    
    int brushStrength = 100;    //how much it adds at the center
    
    int maxDist = 5*fieldScale;
    //paint into the array
    int brushSize=maxDist/fieldScale;
    //get the center of the brush
    int xMid=relativeX/fieldScale;
    int yMid=relativeY/fieldScale;
    
    int xStart=MAX(0,xMid-brushSize);
    int xEnd=MIN(fieldW,xMid+brushSize);
    int yStart=MAX(0,yMid-brushSize);
    int yEnd=MIN(fieldH,yMid+brushSize);
    
    //go through and set those pixels to black
    for (int col=xStart; col<xEnd; col++){
        for (int row=yStart; row<yEnd; row++){
            int pos= row*fieldW+col;
            int rgbPos = row*fieldW*3+col*3;
            
            int brushAmount = ofMap(ofDist(relativeX, relativeY, col*fieldScale, row*fieldScale),0, maxDist, brushStrength, 0, true);
            
            if (touch.id == 0){
                if (curBrushColor<3){
                    //add to the selected color, take away from all others
                    for (int i=0; i<3; i++){
                        if (i==curBrushColor)
                            colorPixels[i][pos] = MIN(255, colorPixels[i][pos]+brushAmount);
                        else
                            colorPixels[i][pos] = MAX(0, colorPixels[i][pos]-brushAmount);
                    }
                    blackPixels[pos] = MAX(0, blackPixels[pos]-brushAmount);
                }else if (curBrushColor==3){
                    blackPixels[pos] = MIN(255, blackPixels[pos]+brushAmount);
                    //shrink the colored images
                    for (int i=0; i<3; i++)
                        colorPixels[i][pos] = MAX(0, colorPixels[i][pos]-brushAmount);
                }
            }
            
            //update this pixel on the combined image
            for (int i=0; i<3; i++)
                combinedPixels[rgbPos+i] = MIN(255, colorPixels[i][pos] + blackPixels[pos]);
            
            //temporary eraser
            if (curBrushColor == 4){
                blackPixels[pos] = MAX(0, blackPixels[pos]-brushAmount);
                for (int i=0; i<3; i++)
                    colorPixels[i][pos] = MAX(0, colorPixels[i][pos]-brushAmount);
            }
        }
    }
    
    //set the image
    for (int i=0; i<3; i++)
        colorImgs[i].setFromPixels(colorPixels[i],fieldW, fieldH);
    blackImg.setFromPixels(blackPixels, fieldW, fieldH);
    
    //put all of the images together as one unified and briliant whole
    combinedImg.setFromPixels(combinedPixels, fieldW, fieldH);
    
}
    
//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs & touch){
        
}
    
//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs & touch){
        
}
    
//--------------------------------------------------------------
void testApp::touchCancelled(ofTouchEventArgs & touch){
        
}
    
//--------------------------------------------------------------
void testApp::lostFocus(){
        
}
    
//--------------------------------------------------------------
void testApp::gotFocus(){
        
}
    
//--------------------------------------------------------------
void testApp::gotMemoryWarning(){
        
}
    
//--------------------------------------------------------------
void testApp::deviceOrientationChanged(int newOrientation){
        
}
