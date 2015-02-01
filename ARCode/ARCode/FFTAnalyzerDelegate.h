//
//  FFTAnalyzerProtocol.h
//  ARCode
//
//  Created by Yu Xuan Liu on 1/31/15.
//  Copyright (c) 2015 wynd. All rights reserved.
//

#ifndef ARCode_FFTAnalyzerProtocol_h
#define ARCode_FFTAnalyzerProtocol_h

@protocol FFTAnalyzerDelegate
-(void)didReceiveFreq:(float)freq;
@end

#endif
