//
//  AAPLGameView.m
//  hello sceneKit
//

//  Copyright (c) 2016年 Amon. All rights reserved.
//

@import SpriteKit;

#import "AAPLGameView.h"

@implementation AAPLGameView {
    SKNode *_overlayNode;
    SKNode *_congratulationsGroupNode;
    SKLabelNode *_collectedPearlCountLabel;
    NSMutableArray<SKSpriteNode *> *_collectedFlowerSprites;
}

#pragma mark -  2D Overlay

#if TARGET_OS_IOS || TARGET_OS_TV

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup2DOverlay];
}

- (void)layoutSubviews {
    [super layoutSubviews];
   // [self layout2DOverlay];
}

#else

- (void)viewDidMoveToWindow {
    [super viewDidMoveToWindow];
    [self setup2DOverlay];
}

- (void)setFrameSize:(NSSize)newSize {
    [super setFrameSize:newSize];

}

#endif


- (void)setup2DOverlay {
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    

    
    // Setup the game overlays using SpriteKit.
    SKScene *skScene = [SKScene sceneWithSize:CGSizeMake(w, h)];
    skScene.scaleMode = SKSceneScaleModeResizeFill;
    

    
    // The virtual D-pad
#if TARGET_OS_IOS
    
    CGRect virtualDPadBounds = self.virtualDPadBoundsInScene;
    SKSpriteNode *dpadSprite = [SKSpriteNode spriteNodeWithImageNamed:@"dpad.png"];
    dpadSprite.anchorPoint = CGPointMake(0.0, 0.0);
    dpadSprite.position = virtualDPadBounds.origin;
    dpadSprite.size = virtualDPadBounds.size;
    [skScene addChild:dpadSprite];
    
#endif
    
    // Assign the SpriteKit overlay to the SceneKit view.
    self.overlaySKScene = skScene;
    skScene.userInteractionEnabled = NO;
}



#if !(TARGET_OS_IOS || TARGET_OS_TV)

- (void)mouseDown:(NSEvent *)theEvent {
    if (!_eventsDelegate || [_eventsDelegate mouseDown:self event:theEvent] == NO) {
        [super mouseDown:theEvent];
    }
}

- (void)mouseDragged:(NSEvent *)theEvent {
    if (!_eventsDelegate || [_eventsDelegate mouseDragged:self event:theEvent] == NO) {
        [super mouseDragged:theEvent];
    }
}

- (void)mouseUp:(NSEvent *)theEvent {
    if (!_eventsDelegate || [_eventsDelegate mouseUp:self event:theEvent] == NO) {
        [super mouseUp:theEvent];
    }
}

- (void)keyDown:(NSEvent *)theEvent {
    if (!_eventsDelegate || [_eventsDelegate keyDown:self event:theEvent] == NO) {
        [super keyDown:theEvent];
    }
}

- (void)keyUp:(NSEvent *)theEvent {
    if (!_eventsDelegate || [_eventsDelegate keyUp:self event:theEvent] == NO) {
        [super keyUp:theEvent];
    }
}

#endif

#pragma mark - Virtual D-pad

#if TARGET_OS_IOS

- (CGRect)virtualDPadBoundsInScene {
    return CGRectMake(10.0, 10.0, 150.0, 150.0);
}

- (CGRect)virtualDPadBounds {
    CGRect virtualDPadBounds = [self virtualDPadBoundsInScene];
    virtualDPadBounds.origin.y = self.bounds.size.height - virtualDPadBounds.size.height + virtualDPadBounds.origin.y;
    return virtualDPadBounds;
}

#endif

@end
