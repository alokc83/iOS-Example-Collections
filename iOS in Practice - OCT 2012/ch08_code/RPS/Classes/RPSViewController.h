//
//  RPSViewController.h
//  RPS
//
//  Created by Bear Cahill on 9/3/10.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APNSender.h"
#import <StoreKit/StoreKit.h>
#import "UtilGameCenter.h"
#import <AVFoundation/AVFoundation.h>

#define RPSOverturn @"100"
#define RPSOverturnCount @"RPSOverturnCount"

#define ROCK 0
#define PAPER 1
#define SCISSORS 2

@interface RPSViewController : UIViewController <SKPaymentTransactionObserver, UINavigationControllerDelegate> {

IBOutlet UIButton *btnRock;
IBOutlet UIButton *btnPaper;
IBOutlet UIButton *btnScissors;
IBOutlet UIButton *btnOverturn;
    
    int myChoice;
    int gamePoints;
    bool isWin;
    
    IBOutlet UILabel *lblPoints;
    IBOutlet UILabel *lblMessage;
    
    UtilGameCenter *gameCenter;
    
    bool inAGame;
    GKMatch *gameMatch;
    int opponentChoice;
    GKVoiceChat *chat;
    
}
- (IBAction)doBtnPush:(id)sender;
- (IBAction)doBtnBuy:(id)sender;
- (IBAction)doBtnOverturn:(id)sender;

- (IBAction)doBtnRock:(id)sender;
- (IBAction)doBtnPaper:(id)sender;
- (IBAction)doBtnScissors:(id)sender;

- (IBAction)doBtnSave:(id)sender;
- (IBAction)doBtnScores:(id)sender;
- (IBAction)doBtnAchievements:(id)sender;
- (IBAction)doBtnPlay:(id)sender;
- (IBAction)doBtnChat:(id)sender;
@end

