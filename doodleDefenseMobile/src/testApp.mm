#include "testApp.h"


//--------------------------------------------------------------
void testApp::setup(){	
    cout<<ofGetWidth()<<" X "<<ofGetHeight()<<endl;
	
    //orient landscape
	iPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_RIGHT);
	ofSetFrameRate(30);
    
	ofBackground(127,127,127);
    
    //size of the grid the game is played on
    float sizeIncreaseToBoard = 7;
    fieldW=80;
    fieldH=60;
    boardW=fieldW*sizeIncreaseToBoard;
    boardH=fieldH*sizeIncreaseToBoard;
    
    fieldScale = 10; //this was 7 in the computer verison
    boardScale = fieldScale/sizeIncreaseToBoard; //these things should not be set manualy since they need to be exact
    
    //setup vector field
    VF.setupField(120, 90,fieldW*fieldScale, fieldH*fieldScale);
    
    boardOffset.set(10,120);
    
    //black image
    blackImg.allocate(boardW, boardH);
    blackPixels = new unsigned char [boardW * boardH];
    blackThreshold = 97;
    
    //set up the images
    wallPixels = new unsigned char [fieldW * fieldH];
    wallImage.allocate(fieldW, fieldH);
    
    //r,g,b images WILL PROBABLY NEED TO BE DOUBLE RESOLUTION
    for (int i=0; i<3; i++){
        colorImgs[i].allocate(boardW, boardH);
        colorPixels[i]= new unsigned char [boardW * boardH];
    }
    //combined image
    combinedImg.allocate(boardW, boardH);
    combinedPixels = new unsigned char [boardW * boardH * 3];
    
    //clear them
    for (int i=0; i<boardW*boardH; i++){
        blackPixels[i] = 0;
        colorPixels[0][i] = 0;
        colorPixels[1][i] = 0;
        colorPixels[2][i] = 0;
    }
    for (int i=0; i<boardW*boardH*3; i++){
        combinedPixels[i] = 0;
    }
    
    //set the maze border
    mazeTop=10;
    mazeBottom=fieldH-4;
    mazeLeft=10;
    mazeRight=fieldW-4;
    
    //where the foes start and end
    startX[0]=60/boardScale;
    startY[0]=boardH*boardScale/2+25;
    startX[1]=boardW*boardScale/2+25;
    startY[1]=60/boardScale;
    goalX[0]=boardW*boardScale-10;
    goalY[0]=boardH*boardScale/2+25;
    goalX[1]=boardW*boardScale/2+25;
    goalY[1]=boardH*boardScale-10;
    
    //border
    borderPics[0].loadImage("walls1Entrance.png");
    borderPics[1].loadImage("walls2Entrance.png");
    
    //color selection
    curBrushColor = 3;
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
    
    //foe images
    for (int i=0; i<NUM_FOE_FRAMES; i++){
        normFoePic[0][i].loadImage("foePics/normal/wnormal"+ofToString(i+1)+".png");
        normFoePic[1][i].loadImage("foePics/normal/nfill"+ofToString(i+1)+".png");
        //        fastFoePic[0][i].loadImage("foePics/fast/wfast"+ofToString(i+1)+".png");
        //        fastFoePic[1][i].loadImage("foePics/fast/ffill"+ofToString(i+1)+".png");
        //        heavyFoePic[0][i].loadImage("foePics/heavy/heavy"+ofToString(i+1)+".png");
        //        heavyFoePic[1][i].loadImage("foePics/heavy/hfill"+ofToString(i+1)+".png");
        //        stealthFoePic[0][i].loadImage("foePics/stealth/wstealth"+ofToString(i+1)+".png");
        //        stealthFoePic[1][i].loadImage("foePics/stealth/sfill"+ofToString(i+1)+".png");
        //        immuneRedFoePic[0][i].loadImage("foePics/immune/immune"+ofToString(i+1)+".png");
        //        immuneRedFoePic[1][i].loadImage("foePics/immune/ifill"+ofToString(i+1)+".png");
    }
    
    //explosion and puff images
    explosionPic.loadImage("misc/explosionFill.png");
    
    //load the sounds
    SM.setup();
    SM.loadSound("audio/BOMB.wav", "bomb", 1);
    SM.loadSound("audio/ENEMYEXPLODES.wav", "enemyDeath", 0.6);
    SM.loadSound("audio/ERROR.wav", "error", 1);
    SM.loadSound("audio/FREEZE.wav", "freeze", 0.3);
    SM.loadSound("audio/HIT.wav", "hit", 0.4);
    SM.loadSound("audio/LOSEGAME2.wav", "playerHit", 1);
    SM.loadSound("audio/SHOT.wav", "shoot", 0.6);
    SM.loadSound("audio/TRIUMPH4.wav", "beatWave", 1);
    SM.loadSound("audio/NEWLOSE1.wav", "lose", 1);
    SM.loadSound("audio/STARTGAME.wav", "start", 1);
    
    //fonts
    string fontName="JolenesHand-Regular.ttf";
    infoFontSmall.loadFont(fontName, 40, true, true);
    infoFont.loadFont(fontName, 50, true, true);
    infoFontBig.loadFont(fontName, 75, true, true);
    infoFontHuge.loadFont(fontName, 100, true, true);
    
    showAllInfo = false;
    
    fingerDown = false;
    gameStarted = true;
    
    combinedImg.invert();
    
    reset();
}

//--------------------------------------------------------------
void testApp::loadFromText(){ 
    waves.clear();  //get rid of any waves that may be there
    
    //load in the text file
	ifstream fin;
	fin.open(ofToDataPath("waves.txt").c_str());
	
	while(fin!=NULL) //as long as theres still text to be read  
	{  
		string full; //declare a string for storage  
		getline(fin, full); //get a line from the file, put it in the string 
        
        //if there are not at least 4 characters it is not a command and the line can be skipped
        if (full.length()>3){
            //split the string into the command and value
            string cmd=full.substr(0,3);    //command is the first 3 values
            string val=full.substr(4);  //value is everything after the space
            
            //check commands
            
            //create a new wave at the given level. This must be the first command
            if (cmd=="new"){
                int level= atoi(val.c_str());
                //create a new wave and add it to the vector
                Wave newWave;
                newWave.setup(level);
                waves.push_back(newWave);
            }
            
            //set the time
            if (cmd=="dur"){
                int duration= atoi(val.c_str());
                waves[waves.size()-1].setTime(duration);
            }
            
            //add a number of foes
            if (cmd=="add"){
                //there are two values here, a name and a number seperated by a space
                size_t spacePos=val.find(" ");
                string name=val.substr(0,spacePos);
                string numString=val.substr(spacePos+1);
                int num=atoi(numString.c_str());
                
                waves[waves.size()-1].addFoes(name, num);
            }
            
            //add a message
            if (cmd=="mes"){
                waves[waves.size()-1].setMessage(val);
            }
            
            //set the color for the box
            if (cmd=="col"){
                waves[waves.size()-1].setBoxColor(val);
            }
            
            //randomize the wave
            if (cmd=="ran"){
                waves[waves.size()-1].randomize();
            }
        }
	}
    
    //set the wave info boxes
    waveInfoBoxes.clear();  //get rid of any old ones
    float waveInfoSpacing=80;
    float boxWidth=400;
    float boxHeight=300;
    for (int i=0; i<waves.size(); i++){
        WaveInfoBox newInfoBox;
        
        newInfoBox.setup(i+1, waves[i].message, &waveInfoPics[i%3], &infoFont, &infoFontSmall, waves[i].boxColorID, waveInfoX, waveInfoBottom-i*(boxHeight+waveInfoSpacing), boxWidth, boxHeight);
        newInfoBox.alpha=ofMap( waveInfoBottom-newInfoBox.pos.y, 0, waveInfoDistToFadeOut, 255, 0, true);
        waveInfoBoxes.push_back(newInfoBox);
    }
}

//--------------------------------------------------------------
void testApp::reset(){ 
    
    //    //clear out any foes if there are any
    //    for (int i=foes.size()-1; i>=0; i--)
    //        killFoe(i);
    //    
    //    //set all towers to think the player is alive
    //    for (int i=0; i<towers.size(); i++)
    //        towers[i]->playerDead=false;
    //    
    health=healthStart;
    totalInk=startInk;
    score=0;
    tooMuchInk=false;
    numEntrances=1;
    nextEntrance=0;
    
    fastForward = false;
    
    damageFlashTimer=0;
    //    
    //    //clear any ink coming to the player
    //    inkParticles.clear();
    //    
    //    //set all of the pixels to blank
    //    for (int i=0; i<fieldW*fieldH; i++){
    //        wallPixels[i]=255;
    //    }
    //    
    paused=false;
    noPath=false;
    //    
    //    towerID=0;
    //    
    curWave=-1;
    wavesDone=false;
    loadFromText();
    //    startNextWave();
    //    
    //    //play the sound
    //    if (ofGetFrameNum()>5)  //don't play the sound when the game first turns on
    //        SM.playSound("start");
    
    convertDrawingToGame();
}


//--------------------------------------------------------------
void testApp::update(){
    //TESTING
    waveComplete = false;
    
    //check if there is any reason to pause the game
    if (playerPause || noPath || tooMuchInk  || !gameStarted || waveComplete || fingerDown)
        paused=true;
    else
        paused=false;
    
    int numUpdates=1;
    if (fastForward)    numUpdates=6;
    for (int i=0; i<numUpdates; i++){
        //manage the current wave
        if (curWave>=0 && !wavesDone){
            waves[curWave].update(paused, fastForward);
            if (waves[curWave].readyForNextFoe)
                spawnFoe(waves[curWave].getNextFoe(),waves[curWave].level);
            
            //if this wave is done, and all foes are dead or offscreen, we can start the next wave if the player is still alive
            if (waves[curWave].done && foes.size()==0 && health>0 && !waveComplete)
                endWave();
        }
        
        //update Foes
        bool allFoesHavePath=true;  //assume that all foes can reach the end
        bool addToPunishmentTimer=false;    //assume that none back tracked
        for (int i=foes.size()-1; i>=0; i--){
            foes[i]->update();
            
            if (!foes[i]->pathFound) allFoesHavePath=false;
            
            //if it just backtracked, increase the timer before spawning a punishment stealth foe
            if (foes[i]->justBacktracked){
                foes[i]->justBacktracked=false; //turn off the flag
                addToPunishmentTimer=true;
            }
            
            //remove it if it reached the end
            if (foes[i]->reachedTheEnd){
                takeDamage(foes[i]->damageToPlayer);   //player takes damage
                killFoe(i);
            }
            //remove it if it is dead
            else if (foes[i]->dead){
                //spawn ink particles
                for (int p=0; p<foes[i]->inkVal;p++){
                    particle newInkParticle;
                    newInkParticle.setInitialCondition(foes[i]->p.pos.x,foes[i]->p.pos.y,ofRandom(-5,5),ofRandom(-5,5));
                    //inkParticles.push_back(newInkParticle);
                }
                //kill it
                killFoe(i);
                //play the sound
                //SM.playSound("enemyDeath");
            }
        }
        
        //        //add to the punishment timer if a foe back tracked
        //        if (addToPunishmentTimer)
        //            punishmentFoeTimer++;
        //        
        //        //reduce the timer slightly to account for no back tracking recently
        //        if (punishmentFoeTimer>0 && !paused)
        //            punishmentFoeTimer-=punishmentTimerDecrease;
        //        
        //        //check if it's time to spawn an punishment foe
        //        if (punishmentFoeTimer>=punishmentFoeTime){
        //            punishmentFoeTimer=0;   //reset the timer
        //            //spawn a stealth foe slightly stronger than the current wave level
        //            spawnFoe("stealth", waves[curWave].level+1);
        //        }
        //        
        //        //if the game was paused because a foes didn't have a path, unpause if the way is clear now
        //        //        if (allFoesHavePath && noPath){
        //        //            noPath=false;
        //        //        }
        //        
        //        //update the towers
        //        for (int i=0; i<towers.size(); i++){
        //            towers[i]->update();
        //            
        //            //if this tower is ready to shoot and the player isn't dead, check if there is a foe within range
        //            if (towers[i]->readyToShoot && health>0){
        //                
        //                float closestDist=10000000;
        //                int closestID=-1;
        //                for (int k=0; k<foes.size(); k++){
        //                    float distance=towers[i]->pos.distance(foes[k]->p.pos);
        //                    if ( distance < towers[i]->range +towers[i]->rangePadding && distance<closestDist){
        //                        
        //                        //red can only target foes not immune to red
        //                        if (towers[i]->type=="red" && foes[k]->type!="immune_red"){
        //                            closestDist=distance;
        //                            closestID=k;
        //                        }
        //                        
        //                        //green can shoot goddamn anything
        //                        if (towers[i]->type=="green"){
        //                            closestDist=distance;
        //                            closestID=k;
        //                        }
        //                        
        //                        //freeze tower cannot shoot the foe if it is already frozen
        //                        if (towers[i]->type=="blue" && foes[k]->freezeTimer<=0){
        //                            closestDist=distance;
        //                            closestID=k;
        //                        }
        //                    }
        //                }
        //                
        //                if (closestID!=-1){
        //                    towers[i]->fire(foes[closestID]);
        //                }
        //                
        //            }
        //            
        //            //if this is a bomb tower, check if it just hit
        //            if(towers[i]->bombHit){
        //                towers[i]->bombHit=false;
        //                
        //                //find all of the foes in range of the bullet and damage them
        //                for (int k=0; k<foes.size(); k++){
        //                    if (towers[i]->bullet.pos.distance(foes[k]->p.pos)<towers[i]->blastRadius){
        //                        foes[k]->hp-=towers[i]->bulletDamage;
        //                    }
        //                }
        //                
        //                //add an animation
        //                BombAnimation newBombAnimation;
        //                newBombAnimation.setup(towers[i]->bullet.pos.x,towers[i]->bullet.pos.y,towers[i]->blastRadius);
        //                bombAnimations.push_back(newBombAnimation);
        //            }
        //        }
    }
    
    //    //kil any old bomb animations
    //    for (int i=bombAnimations.size()-1; i>=0; i--){
    //        bombAnimations[i].update();
    //        if (bombAnimations[i].done)
    //            bombAnimations.erase(bombAnimations.begin()+i);
    //    }
    //    
    //    //update ink particles
    //    int inkEndX=-175;
    //    int inkEndY=215;
    //    for (int i=inkParticles.size()-1; i>=0; i--){
    //        //reset the particle
    //        inkParticles[i].resetForce();
    //        //atract the controler to the next node
    //        inkParticles[i].addAttractionForce(inkEndX, inkEndY, 10000, 0.4);
    //        //dampen and update the particle
    //        inkParticles[i].addDampingForce();
    //        inkParticles[i].update();
    //        
    //        //check if it reached the end
    //        if (ofDist(inkParticles[i].pos.x, inkParticles[i].pos.y, inkEndX, inkEndY)<20){
    //            //give the player ink
    //            totalInk++;
    //            //kill the particle
    //            inkParticles.erase(inkParticles.begin()+i);
    //        }
    //    }
    //    
    //update explosions and puffs
    for (int i=explosions.size()-1; i>=0; i--){
        explosions[i].update();
        
        if (explosions[i].killMe)
            explosions.erase(explosions.begin()+i);
    }
    //    
    //    //update the wave info boxes if they need any changing
    //    //fade out the bottom box if the level was just finished
    //    if (waveInfoBoxes.size()>0){
    //        if (waveInfoBoxes[0].fading){
    //            waveInfoBoxes[0].alpha-=waveInfoBoxes[0].fadeSpeed;
    //            //kill it if it is gone
    //            if (waveInfoBoxes[0].alpha<=0){
    //                waveInfoBoxes.erase(waveInfoBoxes.begin());
    //            }
    //        }
    //    }
    //    //if the bottom box is not on the bottom line, move them all down and adjust the alhpa
    //    if (waveInfoBoxes.size()>0){    //make sure there is somehting there
    //        if (waveInfoBoxes[0].pos.y<waveInfoBottom){
    //            for (int i=0; i<waveInfoBoxes.size(); i++){
    //                waveInfoBoxes[i].pos.y+=waveInfoBoxes[i].fallSpeed;
    //                //make sure they don't go below the line
    //                waveInfoBoxes[i].pos.y=MIN(waveInfoBottom, waveInfoBoxes[i].pos.y);
    //                //set the alpha based on the distance to the bottom line
    //                waveInfoBoxes[i].alpha=ofMap( waveInfoBottom-waveInfoBoxes[i].pos.y, 0, waveInfoDistToFadeOut, 255, 0, true);
    //            }
    //        }
    //    }
    //    
	
}

//--------------------------------------------------------------
void testApp::draw(){	
	ofSetColor(255);
    
    if (curView < 3)
        colorImgs[curView].draw(boardOffset.x,boardOffset.y, boardW*boardScale, boardH*boardScale);
    if (curView == 3)
        blackImg.draw(boardOffset.x,boardOffset.y, boardW*boardScale, boardH*boardScale);
    if (curView == 4)
        combinedImg.draw(boardOffset.x,boardOffset.y, boardW*boardScale, boardH*boardScale);
    
    //testing the wall image
    wallImage.draw(boardOffset.x+boardW*boardScale, ofGetHeight()*0.5, fieldW*2, fieldH*2);
    
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
    //dot to show the one we're one
    ofSetColor(100);
    ofCircle(colorButtons[curBrushColor].x+colorButtons[0].width/2, colorButtons[curBrushColor].y+colorButtons[0].height/2, 20);
    
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
    
    //below this from the computer verison:
    
    
    ofEnableAlphaBlending();
    
    ofPushMatrix();
    ofTranslate(boardOffset.x, boardOffset.y);
    //ofScale(projScale, projScale);
    
    //show the border
//    ofSetRectMode(OF_RECTMODE_CORNER);
//    ofSetColor(255);
//    borderPics[numEntrances-1].draw(0,0,boardW*boardScale,boardH*boardScale);
    
    //show the game
    drawGame();
    //drawPlayerInfo();   //show player stats that live outside of the game area
    ofPopMatrix();
    
    ofDisableAlphaBlending();
    //set the rect mode back
    ofSetRectMode(OF_RECTMODE_CORNER);
    
}

//--------------------------------------------------------------
void testApp::drawGame(){
    
    ofSetRectMode(OF_RECTMODE_CENTER);
    if(showAllInfo){
        //go through the images and draw them all out to the screen
        for (int x=0; x<fieldW; x++){
            for (int y=0; y<fieldH; y++){
                int pos=y*fieldW+x;
                if (wallPixels[pos]==0){
                    ofSetColor(0,100,200);
                    ofRect(x*fieldScale, y*fieldScale, fieldScale, fieldScale);
                }
            }
        }
        
        //show the vector field if we're viewing all data
        ofSetColor(0,130,130, 200);
        VF.draw();
    }
    
    //    //show the towers
    //    for (int i=0; i<towers.size(); i++)
    //        towers[i]->draw();
    
    //show the foes
    for (int i=0; i<foes.size(); i++){
        if (showAllInfo)
            foes[i]->drawDebug();
        foes[i]->draw();
    }
    
    //draw the bomb animations if there are any
    //    ofFill();
    //    for (int i=0; i<bombAnimations.size(); i++)
    //        bombAnimations[i].draw();
    
    //draw explosions and puffs
    for (int i=0; i<explosions.size(); i++)
        explosions[i].draw();
    
    //draw ink particles if there are any
    //    ofSetColor(150);
    //    for (int i=0; i<inkParticles.size(); i++)
    //        inkParticles[i].draw();
    
    
}

//--------------------------------------------------------------
void testApp::drawWaveCompleteAnimation(){
    //    //get the amount of time the animation has played
    //    float curTime=ofGetElapsedTimef()-waveAnimationStart;
    //    
    //    int messageX=615;
    //    int messageY=-120;
    //    
    //    ofColor thisCol;
    //    thisCol.setHsb(ofRandom(255), 255, 100);
    //    
    //    ofSetColor(thisCol);
    //    
    //    
    //    if (wavesDone)
    //        banners[3].draw(messageX, messageY);
    //    else {
    //        banners[2].draw(messageX, messageY);
    //    }
    //    
    //    //    if (curWave+1 != waves.size()){
    //    //        banners[2].draw(messageX, messageY);
    //    //    }else{
    //    //        banners[3].draw(messageX, messageY);
    //    //        curTime=0;
    //    //    }
    //    
    //    //if time is up, return to the game
    //    if (curTime>waveAnimationTime){
    //        cout<<"start it I think"<<endl;
    //        startNextWave();
    //    }
}

//--------------------------------------------------------------
void testApp::drawPlayerInfo(){
    
    //    //draw health
    //    ofSetRectMode(OF_RECTMODE_CORNER);
    //    float xCenter=(fieldW*fieldScale)/2+5; //slight offset for the openning on the side
    //    float healthY=870;
    //    float healthWidth=(mazeRight-mazeLeft)*fieldScale;
    //    float xLeft=xCenter-healthWidth/2+healthPicFull[0].width/2;
    //    float healthSpacing= (healthWidth - healthStart*healthPicFull[0].width)/healthStart;
    //    //draw full hearts for the life remaining
    //    ofSetColor(255);
    //    for (int i=0; i<health; i++){
    //        healthPicFull[i].draw(xLeft+i*healthPicFull[0].width+i*healthSpacing,healthY);
    //    }
    //    //end empty life for the life lost
    //    for (int i=health; i<healthStart; i++){
    //        healthPicEmpty[0].draw(xLeft+i*healthPicEmpty[0].width+i*healthSpacing,healthY);
    //    }
    //    
    //    
    //    //written values
    //    int thisTextX;
    //    
    //    //SHOW INK VALUES
    //    ofFill();
    //    ofSetColor(0);
    //    //make it blink if the player is out if ink
    //    if (tooMuchInk && ofGetFrameNum()/4%2==0)   ofSetColor(255,0,0);
    //    int inktextRightX=-150;
    //    int inkTextY=160;
    //    
    //    thisTextX=inktextRightX-infoFont.stringWidth("Ink Left:")/2;
    //    infoFont.drawString("Ink Left:",thisTextX,inkTextY);
    //    inkTextY+=infoFontBig.getLineHeight();
    //    
    //    //thisTextX=inktextRightX-infoFontBig.stringWidth(ofToString((int)(totalInk-inkUsed))+"/"+ofToString((int)totalInk));
    //    thisTextX=inktextRightX-infoFontBig.stringWidth(ofToString((int)(totalInk-inkUsed)))/2;
    //    infoFontBig.drawString(ofToString((int)(totalInk-inkUsed)),thisTextX,inkTextY);
    //    inkTextY+=infoFontBig.getLineHeight();
    //    
    //    
    //    //draw the wave info boxes
    //    ofSetRectMode(OF_RECTMODE_CENTER);
    //    for (int i=0; i<waveInfoBoxes.size(); i++){
    //        waveInfoBoxes[i].draw();
    //    }
    //    
    //    //BANNERS
    //    //let the player no if there is no path
    //    ofFill();
    //    int messageX=615;
    //    int messageY=-120;
    //    ofSetColor(0,0,0);
    //    if (noPath){
    //        banners[0].draw(messageX, messageY);
    //    }
    //    //let the player know if they used too much ink
    //    if (tooMuchInk){
    //        banners[1].draw(messageX, messageY);
    //    }
    //    //let the player know if they are dead
    //    if (health<=0){
    //        ofSetColor(255,0,0);
    //        if (ofGetFrameNum()/4%2==0) ofSetColor(0);
    //        banners[4].draw(messageX, messageY);
    //    }
    //    
    //    //check if we should be showing the wave complete animation
    //    if (waveComplete)
    //        drawWaveCompleteAnimation();
    //    
    //    //draw red over the game if the player was just hit
    //    if (damageFlashTimer-- >0){
    //        ofSetRectMode(OF_RECTMODE_CORNER);
    //        ofSetColor(255, ofMap(damageFlashTimer, 0, damageFlashTime, 0, 255));
    //        playerHitPic.draw(75,80);
    //    }
    
}

//--------------------------------------------------------------
void testApp::exit(){
    
}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs & touch){
    
    if (touch.id == 0){
        fingerDown = true;
        
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
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs & touch){
    if (touch.id == 0){
        int relativeX = touch.x-boardOffset.x;
        int relativeY = touch.y-boardOffset.y;
        
        int brushStrength = 100;    //how much it adds at the center
        
        int maxDist = 15*boardScale;
        if (curBrushColor == 4) maxDist*=3; //make the eraser bigger
        //paint into the array
        int brushSize=maxDist/boardScale;
        //get the center of the brush
        int xMid=relativeX/boardScale;
        int yMid=relativeY/boardScale;
        
        int xStart=MAX(0,xMid-brushSize);
        int xEnd=MIN(boardW,xMid+brushSize);
        int yStart=MAX(0,yMid-brushSize);
        int yEnd=MIN(boardH,yMid+brushSize);
        
        //go through and set the pixels being effected by the brush
        for (int col=xStart; col<xEnd; col++){
            for (int row=yStart; row<yEnd; row++){
                int pos= row*boardW+col;
                int rgbPos = row*boardW*3+col*3;
                
                int brushAmount = ofMap(ofDist(relativeX, relativeY, col*boardScale, row*boardScale),0, maxDist, brushStrength, 0, true);
                
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
                for (int i=0; i<3; i++){
                    combinedPixels[rgbPos+i] = MIN(255, colorPixels[i][pos] + blackPixels[pos]);                                                   
                }
                
                //temporary eraser
                if (curBrushColor == 4){
                    blackPixels[pos] = MAX(0, blackPixels[pos]-brushAmount);
                    for (int i=0; i<3; i++)
                        colorPixels[i][pos] = MAX(0, colorPixels[i][pos]-brushAmount);
                }
                
                //since something changed, flag that we need to alter the game
                needToConvertDrawingToGame = true;
            }
        }
        
        //set the image
        for (int i=0; i<3; i++)
            colorImgs[i].setFromPixels(colorPixels[i],boardW, boardH);
        blackImg.setFromPixels(blackPixels, boardW, boardH);
        
        //put all of the images together as one unified and briliant whole
        combinedImg.setFromPixels(combinedPixels, boardW, boardH);
        combinedImg.invert();
    }
    
}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs & touch){
    if (touch.id == 0){
        if (needToConvertDrawingToGame){
            convertDrawingToGame();
        }else{
            cout<<"fuck your sad ass"<<endl;
        }
        fingerDown = false;
    }
}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs & touch){
    if (touch.x<60 && touch.y>ofGetHeight()-60)
        showAllInfo = !showAllInfo;
    
    else
        spawnFoe("norm", 1);
    
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

//--------------------------------------------------------------
void testApp::convertDrawingToGame(){ 
    needToConvertDrawingToGame = false; //turn the flag off
    
    //get the walls
    wallImage.scaleIntoMe(blackImg);
    //wallImage=blackImg;
    wallImage.threshold(blackThreshold,false);
    wallImage.invert();
    wallPixels=wallImage.getPixels();
    //thickenWallImage(); //maybe don't need to do this
    setMazeBorders();
    
    //pathfinding for the foes
    if (foes.size()>0){
        for (int i=foes.size()-1; i>=0; i--){
            //it would be way better to check each foe's current locaiton against the path made by tempFoe, but it just isn't fucking working.
            foes[i]->findPath();
            
            //pause the game if this foe can't reach the end
            if (!foes[i]->pathFound){
                noPath=true;
                SM.playSound("error");  //play the sound
                cout<<"NO PATH. GET OUT"<<endl;
                return;
            }
            //you could also, create a temp foe at the end, and check to see if it can make it to the start
            
        }
    }
    
    //if we got this far, there is a path
    noPath=false;
    
    VF.clear();
    //add some repulsion from each wall
    for (int i=0; i<fieldW*fieldH; i++){
        if (wallPixels[i]==0){
            int wallX=i%fieldW;
            int wallY=floor(i/fieldW);
            
            VF.addOutwardCircle(wallX*fieldScale, wallY*fieldScale, 20, 0.3);
        }
    }
    //    
    //    //look for blobs to turn into towers
    //    //set all towers as unfound. If they are not found when checking the blobs, they will be rmeoved
    //    for (int i=0; i<towers.size(); i++){
    //        towers[i]->found=false;
    //    }
    //    
    //    //red
    //    int minArea=20;
    //    int maxArea=(fieldW*fieldH)/2;
    //    int maxNumberOfBlobs=25;
    //    
    //    //expand the pixels in the images 
    //    for (int i=0; i<3; i++)
    //        colorImgs[i].dilate_3x3();    
    //    
    //    contourFinder.findContours(colorImgs[0], minArea, maxArea, maxNumberOfBlobs, false);
    //    checkTowers("red");
    //    //green
    //    contourFinder.findContours(colorImgs[1], minArea, maxArea, maxNumberOfBlobs, false);
    //    checkTowers("green");
    //    //blue
    //    contourFinder.findContours(colorImgs[2], minArea, maxArea, maxNumberOfBlobs, false);
    //    checkTowers("blue");
    //    
    //    //find any towers that were not found in the last sweep and kill them
    //    for (int i=towers.size()-1; i>=0; i--){
    //        if (!towers[i]->found){
    //            delete towers[i];
    //            towers.erase(towers.begin()+i);
    //        }
    //    }
    //    
    //    //in case the markers fucked with the IR reading, save a new background
    //    saveChangeBackground=true;
    //    
    //    //save these images to the display array for debug purposes
    //    for (int i=0; i<3; i++)
    //        colorImgsDisplay[i]=colorImgs[i];
    //    
    //    
    //    //check how much ink has been used
    //    inkUsed= 0;  
    //    //check black pixels
    //    for (int i=0; i<fieldW*fieldH; i++){
    //        if (wallPixels[i]==0) inkUsed+=blackInkValue;
    //    }
    //    //check towers
    //    for (int i=0; i<towers.size(); i++){
    //        if (towers[i]->type=="red") inkUsed+=rInkValue*towers[i]->size;
    //        if (towers[i]->type=="green") inkUsed+=gInkValue*towers[i]->size;
    //        if (towers[i]->type=="blue") inkUsed+=bInkValue*towers[i]->size;
    //    }
    //    //let calibration know how much was used
    //    calibration.inkUsedBeforeRefund=inkUsed;
    //    //factor in the refund
    //    inkUsed-=inkRefund;
    //    //make sure ink used is not negative
    //    inkUsed=MAX(0,inkUsed);
    //    //check if they used more ink than they have
    //    if (inkUsed>totalInk){
    //        tooMuchInk=true;
    //        SM.playSound("error");  //play the sound
    //    }else if (tooMuchInk){  //if they just fixed using too much ink, unpause the game
    //        tooMuchInk=false;
    //    }
    //    
    //    //if there is nothing wrong, the game is ready to continue
    //    //but we should check to see if any towers from the last safe game state were removed
    //    if (!tooMuchInk && !noPath){
    //        cout<<"ITS GOOD"<<endl;
    //        
    //        //check the current wall image against the last one to see if any big chunks of wall were erased
    //        vector <int> wallEraseLocations;
    //        wallDiffImage.absDiff(lastSafeWallImage, wallImage);
    //        wallDiffImage.erode_3x3();  //try to remove some noise by expanding the black parts of the image
    //        unsigned char * wallDiffPixels=wallDiffImage.getPixels();
    //        //go thorugh and see how many pixels that had been black are now white
    //        int totalDiff=0;
    //        //int spawnParticleFrequency= (1/blackInkValue)*wallRefund;
    //        for (int i=0; i<fieldW*fieldH; i++){
    //            if (wallDiffPixels[i]>128 && wallPixels[i]==255){
    //                totalDiff++;
    //                //spawn an ink particle every so often based on the number of pixels checked so far if the game has started
    //                if (gameStarted){
    //                    particle newInkParticle;
    //                    int xPos= (i%fieldW)*fieldScale;
    //                    int yPos= ( floor(i/fieldW) )*fieldScale;
    //                    newInkParticle.setInitialCondition( xPos, yPos , ofRandom(-5,5),ofRandom(-5,5));
    //                    inkParticles.push_back(newInkParticle);
    //                }
    //            }
    //        }
    //        //remove from their total ink based on the total
    //        if (gameStarted)
    //            totalInk-= totalDiff/wallRefund;
    //        cout<<"total wall difference: "<<totalDiff<<endl;
    //        cout<<"took Away: "<<totalDiff/wallRefund<<endl;
    //        
    //        
    //        
    //        //go through the tower data from the last safe state and see if antyhing is missing
    //        for (int i=0; i<lastSafeTowerSet.size(); i++){
    //            bool found=false;   //assume the tower will not be found
    //            
    //            //checking each tower might be a super innificient way of doing this
    //            for (int k=0; k<towers.size(); k++){
    //                if ( lastSafeTowerSet[i].pos.distance(towers[k]->pos)<lastSafeTowerSet[i].size && lastSafeTowerSet[i].type==towers[k]->type){
    //                    found=true;
    //                    break;
    //                }
    //            }
    //            
    //            if (!found){
    //                cout<<"you erased the tower at "<<lastSafeTowerSet[i].pos.x<<" , "<<lastSafeTowerSet[i].pos.y<<endl;
    //                
    //                //figure out how much ink that tower was worth
    //                float inkValue;
    //                if (lastSafeTowerSet[i].type=="red") inkValue=rInkValue*lastSafeTowerSet[i].size;
    //                if (lastSafeTowerSet[i].type=="green") inkValue=gInkValue*lastSafeTowerSet[i].size;
    //                if (lastSafeTowerSet[i].type=="blue") inkValue=bInkValue*lastSafeTowerSet[i].size;
    //                
    //                //remove that ink from the player's reserve if the game has been started
    //                if (gameStarted){
    //                    totalInk-=inkValue;
    //                    //and spawn ink particles equal to the refund they should get
    //                    for (int r=0; r<inkValue*towerRefund; r++){
    //                        particle newInkParticle;
    //                        newInkParticle.setInitialCondition(lastSafeTowerSet[i].pos.x,lastSafeTowerSet[i].pos.y,ofRandom(-5,5),ofRandom(-5,5));
    //                        inkParticles.push_back(newInkParticle);
    //                    }
    //                }
    //                
    //            }
    //            
    //            
    //        }
    //        
    //        //save the current wall image
    //        lastSafeWallImage=wallImage;
    //        
    //        //save all of the current tower info to be checked next time
    //        lastSafeTowerSet.clear();
    //        for (int i=0; i<towers.size(); i++){
    //            TowerInfo newInfo;
    //            newInfo.pos=towers[i]->pos;
    //            newInfo.size=towers[i]->size;
    //            newInfo.type=towers[i]->type;
    //            lastSafeTowerSet.push_back(newInfo);
    //        }
    //    }
    //    else{
    //        cout<<"NO GOOD BAD BAD"<<endl;
    //        if (tooMuchInk)    cout<<"TOO MUCH INK"<<endl;
    //        if (noPath)        cout<<"NO PATH"<<endl;
    //    }
    
}

//--------------------------------------------------------------
//takes the pixels in the wall image and adds a black pixel next to each black pixel
void testApp::thickenWallImage(){
    
    vector<int> pixelsToAdd;
    
    //starting at 1 and ghoing to length-2 so that there is a slight buffer on the edges
    for (int x=1; x<fieldW-2; x++){
        for (int y=1; y<fieldH-2; y++){
            int pos=x*fieldW+y;
            if (wallPixels[pos]==0){
                int top=x*fieldW+(y-1);
                int bottom=x*fieldW+(y+1);
                int left=(x-1)*fieldW+y;
                int right=(x+1)*fieldW+y;
                
                if (wallPixels[top]==255)   pixelsToAdd.push_back(top);
                if (wallPixels[bottom]==255)   pixelsToAdd.push_back(bottom);
                if (wallPixels[left]==255)   pixelsToAdd.push_back(left);
                if (wallPixels[right]==255)   pixelsToAdd.push_back(right);
            }
        }
    }
    
    //actualy darken those pixels
    for (int i=0; i<pixelsToAdd.size(); i++)
        wallPixels[pixelsToAdd[i]]=0;
    
}

//--------------------------------------------------------------
//draws the borders of the maze into the wall pixels
void testApp::setMazeBorders(){
    //ignore anything drawn outside of the maze by painting it white
    for (int x=0; x<fieldW; x++){
        for (int y=0; y<fieldH; y++){
            if ( x<mazeLeft || x>mazeRight || y<mazeTop || y>mazeBottom){
                int pos=y*fieldW+x;
                wallPixels[pos]=255;
            }
        }
    }
    
    //keep the hole empty
    int hole=mazeLeft+ (mazeRight-mazeLeft)/2;
    //top and bottom walls
    for (int i=mazeLeft; i<=mazeRight; i++){
        if(i<hole-5 || i>hole+5){
            int topPos=mazeTop*fieldW+i;
            int bottomPos=mazeBottom*fieldW+i;
            wallPixels[topPos]=0;
            wallPixels[bottomPos]=0;
        }
    }
    
    // top entrance way
    for (int i=0; i<mazeTop; i++){
        int leftPos=i*fieldW+(hole-5);
        int rightPos=i*fieldW+(hole+5);
        wallPixels[leftPos]=0;
        wallPixels[rightPos]=0;
    }
    
    //bottom exit
    for (int i=mazeBottom; i<fieldH; i++){
        int leftPos=i*fieldW+(hole-5);
        int rightPos=i*fieldW+(hole+5);
        wallPixels[leftPos]=0;
        wallPixels[rightPos]=0;
    }
    
    
    //left and right walls with opennings in the middle
    int center=mazeTop+ (mazeBottom-mazeTop)/2;
    for (int i=mazeTop; i<=mazeBottom; i++){
        if (i<center-5 || i>center+5){
            int leftPos=i*fieldW+mazeLeft;
            int rightPos=i*fieldW+mazeRight;
            wallPixels[leftPos]=0;
            wallPixels[rightPos]=0;
        }
    }
    
    //left entrance way
    for (int i=0; i<mazeLeft; i++){
        int topPos=(center-5)*fieldW+i;
        int bottomPos=(center+5)*fieldW+i;
        wallPixels[topPos]=0;
        wallPixels[bottomPos]=0;
    }
    
    //right exit
    for (int i=mazeRight; i<fieldW; i++){
        int topPos=(center-5)*fieldW+i;
        int bottomPos=(center+5)*fieldW+i;
        wallPixels[topPos]=0;
        wallPixels[bottomPos]=0;
    }
    
}

//--------------------------------------------------------------
void testApp::endWave(){
    waveComplete=true;
    waveAnimationStart=ofGetElapsedTimef();
    
    //remove the box for this wave. Checking all boxes just in case somehting weird hapenned
    for (int i=0; i<waveInfoBoxes.size(); i++){
        if (waveInfoBoxes[i].waveNum== curWave+1)
            waveInfoBoxes[i].fading=true;
    }
    
    //play the sound
    SM.playSound("beatWave");
}

//--------------------------------------------------------------
void testApp::spawnFoe(string name, int level){ 
    //    if (name=="fast"){
    //        FastFoe * newFoe=new FastFoe;
    //        newFoe->setPics(fastFoePic[0], fastFoePic[1]);
    //        foes.push_back(newFoe);
    //    }
    //    else if (name=="stealth"){
    //        StealthFoe * newFoe=new StealthFoe;
    //        newFoe->setPics(stealthFoePic[0], stealthFoePic[1]);
    //        foes.push_back(newFoe);
    //    }
    //    else if (name=="immune_red"){
    //        ImmuneRedFoe * newFoe=new ImmuneRedFoe;
    //        newFoe->setPics(immuneRedFoePic[0], immuneRedFoePic[1]);
    //        foes.push_back(newFoe);
    //    }
    //    else if (name=="heavy"){
    //        HeavyFoe * newFoe=new HeavyFoe;
    //        newFoe->setPics(heavyFoePic[0], heavyFoePic[1]);
    //        foes.push_back(newFoe);
    //    }
    //    else {  //assume anything that didn't ahve one of the above names is a normal foe
    NormFoe * newFoe=new NormFoe;
    newFoe->setPics(normFoePic[0], normFoePic[1]);
    //add it to the vector
    foes.push_back(newFoe);
    //    }
    
    //give the foe all of the info it needs
    int entrance=nextEntrance;
    if (++nextEntrance >= numEntrances) nextEntrance=0;
    foes[foes.size()-1]->setup(&VF, startX[entrance], startY[entrance], goalX[entrance], goalY[entrance], fieldScale, fieldW, fieldH,level);
    foes[foes.size()-1]->wallPixels=wallPixels;
    foes[foes.size()-1]->showAllInfo=&showAllInfo;
    foes[foes.size()-1]->paused=&paused;
    foes[foes.size()-1]->findPath();
    
    //if there is no path for this guy, pause the game
    if (!foes[foes.size()-1]->pathFound){
        noPath=true;
    }
}

//--------------------------------------------------------------
void testApp::killFoe(int num){
    //spawn an explosion
    Explosion newExplosion;
    newExplosion.setup(foes[num]->p.pos, &explosionPic);
    explosions.push_back(newExplosion);
    
    //    //go through and find any towers targetting this foe and remove the target
    //    for (int i=0; i<towers.size(); i++){
    //        if (towers[i]->target==foes[num]){
    //            towers[i]->target=NULL;
    //        }
    //    }
    
    delete foes[num]; //dealocate the meory
    foes.erase(foes.begin()+num);
}

//--------------------------------------------------------------
void testApp::takeDamage(int damage){
    //show red for a second if the player is still in the game
    if (health>0)   damageFlashTimer=damageFlashTime; 
    
    health-=damage;
    //health=MAX(0,health); //IT'S OK IF THE HEALTH GOES BELOW 0
    
    //check if the player is dead
    if (health==0){
        //        //gray out all towers
        //        for (int i=0; i<towers.size(); i++)
        //            towers[i]->playerDead=true;
        //play the lose game sound
        SM.playSound("lose");
    }
    
    //play the sound
    SM.playSound("playerHit");
}

