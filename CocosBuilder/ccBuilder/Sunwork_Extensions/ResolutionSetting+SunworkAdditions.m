//
//  ResolutionSetting+ResolutionSettings_SunworkAdditions.m
//  CocosBuilder
//
//  Created by oleg on 4/29/13.
//
//

#import "ResolutionSetting+SunworkAdditions.h"

@implementation ResolutionSetting (ResolutionSettings_SunworkAdditions)

+ (ResolutionSetting*) setting1280x750
{
    ResolutionSetting* setting = [self settingIPad];
    
    setting.name = @"AB 1280 x 750";
    setting.width = 1280;
    setting.height = 750;
    
    return setting;
}

+ (ResolutionSetting*) settingFromSize:(CGSize)size
{
    ResolutionSetting* setting = [self settingIPad];
    
    setting.name = @"AB From Img Size";
    setting.width = size.width;
    setting.height = size.height;
    
    return setting;
}

@end
