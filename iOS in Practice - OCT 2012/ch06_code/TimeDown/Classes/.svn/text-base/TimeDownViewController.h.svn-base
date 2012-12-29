//
//  TimeDownViewController.h
//  TimeDown
//
//  Created by Bear Cahill on 8/2/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "VCAbout.h"

@interface TimeDownViewController : UIViewController <UIAccelerometerDelegate, UIActionSheetDelegate> {

	IBOutlet VCAbout* vcAbout;	
	
	IBOutlet UILabel *lblTimer, *lblTitle;

	int timeSettings;
	bool autoStart;
	AVAudioPlayer *aAudioPlayer;
	
	BOOL isShaking;
	UIAcceleration *prevAcceleration;
	
	NSTimer *secTimer;
	
}

@property (nonatomic, retain) UIAcceleration *prevAcceleration;

-(IBAction)doAboutBtn:(id)sender;
- (IBAction)doBtnDoneAbout:(id)sender;

@end

