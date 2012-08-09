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
    bool playSound(string refrenceName);
    
    vector<string>        soundNames;
    vector<AVAudioPlayer*> sounds;
    
    bool muteSoundEffects;
    
};



#endif
