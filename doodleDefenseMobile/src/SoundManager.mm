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
    
    //loadSound("audio/BOMB","caf", "bomb", 1);
    //loadSound("audio/ENEMYEXPLODES","caf", "enemyDeath", 0.6);
    loadSound("audio/ERROR","caf", "error", 1);
    //loadSound("audio/FREEZE","caf", "freeze", 0.3);
    //loadSound("audio/HIT","caf", "hit", 0.4);
    loadSound("audio/LOSEGAME2","caf", "playerHit", 1);
    //loadSound("audio/SHOT","caf", "shoot5555", 0.6);
    loadSound("audio/TRIUMPH4","caf", "beatWave", 1);
    loadSound("audio/NEWLOSE1","caf", "lose", 1);
    loadSound("audio/STARTGAME","caf", "start", 1);
    loadSound("audio/paper","caf", "paper", 1);
    
    //sounds that need to be able to play more than once at a time
    for (int i=0; i<NUM_DUP_SOUNDS; i++){
        bombSounds[i] = loadSingleSound("audio/BOMB", "caf", 1, false);
        enemyDeathSounds[i] = loadSingleSound("audio/ENEMYEXPLODES", "caf", 0.6, false);
        freezeSounds[i] = loadSingleSound("audio/FREEZE", "caf", 0.3, false);
        hitSounds[i] = loadSingleSound("audio/HIT", "caf", 0.4, false);
        shootSounds[i] = loadSingleSound("audio/SHOT", "caf", 0.6, false);
    }
    
    //game music
    gameMusic = loadSingleSound("audio/DD_THEME_LOOP", "caf", 0.4, true);
    
    muteSoundEffects = false;
    muteMusic = true;
    
    if (!muteMusic)
        [gameMusic play];
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

AVAudioPlayer* SoundManager::loadSingleSound(string fileName, string fileType, float volume, bool loop){
    //load the sound
    AVAudioPlayer *audioPlayer;
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:ofxStringToNSString(fileName) ofType:ofxStringToNSString(fileType)]];
    NSError *error;
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    audioPlayer.volume = volume;
    if (loop)   audioPlayer.numberOfLoops = -1;
    [audioPlayer prepareToPlay];
    return audioPlayer;
}

//plays the specified sound. Returns false if the sound was not found
bool SoundManager::playSound(string refrenceName){
    if (muteSoundEffects)   return false;
    
    if (refrenceName=="bomb"){
        //find the first verison of the file not currently playing
        for (int i=0; i<NUM_DUP_SOUNDS; i++){
            if ( ![bombSounds[i] isPlaying] ){
                [bombSounds[i] play];
                return true; //get out!
            }
        }
        return false;
    }
    
    if (refrenceName=="enemyDeath"){
        //find the first verison of the file not currently playing
        for (int i=0; i<NUM_DUP_SOUNDS; i++){
            if ( ![enemyDeathSounds[i] isPlaying] ){
                [enemyDeathSounds[i] play];
                return true; //get out!
            }
        }
        return false;
    }
    
    if (refrenceName=="freeze"){
        //find the first verison of the file not currently playing
        for (int i=0; i<NUM_DUP_SOUNDS; i++){
            if ( ![freezeSounds[i] isPlaying] ){
                [freezeSounds[i] play];
                return true; //get out!
            }
        }
        return false;
    }
    
    if (refrenceName=="hit"){
        //find the first verison of the file not currently playing
        for (int i=0; i<NUM_DUP_SOUNDS; i++){
            if ( ![hitSounds[i] isPlaying] ){
                [hitSounds[i] play];
                return true; //get out!
            }
        }
        return false;
    }
    
    if (refrenceName=="shoot"){
        //find the first verison of the file not currently playing
        for (int i=0; i<NUM_DUP_SOUNDS; i++){
            if ( ![shootSounds[i] isPlaying] ){
                [shootSounds[i] play];
                return true; //get out!
            }
        }
        return false;
    }
    
    //check the vector of names for the specified sound
    for (int i=0; i<soundNames.size(); i++){
        if (refrenceName==soundNames[i]){
            if ( [sounds[i] isPlaying]){
                sounds[i].currentTime=0;  //rewind it
            }
            [sounds[i] play];
            return true;
        }
    }
    cout<<"BAD SOUND NAME: "<<refrenceName<<endl;
    return false;
}

void SoundManager::toggleSounds(){
    muteSoundEffects = !muteSoundEffects;
    
    //if the sounds were turned off, stop any that are playing
    if (muteSoundEffects){
        for (int i=0; i<soundNames.size(); i++){
            if ( [sounds[i] isPlaying]){
                [sounds[i] stop];
            }
        }
    }
}

void SoundManager::toggleMusic(){
    muteMusic = !muteMusic;
    
    //start or stop the music depending on the choice
    if (!muteMusic){
        [gameMusic play];
    }else{
        [gameMusic pause];
    }
}