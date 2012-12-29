//
//  VCImageEditing.h
//  PicDecor
//
//  Created by Bear Cahill on 12/20/09.
//  Copyright 2009 Brainwash Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MovableImageView.h"
#import <QuartzCore/QuartzCore.h>
#import <MessageUI/MessageUI.h>

#import "VCDecorations.h"

@interface VCImageEditing : UIViewController <MFMailComposeViewControllerDelegate> {

	IBOutlet VCDecorations *vcDecorations;
	UIImage *editImage;
	bool selectingImage;

	IBOutlet UIImageView *ivEditingImage;

}

-(IBAction)doDecorateBtn:(id)sender;
-(IBAction)doEmailBtn:(id)sender;

@property (nonatomic, retain) UIImage *editImage;

@end
