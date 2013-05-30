//
//  CCBReaderInternal+CCBReaderInternal_SunworkAdditions.m
//  CocosBuilder
//
//  Created by oleg on 4/30/13.
//
//

#import "CCBReaderInternal+SunworkAdditions.h"

#import "CCBReaderInternalV1.h"
#import "PlugInManager.h"
#import "PlugInNode.h"
#import "NodeInfo.h"
#import "CCBWriterInternal.h"
#import "TexturePropertySetter.h"
#import "AnimationPropertySetter.h"
#import "CCBGlobals.h"
#import "CocosBuilderAppDelegate.h"
#import "ResourceManager.h"
#import "NodeGraphPropertySetter.h"
#import "PositionPropertySetter.h"
#import "CCNode+NodeInfo.h"

@implementation CCBReaderInternal (CCBReaderInternal_SunworkAdditions)

+ (NSPoint) deserializePoint:(id) val
{
    float x = [[val objectAtIndex:0] floatValue];
    float y = [[val objectAtIndex:1] floatValue];
    return NSMakePoint(x,y);
}

+ (NSSize) deserializeSize:(id) val
{
    float w = [[val objectAtIndex:0] floatValue];
    float h = [[val objectAtIndex:1] floatValue];
    return NSMakeSize(w, h);
}

+ (float) deserializeFloat:(id) val
{
    return [val floatValue];
}

+ (int) deserializeInt:(id) val
{
    return [val intValue];
}

+ (BOOL) deserializeBool:(id) val
{
    return [val boolValue];
}

+ (ccColor3B) deserializeColor3:(id) val
{
    ccColor3B c;
    c.r = [[val objectAtIndex:0] intValue];
    c.g = [[val objectAtIndex:1] intValue];
    c.b = [[val objectAtIndex:2] intValue];
    return c;
}

+ (ccColor4B) deserializeColor4:(id) val
{
    ccColor4B c;
    c.r = [[val objectAtIndex:0] intValue];
    c.g = [[val objectAtIndex:1] intValue];
    c.b = [[val objectAtIndex:2] intValue];
    c.a = [[val objectAtIndex:3] intValue];
    return c;
}

+ (ccColor4F) deserializeColor4F:(id) val
{
    ccColor4F c;
    c.r = [[val objectAtIndex:0] floatValue];
    c.g = [[val objectAtIndex:1] floatValue];
    c.b = [[val objectAtIndex:2] floatValue];
    c.a = [[val objectAtIndex:3] floatValue];
    return c;
}

+ (ccBlendFunc) deserializeBlendFunc:(id) val
{
    ccBlendFunc bf;
    bf.src = [[val objectAtIndex:0] intValue];
    bf.dst = [[val objectAtIndex:1] intValue];
    return bf;
}

+ (void) setProp:(NSString*)name ofType:(NSString*)type toValue:(id)serializedValue forNode:(CCNode*)node parentSize:(CGSize)parentSize
{
    // Fetch info and extra properties
    NodeInfo* nodeInfo = node.userObject;
    NSMutableDictionary* extraProps = nodeInfo.extraProps;
    
    if ([type isEqualToString:@"Position"])
    {
        float x = [[serializedValue objectAtIndex:0] floatValue];
        float y = [[serializedValue objectAtIndex:1] floatValue];
        int posType = 0;
        if ([(NSArray*)serializedValue count] == 3) posType = [[serializedValue objectAtIndex:2] intValue];
        [PositionPropertySetter setPosition:NSMakePoint(x, y) type:posType forNode:node prop:name parentSize:parentSize];
    }
    else if ([type isEqualToString:@"Point"]
             || [type isEqualToString:@"PointLock"])
    {
        NSPoint pt = [CCBReaderInternal deserializePoint: serializedValue];
		
        [node setValue:[NSValue valueWithPoint:pt] forKey:name];
    }
    else if ([type isEqualToString:@"Size"])
    {
        float w = [[serializedValue objectAtIndex:0] floatValue];
        float h = [[serializedValue objectAtIndex:1] floatValue];
        NSSize size =  NSMakeSize(w, h);
        int sizeType = 0;
        if ([(NSArray*)serializedValue count] == 3) sizeType = [[serializedValue objectAtIndex:2] intValue];
        [PositionPropertySetter setSize:size type:sizeType forNode:node prop:name parentSize:parentSize];
    }
    else if ([type isEqualToString:@"Scale"]
             || [type isEqualToString:@"ScaleLock"])
    {
        float x = [[serializedValue objectAtIndex:0] floatValue];
        float y = [[serializedValue objectAtIndex:1] floatValue];
        int scaleType = 0;
        if ([(NSArray*)serializedValue count] >= 3)
        {
            [extraProps setValue:[serializedValue objectAtIndex:2] forKey:[NSString stringWithFormat:@"%@Lock",name]];
            if ([(NSArray*)serializedValue count] == 4)
            {
                scaleType = [[serializedValue objectAtIndex:3] intValue];
            }
        }
        [PositionPropertySetter setScaledX:x Y:y type:scaleType forNode:node prop:name];
    }
    else if ([type isEqualToString:@"FloatXY"])
    {
        float x = [[serializedValue objectAtIndex:0] floatValue];
        float y = [[serializedValue objectAtIndex:1] floatValue];
        [node setValue:[NSNumber numberWithFloat:x] forKey:[name stringByAppendingString:@"X"]];
        [node setValue:[NSNumber numberWithFloat:y] forKey:[name stringByAppendingString:@"Y"]];
    }
    else if ([type isEqualToString:@"Float"]
             || [type isEqualToString:@"Degrees"])
    {
        float f = [CCBReaderInternal deserializeFloat: serializedValue];
        [node setValue:[NSNumber numberWithFloat:f] forKey:name];
    }
    else if ([type isEqualToString:@"FloatScale"])
    {
        float f = 0;
        int type = 0;
        if ([serializedValue isKindOfClass:[NSNumber class]])
        {
            // Support for old files
            f = [serializedValue floatValue];
        }
        else
        {
            f = [[serializedValue objectAtIndex:0] floatValue];
            type = [[serializedValue objectAtIndex:1] intValue];
        }
        [PositionPropertySetter setFloatScale:f type:type forNode:node prop:name];
    }
    else if ([type isEqualToString:@"FloatVar"])
    {
        [node setValue:[serializedValue objectAtIndex:0] forKey:name];
        [node setValue:[serializedValue objectAtIndex:1] forKey:[NSString stringWithFormat:@"%@Var",name]];
    }
    else if ([type isEqualToString:@"Integer"]
             || [type isEqualToString:@"IntegerLabeled"]
             || [type isEqualToString:@"Byte"])
    {
        int d = [CCBReaderInternal deserializeInt: serializedValue];
        [node setValue:[NSNumber numberWithInt:d] forKey:name];
    }
    else if ([type isEqualToString:@"Check"])
    {
        BOOL check = [CCBReaderInternal deserializeBool:serializedValue];
        if ([name isEqualToString:@"playing"])//on: account for CCSoundNode play/stop: don't start sound if timeline is not playing
        {
            check = (check && [[CocosBuilderAppDelegate appDelegate]playingBack]);
        }
        [node setValue:[NSNumber numberWithBool:check] forKey:name];
    }
    else if ([type isEqualToString:@"Flip"])
    {
        [node setValue:[serializedValue objectAtIndex:0] forKey:[NSString stringWithFormat:@"%@X",name]];
        [node setValue:[serializedValue objectAtIndex:1] forKey:[NSString stringWithFormat:@"%@Y",name]];
    }
    else if ([type isEqualToString:@"SpriteFrame"])
    {
        NSString* spriteSheetFile = [serializedValue objectAtIndex:0];
        NSString* spriteFile = [serializedValue objectAtIndex:1];
        if (!spriteSheetFile || [spriteSheetFile isEqualToString:@""])
        {
            spriteSheetFile = kCCBUseRegularFile;
        }
        
        [extraProps setObject:spriteSheetFile forKey:[NSString stringWithFormat:@"%@Sheet",name]];
        [extraProps setObject:spriteFile forKey:name];
        [TexturePropertySetter setSpriteFrameForNode:node andProperty:name withFile:spriteFile andSheetFile:spriteSheetFile];
    }
    else if ([type isEqualToString:@"Animation"])
    {
        NSString* animationFile = [serializedValue objectAtIndex:0];
        NSString* animationName = [serializedValue objectAtIndex:1];
        if (!animationFile) animationFile = @"";
        if (!animationName) animationName = @"";
        
        [extraProps setObject:animationFile forKey:[NSString stringWithFormat:@"%@Animation",name]];
        [extraProps setObject:animationName forKey:name];
        [AnimationPropertySetter setAnimationForNode:node andProperty:name withName:animationName andFile:animationFile];
    }
    else if ([type isEqualToString:@"Texture"])
    {
        NSString* spriteFile = serializedValue;
        if (!spriteFile) spriteFile = @"";
        [TexturePropertySetter setTextureForNode:node andProperty:name withFile:spriteFile];
        [extraProps setObject:spriteFile forKey:name];
    }
    else if ([type isEqualToString:@"Color3"])
    {
        ccColor3B c = [CCBReaderInternal deserializeColor3:serializedValue];
        NSValue* colorValue = [NSValue value:&c withObjCType:@encode(ccColor3B)];
        [node setValue:colorValue forKey:name];
    }
    else if ([type isEqualToString:@"Color4FVar"])
    {
        ccColor4F c = [CCBReaderInternal deserializeColor4F:[serializedValue objectAtIndex:0]];
        ccColor4F cVar = [CCBReaderInternal deserializeColor4F:[serializedValue objectAtIndex:1]];
        NSValue* cValue = [NSValue value:&c withObjCType:@encode(ccColor4F)];
        NSValue* cVarValue = [NSValue value:&cVar withObjCType:@encode(ccColor4F)];
        [node setValue:cValue forKey:name];
        [node setValue:cVarValue forKey:[NSString stringWithFormat:@"%@Var",name]];
    }
    else if ([type isEqualToString:@"Blendmode"])
    {
        ccBlendFunc bf = [CCBReaderInternal deserializeBlendFunc:serializedValue];
        NSValue* blendValue = [NSValue value:&bf withObjCType:@encode(ccBlendFunc)];
        [node setValue:blendValue forKey:name];
    }
    else if ([type isEqualToString:@"FntFile"])
    {
        NSString* fntFile = serializedValue;
        if (!fntFile) fntFile = @"";
        [TexturePropertySetter setFontForNode:node andProperty:name withFile:fntFile];
        [extraProps setObject:fntFile forKey:name];
    }
    else if ([type isEqualToString:@"Text"]
             || [type isEqualToString:@"String"])
    {
        NSString* str = serializedValue;
        if (!str) str = @"";
        [node setValue:str forKey:name];
    }
    else if ([type isEqualToString:@"FontTTF"])
    {
        NSString* str = serializedValue;
        if (!str) str = @"";
        [TexturePropertySetter setTtfForNode:node andProperty:name withFont:str];
    }
    else if ([type isEqualToString:@"Block"])
    {
        NSString* selector = [serializedValue objectAtIndex:0];
        NSNumber* target = [serializedValue objectAtIndex:1];
        if (!selector) selector = @"";
        if (!target) target = [NSNumber numberWithInt:0];
        [extraProps setObject: selector forKey:name];
        [extraProps setObject:target forKey:[NSString stringWithFormat:@"%@Target",name]];
    }
    else if ([type isEqualToString:@"BlockCCControl"])
    {
        NSString* selector = [serializedValue objectAtIndex:0];
        NSNumber* target = [serializedValue objectAtIndex:1];
        NSNumber* ctrlEvts = [serializedValue objectAtIndex:2];
        if (!selector) selector = @"";
        if (!target) target = [NSNumber numberWithInt:0];
        if (!ctrlEvts) ctrlEvts = [NSNumber numberWithInt:0];
        [extraProps setObject: selector forKey:name];
        [extraProps setObject:target forKey:[NSString stringWithFormat:@"%@Target",name]];
        [extraProps setObject:ctrlEvts forKey:[NSString stringWithFormat:@"%@CtrlEvts",name]];
    }
    else if ([type isEqualToString:@"CCBFile"])
    {
        NSString* ccbFile = serializedValue;
        if (!ccbFile) ccbFile = @"";
        [NodeGraphPropertySetter setNodeGraphForNode:node andProperty:name withFile:ccbFile parentSize:parentSize];
        [extraProps setObject:ccbFile forKey:name];
    }
    else if ([type isEqualToString:@"AudioFile"])
    {
        NSString* audioFile = serializedValue;
        if (!audioFile) audioFile = @"";
        [node setValue:[[ResourceManager sharedManager] toAbsolutePath:audioFile] forKey:name];
        [extraProps setObject:audioFile forKey:name];
    }
    else
    {
        NSLog(@"WARNING Unrecognized property type: %@", type);
    }
}

@end
