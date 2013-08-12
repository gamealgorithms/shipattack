//-------------------------------------------------------------------
//  Ship.h - Player's ship.
//
//  Ship Attack Sample for Game Programming Algorithms and Techniques
//  Copyright (c) 2013 Sanjay Madhav. All rights reserved.
//
//  Released under the BSD license.
//  See LICENSE.md for full details.
//-------------------------------------------------------------------

#import "Ship.h"
#import "cocos2d.h"
#import "GameplayScene.h"

@implementation Ship

@synthesize targetPos = m_targetPos;

-(id) init
{
	CCSpriteFrameCache* cache = [GameplayScene getFrameCache];
	self = [super initWithSpriteFrame:[cache spriteFrameByName:@"f1.png"]];
	if (self)
	{
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		self.position = ccp(self.contentSize.width / 1.5f, winSize.height / 2);
		self.targetPos = self.position;
		
		// Setup all the images for the basic animation
		NSMutableArray* files = [NSMutableArray arrayWithObjects:
								 @"f1.png",
								 @"f2.png",
								 @"f3.png",
								 @"f4.png",
								 nil];
		
		NSMutableArray* frames = [NSMutableArray arrayWithCapacity:10];
		
		for (int i = 0; i < files.count; i++)
		{
			NSString* file = [files objectAtIndex:i];
			CCSpriteFrame* frame = [cache spriteFrameByName:file];
			[frames addObject:frame];
		}
		
		// Start the animation
		CCAnimation* anim = [CCAnimation animationWithSpriteFrames:frames delay:0.15f];
		CCAnimate* animate = [CCAnimate actionWithAnimation:anim];
		CCRepeatForever* repeat = [CCRepeatForever actionWithAction:animate];
		[self runAction:repeat];
		
		// We can move 300 units/sec
		m_YSpeed = 300.0f;
	}
	
	return self;
}

-(void) update:(ccTime)dt
{
	// If we aren't close to the taget position,
	// move our Y in that direciton a bit.
	// (The ship can't move in the X direction in this game)
	if (ccpDistance(self.position, self.targetPos) > 5.0f)
	{
		float targetMult = 1.0f;
		if (self.targetPos.y < self.position.y)
		{
			targetMult = -1.0f;
		}
		self.position = ccp(self.position.x,
							self.position.y + targetMult * m_YSpeed * dt);
	}
}
@end
