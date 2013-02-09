//
//  Car.h
//  Facade
//
//  Created by Carlo Chung on 11/15/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Car : NSObject 
{

}

// ...

- (void) releaseBrakes;
- (void) changeGears;
- (void) pressAccelerator;
- (void) pressBrakes;
- (void) releaseAccelerator;

// ...

@end
