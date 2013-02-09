//
//  Book.h
//  BookStore
//
//  Created by Brad Lees on 4/12/10.
//  Copyright 2010 Smarsh. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Author;

@interface Book :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * yearPublished;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) Author * Author;

@end



