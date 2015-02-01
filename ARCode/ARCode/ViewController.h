//
//  ViewController.h
//  ARCode
//
//  Created by Yu Xuan Liu on 1/31/15.
//  Copyright (c) 2015 wynd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FFTAnalyzerDelegate.h"

@class FFTAnalyzer;

@interface ViewController : UIViewController<FFTAnalyzerDelegate>{
    bool started, foundlen, startmsg;
    float startf, maxf, lastf, maxlen;
    int startcount, startnotcount, lencount, lennotcount, lastcount, lastnotcount, minlen, datatype;
    NSMutableArray *ar, *data;
}

-(void)enterBackground;
-(void)enterForeground;
-(void)clearAr;
-(void)receivedMsg:(float)freq;

@property(nonatomic, strong) FFTAnalyzer *analyzer;

@end

