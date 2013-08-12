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

#import "CCScene.h"
#import "CCSpriteFrameCache.h"
#import "ScrollingLayer.h"
#import "ObjectLayer.h"

@interface GameplayScene : CCScene
{
	// These two scrolling layers scroll at different speeds to create
	// the parallax effect.
	ScrollingLayer* m_MainBGLayer;
	ScrollingLayer* m_StarField;
	
	// This layer stores all the objects during gameplay.
	// (ship, lasers, projectiles, etc).
	ObjectLayer* m_Objects;
}

// Frame cache stores all the sprites in the spritesheet
+(CCSpriteFrameCache*) getFrameCache;

@end
