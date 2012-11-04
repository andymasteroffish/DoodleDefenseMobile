#include "testApp.h"

bool publicRelease = true;

//--------------------------------------------------------------
void testApp::setup(){	
    
    //orient landscape
	iPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_LEFT);
	ofSetFrameRate(30);
    
    //check for retina
    retina = false;
    if (ofGetWidth()>=2000)   retina = true;
    
    //set file names
    string picNameEnd = retina ? "Retina.png" : ".png";
    
	ofBackground(255,255,255);
    
    setBackerNames();
    
    cout<<ofGetWidth()<<" X "<<ofGetHeight()<<endl;
    
    //size of the grid the game is played on
    float sizeIncreaseToBoard = 7;
    fieldW=FIELD_W;
    fieldH=FIELD_H;
    boardW=fieldW*sizeIncreaseToBoard;
    boardH=fieldH*sizeIncreaseToBoard;
    
    cout<<"board size: "<<boardW<<" X "<<boardH<<endl;
    
    fieldScale = 10*(retina+1); //this was 7 in the computer verison
    boardScale = fieldScale/sizeIncreaseToBoard;
    
    boardOffset.set(ofGetWidth()*0.04,ofGetHeight()*0.09);  //*0.15);
    
    //black image
    blackImg.allocate(boardW, boardH);
    blackPixels = new unsigned char [boardW * boardH];
    
    //set up the images
    wallPixels = new unsigned char [fieldW * fieldH];
    wallImage.allocate(fieldW, fieldH);
    
    //r,g,b images
    for (int i=0; i<3; i++){
        colorImgs[i].allocate(boardW, boardH);
        colorPixels[i]= new unsigned char [boardW * boardH];
    }
    
    //set the colors to display each image
    dispColor[0].set(255,0,0);
    dispColor[1].set(0,255,0);
    dispColor[2].set(0,0,255);
    
    //threhsolding info
    blackThreshold = 40;
    colorThreshold = 200;

    //display images to actually show the user
    wallDispTex.allocate(boardW, boardH, GL_LUMINANCE_ALPHA);
    wallDispPixels = new unsigned char [boardW * boardH * 2];
    for (int i=0; i<3; i++){
        colorDispTex[i].allocate(boardW, boardH, GL_LUMINANCE_ALPHA);
        colorDispPixels[i] = new unsigned char [boardW * boardH * 2];
    }
    
    //load in the paper texture and set the greycscale part of the pictures
    ofImage paperPic;
    paperPic.loadImage("paper/paperTexture.jpg");   //load the same image even for retina
    paperPic.setImageType(OF_IMAGE_GRAYSCALE);
    
    
    unsigned char *	paperPixels = paperPic.getPixels();
    
    for (int i=0; i<boardW * boardH * 2; i+=2){
        wallDispPixels[i]   = 255-paperPixels[i/2];
        //wallDispPixels[i+1] = 0;
        for (int k=0; k<3; k++){
            colorDispPixels[k][i]   = paperPixels[i/2];
            //colorDispPixels[k][i+1] = 0;
        }
    }
    
    
    //set the maze border
    mazeTop=4;
    mazeBottom=fieldH-4;
    mazeLeft=4;
    mazeRight=fieldW-4;
    
    //where the foes start and end
    startX[0]=boardW*boardScale*0.01;
    startY[0]=boardH*boardScale*0.5;
    goalX[0]=boardW*boardScale*0.99;
    goalY[0]=boardH*boardScale*0.5;
    
    startX[1]=boardW*boardScale*0.5;
    startY[1]=boardH*boardScale*0.02;
    goalX[1]=boardW*boardScale*0.5;
    goalY[1]=boardH*boardScale*0.98;
    
    //border
    borderPics[0].loadImage("walls1Entrance.png");
    borderPics[1].loadImage("walls2Entrance.png");
    
    //for calculating what counts as a tower
    maxCompactness = 1.8;
    
    //color selection
    curBrushColor = 3;
    colorButtonPics[0].loadImage("buttons/game/hitTower"+picNameEnd);
    colorButtonPics[1].loadImage("buttons/game/bombTower"+picNameEnd);
    colorButtonPics[2].loadImage("buttons/game/freezeTower"+picNameEnd);
    colorButtonPics[3].loadImage("buttons/game/wall"+picNameEnd);
    colorButtonPics[4].loadImage("buttons/game/eraser"+picNameEnd);
    int buttonW=colorButtonPics[0].width;
    int buttonH=colorButtonPics[0].height;
    for (int i=0; i<5; i++){
        
        //move everything over so that the color buttons are on the right
        int num = (i+2)%5;
        
        //switch the location of eraser and wall
        if (num == 0)   num = 1;
        else if (num == 1)  num = 0;
        
        int xPos = ofGetWidth()*0.2+num*(buttonW+10);
        if (num<2)    xPos-=ofGetWidth()*0.025;
        if (num>=2)    xPos+=ofGetWidth()*0.05;
        colorButtons[i].set(xPos,boardOffset.y +boardH*boardScale - ofGetHeight()*0.02, buttonW, buttonH);
    }
    
    //bullet image
    bulletPic.loadImage("bullets/bullet"+picNameEnd);
    
    //game buttons
    fastForwardButtonPic.loadImage("buttons/game/fastForwardButton"+picNameEnd);
    pauseButtonPic.loadImage("buttons/game/pauseButton"+picNameEnd);
    int gameButtonX = ofGetWidth()*0.85;
    fastForwardButton.set(gameButtonX, ofGetHeight()*0.15, fastForwardButtonPic.width, fastForwardButtonPic.height);
    pauseButton.set(gameButtonX, ofGetHeight()*0.30, pauseButtonPic.width, pauseButtonPic.height);

    
    
    //pause screen buttons
    pauseScreenButtonPics[0].loadImage("buttons/pauseScreen/play"+picNameEnd);
    pauseScreenButtonPics[1].loadImage("buttons/pauseScreen/howToPlay"+picNameEnd);
    pauseScreenButtonPics[2].loadImage("buttons/pauseScreen/credits"+picNameEnd);
    pauseScreenButtonPics[3].loadImage("buttons/pauseScreen/quit"+picNameEnd);
    float pauseButtonStartY = ofGetHeight()*0.36;
    float pauseButtonEndY = ofGetHeight()*0.85;
    for (int i=0; i<4; i++){
        pauseScreenButtons[i].set(ofGetWidth()/2-pauseScreenButtonPics[i].width/2, (int)ofMap(i,0,3,pauseButtonStartY,pauseButtonEndY), pauseScreenButtonPics[i].width, pauseScreenButtonPics[i].height);
    }
    //about to quit warning
    aboutToQuit=false;
    yesNoButtonPics[0].loadImage("buttons/pauseScreen/no"+picNameEnd);
    yesNoButtonPics[1].loadImage("buttons/pauseScreen/yes"+picNameEnd);
    yesNoButtons[0].set(0,0, yesNoButtonPics[0].width, yesNoButtonPics[0].height);
    yesNoButtons[1].set(0,0, yesNoButtonPics[1].width, yesNoButtonPics[1].height);
    quitWarningPic.loadImage("buttons/pauseScreen/quitWarning"+picNameEnd);
	
	//testing different views
    for (int i=0; i<5; i++){
        viewButtons[i].set(ofGetWidth()-buttonW,i*(buttonH/2+10), buttonW, buttonH/2);
    }
    curView = 4;
    
    //player values
    healthStart=15;
    startInk=450;
    
    waveAnimationTime=5;    //flash for x seconds when a wave is finished
    
    //getting ink back when towers and walls are erased
    towerRefund=0.85;    //what percentage of the tower's value a player gets back when they kill one
    wallRefund=0.85;
    
    
    //foe images
    string foePicFolder = "foePics/";
    if (retina) foePicFolder+="retina/";
    for (int i=0; i<NUM_FOE_FRAMES; i++){
        normFoePic[0][i].loadImage(foePicFolder+"normal/wnormal"+ofToString(i+1)+".png");
        normFoePic[1][i].loadImage(foePicFolder+"normal/nfill"+ofToString(i+1)+".png");
        fastFoePic[0][i].loadImage(foePicFolder+"fast/wfast"+ofToString(i+1)+".png");
        fastFoePic[1][i].loadImage(foePicFolder+"fast/ffill"+ofToString(i+1)+".png");
        heavyFoePic[0][i].loadImage(foePicFolder+"heavy/heavy"+ofToString(i+1)+".png");
        heavyFoePic[1][i].loadImage(foePicFolder+"heavy/hfill"+ofToString(i+1)+".png");
        stealthFoePic[0][i].loadImage(foePicFolder+"stealth/wstealth"+ofToString(i+1)+".png");
        stealthFoePic[1][i].loadImage(foePicFolder+"stealth/sfill"+ofToString(i+1)+".png");
        ImmuneFoePic[0][i].loadImage(foePicFolder+"immune/immune"+ofToString(i+1)+".png");
        ImmuneFoePic[1][i].loadImage(foePicFolder+"immune/ifill"+ofToString(i+1)+".png");
    }
    
    //other images for foes
    explosionPic.loadImage("misc/explosionFill"+picNameEnd);
    foeExclamationPic.loadImage("misc/exclamation"+picNameEnd);
    
    //ink particle pic
    inkParticlePic.loadImage("misc/inkParticle"+picNameEnd);
    
    //banners
    banners[0].loadImage("banners/nopath"+picNameEnd);
    banners[1].loadImage("banners/outofink"+picNameEnd);
    banners[2].loadImage("banners/wave"+picNameEnd);
    banners[3].loadImage("banners/youwin"+picNameEnd);
    banners[4].loadImage("banners/youlose"+picNameEnd);
    banners[5].loadImage("banners/paused"+picNameEnd);
    banners[6].loadImage("banners/credits"+picNameEnd);
    bannerBacks[0].loadImage("banners/nopathBack"+picNameEnd);
    bannerBacks[1].loadImage("banners/outofinkBack"+picNameEnd);
    bannerBacks[2].loadImage("banners/waveBack"+picNameEnd);
    bannerBacks[3].loadImage("banners/youwinBack"+picNameEnd);
    bannerBacks[4].loadImage("banners/youloseBack"+picNameEnd);
    bannerBacks[5].loadImage("banners/pausedBack"+picNameEnd);
    bannerBacks[6].loadImage("banners/creditsBack"+picNameEnd);
    
    //background
    backgroundPic.loadImage("paper/paperBacking.jpg");  //load the same image even for retina
    
    //showing when player is out of ink
    outOfInkBannerTime = 1.5;
    
    //getting hit
    damageFlashTime=8;
    playerHitPic.loadImage("banners/playerHit"+picNameEnd);
    
    //player info pics
    for(int i=0; i<healthStart; i++){
        healthPicFull[i].loadImage("playerInfo/hearts/filled_hearts-"+ofToString(i+1)+picNameEnd);
        healthPicEmpty[i].loadImage("playerInfo/hearts/outlinehearts-"+ofToString(i+1)+picNameEnd);
    }
    
    //displaying the wave info
    waveInfoBottom=ofGetHeight()*0.90;
    waveInfoDistToFadeOut=ofGetHeight()*0.27;
    //box images
    for (int i=0; i<NUM_WAVE_INFO_BOX_PICS; i++)
        waveInfoPics[i].loadImage("waveInfoBoxes/boxes-"+ofToString(i+1)+picNameEnd);
    
    //load the sounds
    SM.setup();
    
    //fonts
    string fontName="JolenesHand-Regular.ttf";
    infoFontSmall.loadFont(fontName, 20*(retina+1), true, true);
    infoFont.loadFont(fontName, 25*(retina+1), true, true);
    infoFontBig.loadFont(fontName, 37*(retina+1), true, true);
    infoFontHuge.loadFont(fontName, 50*(retina+1), true, true);
    
    //game over screen
    gameOverButtonPic.loadImage("buttons/gameOver/menu"+picNameEnd);
    gameOverButton.set(0, 0, gameOverButtonPic.width, gameOverButtonPic.height);    //location set in drawEndGame
    
    //menu
    titlePic.loadImage("menu/title"+picNameEnd);
    menuButtonPics[0]=pauseScreenButtonPics[0];
    menuButtonPics[1]=pauseScreenButtonPics[1];
    menuButtonPics[2]=pauseScreenButtonPics[2];
    menuButtonPics[3].loadImage("buttons/menu/playHard"+picNameEnd);
    menuButtonPics[4].loadImage("buttons/menu/playNormal"+picNameEnd);
    float menuButtonsStartY = ofGetHeight()*0.55;
    float menuButtonsEndY = ofGetHeight()*0.85;
    for (int i=0; i<NUM_MENU_BUTONS; i++){
        menuButtons[i].set(ofGetWidth()/2-menuButtonPics[i].width/2, (int)ofMap(i,0,2,menuButtonsStartY,menuButtonsEndY), menuButtonPics[i].width, menuButtonPics[i].height);
        //buttons 3 and 4, will be moved in drawMenu if it available to the player
    }
    
    //how To
    forceHowTo = true;  //assume this is the first run and they need to see the how to slides. This will ussualy be turned off in loadData()
    for (int i=0; i<NUM_HOW_TO_SLIDES; i++){
        howToSlides[i].loadImage("howTo/howTo"+ofToString(i)+".png");   //load the same image even for retina
    }
    //set up the next button
    nextButtonPic[0].loadImage("buttons/howTo/nextButton"+picNameEnd);
    nextButtonPic[1].loadImage("buttons/howTo/doneButton"+picNameEnd);
    nextButton.set(ofGetWidth()*0.64,ofGetHeight()*0.67,nextButtonPic[0].width, nextButtonPic[0].height);

    //credits
    creditsBackButtonPic.loadImage("buttons/credits/back"+picNameEnd);
    creditsBackButton.set(ofGetWidth()*0.02, ofGetHeight()*0.91, creditsBackButtonPic.width, creditsBackButtonPic.height);
    //creditsBackButton.set(ofGetWidth()*0.02, ofGetHeight()*0.91, gameOverButtonPic.width*0.7, gameOverButtonPic.height*0.7);
    
    //mute buttons
    int muteButtonY=ofGetHeight()*0.9;
    muteSoundsButtonPics[0].loadImage("buttons/mute/muteSoundsOn"+picNameEnd);
    muteSoundsButtonPics[1].loadImage("buttons/mute/muteSoundsOff"+picNameEnd);
    muteMusicButtonPics[0].loadImage("buttons/mute/muteMusicOn"+picNameEnd);
    muteMusicButtonPics[1].loadImage("buttons/mute/muteMusicOff"+picNameEnd);
    muteSoundsButton.set(ofGetWidth()*0.8, muteButtonY, muteSoundsButtonPics[0].width,muteSoundsButtonPics[0].height);
    muteMusicButton.set(ofGetWidth()*0.9, muteButtonY, muteMusicButtonPics[0].width,muteMusicButtonPics[0].height);
    
    
    //punishing the player for forcing backtracks
    punishmentFoeTime=100;
    punishmentTimerDecrease=0.6;
    punishmentFoeTimer=0;
    
    //hard mode
    hardModeUnlocked=false;
    hardModeBeaten=false;
    hardModeActive = false;
    hardModeLevelIncrease =2.2;
    hardModeInkBonus = 50;
    hardModeCrownPic.loadImage("menu/titleCrown"+picNameEnd);
    
    //load the prefrences
    loadData();
    
    //pre-game stuff
    showAllInfo = false;
    
    //states
    fingerDown = false;
    ignoreTouchUp = false;
    gameStarted = true;
    
    prevFrameTime = ofGetElapsedTimef();
    
    gameState="menu";
    
    reset();
}

//--------------------------------------------------------------
void testApp::reset(){
    gameOver = false;
    
    //clear out any foes if there are any
    for (int i=foes.size()-1; i>=0; i--){
        //set the reached the end flag so they don't spawn an exlosion
        foes[i]->reachedTheEnd=true;
        //kill them
        killFoe(i);
    }
    
    //set all towers to think the player is alive
    for (int i=0; i<towers.size(); i++)
        towers[i]->playerDead=false;
    
    //ink values
    float relativeInkScale;// = 0.37;//0.4;   //for adjusting the overall cost of things
    if (!hardModeActive) relativeInkScale = 0.3;
    else                relativeInkScale = 0.37;
    blackInkValue   = .02 *relativeInkScale;
    colorInkValue[0] = .23 *relativeInkScale;
    colorInkValue[1] = .35 *relativeInkScale;
    colorInkValue[2] = .30 *relativeInkScale;
    
    health=healthStart;
    totalInk=startInk;
    if (hardModeActive) totalInk+=hardModeInkBonus;
    score=0;
    outOfInkBannerTimer=0;
    numEntrances=1; //TESTING
    nextEntrance=0;
    
    fastForward = false;
    
    damageFlashTimer=0;
    
    //clear any ink coming to the player
    inkParticles.clear();
    
    inkUsed = 0;
    
    //set all of the pixels to blank
    for (int i=0; i<fieldW*fieldH; i++){
        wallPixels[i]=255;
    }
    
    //clear all of the images
    for (int i=0; i<boardW*boardH; i++){
        blackPixels[i] = 0;
        colorPixels[0][i] = 0;
        colorPixels[1][i] = 0;
        colorPixels[2][i] = 0;
    }
    for (int i=0; i<boardW * boardH * 2; i+=2){
        //wallDispPixels[i]   = 255;
        wallDispPixels[i+1] = 0;
        for (int k=0; k<3; k++){
            //colorDispPixels[k][i]   = 255;
            colorDispPixels[k][i+1] = 0;
        }
    }
    //set the images
    for (int i=0; i<3; i++){
        colorImgs[i].setFromPixels(colorPixels[i],boardW, boardH);
        colorDispTex[i].loadData(colorDispPixels[i], boardW, boardH, GL_LUMINANCE_ALPHA);
    }
    blackImg.setFromPixels(blackPixels, boardW, boardH);
    wallDispTex.loadData(wallDispPixels, boardW, boardH, GL_LUMINANCE_ALPHA);
    
    //clear the route grids
    for (int x=0; x<FIELD_W; x++){
        for (int y=0; y<FIELD_H; y++){
            routeFromLeftGrid[x][y].set(-2,-2); //-2 means it's not active
            routeFromTopGrid[x][y].set(-2,-2); 
        }
    }
    
    playerPause = false;
    noPath=false;
    
    towerID=0;
    
    curWave=-1;
    wavesDone=false;
    loadFromText();
    startNextWave();
    //    
    //    //play the sound
    //    if (ofGetFrameNum()>5)  //don't play the sound when the game first turns on
    //        SM.playSound("start");
    
    convertDrawingToGame();
}


//--------------------------------------------------------------
void testApp::update(){
    //anything that only needs to happen at the very start
    if (ofGetFrameNum()<10){
        //set it to mirror if it isn't already
        if (!ofxiPhoneExternalDisplay::isMirroring()){
            //code from the internet to get it to mirror on exteral screens
            ofxiPhoneExternalDisplay::mirrorOn();
            ofxiPhoneExternalDisplay::isMirroring();
        }
    }
    //TESTING
    //waveComplete = false;
    
    //get delta time
    deltaTime = ofGetElapsedTimef()-prevFrameTime;
    prevFrameTime = ofGetElapsedTimef();
    
    if (gameState=="game"){
        //check if there is any reason to pause the game
        if (playerPause || noPath  || !gameStarted || waveComplete || fingerDown)
            paused=true;
        else
            paused=false;
        
        int numUpdates=1;
        if (fastForward)    numUpdates= (retina) ? 4 : 3;   //older iPads can't go quite as fast :(
        for (int i=0; i<numUpdates; i++){
            //manage the current wave
            if (curWave>=0 && !wavesDone){
                waves[curWave].update(paused, fastForward);
                if (waves[curWave].readyForNextFoe)
                    spawnFoe(waves[curWave].getNextFoe(),waves[curWave].level + (hardModeActive*hardModeLevelIncrease));
                
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
                //remove it if it is dead (and the player is still alive)
                else if (foes[i]->dead && health>0){
                    //kill it
                    killFoe(i);
                    //play the sound
                    //SM.playSound("enemyDeath");
                }
            }
            
            //add to the punishment timer if a foe back tracked
            if (addToPunishmentTimer)
                punishmentFoeTimer++;
            
            //reduce the timer slightly to account for no back tracking recently
            if (punishmentFoeTimer>0 && !paused)
                punishmentFoeTimer-=punishmentTimerDecrease;
            
            //check if it's time to spawn an punishment foe
            if (punishmentFoeTimer>=punishmentFoeTime){
                punishmentFoeTimer=0;   //reset the timer
                //spawn a stealth foe slightly stronger than the current wave level
                spawnFoe("stealth", waves[curWave].level+1);
            }
            
            //if the game was paused because a foes didn't have a path, unpause if the way is clear now
            //        if (allFoesHavePath && noPath){
            //            noPath=false;
            //        }
            
       
            
            //update the towers
            for (int i=0; i<towers.size(); i++){
                towers[i]->update();
                
                //if this tower is ready to shoot and the player isn't dead, check if there is a foe within range
                if (towers[i]->readyToShoot && health>0){
                    
                    float closestDist=10000000;
                    int closestID=-1;
                    for (int k=0; k<foes.size(); k++){
                        float distance=towers[i]->pos.distance(foes[k]->p.pos);
                        if ( distance < towers[i]->range +towers[i]->rangePadding && distance<closestDist){
                            
                            //red can only target foes not immune to red
                            if (towers[i]->type=="red"){
                                closestDist=distance;
                                closestID=k;
                            }
                            
                            //green can shoot goddamn anything
                            //MAYBE NOT. TETSING THIS OUT
                            if (towers[i]->type=="green" && foes[k]->type!="immune"){
                                closestDist=distance;
                                closestID=k;
                            }
                            
                            //freeze tower cannot shoot the foe if it is already frozen
                            if (towers[i]->type=="blue" && foes[k]->freezeTimer<=0){
                                closestDist=distance;
                                closestID=k;
                            }
                        }
                    }
                    
                    if (closestID!=-1){
                        towers[i]->fire(foes[closestID]);
                    }
                    
                }
                
                //if this is a bomb tower, check if it just hit
                if(towers[i]->bombHit){
                    towers[i]->bombHit=false;
                    
                    //find all of the foes in range of the bullet and damage them
                    for (int k=0; k<foes.size(); k++){
                        if (towers[i]->bullet.pos.distance(foes[k]->p.pos)<towers[i]->blastRadius && foes[k]->type!="immune" && health>0){
                            foes[k]->hp-=towers[i]->bulletDamage;
                        }
                    }
                    
                    //add an animation
                    BombAnimation newBombAnimation;
                    newBombAnimation.setup(towers[i]->bullet.pos.x,towers[i]->bullet.pos.y,towers[i]->blastRadius);
                    bombAnimations.push_back(newBombAnimation);
                }
            }
        }
        
        //kil any old bomb animations
        for (int i=bombAnimations.size()-1; i>=0; i--){
            bombAnimations[i].update();
            if (bombAnimations[i].done)
                bombAnimations.erase(bombAnimations.begin()+i);
        }
        
        //update ink particles
        //the location is in terms of the board the game is played on
        int inkEndX=ofGetWidth()*0.05;
        int inkEndY=ofGetHeight()*0.85;
        for (int i=inkParticles.size()-1; i>=0; i--){
            //reset the particle
            inkParticles[i].resetForce();
            //atract the controler to the next node
            inkParticles[i].addAttractionForce(inkEndX, inkEndY, ofGetWidth()*1.5, 0.95);
            //dampen and update the particle
            inkParticles[i].addDampingForce();
            inkParticles[i].update();
            
            //check if it reached the end
            if (ofDist(inkParticles[i].pos.x, inkParticles[i].pos.y, inkEndX, inkEndY)<ofGetWidth()*0.02){
                //give the player ink
                //totalInk+=inkParticles[i].inkValue;
                //kill the particle
                inkParticles.erase(inkParticles.begin()+i);
            }
        }
        
        //update explosions and puffs
        for (int i=explosions.size()-1; i>=0; i--){
            explosions[i].update();
            
            if (explosions[i].killMe)
                explosions.erase(explosions.begin()+i);
        }
        
        //update the wave info boxes if they need any changing
        //fade out the bottom box if the level was just finished
        if (waveInfoBoxes.size()>0){
            if (waveInfoBoxes[0].fading){
                waveInfoBoxes[0].alpha-=waveInfoBoxes[0].fadeSpeed;
                //kill it if it is gone
                if (waveInfoBoxes[0].alpha<=0){
                    waveInfoBoxes.erase(waveInfoBoxes.begin());
                }
            }
        }
        //if the bottom box is not on the bottom line, move them all down and adjust the alhpa
        if (waveInfoBoxes.size()>0){    //make sure there is somehting there
            if (waveInfoBoxes[0].pos.y<waveInfoBottom){
                for (int i=0; i<waveInfoBoxes.size(); i++){
                    waveInfoBoxes[i].pos.y+=waveInfoBoxes[i].fallSpeed;
                    //make sure they don't go below the line
                    waveInfoBoxes[i].pos.y=MIN(waveInfoBottom, waveInfoBoxes[i].pos.y);
                    //set the alpha based on the distance to the bottom line
                    waveInfoBoxes[i].alpha=ofMap( waveInfoBottom-waveInfoBoxes[i].pos.y, 0, waveInfoDistToFadeOut, 255, 0, true);
                }
            }
        }
    }

}

//--------------------------------------------------------------
void testApp::draw(){
	ofSetRectMode(OF_RECTMODE_CORNER);
	ofSetColor(255);
    backgroundPic.draw(0,0, ofGetWidth(), ofGetHeight());
    
    ofEnableAlphaBlending();
    
    if (gameState=="game"){
        //show the game
        drawGame();
        
        //show the border
        ofSetRectMode(OF_RECTMODE_CORNER);
        ofSetColor(255);
        borderPics[numEntrances-1].draw(boardOffset.x, boardOffset.y, borderPics[numEntrances-1].width*(1+retina), borderPics[numEntrances-1].height*(1+retina));
        
        //show player stats that live outside of the game area
        drawPlayerInfo(); 
        
        //let the player know if they are dead
        if (gameOver && health<=0){
            drawEndGame(false);
        }
        
        //show the pause screen if it's up
        if (playerPause){
            drawPause();
        }
        
        //set the rect mode back
        ofSetRectMode(OF_RECTMODE_CORNER);
    }
    
    if (gameState=="menu"){
        drawMenu();
    }
    
    if (gameState=="howTo"){
        drawHowTo();
    }
    
    if (gameState=="credits"){
        drawCredits();
    }
    
    //draw the mute buttons on menu or pause
    if ( (gameState=="menu" || playerPause) && gameState!="credits"){
        ofSetColor(255);
        muteSoundsButtonPics[SM.muteSoundEffects].draw(muteSoundsButton.x,muteSoundsButton.y);
        muteMusicButtonPics[SM.muteMusic].draw(muteMusicButton.x,muteMusicButton.y);
    }
    
    ofDisableAlphaBlending();
    
    //debug info
//    ofSetColor(255,100,100);
//    ofDrawBitmapString(ofToString(ofGetFrameRate()), 5,ofGetHeight()-2);
//    string pausedText = "not paused";
//    if (paused){
//        pausedText = "paused because  ";
//        if (playerPause)    pausedText+="player paused  ";
//        if (noPath)         pausedText+="no path  ";
//        if (!gameStarted)   pausedText+="game not started  ";
//        if (waveComplete)   pausedText+="wave complete  ";
//        if (fingerDown)     pausedText+="finger down";
//    }
//    ofDrawBitmapString(pausedText, 100, ofGetHeight()-2);
    
}

//--------------------------------------------------------------
void testApp::drawGame(){
    ofPushMatrix();
    ofTranslate(boardOffset.x, boardOffset.y);
    
    ofSetRectMode(OF_RECTMODE_CENTER);
    //DRAW OUT THE DEBUG INFO IF THIS IS TURNED ON
    if(showAllInfo){

        //go through the images and draw them all out to the screen
        for (int x=0; x<fieldW; x++){
            for (int y=0; y<fieldH; y++){
                int pos=y*fieldW+x;
                ofSetColor(0,100,200);
                if (wallPixels[pos]==0){
                    ofRect(x*fieldScale, y*fieldScale, fieldScale, fieldScale);
                }
                
                //draw if this is part of the route from the left
                if (routeFromLeftGrid[x][y].x != -2){
                    ofSetColor(200,100,0);
                    ofRect(x*fieldScale, y*fieldScale, fieldScale, fieldScale);
                }
                //or part of the route form the top
                if (routeFromTopGrid[x][y].x != -2){
                    ofSetHexColor(0xed21ef);
                    ofRect(x*fieldScale, y*fieldScale, fieldScale, fieldScale);
                }
                
            }
        }
        
        //show the vector field if we're viewing all data
        ofSetColor(0,130,130, 200);
    }
    
    //show the towers
    ofEnableBlendMode(OF_BLENDMODE_MULTIPLY);
    for (int i=0; i<towers.size(); i++)
        towers[i]->draw();
    ofDisableBlendMode();
    ofEnableAlphaBlending();
    
    //draw the board
    ofSetRectMode(OF_RECTMODE_CORNER);
    //black walls
    ofSetColor(255);
    wallDispTex.draw(0,0, boardW*boardScale, boardH*boardScale);
    //collored bits
    for (int i=0; i<3; i++){
        //grey out the drawing if the player is dead
        if (health>0)   ofSetColor(dispColor[i]);
        else            ofSetColor(200);
        colorDispTex[i].draw(0,0, boardW*boardScale, boardH*boardScale);
    }
    
    ofSetRectMode(OF_RECTMODE_CENTER);
    //show the foes
    for (int i=0; i<foes.size(); i++){
        foes[i]->draw();
        
        if (showAllInfo)
            foes[i]->drawDebug();
    }
    
    //draw the bomb animations if there are any
    ofFill();
    for (int i=0; i<bombAnimations.size(); i++)
        bombAnimations[i].draw();
    
    //draw the bullets beign shot by towers (if any)
    for (int i=0; i<towers.size(); i++)
        towers[i]->drawBullet();
    
    //draw explosions and puffs
    for (int i=0; i<explosions.size(); i++)
        explosions[i].draw();
    
    
    //Things to draw if there is no path
    if (noPath){
        //show exclamations 
        for (int i=0; i<foes.size(); i++){
            //if they have no path, show the exclamation point
            if (!foes[i]->pathFound){
                ofSetColor(255);
                float xPos = foes[i]->p.pos.x+ofGetWidth()*0.005 + ofNoise(i*100, ofGetElapsedTimef()/3)*ofGetWidth()*0.005;
                float yPos = foes[i]->p.pos.y-ofGetWidth()*0.03 - ofNoise(i, ofGetElapsedTimef()/3)*ofGetWidth()*0.01;
                foeExclamationPic.draw(xPos, yPos);
            }
        }
        
        //show the path of the foes that could not reach the end
        for (int i=0; i<foes.size(); i++){
            if (foes[i]->showPath){
                foes[i]->drawExplored();
            }
        }
        //show the explored area of the tempFoes if they could not find a path
        if (health>0){
            ofFill();
            if (tempFoeTop.showPath){
                tempFoeTop.drawExplored();
            }
            if (tempFoeLeft.showPath){
                tempFoeLeft.drawExplored();
            }
        }
    }
    
    //draw ink particles if there are any
    //ofSetColor(150);
    ofFill();
    ofSetRectMode(OF_RECTMODE_CENTER);
    for (int i=0; i<inkParticles.size(); i++)
        inkParticles[i].drawInk();
    
    
     ofPopMatrix();
}

//--------------------------------------------------------------
void testApp::drawPause(){
    //fade out the screen a bit
    ofSetRectMode(OF_RECTMODE_CORNER);
    ofSetColor(255,220);
    backgroundPic.draw(0,0, ofGetWidth(), ofGetHeight());
    
    ofSetRectMode(OF_RECTMODE_CENTER);
    int bannerX = ofGetWidth()*0.5;
    int bannerY =ofGetHeight()*0.2;
    
    ofSetColor(255,ofMap(sin(ofGetElapsedTimef()*2), -1,1, 140,250));
    bannerBacks[5].draw(bannerX, bannerY);
    ofSetColor(0);
    banners[5].draw(bannerX, bannerY);
    
    //show normal buttons when not showing the quit warning
    if (!aboutToQuit){
        //draw the buttons
        ofSetRectMode(OF_RECTMODE_CORNER);
        ofSetColor(255);
        for (int i=0; i<4; i++){
            pauseScreenButtonPics[i].draw(pauseScreenButtons[i].x, pauseScreenButtons[i].y, pauseScreenButtons[i].width, pauseScreenButtons[i].height);
        }
    }else{
        int buttonY = ofGetHeight()*0.7;
        int spacing = ofGetWidth()*0.1;
        yesNoButtons[0].x = ofGetWidth()/2-yesNoButtons[0].width-spacing;
        yesNoButtons[0].y =buttonY;
        yesNoButtons[1].x = ofGetWidth()/2+spacing;
        yesNoButtons[1].y = buttonY;
        
        ofSetRectMode(OF_RECTMODE_CENTER);
        ofSetColor(255);
        quitWarningPic.draw(ofGetWidth()/2, ofGetHeight()*0.5);
        
        ofSetRectMode(OF_RECTMODE_CORNER);
        
        for (int i=0; i<2; i++){
            yesNoButtonPics[i].draw(yesNoButtons[i].x, yesNoButtons[i].y);
        }
    }
}

//--------------------------------------------------------------
void testApp::drawEndGame(bool win){
    //fade out the screen a bit
    ofSetRectMode(OF_RECTMODE_CORNER);
    ofSetColor(255,170);
    backgroundPic.draw(0,0, ofGetWidth(), ofGetHeight());
    
    ofSetRectMode(OF_RECTMODE_CENTER);
    int messageX=boardOffset.x+boardW*boardScale*0.5;
    int messageY=ofGetHeight()*0.25 +ofGetHeight()*0.02;
    float deathMessageY=boardOffset.y+boardH*boardScale*0.3 +ofGetHeight()*0.02;
    if (win) deathMessageY-=ofGetHeight()*0.03;
    ofSetColor(255,ofMap(sin(ofGetElapsedTimef()*2), -1,1, 120,210));
    
    if (!win){
        bannerBacks[4].draw(messageX, deathMessageY);
        ofSetColor(255,0,0);
        if (ofGetFrameNum()/4%2==0) ofSetColor(0);
        banners[4].draw(messageX, deathMessageY);
        
        ofSetColor(0);
        drawCenteredText("After "+ofToString(curWave)+" waves", infoFontBig, messageX, messageY+ofGetHeight()*0.24);
    }
    else{
        bannerBacks[3].draw(messageX, deathMessageY);
        ofSetColor(255,0,0);
        if (ofGetFrameNum()/4%2==0) ofSetColor(0);
        banners[3].draw(messageX, deathMessageY);
        
        ofSetColor(0);
        drawCenteredText("With "+ofToString((int)(totalInk-inkUsed))+" ink left", infoFontBig, messageX, messageY+ofGetHeight()*0.24);
    }
    
    //reset button
    int alpha = ofMap(sin(ofGetElapsedTimef()*3),-1,1, 180, 255);
    ofSetColor(255,alpha);
    ofSetRectMode(OF_RECTMODE_CORNER);
    gameOverButton.y=messageY+ofGetHeight()*0.34;
    gameOverButton.x= messageX-gameOverButton.width/2;
    gameOverButtonPic.draw(gameOverButton.x, gameOverButton.y);
}


//--------------------------------------------------------------
void testApp::drawWaveCompleteAnimation(){
    //get the amount of time the animation has played
    float curTime=ofGetElapsedTimef()-waveAnimationStart;
    
    int messageX=boardOffset.x+boardW*boardScale*0.5;
    int messageY=boardOffset.y+boardH*boardScale*0.5;
    
    //ofColor thisCol;
    //thisCol.setHsb(ofRandom(255), 255, 100);
    
    ofSetRectMode(OF_RECTMODE_CENTER);
    
    //backing
    
    if (wavesDone){
        gameOver = true;
        drawEndGame(true);
    }else{
        //draw the backing
        ofSetColor(255,ofMap(sin(ofGetElapsedTimef()*2), -1,1, 120,210));
         bannerBacks[2].draw(messageX, messageY);
        //and the banner proper
        ofSetColor(ofColor::fromHsb(ofRandom(255), 255, 100));
         banners[2].draw(messageX, messageY);
    }
    
    //    if (curWave+1 != waves.size()){
    //        banners[2].draw(messageX, messageY);
    //    }else{
    //        banners[3].draw(messageX, messageY);
    //        curTime=0;
    //    }
    
    //if time is up, return to the game
    if (curTime>waveAnimationTime){
        startNextWave();
    }
}

//--------------------------------------------------------------
void testApp::drawPlayerInfo(){
    
    //draw health
    ofSetRectMode(OF_RECTMODE_CORNER);
    float xCenter=boardOffset.x + boardW*boardScale*0.5;
    float healthY=ofGetHeight()*0.01;   //boardOffset.y + boardH*boardScale;
    float healthWidth=boardW*boardScale;
    float xLeft=xCenter-healthWidth/2;
    float healthSpacing= (healthWidth - healthStart*healthPicFull[0].width)/healthStart;
    //draw full hearts for the life remaining
    ofSetColor(255);
    for (int i=0; i<health; i++){
        healthPicFull[i].draw(xLeft+i*healthPicFull[0].width+i*healthSpacing,healthY);
    }
    //end empty life for the life lost
    for (int i=MAX(0,health); i<healthStart; i++){
        healthPicEmpty[i].draw(xLeft+i*healthPicEmpty[0].width+i*healthSpacing,healthY);
    }
    
    
    //written values
    int thisTextX;
    
    //SHOW INK VALUES
    ofFill();
    ofSetColor(0);
    int inktextRightX=ofGetWidth()*0.09;
    int inkTextY=ofGetHeight()*0.91;
    
    thisTextX=inktextRightX-infoFont.stringWidth("Ink Left:")/2;
    infoFont.drawString("Ink Left:",thisTextX,inkTextY);
    thisTextX=inktextRightX-infoFontBig.stringWidth(ofToString((int)(totalInk-inkUsed)))/2;
    infoFontBig.drawString(ofToString((int)(totalInk-inkUsed)),thisTextX,inkTextY+ofGetHeight()*0.04);
    
    
    //draw the wave info boxes
    //don't show these during how to, only during game
    if (gameState=="game"){
        ofSetRectMode(OF_RECTMODE_CENTER);
        for (int i=0; i<waveInfoBoxes.size(); i++){
            waveInfoBoxes[i].draw();
        }
    }
    
    //color selection buttons
    ofSetRectMode(OF_RECTMODE_CORNER);
    //show the one that has been selected during gamepaly
    if (gameState=="game"){
        ofPushMatrix();
        ofTranslate(colorButtons[curBrushColor].x+colorButtonPics[curBrushColor].width/2, colorButtons[curBrushColor].y+colorButtonPics[curBrushColor].height/2);
        ofScale(1.3,1.3);
        ofSetColor(255,120);
        colorButtonPics[curBrushColor].draw(-colorButtonPics[curBrushColor].width/2,-colorButtonPics[curBrushColor].height/2);
        ofPopMatrix();
    }
    //then draw all of them
    ofSetColor(255);
    for (int i=0; i<5; i++)
        colorButtonPics[i].draw(colorButtons[i].x, colorButtons[i].y);
    
    //game buttons
    ofNoFill();
    ofSetColor(255);
    //pause buttons
    pauseButtonPic.draw(pauseButton.x, pauseButton.y);
    //if the fast forward button has been selected, show it again behind itself during gamepaly
    if (fastForward && gameState=="game"){
        ofPushMatrix();
        ofTranslate(fastForwardButton.x+fastForwardButtonPic.width/2, fastForwardButton.y+fastForwardButtonPic.height/2);
        ofScale(1.3,1.3);
        ofSetColor(255,120);
        fastForwardButtonPic.draw(-fastForwardButtonPic.width/2,-fastForwardButtonPic.height/2);
        ofPopMatrix();
    }
    ofSetColor(255);
    fastForwardButtonPic.draw(fastForwardButton.x, fastForwardButton.y);
    
    //if they are playing in hard mode, show the crown on top
    if (hardModeActive){
        ofPushMatrix();
        ofTranslate(ofGetWidth()*0.89, ofGetHeight()*0.04);
        ofScale(0.5,0.5);
        ofRotate(69);
        ofSetColor(255,120);
        hardModeCrownPic.draw(-hardModeCrownPic.width/2,-hardModeCrownPic.height/2);
        ofPopMatrix();
    }
    
    //BANNERS
    //let the player no if there is no path
    ofFill();
    ofSetRectMode(OF_RECTMODE_CENTER);
    int messageX=boardOffset.x+boardW*boardScale*0.5;
    int messageY=ofGetHeight()*0.11;//*0.25;
    ofSetColor(0,0,0);
    if (noPath && !wavesDone){
        ofSetColor(255,ofMap(sin(ofGetElapsedTimef()*2), -1,1, 120,210));
        bannerBacks[0].draw(messageX, messageY);
        ofSetColor(0);
        banners[0].draw(messageX, messageY);
    }
    //let the player know if they used too much ink
    if (outOfInkBannerTimer > 0 && !wavesDone){
        float alpha = ofMap(outOfInkBannerTimer, outOfInkBannerTime*0.75, 0, 255,0);
        ofSetColor(255,alpha-40);
        bannerBacks[1].draw(messageX, messageY);
        ofSetColor(0,alpha);
        banners[1].draw(messageX, messageY);
        outOfInkBannerTimer-=deltaTime;
    }
    
    //check if we should be showing the wave complete animation
    if (waveComplete)
        drawWaveCompleteAnimation();
    
    //draw red over the game if the player was just hit
    if (damageFlashTimer-- > 0){
        ofSetRectMode(OF_RECTMODE_CORNER);
        ofSetColor(255, ofMap(damageFlashTimer, 0, damageFlashTime, 0, 255));
        float damageX = boardOffset.x+boardW*boardScale*0.48 - playerHitPic.width/2;
        float damageY = boardOffset.y+boardH*boardScale*0.5 - playerHitPic.height/2;
        playerHitPic.draw(damageX,damageY);
    }
    
}

//--------------------------------------------------------------
void testApp::drawMenu(){
    
    ofSetRectMode(OF_RECTMODE_CENTER);
    ofSetColor(255);
    titlePic.draw(ofGetWidth()*0.5, ofGetHeight()*0.27);
    
    //if hardmode is unlocked, reposition play and playHard
    if (hardModeUnlocked){
        int spacing = ofGetWidth()*0.25;
        menuButtons[0].width = menuButtonPics[4].width;
        menuButtons[0].height = menuButtonPics[4].width;
        menuButtons[0].x=ofGetWidth()/2-spacing-menuButtons[0].width/2;
        menuButtons[3].x=ofGetWidth()/2+spacing-menuButtons[3].width/2;
        menuButtons[3].y=menuButtons[0].y;
    }
    
    //show the crowns if they've beaten the game at all
    ofSetColor(255);
    if (hardModeUnlocked){
        hardModeCrownPic.draw(ofGetWidth()*0.35, ofGetHeight()*0.09);
        
        if (hardModeBeaten)
            hardModeCrownPic.draw(ofGetWidth()*0.64, ofGetHeight()*0.08, -hardModeCrownPic.width, hardModeCrownPic.height);
    }
    
    ofSetRectMode(OF_RECTMODE_CORNER);
    //draw the buttons
    for (int i=0; i<NUM_MENU_BUTONS-(1-hardModeUnlocked); i++){
        //have play pulse
        int alpha = (i==0 || i==3) ? ofMap(sin(ofGetElapsedTimef()*3),-1,1, 180, 255) : 255;
        ofSetColor(255,alpha);
        if (i==0 && hardModeUnlocked){
            menuButtonPics[4].draw(menuButtons[i].x, menuButtons[i].y);
        }else{
            menuButtonPics[i].draw(menuButtons[i].x, menuButtons[i].y);
        }
    }
    
    //probaby don't need to draw your name if its on the launch image and the credits page
    //ofSetColor(0);
    //infoFontSmall.drawString("Andy Wallace 2012", ofGetWidth()*0.01, ofGetHeight()*0.98);
}

//--------------------------------------------------------------
void testApp::drawHowTo(){
    //draw the HUD
    //show the border
    ofSetRectMode(OF_RECTMODE_CORNER);
    ofSetColor(255);
    borderPics[numEntrances-1].draw(boardOffset.x, boardOffset.y, borderPics[numEntrances-1].width*(1+retina), borderPics[numEntrances-1].height*(1+retina));
    
    //show player stats that live outside of the game area
    drawPlayerInfo(); 
    
    //cover it up a bit
    ofSetRectMode(OF_RECTMODE_CORNER);
    ofSetColor(255,150);
    backgroundPic.draw(0,0, ofGetWidth(), ofGetHeight());
    
    //draw the slide
    ofSetRectMode(OF_RECTMODE_CORNER);
    ofSetColor(255);
    howToSlides[curHowToSlide].draw(ofGetWidth()*0.07,ofGetHeight()*0.16, howToSlides[curHowToSlide].width*(retina+1), howToSlides[curHowToSlide].height*(retina+1));
    
    //and the next button
    nextButtonPic[curHowToSlide==NUM_HOW_TO_SLIDES-1].draw(nextButton.x, nextButton.y, nextButton.width, nextButton.height);
    
    //make sure the game is paused
    paused = true;
}

//--------------------------------------------------------------
void testApp::drawCredits(){
    ofSetRectMode(OF_RECTMODE_CENTER);
    
    ofSetColor(255,ofMap(sin(ofGetElapsedTimef()*2), -1,1, 120,210));
    bannerBacks[6].draw(ofGetWidth()*0.5, ofGetHeight()*0.13);
    ofSetColor(0);
    banners[6].draw(ofGetWidth()*0.5, ofGetHeight()*0.13);
    
    
    int startY = ofGetHeight()*0.3;
    int ySpacing = ofGetHeight()*0.09;
    
    ofSetColor(0);
    infoFontBig.drawCenteredStringBottom("Game by Andy Wallace", ofGetWidth()/2, startY+ySpacing*0);
    infoFontBig.drawCenteredStringBottom("Art by Midge Belickis", ofGetWidth()/2, startY+ySpacing*1);
    infoFontBig.drawCenteredStringBottom("Sound & Music by Jay Braun", ofGetWidth()/2, startY+ySpacing*2);
    
    infoFontBig.drawCenteredStringBottom("Special Thanks:", ofGetWidth()/2, startY+ySpacing*3);
    
    //draw the back names
    int backerSpacing = ofGetHeight()*0.05;
    int totalHeight = NUM_BACKERS * backerSpacing + backerSpacing;
    
    float backerEnd = startY+ySpacing*3.4;
    float backerStart = ofGetHeight()+backerSpacing;
    
    float speed = 75;
    
    for (int i=0; i<NUM_BACKERS; i++){
        //int thisY = i*backerSpacing + backerStart - (int)(ofGetElapsedTimef()*speed)%totalHeight;
        int thisY = i*backerSpacing + backerStart - ofGetElapsedTimef()*speed;
        
        
        //holy shit this could get bad if it's been running for a long time
        while (thisY < backerEnd){
            thisY+=totalHeight;
        }
        
        if (thisY>backerEnd && thisY<backerStart){
            int alpha = ofMap(thisY-backerEnd,0, ofGetHeight()*0.02, 0, 255, true);
            ofSetColor(0,alpha);
            infoFont.drawCenteredStringBottom(backerNames[i], ofGetWidth()/2, thisY);
        }
        
        
    }
    
    //draw the back button
    ofSetRectMode(OF_RECTMODE_CORNER);
    ofSetColor(255);
    creditsBackButtonPic.draw(creditsBackButton.x, creditsBackButton.y, creditsBackButton.width, creditsBackButton.height);
    
}


//--------------------------------------------------------------
void testApp::exit(){
    
}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs & touch){
    
    if (gameState=="game"){
        fingerDown = true;
        
        if (!playerPause && health>0){
            //check the pallet buttons
            for (int i=0; i<5; i++){
                if (colorButtons[i].inside(touch.x,touch.y)){
                    curBrushColor = i;
                }
            }
            
            //other buttons
            if (fastForwardButton.inside(touch.x,touch.y)){
                fastForward=!fastForward;
            }
            if (pauseButton.inside(touch.x,touch.y)){
                playerPause = true;
                SM.playSound("paper");
            }
            
            //start applying the brush
            if (touch.id==0){
                brushDown(touch.x, touch.y);
            }
            
        }
        
    }
    
    if ((playerPause || gameState=="menu") && gameState!="credits"){
        if (muteSoundsButton.inside(touch.x, touch.y)){
            SM.toggleSounds();
            SM.playSound("paper");
            saveData();
        }
        if (muteMusicButton.inside(touch.x, touch.y)){
            SM.toggleMusic();
            SM.playSound("paper");
            saveData();
        }
    }
    
    if (gameState == "howTo" && nextButton.inside(touch.x, touch.y)){
        curHowToSlide++;
        if (curHowToSlide==NUM_HOW_TO_SLIDES){
            gameState=stateToReturnTo;
            //in case this was the first time through, turn off the flag to force the how to and save
            if (forceHowTo){
                forceHowTo = false;
                saveData();
                playerPause = false;
                reset();
            }
        }
        SM.playSound("paper");
        ignoreTouchUp=true;
    }
    
    if (gameState == "credits"){
        if (creditsBackButton.inside(touch.x, touch.y)){
            gameState=stateToReturnTo;
            SM.playSound("paper");
            ignoreTouchUp=true;
        }
    }
    
    if (touch.id==0){
        lastX = touch.x;
        lastY = touch.y;
    }
    
}

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs & touch){
    if (touch.id == 0 && !playerPause && gameState=="game"){
        
        //if the finger moved fast, there could be blank space between where the two brush events are called
        //point spacing shows the aproximate number of pixels that shuld be betweene ach call to brushDown
        //if the finger further than this distance away from the last recorded position, create points along that line
        float pointSpacing = 6;
        
        float distanceToLastPos = ofDist(touch.x, touch.y, lastX, lastY);
        int numSpacedPoints = distanceToLastPos/pointSpacing;
        
        //get the distance between each individual point as rise and run
        float rise = (touch.y-lastY)/(numSpacedPoints+1);
        float run = (touch.x-lastX)/(numSpacedPoints+1);
        
        for (int i=0; i<numSpacedPoints+1; i++){
            brushDown(lastX + i*run, lastY + i*rise);
        }
        
        lastX = touch.x;
        lastY = touch.y;
    
    }
    
    
    
}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs & touch){
    
    if (ignoreTouchUp){
        //turn off the flag and get out
        ignoreTouchUp=false;
        return;
    }
    
    if (gameState=="game"){
        if (touch.id == 0){
            if (needToConvertDrawingToGame){
                convertDrawingToGame();
            }
            fingerDown = false;
        }
        
        //check for the pause screen buttons if that's what's up
        if (playerPause){
            
            if (pauseScreenButtons[0].inside(touch.x,touch.y)){
                playerPause=false;
                SM.playSound("paper");
            }
            
            if (pauseScreenButtons[1].inside(touch.x,touch.y)){
                gameState="howTo";
                curHowToSlide=0;
                stateToReturnTo = "game";
                SM.playSound("paper");
            }
            
            if (pauseScreenButtons[2].inside(touch.x,touch.y)){
                gameState="credits";
                stateToReturnTo = "game";
                SM.playSound("paper");
            }
            
            if (pauseScreenButtons[3].inside(touch.x,touch.y)){
                aboutToQuit=true;
//                gameState="menu";
                SM.playSound("paper");
            }else if (aboutToQuit){
                if (yesNoButtons[0].inside(touch.x,touch.y)){
                    aboutToQuit=false;
                    SM.playSound("paper");
                }
                if (yesNoButtons[1].inside(touch.x,touch.y)){
                    gameState="menu";
                    SM.playSound("paper");
                    aboutToQuit=false;
                }
            }
            
        }
        
        if (gameOver && gameOverButton.inside(touch.x,touch.y)){
            gameState="menu";
            SM.playSound("paper");
        }
        
    }
    
    else if (gameState=="menu"){
    
        if (menuButtons[0].inside(touch.x, touch.y)){
            //ussualy go to the game, but if this is the player's first time, show the how to
            if (!forceHowTo){
                gameState="game";
                SM.playSound("paper");
                hardModeActive=false;
                reset();
            }
            else{
                gameState="howTo";
                curHowToSlide=0;
                stateToReturnTo = "game";
                SM.playSound("paper");
                playerPause = true; //don't let the timer start running
            }
            
        }
        if (menuButtons[3].inside(touch.x,touch.y) && hardModeUnlocked){
            gameState="game";
            SM.playSound("paper");
            hardModeActive=true;
            reset();
        }
        
        if (menuButtons[1].inside(touch.x, touch.y)){
            gameState="howTo";
            curHowToSlide = 0;
            stateToReturnTo = "menu";
            SM.playSound("paper");
        }
        
        if (menuButtons[2].inside(touch.x, touch.y)){
            gameState="credits";
            stateToReturnTo = "menu";
            SM.playSound("paper");
        }
    
    }
    
}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs & touch){
    
    if(!publicRelease){
        if (touch.x<60 && touch.y>ofGetHeight()-60)
            showAllInfo = !showAllInfo;
        
        if (touch.x>ofGetWidth()-60 && touch.y>ofGetHeight()-60)
            spawnFoe("norm", 1);
        
        if (touch.x<60 && touch.y<60)
            reset();
    }
    
    //health-=1;
    
}

//--------------------------------------------------------------
void testApp::touchCancelled(ofTouchEventArgs & touch){
    
}

//--------------------------------------------------------------
void testApp::lostFocus(){
    //pause the game
    playerPause = true;
    cout<<"See ya later bye"<<endl;
    saveGameState();
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

void testApp::brushDown(float touchX, float touchY){
    //get out immediatly if the player is dead
    if (gameOver)  return;
    
    int relativeX = touchX-boardOffset.x;
    int relativeY = touchY-boardOffset.y;
    
    int brushStrength = 100;    //how much it adds at the center
    
    int maxDist = 15*boardScale;
    if (retina) maxDist*=0.7;    //shrink it a bit for retina
    
    //black gets a smaller but more powerful brush
    if (curBrushColor == 3){ 
        maxDist*= (retina) ? 0.6 : 0.45;   //black can be smaller. On retina devices they sometimes walk through thinner walls
        brushStrength = 255;
    }
    
    //eraser gets a smaller brush
    if (curBrushColor == 4) maxDist*=0.8;   
    
    //keeping track of how much ink refund (if any) was generated 
    //float blackInkRefund=0;
    float colorInkRefund[4];    //slot 3 is black
    for (int i=0; i<4; i++) colorInkRefund[i]=0;
    ofVec2f refundAvgLoc(0,0);
    int numRefundPix=0;   //used to calculate the average location
    
    //paint into the array
    int brushSize=maxDist/boardScale;
    //get the center of the brush
    int xMid=relativeX/boardScale;
    int yMid=relativeY/boardScale;
    
    int padding = 3;    //let them draw off the board just a bit
    int xStart=MAX(ofMap(mazeLeft,0,fieldW,-padding,boardW+padding),xMid-brushSize);
    int xEnd=MIN(ofMap(mazeRight,0,fieldW,-padding,boardW+padding),xMid+brushSize);
    int yStart=MAX(ofMap(mazeTop,0,fieldH,-padding,boardH+padding),yMid-brushSize);
    int yEnd=MIN(ofMap(mazeBottom,0,fieldH,-padding,boardH+padding),yMid+brushSize);
    
    //go through and set the pixels being effected by the brush
    for (int col=xStart; col<xEnd; col++){
        for (int row=yStart; row<yEnd; row++){
            //if there is no ink left to use, just get out
            if (inkUsed > totalInk && curBrushColor!=4){ 
                //play the error sound if this is the firts frame in a while where they'r eout of ink
                if (outOfInkBannerTimer<outOfInkBannerTime*0.8){
                    SM.playSound("error");
                }
                outOfInkBannerTimer = outOfInkBannerTime;
                break;
            }
            
            //figure out where in the arrays this pixel is
            int pos= row*boardW+col;
            int dispPos= row*boardW*2+col*2;    //locaiton in the array of greyscale/alpha pixels used for display
            
            int brushAmount = ofMap(ofDist(relativeX, relativeY, col*boardScale, row*boardScale),0, maxDist, brushStrength, 0, true);
            
            //store the values of the pixel before anything was changed to see if the pixel crossed any thresholds
            int prevBlackPixel = blackPixels[pos];
            int prevColPixels[3];
            for (int i=0; i<3; i++){
                prevColPixels[i] = colorPixels[i][pos];
            }
            
            //adjust the pixel values based on the brush and distance
            if (curBrushColor<3){
                //add to the selected color, take away from all others
                for (int i=0; i<3; i++){
                    if (i==curBrushColor)
                        colorPixels[i][pos] = MIN(255, colorPixels[i][pos]+brushAmount);
                    else
                        colorPixels[i][pos] = MAX(0, colorPixels[i][pos]-brushAmount);
                }
                //everything adds to the black pixels
                blackPixels[pos] = MIN(255, blackPixels[pos]+brushAmount);
            }else if (curBrushColor==3){
                //black brush
                blackPixels[pos] = MIN(255, blackPixels[pos]+brushAmount);
                //shrink the colored images
                for (int i=0; i<3; i++)
                    colorPixels[i][pos] = MAX(0, colorPixels[i][pos]-brushAmount);
            }
            else{
                //erase
                blackPixels[pos] = MAX(0, blackPixels[pos]-brushAmount);
                for (int i=0; i<3; i++)
                    colorPixels[i][pos] = MAX(0, colorPixels[i][pos]-brushAmount);
                
                //update this pixel on the display images
                for (int i=0; i<3; i++){
                    colorDispPixels[i][dispPos+1] = MIN(255, colorPixels[i][pos]);
                }
                //and the black display image
                wallDispPixels[dispPos+1] = blackPixels[pos];
            }
            
            
            //check if any pixels crossed a threshold
            if (prevBlackPixel < blackThreshold && blackPixels[pos] >= blackThreshold){
                inkUsed += blackInkValue;
            }
            if (prevBlackPixel >= blackThreshold && blackPixels[pos] < blackThreshold){
                //mark that ink should be returned
                colorInkRefund[3] += blackInkValue*wallRefund;
                refundAvgLoc.x+=col;
                refundAvgLoc.y+=row;
                numRefundPix++;
            }
            
            //check if color pixels crossed the threshold
            for (int i=0; i<3; i++){
                if (prevColPixels[i] < colorThreshold && colorPixels[i][pos] >= colorThreshold){
                    inkUsed += colorInkValue[i];
                }
                if (prevColPixels[i] >= colorThreshold && colorPixels[i][pos] < colorThreshold){
                    //mark that ink should be returned
                    colorInkRefund[i] += colorInkValue[i]*towerRefund;
                    refundAvgLoc.x+=col;
                    refundAvgLoc.y+=row;
                    numRefundPix++;
                }
            }
            
            //update this pixel on the display images
            for (int i=0; i<3; i++){
                colorDispPixels[i][dispPos+1] = MIN(255, colorPixels[i][pos]);
            }
            //and the black display image
            wallDispPixels[dispPos+1] = blackPixels[pos];
            
            //since soemthing changed, flag that we need to alter the game
            needToConvertDrawingToGame = true;
        }
    }
    
    //spit out some ink pixels if ink was refunded
    float inkPerParticle = 4;
    float pixelWiggle = ofGetWidth()*0.01;  //the force with which the particle can spawn
    
    //get the average locaiton of any refunds that hapenned
    if (numRefundPix>0) //no divide by 0
        refundAvgLoc/=numRefundPix;
    
    //check for colored ink
    for (int i=0; i<4; i++){
        while(colorInkRefund[i]>0){
            particle newInkParticle;
            float thisAngle = ofRandom(TWO_PI);
            float newX = refundAvgLoc.x*boardScale;
            float newY = refundAvgLoc.y*boardScale;    //right now, this is not technicaly placing along a circle
            newInkParticle.setInitialCondition(newX, newY, cos(thisAngle)*ofRandom(pixelWiggle), sin(thisAngle)*ofRandom(pixelWiggle));
            newInkParticle.inkValue = MIN(inkPerParticle, colorInkRefund[i]);
            newInkParticle.col = (i<3) ? dispColor[i] : ofColor::black;
            newInkParticle.inkPic = &inkParticlePic;
            inkParticles.push_back(newInkParticle);
            //take away from the total
            colorInkRefund[i]-=inkPerParticle;
            //add the ink to the player
            totalInk+=newInkParticle.inkValue;
        }
    }
    
    //set the images
    for (int i=0; i<3; i++){
        colorImgs[i].setFromPixels(colorPixels[i],boardW, boardH);
        colorDispTex[i].loadData(colorDispPixels[i], boardW, boardH, GL_LUMINANCE_ALPHA);
    }
    blackImg.setFromPixels(blackPixels, boardW, boardH);
    wallDispTex.loadData(wallDispPixels, boardW, boardH, GL_LUMINANCE_ALPHA);
    
}


//--------------------------------------------------------------
void testApp::convertDrawingToGame(){
    needToConvertDrawingToGame = false; //turn the flag off
    
    //get the walls
    wallImage.scaleIntoMe(blackImg);
    //wallImage=blackImg;
    wallImage.threshold(blackThreshold,true);
    wallPixels=wallImage.getPixels();
    //thickenWallImage(); //maybe don't need to do this
    setMazeBorders();
    
    //do path finding for the foes
    if (findPathsForFoes()){
        //if we got this far, there is a path
        noPath=false;
    }else{
        noPath=true;
        SM.playSound("error");  //play the sound
        return; //stop checking
    }
    
    //look for blobs to turn into towers
    //set all towers as unfound. If they are not found when checking the blobs, they will be removed
    for (int i=0; i<towers.size(); i++){
        towers[i]->found=false;
    }
    
    //red
    int minArea=20;
    int maxArea=(boardW*boardH)/2;
    int maxNumberOfBlobs=30;        //how many towers there can be
    
    //threshold the color images before looking for blobs
    //this will be undone next time the images are set from the pixel arrays
    for (int i=0; i<3; i++){
        colorImgs[i].threshold(colorThreshold, false);
    }
    
    contourFinder.findContours(colorImgs[0], minArea, maxArea, maxNumberOfBlobs+10, true);
    checkTowers("red");
    //green
    contourFinder.findContours(colorImgs[1], minArea, maxArea, maxNumberOfBlobs, true);
    checkTowers("green");
    //blue
    contourFinder.findContours(colorImgs[2], minArea, maxArea, maxNumberOfBlobs-10, true);
    checkTowers("blue");
    
    //find any towers that were not found in the last sweep and kill them
    for (int i=towers.size()-1; i>=0; i--){
        if (!towers[i]->found){
            delete towers[i];
            towers.erase(towers.begin()+i);
        }
    }
}

//--------------------------------------------------------------
bool testApp::findPathsForFoes(){
    //check if we even need to bother
    if (curBrushColor != 4){
        bool noObstruction = true;
        for (int i=foes.size()-1; i>=0; i--){
            //foes[i]->isObstructed=false;    //assume it's OK
            if (foes[i]->checkRouteForObstruction() == false){
                noObstruction=false;
            }
        }
        
        if (noObstruction){
            return true;
        }
    }
    
    
    
    //give the foes all of the info they need
    //for left
    tempFoeLeft.setup(startX[0], startY[0], goalX[0], goalY[0], fieldScale, fieldW, fieldH,0, retina);
    tempFoeLeft.wallPixels=wallPixels;
    tempFoeLeft.findPath();
    //from top
    tempFoeTop.setup(startX[1], startY[1], goalX[1], goalY[1], fieldScale, fieldW, fieldH,0, retina);
    tempFoeTop.wallPixels=wallPixels;
    tempFoeTop.findPath();
    
    //if there is no path for either foe, pause the game
    if (!tempFoeLeft.pathFound || (!tempFoeTop.pathFound && numEntrances==2)){
        //go through and mark every foe as hot having a path
        for (int i=0; i<foes.size(); i++){
            //if the foe's guide couldn't make it to the end, mark that they coudl not find a path
            if ((!tempFoeLeft.pathFound && foes[i]->horizontalGoal) || (!tempFoeTop.pathFound && !foes[i]->horizontalGoal)){
                foes[i]->pathFound=false;
                //foes[i]->clearPathfindingLists();
            }
        }
        
        return false;
    }
    
    //otherwise fill up our route grids
    else{
        //clear the route grids
        for (int x=0; x<FIELD_W; x++){
            for (int y=0; y<FIELD_H; y++){
                routeFromLeftGrid[x][y].set(-2,-2); //-2 means it's not active
                routeFromTopGrid[x][y].set(-2,-2); 
            }
        }
        
        //transfer the info about the path the left to right foe is using to the tile vector and grid
        for (int i=0; i<tempFoeLeft.route.size(); i++){
            tile newTile(tempFoeLeft.route[i]->x,tempFoeLeft.route[i]->y);
            //mark it in the grid
            //each grid location saves the alocation of the parent
            if (i<tempFoeLeft.route.size()-1)
                routeFromLeftGrid[newTile.x][newTile.y].set(tempFoeLeft.route[i+1]->x,tempFoeLeft.route[i+1]->y); 
            //the origin is marked as -1,-1
            else
                routeFromLeftGrid[newTile.x][newTile.y].set(-1,1); 
        }
        
        //transfer the info for the top to bottom foe
        for (int i=0; i<tempFoeTop.route.size(); i++){
            tile newTile(tempFoeTop.route[i]->x,tempFoeTop.route[i]->y);
            //mark it in the grid
            //each grid location saves the alocation of the parent
            if (i<tempFoeTop.route.size()-1)
                routeFromTopGrid[newTile.x][newTile.y].set(tempFoeTop.route[i+1]->x,tempFoeTop.route[i+1]->y); 
            //the origin is marked as -1,-1
            else
                routeFromTopGrid[newTile.x][newTile.y].set(-1,1); 
        }
        
    }
    
    //pathfinding for the foes
    if (foes.size()>0){
        for (int i=foes.size()-1; i>=0; i--){
            
            //first, if nothing was erased, check if their current path is still clear
            bool curPathOK = false;
            if (curBrushColor != 4){
                curPathOK = !foes[i]->isObstructed;
            }
            
            //if that didn't work, see if they can hop on the existing route
            bool standardRouteOK = false;
            if (!curPathOK){
                if (foes[i]->horizontalGoal)
                    standardRouteOK = foes[i]->checkExistingRoute(routeFromLeftGrid);
                else
                    standardRouteOK = foes[i]->checkExistingRoute(routeFromTopGrid);
                
                //if (standardRouteOK)   cout<<"using standard route"<<endl;
            }
            
            //if that doens't work, have the foe find its own path
            if (!curPathOK && !standardRouteOK){
                foes[i]->findPath();
                
                //pause the game if this foe can't reach the end
                if (!foes[i]->pathFound){
                    cout<<"NO PATH. GET OUT"<<endl;
                    return false;
                }
            }
        }
    }
    
    return true;
}

//--------------------------------------------------------------
//checks the contour finder for blobs and updates the towers based on them
void testApp::checkTowers(string type){
    //if there is a blob inside of another blob, then it was not a full circle and should not be considerred
    vector <int> skip;
    float minDist=5;
    
    //JUST USE the holes boolean in the blob. JESUS
    for (int i = 0; i < contourFinder.nBlobs; i++){
        for (int k=0; k<i; k++){
            if (ofDistSquared(contourFinder.blobs[i].centroid.x,contourFinder.blobs[i].centroid.y,
                       contourFinder.blobs[k].centroid.x,contourFinder.blobs[k].centroid.y)<minDist*minDist){
                skip.push_back(i);
                skip.push_back(k);
            }
        }
    }
    
    for (int i = 0; i < contourFinder.nBlobs; i++){
        //check if this was one of the blobs with holes. Skip it if it was
        bool skipMe=false;
        
        for (int k=0; k<skip.size(); k++){
            if (i==skip[k]) {
                skipMe=true;
            }
        }
        
        //find the radius
        float size=sqrt( contourFinder.blobs[i].area/PI )/2;    //diviing by 2 because the image is twice the size of the field
        
        //make sure the blob is at least pretty close to being a circle
        //check compacntess of the blob. a value of 1 would be a perfect circle. Higher values are less compact
        float compactness = (float)((contourFinder.blobs[i].length*contourFinder.blobs[i].length/contourFinder.blobs[i].area)/FOUR_PI);
        if (compactness>maxCompactness){ 
            skipMe=true;
        }
        
        //if it passed all those tests, try to make a tower for the blob
        if (!skipMe){
            //check if there is already a tower in this spot
            bool towerHere=false;
            
            for (int k=0; k<towers.size(); k++){
                if ( ofDistSquared(towers[k]->pos.x,towers[k]->pos.y, contourFinder.blobs[i].centroid.x*boardScale,contourFinder.blobs[i].centroid.y*boardScale)<powf(size*boardScale,2) &&
                    towers[k]->type==type){
                    //there is a tower here
                    towerHere=true;
                    towers[k]->found=true;
                    
                    //was the tower built up? adjust its size and center position
                    //the image is twice the size of the field, so we need to cut the values in half before scalling them up to game size
                    towers[k]->setNewPos(contourFinder.blobs[i].centroid.x*boardScale, contourFinder.blobs[i].centroid.y*boardScale, size*boardScale);
                }
            }
            
            //if there is no tower currently in this spot, create one
            if (!towerHere){
                if (type=="red"){
                    HitTower * newTower=new HitTower();
                    newTower->setup(contourFinder.blobs[i].centroid.x*boardScale, contourFinder.blobs[i].centroid.y*boardScale, size*boardScale, ++towerID, &bulletPic);
                    newTower->showAllInfo=&showAllInfo;
                    newTower->paused=&paused;
                    newTower->SM= &SM;
                    towers.push_back(newTower);
                }
                if (type=="green"){
                    BombTower * newTower=new BombTower();
                    newTower->setup(contourFinder.blobs[i].centroid.x*boardScale, contourFinder.blobs[i].centroid.y*boardScale, size*boardScale, ++towerID, &bulletPic);
                    newTower->showAllInfo=&showAllInfo;
                    newTower->paused=&paused;
                    newTower->SM= &SM;
                    towers.push_back(newTower);
                }
                if (type=="blue"){
                    FreezeTower * newTower=new FreezeTower();
                    newTower->setup(contourFinder.blobs[i].centroid.x*boardScale, contourFinder.blobs[i].centroid.y*boardScale, size*boardScale, ++towerID, &bulletPic);
                    newTower->showAllInfo=&showAllInfo;
                    newTower->paused=&paused;
                    newTower->SM= &SM;
                    towers.push_back(newTower);
                }
            }
        }
    }
    
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
//    //ignore anything drawn outside of the maze by painting it white
//    for (int x=0; x<fieldW; x++){
//        for (int y=0; y<fieldH; y++){
//            if ( x<mazeLeft || x>mazeRight || y<mazeTop || y>mazeBottom){
//                int pos=y*fieldW+x;
//                wallPixels[pos]=255;
//            }
//        }
//    }
    
    //keep the hole empty
    int hole;//=mazeLeft+ (mazeRight-mazeLeft)/2;
    hole = fieldW/2;
    //top and bottom walls
    for (int i=mazeLeft; i<=mazeRight; i++){
        if(i<hole-5 || i>hole+5 || numEntrances==1){
            int topPos=mazeTop*fieldW+i;
            int bottomPos=mazeBottom*fieldW+i;
            wallPixels[topPos]=0;
            wallPixels[bottomPos]=0;
        }
    }
    
    // top entrance way
    for (int i=0; i<=mazeTop; i++){
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
    for (int i=0; i<=mazeLeft; i++){
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
void testApp::startNextWave(){
    waveComplete=false;
    curWave++;
    if (curWave<waves.size()){
        waves[curWave].start();
    }else{
        cout<<"we're done!"<<endl;
        curWave=waves.size()-1;
        wavesDone=true;
        //unlock hard mode and save the data!
        cout<<"unlock hardmode"<<endl;
        hardModeUnlocked = true;
        //and if they were playing hard mode, mark that they beat it
        if (hardModeActive){
            cout<<"beat hard mode!"<<endl;
            hardModeBeaten=true;
        }
        saveData();
        //show the game complete message
        endWave();  
    }
    
    //check if it is time to increase the number of entrances starting with the 3rd wave
    if (curWave>=4){ //should be 4
        numEntrances=2;
        convertDrawingToGame(); //to account for the new maze border
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
    if (!gameOver)
        SM.playSound("beatWave");
}

//--------------------------------------------------------------
void testApp::spawnFoe(string name, float level){ 
    if (name=="fast"){
        FastFoe * newFoe=new FastFoe;
        newFoe->setPics(fastFoePic[0], fastFoePic[1]);
        foes.push_back(newFoe);
    }
    else if (name=="stealth"){
        StealthFoe * newFoe=new StealthFoe;
        newFoe->setPics(stealthFoePic[0], stealthFoePic[1]);
        foes.push_back(newFoe);
    }
    else if (name=="immune"){
        ImmuneFoe * newFoe=new ImmuneFoe;
        newFoe->setPics(ImmuneFoePic[0], ImmuneFoePic[1]);
        foes.push_back(newFoe);
    }
    else if (name=="heavy"){
        HeavyFoe * newFoe=new HeavyFoe;
        newFoe->setPics(heavyFoePic[0], heavyFoePic[1]);
        foes.push_back(newFoe);
    }
    else {  //assume anything that didn't ahve one of the above names is a normal foe
        NormFoe * newFoe=new NormFoe;
        newFoe->setPics(normFoePic[0], normFoePic[1]);
        //add it to the vector
        foes.push_back(newFoe);
    }
    
    //give the foe all of the info it needs
    int entrance=nextEntrance;
    if (++nextEntrance >= numEntrances) nextEntrance=0;
    foes[foes.size()-1]->setup(startX[entrance], startY[entrance], goalX[entrance], goalY[entrance], fieldScale, fieldW, fieldH,level, retina);
    foes[foes.size()-1]->wallPixels=wallPixels;
    foes[foes.size()-1]->showAllInfo=&showAllInfo;
    foes[foes.size()-1]->paused=&paused;
    //foes[foes.size()-1]->findPath();
    
    //see if they can hop on the existing route
    bool standardRouteOK = false;
    if (!noPath){
        if (foes[foes.size()-1]->horizontalGoal){
            standardRouteOK = foes[foes.size()-1]->checkExistingRoute(routeFromLeftGrid);
        }else
            standardRouteOK = foes[foes.size()-1]->checkExistingRoute(routeFromTopGrid);
    }
    
    //if that doens't work, have the foe find its own path
    if (!standardRouteOK){
        foes[foes.size()-1]->findPath();
        
        //pause the game if this foe can't reach the end
        if (!foes[foes.size()-1]->pathFound){
            noPath=true;
            SM.playSound("error");  //play the sound
        }
    }
    
}

//--------------------------------------------------------------
void testApp::killFoe(int num){
    //spawn an explosion and amke ink if it didn't reach the end
    if (!foes[num]->reachedTheEnd){
        Explosion newExplosion;
        newExplosion.setup(foes[num]->p.pos, &explosionPic);
        explosions.push_back(newExplosion);
        
        //spawn ink particles
        for (int p=0; p<foes[num]->inkVal;p++){
            particle newInkParticle;
            newInkParticle.setInitialCondition(foes[num]->p.pos.x,foes[num]->p.pos.y,ofRandom(-5,5),ofRandom(-5,5));
            newInkParticle.inkValue = 1;
            newInkParticle.col.set(0, 0, 0);
            newInkParticle.inkPic = &inkParticlePic;
            inkParticles.push_back(newInkParticle);
            //add the ink to the player
            totalInk+=newInkParticle.inkValue;
        }

    }
        
        
    //go through and find any towers targetting this foe and remove the target
    for (int i=0; i<towers.size(); i++){
        if (towers[i]->target==foes[num]){
            towers[i]->target=NULL;
        }
    }
    
    delete foes[num]; //dealocate the meory
    foes.erase(foes.begin()+num);
}

//--------------------------------------------------------------
void testApp::takeDamage(int damage){
    health-=damage;
    
    //check if the player is dead
    if (health==0){
        //gray out all towers
        for (int i=0; i<towers.size(); i++){
            towers[i]->playerDead=true;
        }
        //play the lose game sound
        SM.playSound("lose");
        gameOver = true;
    }
    
    //play the sound if the player is still alive
    if (health>0){
        SM.playSound("playerHit");
        //show red for a second if the player is still in the game
        damageFlashTimer=damageFlashTime;
    }
}

//--------------------------------------------------------------
void testApp::saveData(){
    cout<<"saving"<<endl;
    ofstream fout;
    fout.open (ofToDataPath(ofxiPhoneGetDocumentsDirectory()+"playerData.txt").c_str());
    
    fout << SM.muteSoundEffects<<endl;
    fout << SM.muteMusic<<endl;
    fout << forceHowTo<<endl;
    fout << hardModeUnlocked<<endl;
    fout << hardModeBeaten<<endl;
    
    fout.close();
}


//--------------------------------------------------------------
void testApp::loadData(){
    //load in the text file
	ifstream fin;
	fin.open(ofToDataPath(ofxiPhoneGetDocumentsDirectory()+"playerData.txt").c_str());
    
    if (fin==NULL){
        cout<<"no data there"<<endl;
        if (SM.muteMusic){
            SM.toggleMusic();
        }
        saveData();
    }
    else{
        cout<<"load the data in"<<endl;
        
        vector<string> dataStrings;
        
        while (fin!=NULL){
            string full; 
            getline(fin, full); 
            dataStrings.push_back(full);
        }
        
        //make sure there is enough to fill all of the options
        if (dataStrings.size()<5){
            cout<<"NOT ENOUGH DATA"<<endl;
            return;
        }
        
        //set the variables that we need ot remember
        //SM.muteSoundEffects = ofToInt(dataStrings[0]);
        //SM.muteMusic = ofToInt(dataStrings[1]);
        if (SM.muteSoundEffects!=ofToInt(dataStrings[0])){
            SM.toggleSounds();
        }
        if (SM.muteMusic!=ofToInt(dataStrings[1])){
            SM.toggleMusic();
        }
        
        forceHowTo = ofToInt(dataStrings[2]);
        hardModeUnlocked = ofToInt(dataStrings[3]);
        hardModeBeaten = ofToInt(dataStrings[4]);
        cout<<"hard mode unlocked: "<<hardModeUnlocked<<endl;
        cout<<"hard mode beaten: "<<hardModeBeaten<<endl;
    }
	
	
}

//--------------------------------------------------------------
void testApp::loadGameState(){
    
}
//--------------------------------------------------------------
void testApp::saveGameState(){
    cout<<"saving gamestate"<<endl;
    
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
    float waveInfoX=ofGetWidth()*0.895;
    float waveInfoSpacing=ofGetHeight()*0.03;
    float boxWidth=208*(retina+1);
    float boxHeight=150*(retina+1);
    for (int i=0; i<waves.size(); i++){
        WaveInfoBox newInfoBox;
        
        newInfoBox.setup(i+1, waves[i].message, &waveInfoPics[i%3], &infoFont, &infoFontSmall, waves[i].boxColorID, waveInfoX, waveInfoBottom-i*(boxHeight+waveInfoSpacing), boxWidth, boxHeight);
        newInfoBox.alpha=ofMap( waveInfoBottom-newInfoBox.pos.y, 0, waveInfoDistToFadeOut, 255, 0, true);
        waveInfoBoxes.push_back(newInfoBox);
        
    }
}


//--------------------------------------------------------------
void testApp::drawCenteredText(string text, ofTrueTypeFont font, int x, int y){
    int centerX=x-font.stringWidth(text)/2;
    //int centerY=y+font.stringHeight(text)/2;
    font.drawString(text, centerX, y);
}
