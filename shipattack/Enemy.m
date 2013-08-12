//-------------------------------------------------------------------
//  Enemy.m - Handles all behavior related to enemies.
//
//  Ship Attack Sample for Game Programming Algorithms and Techniques
//  Copyright (c) 2013 Sanjay Madhav. All rights reserved.
//
//  Released under the BSD license.
//  See LICENSE.md for full details.
//-------------------------------------------------------------------

#import "Enemy.h"
#import "cocos2d.h"
#import "GameplayScene.h"

@implementation Enemy
@synthesize speed = m_Speed;
@synthesize health = m_Health;
@synthesize value = m_Value;

-(id) init
{
	CCSpriteFrameCache* cache = [GameplayScene getFrameCache];
	self = [super initWithSpriteFrame:[cache spriteFrameByName:@"e_b1.png"]];
	if (self)
	{
		// Default values, these might get overwritten by
		// Other setup functions (or from the game object).
		m_Speed = 250.0f;
		m_Value = 100;
		m_TargetPlayer = YES;
		m_Health = 1;
		
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		// Always starts slightly off screen
		// The height will be set randomly later
		self.position = ccp(winSize.width + self.contentSize.width / 2, 0);
		
		m_FireFunc = [CCCallFunc actionWithTarget:self selector:@selector(fire)];
		
		m_RemoveFunc = [CCCallFunc actionWithTarget:self selector:@selector(despawn)];
	}
	
	return self;
}

// Setup either the blue or yellow saucer animations
-(void) setupAnim:(BOOL)isYellow
{
	NSMutableArray* files;
	
	if (isYellow == NO)
	{
		files = [NSMutableArray arrayWithObjects:
								 @"e_b1.png",
								 @"e_b2.png",
								 @"e_b3.png",
								 @"e_b4.png",
								 @"e_b5.png",
								 @"e_b6.png",
								 nil];
	}
	else
	{
		files = [NSMutableArray arrayWithObjects:
								 @"e_f1.png",
								 @"e_f2.png",
								 @"e_f3.png",
								 @"e_f4.png",
								 @"e_f5.png",
								 @"e_f6.png",
								 nil];
	}
	
	CCSpriteFrameCache* cache = [GameplayScene getFrameCache];
	
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
}

// Figure 8 Route:
// This is the boss enemy, so it has more health
// Targets the player and fires repeatedly, doing this pattern:
// 1. Move diagonally up or down
// 2. Move vertically up or down
// 3. Move diagonally down or up
// 4. Move vertically down or up
-(void) setupFigure8Route
{
	[self setupAnim:YES];
	self.scale = 1.25f;
	m_Health = 3;
	m_Value = 300;
	m_TargetPlayer = YES;
	
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	float yPos = self.position.y;
	
	// Construct path for this enemy
	float heightOffset = 100.0f;
	
	// The first target point is always (middle, +/- heightOffset)
	CGPoint firstTarget, secondTarget, thirdTarget, fourthTarget;
	if (yPos < winSize.height / 2)
	{
		firstTarget = ccp(winSize.width / 2, self.position.y + heightOffset);
	}
	else
	{
		firstTarget = ccp(winSize.width / 2, self.position.y - heightOffset);
	}
	
	// Now complete the figure 8
	secondTarget = ccp(firstTarget.x, self.position.y);
	thirdTarget = ccp(self.position.x - self.contentSize.width, firstTarget.y);
	fourthTarget = ccp(self.position.x - self.contentSize.width, self.position.y);
	
	NSMutableArray* locations = [NSMutableArray arrayWithCapacity:10];
	[locations addObject:[NSValue valueWithCGPoint:firstTarget]];
	[locations addObject:[NSValue valueWithCGPoint:secondTarget]];
	[locations addObject:[NSValue valueWithCGPoint:thirdTarget]];
	[locations addObject:[NSValue valueWithCGPoint:fourthTarget]];
	
	NSMutableArray* moves = [self createMoveActions:locations];
	
	// The figure 8 continues forever
	[self runAction:[CCRepeatForever actionWithAction:[CCSequence actions:
					 [moves objectAtIndex:0],
					 [moves objectAtIndex:1],
					 [moves objectAtIndex:2],
					 [moves objectAtIndex:3],
					 nil]]];
	
	// This enemy will keep shooting every 1/2 second until dead
	[self schedule:@selector(fire) interval:0.5f];
}

// Post Route:
// 1. Horizontally straight to middle screen line.
// 2. Fire in -X direction
// 3. Exit on top or bottom (whichever is closest)
-(void) setupPostRoute
{
	[self setupAnim:NO];
	// Does not fire at player, fires in -X direction
	m_TargetPlayer = NO;
	m_FireDir = ccp(-1, 0);
	
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	float yPos = self.position.y;
	
	CGPoint firstTarget = ccp(winSize.width / 2, yPos);
	CGPoint secondTarget = ccp(firstTarget.x, 0);
	if (yPos < winSize.height / 2)
	{
		secondTarget.y = -self.contentSize.height;
	}
	else
	{
		secondTarget.y = winSize.height + self.contentSize.height;
	}
	
	NSMutableArray* locations = [NSMutableArray arrayWithCapacity:10];
	[locations addObject:[NSValue valueWithCGPoint:firstTarget]];
	[locations addObject:[NSValue valueWithCGPoint:secondTarget]];
	
	NSMutableArray* moves = [self createMoveActions:locations];
	
	// Will run the route once then remove itself
	[self runAction:[CCSequence actions:
					 [moves objectAtIndex:0],
					 m_FireFunc,
					 [moves objectAtIndex:1],
					 m_RemoveFunc,
					 nil]];
}

// Helper function to generate all the appropriate actions based
// on the list of positions to travel to.
-(NSMutableArray*) createMoveActions:(NSMutableArray*)locations
{
	NSMutableArray* retVal = [NSMutableArray arrayWithCapacity:10];
	
	for (int i = 0; i < locations.count; i++)
	{
		CGPoint start, end;
		if (i == 0)
		{
			start = self.position;
		}
		else
		{
			start = [[locations objectAtIndex:(i - 1)] CGPointValue];
		}
		
		end = [[locations objectAtIndex:(i)] CGPointValue];
		
		CCMoveTo* move = [CCMoveTo actionWithDuration:
						  ccpDistance(start, end) / m_Speed position:end];
		
		[retVal addObject:move];
	}
	
	return retVal;
}

// Tell my parent to remove me
-(void)despawn
{
	[(ObjectLayer*)[self parent] removeEnemy:self];
}

// Function called to fire an enemy projectile
// Will fire at player or in a specific direction, depending on m_TargetPlayer
-(void)fire
{
	CGPoint firePos = ccp(self.position.x - self.contentSize.width / 2.0f, self.position.y);
	
	if (m_TargetPlayer)
	{
		[(ObjectLayer*)[self parent] spawnEnemyProjAtPlayer:firePos];
	}
	else
	{
		[(ObjectLayer*)[self parent] spawnEnemyProjInDirection:firePos direction:m_FireDir];
	}
}
@end
