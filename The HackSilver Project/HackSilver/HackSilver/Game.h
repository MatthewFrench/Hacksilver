//
//  Game.h
//  HackSilver
//
//  Created by Matthew French on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Enemy.h"
#import <QuartzCore/CALayer.h>

@interface Game : UIViewController<UIGestureRecognizerDelegate> {
    int SCALE;
    int MAP_W;
    int MAP_H;
    int ROOM_W;
    int ROOM_H;
    int ROOM_COUNT;
    int BLOCK_W;
    int BLOCK_H;
    BOOL ROOMS_CONNECT_TO_ALL; //Create Cool Star/Shape like patterns
    BOOL SCALE_MAP_TO_FIT; //Mainly for seeing the big picture
    
    int **grid;
    
    UIImage* blockImg,*emptyImg;
    
    NSMutableArray *gridImageViews;
    
    int playerImage;
    UIImage* playerImages[8];
    UIImageView* player;
    CGPoint playerPos;
    NSMutableArray* movementPath;
    NSTimer* movementTimer;
    
    NSMutableArray* enemies;
    NSTimer* enemyTimer;
    
    UITapGestureRecognizer *singleTap;
    UIPanGestureRecognizer *swordTracker;
    UIView* map;
    
    BOOL attackingMode;
    
    UIImageView* sword;
    float swordRot;
}
- (IBAction)back;
- (IBAction)attackButtonDown;
- (IBAction)attackButtonUp;
- (void)repositionSword;
- (void)bresenhamLineAlgorithm:(int)startx startY:(int)starty endX:(int)endx endY:(int)endy;
- (void)generateMap;
- (IBAction)regenerateMap;
- (IBAction)handleTap:(UITapGestureRecognizer *)sender;
- (NSMutableArray*)findPath:(CGPoint)toPos from:(CGPoint)fromPos;
- (void)repositionMap:(BOOL)scaleToFit;
- (void)move;
@end
