//
//  GameViewController.h
//  hello sceneKit
//

//  Copyright (c) 2016年 Amon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import "AAPLGameView.h"
@import GameController;
@interface GameViewController : UIViewController<SCNSceneRendererDelegate>
{
    CAAnimation *_walkAnimation;
     SCNNode *_cameraNode;
    SCNNode * panda;
    float z;
    NSTimeInterval _previousUpdateTime;
    BOOL iswalking;



}


@property (nonatomic, strong) AAPLGameView *gameView;
@end


