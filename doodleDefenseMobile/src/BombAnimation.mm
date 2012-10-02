//
//  BombAnimation.cpp
//  ofxKinectExample
//
//  Created by Andy Wallace on 12/15/11.
//  Copyright (c) 2011 AndyMakes. All rights reserved.
//

#include"BombAnimation.h"


void BombAnimation::setup(float _x, float _y, float _size){
    x=_x;
    y=_y;
    size=_size;
    
    timer=0;
    done=false;
    endTime=10;
}

void BombAnimation::update(){
    timer++;
    if (timer>=endTime)   done=true;
}

void BombAnimation::draw(){
    
    int sections=3;

    for (int i=0; i<sections; i++){
        ofSetColor(ofMap(i,0,sections,150,255), ofMap(i,0,sections,150,255), 0, 100);
        
        
        float thisSize=ofMap(timer,0,endTime,size,1)/i;
        ofCircle(x, y, thisSize);
    }
}