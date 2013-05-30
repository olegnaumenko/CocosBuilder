//
//  CCBXCocos2diPhone+SunworkAdditions.m
//  CocosBuilder
//
//  Created by oleg on 5/27/13.
//
//

#import "CCBXCocos2diPhoneWriter+SunworkAdditions.h"

@implementation CCBXCocos2diPhoneWriter (CCBXCocos2diPhoneWriter_SunworkAdditions)

- (void) setupPropTypes
{
    propTypes = [[NSMutableArray alloc] init];
    
    [propTypes addObject:@"Position"];
    [propTypes addObject:@"Size"];
    [propTypes addObject:@"Point"];
    [propTypes addObject:@"PointLock"];
    [propTypes addObject:@"ScaleLock"];
    [propTypes addObject:@"Degrees"];
    [propTypes addObject:@"Integer"];
    [propTypes addObject:@"Float"];
    [propTypes addObject:@"FloatVar"];
    [propTypes addObject:@"Check"];
    [propTypes addObject:@"SpriteFrame"];
    [propTypes addObject:@"Texture"];
    [propTypes addObject:@"Byte"];
    [propTypes addObject:@"Color3"];
    [propTypes addObject:@"Color4FVar"];
    [propTypes addObject:@"Flip"];
    [propTypes addObject:@"Blendmode"];
    [propTypes addObject:@"FntFile"];
    [propTypes addObject:@"Text"];
    [propTypes addObject:@"FontTTF"];
    [propTypes addObject:@"IntegerLabeled"];
    [propTypes addObject:@"Block"];
    [propTypes addObject:@"Animation"];
    [propTypes addObject:@"CCBFile"];
    [propTypes addObject:@"String"];
    [propTypes addObject:@"BlockCCControl"];
    [propTypes addObject:@"FloatScale"];
    [propTypes addObject:@"FloatXY"];
    
    [propTypes addObject:@"AudioFile"];
}
@end
