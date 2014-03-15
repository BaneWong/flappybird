//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "Obstacle.h"


//static const CGFloat _scrollSpeed = 80.f;
static const CGFloat firstObstaclePosition = 280.f;
static const CGFloat distanceBetweenObstacles = 160.f ;
typedef NS_ENUM(NSInteger, DrawingOrder){
    DrawingOrderPipes,
    DrawingOrderGround,
    DrawingOrderHero
};
@implementation MainScene{
    
    CCSprite *_hero ;
    CCPhysicsNode *_physicsNode ;
    CCNode *_ground1 ;
    CCNode *_ground2 ;
    NSArray *_groundsArray ;
    NSTimeInterval _sinceTouch;
    NSMutableArray *_obstacles ;
    CCButton *_restartButton ;
    CGFloat _scrollSpeed ;
    BOOL _isGameOver ;
    NSInteger _points ;
    CCLabelTTF *_scoreLabel ;
    
}
- (void)didLoadFromCCB{
    self.userInteractionEnabled = YES ;
    _scrollSpeed = 80.f ;
    _groundsArray = @[_ground1,_ground2];
    //???
    for(CCNode *ground in _groundsArray){
        ground.zOrder = DrawingOrderGround ;
        ground.physicsBody.collisionType = @"level" ;
    }
    
    _obstacles = [NSMutableArray array] ;
    [self spawnNewObstacle] ;
    [self spawnNewObstacle] ;
    [self spawnNewObstacle] ;
    
    //set this class as delegate ;
    _physicsNode.collisionDelegate = self ;
    _hero.physicsBody.collisionType = @"hero" ;
    _hero.zOrder = DrawingOrderHero ;
    
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero level:(CCNode *)level
{
    CCLOG(@"ccPhysicsCollisionBegin  ") ;
    [self gameOver];
    return YES ;
}

//- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero goal:(CCNode *)goal
//{
//    CCLOG(@"hero and goals collision ") ;
//    [goal removeFromParent] ;
//    _points ++ ;
//    _scoreLabel.string = [NSString stringWithFormat:@"%d",_points] ;
//    return TRUE ;
//}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair hero:(CCNode *)hero goals:(CCNode *)goals
{
    CCLOG(@"hero and goals collision ") ;
    [goals removeFromParent];
    _points++;
    _scoreLabel.string = [NSString stringWithFormat:@"%d", _points];
    return TRUE;
}


- (void)update:(CCTime)delta
{
    //clamp velocity
    float yVelocity = clampf(_hero.physicsBody.velocity.y,-1*MAXFLOAT,200.f);
    _hero.physicsBody.velocity = ccp(0, yVelocity);
    float moveDistance = delta*_scrollSpeed ;
    _hero.position = ccp(_hero.position.x + moveDistance,_hero.position.y);
//    CCLOG(@"hero x=%f y = %f",_hero.position.x,_hero.position.y);
//    CCLOG(@"position of physicsNode x:%f y:%f",_physicsNode.position.x,_physicsNode.position.y);
//    CCLOG(@"cctime<<<<<<<<<<<<< 3%f",delta) ;
    _physicsNode.position = ccp(_physicsNode.position.x - moveDistance,_physicsNode.position.y);
    // loop the ground
    
    for (CCNode *ground in _groundsArray)
    {
//        CCLOG(@"ground x %f y=%f",ground.position.x,ground.position.y);
        // get the world position of the ground
        CGPoint groundWorldPosition = [_physicsNode convertToWorldSpace:ground.position];
        // get the screen position of the ground
        CGPoint groundScreenPosition = [self convertToNodeSpace:groundWorldPosition];
        // if the left corner is one complete width off the screen, move it to the right
        if (groundScreenPosition.x <= (-1 * ground.contentSize.width))
        {
            ground.position = ccp(ground.position.x + 2 * ground.contentSize.width, ground.position.y);
        }
    }
    
    _sinceTouch += delta;
    _hero.rotation = clampf(_hero.rotation, -30.f, 90.f);
    if (_hero.physicsBody.allowsRotation) {
        float angularVelocity = clampf(_hero.physicsBody.angularVelocity, -2.f, 1.f);
        _hero.physicsBody.angularVelocity = angularVelocity;
    }
    if ((_sinceTouch > 0.5f)) {
        [_hero.physicsBody applyAngularImpulse:-40000.f*delta];
    }
    
    
    NSMutableArray *offScreenObstacles = nil ;
    for(CCNode *obstacle in _obstacles)
    {
        CGPoint obstacleWorldPosition = [_physicsNode convertToWorldSpace:obstacle.position] ;
        CGPoint obstacleScreenPosition = [self convertToNodeSpace:obstacleWorldPosition];
        if(obstacleScreenPosition.x <= -obstacle.contentSize.width)
        {
            if(!offScreenObstacles){
                offScreenObstacles = [NSMutableArray array] ;
            }
            [offScreenObstacles addObject:obstacle] ;
        }
        
    }
    for(CCNode *obstacle2Rm in offScreenObstacles)
    {
        [obstacle2Rm removeFromParent] ;
        [_obstacles removeObject:obstacle2Rm] ;
        //for each removed obstacle, add a new one
        [self spawnNewObstacle] ;
    }
    
    
}

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if(!_isGameOver)
    {
        [_hero.physicsBody applyImpulse:ccp(0, 350.f)];
        [_hero.physicsBody applyAngularImpulse:10000.f];
        _sinceTouch = 0.f;
        
    }
}


- (void)restartGame
{
    CCScene *scene = [CCBReader loadAsScene:@"MainScene"] ;
    [[CCDirector sharedDirector] replaceScene:scene] ;
}

- (void)spawnNewObstacle
{
    CCNode *previousObstacle = [_obstacles lastObject];
    CGFloat previousObstacleXPosition = previousObstacle.position.x ;
    if(!previousObstacle){
        previousObstacleXPosition = firstObstaclePosition ;
    }
    Obstacle *obstacle = (Obstacle*)[CCBReader load:@"Obstacle"] ;
    obstacle.zOrder = DrawingOrderPipes ;
    obstacle.position = ccp(previousObstacleXPosition + distanceBetweenObstacles,0) ;
    [obstacle setupRandomPosition] ;
    [_physicsNode addChild:obstacle] ;
    [_obstacles addObject:obstacle] ;
}


- (void)gameOver
{
    if (!_isGameOver) {
        _scrollSpeed = 0.f;
        _isGameOver = TRUE;
        _restartButton.visible = TRUE;
        _hero.rotation = 90.f;
        _hero.physicsBody.allowsRotation = FALSE;
        [_hero stopAllActions];
        CCActionMoveBy *moveBy = [CCActionMoveBy actionWithDuration:0.2f position:ccp(-2, 2)];
        CCActionInterval *reverseMovement = [moveBy reverse];
        CCActionSequence *shakeSequence = [CCActionSequence actionWithArray:@[moveBy, reverseMovement]];
        CCActionEaseBounce *bounce = [CCActionEaseBounce actionWithAction:shakeSequence];
        [self runAction:bounce];
    }
}


@end
