//-------------------------------------------------------------------
//  ScrollingLayer.m - Generic class that handles one or more screen-
//  sized layers that can then scroll endlessly across the screen.
//  You need a minimum of two screen-sized images for this to work.
//
//  Ship Attack Sample for Game Programming Algorithms and Techniques
//  Copyright (c) 2013 Sanjay Madhav. All rights reserved.
//
//  Released under the BSD license.
//  See LICENSE.md for full details.
//-------------------------------------------------------------------

#import "ScrollingLayer.h"
#import "cocos2d.h"
#import "GameplayScene.h"

@implementation ScrollingLayer
-(id) initWithSegments:(NSMutableArray*)names speed:(int)xspeed
{
	self = [super init];
    if (self)
	{
		// Set our initial speed
		m_XSpeed = xspeed;
		
		// Allocate our array which will store all the background images
		m_Backgrounds = [[NSMutableArray alloc] init];
		
		// Store the size of the window in a member variable so we don't
		// have to grab it later.
		m_WinSize = [[CCDirector sharedDirector] winSize];
		
		CCSpriteFrameCache* cache = [GameplayScene getFrameCache];
		
		for (int i = 0; i < names.count; i++)
		{
			// Create a sprite for each image in our list
			CCSprite *background;
			background = [CCSprite spriteWithSpriteFrame:[cache spriteFrameByName:[names objectAtIndex:i]]];
			
			background.position = ccp(m_WinSize.width/2 + m_WinSize.width * i,
									  m_WinSize.height/2);
			
			// Disable anti-aliasing
			// (This makes the seams a little less noticeable)
			[[background texture] setAliasTexParameters];
			
			// add the image as a child to this Layer
			[self addChild: background];
			
			// Add it to the array of our backgrounds
			[m_Backgrounds addObject:background];
		}
    }
    return self;
}

-(void) update:(ccTime)dt
{
	// Move all the backgrounds by the m_XSpeed, and if one scrolls off the screen,
	// wrap it to the location back at the end.
	
	for (int i = 0; i < m_Backgrounds.count; i++)
	{
		CCSprite* background = [m_Backgrounds objectAtIndex:i];
		background.position = ccp(background.position.x - m_XSpeed * dt,
								  background.position.y);
		
		// Did we scroll off the screen?
		if (background.position.x <= (m_WinSize.width/-2))
		{
			// Only one image can scroll off at a time, so this places it at the end after
			// all the other images
			background.position = ccp(m_WinSize.width/2 + m_WinSize.width * (m_Backgrounds.count - 1) - 1,
									  m_WinSize.height/2);
		}
	}
}

- (void) dealloc
{
	// Clear out our array of backgrounds
	[m_Backgrounds removeAllObjects];
	[m_Backgrounds dealloc];
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

@end
