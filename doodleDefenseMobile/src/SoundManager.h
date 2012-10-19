//
//  SoundManager.h
//  ofxKinectExample
//
//  Created by Andy Wallace on 4/13/12.
//  Copyright (c) 2012 AndyMakes. All rights reserved.
//

#ifndef ofxKinectExample_SoundManager_h
#define ofxKinectExample_SoundManager_h

#import <AVFoundation/AVFoundation.h>
#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"

class SoundManager{
public:

    void setup();
    void loadSound(string fileName, string fileType, string refrenceName, float volume);
    AVAudioPlayer* loadSingleSound(string fileName, string fileType, float volume, bool loop);
    bool playSound(string refrenceName);
    
//    void startPlayingMarkerSound();
//    void updateMarkerSound();
//    void stopPlayingMarkerSound();
    
    void toggleSounds();
    void toggleMusic();
    
    vector<string>        soundNames;
    vector<AVAudioPlayer*> sounds;
    
    AVAudioPlayer* gameMusic;
    
    //some sound effects need to be able to play more than once
    #define NUM_DUP_SOUNDS 5
    AVAudioPlayer* bombSounds[NUM_DUP_SOUNDS];
    AVAudioPlayer* enemyDeathSounds[NUM_DUP_SOUNDS];
    AVAudioPlayer* freezeSounds[NUM_DUP_SOUNDS];
    AVAudioPlayer* hitSounds[NUM_DUP_SOUNDS];
    AVAudioPlayer* shootSounds[NUM_DUP_SOUNDS];
    
    //drawing sounds
//    AVAudioPlayer* markerStartSound;
//    AVAudioPlayer* markerLoop;
//    bool playingMarkerStartSound;
    
    bool muteSoundEffects;
    bool muteMusic;
    
   
    
};



#endif
