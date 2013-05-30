//
//  CCBGlobalsLastProject.m
//  CocosBuilder
//
//  Created by oleg on 4/29/13.
//
//

#import "CCBGlobalsSunwork.h"
#import "CocosBuilderAppDelegate.h"


@implementation CCBGlobalsSunwork
@synthesize lastOpenProject;

+ (CCBGlobalsSunwork*) sglobals
{
    static CCBGlobalsSunwork* g = NULL;
    if (g == NULL)
    {
        g = [[CCBGlobalsSunwork alloc] init];
    }
    return g;
}

- (id)init
{
    self = [super init];
    if (!self) return NULL;
    
    self.lastOpenProject = (NSString*)[[NSUserDefaults standardUserDefaults] valueForKey:@"lastOpenProject"];
    //[self writeSettings];
    
    return self;
}

- (void) writeSettings
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSString stringWithString:self.lastOpenProject] forKey:@"lastOpenProject"];
}




@end