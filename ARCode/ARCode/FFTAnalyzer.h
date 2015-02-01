//
//  FFTAnalyzer.h
//  ARCode
//
//  Created by Yu Xuan Liu on 1/31/15.
//  Copyright (c) 2015 wynd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "mo_audio.h" //stuff that helps set up low-level audio
#import "FFTHelper.h"
#import "FFTAnalyzerDelegate.h"


#define SAMPLE_RATE 44100  //22050 //44100
#define FRAMESIZE  512
#define NUMCHANNELS 2

#define kOutputBus 0
#define kInputBus 1


@interface FFTAnalyzer : NSObject

-(id)initWithDelegate:(id<FFTAnalyzerDelegate>)del;
-(void)initMomuAudio;
-(void)setup;
-(void)pause;
-(void)start;

@end
