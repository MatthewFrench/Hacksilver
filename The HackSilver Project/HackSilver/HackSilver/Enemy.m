//
//  Enemy.m
//  HackSilver
//
//  Created by Matthew French on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Enemy.h"

@implementation Enemy
@synthesize x,y,width,height,moveCount,imageView;
- (id)initWithWidth:(float)w height:(float)h
{
    self = [super init];
    if (self) {
        // Initialization code here.
        x = 0;
        y = 0;
        moveCount = 0;
        width = w;
        height = h;
        imageView = [[UIImageView alloc] init];
    }
    
    return self;
}
-(void)update:(BOOL)animated {
    [UIView animateWithDuration:1.0/3 delay:0.0 options:UIViewAnimationOptionAllowUserInteraction 
    animations:^{
         imageView.frame = CGRectMake(x*width,y*height,width+1,height+1);
    }completion:^(BOOL finished){}];
}

@end
