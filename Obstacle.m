//
//  Obstacle.m
//  FlappyBird
//
//  Created by 吴海涛 on 14-3-14.
//  Copyright 2014年 Apportable. All rights reserved.
//

#import "Obstacle.h"


@implementation Obstacle{
    CCNode *_bottomPipe ;
    CCNode *_topPipe ;
}

#define ARC4RANDOM_MAX 0x100000000
//visibility on a 3.5-inch iPhone ends a 88 points and we want some meat
static const CGFloat minmumYPositionTopPipe = 128.f ;
static const CGFloat maxmumYpositionBottomPipe = 440.f ;
static const CGFloat pipeDistance = 142.f ;
static const CGFloat maxmumYpositionTopPipe = maxmumYpositionBottomPipe - pipeDistance ;


- (void)didLoadFromCCB{
    _bottomPipe.physicsBody.collisionType = @"level" ;
    //为什么加了这行后，collision 就会消失？
//    _bottomPipe.physicsBody.sensor = TRUE ;
    _topPipe.physicsBody.collisionType = @"level" ;
//    _topPipe.physicsBody.sensor = TRUE ;

}



- (void) setupRandomPosition
{
    CGFloat random = ((double)arc4random() / ARC4RANDOM_MAX) ;
    CGFloat range = maxmumYpositionTopPipe - minmumYPositionTopPipe ;
//    _topPipe.position = ccp(_topPipe.position.x, _topPipe.position.y) ;
    _topPipe.position = ccp(_topPipe.position.x, minmumYPositionTopPipe+(range*random)) ;
    _bottomPipe.position = ccp(_bottomPipe.position.x, _topPipe.position.y+pipeDistance) ;
}

@end
