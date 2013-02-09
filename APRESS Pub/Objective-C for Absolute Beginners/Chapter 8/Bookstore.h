//
//  Bookstore.h
//  MyBookstore
//
//  Created by Mitch Fisher on 12/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Book.h"

@interface Bookstore : NSObject {
	NSMutableDictionary*	myBookstore;
}

- (id)init;
- (void)printInventory;
- (BOOL)addBook: (Book *)newBook;
- (BOOL)removeBookWithTitle: (NSString *)whichTitle;

@property (nonatomic,retain) NSMutableDictionary* myBookstore;

@end
