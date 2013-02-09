//
//  Bookstore.m
//  MyBookstore
//
//  Created by Mitch Fisher on 12/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Bookstore.h"

@implementation Bookstore
@synthesize myBookstore;

- (id)init {
	self = [super init];
	if (self != nil) {
		self.myBookstore = [[NSMutableDictionary alloc] init];
	}
	return self;
}

- (BOOL)addBook:(Book *)newBook {
	[myBookstore setObject:newBook forKey:newBook.title];
    
	return YES;
}

- (BOOL)removeBookWithTitle:(NSString *)whichTitle {
	[myBookstore removeObjectForKey:whichTitle];
	return YES;
}

- (void)printInventory {
	Book *book;
	for (NSString* key in myBookstore) {
		book = [myBookstore objectForKey:key];
		NSLog(@"      Title: %@\n", book.title);
		NSLog(@"     Author: %@\n", book.author);
		NSLog(@"Description: %@\n", book.description);
	}
}

@end
