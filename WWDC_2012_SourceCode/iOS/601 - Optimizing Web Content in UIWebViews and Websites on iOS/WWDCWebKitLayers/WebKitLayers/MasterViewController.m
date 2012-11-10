//     File: MasterViewController.m
// Abstract: MasterViewController defines and populates the demo page list.
//  Version: 1.0
// 
// Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
// Inc. ("Apple") in consideration of your agreement to the following
// terms, and your use, installation, modification or redistribution of
// this Apple software constitutes acceptance of these terms.  If you do
// not agree with these terms, please do not use, install, modify or
// redistribute this Apple software.
// 
// In consideration of your agreement to abide by the following terms, and
// subject to these terms, Apple grants you a personal, non-exclusive
// license, under Apple's copyrights in this original Apple software (the
// "Apple Software"), to use, reproduce, modify and redistribute the Apple
// Software, with or without modifications, in source and/or binary forms;
// provided that if you redistribute the Apple Software in its entirety and
// without modifications, you must retain this notice and the following
// text and disclaimers in all such redistributions of the Apple Software.
// Neither the name, trademarks, service marks or logos of Apple Inc. may
// be used to endorse or promote products derived from the Apple Software
// without specific prior written permission from Apple.  Except as
// expressly stated in this notice, no other rights or licenses, express or
// implied, are granted by Apple herein, including but not limited to any
// patent rights that may be infringed by your derivative works or by other
// works in which the Apple Software may be incorporated.
// 
// The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
// MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
// THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
// OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
// 
// IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
// OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
// MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
// AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
// STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
// 
// Copyright (C) 2012 Apple Inc. All Rights Reserved.
// 
// 
// WWDC 2012 License
// 
// NOTE: This Apple Software was supplied by Apple as part of a WWDC 2012
// Session. Please refer to the applicable WWDC 2012 Session for further
// information.
// 
// IMPORTANT: This Apple software is supplied to you by Apple
// Inc. ("Apple") in consideration of your agreement to the following
// terms, and your use, installation, modification or redistribution of
// this Apple software constitutes acceptance of these terms.  If you do
// not agree with these terms, please do not use, install, modify or
// redistribute this Apple software.
// 
// In consideration of your agreement to abide by the following terms, and
// subject to these terms, Apple grants you a non-exclusive license, under
// Apple's copyrights in this original Apple software (the "Apple
// Software"), to use, reproduce, modify and redistribute the Apple
// Software, with or without modifications, in source and/or binary forms;
// provided that if you redistribute the Apple Software in its entirety and
// without modifications, you must retain this notice and the following
// text and disclaimers in all such redistributions of the Apple Software.
// Neither the name, trademarks, service marks or logos of Apple Inc. may
// be used to endorse or promote products derived from the Apple Software
// without specific prior written permission from Apple.  Except as
// expressly stated in this notice, no other rights or licenses, express or
// implied, are granted by Apple herein, including but not limited to any
// patent rights that may be infringed by your derivative works or by other
// works in which the Apple Software may be incorporated.
// 
// The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
// MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
// THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
// OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
// 
// IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
// OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
// MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
// AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
// STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
// 

#import "MasterViewController.h"

#import "DetailViewController.h"
#import "URLItem.h"

static NSInteger const kSwitchSection = 0;
static NSString * const kLayerBordersKey = @"WebKitShowDebugBorders";


@interface MasterViewController ()
@property (nonatomic, strong) NSArray *urls;
@property (nonatomic, strong) UISwitch *layerBordersSwitch;
@end

@implementation MasterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self)
        return nil;

    self.title = NSLocalizedString(@"Demo Pages", @"Demo Pages");
    self.urls = @[
        [[URLItem alloc]
            initWithTitle:@"Flashing Content"
            bundleFile:@"index"
            directory:@"page-1"
            actionTitle:@"Toggle Layers"
            handler:^(UIWebView *webView) {
                // Toggle "-webkit-transform:translateZ(0)" on particular items by adding/remove the ".split" className.
                [webView stringByEvaluatingJavaScriptFromString:@" \
                    document.body.classList.toggle('split');       \
                "];
            }],
        [[URLItem alloc]
             initWithTitle:@"Large Layers"
             bundleFile:@"one-up"
             directory:@"page-1"
             actionTitle:nil
             handler:nil],
        [[URLItem alloc]
            initWithTitle:@"Unnecessary Layers"
            urlString:@"http://nytimes.com"
            actionTitle:@"Toggle Layers"
            handler:^(UIWebView *webView) {
                // Toggle injecting "<style id='injected-style-element'>* { -webkit-transform:translateZ(0); }</style>" in the page.
                [webView stringByEvaluatingJavaScriptFromString:@"                      \
                     const styleID = 'injected-style-element';                          \
                     var style = document.getElementById(styleID);                      \
                     if (style)                                                         \
                         style.parentNode.removeChild(style);                           \
                     else {                                                             \
                         style = document.createElement('style');                       \
                         style.id = styleID;                                            \
                         style.textContent = '* { -webkit-transform: translateZ(0); }'; \
                         document.head.appendChild(style);                              \
                     }                                                                  \
                 "];
            }],
        [[URLItem alloc]
            initWithTitle:@"Accidental Layers"
            bundleFile:@"index"
            directory:@"page-2"
            actionTitle:@"Toggle Header"
            handler:^(UIWebView *webView) {
                // Toggle the position:fixed div#background to show its effects.
                [webView stringByEvaluatingJavaScriptFromString:@"          \
                    var background = document.getElementById('background'); \
                    background.hidden = !background.hidden;                 \
                "];
            }],
        [[URLItem alloc]
            initWithTitle:@"Animations"
            urlString:@"http://www.webkit.org/blog-files/leaves/"
            actionTitle:nil
            handler:nil],
    ];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }
    
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.layerBordersSwitch = [[UISwitch alloc] init];
    self.layerBordersSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:kLayerBordersKey];
    [self.layerBordersSwitch addTarget:self action:@selector(_switchChanged:) forControlEvents:UIControlEventValueChanged];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - UISwitch Delegate

- (void)_switchChanged:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:self.layerBordersSwitch.on forKey:kLayerBordersKey];

    NSString *title = self.layerBordersSwitch.on ? @"WebKit Debug Borders Enabled" : @"WebKit Debug Borders Disabled";
    NSString *message = @"You must restart the application for the changes to take effect.";
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}


#pragma mark - TableView DataSource and Delegate

- (UITableViewCell *)_tableViewCreateSwitchCell:(UITableView *)tableView
{
    static NSString *kSwitchCellIdentifier = @"DemoTableSwitchCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kSwitchCellIdentifier];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSwitchCellIdentifier];

    self.layerBordersSwitch.frame = CGRectMake(236.0, 9.0, 94.0, 27.0);
    cell.textLabel.text = @"WebKit Debug Borders";
    [cell.contentView addSubview:self.layerBordersSwitch];

    return cell;
}

- (UITableViewCell *)_tableView:(UITableView *)tableView createURLCellWithTitle:(NSString *)url
{
    static NSString *kCellIdentifier = @"DemoTableURLCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    cell.textLabel.text = url;

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kSwitchSection)
        return 1;
    return self.urls.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == kSwitchSection)
        return @"Settings";
    return @"Pages";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kSwitchSection)
        return [self _tableViewCreateSwitchCell:tableView];

    URLItem *urlItem = self.urls[indexPath.row];
    return [self _tableView:tableView createURLCellWithTitle:urlItem.title];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kSwitchSection)
        return NO;
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kSwitchSection)
        return;

    URLItem *urlItem = self.urls[indexPath.row];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    if (!self.detailViewController)
	        self.detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController_iPhone" bundle:nil];
	    self.detailViewController.detailItem = urlItem;
        [self.navigationController pushViewController:self.detailViewController animated:YES];
    } else
        self.detailViewController.detailItem = urlItem;
}

@end
