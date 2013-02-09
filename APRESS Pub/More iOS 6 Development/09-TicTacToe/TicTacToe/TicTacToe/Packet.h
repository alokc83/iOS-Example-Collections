//
//  Packet.h
//  TicTacToe
//
//  Created by Kevin Y. Kim on 10/1/12.
//  Copyright (c) 2012 AppOrchard LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TicTacToe.h"

@interface Packet : NSObject <NSCoding>

@property (nonatomic) PacketType type;
@property (nonatomic) NSUInteger dieRoll;
@property (nonatomic) BoardSpace space;

- (id)initWithType:(PacketType)aPacketType dieRoll:(NSUInteger)aDieRoll space:(BoardSpace)aBoardSpace;
- (id)initDieRollPacket;
- (id)initDieRollPacketWithRoll:(NSUInteger)aDieRoll;
- (id)initMovePacketWithSpace:(BoardSpace)aBoardSpace;
- (id)initAckPacketWithDieRoll:(NSUInteger)aDieRoll;
- (id)initResetPacket;

@end
