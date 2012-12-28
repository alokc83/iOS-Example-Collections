//
//  HomepwnerItemCell.m
//  Homepwner
//
//  Created by joeconway on 9/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HomepwnerItemCell.h"

@implementation HomepwnerItemCell
@synthesize serialNumberLabel;
@synthesize valueLabel;
@synthesize thumbnailView;
@synthesize nameLabel;
@synthesize controller;
@synthesize tableView;

- (IBAction)showImage:(id)sender 
{
    NSString *selector = NSStringFromSelector(_cmd);
    selector = [selector stringByAppendingString:@"atIndexPath:"];
    SEL newSelector = NSSelectorFromString(selector);
    
    NSIndexPath *indexPath = [[self tableView] indexPathForCell:self];
    if(indexPath) {
        if([controller respondsToSelector:newSelector]) {
            [controller performSelector:newSelector withObject:sender 
                             withObject:indexPath];
        }
    }
}
@end
