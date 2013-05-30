//
//  ResolutionSetting+ResolutionSettings_SunworkAdditions.h
//  CocosBuilder
//
//  Created by oleg on 4/29/13.
//
//

#import "ResolutionSetting.h"

@interface ResolutionSetting (ResolutionSettings_SunworkAdditions)


+ (ResolutionSetting*) setting1280x750;
+ (ResolutionSetting*) settingFromSize:(CGSize)size;

@end
