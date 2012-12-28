//
//  BNRItem.h
//  Homepwner
//
//  Created by joeconway on 9/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BNRItem : NSManagedObject

@property (nonatomic, retain) NSString * itemName;
@property (nonatomic) int32_t valueInDollars;
@property (nonatomic, retain) NSData * thumbnailData;
@property (nonatomic, retain) NSString * imageKey;
@property (nonatomic, retain) NSString * serialNumber;
@property (nonatomic) NSTimeInterval dateCreated;
@property (nonatomic, strong) UIImage * thumbnail;
@property (nonatomic) double orderingValue;
@property (nonatomic, retain) NSManagedObject *assetType;

- (void)setThumbnailDataFromImage:(UIImage *)image;

@end
