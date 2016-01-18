//
//  naXMLParser.m
//  LowVision
//
//  Created by Sen Zeng on 14/12/15.
//  Copyright (c) 2014年 naturalsoft. All rights reserved.
//

#import "naXMLParser.h"
#import "naHTMLParser.h"
#import "naDataProcessing.h"

@implementation naXMLParser{
    NSMutableString *tmpString;
    NSString  *currentElementName;
    NSMutableDictionary *newsDict;
    NSMutableArray *topicArray;
    NSMutableDictionary *article;
    NSString *articleSourceStr;
}

-(id)init{
    if (self=[super init]) {
            topicArray=[[NSMutableArray alloc]init];
            article=[[NSMutableDictionary alloc]init];
    }
    return self;
}

-(NSArray*)parseXML:(NSData*)data{
//    NSData *data = [NSData dataWithContentsOfURL:tmpURL];
    NSXMLParser *parser = [[NSXMLParser alloc] initWithData:data];
    //设置该类本身为代理类，即该类在声明时要实现NSXMLParserDelegate委托协议
    [parser setDelegate:self];  //设置代理为本地
    BOOL flag = [parser parse]; //开始解析
    if(flag) {
        NSLog(@"%@ 获取指定路径的xml文件成功",articleSourceStr);
        return topicArray;
    }else{
        NSLog(@"%@ 获取指定路径的xml文件失败",articleSourceStr);
        return nil;
    }
}


-(NSString*)markArticleSource:(NSString*)source{
    articleSourceStr=source;
    return articleSourceStr;
}


#pragma mark-   NSXMLParser Delegate
//解析前的准备
- (void)parserDidStartDocument:(NSXMLParser *)parser{

}

//查询节点，同时alloc出一个对象 ，用于储存数据
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    tmpString=[[NSMutableString alloc]init];
    if ([elementName isEqualToString:@"item"]) {
        newsDict=[[ NSMutableDictionary alloc] init];
    }else if(newsDict) {
        NSMutableString *string = [[ NSMutableString alloc ] initWithCapacity : 0 ];
        [newsDict setObject :string forKey :elementName];
        currentElementName = elementName;
    }
}

//找到节点数据，通过NSString对象来传递
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if(![string isEqualToString:@""])
    {
        [tmpString appendString:string];
    }
    
}

//调用多次
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    //将NSMutablestring去除首尾空格和换行符
    NSString *tmp=[tmpString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([elementName isEqualToString:@"item"]) {
        newsDict = nil;
    }else if ([elementName isEqualToString:currentElementName]) {
//        if ([elementName isEqualToString:@"description"]) {
//            //过滤<>之间的内容和&nbsp;
//            NSScanner *theScanner;
//            NSString *text = nil;
//            theScanner = [NSScanner scannerWithString:tmpString];
//            while ([theScanner isAtEnd] == NO) {
//                // find start of tag
//                [theScanner scanUpToString:@"<" intoString:NULL] ;
//                
//                // find end of tag
//                [theScanner scanUpToString:@">" intoString:&text] ;
//                
//                // replace the found tag with a space
//                //(you can filter multi-spaces out later if you wish)
//                tmpString = (NSMutableString*)[tmpString stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
//                
//                tmpString=(NSMutableString*)[tmpString stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@""];
//            }
//            [article setObject:tmp forKey:@"main"];
//          NSLog(@"article %@",[article objectForKey:@"main"]);
        [article setObject:articleSourceStr forKey:@"source"];
        if([elementName isEqualToString:@"title"]){
            [article setObject:tmp forKey:@"title"];
        }else if ([elementName isEqualToString:@"link"]){
            [article setObject:tmp forKey:@"link"];
        }else if ([elementName isEqualToString:@"pubDate"]){
            NSString *tmpPubDate=[[naDataProcessing shareInstance] stringFromString:tmp];
            [article setObject:tmpPubDate forKey:@"pubDate"];
        }
    if ([article allKeys].count==4) {
        NSMutableDictionary *tmpDic=[[NSMutableDictionary alloc] initWithDictionary:article];
//        NSDictionary *tmpDic=[article mutableCopy];
        [topicArray addObject:tmpDic];
        [article removeAllObjects];
        }
    }
}


//解析完成
- (void)parserDidEndDocument:(NSXMLParser *)parser{
    currentElementName=nil;
//    for (id tmp in topicArray) {
//        NSLog(@"%@",tmp);
//    }
}

@end
