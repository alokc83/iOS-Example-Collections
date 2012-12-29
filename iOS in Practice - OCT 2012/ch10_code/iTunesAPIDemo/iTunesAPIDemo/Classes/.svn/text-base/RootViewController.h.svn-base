//
//  RootViewController.h
//  iTunesAPIDemo
//
//  Created by Bear Cahill on 1/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <iAd/iAd.h>

@interface RootViewController : UITableViewController <ADBannerViewDelegate, UITextFieldDelegate, UIActionSheetDelegate, UIWebViewDelegate> {
	IBOutlet UIViewController *vcSearch;
	NSArray *results;
	AVAudioPlayer *aAudioPlayer;

	int selectedRow;
	
	IBOutlet UIViewController *vcWebView;
	IBOutlet UIWebView *webView;
	
	IBOutlet ADBannerView *adBanner;
	bool hidingAdBanner;
}

-(IBAction)doBtnCancel:(id)sender;


@end
