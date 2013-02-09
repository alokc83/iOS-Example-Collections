//
//  ChainOfResponsibilityViewController.m
//  ChainOfResponsibility
//
//  Created by Carlo Chung on 11/28/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "ChainOfResponsibilityViewController.h"
#import "Avatar.h"
#import "MetalArmor.h"
#import "CrystalShield.h"
#import "SwordAttack.h"
#import "MagicFireAttack.h"
#import "LightningAttack.h"

@implementation ChainOfResponsibilityViewController



/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // create a new avatar
  AttackHandler *avatar = [[[Avatar alloc] init] autorelease];
  
  // put it in metal armor
  AttackHandler *metalArmoredAvatar = [[[MetalArmor alloc] init] autorelease];
  [metalArmoredAvatar setAttackHandler:avatar];
  
  // then add a crytal shield
  // to the avatar who's in 
  // a metal armor
  AttackHandler *superAvatar = [[[CrystalShield alloc] init] autorelease];
  [superAvatar setAttackHandler:metalArmoredAvatar];
  
  // ... some other actions
  
  // attack the avatar with
  // a sword
  Attack *swordAttack = [[[SwordAttack alloc] init] autorelease];
  [superAvatar handleAttack:swordAttack];
  
  // then attack the avatar with
  // magic fire
  Attack *magicFireAttack = [[[MagicFireAttack alloc] init] autorelease];
  [superAvatar handleAttack:magicFireAttack];
  
  // now there is a new attack
  // with lightning...
  Attack *lightningAttack = [[[LightningAttack alloc] init] autorelease];
  [superAvatar handleAttack:lightningAttack];
  
  // ... further actions
}



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

@end
