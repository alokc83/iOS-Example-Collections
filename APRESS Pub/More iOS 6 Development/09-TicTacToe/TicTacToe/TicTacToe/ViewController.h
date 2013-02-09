//
//  ViewController.h
//  TicTacToe
//
//  Created by Kevin Y. Kim on 10/1/12.
//  Copyright (c) 2012 AppOrchard LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "TicTacToe.h"

@class Packet;

@interface ViewController : UIViewController <GKPeerPickerControllerDelegate, GKSessionDelegate, UIAlertViewDelegate>
{
    GameState _state;
    NSInteger _myDieRoll;
    NSInteger _opponentDieRoll;
    PlayerPiece _playerPiece;
    BOOL _dieRollReceived;
    BOOL _dieRollAcknowledged;
}

@property (nonatomic, strong) GKSession *session;
@property (nonatomic, strong) NSString *peerID;
@property (nonatomic, strong) UIImage *xPieceImage;
@property (nonatomic, strong) UIImage *oPieceImage;

@property (weak, nonatomic) IBOutlet UIButton *gameButton;
@property (weak, nonatomic) IBOutlet UILabel *feedbackLabel;

- (void)resetBoard;
- (void)startNewGame;
- (void)resetDieState;
- (void)startGame;
- (void)sendPacket:(Packet *)packet;
- (void)sendDieRoll;
- (void)checkForGameEnd;

- (IBAction)gameButtonPressed:(id)sender;
- (IBAction)gameSpacePressed:(id)sender;

@end
