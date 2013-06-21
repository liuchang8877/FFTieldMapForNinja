//
//  HelloWorldLayer.h
//  FFTieldMapForNinja
//
//  Created by liu on 6/19/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "HudLayer.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
    CCTMXTiledMap *_tileMap;
    CCTMXLayer *_background;
    CCSprite   *_player;
}

@property (nonatomic, retain) CCTMXTiledMap *tileMap;
@property (strong) CCTMXLayer *meta;
@property (strong) CCTMXLayer *foreground;
@property (nonatomic, retain) CCTMXLayer *background;
@property (nonatomic, retain) CCSprite *player;

@property (strong) HudLayer *hud;
@property (assign) int numCollected;


// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end

