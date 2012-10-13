//
//  BombTower.cpp
//  opencvExample
//
//  Created by Andy Wallace on 12/2/11.
//  Copyright (c) 2011 AndyMakes. All rights reserved.
//

#include "BombTower.h"

void BombTower::typeSetup(){
    range=size*4.5 *mobileRangeIncrease;           //large range
    
    rechargeTime=60;         //slow recharge
    bulletAtraction=0.6;    //slow bullet
    bulletDamage=30;        //huge damage
    
    type="green";
    
    bulletCol.setHex(0x188C25);
    //bulletCol.setHex(0xD4D413);
    
    blastRadius=size*6.5 *mobileRangeIncrease;
}

void BombTower::draw(){
    ofFill();
    if (! *showAllInfo){
        //ofSetColor(0, 255, 0,80);
        ofSetColor(0, 255, 0,10);
        //ofSetHexColor(0xD4D413, 100);
        if (playerDead) ofSetColor(100,100,100,70);
        
        ofCircle(pos.x, pos.y, range);
    }
    
}

void BombTower::hitTarget(){
    shooting=false;
    bombHit=true;
    //play the sound
    SM->playSound("bomb");
}
