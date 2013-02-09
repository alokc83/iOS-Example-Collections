//
//  CertificatesViewController.m
//  KeychainViewer
//
//  Created by Kevin Y. Kim on 9/5/12.
//  Copyright (c) 2012 kykim. inc. All rights reserved.
//

#import "CertificatesViewController.h"
#import "KeychainCertificate.h"
#import "KeychainItemViewController.h"

@interface CertificatesViewController ()

@end

@implementation CertificatesViewController

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
    self.items = [KeychainCertificate allKeychainCertificates];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"CertificateSegue"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        KeychainCertificate *cert = self.items[indexPath.row];
        KeychainItemViewController *kivc = [segue destinationViewController];
        kivc.item = cert;
    }
}

@end
