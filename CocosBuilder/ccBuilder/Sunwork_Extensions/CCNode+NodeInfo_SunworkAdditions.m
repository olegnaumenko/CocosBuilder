//
//  CCNode+CCNode_NodeInfo_SunworkAdditions.m
//  CocosBuilder
//
//  Created by oleg on 4/30/13.
//
//

#import "CCNode+NodeInfo_SunworkAdditions.h"
#import "CCNode+NodeInfo.h"
#import "NodeInfo.h"
#import "PlugInNode.h"
#import "SequencerNodeProperty.h"
#import "SequencerKeyframe.h"
#import "SequencerKeyframeEasing.h"
#import "CocosBuilderAppDelegate.h"
#import "SequencerHandler.h"
#import "SequencerSequence.h"
#import "PositionPropertySetter.h"
#import "TexturePropertySetter.h"
#import "CCBWriterInternal.h"
#import "CCBReaderInternal.h"
#import "CCBDocument.h"
#import "CustomPropSetting.h"
#import "CocosScene.h"

@implementation CCNode (CCNode_NodeInfo_SunworkAdditions)
- (void) updateProperty:(NSString*) propName time:(float)time sequenceId:(int)seqId
{
    int type = [SequencerKeyframe keyframeTypeFromPropertyType:[self.plugIn propertyTypeForProperty:propName]];
    
    if (!type) return;
    
    id value = [self valueForProperty:propName atTime:time sequenceId:seqId];
    
    if (type == kCCBKeyframeTypeDegrees)
    {
        [self setValue:value forKey:propName];
    }
    else if (type == kCCBKeyframeTypePosition)
    {
        NSPoint pos = NSZeroPoint;
        pos.x = [[value objectAtIndex:0] floatValue];
        pos.y = [[value objectAtIndex:1] floatValue];
        
        [PositionPropertySetter setPosition: pos forNode:self prop:propName];
    }
    else if (type == kCCBKeyframeTypeScaleLock)
    {
        float x = [[value objectAtIndex:0] floatValue];
        float y = [[value objectAtIndex:1] floatValue];
        int type = [PositionPropertySetter scaledFloatTypeForNode:self prop:propName];
        
        [PositionPropertySetter setScaledX:x Y:y type:type forNode:self prop:propName];
    }
    else if (type == kCCBKeyframeTypeToggle)
    {
        if ([value boolValue]==YES && [propName isEqualToString:@"playing"])//on: account for CCSoundNode play/stop: don't start sound if timeline is not playing
        {
            if([[CocosBuilderAppDelegate appDelegate]playingBack]) [self setValue:value forKey:propName];
        }
        else
            [self setValue:value forKey:propName];
    }
    else if (type == kCCBKeyframeTypeColor3)
    {
        ccColor3B c = [CCBReaderInternal deserializeColor3:value];
        NSValue* colorValue = [NSValue value:&c withObjCType:@encode(ccColor3B)];
        [self setValue:colorValue forKey:propName];
        
    }
    else if (type == kCCBKeyframeTypeSpriteFrame)
    {
        NSString* sprite = [value objectAtIndex:0];
        NSString* sheet = [value objectAtIndex:1];
        
        [TexturePropertySetter setSpriteFrameForNode:self andProperty:propName withFile:sprite andSheetFile:sheet];
    }
    else if (type == kCCBKeyframeTypeByte)
    {
        [self setValue:value forKey:propName];
    }
    else if (type == kCCBKeyframeTypeFloatXY)
    {
        float x = [[value objectAtIndex:0] floatValue];
        float y = [[value objectAtIndex:1] floatValue];
        
        [self setValue:[NSNumber numberWithFloat:x] forKey:[propName stringByAppendingString:@"X"]];
        [self setValue:[NSNumber numberWithFloat:y] forKey:[propName stringByAppendingString:@"Y"]];
    }
}
@end
