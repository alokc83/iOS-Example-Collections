//
//  MSDetailViewController.m
//  MeetSocial
//
//  Created by Bear Cahill on 7/21/12.
//  Copyright (c) 2012 BrainwashInc.com. All rights reserved.
//

#import "MSDetailViewController.h"
#import "JSON.h"

@interface MSDetailViewController () 
{
    NSDateFormatter *dateFormatter;
    NSDictionary *selectedItem;
    NSArray *displayItems;
}
@end

@implementation MSDetailViewController

- (void)dealloc
{
    [dateFormatter release];
    [selectedItem release];
    [displayItems release];
    [super dealloc];
}

#pragma mark - Managing the detail item

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.restorationClass = [self class];
    [self setTitle:@"Results"];
}

//- (void) encodeRestorableStateWithCoder:(NSCoder *)coder NS_AVAILABLE_IOS(6_0);
//{
//    [super encodeRestorableStateWithCoder:coder];
//}
//
//- (void) decodeRestorableStateWithCoder:(NSCoder *)coder NS_AVAILABLE_IOS(6_0);
//{
//    [super decodeRestorableStateWithCoder:coder];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*) readResultsFile
{
    //get the documents directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *fileName = [NSString stringWithFormat:@"%@/results.json",
                          documentsDirectory];
    NSError *error = nil;
    NSString *content = [[[NSString alloc] initWithContentsOfFile:fileName
                                                     usedEncoding:nil
                                                            error:&error] autorelease];
    if (error)
    {
        NSLog(@"read error: %@", error);
        return nil;
    }
    
    return content;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (UIInterfaceOrientationIsPortrait(interfaceOrientation));
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
    NSString *resultsJSON = [self readResultsFile];
    
    NSDictionary* resultsDict = [resultsJSON JSONValue];
    if (resultsDict)
    {
        [displayItems release];
        displayItems = [[resultsDict objectForKey:@"results"] retain];
    }
    
    return [displayItems count];
}

static NSString *CellIdentifier = @"ResultsCell";

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.contentView.backgroundColor = [UIColor darkGrayColor];
    
    NSDictionary *item = [displayItems objectAtIndex:indexPath.row];
    NSString *photoURL = [item objectForKey:@"photo_url"];
    NSDecimalNumber *time = [item objectForKey:@"time"];
    
    UIImageView *iv = nil;
    UILabel *lbl = nil;
    
    for (UIView *v in cell.contentView.subviews)
    {
        if ([v isKindOfClass:[UIImageView class]])
        {
            iv = (UIImageView*)v;
            [iv.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        else if ([v isKindOfClass:[UILabel class]])
            lbl = (UILabel*)v;
    }
    
    [iv setImage:nil];
    [lbl setText:[item objectForKey:@"name"]];
    
    if (photoURL)
    {
        if ([photoURL length] > 0)
            [iv setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoURL]]]];
    }
    else if (time)
    {
        if ([time floatValue] > 0)
        {
            if (!dateFormatter)
            {
                dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
                [dateFormatter setDateFormat:@"M/d/YY H:MM"];
            }
            
            NSDate *eventDate = [NSDate dateWithTimeIntervalSince1970:[time floatValue]/1000];
            NSString *dateStr = [dateFormatter stringFromDate:eventDate];
            
            UILabel *lblDate = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 90, 90)] autorelease];
            [lblDate setNumberOfLines:2];
            [lblDate setFont:[UIFont boldSystemFontOfSize:22]];
            [lblDate setLineBreakMode:NSLineBreakByWordWrapping];
            [lblDate setTextAlignment:NSTextAlignmentCenter];
            [lblDate setTextColor:[UIColor whiteColor]];
            [lblDate setBackgroundColor:[UIColor blackColor]];
            [lblDate setText:dateStr];
            [iv addSubview:lblDate];
        }
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
{
    [selectedItem release];
    selectedItem = [[displayItems objectAtIndex:indexPath.row] retain];
    NSString *url = [selectedItem objectForKey:@"link"];
    
    UIAlertView *av = nil;
    if (url)
        av = [[[UIAlertView alloc] initWithTitle:@"Details" message:@"Would you like to..." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"See Group Page", @"Share", nil] autorelease];
    else
        av = [[[UIAlertView alloc] initWithTitle:@"Details" message:@"Would you like to..." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"See Event Page", @"Share", @"Create Cal Item", @"Create Reminder", nil] autorelease];
    
    [av show];
}

- (void)eventEditViewController:(EKEventEditViewController *)controller didCompleteWithAction:(EKEventEditViewAction)action;
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)createCalItem;
{
    EKEventStore *eStore = [[[EKEventStore alloc] init] autorelease];
    
    EKEvent *event = [EKEvent eventWithEventStore:eStore];
    [event setCalendar:[eStore defaultCalendarForNewEvents]];
    [event setTitle:[selectedItem objectForKey:@"name"]];

    NSDecimalNumber *time = [selectedItem objectForKey:@"time"];
    NSDate *eventDate = [NSDate dateWithTimeIntervalSince1970:
                          [time floatValue]/1000];

    [event setStartDate:eventDate];
    [event setEndDate:eventDate];
    NSError *error = nil;
    [eStore saveEvent:event span:EKSpanThisEvent
               commit:YES error:&error];
    if (error)
        NSLog(@"Saving createCalItem: %@", error);
    
    EKEventEditViewController *editEvent =
        [[[EKEventEditViewController alloc] init] autorelease];
    [editEvent setEditViewDelegate:self];
    [editEvent setEvent:event];
    [self presentViewController:editEvent animated:YES completion:nil];
}

-(void)createReminderItem;
{
    EKEventStore *eStore = [[[EKEventStore alloc] init] autorelease];

    NSDecimalNumber *time = [selectedItem objectForKey:@"time"];
    NSDate *eventDate = [NSDate dateWithTimeIntervalSince1970:
                          [time floatValue]/1000];

    EKReminder *reminder = [EKReminder reminderWithEventStore:eStore];

    NSCalendar *gregorian = [[[NSCalendar alloc]
                              initWithCalendarIdentifier:
                              NSGregorianCalendar]
                             retain];
    NSDateComponents *comps = [gregorian components:
                               (NSDayCalendarUnit | NSMonthCalendarUnit
                                    | NSYearCalendarUnit)
                                fromDate:eventDate];
    [comps setDay:[comps day]];
    [comps setMonth:[comps month]];
    [comps setYear:[comps year]];

    [reminder setCalendar:[eStore defaultCalendarForNewReminders]];
    [reminder setTitle:[selectedItem objectForKey:@"name"]];
    [reminder setDueDateComponents:comps];

    NSError *error = nil;
    [eStore saveReminder:reminder commit:YES error:&error];
    if (error)
        NSLog(@"Saving createCalItem: %@", error);

    UIAlertView *av = [[[UIAlertView alloc]
                        initWithTitle:@"Reminder"
                        message:@"Reminder created!"
                        delegate:nil cancelButtonTitle:nil
                        otherButtonTitles:@"OK", nil]
                       autorelease];
    [av show];
}

-(bool)isAuthorizedForEntityType:(EKEntityType)type;
{
    EKAuthorizationStatus authStatus =
        [EKEventStore authorizationStatusForEntityType:type];
    if (authStatus != EKAuthorizationStatusAuthorized)
    {
        [[EKEventStore alloc]
            requestAccessToEntityType:EKEntityTypeEvent
            completion:^ (BOOL granted, NSError *error)
         {
             if (granted)
             {
                 if (type == EKEntityTypeEvent)
                     [self createCalItem];
                 else
                     [self createReminderItem];
             }
             else
             {
                 UIAlertView *av = [[[UIAlertView alloc]
                    initWithTitle:@"Permissions"
                    message:@"If you deny the app permissions, you can not \
                                     create calendar events.\n\nYou can \
                                     change your permissiongs in the Settings \
                                     app under Privacy."
                        delegate:nil
                        cancelButtonTitle:nil
                        otherButtonTitles:@"OK", nil] autorelease];
                 [av show];
             }
         }];
        return NO;
    }
    else
        return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex == 0)
        return;
    
    if (buttonIndex == 2)
    {
        [self share];
    }
    else
    {
        NSString *url = [selectedItem objectForKey:@"link"];
        
        if (url)
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        else 
        {
            if (buttonIndex == 1)
            {
                NSString *url = [selectedItem objectForKey:@"event_url"];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
            }
            else
            {
                if (buttonIndex == 3)
                {
                    if ([self isAuthorizedForEntityType:EKEntityTypeEvent])
                        [self createCalItem];
                }
                else
                {
                    if ([self isAuthorizedForEntityType:EKEntityTypeReminder])
                        [self createReminderItem];
                }
            }
        }
    }
}

-(void)share;
{
    NSString *url = [selectedItem objectForKey:@"link"];
    NSString *textToShare = [selectedItem objectForKey:@"name"];
    
    UIImage *imageToShare = nil;
    NSArray *activityItems = nil;
    if (url)
    {
        NSString *photoURL = [selectedItem objectForKey:@"photo_url"];
        imageToShare = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:photoURL]]];
        activityItems = @[textToShare, url, imageToShare];
    }
    else
    {
        url = [selectedItem objectForKey:@"event_url"];
        
        NSDecimalNumber *time = [selectedItem objectForKey:@"time"];
        NSDate *eventDate = [[NSDate dateWithTimeIntervalSince1970:[time floatValue]/1000] autorelease];
        NSString *dateStr = [dateFormatter stringFromDate:eventDate];
        
        activityItems = @[textToShare, url, dateStr];
    }
    
    UIActivityViewController *activityVC =
    [[[UIActivityViewController alloc] initWithActivityItems:activityItems
                                       applicationActivities:nil] autorelease];
    [self presentViewController:activityVC animated:YES completion:nil];
}

+ (UIViewController *) viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder;
{
    UIStoryboard* sb = [coder decodeObjectForKey:UIStateRestorationViewControllerStoryboardKey];
    NSString* lastID = [identifierComponents lastObject];
    if (sb)
        return (MSDetailViewController*)[sb instantiateViewControllerWithIdentifier:lastID];
    return nil;
}

- (NSString *) modelIdentifierForElementAtIndexPath:(NSIndexPath *)idx inView:(UIView *)view;
{
    NSDictionary *item = [displayItems objectAtIndex:idx.row];
    NSLog(@"modelID: %@", [NSString stringWithFormat:@"%@", [item objectForKey:@"id"]]);
    return [NSString stringWithFormat:@"%@", [item objectForKey:@"id"]];
}

- (NSIndexPath *) indexPathForElementWithModelIdentifier:(NSString *)identifier inView:(UIView *)view;
{
    NSLog(@"ip for model id: %@", identifier);
    int cnt = 0;
    for (NSDictionary *item in displayItems)
    {
        if ([[item objectForKey:@"id"] isEqualToString:identifier])
            return [NSIndexPath indexPathForRow:cnt inSection:0];
        cnt++;
    }
    return nil;
}

@end
