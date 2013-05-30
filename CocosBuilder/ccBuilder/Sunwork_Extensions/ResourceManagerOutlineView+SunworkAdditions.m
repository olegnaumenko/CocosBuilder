//
//  ResourceManagerOutlineView+ResourceManagerOutlineView_SunworkAdditions.m
//  CocosBuilder
//
//  Created by oleg on 4/29/13.
//
//

#import "ResourceManagerOutlineView+SunworkAdditions.h"

#import "CocosBuilderAppDelegate.h"
#import "ResourceManager.h"

@implementation ResourceManagerOutlineView (ResourceManagerOutlineView_SunworkAdditions)
- (NSMenu*) menuForEvent:(NSEvent *)evt
{
    NSPoint pt = [self convertPoint:[evt locationInWindow] fromView:nil];
    NSInteger row=[self rowAtPoint:pt];
    
    RMResource* clickedResource = [self itemAtRow:row];
    
    NSMenu* menu = [CocosBuilderAppDelegate appDelegate].menuContextResManager;
    menu.autoenablesItems = NO;
    
    NSArray* items = [menu itemArray];
    for (NSMenuItem* item in items)
    {
        if (item.action == @selector(menuCreateSmartSpriteSheet:))
        {
            if (clickedResource.type == kCCBResTypeDirectory)
            {
                RMDirectory* dir = clickedResource.data;
                
                if (dir.isDynamicSpriteSheet)
                {
                    item.title = @"Remove Smart Sprite Sheet";
                }
                else
                {
                    item.title = @"Make Smart Sprite Sheet";
                }
                
                [item setEnabled:YES];
                item.tag = row;
            }
            else
            {
                [item setEnabled:NO];
            }
        }
        else if (item.action == @selector(menuEditSmartSpriteSheet:))
        {
            [item setEnabled:NO];
            if (clickedResource.type == kCCBResTypeDirectory)
            {
                RMDirectory* dir = clickedResource.data;
                if (dir.isDynamicSpriteSheet)
                {
                    [item setEnabled:YES];
                    item.tag = row;
                }
            }
        }
        else if (item.action == @selector(menuOpenExternal:))
        {
            if(![[CocosBuilderAppDelegate appDelegate]projectSettings])
            {
                [item setEnabled:NO];
            }
            else if (clickedResource.type != kCCBResTypeJS)
            {
                [item setEnabled:YES];
                item.title = @"Show in Finder";
                item.action = @selector(menuShowResourceInFinder:);
            }
            else
            {
                item.title = @"Open With External Editor";
                [item setEnabled:YES];
            }
            item.tag = row;
            NSLog(@"ROW: %ld", (long)row);
        }
        else if (item.action == @selector(menuCreateNewSceneFromImage:))
        {
            if (clickedResource.type == kCCBResTypeImage)
            {
                [item setEnabled:YES];
                item.title = @"To Scenes...";
                item.tag = (NSInteger)self;
            }
            else [item setEnabled:NO];
        }
    }
    
    // TODO: Update menu
    
    return menu;
}
@end
