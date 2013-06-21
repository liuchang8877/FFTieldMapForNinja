//
//  HelloWorldLayer.m
//  FFTieldMapForNinja
//
//  Created by liu on 6/19/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "SimpleAudioEngine.h"

// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#pragma mark - HelloWorldLayer

// HelloWorldLayer implementation
@implementation HelloWorldLayer
@synthesize tileMap = _tileMap;
@synthesize background = _background;
@synthesize player = _player;
// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
    //add the hud
    HudLayer *hud = [HudLayer node];
    [scene addChild:hud];
    layer.hud = hud;
    
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"pickup.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"hit.caf"];
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"move.caf"];
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"TileMap.caf"];
    
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		
        //set the map
        self.tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"myMap.tmx"];
        self.background = [_tileMap layerNamed:@"Background"];
        self.meta = [_tileMap layerNamed:@"Meta"];
        self.foreground = [_tileMap layerNamed:@"Foreground"];
        _meta.visible = NO;
        
        [self addChild:_tileMap z:-1];
        
        //set the player
        CCTMXObjectGroup  *objects = [_tileMap objectGroupNamed:@"Objects"];
        NSAssert(objects != nil, @"'Objects' object group not found");
        
        NSMutableDictionary *spawnPoint = [objects objectNamed:@"SpawnPoint"];
        NSAssert(spawnPoint != nil, @"SpawnPoint object not found");
        
        int x = [[spawnPoint valueForKey:@"x"]intValue];
        int y = [[spawnPoint valueForKey:@"y"]intValue];
        
        self.player = [CCSprite spriteWithFile:@"Player.png"];
        _player.position = ccp(x, y);
        [self addChild:_player];
        
        [self setViewpointCenters: _player.position];
        
        //can touch
        self.isTouchEnabled = YES;
	}
	return self;
}

- (CGPoint)tileCoordForPosition:(CGPoint)position {
    int x = position.x / _tileMap.tileSize.width;
    int y = ((_tileMap.mapSize.height * _tileMap.tileSize.height) - position.y) / _tileMap.tileSize.height;
    return ccp(x, y);
}

-(void) registerWithTouchDispatcher
{
//	CCTouchDispatcher* dispatch = [CCTouchDispatcher sharedDispatcher];
//    [dispatch addTargetedDelegate:self priority:INT32_MIN+1 swallowsTouches:YES];
    
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self
                                                     priority:0 swallowsTouches:YES];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
	return YES;
}

-(void)setPlayerPosition:(CGPoint)position {
    
    // Right before setting player position
    [[SimpleAudioEngine sharedEngine] playEffect:@"move.caf"];
    
	CGPoint tileCoord = [self tileCoordForPosition:position];
    int tileGid = [_meta tileGIDAt:tileCoord];
    if (tileGid) {
        NSDictionary *properties = [_tileMap propertiesForGID:tileGid];
        if (properties) {
            NSString *collision = properties[@"Collidable"];
            if (collision && [collision isEqualToString:@"True"]) {
                // In case for collidable tile
                [[SimpleAudioEngine sharedEngine] playEffect:@"hit.caf"];
                
                return;
            }
            
            NSString *collectible = properties[@"Collectable"];
            if (collectible && [collectible isEqualToString:@"True"]) {
                // In case of collectable tile
                [[SimpleAudioEngine sharedEngine] playEffect:@"pickup.caf"];
                
                //change the number
                self.numCollected++;
                [_hud numCollectedChanged:_numCollected];
                
                [_meta removeTileAt:tileCoord];
                [_foreground removeTileAt:tileCoord];
            }
        }
    }
    
    _player.position = position;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation  = [touch locationInView:[touch view]];
    touchLocation = [[CCDirector sharedDirector]convertToGL:touchLocation];
    touchLocation = [self convertToNodeSpace:touchLocation];
    
    CGPoint playerPos = _player.position;
    CGPoint diff  = ccpSub(touchLocation, playerPos);
    
    if (abs(diff.x) > abs(diff.y)) {
        
        if (diff.x > 0) {
        
            playerPos.x += _tileMap.tileSize.width;
        } else {
        
            playerPos.x -= _tileMap.tileSize.width;
        }
    } else {
    
        if (diff.y > 0) {
            
            playerPos.y += _tileMap.tileSize.height;
        } else {
            
            playerPos.y -= _tileMap.tileSize.height;
        }
    }
    
    //player is in the map 
    if (playerPos.x <= (_tileMap.mapSize.width * _tileMap.tileSize.width) &&
        playerPos.y <= (_tileMap.mapSize.height * _tileMap.tileSize.height) &&
        playerPos.y >= 0 && playerPos.x >= 0 ) {
        
        [self setPlayerPosition:playerPos];
    }

    [self setViewpointCenters:_player.position];
}

//set it to the center
- (void)setViewpointCenters:(CGPoint) position {
    
    CGSize winSize = [[CCDirector sharedDirector]winSize];
    
    int x = MAX(position.x, winSize.width/2);
    int y = MAX(position.y, winSize.height/2);
    
    x  = MIN(x,_tileMap.mapSize.width * _tileMap.tileSize.width - winSize.width /2);
    y  = MIN(y,_tileMap.mapSize.height * _tileMap.tileSize.height - winSize.height /2);
    
    CGPoint actualPosition = ccp(x, y);
    
    CGPoint centerOfView = ccp(winSize.width/2, winSize.height/2);
    
    CGPoint viewPoint = ccpSub(centerOfView, actualPosition);
    
    self.position  = viewPoint;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
    self.tileMap = nil;
    self.background = nil;
    self.player = nil;

	// don't forget to call "super dealloc"
	[super dealloc];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end
