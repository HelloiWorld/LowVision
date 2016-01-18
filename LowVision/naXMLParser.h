//
//  naXMLParser.h
//  LowVision
//
//  Created by Sen Zeng on 14/12/15.
//  Copyright (c) 2014年 naturalsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "naHTMLParser.h"

@interface naXMLParser : NSObject<NSXMLParserDelegate>

-(NSArray*)parseXML:(NSData*)data;

-(NSString*)markArticleSource:(NSString*)source;

@end
