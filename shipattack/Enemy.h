//-------------------------------------------------------------------
//  Enemy.h - Handles all behavior related to enemies.
//
//  Ship Attack Sample for Game Programming Algorithms and Techniques
//  Copyright (c) 2013 Sanjay Madhav. All rights reserved.
//
//  Released under the BSD license.
//  See LICENSE.md for full details.
//-------------------------------------------------------------------

#import "CCSprite.h"
#import "CCActionInstant.h"

@interface Enemy : CCSprite
{
	// Speed ship travels at
	float m_Speed;
	// How many points you get when you kill it
	int m_Value;
	// Number of laser hits it takes to kill it
	int m_Health;
	// Whether or not this enemy aims at the player
	BOOL m_TargetPlayer;
	// Direction to fire at (if not at player)
	CGPoint m_FireDir;
	
	// These are used to keep track of internal fire/remove functions.
	CCCallFunc* m_FireFunc;
	CCCallFunc* m_RemoveFunc;
}
// Speed ship travels at
@property float speed;
// How many points you get when you kill it
@property int value;
// Number of laser hits it takes to kill it
@property int health;

// Setup a yellow enemy that follows the Figure 8 (ish) path
-(void) setupFigure8Route;

// Setup a blue enemy that runs a post route
-(void) setupPostRoute;
@end
