//
//  TimeDownViewController.m
//  TimeDown
//
//  Created by Bear Cahill on 8/2/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "TimeDownViewController.h"


@implementation TimeDownViewController

@synthesize prevAcceleration;

-(BOOL)shakingEnoughFromPrev:(UIAcceleration*) prevShake 
				 toThisShake:(UIAcceleration*) thisShake 
		   withThisThreshold:(double) shakeThreshold;
{
	double dX = fabs(prevShake.x - thisShake.x);
	double dY = fabs(prevShake.y - thisShake.y);
	double dZ = fabs(prevShake.z - thisShake.z);
	
	return (dX > shakeThreshold && dY > shakeThreshold) ||
		   (dX > shakeThreshold && dZ > shakeThreshold) ||
		   (dY > shakeThreshold && dZ > shakeThreshold);
}



-(void)playSound:(NSString*)soundFileName
{
	NSString *aFilePath = [[NSBundle mainBundle] pathForResource:soundFileName ofType:@"mp3"];
	if (nil != aAudioPlayer)
	{
		[aAudioPlayer stop];
	}
	aAudioPlayer =[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:aFilePath] error:NULL];
	[aAudioPlayer play];
}

-(void)vibrate;
{
	AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
}

-(void)oneSecond:(NSTimer*)timer;
{
	timeSettings--;
	if (timeSettings > -1)
		[lblTimer setText:[NSString stringWithFormat:@"%d:%02d", timeSettings/60, timeSettings%60]];
	else 
	{
		[secTimer invalidate];
		secTimer = nil;
		[self playSound:@"beeps"];
		[self vibrate];
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (0 == buttonIndex)
	{
		[lblTimer setText:@""];
		NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];

		timeSettings = [[settings objectForKey:@"timeSettings"] intValue];
		timeSettings *= 60;

		if (!secTimer)
			secTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 
											 target:self selector:@selector(oneSecond:) userInfo:nil repeats:YES];
	}
	isShaking = NO;
}

-(void)handleShake;
{	
	UIActionSheet *as = [[UIActionSheet alloc] initWithTitle:@"Start Timer" delegate:self cancelButtonTitle:@"Cancel" 
									   destructiveButtonTitle:nil otherButtonTitles:@"Start", nil];
	[as showInView:self.view];
}

- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	
	if (self.prevAcceleration) 
	{
		if (!isShaking && [self shakingEnoughFromPrev:self.prevAcceleration toThisShake:acceleration withThisThreshold:0.5]) 
		{
			isShaking = YES;
			[self handleShake];
		} 
	}
	
	self.prevAcceleration = acceleration;

}

-(void)viewWillAppear:(BOOL)animated
{
	NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
	timeSettings = [[settings objectForKey:@"timeSettings"] intValue];
	autoStart = [[settings objectForKey:@"autoStart"] boolValue];
	
	NSLog(@"timeSettings: %d autoStart: %d", timeSettings, autoStart);
	
	[lblTimer.layer setCornerRadius:5.0];
	[lblTitle.layer setCornerRadius:5.0];
	
	timeSettings *= 60;
	[lblTimer setText:@""];
	if (autoStart)
		secTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(oneSecond:) userInfo:nil repeats:YES];

	if ([UIAccelerometer sharedAccelerometer].delegate == nil)
		[UIAccelerometer sharedAccelerometer].delegate = self;

}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}



-(IBAction)doAboutBtn:(id)sender;
{
	[self presentModalViewController:vcAbout animated:YES];
}

- (IBAction)doBtnDoneAbout:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}


@end
