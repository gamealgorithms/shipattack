//-------------------------------------------------------------------
//  Projectile.m - Base class for laser and enemy projectiles.
//
//  Ship Attack Sample for Game Programming Algorithms and Techniques
//  Copyright (c) 2013 Sanjay Madhav. All rights reserved.
//
//  Released under the BSD license.
//  See LICENSE.md for full details.
//-------------------------------------------------------------------

#import "Projectile.h"
#import "cocos2d.h"
#import "ObjectLayer.h"

@implementation Projectile
@synthesize velocity = m_Velocity;

-(void) update:(ccTime)dt
{
	// This is Euler Integration, it turns out
	self.position = ccpAdd(self.position, ccpMult(self.velocity, dt));
	
	// If we're off the screen, say goodbye
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	if (self.position.x > winSize.width + self.boundingBox.size.width ||
		self.position.x < -1 * self.boundingBox.size.width ||
		self.position.y > winSize.height + self.boundingBox.size.height ||
		self.position.y < -1 * self.boundingBox.size.height)
	{
		[self despawn];
	}
}

// This needs to be overloaded by child classes
-(void) despawn
{
	
}
@end
