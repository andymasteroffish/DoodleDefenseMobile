//
//  SoundManager.cpp
//  ofxKinectExample
//
//  Created by Andy Wallace on 4/13/12.
//  Copyright (c) 2012 AndyMakes. All rights reserved.
//

#include "SoundManager.h"


void SoundManager::setup(){
    sounds.clear();
    soundNames.clear();
    
    loadSound("audio/BOMB","wav", "bomb", 1);
    loadSound("audio/ENEMYEXPLODES","wav", "enemyDeath", 0.6);
    loadSound("audio/ERROR","wav", "error", 1);
    loadSound("audio/FREEZE","wav", "freeze", 0.3);
    loadSound("audio/HIT","wav", "hit", 0.4);
    loadSound("audio/LOSEGAME2","wav", "playerHit", 1);
    loadSound("audio/SHOT","wav", "shoot", 0.6);
    loadSound("audio/TRIUMPH4","wav", "beatWave", 1);
    loadSound("audio/NEWLOSE1","wav", "lose", 1);
    loadSound("audio/STARTGAME","wav", "start", 1);
    
    muteSoundEffects = false;
}

//adds an external file to the vector of sound effects
void SoundManager::loadSound(string fileName, string fileType, string refrenceName, float volume){
    //load the sound
    AVAudioPlayer *audioPlayer1;
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:ofxStringToNSString(fileName) ofType:ofxStringToNSString(fileType)]];
    NSError *error;
    audioPlayer1 = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [audioPlayer1 setVolume:volume];
    //[audioPlayer1 setEnableRate:YES];  //only works in iOS5 and above! TOO BAD IT'S NOT WORKING AT ALL
    [audioPlayer1 prepareToPlay];
    //add the sound and names to the vector
    sounds.push_back(audioPlayer1);
    soundNames.push_back(refrenceName);
}

//plays the specified sound. Returns false if the sound was not found
bool SoundManager::playSound(string refrenceName){
    if (muteSoundEffects)   return false;
    
    //check the vector of names for the specified sound
    for (int i=0; i<soundNames.size(); i++){
        if (refrenceName==soundNames[i]){
            if ( [sounds[i] isPlaying]){
                return true;    //TESTING
                sounds[i].currentTime=0;  //rewind it
            }
            [sounds[i] play];
            return true;
        }
    }
    cout<<"BAD SOUND NAME: "<<refrenceName<<endl;
    return false;
}