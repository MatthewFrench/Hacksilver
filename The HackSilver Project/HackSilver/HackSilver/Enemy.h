//
//  Enemy.h
//  HackSilver
//
//  Created by Matthew French on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Enemy : NSObject
@property(nonatomic) float x,width;
@property(nonatomic) float y,height;
@property(nonatomic) int moveCount;
@property(nonatomic, retain) UIImageView* imageView;

- (id)initWithWidth:(float)w height:(float)h;
-(void)update:(BOOL)animated;
@end
