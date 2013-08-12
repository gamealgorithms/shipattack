//-------------------------------------------------------------------
//  MainMenuLayer.h - Initial entry point layer.
//
//  Ship Attack Sample for Game Programming Algorithms and Techniques
//  Copyright (c) 2013 Sanjay Madhav. All rights reserved.
//
//  Released under the BSD license.
//  See LICENSE.md for full details.
//-------------------------------------------------------------------


// Import the interfaces
#import "MainMenuLayer.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#import "CCDirector.h"
#import "CCTransition.h"
#import "GameplayScene.h"

#pragma mark - MainMenuLayer

// MainMenuLayer implementation
@implementation MainMenuLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainMenuLayer *layer = [MainMenuLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		
		// create and initialize a Label
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Ship Attack!" fontName:@"Marker Felt" fontSize:64];

		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
	
		// position the label on the center of the screen
		label.position =  ccp( size.width /2, size.height/2 + 60 );
		
		// add the label as a child to this Layer
		[self addChild: label];
		
		
		
		//
		// Leaderboards and Achievements
		//
		
		// Default font size will be 28 points.
		[CCMenuItemFont setFontSize:28];
		
		// Start Game Menu Item using blocks
		CCMenuItem *itemStartGame = [CCMenuItemFont itemWithString:@"Start Game" block:^(id sender) {
			[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[GameplayScene node]]];
		}];

		
		CCMenu *menu = [CCMenu menuWithItems:itemStartGame, nil];
		
		[menu alignItemsHorizontallyWithPadding:20];
		[menu setPosition:ccp( size.width/2, size.height/2 - 30)];
		
		// Add the menu to the layer
		[self addChild:menu];

	}
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
