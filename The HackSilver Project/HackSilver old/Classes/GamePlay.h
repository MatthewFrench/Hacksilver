#import <Foundation/Foundation.h>
#import "cocos2d.h"
@interface GamePlay : CCLayer {
	CCLayer* gameLayer,*hudLayer;
	CCMenu *PauseButton;
	
	CCSprite* hero;
	
	CGPoint moveToTile,smallMove;
	CGPoint prevPos, prevTile;
	float movePercentage;
	
	CCTMXTiledMap *tileMap;
	CCTMXLayer *layer;
}
+(id) scene;
- (void)updateWorld;
- (void)setHeroTilePosition:(CGPoint)pos;
- (void)setViewpointCenter:(CGPoint)point;
- (CGPoint)getTileFromPos:(CGPoint)pos;
- (unsigned int)getGIDAtPosition:(CGPoint)point;
-(void)setPlayerAnimation:(CGPoint)pos;
@end