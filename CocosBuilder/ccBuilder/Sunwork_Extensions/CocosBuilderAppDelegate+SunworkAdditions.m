//
//  CocosBuilderAppDelegate+CocosBuilderAppDelegate_SunworkAdditions.m
//  CocosBuilder
//
//  Created by oleg on 4/29/13.
//
//

#import "CocosBuilderAppDelegate+SunworkAdditions.h"
#import "ResolutionSetting+SunworkAdditions.h"
#import "ResourceManager.h"
#import "ResourceManagerUtil.h"
//#import "PlugInManager.h"
//#import "ResolutionSetting.h"
//#import "CocosScene.h"
//#import "NodeInfo.h"
//#import "CCBReaderInternal.h"
//#import "PositionPropertySetter.h"
#import "CocosScene.h"
#import "CCBGLView.h"
#import "NSFlippedView.h"
#import "CCBGlobals.h"
#import "cocos2d.h"
#import "CCBWriterInternal.h"
#import "CCBReaderInternal.h"
#import "CCBReaderInternalV1.h"
#import "CCBDocument.h"
#import "NewDocWindowController.h"
#import "CCBSpriteSheetParser.h"
#import "CCBUtil.h"
#import "StageSizeWindow.h"
#import "ResolutionSettingsWindow.h"
#import "PlugInManager.h"
#import "InspectorPosition.h"
#import "NodeInfo.h"
#import "PlugInNode.h"
#import "PlugInExport.h"
#import "TexturePropertySetter.h"
#import "PositionPropertySetter.h"
#import "PublishTypeAccessoryView.h"
#import "ResourceManager.h"
#import "ResourceManagerPanel.h"
#import "GuidesLayer.h"
#import "RulersLayer.h"
#import "NSString+RelativePath.h"
#import "CCBTransparentWindow.h"
#import "CCBTransparentView.h"
#import "NotesLayer.h"
#import "ResolutionSetting.h"
#import "ProjectSettingsWindow.h"
#import "PublishSettingsWindow.h"
#import "ProjectSettings.h"
#import "ResourceManagerOutlineHandler.h"
#import "SavePanelLimiter.h"
#import "CCBPublisher.h"
#import "CCBWarnings.h"
#import "WarningsWindow.h"
#import "TaskStatusWindow.h"
#import "SequencerHandler.h"
#import "MainWindow.h"
#import "CCNode+NodeInfo.h"
#import "SequencerNodeProperty.h"
#import "SequencerSequence.h"
#import "SequencerSettingsWindow.h"
#import "SequencerDurationWindow.h"
#import "SequencerKeyframe.h"
#import "SequencerKeyframeEasing.h"
#import "SequencerKeyframeEasingWindow.h"
#import "JavaScriptDocument.h"
#import "PlayerConnection.h"
#import "PlayerConsoleWindow.h"
#import "SequencerUtil.h"
#import "SequencerStretchWindow.h"
#import "SequencerSoundChannel.h"
#import "SequencerCallbackChannel.h"
#import "CustomPropSettingsWindow.h"
#import "CustomPropSetting.h"
#import "MainToolbarDelegate.h"
#import "InspectorSeparator.h"
#import "HelpWindow.h"
#import "APIDocsWindow.h"
#import "NodeGraphPropertySetter.h"
#import "CCBSplitHorizontalView.h"
#import "SpriteSheetSettingsWindow.h"
#import "CDAudioManager.h"

#import <ExceptionHandling/NSExceptionHandler.h>

#import "CCBGlobalsSunwork.h"

@implementation CocosBuilderAppDelegate (CocosBuilderAppDelegate_SunworkAdditions)

- (IBAction)menuShowResourceInFinder :(id)sender
{
    NSUInteger selectedRow = [sender tag];
    {
        RMResource* res = [outlineProject itemAtRow:selectedRow];
        NSString * filePath = res.filePath;
        if(!filePath && projectSettings) {
            filePath = projectSettings.projectPath;
        }
        if(filePath)
        {
            NSLog(@"OPEN IN FINDER: %@", filePath);
            NSURL * fileUrl = [NSURL fileURLWithPath:filePath];
            NSArray *fileURLs = [NSArray arrayWithObject:fileUrl];
            [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:fileURLs];
        }
    }
    
    //in ResourceManagerOutlineView+ResourceManagerOutlineView_SunworkAdditions menuForEvent we assign this selector occasionally, so need to assign back what was initially
    [sender setAction: @selector(menuOpenExternal:)];
}

#pragma mart New AB Scene From Image

- (IBAction)menuCreateNewSceneFromImage:(id)sender
{
    NSOutlineView * oline = (NSOutlineView*)[sender tag];
    
    NSIndexSet * set = [oline selectedRowIndexes];
    
    NSUInteger index = [set firstIndex];
    while (index != NSNotFound)
    {
        RMResource* res = [outlineProject itemAtRow:index];
        if(res.type != kCCBResTypeImage) continue;
        NSString * filePath = res.filePath;
        NSLog(@"%@", filePath);
        [self newABSceneWithBackgroundImage:[ResourceManagerUtil relativePathFromAbsolutePath:filePath]];
        
        index = [set indexGreaterThanIndex: index];
    }
}

- (void) newFile:(NSString*) fileName type:(NSString*)type resolutions: (NSMutableArray*) resolutions;
{
    BOOL origin = NO;
    ResolutionSetting* resolution = [resolutions objectAtIndex:0];
    CGSize stageSize = CGSizeMake(resolution.width, resolution.height);
    
    // Close old doc if neccessary
    CCBDocument* oldDoc = [self findDocumentFromFile:fileName];
    if (oldDoc)
    {
        NSTabViewItem* item = [self tabViewItemFromDoc:oldDoc];
        if (item) [tabView removeTabViewItem:item];
    }
    
    [self prepareForDocumentSwitch];
    
    [[CocosScene cocosScene].notesLayer removeAllNotes];
    
    self.selectedNodes = NULL;
    [[CocosScene cocosScene] setStageSize:stageSize centeredOrigin:origin];
    
    // Create new node
    [[CocosScene cocosScene] replaceRootNodeWith:[[PlugInManager sharedManager] createDefaultNodeOfType:type]];
    
    // Set default contentSize to 100% x 100%
    if (([type isEqualToString:@"CCNode"] || [type isEqualToString:@"CCLayer"])
        && stageSize.width != 0 && stageSize.height != 0)
    {
        [PositionPropertySetter setSize:NSMakeSize(100, 100) type:kCCBSizeTypePercent forNode:[CocosScene cocosScene].rootNode prop:@"contentSize"];
    }
    
    [outlineHierarchy reloadData];
    [sequenceHandler updateOutlineViewSelection];
    [self updateInspectorFromSelection];
    
    self.currentDocument = [[[CCBDocument alloc] init] autorelease];
    self.currentDocument.resolutions = resolutions;
    self.currentDocument.currentResolution = 0;
    [self updateResolutionMenu];
    
    [self saveFile:fileName];
    
    [self addDocument:currentDocument];
    
    // Setup a default timeline
    NSMutableArray* sequences = [NSMutableArray array];
    
    SequencerSequence* seq = [[[SequencerSequence alloc] init] autorelease];
    seq.name = @"Default Timeline";
    seq.sequenceId = 0;
    seq.autoPlay = YES;
    [sequences addObject:seq];
    
    currentDocument.sequences = sequences;
    sequenceHandler.currentSequence = seq;
    
    
    self.hasOpenedDocument = YES;
    
    [self updateStateOriginCenteredMenu];
    
    [[CocosScene cocosScene] setStageZoom:1];
    [[CocosScene cocosScene] setScrollOffset:ccp(0,0)];
    
    [self checkForTooManyDirectoriesInCurrentDoc];
}

- (void) newABSceneWithBackgroundImage:(NSString *)imageFile
{
    NSArray * arr = [imageFile pathComponents];
    
    NSString * fname = [arr objectAtIndex:[arr count]-1];
    fname = [NSString stringWithFormat:@"scene_%@.ccb", [fname stringByDeletingPathExtension]];
    
    NSString * path = [[projectSettings projectPath]stringByDeletingLastPathComponent];
    path = [path stringByAppendingPathComponent:[[[projectSettings resourcePaths]objectAtIndex:0]objectForKey:@"path"]];
    path = [path stringByAppendingPathComponent:fname];
    
    [self newFile:path type:@"CCLayer" resolutions:[NSMutableArray arrayWithObject:[ResolutionSetting setting1280x750]]];
    
    CCNode * newNode = [[PlugInManager sharedManager] createDefaultNodeOfType:@"CCSprite"];
    
    NodeInfo* info = [[CocosScene cocosScene]rootNode].userObject;
    PlugInNode* plugIn = info.plugIn;
    NSString* prop = plugIn.dropTargetSpriteFrameProperty;
    [CCBReaderInternal setProp:prop ofType:@"SpriteFrame" toValue:[NSArray arrayWithObjects:@"", imageFile, nil] forNode:newNode parentSize:CGSizeZero];
    
    //[PositionPropertySetter setPositionType:kCCBPositionTypePercent forNode:newNode prop:@"position"];
    //[PositionPropertySetter setPosition: NSPointFromCGPoint(ccp(50.0f, 50.0f)) type:kCCBPositionTypePercent forNode:newNode prop:@"position"];
    [PositionPropertySetter setPosition:NSMakePoint(newNode.contentSize.width/2, newNode.contentSize.height/2) forNode:newNode prop:@"position"];
    
    newNode.displayName = [NSString stringWithFormat:@"%@_background",[[imageFile lastPathComponent] stringByDeletingPathExtension]];
    [newNode setExtraProp:@"background" forKey:@"memberVarAssignmentName"];
    
    [[[CocosScene cocosScene]rootNode] setExtraProp:@"SlideLayerCCB" forKey:@"customClass"];
    
    [self addCCObject:newNode asChild:NO];
}

- (void) setupGUIWindow
{
    NSRect frame = cocosView.frame;
    
    frame.origin = [cocosView convertPoint:NSZeroPoint toView:NULL];
    frame.origin.x += self.window.frame.origin.x;
    frame.origin.y += self.window.frame.origin.y;
    
    guiWindow = [[CCBTransparentWindow alloc] initWithContentRect:frame];
    
    guiView = [[[CCBTransparentView alloc] initWithFrame:cocosView.frame] autorelease];
    [guiWindow setContentView:guiView];
    guiWindow.delegate = self;
    
    [window addChildWindow:guiWindow ordered:NSWindowAbove];
    
    [window setFrameUsingName: @"autosaveWindow"];
    [window setFrameAutosaveName: @"autosaveWindow"];
    
    [splitHorizontalView setAutosaveName: @"autosaveSplitHorView"];
    
    NSMenu * mainMenu = [window menu];
    NSMenuItem * windowItem = [mainMenu itemWithTitle:@"Window"];
    NSMenuItem * resItem = [[NSMenuItem alloc]initWithTitle:@"Resource Manager" action:@selector(menuOpenResourceManager:) keyEquivalent:@"."];
    [resItem setKeyEquivalentModifierMask:NSCommandKeyMask];
    [[windowItem submenu]addItem:resItem];
    
    NSMenuItem * createScenesFromResItem = [[NSMenuItem alloc]initWithTitle:@"To Scenes..." action:@selector(menuCreateNewSceneFromImage:) keyEquivalent:@""];
    [menuContextResManager addItem:createScenesFromResItem];
    
    [self checkForLastOpenedProject];
}

- (void) checkForLastOpenedProject
{
    //NSLog(@"CHECK");
    if(!delayOpenFiles)
    {
        NSString * g = [[CCBGlobalsSunwork sglobals]lastOpenProject];
        if(g && [g compare:@""])
        {
            delayOpenFiles = [[NSMutableArray alloc] initWithObjects:g, nil];
        }
    }
}

- (void) applicationWillTerminate:(NSNotification *)notification
{
    //[projectSettings store];
    //NSLog(@"CATWILLTERMINATE");
    ProjectSettings * set = [[CocosBuilderAppDelegate appDelegate] projectSettings];
    NSString * proj = [set projectPath];
    [[CCBGlobalsSunwork sglobals]setLastOpenProject:proj];
    [[CCBGlobalsSunwork sglobals]writeSettings];
}

//- (void) setProjectSettings:(ProjectSettings *)pSettings
//{
//    if(pSettings !=self.projectSettings)
//    {
//        if (self.projectSettings)
//        {
//            [self.projectSettings release];
//            projectSettings = nil;
//        }
//        projectSettings = [pSettings retain];
//    }
//    [window setTitle:[NSString stringWithFormat:@"%@     |    %@", [[pSettings.projectPath lastPathComponent] stringByDeletingPathExtension] , pSettings.projectPath]];
//}

- (IBAction)playbackStop:(id)sender
{
    NSLog(@"playbackStop");
    playingBack = NO;
    
    [[[CDAudioManager sharedManager]soundEngine]stopAllSounds];//
}

- (BOOL) playingBack
{
    return playingBack;
}

- (void) setPlayingBack:(BOOL)playing
{
    playingBack = playing;
}

- (void) setupResourceManager
{
    // Load resource manager
    resManager = [ResourceManager sharedManager];
    resManagerPanel = [[ResourceManagerPanel alloc] initWithWindowNibName:@"ResourceManagerPanel"];
    [resManagerPanel.window setIsVisible:NO];
    
    // Setup project display
    projectOutlineHandler = [[ResourceManagerOutlineHandler alloc] initWithOutlineView:outlineProject resType:kCCBResTypeNone];
    [self.window makeKeyWindow];
}

- (IBAction) menuOpenResourceManager:(id)sender
{
    [resManagerPanel.window setIsVisible:![resManagerPanel.window isVisible]];
}

//
//- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
//{
//    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"ApplePersistenceIgnoreState"];
//    [self.window center];
//    
//    selectedNodes = [[NSMutableArray alloc] init];
//    loadedSelectedNodes = [[NSMutableArray alloc] init];
//    
//    sharedAppDelegate = self;
//    
//    [[NSExceptionHandler defaultExceptionHandler] setExceptionHandlingMask: NSLogUncaughtExceptionMask | NSLogUncaughtSystemExceptionMask | NSLogUncaughtRuntimeErrorMask];
//    
//    // iOS
//    defaultCanvasSizes[kCCBCanvasSizeIPhoneLandscape] = CGSizeMake(480, 320);
//    defaultCanvasSizes[kCCBCanvasSizeIPhonePortrait] = CGSizeMake(320, 480);
//    defaultCanvasSizes[kCCBCanvasSizeIPhone5Landscape] = CGSizeMake(568, 320);
//    defaultCanvasSizes[kCCBCanvasSizeIPhone5Portrait] = CGSizeMake(320, 568);
//    defaultCanvasSizes[kCCBCanvasSizeIPadLandscape] = CGSizeMake(1024, 768);
//    defaultCanvasSizes[kCCBCanvasSizeIPadPortrait] = CGSizeMake(768, 1024);
//    
//    // Android
//    defaultCanvasSizes[kCCBCanvasSizeAndroidXSmallLandscape] = CGSizeMake(320, 240);
//    defaultCanvasSizes[kCCBCanvasSizeAndroidXSmallPortrait] = CGSizeMake(240, 320);
//    defaultCanvasSizes[kCCBCanvasSizeAndroidSmallLandscape] = CGSizeMake(480, 340);
//    defaultCanvasSizes[kCCBCanvasSizeAndroidSmallPortrait] = CGSizeMake(340, 480);
//    defaultCanvasSizes[kCCBCanvasSizeAndroidMediumLandscape] = CGSizeMake(800, 480);
//    defaultCanvasSizes[kCCBCanvasSizeAndroidMediumPortrait] = CGSizeMake(480, 800);
//    
//    [window setDelegate:self];
//    
//    [self setupTabBar];
//    [self setupInspectorPane];
//    [self setupCocos2d];
//    [self setupSequenceHandler];
//    [self updateInspectorFromSelection];
//    
//    [[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
//    
//    CocosScene* cs = [CocosScene cocosScene];
//    [cs setStageBorder:0];
//    [self updateCanvasBorderMenu];
//    [self updateJSControlledMenu];
//    
//    // Load plug-ins
//    plugInManager = [PlugInManager sharedManager];
//    [plugInManager loadPlugIns];
//    
//    // Update toolbar with plug-ins
//    [self setupToolbar];
//    
//    [self setupResourceManager];
//    [self setupGUIWindow];
//    
//    [self setupPlayerConnection];
//    
//    self.showGuides = YES;
//    self.snapToGuides = YES;
//    self.showStickyNotes = YES;
//    
//    [self.window makeKeyWindow];
//    
//    // Open files
//    if(delayOpenFiles)
//	{
//		[self openFiles:delayOpenFiles];
//		[delayOpenFiles release];
//		delayOpenFiles = nil;
//	}
//    
//    // Check for first run
//    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"completedFirstRun"] boolValue])
//    {
//        [self showHelp:self];
//        
//        // First run completed
//        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"completedFirstRun"];
//    }
//}


@end
