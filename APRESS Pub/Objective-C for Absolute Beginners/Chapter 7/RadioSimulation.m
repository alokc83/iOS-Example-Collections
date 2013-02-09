#import <Foundation/Foundation.h>
#import "RadioStation.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    // insert code here...
    NSMutableDictionary* stations = [[NSMutableDictionary alloc] init];
    RadioStation* newStation;
    
    newStation = [[RadioStation alloc] initWithName:@"Star 94 FM"
                                        atFrequency:94.1];
    
    [stations setObject:newStation forKey:@"WSTR"];
    [newStation release];
    
    NSLog(@"%@", [stations objectForKey:@"WSTR"]);
    
    [stations release];
    [pool drain];
    return 0;
}
