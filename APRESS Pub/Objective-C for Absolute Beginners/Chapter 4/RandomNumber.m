#import <Foundation/Foundation.h>

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    // insert code here...
	int randomNumber = 1;
	int userGuess = 1;
	BOOL continueGuessing = TRUE;
	BOOL keepPlaying = TRUE;
	char yesNo = ' ';
	
	while (keepPlaying)
	{
		randomNumber = (random() % 101);
		NSLog(@"The random number to guess is: %d",randomNumber);
		while (continueGuessing)
		{
			NSLog (@"Pick a number between 0 and 100.  ");
			scanf ("%i", &userGuess);
			fgetc(stdin);//remove CR/LF i.e extra character
			if (userGuess == randomNumber) 
			{
				continueGuessing = FALSE;
				NSLog(@"Correct number!");
			}
			//nested if statement
			else if (userGuess > randomNumber)
			{
				//user guessed too high
				NSLog(@"Your guess is too high");
			}
			else 
			{
				// no reason to check if userGuess < randomNumber. It has to be.
				NSLog(@"Your guess is too low");
			}
			//refactored from our Alice app. This way we only have to code once.
			NSLog(@"The user guessed %d",userGuess);
		}
		NSLog (@"Play Again? Y or N");
		
		yesNo = fgetc(stdin);
	
		if (yesNo == 'N')
		{
			keepPlaying = FALSE;
		}
		continueGuessing = TRUE;
	}
    [pool drain];
    return 0;
}
