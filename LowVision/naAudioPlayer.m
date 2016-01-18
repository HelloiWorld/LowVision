//
//  naAudioPlayer.m
//  LowVision
//
//  Created by Sen Zeng on 14/12/15.
//  Copyright (c) 2014年 naturalsoft. All rights reserved.
//

#import "naAudioPlayer.h"

@implementation naAudioPlayer

-(id)init{
    self=[super init];
    return self;
}

-(AVAudioPlayer *)player{
    if (_player==nil) {
        _player=[[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle]pathForResource:@"music" ofType:@"mp3"]] error:nil];
        _player.delegate=self;
    }
    return _player;
}

-(void)play:(NSString *)path{
    NSURL *url=[NSURL fileURLWithPath:path];
//    NSData  *data =[NSData dataWithContentsOfFile:path];
    self.player=[[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
//    self.player=[[AVAudioPlayer alloc] initWithData:data error:nil];
    self.player.volume=1.0;
    self.player.currentTime=8.0;
    _player.numberOfLoops=0;
    self.player.delegate=self;
    [self.player prepareToPlay];
    [self.player play];
}

-(void)stop{
    _player.currentTime=8.0;
    [_player stop];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"musicfinishNotification" object:nil];
    NSLog(@"audio finish");
}


@end
