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
    [NSTimer scheduledTimerWithTimeInterval:1/60.0
                                     target:self
                                   selector:@selector(animate)
                                   userInfo:nil
                                    repeats:YES];
    self.btn.alpha = 0;
}

-(void)animate{
    time += 1/60.0;
    double trans1 = sin(time * 2 * M_PI / 2) * 0.05 + 0.005 * (rand()%3) + 0.9;
    self.circle1.transform = CGAffineTransformScale(CGAffineTransformIdentity, trans1, trans1);
    double trans2 = sin(time * 2 * M_PI * 2) * 0.05 + 0.1* prevf/600.0 + 0.005 * (rand()%7) + 0.9;
    self.circle2.transform = CGAffineTransformScale(CGAffineTransformIdentity, trans2, trans2);
    double trans3 = sin(time * 2 * M_PI * 3.17) * 0.05 + 0.2* prevf/600.0 + 0.005 * (rand()%7) + 0.9;
    self.circle3.transform = CGAffineTransformScale(CGAffineTransformIdentity, trans3, trans3);
    time = fmod(time, (8*M_PI));
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
    prevf = freq;
    //NSLog(@"f%.2f",freq);
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
                animateFade(self.bar1, 1.0);
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
                animateFade(self.bar2, 1.0);
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
                animateFade(self.bar3, 1.0);
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
                [self didFinish];
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
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Message" message:str delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
            });
            animateFade(self.bar4, 1.0);
        }
    }
}

-(void)didFinish{
    if (datatype == LINK) {
        NSMutableString *str = [[NSMutableString alloc] init];
        for(int i = 3; i < (int)data.count; i++){
            long a = [[data objectAtIndex:i] integerValue];
            [str appendString:[NSString stringWithFormat:@"%lx", a]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *udata = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:[@"http://arcodez.azurewebsites.net/?data=" stringByAppendingString:str]] encoding:NSUTF8StringEncoding error:nil];
            if(udata){
                //[[[UIAlertView alloc] initWithTitle:@"URL" message:udata delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:udata]];
            }
            NSLog(@"%@ %@",str, udata);
        });
        animateFade(self.bar4, 1.0);
    }
    if(datatype == PIC){
        NSMutableString *str = [[NSMutableString alloc] init];
        for(int i = 3; i < (int)data.count; i++){
            long a = [[data objectAtIndex:i] integerValue];
            [str appendString:[NSString stringWithFormat:@"%lx", a]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *udata = [[NSString alloc] initWithContentsOfURL:[NSURL URLWithString:[@"http://arcodez.azurewebsites.net/?data=" stringByAppendingString:str]] encoding:NSUTF8StringEncoding error:nil];
            if(udata){
                //[[[UIAlertView alloc] initWithTitle:@"URL" message:udata delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
                self.picture.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:udata]]];
                self.btn.alpha = 1;
            }
            NSLog(@"%@ %@",str, udata);
        });
        animateFade(self.bar4, 1.0);
    }
}

-(IBAction)close:(id)sender{
    self.picture.image = nil;
    self.btn.alpha = 0;
}

void animateFade(UIImageView *img, double alpha){
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.25 animations:^{
            img.alpha = alpha;
        }];
    });
}

-(IBAction)send:(id)sender{
    
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"Send ARCode" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *destructiveAction = [UIAlertAction actionWithTitle:@"Google" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self playSound:@"google"];
    }];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"HackRice" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self playSound:@"hackrice"];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cat" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self playSound:@"cat"];
    }];
    
    [actionSheet addAction:destructiveAction];
    [actionSheet addAction:defaultAction];
    [actionSheet addAction:cancelAction];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Hello World" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self playSound:@"helloworld"];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Dog" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self playSound:@"doge"];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Leaked Baker 13 footage" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self playSound:@"rickroll"];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
    
}

-(void)playSound:(NSString*) sound{
    [self.analyzer pause];
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:sound ofType:@"wav"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    AudioServicesPlaySystemSound (soundID);
    AudioServicesAddSystemSoundCompletion (
                                           soundID,
                                           NULL,
                                           NULL,
                                           endSound,
                                           NULL
                                           );
}


-(IBAction)record:(id)sender{
    [self.analyzer start];
}

void endSound (
               SystemSoundID  ssID,
               void           *clientData
               )
{
    NSLog(@"Complete");
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
    animateFade(self.bar1, 0.0);
    animateFade(self.bar2, 0.0);
    animateFade(self.bar3, 0.0);
    animateFade(self.bar4, 0.0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end