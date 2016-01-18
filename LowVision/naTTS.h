//
//  naTTS.h
//  LowVision
//
//  Created by Sen Zeng on 14/12/15.
//  Copyright (c) 2014年 naturalsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "naMainData.h"

@interface naTTS : NSObject<AVSpeechSynthesizerDelegate>

@property (strong,nonatomic) AVSpeechSynthesizer *synthesizer;

@property(nonatomic,strong) NSDictionary *languageDic;


+(instancetype)shareInstance;

-(void)play:(NSString *)content;
-(void)pause;
-(void)stop;
-(void)resume;
@end
