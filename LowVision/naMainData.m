//
//  naMainData.m
//  LowVision
//
//  Created by Sen Zeng on 14/12/12.
//  Copyright (c) 2014 naturalsoft. All rights reserved.
//

#import "naMainData.h"

static naMainData *data=nil;

@implementation naMainData{
    NSString *configurationFile;
    NSString *dataFile;
    NSString *previousNewsFile;
    
    NSDictionary *newsTopicDic;
    NSDictionary *selectionTopicDic;
    NSDictionary *entertainmentTopicDic;
    NSDictionary *lifeTopicDic;
    NSDictionary *scienceTopicDic;
}

+(instancetype)shareInstance{
    if (data==nil) {
        data=[[[self class]alloc]init];
    }
    return data;
}

-(id)init{
    if (self=[super init]) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *plistPath = [paths objectAtIndex:0];
        configurationFile = [plistPath stringByAppendingPathComponent:@"configuration.plist"];
        if(![fileManager fileExistsAtPath:configurationFile]) {
            [fileManager createFileAtPath:configurationFile contents:nil attributes:[NSDictionary dictionary]];//创建一个dictionary文件
        }
        dataFile = [plistPath stringByAppendingPathComponent:@"data.plist"];
        if(![fileManager fileExistsAtPath:dataFile]) {
            [fileManager createFileAtPath:dataFile contents:nil attributes:[NSDictionary dictionary]];//创建一个dictionary文件
        }
        previousNewsFile = [plistPath stringByAppendingPathComponent:@"previousNews.plist"];
        if(![fileManager fileExistsAtPath:previousNewsFile]) {
            [fileManager createFileAtPath:previousNewsFile contents:nil attributes:[NSDictionary dictionary]];//创建一个dictionary文件
        }
    }
    return self;
}

-(NSMutableDictionary*)rssAddressDic{
    if (!_rssAddressDic) {
        newsTopicDic=[[NSDictionary alloc]initWithObjectsAndKeys:
                      @"http://rss.huanqiu.com/mil/china.xml",@"环球网军事",
                      @"http://rss.huanqiu.com/opinion/topic.xml",@"环球网今日话题",
                      @"http://rss.huanqiu.com/world/hot.xml",@"环球网国际热点",
                      @"http://www.ftchinese.com/rss/news",@"FT中文网 - 今日焦点",
                      @"http://www.ftchinese.com/rss/feed",@"FT中文网",
                      @"http://news.ifeng.com/rss/index.xml",@"资讯频道_凤凰网",
                      @"http://zaobao.feedsportal.com/c/34003/f/616934/index.rss",@"联合早报",
                      nil];
        entertainmentTopicDic=[[NSDictionary alloc]initWithObjectsAndKeys:
                @"http://smweekly.feedsportal.com/c/35020/f/646841/index.rss",@"南都娱乐周刊",
                @"http://9.douban.com/rss/fun",@"九点 趣味",nil];
        selectionTopicDic=[[NSDictionary alloc]initWithObjectsAndKeys:
                    @"http://hanhanone.sinaapp.com/feed/zhihu_dayily",@"知乎每日精选",
                    @"http://www.ftchinese.com/rss/hotstoryby7day",@"FT中文网一周十大热门文章",nil];
        lifeTopicDic=[[NSDictionary alloc]initWithObjectsAndKeys:
                      @"http://www.ftchinese.com/rss/lifestyle",@"FT中文网 - 生活时尚",
                      @"http://www.ftchinese.com/rss/column/007000002",@"FT中文网专栏_《朝九晚五》",
                      @"http://jiaren.org/feed/",@"佳人",
                      @"http://www.chong4.com.cn/feed.php",@"穿衣打扮",
                      nil];
        scienceTopicDic=[[NSDictionary alloc]initWithObjectsAndKeys:@"http://cn.engadget.com/rss.xml",@"Engadget 中国版",@"http://www.engadget.com/rss.xml",@"Engadget",nil];
        
        _rssAddressDic=[[NSMutableDictionary alloc]initWithObjectsAndKeys:newsTopicDic,@"新闻",entertainmentTopicDic,@"娱乐",selectionTopicDic,@"精选",lifeTopicDic,@"生活",scienceTopicDic,@"科技",nil];
    }
    /*
     

     @"http://zaobao.feedsportal.com/c/34003/f/616935/index.rss",@"联合早报-中国财经",
     @"http://zaobao.feedsportal.com/c/34003/f/616938/index.rss",@"联合早报-全球财经",
     @"http://zaobao.feedsportal.com/c/34003/f/616931/index.rss",@"联合早报-国际新闻",
     @"http://zaobao.feedsportal.com/c/34003/f/616930/index.rss",@"联合早报-中国新闻",
     @"http://zaobao.feedsportal.com/c/34003/f/616929/index.rss",@"联合早报-即时报道",
     @"http://zaobao.feedsportal.com/c/34003/f/616934/index.rss",@"联合早报-今日观点",
     @"http://rss.huanqiu.com/mil/china.xml",@"环球网军事",
     @"http://rss.huanqiu.com/opinion/topic.xml",@"环球网今日话题",
     @"http://rss.huanqiu.com/world/hot.xml",@"环球网国际热点",
     @"http://news.ifeng.com/rss/index.xml",@"凤凰网-资讯频道",
     @"http://news.ifeng.com/history/rss/index.xml",@"凤凰网-历史频道",
     @"http://news.ifeng.com/rss/world.xml",@"凤凰网-国际资讯",
     @"http://sports.ifeng.com/rss/index.xml",@"凤凰网-体育频道",
     @"http://www.ftchinese.com/rss/feed",@"FT中文网-每日新闻",
     @"http://www.ftchinese.com/rss/news",@"FT中文网 - 今日焦点",
     @"http://www.ftchinese.com/rss/hotstoryby7day",@"FT中文网一周十大热门文章",
     @"http://www.ftchinese.com/rss/lifestyle",@"FT中文网 - 生活时尚",
     @"http://www.ftchinese.com/rss/column/007000002",@"FT中文网专栏_《朝九晚五》",
     @"http://zaobao.feedsportal.com/c/34003/f/616939/index.rss",@"联合早报-体育新闻",
     @"http://www.engadget.com/rss.xml",@"Engadget",
     @"http://cn.engadget.com/rss.xml",@"Engadget 中国版",
     @"http://hanhanone.sinaapp.com/feed/zhihu_dayily",@"知乎每日精选",
     @"http://jiaren.org/feed/",@"佳人",
     @"http://9.douban.com/rss/fun",@"九点 趣味",
     @"http://www.chong4.com.cn/feed.php",@"穿衣打扮",
     @"http://smweekly.feedsportal.com/c/35020/f/646841/index.rss",@"南都娱乐周刊",
     
     */
    return _rssAddressDic;
}

-(NSMutableDictionary*)configurationDic{
    if (!_configurationDic) {
        _configurationDic=[[NSMutableDictionary alloc]initWithContentsOfFile:configurationFile];
        if (!_configurationDic) {
            _configurationDic=[[NSMutableDictionary alloc]init];
        }
        _userSubscriptionTopicDic=[[NSMutableDictionary alloc]initWithDictionary:[_configurationDic objectForKey:@"userSubscriptionTopicDic"]];
        if (_userSubscriptionTopicDic) {
            _userSubscriptionTopicDic=[[NSMutableDictionary alloc]init];
        }
        _ttsSpeaker=[_configurationDic objectForKey:@"ttsSpeaker"];
        _ttsSpeed=[[_configurationDic objectForKey:@"ttsSpeed"] floatValue];
    }
    return _configurationDic;
}

-(NSMutableDictionary*)userSubscriptionTopicDic{
    _userSubscriptionTopicDic=[self.configurationDic objectForKey:@"userSubscriptionTopicDic"];
    if (!_userSubscriptionTopicDic) {
        _userSubscriptionTopicDic=[[NSMutableDictionary alloc]init];
        [_configurationDic setObject:_userSubscriptionTopicDic forKey:@"userSubscriptionTopicDic"];
    }
    return _userSubscriptionTopicDic;
}

-(NSString*)ttsSpeaker{
    _ttsSpeaker=[self.configurationDic objectForKey:@"ttsSpeaker"];
    if (!_ttsSpeaker) {
        _ttsSpeaker=@"Chinese(China)";
        [_configurationDic setObject:_ttsSpeaker forKey:@"ttsSpeed"];
    }
    return _ttsSpeaker;
}

-(float)ttsSpeed{
    _ttsSpeed=[[self.configurationDic objectForKey:@"ttsSpeed"] floatValue];
    if (!_ttsSpeed) {
        _ttsSpeed=0.2;
        [_configurationDic setObject:[NSNumber numberWithFloat:_ttsSpeed] forKey:@"ttsSpeed"];
    }
    return _ttsSpeed;
}

-(NSMutableDictionary*)allTopicNewsDic{
    if (!_allTopicNewsDic) {
        _allTopicNewsDic=[[NSMutableDictionary alloc]initWithContentsOfFile:dataFile];
        if (!_allTopicNewsDic) {
            _allTopicNewsDic=[[NSMutableDictionary alloc]init];
        }
    }
    return _allTopicNewsDic;
}

-(NSMutableDictionary*)sortedNewsDic{
    if (!_sortedNewsDic&&self.allTopicNewsDic) {
        _sortedNewsDic=[[NSMutableDictionary alloc]initWithDictionary:[[naDataProcessing shareInstance] sortByDate:_allTopicNewsDic]];
    }
    return _sortedNewsDic;
}

-(NSMutableDictionary*)previousNewsDic{
    if (!_previousNewsDic) {
        _previousNewsDic=[[NSMutableDictionary alloc]initWithContentsOfFile:previousNewsFile];
        if (!_previousNewsDic) {
            _previousNewsDic=[[NSMutableDictionary alloc]init];
        }
    }
    return _previousNewsDic;
}

@end
