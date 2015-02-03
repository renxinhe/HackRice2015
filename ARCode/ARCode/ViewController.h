//
//  ViewController.h
//  ARCode
//
//  Created by Yu Xuan Liu on 1/31/15.
//  Copyright (c) 2015 wynd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFTAnalyzerDelegate.h"
#import <AudioToolbox/AudioToolbox.h>

@class FFTAnalyzer;

@interface ViewController : UIViewController<FFTAnalyzerDelegate>{
    bool started, foundlen, startmsg;
    float startf, maxf, lastf;
    int startcount, startnotcount, lencount, lennotcount, lastcount, lastnotcount, minlen, datatype, maxlen, textlen;
    NSMutableArray *ar, *data;
    double time, prevf;
}

-(void)enterBackground;
-(void)enterForeground;
-(void)clearAr;
-(void)receivedMsg:(float)freq;
-(void)didFinish;

@property(nonatomic, strong) FFTAnalyzer *analyzer;
@property(nonatomic, weak) IBOutlet UIImageView *circle1;
@property(nonatomic, weak) IBOutlet UIImageView *circle2;
@property(nonatomic, weak) IBOutlet UIImageView *circle3;
@property(nonatomic, weak) IBOutlet UIImageView *bar1;
@property(nonatomic, weak) IBOutlet UIImageView *bar2;
@property(nonatomic, weak) IBOutlet UIImageView *bar3;
@property(nonatomic, weak) IBOutlet UIImageView *bar4;
@property(nonatomic, weak) IBOutlet UIImageView *picture;
@property(nonatomic, weak) IBOutlet UIButton *btn;

-(IBAction)close:(id)sender;
-(IBAction)send:(id)sender;
-(IBAction)record:(id)sender;
-(void)playSound:(NSString*) sound;
@end

