//
//  KeychainItemViewController.m
//  KeychainViewer
//
//  Created by Kevin Y. Kim on 9/5/12.
//  Copyright (c) 2012 kykim. inc. All rights reserved.
//

#import "KeychainItemViewController.h"
#import "KeychainItem.h"

@interface KeychainItemViewController ()

@end

@implementation KeychainItemViewController

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

- (void)viewWillAppear:(BOOL)animated
{
    if (self.item) {
        NSMutableString *itemInfo = [NSMutableString string];
        [itemInfo appendFormat:@"AccessGroup: %@\n", [self.item valueForAttribute:kSecAttrAccessGroup]];
        [itemInfo appendFormat:@"CreationDate: %@\n", [self.item valueForAttribute:kSecAttrCreationDate]];
        [itemInfo appendFormat:@"CertificateEncoding: %@\n", [self.item valueForAttribute:kSecAttrCertificateEncoding]];
        [itemInfo appendFormat:@"CreationDate: %@\n", [self.item valueForAttribute:kSecClass]];
        [itemInfo appendFormat:@"Issuer: %@\n", [self.item valueForAttribute:kSecAttrIssuer]];
        [itemInfo appendFormat:@"Label: %@\n", [self.item valueForAttribute:kSecAttrLabel]];
        [itemInfo appendFormat:@"ModificationDate: %@\n", [self.item valueForAttribute:kSecAttrModificationDate]];
        [itemInfo appendFormat:@"Accessible: %@\n", [self.item valueForAttribute:kSecAttrAccessible]];
        [itemInfo appendFormat:@"PublicKeyHash: %@\n", [self.item valueForAttribute:kSecAttrPublicKeyHash]];
        [itemInfo appendFormat:@"SerialNumber: %@\n", [self.item valueForAttribute:kSecAttrSerialNumber]];
        [itemInfo appendFormat:@"Subject: %@\n", [self.item valueForAttribute:kSecAttrSubject]];
        self.textView.text = itemInfo;
    }
}

- (IBAction)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
