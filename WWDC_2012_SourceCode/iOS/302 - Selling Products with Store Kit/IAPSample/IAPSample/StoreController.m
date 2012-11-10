
/*
     File: StoreController.m
 Abstract: The StoreController handles all of the StoreKit payment queue processing.
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

#import "StoreController.h"

NSString * const IAPFailedNotification              = @"IAPFailedNotification";
NSString * const IAPSuccessNotification             = @"IAPSuccessfulNotification";
NSString * const IAPDownloadCompleteNotification    = @"IAPDownloadCompleteNotification";

static StoreController *storeControllerSingleton;


@implementation StoreController

#pragma mark - Setup

+ (StoreController *)sharedInstance
{
	if (storeControllerSingleton == nil)
    {
		storeControllerSingleton = [[StoreController alloc] init];		
	}
	return storeControllerSingleton;
}


- (id)init
{
	self = [super init];
	if (self != nil)
    {
		[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
	}	
	return self;
}


- (void)unlockFeature:(SKPaymentTransaction *)transaction
{
    Log(@"Unlocked feature for %@", transaction.payment.productIdentifier);
}


#pragma mark - SKPaymentTransactionObserver protocol implementation

// Sent when the transaction array has changed (additions or state changes).  Client should check state of transactions and finish as appropriate.
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    // There could be multiple trasnaction so lets process each one seperately
    for (SKPaymentTransaction *transaction in transactions)
    {
        Log(@"Processing transaction: %@", transaction);
        
        switch ([transaction transactionState])
        {
			case SKPaymentTransactionStatePurchasing:			
                Log(@"Purchasing...");
				break;
				
			case SKPaymentTransactionStateRestored:
                // Do anything special for the restored case (like checking if you've already unlocked your feature for this product type).
                // Fall through to the SKPaymentTransactionStatePurchased case.
                // Depending on what your app does with restored transactions you want want to handle this differently.
            case SKPaymentTransactionStatePurchased:
                [self unlockFeature:transaction];  // Unlock the feature in your app.
                if(transaction.downloads && transaction.downloads.count > 0)
                {
                    Log(@"Start downloading the hosted content data");
                    // Don't finish the transaction for this case. Only finish it when the download completes.
                    [[SKPaymentQueue defaultQueue] startDownloads:transaction.downloads];
                } else {
                    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];                    
                }
                if(SKPaymentTransactionStatePurchased == transaction.transactionState) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:IAPSuccessNotification object:self];
                } else {
                    // For the SKPaymentTransactionStateRestored case, you may get back lots of transations.
                    Log(@"Restored transaction: %@", transaction);
                }

				break;
				
            case SKPaymentTransactionStateFailed:
                Log(@"Purchase failed!");
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                [[NSNotificationCenter defaultCenter] postNotificationName:IAPFailedNotification object:self];
				break;
                                
            default:
				Log(@"StoreEngine: Unknown transaction state = %d", [transaction transactionState]);
                break;
        }
    }
}


// Sent when transactions are removed from the queue (via finishTransaction:).
- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
{
	for (SKPaymentTransaction *transaction in transactions)
    {
        Log(@"Removed transaction: %@", transaction);
	}
}


// Sent when an error is encountered while adding transactions from the user's purchase history back to the queue.
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
	Log(@"Error=%@", error);
}


// Sent when all transactions from the user's purchase history have successfully been added back to the queue.
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    Log();
}


// Sent when the download state has changed.
- (void)paymentQueue:(SKPaymentQueue *)queue updatedDownloads:(NSArray *)downloads
{
    // If we get here, there are some transaction assets to download
    for (SKDownload* downloadAsset in downloads)
    {
        switch (downloadAsset.downloadState)
        {
            case SKDownloadStateActive:
                Log(@"Download progress=%.2f%%", downloadAsset.progress*100);
                break;
                
            case SKDownloadStateCancelled:
                Log(@"Download Cancelled");
                [self cleanupDownloadedAsset:downloadAsset];
                [self finishTransactionIfNeeded:downloadAsset.transaction];                
                break;
                
            case SKDownloadStateFailed:
                Log(@"Download Failed");
                // If a download fails, it is recommended that you add some retry logic.
                [self cleanupDownloadedAsset:downloadAsset];
                [self finishTransactionIfNeeded:downloadAsset.transaction];
                break;
                
            case SKDownloadStatePaused:
                Log(@"Download Paused");
                // You'll get here if pauseDownloads: was called for the download.  Use resumeDownloads: to continue those downloads.
                break;
                
            case SKDownloadStateFinished:
                Log(@"Download Finished");
                [self processDownloadedAsset:downloadAsset];
                [self finishTransactionIfNeeded:downloadAsset.transaction];
                break;
                
            case SKDownloadStateWaiting:
                Log(@"Download Waiting");
                // Since we already start all downloads when we get a SKPaymentTransactionStatePurchased
                //  or SKPaymentTransactionStateRestored this is just added to play it safe
                Log(@"Start a waiting download");
                [[SKPaymentQueue defaultQueue] startDownloads:[NSArray arrayWithObject:downloadAsset]];
                break;
                
            default:
                Log(@"Invalid downloadState=%d", downloadAsset.downloadState);
                abort();
                break;
        }
    }
}


#pragma mark - Hosted Download Stuff

- (void)processDownloadedAsset:(SKDownload*)downloadAsset
{
    NSString* contentPath = [downloadAsset.contentURL path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:contentPath])
    {
        // Lets copy the download to the Documents folder and puts it within a folder with the transaction id as the name.
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString* transactionFolder = [NSString stringWithFormat:@"%@", downloadAsset.transaction.transactionIdentifier];
        NSString* destPath = [[paths objectAtIndex: 0] stringByAppendingPathComponent:transactionFolder];
        
        NSError* error = nil;
        
        Log(@"Copying %@ -> %@", downloadAsset.contentURL, destPath);
        [[NSFileManager defaultManager] copyItemAtPath:[downloadAsset.contentURL path] toPath:destPath error:&error];
        if(error)
        {
            Log(@"Error copying downloaded asset to the Documents folder. error=%@", error);
        }
        [self cleanupDownloadedAsset:downloadAsset];
    } else {
        Log(@"Download asset file doesn't exist at %@", downloadAsset.contentURL);
    }
}


- (void)cleanupDownloadedAsset:(SKDownload*)downloadAsset
{
    // This should delete the download assets from the Cache folder.
    NSError* error = nil;
    [[NSFileManager defaultManager] removeItemAtURL:downloadAsset.contentURL error:&error];
    
    if(error)
    {
        Log(@"Error removing asset from Cache folder. error=%@", error);
    }
}


- (void)finishTransactionIfNeeded:(SKPaymentTransaction*)transaction
{
    // We should only finish a transaction if all its downloads are complete (in some form).
    BOOL allTransactionDataDownloaded = YES;
    for (SKDownload* download in transaction.downloads)
    {
        // If its not in one of these states, then there is still some downloads pending.
        // Also, for the failed case it is recommended you retry the download again before
        //  finally finishing the transaction.
        if (SKDownloadStateFinished     !=  download.downloadState  &&
            SKDownloadStateFailed       !=  download.downloadState  &&
            SKDownloadStateCancelled    !=  download.downloadState )
        {
            // This trsancation should not be finished as there are some pending downloads.
            allTransactionDataDownloaded = NO;
            break;
        }
    }
    
    // If all downloads are complete lets finish the transaction and post a notification that the download is done.
    if (allTransactionDataDownloaded)
    {
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        [[NSNotificationCenter defaultCenter] postNotificationName:IAPDownloadCompleteNotification object:self];
    }    
}

@end
