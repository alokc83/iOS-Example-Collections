
### IAPSample ###

===========================================================================
DESCRIPTION:

This sample demonstrates a number of aspects of the StoreKit framework. It shows how you can:
1) Request product details from the iTunes Store (SKProductsRequest, SKProductsRequestDelegate).
2) Make regular in-app purchases. (SKPaymentQueue, SKPaymentTransactionObserver).
3) Download hosted content from the iTunes servers for in-app purchases. (New download APIs/callbacks in SKPaymentQueue/SKPaymentTransactionObserver).
4) Purchase another app (the iTunes Trailer App) within the app (SKStoreProductViewController).



Special Note:

In-app purchase requires you to do some setup in iTunes Connect: you must perform the following steps to see this app actually work against the iTunes sandbox.
• Update the CFBundleIdentifier of the app to something that you've defined in iTunes Connect.
• Update the product ids in the sample code (which are currently #defined with the prefix IAP_PRODUCT_ID_). 
• Create an iTunes Sandbox test user, so you can actually make purchases.
Please refer to the iTunes Developer Guide (available at https://itunesconnect.apple.com/docs/iTunesConnect_DeveloperGuide.pdf) for additional details on how to setup these steps.



UI/Usage Flow:

The app has a minimal user interface to reinforce the idea that the example is not specific to any particular UI. You should, however, inspect the console log, which should help you understand what's going on as the in-app purchase moves through the various states in StoreKit's payment queue.

The UI contains just 4 buttons managed by a single view controller, one for each of the features specified above in the outline.

• Tap the first button to complete #1 specified above. Once that completes and the iTunes Store returns the valid products for the regular IAP and hosted IAP, the buttons for #2 and #3 will be enabled so you can purchase those products.
• As purchases are processed StoreKit, presents the standard in-app purchase alerts. For the IAP hosted content downloads, once the purchase completes the app will download the content and move it to the app's documents directory upon download completion.  The app will have iTunes File sharing enabled and you will be able to download/view the content via iTunes/Xcode.
• For #4, when you tap the corresponding button, the in-app store sheet will display the iTunes Trailer app and allow you to purchase the corresponding app.


===========================================================================
Copyright (C) 2012 Apple Inc. All rights reserved.
