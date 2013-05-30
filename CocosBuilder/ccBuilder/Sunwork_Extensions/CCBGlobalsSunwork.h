//
//  CCBGlobalsLastProject.h
//  CocosBuilder
//
//  Created by oleg on 4/29/13.
//
//

#import <Foundation/Foundation.h>

@interface CCBGlobalsSunwork : NSObject
{
    NSString * lastOpenProject;
}

// Settings

@property (nonatomic, retain) NSString * lastOpenProject;

+ (CCBGlobalsSunwork*) sglobals;

- (void) writeSettings;

@end
