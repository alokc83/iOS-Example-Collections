//
//  RPSViewController.m
//  RPS
//
//  Created by Bear Cahill on 9/3/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "RPSViewController.h"

@implementation RPSViewController

-(void)processOtherPlayersChoice:(int)otherPlayerChoice;
{    
    isWin = NO;
    NSLog(@"My Choice: %d Other Player's Choice: %d", myChoice, otherPlayerChoice);
    if (otherPlayerChoice != myChoice)
    {
        int diff = myChoice - otherPlayerChoice;
        if (diff == 1 || diff == -2)
        {
            gamePoints++;
            isWin = YES;
            [lblMessage setText:@"You win!"];
        }
        else
            [lblMessage setText:@"You lose."];
    }
    NSLog(@"Win: %@ Points: %d", isWin ? @"Yes" : @"No", gamePoints);
    [lblPoints setText:[NSString stringWithFormat:@"Points: %d", gamePoints]];
    myChoice = -1;
    opponentChoice = -1;
}

-(void)waitForOtherPlayer;
{
    if (inAGame)
    {
        [lblMessage setText:@"Waiting for other player..."];
        NSString *choice = [NSString stringWithFormat:@"%d", myChoice];
        NSData *data = [choice dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        [gameMatch sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
    }
    else
    {
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:@"Not Playing" 
							  message:@"Please press play to start a game."
							  delegate:self 
							  cancelButtonTitle:@"OK" 
							  otherButtonTitles: nil];
		[alert show];
    }
    
//    int otherPlayerChoice = rand()%3;
//    [self processOtherPlayersChoice:otherPlayerChoice];
}

-(void)sendMyChoice;
{
    NSString *choice = [NSString stringWithFormat:@"%d", myChoice];
    NSData *data = [choice dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    [gameMatch sendDataToAllPlayers:data withDataMode:GKMatchSendDataReliable error:&error];
}

- (IBAction)doBtnRock:(id)sender;
{
    myChoice = ROCK;
    if (opponentChoice == -1)
        [self waitForOtherPlayer];
    else 
    {
        [self sendMyChoice];
        [self processOtherPlayersChoice:opponentChoice];
    }
}

- (IBAction)doBtnPaper:(id)sender;
{
    myChoice = PAPER;
    if (opponentChoice == -1)
        [self waitForOtherPlayer];
    else 
    {
        [self sendMyChoice];
        [self processOtherPlayersChoice:opponentChoice];
    }
}

- (IBAction)doBtnScissors:(id)sender;
{
    myChoice = SCISSORS;
    if (opponentChoice == -1)
        [self waitForOtherPlayer];
    else 
    {
        [self sendMyChoice];
        [self processOtherPlayersChoice:opponentChoice];
    }
}

-(IBAction)doBtnOverturn:(id)sender;
{
	int overturns = [[NSUserDefaults standardUserDefaults] 
					 integerForKey:RPSOverturnCount];
    if (overturns == 0)
    {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Overturns" message:@"You do not currently have any overturns.\n\nTap 'Buy' below to buy overturn credits." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
        return;
    }
    else
    {
        if (isWin)
        {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"No Overturns" message:@"Ummm, but you won." delegate:nil cancelButtonTitle:@"Oops" otherButtonTitles:nil];
            [av show];
            return;
        }
        overturns--;
        [[NSUserDefaults standardUserDefaults] 
         setInteger:overturns 
         forKey:RPSOverturnCount];
        isWin = YES;
        gamePoints++;
        [lblPoints setText:[NSString stringWithFormat:@"Points: %d", gamePoints]];
        [APNSender sendAPNWithMsg:@"I just overturned a loss!"];

    }
}

-(IBAction)doBtnSave:(id)sender;
{
    if (gameCenter.gameCenterFeaturesEnabled)
    {
        [gameCenter reportScore:gamePoints];
        if (gamePoints < 101)
            [gameCenter reportPercentage:gamePoints ofAchievement:@"com.brainwashinc.RPS.HundredPoints"];
    }
}

- (IBAction)doBtnScores:(id)sender;
{
    if (gameCenter.gameCenterFeaturesEnabled)
        [gameCenter showLeaderboardToVC:self forCategory:@"com.brainwashinc.RPS.HighScoreCategory"];
}

- (IBAction)doBtnAchievements:(id)sender;
{
    if (gameCenter.gameCenterFeaturesEnabled)
        [gameCenter showAchievementsToVC:self];
}

- (IBAction)doBtnPush:(id)sender;
{
    [APNSender sendAPNWithMsg:@"Test"];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
		NSString *messageToBeShown = [NSString 
			stringWithFormat:@"Reason: %@, You can try: %@", 
			  [transaction.error localizedFailureReason], 
			  [transaction.error localizedRecoverySuggestion]];
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:@"Unable to complete your purchase" 
							  message:messageToBeShown
							  delegate:self 
							  cancelButtonTitle:@"OK" 
							  otherButtonTitles: nil];
		[alert show];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];	
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];	
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
	int overturns = [[NSUserDefaults standardUserDefaults] 
					 integerForKey:RPSOverturnCount];
	overturns++;
	NSLog(@"number of overturns: %d", overturns);
	[[NSUserDefaults standardUserDefaults] 
					 setInteger:overturns 
					 forKey:RPSOverturnCount];
	
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];	
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }	
}

- (IBAction)doBtnBuy:(id)sender;
{
	if ([SKPaymentQueue canMakePayments])
	{
		SKPayment *payment = [SKPayment 
							  paymentWithProductIdentifier:RPSOverturn];
		[[SKPaymentQueue defaultQueue] 
		 addPayment:payment];
		[[SKPaymentQueue defaultQueue] 
		 addTransactionObserver:self];
	}
	else
	{
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:@"Not Authorized" 
							  message:@"Not authorized to purchase."
							  delegate:self 
							  cancelButtonTitle:@"OK" 
							  otherButtonTitles: nil];
		[alert show];
	}
}

- (void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    NSString *otherPlayersChoice = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    opponentChoice = [otherPlayersChoice intValue];
    if (myChoice != -1)
    {
        [lblMessage setText:@"Player selected."];
        [self processOtherPlayersChoice:opponentChoice];
    }
    else 
        [lblMessage setText:@"Other player selected. Waiting for you..."];
}

- (void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state
{
    if (state == GKPlayerStateConnected)
    {
        inAGame = YES;
        gameMatch = match;
        [lblMessage setText:@"Match Found. Play!"];
    }
    else if (state == GKPlayerStateDisconnected)
    {
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:@"Disconnected" 
							  message:@"The other player disconnected."
							  delegate:self 
							  cancelButtonTitle:@"OK" 
							  otherButtonTitles: nil];
		[alert show];
        inAGame = NO;
    }
}

-(void)startChat;
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error;
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    [audioSession setActive:YES error:&error];
}

-(IBAction)doBtnChat:(id)sender;
{
    if (nil == gameMatch)
    {
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:@"No Game" 
							  message:@"You are not currently in a game."
							  delegate:self 
							  cancelButtonTitle:@"OK" 
							  otherButtonTitles: nil];
		[alert show];
        inAGame = NO;
        return;
    }
    
    chat = [gameMatch voiceChatWithName:@"RPS"];
    [chat start];
}

- (IBAction)doBtnPlay:(id)sender;
{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Play" message:@"Would you like to invite a friend or play a random player?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Invite", @"Random", nil];
    [av show];
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewControllerdidFindMatch:(GKMatch *)match
{
    inAGame = YES;
    gameMatch = match;
    [lblMessage setText:@"Match Found. Play!"]; 
    [self dismissModalViewControllerAnimated:YES];
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindPlayers:(NSArray *)playerIDs
{
    [self dismissModalViewControllerAnimated:YES];
    // for hosted setup - still required method
}

- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController
{
    [self dismissModalViewControllerAnimated:YES];
    [lblMessage setText:@"Nevermind."];
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
    [lblMessage setText:@"Invite failed."];    
}

-(void)inviteFriend;
{
    inAGame = NO;
    myChoice = -1;
    opponentChoice = -1;
    if (gameCenter.gameCenterFeaturesEnabled)
    {
        [lblMessage setText:@"Inviting friend..."];
        [gameCenter inviteMatchWithMatchDelegate:self];
    }
    else 
    {
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:@"Authenticate" 
							  message:@"You have not been authenticated into GameCenter yet."
							  delegate:self 
							  cancelButtonTitle:@"OK" 
							  otherButtonTitles: nil];
		[alert show];
    }
}

-(void)autoMatch;
{
    inAGame = NO;
    myChoice = -1;
    opponentChoice = -1;
    if (gameCenter.gameCenterFeaturesEnabled)
    {
        [lblMessage setText:@"Waiting for match..."];
        [gameCenter fetchMatchWithMatchDelegate:self];
    }
    else 
    {
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:@"Authenticate" 
							  message:@"You have not been authenticated into GameCenter yet."
							  delegate:self 
							  cancelButtonTitle:@"OK" 
							  otherButtonTitles: nil];
		[alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
        [self inviteFriend];
    else if (buttonIndex == 2)
        [self autoMatch];
}


/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [lblMessage setText:@"Authenticating..."];
    gameCenter = [[UtilGameCenter alloc] init];
    
    [GKMatchmaker sharedMatchmaker].inviteHandler = ^(GKInvite *invite, NSArray *playersToInvite) {
        GKMatchmakerViewController *controller = [[GKMatchmakerViewController alloc] initWithInvite:invite];
        controller.delegate = self;
        [self presentModalViewController:controller animated:YES];
    };    
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}



@end
