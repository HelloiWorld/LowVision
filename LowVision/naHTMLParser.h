//
//  naHTMLParser.h
//  LowVision
//
//  Created by Sen Zeng on 14/12/15.
//  Copyright (c) 2014年 naturalsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFHpple.h"
#import "TFHppleElement.h"
#import "XPathQuery.h"


@interface naHTMLParser : NSObject

-(BOOL)isTheWhiteHouseXML:(BOOL)flag;

-(NSString*)parseHTML:(NSURL*)tmpURL;

//-(NSString*)parseHTML2:(NSURL*)tmpURL;

@end