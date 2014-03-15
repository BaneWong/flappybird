//
//  Goals.m
//  FlappyBird
//
//  Created by 吴海涛 on 14-3-15.
//  Copyright 2014年 Apportable. All rights reserved.
//

#import "Goals.h"


@implementation Goals

- (void)didLoadFromCCB
{
    CCLOG(@"goals didLoadFromCCB ...") ;
    self.physicsBody.collisionType = @"goals" ;
//    self.physicsBody.sensor = TRUE ;
}

@end
