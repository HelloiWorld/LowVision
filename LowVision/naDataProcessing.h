//
//  naDataProcessing.h
//  LowVision
//
//  Created by Sen Zeng on 14/12/12.
//  Copyright (c) 2014年 naturalsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface naDataProcessing : NSObject

+(instancetype)shareInstance;

#pragma mark - handle content
-(NSArray *)sortedDateKey;
-(NSString *)stringFromDate:(NSDate *)date;
-(NSDate *)dateFromString:(NSString *)string;
-(NSString *)stringFromString:(NSString *)string;
//-(NSDate *)getCompareDate:(NSString *)dayString today:(BOOL)isToday;
-(NSDate *)getCompareDate:(NSString *)dayString;
-(NSDate *)getLatestDate;
//解析完成后获取的新闻按时间排序
-(NSDictionary *)sortByDate:(NSDictionary *)allNews;
//获取某一天的新闻集合
-(NSArray *)getDailyNews:(NSDate *)date;

#pragma mark - handle SubscriptionTopic
-(NSArray *)getUnsubscriptionTopic:(NSArray *)topic;
-(void)deleteSubscriptionTopic:(NSArray *)topic;
-(NSArray *)selectSubscriptionTopic:(NSString *)topic;

-(void)addSubscriptionTopic:(NSArray *)topic;

-(void)refreshTopicNews:(NSArray *)topic;

#pragma mark - savaData
-(void)saveData;

#pragma mark - TTS
-(void)changeSpeaker:(NSString *)speaker;
-(void)changeSpeed:(float) rate;
//-(NSString*)parseLinkToGetContent:(NSInteger)index link:(NSArray*)links;
-(NSString*)parseLinkToGetContent:(NSString *)link;
-(void)saveTTSContent:(NSString *)link withDate:(NSString *)date andContent:(NSString *)content;
-(void)ttsPlay:(NSString*)content;
-(void)ttsPause;
-(void)ttsStop;
-(void)ttsResume;
-(BOOL)ttsDidStop;

#pragma mark - Audio
-(void)audioPlay;
-(void)audioStop;

@end
