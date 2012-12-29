//
//  WhereAmIParkedViewController.m
//  WhereAmIParked
//
//  Created by Bear Cahill on 1/29/10.
//  Copyright Brainwash Inc. 2010. All rights reserved.
//

#import "WhereAmIParkedViewController.h"

@implementation SpotAnnotation

@synthesize title, subtitle, coordinate;


@end


@implementation WhereAmIParkedViewController

+ (UIImage*)imageWithImage:(UIImage*)image 
			  scaledToSize:(CGSize)newSize;
{
	UIGraphicsBeginImageContext( newSize );
	[image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
	UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return newImage;
}


-(NSString*)imagePath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString *documentsDirectoryPath = [paths objectAtIndex:0];
	
	NSString *imgPath = [NSString stringWithFormat:@"%@/WIMCApp/", 
						 documentsDirectoryPath];
	
	NSError *err;
	[[NSFileManager defaultManager] 
	 createDirectoryAtPath:imgPath withIntermediateDirectories:YES
	 attributes:nil error:&err];
	
	return [NSString stringWithFormat:
				@"%@WIMCpic.png", imgPath];
}

- (void)imagePickerController:(UIImagePickerController *)picker 
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *pic = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	pic = [WhereAmIParkedViewController imageWithImage:pic
										scaledToSize:CGSizeMake(320.0, 460.0)];
	
	[UIImagePNGRepresentation(pic) 
		writeToFile:[self imagePath] atomically:YES];
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)doBtnDoneAbout:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)doPicBtn:(id)sender;
{
	if ([[[UIDevice currentDevice] model] 
		 rangeOfString:@"Sim"].location == NSNotFound) 
		[picController setSourceType:UIImagePickerControllerSourceTypeCamera];
	[self presentModalViewController:picController animated:YES];
}

-(IBAction)doShowPicBtn:(id)sender;
{
	UIImage *pic = [UIImage imageWithContentsOfFile:[self imagePath]];
	
	if (nil == pic)
		return;
	
	[ivPic setImage:pic];
	[self presentModalViewController:vcDisplayPic animated:YES];
}

-(IBAction)doDonePicBtn:(id)sender;
{
	[self dismissModalViewControllerAnimated:YES];
}

-(IBAction)doNoteBtn:(id)sender;
{
	[btnDone setHidden:NO];
	[tvNote setHidden:NO];
	[tvNote becomeFirstResponder];
	
	[tvNote setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"WIMCAppNote"]];
}

-(IBAction)doDoneBtn:(id)sender;
{
	[btnDone setHidden:YES];
	[tvNote setHidden:YES];
	[tvNote resignFirstResponder];
	
	[[NSUserDefaults standardUserDefaults] setObject:[tvNote text] forKey:@"WIMCAppNote"];
}

-(void)doRevGeocodeUsingLat:(float)lat andLng:(float)lng;
{
    CLLocation *c = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
	
    CLGeocoder *revGeo = [[CLGeocoder alloc] init];
    [revGeo reverseGeocodeLocation:c
                 completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if (!error && [placemarks count] > 0)
        {
            NSDictionary *dict =
                [[placemarks objectAtIndex:0] addressDictionary];
            NSLog(@"street address: %@", [dict objectForKey:@"Street"]);
            
            for (SpotAnnotation *ann in [mapParking annotations])
            {
                if ([ann isKindOfClass:[SpotAnnotation class]])
                    [ann setTitle:[dict objectForKey:@"Street"]];
            }
        }
        else
        {
            NSLog(@"ERROR: %@", error);
        }
    }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	if (![annotation isKindOfClass:[SpotAnnotation class]])
		return nil;
		
	NSString *dqref = @"ParkingAnnon";
	id av = [mapView dequeueReusableAnnotationViewWithIdentifier:dqref];
	if (nil == av)
	{
		av = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:dqref];
		[av setPinColor:MKPinAnnotationColorRed];
		[av setAnimatesDrop:YES];
		[av setCanShowCallout:YES];
	}
	
	return av;
}

- (void) dropPinAtCoord: (CLLocationCoordinate2D) coord  {
  if ([[mapParking annotations] count] > 1)
		[mapParking removeAnnotation:[[mapParking annotations] objectAtIndex:1]];
	SpotAnnotation *ann = [[SpotAnnotation alloc] init];
	[ann setCoordinate:coord];
	[mapParking addAnnotation:ann];	
	
	[self doRevGeocodeUsingLat:coord.latitude andLng:coord.longitude];
	
	[[NSUserDefaults standardUserDefaults] setFloat:coord.latitude forKey:@"WIMCLat"];
	[[NSUserDefaults standardUserDefaults] setFloat:coord.longitude forKey:@"WIMCLng"];
}

-(IBAction)doParkBtn:(id)sender;
{
	CLLocationCoordinate2D coord = [mapParking userLocation].location.coordinate;

	[self dropPinAtCoord: coord];
}

- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
{
	if (0.00001 > [mapView userLocation].location.coordinate.latitude)
	{
		[self performSelector:@selector(mapViewDidFinishLoadingMap:) withObject:mapView afterDelay:1.0];
		return;
	}

	MKCoordinateRegion region = [mapView region];
	region.center = [mapView userLocation].location.coordinate;
	region.span.latitudeDelta = 0.02;
	region.span.longitudeDelta = 0.02;
	[mapView setRegion:region animated:YES];
	
	if ([[NSUserDefaults standardUserDefaults] floatForKey:@"WIMCLat"] != 0.000)
	{
		CLLocationCoordinate2D coord;
		coord.latitude = [[NSUserDefaults standardUserDefaults] 
						   floatForKey:@"WIMCLat"];
		coord.longitude = [[NSUserDefaults standardUserDefaults] 
						   floatForKey:@"WIMCLng"];
		[self dropPinAtCoord:coord];
	}
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



-(IBAction)doAboutBtn:(id)sender;
{
	[self presentModalViewController:vcAbout animated:YES];
}

@end
