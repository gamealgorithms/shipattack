//-------------------------------------------------------------------
//  ObjectLayer.h - Handles all game objects in main gameplay.
//
//  Ship Attack Sample for Game Programming Algorithms and Techniques
//  Copyright (c) 2013 Sanjay Madhav. All rights reserved.
//
//  Released under the BSD license.
//  See LICENSE.md for full details.
//-------------------------------------------------------------------

#import "CCLayer.h"
#import "Ship.h"
#import "CCLabelTTF.h"

@interface ObjectLayer : CCLayer
{
	// Pointer to our ship
	Ship* m_Ship;
	// Seconds between respawn
	float m_RespawnTime;
	// How quickly the ship can fire lasers
	float m_RefireSpeed;
	
	// Tracks all the lasers in the world
	NSMutableArray* m_Lasers;
	// How fast lasers travel
	float m_LaserSpeed;
	
	// Tracks all enemies in the world
	NSMutableArray* m_Enemies;
	// How fast enemies travel
	float m_EnemySpeed;
	// Frequency (blue) enemies spawn
	float m_EnemySpawnRate;
	
	// Tracks all the enemy projectiles in the world
	NSMutableArray* m_EnemyProjs;
	// How fast enemy projectiles travel
	float m_EnemyProjSpeed;
	
	// These track the touches used to fire/move the ship
	UITouch* m_FireTouch;
	UITouch* m_MoveTouch;
	
	// Number of enemies that spawn before a boss spawns
	int m_PerBoss;
	// Keeps track of how many enemies are left until the a boss
	int m_UntilBoss;
	// Tracks how many bosses the game has spawned
	int m_BossCount;
	// After this many bosses, the spawn rate will increase
	int m_BossesPerSpawnInc;
	// Amount the speed increases after the m_BossesPerSpawnInc is reached
	float m_SpeedIncrease;
	
	// Stores the score and the text display
	float m_ScoreMultiplier;
	int m_Score;
	CCLabelTTF* m_ScoreLabel;
	
	// Stores the number of lives and text display
	int m_Lives;
	CCLabelTTF* m_LivesLabel;
	
	// Number of points to get an extra life
	// This will double every time you gain a life
	int m_PerLife;
	// Number of points until next extra life
	int m_UntilLife;
	
	// Set to YES when game ends
	BOOL m_GameOver;
}

// Remove the player's laser from the world (when off-screen)
-(void) removeLaser:(id)laser;

// Remove an enemy from the world
-(void) removeEnemy:(id)enemy;

// Spawn an enemy projectile that aims at the player's current position
-(void) spawnEnemyProjAtPlayer:(CGPoint)enemyPos;

// Spawn an enemy projectile that fires in a specific direction
-(void) spawnEnemyProjInDirection:(CGPoint)enemyPos direction:(CGPoint)dir;

// Remove an enemy from the world
-(void) removeEnemyProj:(id)proj;

// Updates all of the game objects in the world and checks for collisions
-(void) update:(ccTime)dt;
@end
