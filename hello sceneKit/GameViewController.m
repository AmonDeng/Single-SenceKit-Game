//
//  GameViewController.m
//  hello sceneKit
//
//  Created by Amon   Deng on 16/8/9.
//  Copyright (c) 2016年 Amon. All rights reserved.
//

#import "GameViewController.h"
#import "AAPLGameViewControllerPrivate.h"
@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // create a new scene
    SCNScene *scene = [SCNScene scene];
    self.gameView.scene = scene;
//    self.gameView.playing = YES;
//    self.gameView.loops = YES;

    self.gameView.scene.physicsWorld.contactDelegate = self;
    self.gameView.delegate = self;
    // set the scene to the view


    SCNScene *pandaScene = [SCNScene sceneNamed:@"art.scnassets/panda.scn"];
    panda = pandaScene.rootNode.childNodes[0];
    panda.scale = SCNVector3Make(3, 3, 3);
    [scene.rootNode addChildNode:panda];


    // setup the chassis

   // [scene.rootNode addChildNode:pandaScene];
    // create and add a camera to the scene
    _cameraNode = [SCNNode node];
    _cameraNode.camera = [SCNCamera camera];
    [scene.rootNode addChildNode:_cameraNode];

    
    // place the camera
//    z = 20;
    _cameraNode.position = SCNVector3Make(0, 10, 20);
     _cameraNode.rotation  = SCNVector4Make(1, 0, 0, -M_PI_4*0.75);

//    SCNNode *frontCameraNode = [SCNNode node];
//    frontCameraNode.position = SCNVector3Make(0, 3.5, 2.5);
//    frontCameraNode.rotation = SCNVector4Make(0, 1, 0, M_PI);
//    frontCameraNode.camera = [SCNCamera camera];
//    frontCameraNode.camera.xFov = 0;
//    frontCameraNode.camera.zFar = 500;
//
//    [panda addChildNode:frontCameraNode];

    // create and add a light to the scene
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeOmni;
    lightNode.position = SCNVector3Make(0, 60, 50);
    [scene.rootNode addChildNode:lightNode];
    
    // create and add an ambient light to the scene
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [UIColor darkGrayColor];
    [scene.rootNode addChildNode:ambientLightNode];


    _walkAnimation = [self loadAnimationFromSceneNamed:@"art.scnassets/walk.scn"];
    _walkAnimation.usesSceneTimeBase = NO;
    _walkAnimation.fadeInDuration = 0.3;
    _walkAnimation.fadeOutDuration = 0.3;
    _walkAnimation.repeatCount = FLT_MAX;

    // retrieve the ship node
//    SCNNode *ship = [scene.rootNode childNodeWithName:@"panda" recursively:YES];
//    ship.rotation = SCNVector4Make(0, 1, 0, 0);
//    ship.position = SCNVector3Make(10, 4, 0);

    // animate the 3d object
     [panda addAnimation:_walkAnimation forKey:@"walk"];
    // retrieve the SCNView

    
    // allows the user to manipulate the camera
    //self.gameView.allowsCameraControl = YES;
        
    // show statistics such as fps and timing information
//    scnView.showsStatistics = YES;
//
//    // configure the view
//    scnView.backgroundColor = [UIColor blackColor];

    // add a tap gesture recognizer
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
//    NSMutableArray *gestureRecognizers = [NSMutableArray array];
//    [gestureRecognizers addObject:tapGesture];
//    [gestureRecognizers addObjectsFromArray:scnView.gestureRecognizers];
//    scnView.gestureRecognizers = gestureRecognizers;

    SCNNode*floor = [SCNNode node];
    floor.geometry = [SCNFloor floor];
    floor.geometry.firstMaterial.diffuse.contents = @"wood.png";
    floor.geometry.firstMaterial.diffuse.contentsTransform = SCNMatrix4MakeScale(2, 2, 1); //scale the wood texture
    floor.geometry.firstMaterial.locksAmbientWithDiffuse = YES;
    //    if ([self isHighEndDevice])
    //        ((SCNFloor*)floor.geometry).reflectionFalloffEnd = 10;

    SCNPhysicsBody *staticBody = [SCNPhysicsBody staticBody];
    floor.physicsBody = staticBody;
    [scene.rootNode addChildNode:floor];
    [self setupGameControllers];
    //[self setupEnvironment:scnView.scene];
    



}


- (AAPLGameView *)gameView {
    return (AAPLGameView *)self.view;
}

- (vector_float3)characterDirection {
    vector_float2 controllerDirection = self.controllerDirection;
    vector_float3 direction = {controllerDirection.x, 0.0, controllerDirection.y};

    SCNNode *pov = self.gameView.pointOfView;
    if (pov) {
        SCNVector3 p1 = [pov.presentationNode convertPosition:SCNVector3Make(direction.x, direction.y, direction.z) toNode:nil];
        SCNVector3 p0 = [pov.presentationNode convertPosition:SCNVector3Zero toNode:nil];
        direction = (vector_float3){p1.x - p0.x, 0.0, p1.z - p0.z};

        if (direction.x != 0.0 || direction.z != 0.0) {
            direction = vector_normalize(direction);
        }
    }

    return direction;
}


- (void)renderer:(id<SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time
{

    if (_previousUpdateTime == 0.0) {
        _previousUpdateTime = time;
    }

    NSTimeInterval deltaTime = MIN(time - _previousUpdateTime, 1.0 / 60.0);
    CGFloat characterSpeed = deltaTime * 3 * 0.84;
    _previousUpdateTime = time;
    vector_float3 direction = self.characterDirection;
    if (direction.x != 0.0 && direction.z != 0.0) {
        // move character
        vector_float3 position = SCNVector3ToFloat3(panda.position);
         panda.position = SCNVector3FromFloat3(position + direction * characterSpeed);

        // update orientation
        [self setDirectionAngle:atan2(direction.x, direction.z)];
        self.gameView.allowsCameraControl = false;

    }else{
        self.gameView.allowsCameraControl = true;
        //[panda removeAnimationForKey:@"walk" fadeOutDuration:0.2];
    }

}

- (void) handleTap:(UIGestureRecognizer*)gestureRecognize
{
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    
    // check what nodes are tapped
    CGPoint p = [gestureRecognize locationInView:scnView];
    NSArray *hitResults = [scnView hitTest:p options:nil];
    
    // check that we clicked on at least one object
    if([hitResults count] > 0){
        // retrieved the first clicked object
        SCNHitTestResult *result = [hitResults objectAtIndex:0];
        
        // get its material
        SCNMaterial *material = result.node.geometry.firstMaterial;
        
        // highlight it
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0.5];
        
        // on completion - unhighlight
        [SCNTransaction setCompletionBlock:^{
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            
            material.emission.contents = [UIColor blackColor];
            
            [SCNTransaction commit];
        }];
        
        material.emission.contents = [UIColor redColor];
        
        [SCNTransaction commit];
    }
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (CAAnimation *)loadAnimationFromSceneNamed:(NSString *)sceneName {
    SCNScene *scene = [SCNScene sceneNamed:sceneName];

    // find top level animation
    __block CAAnimation *animation = nil;
    [scene.rootNode enumerateChildNodesUsingBlock:^(SCNNode *child, BOOL *stop) {
        if (child.animationKeys.count > 0) {
            animation = [child animationForKey:child.animationKeys[0]];
            *stop = YES;
        }
    }];

    return animation;
}

- (void)setupEnvironment:(SCNScene *)scene
{
    // add an ambient light
//    SCNNode *ambientLight = [SCNNode node];
//    ambientLight.light = [SCNLight light];
//    ambientLight.light.type = SCNLightTypeAmbient;
//    ambientLight.light.color = [UIColor colorWithWhite:0.3 alpha:1.0];
//    [[scene rootNode] addChildNode:ambientLight];
//
//    //add a key light to the scene
//    SCNNode *lightNode = [SCNNode node];
//    lightNode.light = [SCNLight light];
//    lightNode.light.type = SCNLightTypeSpot;
//    if ([self isHighEndDevice])
//        lightNode.light.castsShadow = YES;
//    lightNode.light.color = [UIColor colorWithWhite:0.8 alpha:1.0];
//    lightNode.position = SCNVector3Make(0, 80, 30);
//    lightNode.rotation = SCNVector4Make(1,0,0,-M_PI/2.8);
//    lightNode.light.spotInnerAngle = 0;
//    lightNode.light.spotOuterAngle = 50;
//    lightNode.light.shadowColor = [SKColor blackColor];
//    lightNode.light.zFar = 500;
//    lightNode.light.zNear = 50;
//    [[scene rootNode] addChildNode:lightNode];
//
//    //keep an ivar for later manipulation
//    _spotLightNode = lightNode;

    //floor
    SCNNode*floor = [SCNNode node];
    floor.geometry = [SCNFloor floor];
    floor.geometry.firstMaterial.diffuse.contents = @"wood.png";
    floor.geometry.firstMaterial.diffuse.contentsTransform = SCNMatrix4MakeScale(2, 2, 1); //scale the wood texture
    floor.geometry.firstMaterial.locksAmbientWithDiffuse = YES;
//    if ([self isHighEndDevice])
//        ((SCNFloor*)floor.geometry).reflectionFalloffEnd = 10;

    SCNPhysicsBody *staticBody = [SCNPhysicsBody staticBody];
    floor.physicsBody = staticBody;
    [[scene rootNode] addChildNode:floor];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

}

- (void)setDirectionAngle:(CGFloat)directionAngle {

    [panda runAction:[SCNAction rotateToX:0.0 y:directionAngle z:0.0 duration:0.1 shortestUnitArc:YES]];
}
@end
