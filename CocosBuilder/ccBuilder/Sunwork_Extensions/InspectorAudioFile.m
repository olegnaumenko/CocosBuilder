//
//  InspectorAudioFile.m
//  CocosBuilder
//
//  Created by oleg on 1/17/13.
//
//

#import "InspectorAudioFile.h"
#import "CCBGlobals.h"
//#import "TexturePropertySetter.h"
#import "ResourceManager.h"
#import "ResourceManagerUtil.h"
#import "CocosBuilderAppDelegate.h"
#import "CCNode+NodeInfo.h"

#import "CCSoundNode.h"

@implementation InspectorAudioFile
//@synthesize duration;

- (void) willBeAdded
{
    // Setup menu
    NSString* sf = [selection extraPropForKey:propertyName];
    
    [ResourceManagerUtil populateResourcePopup:popup resType:kCCBResTypeAudio allowSpriteFrames:NO selectedFile:sf selectedSheet:NULL target:self];
    //[self updateLabel];
}

//- (void) updateLabel
//{
//    NSString * str = [(CCSoundNode*)selection soundFile];
//    if(str) [fileLabel setStringValue: str];
//}

- (void) selectedResource:(id)sender
{
    [[CocosBuilderAppDelegate appDelegate] saveUndoStateWillChangeProperty:propertyName];
    
    id item = [sender representedObject];
    
    // Fetch info about the sprite name
    NSString* sf = NULL;
    
    if ([item isKindOfClass:[RMResource class]])
    {
        RMResource* res = item;
        
        if (res.type == kCCBResTypeAudio)
        {
            sf = [ResourceManagerUtil relativePathFromAbsolutePath:res.filePath];
            [ResourceManagerUtil setTitle:sf forPopup:popup];
        }
    }
    
    // Set the properties and sprite frames
    if (sf)
    {
        [selection setExtraProp:sf forKey:propertyName];
        NSString * str = [[ResourceManager sharedManager] toAbsolutePath:sf];
        [self setPropertyForSelection:str];
        //[self updateLabel];
    }
    
    [self updateAffectedProperties];
}
@end
