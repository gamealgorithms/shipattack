//-------------------------------------------------------------------
//  Laser.m - Player laser class. Most behavior is in parent.
//
//  Ship Attack Sample for Game Programming Algorithms and Techniques
//  Copyright (c) 2013 Sanjay Madhav. All rights reserved.
//
//  Released under the BSD license.
//  See LICENSE.md for full details.
//-------------------------------------------------------------------

#import "Laser.h"
#import "cocos2d.h"
#import "GameplayScene.h"

@implementation Laser
-(id) init
{
	CCSpriteFrameCache* cache = [GameplayScene getFrameCache];
	self = [super initWithSpriteFrame:[cache spriteFrameByName:@"laser.png"]];
	if (self)
	{

	}
	
	return self;
}

-(void) despawn
{
	[(ObjectLayer*)[self parent] removeLaser:self];
}
@end
