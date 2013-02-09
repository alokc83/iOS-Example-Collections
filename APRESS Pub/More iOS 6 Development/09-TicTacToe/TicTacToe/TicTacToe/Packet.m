//
//  Packet.m
//  TicTacToe
//
//  Created by Kevin Y. Kim on 10/1/12.
//  Copyright (c) 2012 AppOrchard LLC. All rights reserved.
//

#import "Packet.h"

@implementation Packet

- (id)initWithType:(PacketType)aPacketType dieRoll:(NSUInteger)aDieRoll space:(BoardSpace)aBoardSpace
{
    self = [super init];
    if (self) {
        self.type = aPacketType;
        self.dieRoll = aDieRoll;
        self.space = aBoardSpace;
    }
    return self;
}

- (id)initDieRollPacket
{
    int roll = dieRoll();
    return [self initWithType:kPacketTypeDieRoll dieRoll:roll space:0];
}

- (id)initDieRollPacketWithRoll:(NSUInteger)aDieRoll
{
    return [self initWithType:kPacketTypeDieRoll dieRoll:aDieRoll space:0];
}

- (id)initMovePacketWithSpace:(BoardSpace)aBoardSpace
{
    return [self initWithType:kPacketTypeMove dieRoll:0 space:aBoardSpace];
}

- (id)initAckPacketWithDieRoll:(NSUInteger)aDieRoll
{
    return [self initWithType:kPacketTypeAck dieRoll:aDieRoll space:0];
}

- (id)initResetPacket
{
    return [self initWithType:kPacketTypeReset dieRoll:0 space:0];
}

#pragma mark - NSCoder (Archiving) Methods

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeInt:[self type] forKey:@"type"];
    [coder encodeInteger:[self dieRoll] forKey:@"dieRoll"];
    [coder encodeInt:[self space] forKey:@"space"];
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
        [self setType:[coder decodeIntForKey:@"type"]];
        [self setDieRoll:[coder decodeIntegerForKey:@"dieRoll"]];
        [self setSpace:[coder decodeIntForKey:@"space"]];
    }
    return self;
}

@end
