//
//  BNRItem.h
//  randomPossessions
//
//  Created by Katie on 12/28/12.
//  Copyright (c) 2012 AC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BNRItem : NSObject
{
    NSString *itemName;
    NSString *serialNumber;
    int valueInDollars;
    NSDate *dateCreated;
    
}

- (void)setItemName:(NSString *)str;
- (NSString *) itemName;

- (void)SetSerialNumber:(NSString *)str;
- (NSString *)serialNumber;

-(void)setValueinDollars:(int)i;
- (int)valueInDollars;



@end
