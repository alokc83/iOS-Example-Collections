#import <Foundation/Foundation.h>


int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    // insert code here...
	//declare and initialize variables
	 
	float firstNumber = 2.27;
	float secondNumber = 3.5;
	float totalSum = 0;
	char c = 'a';
	char d = 'b';
	secondNumber = secondNumber * 10;
	totalSum = firstNumber + secondNumber;
	NSLog(@"The total number is: %f",totalSum);
    NSLog(@"The program has terminated successfully.");
    [pool drain];
    return 0;
}
