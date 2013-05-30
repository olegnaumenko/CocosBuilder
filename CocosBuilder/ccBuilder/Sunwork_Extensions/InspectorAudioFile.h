//
//  InspectorAudioFile.h
//  CocosBuilder
//
//  Created by oleg on 1/17/13.
//
//

#import "InspectorValue.h"

@interface InspectorAudioFile : InspectorValue
{
    IBOutlet NSPopUpButton* popup;
    IBOutlet NSMenu* menu;
    IBOutlet NSTextField * fileLabel;
    //float duration;
}

//@property (nonatomic, assign) float duration;

@end
