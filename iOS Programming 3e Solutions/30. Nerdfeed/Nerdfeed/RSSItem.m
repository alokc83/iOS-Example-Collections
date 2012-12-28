//
//  RSSItem.m
//  Nerdfeed
//
//  Created by joeconway on 9/12/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RSSItem.h"


@implementation RSSItem

@synthesize title, link, parentParserDelegate;
@synthesize publicationDate;
- (BOOL)isEqual:(id)object
{
    // Make sure we are comparing an RSSItem!
    if(![object isKindOfClass:[RSSItem class]])
        return NO;
        
    // Now only return YES if the links are equal.
    return [[self link] isEqual:[object link]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:title forKey:@"title"];
    [aCoder encodeObject:link forKey:@"link"];
    [aCoder encodeObject:publicationDate forKey:@"publicationDate"];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self) {
        [self setTitle:[aDecoder decodeObjectForKey:@"title"]];
        [self setLink:[aDecoder decodeObjectForKey:@"link"]];
        [self setPublicationDate:[aDecoder decodeObjectForKey:@"publicationDate"]];
    }
    return self;
}

- (void)readFromJSONDictionary:(NSDictionary *)d
{
    [self setTitle:[[d objectForKey:@"title"] objectForKey:@"label"]];
    
    // Inside each entry is an array of links, each has an attribute object
    NSArray *links = [d objectForKey:@"link"];
    if([links count] > 1) {
        NSDictionary *sampleDict = [[links objectAtIndex:1] 
                                    objectForKey:@"attributes"];
        
        // The href of an attribute object is the URL for the sample audio file
        [self setLink:[sampleDict objectForKey:@"href"]];
    }
}


- (void)parser:(NSXMLParser *)parser 
    didStartElement:(NSString *)elementName 
       namespaceURI:(NSString *)namespaceURI 
      qualifiedName:(NSString *)qualifiedName 
         attributes:(NSDictionary *)attributeDict
{
    NSLog(@"\t\t%@ found a %@ element", self, elementName);

    if ([elementName isEqual:@"title"]) {
        currentString = [[NSMutableString alloc] init];
        [self setTitle:currentString];
    }
    else if ([elementName isEqual:@"link"]) {
        currentString = [[NSMutableString alloc] init];
        [self setLink:currentString];
    }   else if([elementName isEqualToString:@"pubDate"]) {
        // Create the string, but do not put it into an ivar yet 
        currentString = [[NSMutableString alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)str
{
    [currentString appendString:str];
}

- (void)parser:(NSXMLParser *)parser 
 didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName
{
    // If the pubDate finished, use a date formatter to turn it into an NSDate
    if([elementName isEqualToString:@"pubDate"]) {
        static NSDateFormatter *dateFormatter = nil;
        if(!dateFormatter) {
            dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss z"];
        }
        [self setPublicationDate:[dateFormatter dateFromString:currentString]];
    }

    currentString = nil;

    
    if ([elementName isEqual:@"item"]
    || [elementName isEqual:@"entry"]) {
        [parser setDelegate:parentParserDelegate];
    }
}
@end
