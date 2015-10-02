//
//  GamePlay.m
//  iRPG Online
//
//  Created by Matthew French on 1/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GamePlay.h"
#import "GameOver.h"
#import "PauseScene.h"

enum {
	kTagHero,
	kTagEnemy
};
@implementation GamePlay
-(id) init {
	if( (self=[super init] )) {
		self.isTouchEnabled = YES;

		gameLayer = [CCLayer node];
		[self addChild:gameLayer z:0];

		hudLayer = [CCLayer node];
		[self addChild:hudLayer z:1];
		
		CCMenuItem *Pause = [CCMenuItemImage
							 itemFromNormalImage:@"pausebutton.png" 
							 selectedImage: @"pausebutton.png"
							 target:self selector:@selector(pause:)];
		PauseButton = [CCMenu menuWithItems: Pause, nil];
		PauseButton.position = ccp(25, 295);
		[hudLayer addChild:PauseButton z:0];

		tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"HackSilver Map.tmx"];
		//tileMap.anchorPoint = ccp(0.5,0.5);
		tileMap.position = ccp(0,0);
		[gameLayer addChild:tileMap z:-1];
		layer = [tileMap layerNamed:@"Tile Layer 1"];
		
		hero = [CCSprite spriteWithFile:@"Man.png"];
		[hero setTextureRect:CGRectMake(0,0,45,45)];
		//hero.anchorPoint = ccp(0,0);
		[self setHeroTilePosition:ccp(2,2)];
		[gameLayer addChild:hero];
		
		[self schedule:@selector(updateWorld) interval:1.0/60.0];
	}
	return self;
}
- (void)setHeroTilePosition:(CGPoint)pos {
	moveToTile = pos;
	movePercentage = 105;
	hero.position = ccp(pos.x*45-45.0/2.0, pos.y*45-45.0/2.0);
	prevPos = hero.position;
	[self setViewpointCenter:hero.position];
}
- (void)setViewpointCenter:(CGPoint)point {
	CGPoint centerPoint = ccp(240, 160);
	CGPoint viewPoint = ccpSub(centerPoint, point);
	
	// dont scroll so far so we see anywhere outside the visible map which would show up as black bars
	if(point.x < centerPoint.x)
		viewPoint.x = 0;
	if(point.y < centerPoint.y)
		viewPoint.y = 0;
	if(point.x > tileMap.mapSize.width*tileMap.tileSize.width - centerPoint.x)
		viewPoint.x = -tileMap.mapSize.width*tileMap.tileSize.width + centerPoint.x*2;
	if(point.y > tileMap.mapSize.height*tileMap.tileSize.height - centerPoint.y)
		viewPoint.y = -tileMap.mapSize.height*tileMap.tileSize.height + centerPoint.y*2;
	// while zoomed out, don't adjust the viewpoint
	//if(!isZoomedOut)
	gameLayer.position = viewPoint;
}
- (CGPoint)coordinatesAtPosition:(CGPoint)point {
	CGPoint pos = ccp((int)(point.x / tileMap.tileSize.width), (int)(tileMap.mapSize.height - (point.y / tileMap.tileSize.height)));
	return pos;
	//return ccp((int)(point.x / tileMap.tileSize.width), (int)(point.y / tileMap.tileSize.height));
}
- (void)updateWorld {
	if (movePercentage == 0) {
		//Check if can move and set small move.
		smallMove = prevTile;
		if (moveToTile.x < prevTile.x) {smallMove.x = prevTile.x-1;}
		if (moveToTile.x > prevTile.x) {smallMove.x = prevTile.x+1;}
		if (moveToTile.y < prevTile.y) {smallMove.y = prevTile.y-1;}
		if (moveToTile.y > prevTile.y) {smallMove.y = prevTile.y+1;}
		BOOL continueMove = TRUE;
		if (smallMove.x == 0 && smallMove.y == 0) {continueMove = FALSE;}
		if ([self getGIDAtPosition:smallMove] == 3) {continueMove = FALSE;}
		if (continueMove) {
			movePercentage +=5;
			hero.position = ccp(prevPos.x+((movePercentage/100)*(smallMove.x*45-prevPos.x-45.0/2.0)),prevPos.y+((movePercentage/100)*(smallMove.y*45-prevPos.y-45.0/2.0)));
			[self setViewpointCenter:hero.position];
		} else {movePercentage = 101;}
	} else if (movePercentage < 100) {
		//Move to the small move tile.
		movePercentage += 5;
		hero.position = ccp(prevPos.x+((movePercentage/100)*(smallMove.x*45-prevPos.x-45.0/2.0)),prevPos.y+((movePercentage/100)*(smallMove.y*45-prevPos.y-45.0/2.0)));
		[self setViewpointCenter:hero.position];
	} else if (movePercentage == 100) {
		//If reached movedToTile then leave alone, if still need to move set to 0
		prevPos=ccp(smallMove.x*45,smallMove.y*45);
		prevTile = smallMove;
		hero.position = ccp(smallMove.x*45-45.0/2.0,smallMove.y*45-45.0/2.0);
		movePercentage = 101;
		if (smallMove.x != moveToTile.x || smallMove.y != moveToTile.y) {movePercentage = 0;prevPos = hero.position;prevTile = [self getTileFromPos:hero.position];}
		[self setViewpointCenter:hero.position];
	}
}
- (CGPoint)getTileFromPos:(CGPoint)pos {
	return ccp(round((pos.x+45.0/2.0)/45),round((pos.y+45.0/2.0)/45));
}
- (unsigned int)getGIDAtPosition:(CGPoint)point {
	return [layer tileGIDAt:ccp(point.x-1,tileMap.mapSize.height-point.y)];
}
-(void) pause: (id) sender {
	
	[[CCDirector sharedDirector] pushScene:[PauseScene node]];
}
-(void)setPlayerAnimation:(CGPoint)pos {
	pos = [tileMap convertToNodeSpace:pos];
	float rotation = 360-(atan2(hero.position.y-pos.y, hero.position.x-pos.x)/M_PI*180+180);
	if (rotation > 337) {rotation = 0;}
	[hero setTextureRect:CGRectMake(round(rotation/45)*45,0,45,45)];
}
-(void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *myTouch = [touches anyObject];
	CGPoint point = [myTouch locationInView:[myTouch view]];
	//Flip for Gl coord
	point = [[CCDirector sharedDirector] convertToGL:point];
	[self setPlayerAnimation:point];
}
-(void) ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *myTouch = [touches anyObject];
	CGPoint point = [myTouch locationInView:[myTouch view]];
	//Flip for Gl coord
	point = [[CCDirector sharedDirector] convertToGL:point];
	[self setPlayerAnimation:point];
}
-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *myTouch = [touches anyObject];
	CGPoint point = [myTouch locationInView:[myTouch view]];
	//Flip for Gl coord
	point = [[CCDirector sharedDirector] convertToGL:point];
	[self setPlayerAnimation:point];
	switch ([myTouch tapCount]) 
	{
		case 1:
		{
			point = [tileMap convertToNodeSpace:point];
			moveToTile = [self getTileFromPos:point];
			movePercentage = 0;
			prevPos = hero.position;
			prevTile = [self getTileFromPos:hero.position];
		}
			break;
			
		case 2:
			break;
			
		case 3:
			break;
			
		default:
			break;
	}
}

+(id) scene {
	// ‘scene’ is an autorelease object.
	CCScene *scene = [CCScene node];
	// ‘layer’ is an autorelease object.
	GamePlay *layer = [GamePlay node];
	// add layer as a child to scene
	[scene addChild: layer];
	// return the scene
	return scene;
}
@end
