#import <Foundation/Foundation.h>
#import "Bookstore.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	Bookstore* theBookNook = [[Bookstore alloc] init];
    NSString *newTitle = @"A Farwell To Arms";
    Book *newBook = [[Book alloc] initWithTitle:newTitle
                                         author:@"Ernest Hemingway"
                                    description:@"The story of an affair between an "
                                                 "English nurse an an American soldier "
                                                 "on the Italian front during World War I."];
	
	[theBookNook addBook: newBook];
    [newBook release]; 
	
    [theBookNook printInventory];
    [theBookNook removeBookWithTitle:newTitle];
    [theBookNook printInventory];
    [theBookNook release];
    [pool drain];
    return 0;
}
