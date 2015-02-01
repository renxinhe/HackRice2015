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

@interface ViewController : UIViewController<FFTAnalyzerDelegate>

-(void)enterBackground;
-(void)enterForeground;

@property(nonatomic, strong) FFTAnalyzer *analyzer;

@end

