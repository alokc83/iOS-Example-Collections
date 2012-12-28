//
//  RSSItem.h
//  Nerdfeed
//
//  Created by joeconway on 9/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerializable.h"

@interface RSSItem : NSObject <NSXMLParserDelegate, JSONSerializable, NSCoding>
{
    NSMutableString *currentString;
}
@property (nonatomic, weak) id parentParserDelegate;
@property (nonatomic, strong) NSDate *publicationDate;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *link;

@end
