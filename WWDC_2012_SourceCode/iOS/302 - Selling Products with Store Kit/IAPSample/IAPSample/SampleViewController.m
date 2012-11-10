
/*
     File: SampleViewController.m
 Abstract: View controller for the app's UI
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 
 WWDC 2012 License
 
 NOTE: This Apple Software was supplied by Apple as part of a WWDC 2012
 Session. Please refer to the applicable WWDC 2012 Session for further
 information.
 
 IMPORTANT: This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple
 Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 */

#import "SampleViewController.h"


@implementation SampleViewController


SKProductsRequest *productsRequest;

@synthesize buttonBuyHostedIAP;
@synthesize buttonBuyRegularIAP;


#pragma mark - Startup
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Hide the buttons by default.  Only show them if the products are avaliable for sale.
    buttonBuyHostedIAP.hidden   = YES;
    buttonBuyRegularIAP.hidden  = YES;
}


- (void)viewDidAppear:(BOOL)animated
{
	productsRequest.delegate = self;
    
    // Listen for notification from StoreController for various IAP events
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(processPurchaseFailure) 
                                                 name:IAPFailedNotification 
                                               object:[StoreController sharedInstance]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(processPurchaseSuccess)
                                                 name:IAPSuccessNotification
                                               object:[StoreController sharedInstance]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(processDownloadComplete)
                                                 name:IAPDownloadCompleteNotification
                                               object:[StoreController sharedInstance]];
}


- (void)viewDidDisappear:(BOOL)animated
{
	productsRequest.delegate = nil;
        
    // De-register for notification from StoreController for various IAP events
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IAPFailedNotification
                                                  object:nil];    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IAPSuccessNotification
                                                  object:nil];    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:IAPDownloadCompleteNotification
                                                  object:nil];    
}


#pragma mark - Products Request

- (void)requestProductData
{
    if(![SKPaymentQueue canMakePayments])
    {
        Log(@"In-app purchase is disabled for this app.");
        return;
    }	
	NSArray *identifiers    = [NSArray arrayWithObjects:IAP_PRODUCT_ID_REGULAR, IAP_PRODUCT_ID_HOSTED, nil];
	NSSet *productIdSet     = [[NSSet alloc] initWithArray:identifiers];

	productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers: productIdSet];
	productsRequest.delegate = self;
    
    Log(@"Check list of purchasable add-ons for this app.");
    
    // This will trigger the SKProductsRequestDelegate callbacks
	[productsRequest start];
}


#pragma mark - Buttons actions

- (IBAction)pressedButtonFetchProductInfo
{
    // Lets check with the store to see what products are avaliable
    [self requestProductData];    
}


- (IBAction)pressedButtonBuyRegularIAP
{
	SKMutablePayment *payment = [[SKMutablePayment alloc] init];
    payment.productIdentifier = IAP_PRODUCT_ID_REGULAR;
	payment.quantity = 1;
    
    Log(@"Buy prouct with id %@", payment.productIdentifier);
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    // From here on the StoreController will process the payments in the SKPaymentQueue.
}


- (IBAction)pressedButtonBuyHostedIAP
{
	SKMutablePayment *payment = [[SKMutablePayment alloc] init];
    payment.productIdentifier = IAP_PRODUCT_ID_HOSTED;
	payment.quantity = 1;

    Log(@"Buy prouct with id %@", payment.productIdentifier);
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    // From here on the StoreController will process the payments in the SKPaymentQueue.
}


- (IBAction)pressedButtonBuyStoreContent
{
    SKStoreProductViewController* vc = [[SKStoreProductViewController alloc] init];
    vc.delegate = self;
    
    NSNumber* itemId = [NSNumber numberWithInt:[APPSTORE_APP_ID intValue]];
    NSDictionary* parametersDict = [NSDictionary dictionaryWithObject:itemId
                                                               forKey:SKStoreProductParameterITunesItemIdentifier];
    
    // Request the product details from the Store.
    // When it completes and if it passes, show the viewcontroller to the user.
    [vc loadProductWithParameters:parametersDict completionBlock:^(BOOL result, NSError *error)
        {
            Log(@"[SKStoreProductViewController loadProductWithParameters:] completed. result=%u, error=%@", result, error);
            if(result)
            {
                [self presentViewController:vc animated:YES completion:^
                    {
                        Log(@"presentViewController completed!")
                    }];
            } else {
                UIAlertView* alertFailed = [[UIAlertView alloc] initWithTitle:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]
                                                                      message:@"Error: Can't display the SKStoreProductViewController."
                                                                     delegate:nil
                                                            cancelButtonTitle:@"Ok"
                                                            otherButtonTitles:nil, nil];
                [alertFailed show];
            }
        }];
}


- (IBAction)pressedButtonRestorePurchases {
    Log(@"Restore previous transactions");
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


#pragma mark - SKProductsRequestDelegate

// Sent immediately before -requestDidFinish:
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    Log(@"Valid products returned = %@", response.products);
    Log(@"Invalid products returned = %@", response.invalidProductIdentifiers);
    
    if ([response.invalidProductIdentifiers containsObject:IAP_PRODUCT_ID_REGULAR])
    {
        Log(@"Hiding the button to buy %@, since the add-on is not avaliable in the store. Please ensure its configured correctly in iTunesConnect.", IAP_PRODUCT_ID_REGULAR);
        buttonBuyRegularIAP.hidden = YES;
    } else {
        buttonBuyRegularIAP.hidden = NO;
    }

    if ([response.invalidProductIdentifiers containsObject:IAP_PRODUCT_ID_HOSTED])
    {
        Log(@"Hiding the button to buy %@, since the add-on is not avaliable in the store. Please ensure its configured correctly in iTunesConnect.", IAP_PRODUCT_ID_HOSTED);
        buttonBuyHostedIAP.hidden = YES;
    } else {
        buttonBuyHostedIAP.hidden = NO;
    }
}


- (void)requestDidFinish:(SKRequest *)request
{
	Log();
}


- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
	Log(@"error=%@", error);
}


#pragma mark - SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [self dismissViewControllerAnimated:YES completion:^
        {
            Log(@"dismissModalViewControllerAnimated completed!")        
        }];
}


#pragma mark - Notifications from StoreController

- (void)processPurchaseFailure
{
    UIAlertView* alertFailed = [[UIAlertView alloc] initWithTitle:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]
                                                    message:@"Purchase failed."
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil, nil];
    [alertFailed show];
}


- (void)processPurchaseSuccess
{
    UIAlertView* alertSuccess = [[UIAlertView alloc] initWithTitle:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]
                                                    message:@"Purchase succeeded."
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil, nil];
    [alertSuccess show];    
}


- (void)processDownloadComplete
{
    UIAlertView* alertDownloadComplete = [[UIAlertView alloc] initWithTitle:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]
                                                    message:@"The hosted content downloaded is complete. Check the app's Documents folder."
                                                   delegate:nil
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil, nil];
    [alertDownloadComplete show];    
}

@end
