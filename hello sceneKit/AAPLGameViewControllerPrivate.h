//
//AAPLGameViewControllerPrivate.h
//  hello sceneKit
//

//  Copyright (c) 2016年 Amon. All rights reserved.
//

@import simd;
@import SceneKit;
@import GameController;

#import "GameViewController.h"


@interface GameViewController() {

    // Game controls
    GCControllerDirectionPad *_controllerDPad;
    vector_float2 _controllerDirection;
    
#if !(TARGET_OS_IOS || TARGET_OS_TV)
    CGPoint _lastMousePosition;
#elif TARGET_OS_IOS
    UITouch *_padTouch;
    UITouch *_panningTouch;
#endif
}

- (void)panCamera:(CGPoint)direction;

@end

@interface GameViewController (GameControls) <AAPLKeyboardAndMouseEventsDelegate>

- (void)setupGameControllers;
@property(nonatomic, readonly) vector_float2 controllerDirection;

@end
