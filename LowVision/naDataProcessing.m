//
//  naDataProcessing.m
//  LowVision
//
//  Created by Sen Zeng on 14/12/12.
//  Copyright (c) 2014年 naturalsoft. All rights reserved.
//

#import "naDataProcessing.h"
#import "naMainData.h"
#import "naXMLParser.h"
#import "naHTMLParser.h"
#import "naTTS.h"
#import "naAudioPlayer.h"

static naDataProcessing *data=nil;

@implementation naDataProcessing{
    NSInteger tapNum;
    naAudioPlayer *player;
}

+(instancetype)shareInstance{
    if (data==nil) {
        data=[[[self class]alloc]init];
    }
    return data;
}

#pragma mark - handle content
-(NSArray *)sortedDateKey{
    NSDateFormatter *format=[[NSDateFormatter alloc]init];
    [format setTimeZone:[NSTimeZone systemTimeZone]];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSString *dateKey=[format stringFromDate:[self getCompareDate:@"today"]];
    NSDate *today=[format dateFromString:dateKey];
    for (int i=1; i<5; i++) {
        NSDate *tmpDate=[[NSDate alloc]initWithTimeInterval:(-i*60*60*24) sinceDate:today];
        dateKey=[format stringFromDate:tmpDate];
        NSMutableArray *tmpArticles=[[NSMutableArray alloc] initWithArray:[self getDailyNews:tmpDate]];
        if (tmpArticles.count!=0) {
            [[naMainData shareInstance].previousNewsDic setObject:tmpArticles forKey:dateKey];
        }
    }
    NSMutableArray *tmpKeys=[[NSMutableArray alloc] initWithArray:[[naMainData shareInstance].previousNewsDic allKeys]];
    NSMutableArray *tmpdates=[[NSMutableArray alloc] init];
    NSMutableArray *keys=[[NSMutableArray alloc] init];
    for ( NSString *key in tmpKeys) {
        NSDate *date=[format dateFromString:key];
        [tmpdates addObject:date];
    }
    [tmpdates sortUsingComparator:^NSComparisonResult(id obj1,id obj2){
        NSDate *date1=obj1;
        NSDate *date2=obj2;
        NSComparisonResult result=[date1 compare:date2];
        if(result==NSOrderedDescending){
            return NSOrderedAscending;
        }else if(result==NSOrderedAscending){
            return NSOrderedDescending;
        }else{
            return NSOrderedSame;
        }
    }];
    for (int i=0; i<tmpdates.count; i++) {
        NSString *dateKey=[format stringFromDate:[tmpdates objectAtIndex:i]];
        [keys addObject:dateKey];
    }
    return keys;
}

-(NSDate *)getLatestDate{
    NSDate *latestDate;
    NSDateFormatter *format=[[NSDateFormatter alloc]init];
    [format setTimeZone:[NSTimeZone systemTimeZone]];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSArray *tmpKeys=[[NSArray alloc] initWithArray:[[naMainData shareInstance].previousNewsDic allKeys]];
    if (tmpKeys.count>1) {
        NSMutableArray *tmpDates=[[NSMutableArray alloc] init];
        for ( NSString *key in tmpKeys) {
            NSDate *date=[format dateFromString:key];
            [tmpDates addObject:date];
        }
        [tmpDates sortUsingComparator:^NSComparisonResult(id obj1,id obj2){
            NSDate *date1=obj1;
            NSDate *date2=obj2;
            NSComparisonResult result=[date1 compare:date2];
            if(result==NSOrderedDescending){
                return NSOrderedAscending;
            }else if(result==NSOrderedAscending){
                return NSOrderedDescending;
            }else{
                return NSOrderedSame;
            }
        }];
        latestDate=[tmpDates objectAtIndex:0];
    }else if(tmpKeys.count==1){
        latestDate=[format dateFromString:[tmpKeys objectAtIndex:0]];
    }else{
        latestDate=[NSDate date];
    }
    return  latestDate;
}

-(NSDate *)getCompareDate:(NSString *)dayString{
    NSDate *current=[[NSDate alloc] initWithTimeIntervalSinceNow:0];
    NSDateFormatter *format=[[NSDateFormatter alloc]init];
    [format setDateFormat:@"yyyy-MM-dd"];
    [format setTimeZone:[NSTimeZone systemTimeZone]];
    NSString *day;
    if ([dayString isEqualToString:@"today"]) {
        day=[format stringFromDate:current];
    }else{
        day=dayString;
    }
    NSDate *compareDate=[format dateFromString:day];
    return compareDate;
}

-(NSString *)stringFromDate:(NSDate *)date{
    NSDateFormatter *format=[[NSDateFormatter alloc]init];
    [format setTimeZone:[NSTimeZone systemTimeZone]];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString=[format stringFromDate:date];
    return dateString;
}

-(NSDate *)dateFromString:(NSString *)string{
    NSDateFormatter *format=[[NSDateFormatter alloc]init];
    [format setTimeZone:[NSTimeZone systemTimeZone]];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    NSDate *date=[format dateFromString:string];
    return date;
}

-(NSString *)stringFromString:(NSString *)string{
     NSDate *date;
    NSDateFormatter *format=[[NSDateFormatter alloc]init];
    [format setTimeZone:[NSTimeZone systemTimeZone]];
    int i=[string characterAtIndex:0];
    if( i > 0x4e00 && i < 0x9fff){
        format.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        [format setDateFormat:@"EEEE, dd MM yyyy HH:mm:ss Z"];
        date=[format dateFromString:string];
    }else{
        format.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [format setDateFormat:@"EE, dd MM yyyy HH:mm:ss Z"];
        date=[format dateFromString:string];
        if (date==nil) {
            [format setDateFormat:@"EE, dd MM yyyy HH:mm:ss"];
            date=[format dateFromString:string];
        }
    }
    if (date==nil) {
        return string;
    }else{
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *finalString=[format stringFromDate:date];
    return finalString;
    }
}

//解析完成后获取的新闻按时间排序
-(NSDictionary *)sortByDate:(NSDictionary *)allNews{
    NSMutableArray *unorderedPubDate=[[NSMutableArray alloc]init];
    NSMutableArray *unorderedTitle=[[NSMutableArray alloc]init];
    NSMutableArray *unorderedSource=[[NSMutableArray alloc]init];
    NSMutableArray *unorderedLink=[[NSMutableArray alloc]init];
    NSMutableArray *orderedPubDate=[[NSMutableArray alloc]init];
    NSMutableArray *orderedTitle=[[NSMutableArray alloc]init];
    NSMutableArray *orderedLink=[[NSMutableArray alloc]init];
    NSMutableArray *orderedSource=[[NSMutableArray alloc]init];
    NSMutableArray *tmpDates=[[NSMutableArray alloc]init];

    for (NSString *tmpKey in allNews) {
        NSArray *tmpTopic=[allNews objectForKey:tmpKey];
        for (NSMutableDictionary *tmpArticle in tmpTopic) {
            [unorderedPubDate addObject:[tmpArticle objectForKey:@"pubDate"]];
            [unorderedTitle addObject:[tmpArticle objectForKey:@"title"]];
            [unorderedSource addObject:[tmpArticle objectForKey:@"source"]];
            [unorderedLink addObject:[tmpArticle objectForKey:@"link"]];
        }
    }

    NSMutableArray *dates=[[NSMutableArray alloc]init];
    for (NSString *dateString in unorderedPubDate) {
        [dates addObject:[self dateFromString:dateString]];
    }
    [dates sortUsingComparator:^NSComparisonResult(id obj1,id obj2){
        NSDate *date1=obj1;
        NSDate *date2=obj2;
        NSComparisonResult result=[date1 compare:date2];
        if(result==NSOrderedDescending){
            return NSOrderedAscending;
        }else if(result==NSOrderedAscending){
            return NSOrderedDescending;
        }else{
            return NSOrderedSame;
        }
    }];
    for (NSDate *tmpDate in dates) {
        NSString *dateToString=[self stringFromDate:tmpDate];
        for (int i=0; i<unorderedPubDate.count; i++) {
            if ([dateToString isEqualToString:[unorderedPubDate objectAtIndex:i]]) {
                if (![orderedTitle containsObject:[unorderedTitle objectAtIndex:i]]) {
                    [orderedPubDate addObject:dateToString];
                    [orderedTitle addObject:[unorderedTitle objectAtIndex:i]];
                    [orderedSource addObject:[unorderedSource objectAtIndex:i]];
                    [orderedLink addObject:[unorderedLink objectAtIndex:i]];
                    [tmpDates addObject:tmpDate];
                }
            }
        }
    }
    NSMutableDictionary *sortedNews=[[NSMutableDictionary alloc]initWithObjectsAndKeys:tmpDates,@"tmpDates",orderedPubDate,@"pubDate",orderedTitle,@"title",orderedLink,@"link",orderedSource,@"source",nil];
    
    return sortedNews;
}

//获取某一天的新闻集合
-(NSArray *)getDailyNews:(NSDate *)date{
    NSArray *result;
    
    NSDateFormatter *format=[[NSDateFormatter alloc]init];
    [format setTimeZone:[NSTimeZone systemTimeZone]];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSString *dateKey=[format stringFromDate:date];

    NSMutableArray *newsFromDate=[[NSMutableArray alloc] init];
    NSDate *foreTime=[[NSDate alloc]initWithTimeInterval:0 sinceDate:date];
    NSDate *aftTime=[[NSDate alloc]initWithTimeInterval:60*60*24 sinceDate:date];
    NSMutableArray *tmpDates=[[NSMutableArray alloc]initWithArray:[[naMainData shareInstance].sortedNewsDic objectForKey:@"tmpDates"]];
    NSMutableArray *orderedPubDate=[[NSMutableArray alloc]initWithArray:[[naMainData shareInstance].sortedNewsDic objectForKey:@"pubDate"]];
    NSMutableArray *orderedTitle=[[NSMutableArray alloc]initWithArray:[[naMainData shareInstance].sortedNewsDic objectForKey:@"title"]];
    NSMutableArray *orderedLink=[[NSMutableArray alloc]initWithArray:[[naMainData shareInstance].sortedNewsDic objectForKey:@"link"]];
    NSMutableArray *orderedSource=[[NSMutableArray alloc]initWithArray:[[naMainData shareInstance].sortedNewsDic objectForKey:@"source"]];
    
    for (int i=0;i<tmpDates.count;i++) {
        NSDate *tmpDate=[[NSDate alloc]initWithTimeInterval:0 sinceDate:[tmpDates objectAtIndex:i]];
        NSComparisonResult resultFore=[tmpDate compare:foreTime];
        NSComparisonResult resultAft=[tmpDate compare:aftTime];
        if (resultAft==-1&&resultFore==1) {
            NSMutableDictionary *article=[[NSMutableDictionary alloc]init];
            [article setObject:[orderedPubDate objectAtIndex:i] forKey:@"pubDate"];
            [article setObject:[orderedTitle objectAtIndex:i] forKey:@"title"];
            [article setObject:[orderedLink objectAtIndex:i] forKey:@"link"];
            [article setObject:[orderedSource objectAtIndex:i] forKey:@"source"];
            [newsFromDate addObject:article];
        }
    }
    NSMutableArray *newsFromprevious=[[NSMutableArray alloc] initWithArray:[[naMainData shareInstance].previousNewsDic objectForKey:dateKey]];
    if (newsFromprevious.count==0) {
        result=[[NSArray alloc] initWithArray:newsFromDate];
    }else{
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSDate *dateFromDate=[format dateFromString:[[newsFromDate objectAtIndex:0] objectForKey:@"pubDate"]];
        NSDate *dateFromPrevious=[format dateFromString:[[newsFromprevious objectAtIndex:0] objectForKey:@"pubDate"]];
        if ([dateFromDate compare:dateFromPrevious]==NSOrderedSame) {
            if ([[[newsFromDate objectAtIndex:0] objectForKey:@"title"] isEqualToString:[[newsFromprevious objectAtIndex:0] objectForKey:@"title"]]) {
                result=[[NSArray alloc] initWithArray:newsFromprevious];
            }else{
                [newsFromprevious insertObject:[newsFromDate objectAtIndex:0] atIndex:0];
            }
        }else if ([dateFromDate compare:dateFromPrevious]==NSOrderedDescending){
            for (int i=0; i<newsFromDate.count; i++) {
                NSDate *tmpDateFromDate=[format dateFromString:[[newsFromDate objectAtIndex:i] objectForKey:@"pubDate"]];
                if ([tmpDateFromDate compare:dateFromPrevious]==NSOrderedDescending) {
                    [newsFromprevious insertObject:[newsFromDate objectAtIndex:i] atIndex:i];
                }
            }
            result=[[NSArray alloc] initWithArray:newsFromprevious];
        }else{
            for (int i=0; i<newsFromprevious.count; i++) {
                NSDate *tmpDateFromPrevious=[format dateFromString:[[newsFromprevious objectAtIndex:i] objectForKey:@"pubDate"]];
                for (int j=i; j<newsFromDate.count; j++) {
                    NSDate *tmpDateFromDate=[format dateFromString:[[newsFromDate objectAtIndex:j] objectForKey:@"pubDate"]];
                    if ([tmpDateFromDate compare:tmpDateFromPrevious]==NSOrderedAscending) {
                        [newsFromprevious insertObject:[newsFromDate objectAtIndex:j] atIndex:i];
                    }
                }
                
            }
            result=[[NSArray alloc] initWithArray:newsFromprevious];
        }
    }
    if(result.count){
        [[naMainData shareInstance].previousNewsDic setObject:result forKey:dateKey];
    }
    return result;
}

-(NSArray *)getNewsFormDate:(NSDate *)earlyDate toDate:(NSDate *)date{
    NSMutableArray *tmpDates;
    NSMutableArray *orderedPubDate;
    NSMutableArray *orderedTitle;
    NSMutableArray *orderedContent;
    NSMutableArray *orderedSource;
    NSMutableArray *newsBetweenDates=[[NSMutableArray alloc]init];
    tmpDates=[[NSMutableArray alloc]initWithArray:[[naMainData shareInstance].sortedNewsDic objectForKey:@"tmpDates"]];
    orderedPubDate=[[NSMutableArray alloc]initWithArray:[[naMainData shareInstance].sortedNewsDic objectForKey:@"pubDate"]];
    orderedTitle=[[NSMutableArray alloc]initWithArray:[[naMainData shareInstance].sortedNewsDic objectForKey:@"title"]];
    orderedContent=[[NSMutableArray alloc]initWithArray:[[naMainData shareInstance].sortedNewsDic objectForKey:@"link"]];
    orderedSource=[[NSMutableArray alloc]initWithArray:[[naMainData shareInstance].sortedNewsDic objectForKey:@"source"]];
    
    for (int i=0;i<tmpDates.count;i++) {
        NSDate *tmpDate=[[NSDate alloc]initWithTimeInterval:0 sinceDate:[tmpDates objectAtIndex:i]];
        NSComparisonResult resultFore=[tmpDate compare:earlyDate];
        NSComparisonResult resultAft=[tmpDate compare:date];
        if (resultAft==-1&&resultFore==1) {
            NSMutableDictionary *article=[[NSMutableDictionary alloc]init];
            [article setObject:[orderedPubDate objectAtIndex:i] forKey:@"pubDate"];
            [article setObject:[orderedTitle objectAtIndex:i] forKey:@"title"];
            [article setObject:[orderedContent objectAtIndex:i] forKey:@"link"];
            [article setObject:[orderedSource objectAtIndex:i] forKey:@"source"];
            [newsBetweenDates addObject:article];
        }
    }
    return newsBetweenDates;
}

#pragma mark - handle SubscriptionTopic
-(NSArray *)getUnsubscriptionTopic:(NSArray *)topic{
    NSMutableArray *tmpAlltopic=[[NSMutableArray alloc] initWithArray:[[naMainData shareInstance].rssAddressDic allKeys]];
    for (NSString *tmpTopic in topic) {
        [tmpAlltopic removeObject:tmpTopic];
    }
    NSMutableArray *unSubscriptionTopic=[[NSMutableArray alloc] initWithArray:tmpAlltopic];
    return unSubscriptionTopic;
}

-(void)deleteSubscriptionTopic:(NSArray *)topic{
    for (NSString *tmpTopic in topic) {
        if ([[[naMainData shareInstance].userSubscriptionTopicDic allKeys] containsObject:tmpTopic]) {
            [[naMainData shareInstance].userSubscriptionTopicDic removeObjectForKey:tmpTopic];
        }
    }
}

-(NSArray *)selectSubscriptionTopic:(NSString *)topic{
    NSArray *selectedSubscription=[[NSArray alloc] initWithArray:[[naMainData shareInstance].allTopicNewsDic objectForKey:topic]];
    return selectedSubscription;
}

-(void)addSubscriptionTopic:(NSArray *)topic{
    //使用gcd异步解析数组
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_group_t group = dispatch_group_create();

        for (NSString *tmpTopic in topic) {
            [[naMainData shareInstance].userSubscriptionTopicDic setObject:[[naMainData shareInstance].rssAddressDic objectForKey:tmpTopic] forKey:tmpTopic];
            [[naMainData shareInstance].configurationDic setObject:[naMainData shareInstance].userSubscriptionTopicDic forKey:@"userSubscriptionTopicDic"];
            
            // 关联一个任务到group
            dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"%@ 开启了一个异步任务，当前线程：%@",tmpTopic, [NSThread currentThread]);
            
            if (![[naMainData shareInstance].allTopicNewsDic objectForKey:tmpTopic]) {
                __block  naXMLParser *myXMLParser=[[naXMLParser alloc]init];

                for (NSString *tmp in [[[naMainData shareInstance].rssAddressDic objectForKey:tmpTopic] allKeys]) {
                    
                    [myXMLParser markArticleSource:tmp];
                    NSURL *tmpURL=[NSURL URLWithString:[[[naMainData shareInstance].rssAddressDic objectForKey:tmpTopic] objectForKey:tmp]];
                    NSData *data = [NSData dataWithContentsOfURL:tmpURL];
                   [[naMainData shareInstance].allTopicNewsDic setValue:[myXMLParser parseXML:data] forKey:tmpTopic];
                }
            }
            });
        }
        // 等待任务执行完毕,回到主线程执行block回调
         dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            //解析完成后排序
            [naMainData shareInstance].sortedNewsDic=[[NSMutableDictionary alloc]initWithDictionary:[self sortByDate:[naMainData shareInstance].allTopicNewsDic]];
 
             //取消遮罩
            [[NSNotificationCenter defaultCenter]postNotificationName:@"finishLoadingNotification" object:nil];
             //保存
             [self saveData];
        });
    });
}

-(void)refreshTopicNews:(NSArray *)topic{
    //使用gcd异步解析数组
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_group_t group = dispatch_group_create();
        
        for (NSString *tmpTopic in topic) {
            
            // 关联一个任务到group
            dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSLog(@"%@ 开启了一个异步任务，当前线程：%@",tmpTopic, [NSThread currentThread]);

                __block  naXMLParser *myXMLParser=[[naXMLParser alloc]init];
 
                    for (NSString *tmp in [[[naMainData shareInstance].rssAddressDic objectForKey:tmpTopic] allKeys]) {
                        
                        [myXMLParser markArticleSource:tmp];
                        NSURL *tmpURL=[NSURL URLWithString:[[[naMainData shareInstance].rssAddressDic objectForKey:tmpTopic] objectForKey:tmp]];
                        NSData *data = [NSData dataWithContentsOfURL:tmpURL];
                        [[naMainData shareInstance].allTopicNewsDic setValue:[myXMLParser parseXML:data] forKey:tmpTopic];
                        
                    }
            });
        }
        // 等待任务执行完毕,回到主线程执行block回调
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            //解析完成后排序
            [naMainData shareInstance].sortedNewsDic=[[NSMutableDictionary alloc]initWithDictionary:[self sortByDate:[naMainData shareInstance].allTopicNewsDic]];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshfinishNotification" object:nil];
            [self saveData];
        });
    });
}

#pragma mark - sava data
-(void)saveData{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [paths objectAtIndex:0];
    NSString *configurationFile = [plistPath stringByAppendingPathComponent:@"configuration.plist"];
    NSString *dataFile = [plistPath stringByAppendingPathComponent:@"data.plist"];
    NSString *previousNewsFile = [plistPath stringByAppendingPathComponent:@"previousNews.plist"];
    [[naMainData shareInstance].configurationDic writeToFile:configurationFile atomically:YES];
    [[naMainData shareInstance].allTopicNewsDic writeToFile:dataFile atomically:YES];
    [[naMainData shareInstance].previousNewsDic writeToFile:previousNewsFile atomically:YES];
}

#pragma mark - TTS Control
-(void)changeSpeaker:(NSString *)speaker{
    [naMainData shareInstance].ttsSpeaker=speaker;
    //存入配置字典configurationDic
    [[naMainData shareInstance].configurationDic setObject:speaker forKey:@"ttsSpeaker"];
    NSLog(@"ttsspeaker %@",[[naMainData shareInstance].configurationDic objectForKey:@"ttsSpeaker"]);
}

-(void)changeSpeed:(float) rate{
    [naMainData shareInstance].ttsSpeed=rate;
    //存入配置字典configurationDic
    [[naMainData shareInstance].configurationDic setObject:[NSNumber numberWithFloat:rate] forKey:@"ttsSpeed"];
    NSLog(@"ttsspeed %@",[[naMainData shareInstance].configurationDic objectForKey:@"ttsSpeed"]);
}

-(NSString*)parseLinkToGetContent:(NSString *)link{
    naHTMLParser *htmlParser=[[naHTMLParser alloc]init];
    NSString *content=[htmlParser parseHTML:[NSURL URLWithString:link]];
    return content;
}

-(void)saveTTSContent:(NSString *)link withDate:(NSString *)date andContent:(NSString *)content{
    NSArray *tmp=[date componentsSeparatedByString:@" "];
    NSString *dateKey=[tmp objectAtIndex:0];
    for (NSMutableDictionary *article in [[naMainData shareInstance].previousNewsDic objectForKey:dateKey]) {
        if ([[article objectForKey:@"link"] isEqualToString:link]) {
            [article setObject:content forKey:@"content"];
        }
    }
}

-(void)ttsPlay:(NSString*)content{
    if (content.length==0) {
        content=@"Cannot speak because the content is null";
    }
    [[naTTS shareInstance] play:content];
}

-(void)ttsResume{
    [[naTTS shareInstance] resume];
    NSLog(@"tts resume");
}

-(void)ttsPause{
    [[naTTS shareInstance] pause];
    NSLog(@"TTS pause");
}

-(void)ttsStop{
    [[naTTS shareInstance] stop];
    NSLog(@"TTS stop");
}

-(BOOL)ttsDidStop{
    return [naTTS shareInstance].synthesizer.isSpeaking;
}

#pragma mark - Audio
-(void)audioPlay{
    player=[[naAudioPlayer alloc] init];
    NSString *source=[[NSBundle mainBundle]pathForResource:@"music" ofType:@"mp3"];
    [player play:source];
    NSLog(@"audio");
}

-(void)audioStop{
    
}



@end
