//-------------------------------------------------------------------
//  EnemyProj.m - Enemy projectile class. Most behavior is in parent.
//
//  Ship Attack Sample for Game Programming Algorithms and Techniques
//  Copyright (c) 2013 Sanjay Madhav. All rights reserved.
//
//  Released under the BSD license.
//  See LICENSE.md for full details.
//-------------------------------------------------------------------

#import "EnemyProj.h"
#import "cocos2d.h"
#import "GameplayScene.h"

@implementation EnemyProj
-(id) init
{
	CCSpriteFrameCache* cache = [GameplayScene getFrameCache];
	self = [super initWithSpriteFrame:[cache spriteFrameByName:@"shot.png"]];
	if (self)
	{
		
	}
	
	return self;
}

-(void) despawn
{
	[(ObjectLayer*)[self parent] removeEnemyProj:self];
}
@end
