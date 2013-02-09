//
//  TicTacToe.h
//  TicTacToe
//
//  Created by Kevin Y. Kim on 10/1/12.
//  Copyright (c) 2012 AppOrchard LLC. All rights reserved.
//

#define kTicTacToeSessionID  @"com.apporchard.TicTacToe.session"
#define kTicTacToeArchiveKey @"com.apporchard.TicTacToe"
#define dieRoll() (arc4random() % 1000000)
#define kDiceNotRolled INT_MAX

typedef enum GameStates {
    kGameStateBeginning,
    kGameStateRollingDice,
    kGameStateMyTurn,
    kGameStateYourTurn,
    kGameStateInterrupted,
    kGameStateDone
} GameState;

typedef enum BoardSpaces {
    kUpperLeft = 1000,
    kUpperMiddle,
    kUpperRight,
    kMiddleLeft,
    kMiddleMiddle,
    kMiddleRight,
    kLowerLeft,
    kLowerMiddle,
    kLowerRight
} BoardSpace;

typedef enum PlayerPieces {
    kPlayerPieceUndecided,
    kPlayerPieceO,
    kPlayerPieceX
} PlayerPiece;

typedef enum PacketTypes {
    kPacketTypeDieRoll,
    kPacketTypeAck,
    kPacketTypeMove,
    kPacketTypeReset,
} PacketType;

