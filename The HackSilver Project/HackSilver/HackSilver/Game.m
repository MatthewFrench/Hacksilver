//
//  Game.m
//  HackSilver
//
//  Created by Matthew French on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Game.h"

@implementation Game

- (IBAction)attackButtonDown {
    attackingMode = TRUE;
    [self repositionSword];
    [map addSubview:sword];
}
- (IBAction)attackButtonUp {
    [sword removeFromSuperview];
    [self repositionSword];
    attackingMode = FALSE;
}

- (void)repositionSword {
    sword.layer.anchorPoint = CGPointMake(0.5, 48.0/50.0);
    float swordx = playerPos.x*BLOCK_W;
    float swordy = playerPos.y*BLOCK_H;
    [map insertSubview:sword aboveSubview:player];
    if (playerImage+1 == 1) {swordx+=36;swordy+=26;}
    if (playerImage+1 == 2) {swordx+=32;swordy+=26;}
    if (playerImage+1 == 3) {swordx+=32;swordy+=28;}
    if (playerImage+1 == 4) {swordx+=34;swordy+=29;}
    if (playerImage+1 == 5) {swordx+=28;swordy+=29;}
    if (playerImage+1 == 6) {swordx+=13;swordy+=28; [map insertSubview:sword belowSubview:player];}
    if (playerImage+1 == 7) {swordx+=16;swordy+=28; [map insertSubview:sword belowSubview:player];}
    if (playerImage+1 == 8) {swordx+=22;swordy+=29; [map insertSubview:sword belowSubview:player];}
    sword.center = CGPointMake(swordx,swordy);
    [sword setTransform:CGAffineTransformMakeRotation(swordRot-M_PI/2)];
}

- (void)moveEnemies {
    for (Enemy* enemy in enemies) {
        enemy.moveCount += 1;
        if (enemy.moveCount >= 10) {
            enemy.moveCount = 0;
            if (abs(playerPos.x - enemy.x) < 2 &&
                abs(playerPos.y - enemy.y) < 2) {
                //Go toward player
                int moveX = 0;
                int moveY = 0;
                if (playerPos.x > enemy.x) {
                    moveX = 1;
                } else if (playerPos.x < enemy.x) {
                    moveX = -1;
                } else if (playerPos.y > enemy.y) {
                    moveY = 1;
                } else if (playerPos.y < enemy.y) {
                    moveY = -1;
                }
                if (enemy.x+moveX >= 0 && enemy.x+moveX < MAP_W &&
                    enemy.y+moveY >= 0 && enemy.y+moveY < MAP_H) {
                    if (grid[(int)enemy.x+moveX][(int)enemy.y+moveY]==1 &&
                        (enemy.x+moveX!=playerPos.x || enemy.y+moveY!=playerPos.y)) {
                        //Can't be on top of another enemy either
                        BOOL noMove = FALSE;
                        for (Enemy* enemy2 in enemies) {
                            if (enemy != enemy2 && enemy.x+moveX == enemy2.x && 
                                enemy.y+moveY == enemy2.y) {noMove=TRUE;}
                        }
                        if (!noMove) {
                            enemy.x += moveX;
                            enemy.y += moveY;
                            [enemy update:YES];
                        }
                    }
                }
            } else {
                //Move randomly
                int moveX = 0;
                int moveY = 0;
                if (rand()%2) {
                    moveX = (rand()%2==0?-1:1);
                } else {
                    moveY = (rand()%2==0?-1:1);
                }
                if (enemy.x+moveX >= 0 && enemy.x+moveX < MAP_W &&
                    enemy.y+moveY >= 0 && enemy.y+moveY < MAP_H) {
                    if (grid[(int)enemy.x+moveX][(int)enemy.y+moveY]==1) {
                        //Can't be on top of another enemy either
                        BOOL noMove = FALSE;
                        for (Enemy* enemy2 in enemies) {
                            if (enemy != enemy2 && enemy.x+moveX == enemy2.x && 
                                enemy.y+moveY == enemy2.y) {noMove=TRUE;}
                        }
                        if (!noMove) {
                            enemy.x += moveX;
                            enemy.y += moveY;
                            [enemy update:YES];
                        }
                    }
                }
            }
        }
    }
}

- (IBAction)handleSwordMove:(UIPanGestureRecognizer *)sender {
    if (attackingMode == TRUE) {
        //Rotate player and do swordry stuff
        CGPoint location = [sender locationInView:map];
        float tapx = location.x;
        float tapy = location.y;
        float px = player.center.x;
        float py = player.center.y;
        
        swordRot = atan2(py-tapy, px-tapx);
        
        float prot = swordRot+1.5*(M_PI/4);

        playerImage = (int)( 3+prot/(M_PI/4));
        if (playerImage > 7) {playerImage-=8;}
                 
        
        [player setImage:playerImages[playerImage]];
        [self repositionSword];
    }
}

- (IBAction)handleTap:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded && attackingMode == FALSE)     {         // handling code
        [movementTimer invalidate];
        movementPath = nil;
        CGPoint location = [sender locationInView:map];
        int tapx = location.x/BLOCK_W;
        int tapy = location.y/BLOCK_H;
        if (tapx >= 0 && tapx < MAP_W && tapy >= 0 && tapy < MAP_H) {
            if (grid[tapx][tapy]>0) {
                movementPath = [self findPath:CGPointMake(tapx, tapy) from:playerPos];
                if (movementPath) {
                    [self move];
                    movementTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(move) userInfo:nil repeats:YES];
                }
            }
        }
    } 
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    // Disallow recognition of tap gestures in the button.
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

- (void)move {
    CGPoint pos = [[movementPath objectAtIndex:0] CGPointValue];
    
    //Change player image.
    if (pos.x > playerPos.x) {player.image = playerImages[0];} 
    else if (pos.x < playerPos.x) {player.image = playerImages[4];} 
    else if (pos.y < playerPos.y) {player.image = playerImages[6];} 
    else if (pos.y > playerPos.y) {player.image = playerImages[2];} 
    
    BOOL move = TRUE;
    for (Enemy* enemy in enemies) {
        if (enemy.x == pos.x && enemy.y == pos.y) {
            move = FALSE;
        }
    }
    if (move) {
        playerPos = pos;
        if ([movementPath count] == 1) {
            [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseOut animations:^{
                player.frame = CGRectMake(playerPos.x*BLOCK_W,playerPos.y*BLOCK_H,BLOCK_W+1,BLOCK_H+1);
                if (attackingMode) {
                    [self repositionSword];
                }
                [self repositionMap:SCALE_MAP_TO_FIT];
            } completion:^(BOOL finished) {}];
        } else {
            [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveLinear animations:^{
                player.frame = CGRectMake(playerPos.x*BLOCK_W,playerPos.y*BLOCK_H,BLOCK_W+1,BLOCK_H+1);
                if (attackingMode) {
                    [self repositionSword];
                }
                [self repositionMap:SCALE_MAP_TO_FIT];
            } completion:^(BOOL finished) {}];
        }
        [movementPath removeObjectAtIndex:0];
        if ([movementPath count] == 0) {
            [movementTimer invalidate];
            movementPath = nil;
        }
    } else {
        [movementTimer invalidate];
        movementPath = nil;
    }
}

- (void)repositionMap:(BOOL)scaleToFit {
    float x,y;
    if (scaleToFit) {
        x = (-playerPos.x*BLOCK_W-player.frame.size.width/2.0)/SCALE+240;
        y = (-playerPos.y*BLOCK_H-player.frame.size.height/2.0)/SCALE+160;
    } else {
        x = (-playerPos.x*BLOCK_W-player.frame.size.width/2.0)+240;
        y = (-playerPos.y*BLOCK_H-player.frame.size.height/2.0)+160;
    }
    float width = map.frame.size.width;
    float height = map.frame.size.height;
    if (width > 480) {
        if (x > 0) {x = 0;}
        if (x + width < 480) {x = 480-width;}
    }
    if (height > 320) {
        if (y > 0) {y = 0;}
        if (y + height < 320) {y = 320-height;}
    }
    
    map.frame = CGRectMake(x,y,width,height);
}

- (NSMutableArray*)findPath:(CGPoint)toPos from:(CGPoint)fromPos {
    
    //Make an array that'll hold the flooding numbers
    int fillArray[MAP_W][MAP_H];
    for (int x = 0; x < MAP_W;x++) {
        for (int y = 0; y < MAP_H;y++) {
            if (grid[x][y] == 0) {
                //Blocks = -1
                fillArray[x][y] = -1;
            } else {
                //Empties = 0
                fillArray[x][y] = 0;
            }
        }
    }
    //Make enemies block too
    for (Enemy* enemy in enemies) {
        fillArray[(int)enemy.x][(int)enemy.y] = -1;
    }
    
    //Set the starting point to 1
    fillArray[(int)fromPos.x][(int)fromPos.y] = 1;
    //Have a while loop that runs as long as a tile can still be flooded
    BOOL stillTilesToFill=TRUE;
    BOOL reachedEnd = FALSE;
    while (stillTilesToFill) {
        stillTilesToFill = FALSE;
        for (int x = 0; x < MAP_W;x++) {
            for (int y = 0; y < MAP_H;y++) {
                if (fillArray[x][y] == 0) { //Empty tile needs a number
                    //Check all four directions for numbers
                    int touchingNumber = 0;
                    if (x-1 >= 0) { //Left
                        if (fillArray[x-1][y]>0) {
                            touchingNumber = fillArray[x-1][y];
                        }
                    }
                    if (x+1 < MAP_W) { //Right
                        if (fillArray[x+1][y]>0 && (fillArray[x+1][y] < touchingNumber || touchingNumber == 0)) {
                            touchingNumber = fillArray[x+1][y];
                        }
                    }
                    if (y-1 >= 0) { //Up
                        if (fillArray[x][y-1]>0 && (fillArray[x][y-1] < touchingNumber || touchingNumber == 0)) {
                            touchingNumber = fillArray[x][y-1];
                        }
                    }
                    if (y+1 < MAP_H) { //Down
                        if (fillArray[x][y+1]>0 && (fillArray[x][y+1] < touchingNumber || touchingNumber == 0)) {
                            touchingNumber = fillArray[x][y+1];
                        }
                    }
                    if (touchingNumber > 0) {
                        stillTilesToFill = TRUE;
                        fillArray[x][y] = touchingNumber+1;
                        if (x == toPos.x && y == toPos.y) {//Hit the tile we want
                            stillTilesToFill = FALSE;
                            x = MAP_W;
                            y = MAP_H;
                            reachedEnd = TRUE;
                        }
                    }
                }
            }
        }
    }
    if (!reachedEnd) {
        return nil;
    }
    //Array has been filled. Now track back.
    CGPoint trackBackTile = toPos;
    NSMutableArray* path = [[NSMutableArray alloc] init];
    [path addObject:[NSValue valueWithCGPoint:trackBackTile]];
    
    BOOL reachedBeginning = FALSE;
    //Loop through until reached starting position
    while (!reachedBeginning) {
        CGPoint lowestTile = CGPointMake(-1,-1);
        int lowestTileNum = 0;
        
        CGPoint tempTile;
        int tempTileNum = 0;
        for (int i = 0; i < 4; i++) {
            tempTile = CGPointMake(-1,-1);
            tempTileNum = 0;
            if (i == 0 && trackBackTile.x - 1 >= 0) { //left
                tempTile = CGPointMake(trackBackTile.x-1,trackBackTile.y);
            }
            if (i == 1 && trackBackTile.x + 1 < MAP_W) { //right
                tempTile = CGPointMake(trackBackTile.x+1,trackBackTile.y);
            }
            if (i == 2 && trackBackTile.y - 1 >= 0) { //up
                tempTile = CGPointMake(trackBackTile.x,trackBackTile.y-1);
            }
            if (i == 3 && trackBackTile.y + 1 < MAP_H) { //down
                tempTile = CGPointMake(trackBackTile.x,trackBackTile.y+1);
            }
            
            if (tempTile.x != -1) {
                tempTileNum = fillArray[(int)tempTile.x][(int)tempTile.y];
                if (tempTileNum > 0) {
                    if (lowestTileNum == 0) {
                        lowestTile = tempTile;
                        lowestTileNum = tempTileNum;
                    } else if (tempTileNum<lowestTileNum) {
                        lowestTile = tempTile;
                        lowestTileNum = tempTileNum;
                    }
                }
            }
        }
        [path insertObject:[NSValue valueWithCGPoint:lowestTile] atIndex:0];
        trackBackTile = lowestTile;
        if (trackBackTile.x == fromPos.x && trackBackTile.y == fromPos.y) {reachedBeginning = TRUE;}
    }
    return path;
}

- (void)generateMap {
    //Make an array of open space according to quadrant
    NSMutableArray* openSpacesTopLeft = [[NSMutableArray alloc] init];
    NSMutableArray* openSpacesTopRight = [[NSMutableArray alloc] init];
    NSMutableArray* openSpacesBottomLeft = [[NSMutableArray alloc] init];
    NSMutableArray* openSpacesBottomRight = [[NSMutableArray alloc] init];
    int centerx = MAP_W-ROOM_W/2.0;
    int centery = MAP_H-ROOM_H/2.0;
    for (int x = 1; x < MAP_W-ROOM_W;x++) {
        for (int y = 1; y < MAP_H-ROOM_H;y++) {
            if (x < centerx && y < centery) {
                 [openSpacesTopLeft addObject: [NSValue valueWithCGPoint:CGPointMake(x, y)]];
            }
            if (x >= centerx && y < centery) {
                [openSpacesTopRight addObject: [NSValue valueWithCGPoint:CGPointMake(x, y)]];
            }
            if (x < centerx && y > centery) {
                [openSpacesBottomLeft addObject: [NSValue valueWithCGPoint:CGPointMake(x, y)]];
            }
            if (x >= centerx && y > centery) {
                [openSpacesBottomRight addObject: [NSValue valueWithCGPoint:CGPointMake(x, y)]];
            }
        }
    }
    
    //Create the rooms randomly
    CGPoint rooms[ROOM_COUNT];
    for (int i = 0; i < ROOM_COUNT && ([openSpacesTopLeft count]>0 || [openSpacesTopRight count]>0 ||
                                       [openSpacesBottomLeft count]>0 || [openSpacesBottomRight count]>0);i++) {
        //Place each room randomly within a certain quadrant
        NSMutableArray* spaces = nil;
        while (!spaces) {
            int quadrant = rand()%4;
            if (quadrant == 0) {spaces = openSpacesTopLeft;}
            if (quadrant == 1) {spaces = openSpacesTopRight;}
            if (quadrant == 2) {spaces = openSpacesBottomLeft;}
            if (quadrant == 3) {spaces = openSpacesBottomRight;}
            if ([spaces count] == 0) {spaces = nil;}
        }
        int space = rand()%[spaces count];
        CGPoint room = [[spaces objectAtIndex:space] CGPointValue];
        [spaces removeObjectAtIndex:space];
        
        //Add enemies. 1 per room.
        Enemy* enemy = [enemies objectAtIndex:i];
        enemy.x = room.x;
        enemy.y = room.y;
        [enemy update:NO];
        
        rooms[i] = room;
        //Now alter the grid to show the rooms
        for (int x = 0; x < ROOM_W;x++) {
            for (int y = 0; y < ROOM_H;y++) {
                grid[(int)rooms[i].x+x][(int)rooms[i].y+y] = 1;
            }
        }
    }
    //Now connect the rooms
    if (ROOMS_CONNECT_TO_ALL) {
        for (int i = 0; i < ROOM_COUNT;i++) {
            CGPoint room1 = rooms[i];
            for (int j = 0; j < ROOM_COUNT;j++) {
                CGPoint room2 = rooms[j];
                [self bresenhamLineAlgorithm:room1.x startY:room1.y endX:room2.x endY:room2.y];
            }
        }
    } else {
        for (int i = 0; i < ROOM_COUNT;i++) {
            CGPoint room1 = rooms[i];
            CGPoint room2;
            if (i+1 >= ROOM_COUNT) {
                room2 = rooms[0];
            }   else {
                room2 = rooms[i+1];
            }
            [self bresenhamLineAlgorithm:room1.x startY:room1.y endX:room2.x endY:room2.y];
        }
    }
    openSpacesTopLeft = nil;
    openSpacesTopRight = nil;
    openSpacesBottomLeft = nil;
    openSpacesBottomRight = nil;
}

- (void)bresenhamLineAlgorithm:(int)startx startY:(int)starty endX:(int)endx endY:(int)endy {
    signed char ix;
    signed char iy;
    
    int prevx=startx;
    int prevy=starty;
    
    // if startx == endx or starty == endy, then it does not matter what we set here
    int delta_x;//int delta_x((endx > startx?(ix = 1, endx - startx):(ix = -1, startx - endx)) << 1);
    if (endx > startx) {
        ix = 1;
        delta_x = endx - startx;
        delta_x = delta_x * 2;
    } else {
        ix = -1;
        delta_x = startx - endx;
        delta_x *= 2;
    }
    
    int delta_y; //int delta_y((endy > starty?(iy = 1, endy - starty):(iy = -1, starty - endy)) << 1);
    if (endy > starty) {
        iy = 1;
        delta_y = endy - starty;
        delta_y *= 2;
    } else {
        iy = -1;
        delta_y = starty - endy;
        delta_y *= 2;
    }
    
    grid[startx][starty] = 1;
    
    if (delta_x >= delta_y)
    {
        // error may go below zero
        int error=(delta_y - (delta_x >> 1)); //int error(delta_y - (delta_x >> 1));
        
        while (startx != endx)
        {
            if (error >= 0)
            {
                if (error || (ix > 0))
                {
                    starty += iy;
                    error -= delta_x;
                }
                // else do nothing
            }
            // else do nothing
            
            startx += ix;
            error += delta_y;
            
            grid[startx][starty]=1;
            
            //Look for aweful corners and ANNIHILATE THEM!
            if (startx > prevx && starty > prevy) {grid[prevx+1][prevy]=1;}
            if (startx > prevx && starty < prevy) {grid[prevx+1][prevy]=1;}
            if (startx < prevx && starty > prevy) {grid[prevx-1][prevy]=1;}
            if (startx < prevx && starty < prevy) {grid[prevx-1][prevy]=1;}
            prevx = startx;
            prevy = starty;
        }
    }
    else
    {
        // error may go below zero
        int error=(delta_x - (delta_y >> 1));
        
        while (starty != endy)
        {
            if (error >= 0)
            {
                if (error || (iy > 0))
                {
                    startx += ix;
                    error -= delta_y;
                }
                // else do nothing
            }
            // else do nothing
            
            starty += iy;
            error += delta_x;
            
            grid[startx][starty]=1;
            
            //Look for aweful corners and ANNIHILATE THEM!
            if (startx > prevx && starty > prevy) {grid[prevx+1][prevy]=1;}
            if (startx > prevx && starty < prevy) {grid[prevx+1][prevy]=1;}
            if (startx < prevx && starty > prevy) {grid[prevx-1][prevy]=1;}
            if (startx < prevx && starty < prevy) {grid[prevx-1][prevy]=1;}
            prevx = startx;
            prevy = starty;
        }
    }
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib
    SCALE = 3;
    MAP_W = 10*SCALE;
    MAP_H = 7*SCALE;
    ROOM_W = 3;
    ROOM_H = 3;
    ROOM_COUNT = 8;
    BLOCK_W = 45;
    BLOCK_H = 45;
    ROOMS_CONNECT_TO_ALL = FALSE; //Create Cool Star/Shape like patterns
    SCALE_MAP_TO_FIT = FALSE; //Mainly for seeing the big picture
    
    grid = (int**)malloc(MAP_W * sizeof(int*));
    for (int i = 0; i < MAP_W; i++) {
        grid[i] = (int*)malloc(MAP_H * sizeof(int));
    }
    
    for (int i = 0; i < 8; i++) {
        playerImages[i] = [UIImage imageNamed:[NSString stringWithFormat:@"man%d.png",i+1]];
    }
    
    singleTap =
    [[UITapGestureRecognizer alloc] initWithTarget: self
                                            action: @selector(handleTap:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    singleTap.cancelsTouchesInView = NO;
    singleTap.delegate = self;
    [self.view addGestureRecognizer: singleTap];
    
    swordTracker =
    [[UIPanGestureRecognizer alloc] initWithTarget: self
                                            action: @selector(handleSwordMove:)];
    swordTracker.cancelsTouchesInView = NO;
    swordTracker.delegate = self;
    [self.view addGestureRecognizer: swordTracker];
    
    //Initialize grid
    
    emptyImg = [UIImage imageNamed:@"empty.png"];
    blockImg = [UIImage imageNamed:@"dark.png"];
    
    map = [[UIView alloc] initWithFrame:CGRectMake(0,0,MAP_W*BLOCK_W,MAP_H*BLOCK_H)];
    [map setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [map setContentMode:UIViewContentModeCenter];
    gridImageViews = [[NSMutableArray alloc] init];
    for (int x = 0; x < MAP_W;x++) {
        NSMutableArray *column = [[NSMutableArray alloc] init];
        for (int y = 0; y < MAP_H;y++) {
            UIImageView* tile = 
            [[UIImageView alloc] initWithFrame:CGRectMake((x)*BLOCK_W, (y)*BLOCK_H, BLOCK_W, BLOCK_H)];
            [map addSubview:tile];
            [column addObject:tile];
        }
        [gridImageViews addObject:column];
    }
    
    
    //Add in enemies
    enemies = [[NSMutableArray alloc] init];
    for (int i = 0; i < ROOM_COUNT;i++) {
        Enemy* enemy = [[Enemy alloc] initWithWidth:BLOCK_W height:BLOCK_H];
        [enemy.imageView setImage:[UIImage imageNamed:@"demon.png"]];
        [map addSubview: enemy.imageView];
        [enemies addObject:enemy];
    }
    
    player = [[UIImageView alloc] initWithImage:playerImages[0]];
    [map addSubview:player];
    
    sword = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sword.png"]];
    
    [self regenerateMap];
    
    [map setBackgroundColor:[UIColor orangeColor]];
    [self.view insertSubview:map atIndex:0];
    
    
    
    /*
    CGAffineTransform tr = CGAffineTransformScale(map.transform, SCALE, SCALE);
    CGFloat h = map.frame.size.height;
    [UIView animateWithDuration:2.5 delay:0 options:0 animations:^{
        map.transform = tr;
        map.center = CGPointMake(0,h);
    } completion:^(BOOL finished) {}];
     */
    if (SCALE_MAP_TO_FIT) {
        [self repositionMap:FALSE];
    } else {
        map.transform = CGAffineTransformMakeScale(1.0/SCALE, 1.0/SCALE);
        map.center = CGPointMake(240,160);
    }
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (SCALE_MAP_TO_FIT) {
        [UIView animateWithDuration:1.0 delay:0.5 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            map.transform = CGAffineTransformScale(map.transform, 1.0/SCALE, 1.0/SCALE);
            [self repositionMap:SCALE_MAP_TO_FIT];
        } completion:^(BOOL finished) {
            enemyTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(moveEnemies) userInfo:nil repeats:YES];
        }];
    } else {
        [UIView animateWithDuration:1.0 delay:0.5 options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            map.transform = CGAffineTransformScale(map.transform, SCALE, SCALE);
            [self repositionMap:SCALE_MAP_TO_FIT];
        } completion:^(BOOL finished) {
            enemyTimer = [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(moveEnemies) userInfo:nil repeats:YES];
        }];
    }
}

- (IBAction)regenerateMap {
    [movementTimer invalidate];
    movementPath = nil;
    
    for (int x = 0; x < MAP_W;x++) {
        for (int y = 0; y < MAP_H;y++) {
            grid[x][y] = 0;
        }
    }
    [self generateMap];
    for (int x = 0; x < MAP_W;x++) {
        NSMutableArray *column = [gridImageViews objectAtIndex:x];
        for (int y = 0; y < MAP_H;y++) {
            UIImageView* tile = [column objectAtIndex:y];
            [tile setImage:grid[x][y]?emptyImg:blockImg];
        }
    }
    
    //place player randomly
    //Make an array of open space
    NSMutableArray* openSpaces = [[NSMutableArray alloc] init];
    for (int x = 1; x < MAP_W-ROOM_W;x++) {
        for (int y = 1; y < MAP_H-ROOM_H;y++) {
            if (grid[x][y]==1) {
                BOOL place = TRUE;
                for (Enemy* enemy in enemies) {
                    if (enemy.x == x && enemy.y == y) {
                        place = FALSE;
                    }
                }
                if (place) {
                    [openSpaces addObject: [NSValue valueWithCGPoint:CGPointMake(x, y)]];
                }
            }
        }
    }
    playerPos = [[openSpaces objectAtIndex:rand()%[openSpaces count]] CGPointValue];
    player.frame = CGRectMake(playerPos.x*BLOCK_W,playerPos.y*BLOCK_H,BLOCK_W, BLOCK_H);
    openSpaces = nil;
    
    [self repositionMap:SCALE_MAP_TO_FIT];
}

- (IBAction)back {
    [movementTimer invalidate];
    movementPath = nil;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    gridImageViews = nil;
    emptyImg = nil;
    blockImg = nil;
    for (int i = 0; i < MAP_W; i++) {
        free(grid[i]);
    }
    free(grid);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return ( UIInterfaceOrientationIsLandscape(interfaceOrientation));
}

@end
