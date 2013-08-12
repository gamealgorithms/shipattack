//-------------------------------------------------------------------
//  Ship.h - Player's ship.
//
//  Ship Attack Sample for Game Programming Algorithms and Techniques
//  Copyright (c) 2013 Sanjay Madhav. All rights reserved.
//
//  Released under the BSD license.
//  See LICENSE.md for full details.
//-------------------------------------------------------------------

#import "CCSprite.h"

@interface Ship : CCSprite
{
	// The target position the ship travels to.
	CGPoint m_targetPos;
	// Speed the ship can move vertically
	float m_YSpeed;
}

@property CGPoint targetPos;

-(void) update:(ccTime)dt;
@end
