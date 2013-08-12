//-------------------------------------------------------------------
//  ObjectLayer.m - Handles all game objects in main gameplay.
//
//  Ship Attack Sample for Game Programming Algorithms and Techniques
//  Copyright (c) 2013 Sanjay Madhav. All rights reserved.
//
//  Released under the BSD license.
//  See LICENSE.md for full details.
//-------------------------------------------------------------------

#import "ObjectLayer.h"
#import "cocos2d.h"
#import "Laser.h"
#import "Enemy.h"
#import "EnemyProj.h"
#import "MainMenuLayer.h"
#import "SimpleAudioEngine.h"

@implementation ObjectLayer
- (id)init
{
    self = [super init];
    if (self)
	{
		m_Ship = [Ship node];
		[self addChild:m_Ship];
		
		[self setTouchEnabled:true];
		
		m_Lasers = [[NSMutableArray alloc] init];
		m_Enemies = [[NSMutableArray alloc] init];
		m_EnemyProjs = [[NSMutableArray alloc] init];
		
		m_FireTouch = nil;
		m_MoveTouch = nil;
		
		// Player's lasers move at 250.0f points/sec, and refires every 1/4th second
		m_LaserSpeed = 250.0f;
		m_RefireSpeed = 0.25f;
		
		// How long it takes the player to respawn when they die
		m_RespawnTime = 2.5f;
		
		// Every 7.5k points you get an extra life
		m_PerLife = 7500;
		m_UntilLife = m_PerLife;
		
		// Default speed for enemy projectiles and enemies
		m_EnemyProjSpeed = 200.0f;
		m_EnemySpeed = 250.0f;
		// How often enemies spawn
		m_EnemySpawnRate = 0.5f;
		
		// How many enemies spawn until the next boss
		m_PerBoss = 20;
		m_UntilBoss = m_PerBoss;
		
		// Every 3 bosses, the spawn rate/enemy speed will increase
		m_BossCount = 0;
		m_BossesPerSpawnInc = 3;
		// Amount the speed increases
		m_SpeedIncrease = 1.15f;
		
		// Score multiplier
		m_ScoreMultiplier = 1;
		
		// The game is not over...yet
		m_GameOver = NO;
		
		[self spawnEnemy];
		[self schedule:@selector(spawnEnemy) interval: m_EnemySpawnRate];
		
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		// Initial score is 0
		m_Score = 0;
		m_ScoreLabel = [CCLabelTTF labelWithString:@"Score: 0" fontName:@"Marker Felt" fontSize:30];
		m_ScoreLabel.position =  ccp(winSize.width/2 + winSize.width/4, winSize.height - 30);
		[self updateScoreDisplay];
		[self addChild: m_ScoreLabel];
		
		// Initial number of lives is 3
		m_Lives = 3;
		m_LivesLabel = [CCLabelTTF labelWithString:@"Lives: 0" fontName:@"Marker Felt" fontSize:30];
		m_LivesLabel.position =  ccp(winSize.width/2 - winSize.width/4, winSize.height - 30);
		[self updateLivesDisplay];
		[self addChild: m_LivesLabel];
    }
    return self;
}

// Updates all of the game objects in the world and checks for collisions
-(void) update:(ccTime)dt
{
	// Do these updates even if the game is over, so we don't get
	// stuck projectiles on the screen
	// Update ship, enemies, and projectiles
	[m_Ship update:dt];
	for (int i = 0; i < m_Lasers.count; i++)
	{
		[[m_Lasers objectAtIndex:i] update:dt];
	}
	
	for (int i = 0; i < m_Enemies.count; i++)
	{
		[[m_Enemies objectAtIndex:i] update:dt];
	}
	
	for (int i = 0; i < m_EnemyProjs.count; i++)
	{
		[[m_EnemyProjs objectAtIndex:i] update:dt];
	}

	// Only do collisions if the game is not over
	if (m_GameOver == NO)
	{
		// Check to see if the lasers did some damage
		// using naive n^2 algorithm
		for (int i = 0; i < m_Lasers.count; i++)
		{
			Laser* laser = [m_Lasers objectAtIndex:i];
			
			// Did this laser hit an enemy?
			for (int j = 0; j < m_Enemies.count; j++)
			{
				Enemy* enemy = [m_Enemies objectAtIndex:j];
				if (CGRectIntersectsRect(laser.boundingBox, enemy.boundingBox))
				{
					// Subtract one from health and see if it's dead
					enemy.health--;
					if (enemy.health <= 0)
					{
						// Give points for killing this enemy
						[self addEnemyPoints:enemy];
						
						// Remove this enemy
						[self removeChild:enemy cleanup:YES];
						[m_Enemies removeObjectAtIndex:j];
						// decrement from j so it points at the next after iteration
						j--;
					}
					
					// Remove this laser and break out of inner loop
					[self removeChild:laser cleanup:YES];
					[m_Lasers removeObjectAtIndex:i];
					i--;
					
					// Set laser to nil so next loop doesn't happen
					laser = nil;
					
					// Play the hit sound
					[[SimpleAudioEngine sharedEngine] playEffect:@"176238__melissapons__sci-fi-short-error.wav"];
					
					break;
				}
			}
			
			// Laser was axed, so don't do second loop
			if (!laser)
			{
				continue;
			}
			
			// Maybe it hit an enemy projectile?
			for (int j = 0; j < m_EnemyProjs.count; j++)
			{
				EnemyProj* proj = [m_EnemyProjs objectAtIndex:j];
				if (CGRectIntersectsRect(laser.boundingBox, proj.boundingBox))
				{
					// Remove this projectile
					[self removeChild:proj cleanup:YES];
					[m_EnemyProjs removeObjectAtIndex:j];
					// decrement from j so it points at the next after iteration
					j--;
					
					// Remove this laser and break out of inner loop
					[self removeChild:laser cleanup:YES];
					[m_Lasers removeObjectAtIndex:i];
					i--;
					break;
				}
			}
		}
		
		// Check to see if the player bit it
		// Don't do the check if the ship is dead
		if (m_Ship.visible)
		{
			for (int i = 0; i < m_EnemyProjs.count; i++)
			{
				EnemyProj* proj = [m_EnemyProjs objectAtIndex:i];
				if (CGRectIntersectsRect(m_Ship.boundingBox, proj.boundingBox))
				{
					[self loseLife];
					break;
				}
			}
		}
	}
}

// Tells cocos2d that this layer cares about touches
- (void) registerWithTouchDispatcher
{
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

// Called when a new touch is detected
-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	CGPoint location = [touch locationInView: [touch view]];
	location = [[CCDirector sharedDirector] convertToGL: location];
	
	// If we touched on the right half of the screen, spawn a laser
	if (!m_FireTouch && location.x > winSize.width / 2)
	{
		m_FireTouch = touch;
		[self spawnLaser];
		[self schedule:@selector(spawnLaser) interval: m_RefireSpeed];
		
		return YES;
	}
	// If we touched the left side, ship movement touch
	else if (!m_MoveTouch && location.x < winSize.width / 2)
	{
		m_MoveTouch = touch;
		m_Ship.targetPos = ccp(m_Ship.position.x,
							   location.y);
		
		return YES;
	}

	// Returning NO means we didn't process this touch
	return NO;
}

// Called when an existing touch is moved
-(void) ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint location = [touch locationInView: [touch view]];
	location = [[CCDirector sharedDirector] convertToGL: location];
	
	// Is this the left-hand touch for moving up/down?
	if (touch == m_MoveTouch)
	{
		m_Ship.targetPos = ccp(m_Ship.position.x,
							   location.y);
	}
}

// Called when an existing touch ends
-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
	// If the touch associated with weapon fire was lifted, stop firing
	if (touch == m_FireTouch)
	{
		m_FireTouch = nil;
		[self unschedule:@selector(spawnLaser)];
	}
	else if (touch == m_MoveTouch)
	{
		m_MoveTouch = nil;
	}
}

// Spawns the player's laser
-(void) spawnLaser
{
	// Don't fire laser if ship is dead
	if (m_Ship.visible)
	{
		Laser* laser = [Laser node];
		// Add a little bit in the x direction so it doesn't spawn in the center of the ship
		laser.position = ccp(m_Ship.position.x + m_Ship.contentSize.width,
							 m_Ship.position.y);
		// Laser only travels in the x direction
		laser.velocity = ccp(m_LaserSpeed, 0.0f);
		
		// Add laser to the world
		[self addChild:laser];
		[m_Lasers addObject:laser];

		// Play laser fire sound
		[[SimpleAudioEngine sharedEngine] playEffect:@"146725__fins__laser.wav"];
	}
}

// Remove the player's laser from the world (when off-screen)
-(void) removeLaser:(id)laser
{
	[self removeChild:laser cleanup:YES];
	[m_Lasers removeObject:laser];
}

// Spawn a regular blue enemy that does the post route
-(void) spawnEnemy
{
	// Don't spawn enemies if the ship is dead
	if (m_Ship.visible)
	{
		Enemy* enemy = [Enemy node];
		
		enemy.speed = m_EnemySpeed;
		
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		float yPos = arc4random() % (int)winSize.height;
		enemy.position = ccp(enemy.position.x,
							yPos);
		[enemy setupPostRoute];
		[self addChild: enemy];
		[m_Enemies addObject:enemy];
		
		m_UntilBoss--;
		if (m_UntilBoss == 0)
		{
			m_UntilBoss = m_PerBoss;
			[self scheduleOnce:@selector(spawnBoss) delay:0.25f];
		}
	}
}

// Spawn a bigger yellow enemy that does the figure 8 attack pattern
-(void) spawnBoss
{
	m_BossCount++;
	// Every spawninc boss, increase the spawn rate of enemies by 15%
	// and the speed by 15%
	if ((m_BossCount % m_BossesPerSpawnInc) == 0)
	{
		m_EnemySpawnRate /= m_SpeedIncrease;
		[self schedule:@selector(spawnEnemy) interval: m_EnemySpawnRate];
		
		m_EnemySpeed *= m_SpeedIncrease;
		m_ScoreMultiplier *= m_SpeedIncrease;
	}
	
	Enemy* enemy = [Enemy node];
	
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	float yPos = arc4random() % (int)winSize.height;
	enemy.position = ccp(enemy.position.x,
						 yPos);
	[enemy setupFigure8Route];
	[self addChild: enemy];
	[m_Enemies addObject:enemy];
}

// Remove an enemy from the world
-(void) removeEnemy:(id)enemy
{
	[self removeChild:enemy cleanup:YES];
	[m_Enemies removeObject:enemy];
}

// Spawn an enemy projectile that aims at the player's current position
-(void) spawnEnemyProjAtPlayer:(CGPoint)enemyPos
{
	// Don't spawn projectiles if the ship is dead
	if (m_Ship.visible)
	{
		// Construct vector from enemy to ship
		CGPoint vDir = ccpSub(m_Ship.position, enemyPos);
		// Normalize
		vDir = ccpNormalize(vDir);
		
		[self spawnEnemyProjInDirection:enemyPos direction:vDir];
	}
}

// Spawn an enemy projectile that fires in a specific direction
-(void) spawnEnemyProjInDirection:(CGPoint)enemyPos direction:(CGPoint)dir
{
	// Don't spawn projectiles if the ship is dead
	if (m_Ship.visible)
	{
		EnemyProj* proj = [EnemyProj node];		
		// Set starting position to enemy ship
		proj.position = enemyPos;
		
		// Multiply by fixed speed to get velocity
		proj.velocity = ccpMult(dir, m_EnemyProjSpeed);
		
		// Add this projectile to the world
		[self addChild:proj];
		[m_EnemyProjs addObject:proj];
		
		// Play enemy projectile sound
		[[SimpleAudioEngine sharedEngine] playEffect:@"193427__unfa__projectile-shoot.wav"];
	}
}

// Remove an enemy projectile from the world
-(void) removeEnemyProj:(id)proj
{
	[self removeChild:proj cleanup:YES];
	[m_EnemyProjs removeObject:proj];
}

// Called every time an enemy is killed, to add to the score
-(void) addEnemyPoints:(Enemy*)enemy
{
	int score = enemy.value * m_ScoreMultiplier;
	m_Score += score;
	
	[self updateScoreDisplay];
	
	// Check to see if we earned an extra life
	m_UntilLife -= score;
	if (m_UntilLife <= 0)
	{
		m_Lives++;
		[self updateLivesDisplay];
		// Double the per life
		m_PerLife *= 2;
		// If we're at -something the per life should reset to 9900
		m_UntilLife = m_PerLife	+ m_UntilLife;
		
		// Play the gain life sound
		[[SimpleAudioEngine sharedEngine] playEffect:@"43315__altemark__1up.wav"];
	}
}

// Update the display string for the score
-(void) updateScoreDisplay
{
	m_ScoreLabel.string = [NSString stringWithFormat:@"Score: %d", m_Score];
}

// Update the display string for the number of lives
-(void) updateLivesDisplay
{
	m_LivesLabel.string = [NSString stringWithFormat:@"Lives: %d", m_Lives];
}

// Cause the player to lose a life
-(void) loseLife
{
	m_Lives--;
	[self updateLivesDisplay];
	m_Ship.visible = false;
	
	if (m_Lives <= 0)
	{
		[self gameOver];
	}
	else
	{
		[self scheduleOnce:@selector(respawnShip) delay:m_RespawnTime];
	}
	
	// Play player died sound
	[[SimpleAudioEngine sharedEngine] playEffect:@"155235__zangrutz__bomb-small.wav"];
}

// Called wehn the player loses the game
-(void) gameOver
{
	m_GameOver = YES;
	
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	
	// Display the game over menu
	// create and initialize a Label
	CCLabelTTF *label = [CCLabelTTF labelWithString:@"Game Over :(" fontName:@"Marker Felt" fontSize:64];
	// position the label on the center of the screen
	label.position =  ccp( winSize.width /2, winSize.height/2 + 60 );
	
	// add the label as a child to this Layer
	[self addChild: label];
	
	CCMenuItem *itemGameOver = [CCMenuItemFont itemWithString:@"Return to Main Menu" block:^(id sender) {
		[[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5 scene:[MainMenuLayer scene]]];
	}];
	
	CCMenu *menu = [CCMenu menuWithItems:itemGameOver, nil];
	
	[menu alignItemsHorizontallyWithPadding:20];
	[menu setPosition:ccp( winSize.width/2, winSize.height/2 - 30)];
	
	// Add the menu to the layer
	[self addChild:menu];
}

// Called when the ship respawns
-(void) respawnShip
{
	m_Ship.visible = true;
}

- (void) dealloc
{
	// Clear out our arrays
	[m_Lasers removeAllObjects];
	[m_Lasers dealloc];
	[m_Enemies removeAllObjects];
	[m_Enemies dealloc];
	[m_EnemyProjs removeAllObjects];
	[m_EnemyProjs dealloc];
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

@end
