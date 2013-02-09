//
//  Book.h
//  MyBookstore
//
//  Created by Mitch Fisher on 11/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Book : NSObject {
	NSString* title;
	NSString* author;
	NSString* description;
}



- (id)initWithTitle:(NSString *)newTitle
			 author:(NSString *)newAuthor
		description:(NSString *)newDescription;

@property(retain) NSString* title;
@property(retain) NSString* author;
@property(retain) NSString* description;

@end
