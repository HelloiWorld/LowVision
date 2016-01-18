//
//  naAudioPlayer.h
//  LowVision
//
//  Created by Sen Zeng on 14/12/15.
//  Copyright (c) 2014年 naturalsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface naAudioPlayer : NSObject<AVAudioPlayerDelegate,AVAudioSessionDelegate>

@property (strong,nonatomic) AVAudioPlayer *player;

-(void)play:(NSString *)path;

-(void)stop;

@end
