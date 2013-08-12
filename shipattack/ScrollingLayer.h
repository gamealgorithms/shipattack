//-------------------------------------------------------------------
//  ScrollingLayer.h - Generic class that handles one or more screen-
//  sized layers that can then scroll endlessly across the screen.
//  You need a minimum of two screen-sized images for this to work.
//
//  Ship Attack Sample for Game Programming Algorithms and Techniques
//  Copyright (c) 2013 Sanjay Madhav. All rights reserved.
//
//  Released under the BSD license.
//  See LICENSE.md for full details.
//-------------------------------------------------------------------

#import "CCLayer.h"
#import "CCSprite.h"

@interface ScrollingLayer : CCLayer
{
	// Stores all of the background sprites
	NSMutableArray* m_Backgrounds;
	// Size of the window
	CGSize m_WinSize;
	// Points/second the layer scrolls
	int m_XSpeed;
}

-(id) initWithSegments:(NSMutableArray*)names speed:(int)xspeed;

-(void) update:(ccTime)dt;

@end
