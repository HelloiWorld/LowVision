//
//  naHTMLParser.m
//  LowVision
//
//  Created by Sen Zeng on 14/12/15.
//  Copyright (c) 2014年 naturalsoft. All rights reserved.
//

#import "naHTMLParser.h"

@implementation naHTMLParser{
    BOOL isTheWhiteHouse;
    NSArray *elements;
}

-(BOOL)isTheWhiteHouseXML:(BOOL)flag{
    isTheWhiteHouse=flag;
    
    return isTheWhiteHouse;
}

-(NSString*)parseHTML:(NSURL*)tmpURL{
    NSString *urlString =  [NSString stringWithContentsOfURL:tmpURL encoding:NSUTF8StringEncoding error:nil];
    
//    NSRange rang1=[urlString rangeOfString:@"<div class=\"content\">"];
//    
//    NSMutableString *urlString2=[[NSMutableString alloc]initWithString:[urlString substringFromIndex:rang1.location+rang1.length]];
//    
//    NSRange rang2=[urlString2 rangeOfString:@"<div class=\"clear\">"];
//    NSMutableString *urlString3=[[NSMutableString alloc]initWithString:[urlString2 substringToIndex:rang2.location]];
//    NSData *data = [urlString3 dataUsingEncoding:NSUTF8StringEncoding];

    NSData *data = [urlString dataUsingEncoding:NSUTF8StringEncoding];
    
    TFHpple *xpathParser=[[TFHpple alloc]initWithHTMLData:data];
    
    elements=[xpathParser searchWithXPathQuery:@"//p"];
    
//    if (!elements) {
//        elements=[xpathParser searchWithXPathQuery:@"//div[@id=\"content\"]/p"];
//    }
    

    NSMutableString *contentString=[[NSMutableString alloc]init];
    for (TFHppleElement *element in elements) {
        if ([element content]!=nil) {
            [contentString appendString:[element content]];
        }
        //NSDictionary *elementContent =[element attributes];
        //[contentArray addObject:[elementContent objectForKey:@"class"]];
    }

    return contentString;
}

//-(NSString*)parseHTML2:(NSURL *)tmpURL{
//    NSString *urlString =  [NSString stringWithContentsOfURL:tmpURL encoding:NSUTF8StringEncoding error:nil];
//    
//    NSData *data = [urlString dataUsingEncoding:NSUTF8StringEncoding];
//    
//    TFHpple *xpathParser=[[TFHpple alloc]initWithHTMLData:data];
//    
//    NSArray *elements=[xpathParser searchWithXPathQuery:@"//p"];
//    
//    NSMutableString *contentString=[[NSMutableString alloc]init];
//    
//    for (TFHppleElement *element in elements) {
//        if ([element content]!=nil) {
//            [contentString appendString:[element content]];
//        }
//    }
//    
//    return contentString;
//}



@end