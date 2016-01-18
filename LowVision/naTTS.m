//
//  naTTS.m
//  LowVision
//
//  Created by Sen Zeng on 14/12/15.
//  Copyright (c) 2014年 naturalsoft. All rights reserved.
//

#import "naTTS.h"

@implementation naTTS

static naTTS *instance = nil;
+(instancetype)shareInstance
{
    if(instance == nil)
    {
        instance = [[[self class]alloc]init];  //super 调用allocWithZone
    }
    return instance;
}

-(AVSpeechSynthesizer *)synthesizer{
    if (!_synthesizer) {
        _synthesizer=[[AVSpeechSynthesizer alloc] init];
        _synthesizer.delegate=self;
    }
    return _synthesizer;
}



-(id)init{
    if (self=[super init]) {
        if (!_languageDic) {
            _languageDic=[NSMutableDictionary dictionaryWithObjectsAndKeys:@"zh-CN",@"Chinese(China)",@"zh-HK",@"Chinese(Hong Kong)",@"zh-TW",@"Chinese(Taiwan)",@"en-US",@"English(United States)",@"en-GB",@"English(United Kingdom)", nil];
        }
    }
    return self;
}


-(void)play:(NSString *)content{
    AVSpeechUtterance *utterance=[[AVSpeechUtterance alloc] initWithString:content];
    AVSpeechSynthesisVoice *voice=[AVSpeechSynthesisVoice voiceWithLanguage:[_languageDic objectForKey:[naMainData shareInstance].ttsSpeaker]];
    
    utterance.voice=voice;
    
    float adjustedRate = AVSpeechUtteranceMaximumSpeechRate*[naMainData shareInstance].ttsSpeed;
    if (adjustedRate > AVSpeechUtteranceMaximumSpeechRate) {
        adjustedRate=AVSpeechUtteranceMaximumSpeechRate;
    }
    
    if (adjustedRate < AVSpeechUtteranceMinimumSpeechRate) {
        adjustedRate=AVSpeechUtteranceMinimumSpeechRate;
    }
    
    utterance.rate=adjustedRate;
    
    float pitchMultiplier=1.0;
    if ((pitchMultiplier>=0.5)&&(pitchMultiplier<=2.0)) {
        utterance.pitchMultiplier=pitchMultiplier;
    }
    NSLog(@"ttsContent %@",content);
    [self.synthesizer speakUtterance:utterance];
}

-(void)resume{
    if (self.synthesizer.isPaused) {
        [self.synthesizer continueSpeaking];
    }
}

-(void)pause{
    [self.synthesizer pauseSpeakingAtBoundary:AVSpeechBoundaryImmediate];
}

-(void)stop{
    BOOL speechStopped =  [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];

    if(speechStopped){
        self.synthesizer=nil;
    }
}

-(void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance{
    NSLog(@"tts finished!");
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ttsfinishNotification" object:nil];
}

@end
