//-------------------------------------------------------------------
//  Projectile.h - Base class for laser and enemy projectiles.
//
//  Ship Attack Sample for Game Programming Algorithms and Techniques
//  Copyright (c) 2013 Sanjay Madhav. All rights reserved.
//
//  Released under the BSD license.
//  See LICENSE.md for full details.
//-------------------------------------------------------------------

#import "CCSprite.h"

@interface Projectile : CCSprite
{
	// Velocity the projectile travels at
	CGPoint m_Velocity;
}

@property CGPoint velocity;

-(void) update:(ccTime)dt;
-(void) despawn;
@end
