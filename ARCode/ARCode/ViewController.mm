//
//  ViewController.m
//  ARCode
//
//  Created by Yu Xuan Liu on 1/31/15.
//  Copyright (c) 2015 wynd. All rights reserved.
//
#import "ViewController.h"
#import "FFTAnalyzer.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.analyzer = [[FFTAnalyzer alloc] initWithDelegate:self];
    [self.analyzer setup];
}

-(void)enterBackground{
    //NSLog(@"Enter back");
}

-(void)enterForeground{
    //NSLog(@"enter Fore");
}

-(void)didReceiveFreq:(float)freq{
    NSLog(@"%.2f", freq);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end