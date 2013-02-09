//
//  IdentityViewController.m
//  KeychainViewer
//
//  Created by Kevin Y. Kim on 9/5/12.
//  Copyright (c) 2012 kykim. inc. All rights reserved.
//

#import "IdentityViewController.h"
#import "KeychainIdentity.h"

@interface IdentityViewController () {
    NSData *_encryptedData;
}
- (void)encrypt;
- (void)decrypt;
@end

@implementation IdentityViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)crypt:(id)sender
{
    if (_encryptedData)
        [self decrypt];
    else
        [self encrypt];
}

- (void)encrypt
{
    KeychainIdentity *ident = (KeychainIdentity *)self.item;
    NSData *data = [self.textView.text dataUsingEncoding:NSUTF8StringEncoding];
    _encryptedData = [ident encrypt:data];
    if (_encryptedData == nil) {
        NSLog(@"Encryption Failed");
        return;
    }
    
    self.textView.text = [_encryptedData description];
    [self.cryptButton setTitle:@"Decrypt" forState:UIControlStateNormal];
}

- (void)decrypt
{
    KeychainIdentity *ident = (KeychainIdentity *)self.item;
    NSData *data = [ident decrypt:_encryptedData];
    if (data == nil) {
        NSLog(@"Decryption Failed");
        return;
    }
    
    NSString *decryptedString = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
    _encryptedData = nil;
    self.textView.text = decryptedString;
    [self.cryptButton setTitle:@"Encrypt" forState:UIControlStateNormal];
}


@end
