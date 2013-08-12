//-------------------------------------------------------------------
//  GameplayScene.h - Main scene that tracks all the layers during
//  gameplay.
//
//  Ship Attack Sample for Game Programming Algorithms and Techniques
//  Copyright (c) 2013 Sanjay Madhav. All rights reserved.
//
//  Released under the BSD license.
//  See LICENSE.md for full details.
//-------------------------------------------------------------------

#import "GameplayScene.h"
#import "CCDirector.h"
#import "CCTransition.h"
#import "MainMenuLayer.h"

static CCSpriteFrameCache* s_FrameCache = nil;

@implementation GameplayScene
- (id)init
{
    self = [super init];
    if (self)
	{
		// Add far away background
		NSMutableArray* names = [NSMutableArray arrayWithObjects:
								 @"farback_01.png",
								 @"farback_02.png",
								 nil];
		m_MainBGLayer = [[[ScrollingLayer alloc] initWithSegments:names speed:25] autorelease];
		[self addChild:m_MainBGLayer z:0];
		
		// Add objects in the main layer
		m_Objects = [ObjectLayer node];
		[self addChild:m_Objects z:1];
		
		// Add the star field in front to create some depth
		names = [NSMutableArray arrayWithObjects:
				 @"starfield.png",
				 @"starfield.png",
				 nil];
		m_StarField = [[[ScrollingLayer alloc] initWithSegments:names speed:200] autorelease];
		[self addChild:m_StarField z:2];
		
		[self scheduleUpdate];
    }
    return self;
}

-(void) update:(ccTime)dt
{
	// Update our background layers
	[m_MainBGLayer update:dt];
	[m_StarField update:dt];
	
	// Update main object layer
	[m_Objects update:dt];
}

// Helper class method that allows
// everyone to access the sprite sheet.
+(CCSpriteFrameCache*) getFrameCache
{
	// Load our sprite sheet
	if (s_FrameCache == NULL)
	{
		s_FrameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
		[s_FrameCache addSpriteFramesWithFile:@"space.plist"];
	}
	
	return s_FrameCache;
}

@end
