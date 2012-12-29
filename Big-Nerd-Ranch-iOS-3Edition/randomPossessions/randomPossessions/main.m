//
//  main.m
//  randomPossessions
//
//  Created by Katie on 12/28/12.
//  Copyright (c) 2012 AC. All rights reserved.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        //Crteate a mutable array object, store its address in the items variable
        NSMutableArray *items = [[NSMutableArray alloc] init];
        
        // Send the message addObject: to the NSMutableArray pointed to
        //by the variable items, passing a string each time.
        [items addObject:@"one"];
        [items addObject:@"Two"];
        [items addObject:@"Three"];
        
        //send another message, insertObject:atIndex:, to the same array object
        [items insertObject:@"Zero" atIndex:0];
        
        //for every item in the array as determined by sending count to items
        for(int i = 0; i< [items count]; i++)
        {
            //we get the ith Object from the array and pass it as argument to
            //NSLog, which implicitly sends the description message to that Object
            NSLog(@"%@", [items objectAtIndex:i]);
            
        }
        
        //destroy the array pointed to by items
        
        items  = nil;
        
    }
    return 0;
}

