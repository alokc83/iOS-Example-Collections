//
//  ViewController.m
//  TicTacToe
//
//  Created by Kevin Y. Kim on 10/1/12.
//  Copyright (c) 2012 AppOrchard LLC. All rights reserved.
//

#import "ViewController.h"
#import "Packet.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _myDieRoll = kDiceNotRolled;
    self.oPieceImage = [UIImage imageNamed:@"O.png"];
    self.xPieceImage = [UIImage imageNamed:@"X.png"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.session.available = NO;
    [self.session disconnectFromAllPeers];
    [self.session setDataReceiveHandler: nil withContext: nil];
    self.session.delegate = nil;
}

#pragma mark - Game-Specific Actions

- (IBAction)gameButtonPressed:(id)sender
{
    _dieRollReceived = NO;
    _dieRollAcknowledged = NO;
    
    _gameButton.hidden = YES;
    GKPeerPickerController *picker = [[GKPeerPickerController alloc] init];
    picker.delegate = self;
    [picker show];
}

- (IBAction)gameSpacePressed:(id)sender
{
    UIButton *buttonPressed = sender;
    if (_state == kGameStateMyTurn && [buttonPressed imageForState:UIControlStateNormal] == nil) {
        [buttonPressed setImage:((_playerPiece == kPlayerPieceO) ? self.oPieceImage : self.xPieceImage)
                       forState:UIControlStateNormal];
        _feedbackLabel.text = NSLocalizedString(@"Opponent's Turn", @"Opponent's Turn");
        _state = kGameStateYourTurn;
        
        Packet *packet = [[Packet alloc] initMovePacketWithSpace:buttonPressed.tag];
        [self sendPacket:packet];
        
        [self checkForGameEnd];
    }
}

#pragma mark - GameKit Peer Picker Delegate Methods

- (GKSession *)peerPickerController:(GKPeerPickerController *)picker
           sessionForConnectionType:(GKPeerPickerConnectionType)type
{
    GKSession *theSession;
    if (type == GKPeerPickerConnectionTypeNearby)
        theSession = [[GKSession alloc] initWithSessionID:kTicTacToeSessionID
                                              displayName:nil
                                              sessionMode:GKSessionModePeer];
    return theSession;
}

- (void)peerPickerController:(GKPeerPickerController *)picker
              didConnectPeer:(NSString *)thePeerID
                   toSession:(GKSession *)theSession
{
    self.peerID = thePeerID;
    self.session = theSession;
    self.session.delegate = self;
    [self.session setDataReceiveHandler:self withContext:NULL];
    [picker dismiss];
    picker.delegate = nil;
    [self startNewGame];
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
{
    self.gameButton.hidden = NO;
}

#pragma mark - GameKit Session Delegate Methods

- (void)session:(GKSession *)theSession didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:NSLocalizedString(@"Error Connecting!", @"Error Connecting!")
                          message:NSLocalizedString(@"Unable to establish the connection.",
                                                    @"Unable to establish the connection.")
                          delegate:self
                          cancelButtonTitle:NSLocalizedString(@"Bummer", @"Bummer")
                          otherButtonTitles:nil];
    [alert show];
    theSession.available = NO;
    [theSession disconnectFromAllPeers];
    theSession.delegate = nil;
    [theSession setDataReceiveHandler:nil withContext:nil];
    self.session = nil;
}

- (void)session:(GKSession *)theSession peer:(NSString *)peerID
 didChangeState:(GKPeerConnectionState)inState
{
    if (inState == GKPeerStateDisconnected) {
        _state = kGameStateInterrupted;
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"Peer Disconnected!", @"Peer Disconnected!")
                              message:NSLocalizedString(@"Your opponent has disconnected, or the connection has been lost",
                                                        @"Your opponent has disconnected, or the connection has been lost")
                              delegate:self
                              cancelButtonTitle:NSLocalizedString(@"Bummer", @"Bummer")
                              otherButtonTitles:nil];
        [alert show];
        theSession.available = NO;
        [theSession disconnectFromAllPeers];
        theSession.delegate = nil;
        [theSession setDataReceiveHandler:nil withContext:nil];
        self.session = nil;
    }
}

- (void)receiveData:(NSData *)data
           fromPeer:(NSString *)peer
          inSession:(GKSession *)theSession
            context:(void *)context
{
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    Packet *packet = [unarchiver decodeObjectForKey:kTicTacToeArchiveKey];
    
    switch (packet.type) {
        case kPacketTypeDieRoll: {
            _opponentDieRoll = packet.dieRoll;
            Packet *ack = [[Packet alloc] initAckPacketWithDieRoll:_opponentDieRoll];
            [self sendPacket:ack];
            _dieRollReceived = YES;
            break;
        }
        case kPacketTypeAck: {
            if (packet.dieRoll != _myDieRoll) {
                NSLog(@"Ack packet doesn't match yourDieRoll (mine: %d, send: %d", packet.dieRoll, _myDieRoll);
            }
            _dieRollAcknowledged = YES;
            break;
        }
        case kPacketTypeMove: {
            UIButton *aButton = (UIButton *)[self.view viewWithTag:[packet space]];
            [aButton setImage:((_playerPiece == kPlayerPieceO) ? self.xPieceImage : self.oPieceImage)
                     forState:UIControlStateNormal];
            _state = kGameStateMyTurn;
            _feedbackLabel.text = NSLocalizedString(@"Your Turn", @"Your Turn");
            [self checkForGameEnd];
            break;
        }
        case kPacketTypeReset: {
            if (_state == kGameStateDone)
                [self resetDieState];
            break;
        }
        default: {
            break;
        }
    }
    
    if (_dieRollReceived == YES && _dieRollAcknowledged == YES)
        [self startGame];
}

#pragma mark - UIAlertView Delegate Method

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self resetBoard];
    self.gameButton.hidden = NO;
}

#pragma mark - Instance Methods

- (void) startNewGame
{
    [self resetBoard];
    [self sendDieRoll];
}

- (void)resetBoard
{
    for (int i = kUpperLeft; i <= kLowerRight; i++) {
        UIButton *aButton = (UIButton *)[self.view viewWithTag:i];
        [aButton setImage:nil forState:UIControlStateNormal];
    }
    self.feedbackLabel.text = @"";
    Packet *packet = [[Packet alloc] initResetPacket];
    [self sendPacket:packet];
    _playerPiece = kPlayerPieceUndecided;
}

- (void)resetDieState
{
    _dieRollReceived = NO;
    _dieRollAcknowledged = NO;
    _myDieRoll = kDiceNotRolled;
    _opponentDieRoll = kDiceNotRolled;
}

- (void)startGame
{
    if (_myDieRoll == _opponentDieRoll) {
        _myDieRoll = kDiceNotRolled;
        _opponentDieRoll = kDiceNotRolled;
        [self sendDieRoll];
        _playerPiece = kPlayerPieceUndecided;
    }
    else if (_myDieRoll < _opponentDieRoll) {
        _state = kGameStateYourTurn;
        _playerPiece = kPlayerPieceX;
        self.feedbackLabel.text = NSLocalizedString(@"Opponent's Turn", @"Opponent's Turn");
        
    }
    else {
        _state = kGameStateMyTurn;
        _playerPiece = kPlayerPieceO;
        self.feedbackLabel.text = NSLocalizedString(@"Your Turn", @"Your Turn");
    }
    [self resetDieState];
}

- (void)sendDieRoll
{
    Packet *rollPacket;
    _state = kGameStateRollingDice;
    if (_myDieRoll == kDiceNotRolled) {
        rollPacket = [[Packet alloc] initDieRollPacket];
        _myDieRoll = rollPacket.dieRoll;
    }
    else {
        rollPacket = [[Packet alloc] initDieRollPacketWithRoll:_myDieRoll];
    }
    [self sendPacket:rollPacket];
    
}

- (void)sendPacket:(Packet *)packet
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:packet forKey:kTicTacToeArchiveKey];
    [archiver finishEncoding];
    
    NSError *error = nil;
    if (![self.session sendDataToAllPeers:data withDataMode:GKSendDataReliable error:&error]) {
        // You would some do real error handling
        NSLog(@"Error sending data: %@", [error localizedDescription]);
    }
}

- (void)checkForGameEnd
{
    NSInteger moves = 0;
    
    UIImage     *currentButtonImages[9];
    UIImage     *winningImage = nil;
    
    for (int i = kUpperLeft; i <= kLowerRight; i++) {
        UIButton *oneButton = (UIButton *)[self.view viewWithTag:i];
        if ([oneButton imageForState:UIControlStateNormal])
            moves++;
        currentButtonImages[i - kUpperLeft] = [oneButton imageForState:UIControlStateNormal];
    }
    
    // Top Row
    if (currentButtonImages[0] == currentButtonImages[1]
        && currentButtonImages[0] == currentButtonImages[2]
        && currentButtonImages[0] != nil)
        winningImage = currentButtonImages[0];
    
    // Middle Row
    else if (currentButtonImages[3] == currentButtonImages[4]
             && currentButtonImages[3] == currentButtonImages[5]
             && currentButtonImages[3] != nil)
        winningImage = currentButtonImages[3];
    
    // Bottom Row
    else if (currentButtonImages[6] == currentButtonImages[7]
             && currentButtonImages[6] == currentButtonImages[8]
             && currentButtonImages[6] != nil)
        winningImage = currentButtonImages[6];
    
    // Left Column
    else if (currentButtonImages[0] == currentButtonImages[3]
             && currentButtonImages[0] == currentButtonImages[6]
             && currentButtonImages[0] != nil)
        winningImage = currentButtonImages[0];
    
    // Middle Column
    else if (currentButtonImages[1] == currentButtonImages[4]
             && currentButtonImages[1] == currentButtonImages[7]
             && currentButtonImages[1] != nil)
        winningImage = currentButtonImages[1];
    
    // Right Column
    else if (currentButtonImages[2] == currentButtonImages[5]
             && currentButtonImages[2] == currentButtonImages[8]
             && currentButtonImages[2] != nil)
        winningImage = currentButtonImages[2];
    
    // Diagonal starting top left
    else if (currentButtonImages[0] == currentButtonImages[4]
             && currentButtonImages[0] == currentButtonImages[8]
             && currentButtonImages[0] != nil)
        winningImage = currentButtonImages[0];
    
    // Diagonal starting top right
    else if (currentButtonImages[2] == currentButtonImages[4]
             && currentButtonImages[2] == currentButtonImages[6]
             && currentButtonImages[2] != nil)
        winningImage = currentButtonImages[2];
    
    if (winningImage == self.xPieceImage) {
        if (_playerPiece == kPlayerPieceX) {
            self.feedbackLabel.text = NSLocalizedString(@"You Won!", @"You Won!");
            _state = kGameStateDone;
        }
        else {
            self.feedbackLabel.text = NSLocalizedString(@"Opponent Won!", @"Opponent Won!");
            _state = kGameStateDone;
        }
    }
    else if (winningImage == self.oPieceImage) {
        if (_playerPiece == kPlayerPieceO){
            self.feedbackLabel.text = NSLocalizedString(@"You Won!", @"You Won!");
            _state = kGameStateDone;
        }
        else {
            self.feedbackLabel.text = NSLocalizedString(@"Opponent Won!", @"Opponent Won!");
            _state = kGameStateDone;
        }
        
    }
    else {
        if (moves >= 9) {
            self.feedbackLabel.text = NSLocalizedString(@"Cat Wins!", @"Cat Wins!");
            _state = kGameStateDone;
        }
    }
    
    if (_state == kGameStateDone)
        [self performSelector:@selector(startNewGame) withObject:nil afterDelay:3.0];
}

@end
