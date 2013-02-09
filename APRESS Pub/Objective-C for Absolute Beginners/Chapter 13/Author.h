//
//  Author.h
//  BookStore
//
//  Created by Brad Lees on 4/12/10.
//  Copyright 2010 Smarsh. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Book;

@interface Author :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;

@property (nonatomic, retain) NSSet* books;

@end



@interface Author (CoreDataGeneratedAccessors)
- (void)addBooksObject:(Book *)value;
- (void)removeBooksObject:(Book *)value;
- (void)addBooks:(NSSet *)value;
- (void)removeBooks:(NSSet *)value;

@end

