//
//  PicDecorViewController.m
//  PicDecor
//
//  Created by Bear Cahill on 12/20/09.
//  Copyright Brainwash Inc. 2009. All rights reserved.
//

#import "PicDecorViewController.h"

static BOOL startedUp;

@implementation PicDecorViewController

- (UIImage*)imageWithImage:(UIImage*)image 
			  scaledToSize:(CGSize)newSize;
{
	UIGraphicsBeginImageContext( newSize );
	[image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *i = [info objectForKey:UIImagePickerControllerOriginalImage];
	NSLog(@"%f %f", [i size].width, [i size].height);
	if (i.size.width > 320 || i.size.height > 480)
		i = [self imageWithImage:i scaledToSize:CGSizeMake(320, 480)];
	[self dismissModalViewControllerAnimated:NO];
	[vcImageEditing setEditImage:i];
	[self presentModalViewController:vcImageEditing animated:YES];
}

-(IBAction)doCameraBtn:(id)sender; 
{
	UIImagePickerController *ipController = [[[UIImagePickerController alloc] init] autorelease];
	if ([[[UIDevice currentDevice] model] 
		 rangeOfString:@"Sim"].location == NSNotFound) 
		 [ipController setSourceType:UIImagePickerControllerSourceTypeCamera];
	[ipController setDelegate:self];
	[self presentModalViewController:ipController animated:YES];
}

-(IBAction)doPhotoAlbumBtn:(id)sender; 
{
	UIImagePickerController *ipController = [[[UIImagePickerController alloc] init] autorelease];
	[ipController setDelegate:self];
	[self presentModalViewController:ipController animated:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	if (!startedUp)
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
			[self doPhotoAlbumBtn:nil];
		
	startedUp = YES;	
}

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

-(IBAction)doAboutBtn:(id)sender;
{
	[self presentModalViewController:vcAbout animated:YES];
}

@end
