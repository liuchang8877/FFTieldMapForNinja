//
//  HudLayer.m
//  FFTieldMapForNinja
//
//  Created by liu on 6/21/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "HudLayer.h"


@implementation HudLayer{

    CCLabelTTF *_label;
}

- (id)init {
    
    self = [super init];
    if (self) {
    
        CGSize winSize = [[CCDirector sharedDirector]winSize];
        _label = [CCLabelTTF labelWithString:@"0" fontName:@"Verdana-Bold" fontSize:18.0];
        _label.color = ccc3(0, 0, 0);
        int margin = 10;
        _label.position = ccp(winSize.width - (_label.contentSize.width/2) - margin, _label.contentSize.height/2 +margin);
        [self addChild:_label];
    
    }

    return self;
}

- (void)numCollectedChanged:(int)numCollected {

    _label.string = [NSString stringWithFormat:@"%d",numCollected];

}
@end
