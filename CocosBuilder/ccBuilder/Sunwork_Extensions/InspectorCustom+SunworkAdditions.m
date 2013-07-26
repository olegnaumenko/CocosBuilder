//
//  InspectorCustom+SunworkAdditions.m
//  CocosBuilder
//
//  Created by oleg on 7/26/13.
//
//

#import "InspectorCustom+SunworkAdditions.h"

#import "CustomPropSetting.h"

@implementation InspectorCustom (SunworkAdditions)

- (void) awakeFromNib
{
    
    CustomPropSetting *cp = nil;//[selection customPropertyNamed:propertyName];
    NSMutableArray * cprops = [selection customProperties];
    
    for (CustomPropSetting* setting in cprops)
    {
        if ([setting.name isEqualToString:propertyName])
        {
            cp = setting;
        }
    }
    int type = [cp type];
    if(type==3)
    {
        //does not work probably since it's later altered by xib property setting:
        //[[textField cell]setLineBreakMode:NSLineBreakByWordWrapping];
        //[self.view setAutoresizingMask:[self.view autoresizingMask] | (NSViewHeightSizable & !NSViewMaxYMargin)];
        CGRect frame = [[self view]frame];
        frame.size.height *=3;
        [self.view setFrame:frame];
    }
}
@end
