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
    [self clearAr];
    [self.analyzer setup];
}

-(void)enterBackground{
    //NSLog(@"Enter back");
}

-(void)enterForeground{
    //NSLog(@"enter Fore");
}
#define MAXLEN 500
#define MINLEN 3
#define BITS 16
#define TEXT 4
#define LINK 7
#define PIC 10

static inline bool eq(double a, double b){
    return fabs(a-b) < 13;
}

static float getLastFreq(NSMutableArray *ar, int * count, float neq, int length){
    int last = (int)ar.count-1;
    float f = [[ar objectAtIndex:last] floatValue];
    int ct = 0;
    for(int x = last-1; x>=last-length; x--){
        if(eq(f, [[ar objectAtIndex:x] floatValue]) && !eq(f, neq))
            ct++;
    }
    *count = ct;
    return f;
}


-(void)didReceiveFreq:(float)freq{
    NSLog(@"WTF: %.2f %d", freq, ar.count);
    [ar addObject:[NSNumber numberWithFloat:freq]];
    if(!started) {
        if (ar.count > MINLEN) {
            int ct = 0;
            float f = getLastFreq(ar, &ct, -1, MINLEN*2);
            if( ct >= MINLEN*2 - 1) {
                started = true;
                startf = f;
                startcount = ct;
                startnotcount = 0;
                NSLog(@"Start %.2f", startf);
            }
        }
    } else if(!foundlen) {
        if (ar.count > MINLEN) {
            int ct = 0;
            float f = getLastFreq(ar, &ct, startf, MINLEN);
            if(!eq(freq, startf)){
                startnotcount++;
            }else{
                startcount++;
            }
            if( startnotcount > 1.5 * startcount){
                [self clearAr];
            }
            if( ct >= MINLEN - 1) {
                foundlen = true;
                maxf = f;
                lencount = ct;
                lennotcount = 0;
                NSLog(@"End %.2f", maxf);
            }
        }
    }else if(!startmsg){
        if (ar.count > MINLEN) {
            int ct = 0;
            float f = getLastFreq(ar, &ct, maxf, MINLEN);
            if(eq(freq, maxf)){
                lencount++;
            }else{
                lennotcount++;
            }
            if(lennotcount > 2 * lencount) {
                [self clearAr];
            }
            if( ct >= MINLEN - 1) {
                startmsg = true;
                lastf = f;
                lastcount = ct;
                lastnotcount = 0;
                minlen = (int)(lencount * 0.33/2);
                maxlen = (int)(lencount * 0.66/2);
                NSLog(@"%.2f %.2f %d %d %d L: %d %d  S: %d %d", startf, maxf, minlen, maxlen, (int)(lencount * 0.33/2), lencount, lennotcount, startcount, startnotcount);
            }
        }
    }else{
        if (ar.count > minlen) {
            int ct = 0;
            float f = getLastFreq(ar, &ct, lastf, minlen);
            if(eq(freq, lastf)){
                lastcount++;
            }else{
                lastnotcount++;
            }
            if(lastcount >= maxlen){
                [self receivedMsg:lastf];
                lastcount = 1;//(int)(lencount * 0.25/2);
                lastnotcount = 0;
            }
            if((lastnotcount > 2 * lastcount  && lastcount > minlen * 1.5) || lastnotcount > maxlen) {
                [self receivedMsg:lastf];
                [self clearAr];
            }
            if( ct >= minlen) {
                [self receivedMsg:lastf];
                lastf = f;
                lastcount = ct;
                lastnotcount = 0;
            }
        }
    }
    //NSLog(@"%@ %.2f", ar, freq);
    //NSLog(@"%.2f %.2f %d L: %d %d  S: %d %d", startf, maxf, minlen, lencount, lennotcount, startcount, startnotcount);
    while(ar.count > MAXLEN) {
        [ar removeObjectAtIndex:0];
    }
}
-(void)receivedMsg:(float)freq{
    double minn = 1e99;
    int best = -1;
    double diff = (maxf - startf) / (BITS - 1);
    if( freq < startf - 2 * diff || freq > maxf + 2*diff){
        [self clearAr];
        return;
    }
    for(int i = 0; i<BITS; i++) {
        double x = startf + diff * i;
        double d = abs(x - freq);
        if( d < minn) {
            minn = d;
            best = i;
        }
    }
    NSLog(@"%.2f %.2f %d", freq, startf + diff * best, best);
    if(data.count == 0) {
        if( best != 0 ){
            [self clearAr];
            return;
        }
    }
    if( data.count == 1) {
        int types[3] = {TEXT, LINK, PIC};
        int minn = 99999, min = -1;
        for(int i = 0; i<3; i++){
            int d = abs(types[i] - best);
            if( d < minn) {
                minn = d;
                min = types[i];
            }
        }
        datatype = min;
        NSLog(@"%d", datatype);
    }
    [data addObject:[NSNumber numberWithInt:best]];
    if( datatype == TEXT) {
        if( data.count == 4) {
            long a = [[data objectAtIndex:2] integerValue];
            long b = [[data objectAtIndex:3] integerValue];
            textlen = (int)(a | (b<<4));
            NSLog(@"len: %d", textlen);
        }
        if( ((int)data.count - 4) == textlen * 2) {
            NSMutableString *str = [[NSMutableString alloc] init];
            for(int i = 4; i < (int)data.count; i+=2){
                long a = [[data objectAtIndex:i] integerValue];
                long b = [[data objectAtIndex:i+1] integerValue];
                [str appendString:[NSString stringWithFormat:@"%c", (int)(a | (b<<4))]];
            }
            NSLog(@"%@",str);
        }
    }
}

-(void)clearAr{
    ar = [NSMutableArray array];
    data = [NSMutableArray array];
    started = false;
    foundlen = false;
    startmsg = false;
    startf = 0.0;
    maxf = 0.0;
    startcount = 0;
    startnotcount = 0;
    lencount = 0;
    lennotcount = 0;
    lastcount = 0;
    lastnotcount = 0;
    lastf = 0.0;
    datatype = 0;
    maxlen = 0.0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end