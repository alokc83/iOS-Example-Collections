//
//  Book.m
//  MyBookstore
//
//  Created by Mitch Fisher on 11/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Book.h"


@implementation Book
@synthesize title, author, description;

- (id)initWithTitle:(NSString *)newTitle
			 author:(NSString *)newAuthor
		description:(NSString *)newDescription
{
	[super init];

	title = newTitle;
	author = newAuthor;
	description = newDescription;
	
	return self;
}

@end
