//
//  VCImageEditing.m
//  PicDecor
//
//  Created by Bear Cahill on 12/20/09.
//  Copyright 2009 Brainwash Inc.. All rights reserved.
//

#import "VCImageEditing.h"


@implementation VCImageEditing

@synthesize editImage;


-(IBAction)doDecorateBtn:(id)sender;
{
	selectingImage = YES;
	[self presentModalViewController:vcDecorations animated:YES];
}

+ (UIImage*)imageWithImage:(UIImage*)image 
			  scaledToSize:(CGSize)newSize;
{
	UIGraphicsBeginImageContext( newSize );
	[image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}

- (void)mailComposeController:(MFMailComposeViewController*)controller 
		  didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self dismissModalViewControllerAnimated:YES];
}

-(UIImage *)saveImage:(UIView *)view {
    CGRect mainRect = [[UIScreen mainScreen] bounds];
    
    UIGraphicsBeginImageContext(mainRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
	
    CGContextFillRect(context, mainRect);
    [view.layer renderInContext:context];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
	
    return newImage;
}

-(IBAction)doEmailBtn:(id)sender;
{
	MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
	mailController.mailComposeDelegate = self;
	
	// hide the toolbar
	for (UIView *v in [self.view subviews])
		if ([v isKindOfClass:[UIToolbar class]])
			[v setHidden:YES];
	
	UIImage *i = [self saveImage:self.view];

	// show the toolbar
	for (UIView *v in [self.view subviews])
		if ([v isKindOfClass:[UIToolbar class]])
			[v setHidden:NO];
			
	NSData *imageAsData = UIImagePNGRepresentation(i);
	[mailController addAttachmentData:imageAsData mimeType:@"image/png" fileName:@"PicDecor.png"];
	[mailController setSubject:@"My PicDecor Image"];
	
	[self presentModalViewController:mailController animated:YES];
    [mailController release];

	
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	NSLog(@"image: %@", editImage);
    
	if (editImage != nil)
	{
		[ivEditingImage setImage:editImage];
		[self.view sendSubviewToBack:ivEditingImage];
	}
	
	if (selectingImage)
	{
		MovableImageView *iv = 
			[[[MovableImageView alloc] 
			  initWithImage:[vcDecorations selectedImage]] autorelease];
		[iv setUserInteractionEnabled:YES];
		[self.view addSubview:iv];
	}
	
	selectingImage = NO;
}

- (void)dealloc {
	[editImage release];
    [super dealloc];
}


@end
