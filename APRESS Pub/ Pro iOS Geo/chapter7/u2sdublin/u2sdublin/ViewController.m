//
//  ViewController.m
//  u2sdublin
//
//  Created by Giacomo Andreucci on 13/10/12.
//  Copyright (c) 2012 Giacomo Andreucci. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize webView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    webView.delegate = self;
    NSString *webappURL = @"http://www.progettaremappeonline.it/apress/code/u2sdublin.html";
    NSURL *url = [NSURL URLWithString:webappURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [webView loadRequest:requestObj];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)inType {
    if ( inType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    
    return YES;
}

//No Internet connection error message
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Internet connection not available. Please connect to the Internet to use this app" delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
    [alert show];
    
}

//Close app from AlertView
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    exit(0);
}

@end
