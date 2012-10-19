//
//  HitTower.cpp
//  opencvExample
//
//  Created by Andy Wallace on 12/1/11.
//  Copyright (c) 2011 AndyMakes. All rights reserved.
//

#include"HitTower.h"

void HitTower::typeSetup(){
    range=size*3.5 *mobileRangeIncrease;           //moderate range
    
    rechargeTime=15;         //fast recharge (always going up even when firing
    bulletAtraction=1;//0.5;    //fast bullet
    bulletDamage=size*0.9;//0.85;        //moderate damage based on tower size
    
    bulletCol.setHex(0xCF1515);
    
    //cout<<"size: "<< size<<endl;
    //cout<<"bullet damage: "<<bulletDamage<<endl;
    type="red";
}

void HitTower::draw(){
    ofFill();
    if (! *showAllInfo){
        //ofSetColor(255, 0, 0,80);
        ofSetColor(255, 0, 0,40);
        if (playerDead) ofSetColor(100,100,100,70);
        
        ofCircle(pos.x, pos.y, range);
    }
    
}

void HitTower::hitTarget(){
    shooting=false;
    //the effects that happen to the foe when they get hit
    target->hp-=bulletDamage;
    //play the sound
    SM->playSound("hit"); 
}