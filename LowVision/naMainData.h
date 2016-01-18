//
//  naMainData.h
//  LowVision
//
//  Created by Sen Zeng on 14/12/12.
//  Copyright (c) 2014 naturalsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "naDataProcessing.h"

@interface naMainData : NSObject

@property (nonatomic,strong) NSMutableDictionary *rssAddressDic;//所有可订阅频道{urlArray,topic}

//data.plist
@property (nonatomic,strong) NSMutableDictionary *allTopicNewsDic;//已订阅新闻集合(未排序)

@property (nonatomic,strong) NSMutableDictionary *sortedNewsDic;//排好序的全部新闻

@property (nonatomic,strong) NSMutableDictionary *dailyNewsDic;//某一天的新闻<date,newsArray>

//previousNews.plist
@property (nonatomic,strong) NSMutableDictionary *previousNewsDic;//往期回顾<date,newsArray>
//configuration.plist
@property (nonatomic,strong) NSMutableDictionary *configurationDic;//默认配置信息(userSubscriptionTopic,speaker,rate)

@property (nonatomic,strong) NSMutableDictionary *userSubscriptionTopicDic;//已订阅频道
@property(nonatomic,strong) NSString *ttsSpeaker;
@property (nonatomic) float ttsSpeed;

+(instancetype)shareInstance;

@end
