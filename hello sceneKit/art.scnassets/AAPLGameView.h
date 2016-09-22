//
//  AAPLGameView.h
//  hello sceneKit
//

//  Copyright (c) 2016年 Amon. All rights reserved.
//

@import simd;
@import SceneKit;

@protocol AAPLKeyboardAndMouseEventsDelegate <NSObject>
#if !(TARGET_OS_IOS || TARGET_OS_TV)
@required
- (BOOL)mouseDown:(NSView *)view event:(NSEvent *)event;
- (BOOL)mouseDragged:(NSView *)view event:(NSEvent *)event;
- (BOOL)mouseUp:(NSView *)view event:(NSEvent *)event;
- (BOOL)keyDown:(NSView *)view event:(NSEvent *)event;
- (BOOL)keyUp:(NSView *)view event:(NSEvent *)event;
#endif
@end

@interface AAPLGameView : SCNView

@property(nonatomic) NSUInteger collectedPearlsCount;
@property(nonatomic) NSUInteger collectedFlowersCount;

- (void)showEndScreen;

@property(nonatomic, weak) id <AAPLKeyboardAndMouseEventsDelegate> eventsDelegate;

#if TARGET_OS_IOS
- (CGRect)virtualDPadBounds;
#endif

@end
