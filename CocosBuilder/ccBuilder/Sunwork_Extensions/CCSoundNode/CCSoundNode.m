/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "CCSoundNode.h"
#import "NSImage-Tint.h"

@implementation CCSoundNode

@synthesize soundFile, duration, playing=_playing;

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    self.playing = NO;
    effect = 0;
    _playing = NO;
    self.duration = 0.0f;
    //self.soundFile = @"";//@"/Users/oleg/Documents/lesson1/lesson1/exportab.m4a";//
    
    imgInterpolPlay = [[NSImage imageNamed:@"seq-keyframe-interpol-vis.png"] retain];
    imgInterpolPlay = [imgInterpolPlay bluetoneImage];
    [imgInterpolPlay setFlipped:YES];
    
    return self;
}

- (void) setSoundFile:(NSString *)file
{
    if (file!=soundFile)
    {
        [soundFile release];
        soundFile = nil;
        soundFile = [file retain];
    }
    soundFile = file;
    if(!soundFile || [soundFile isEqualToString:@""]) return;
    [[SimpleAudioEngine sharedEngine]preloadEffect:file];
    source = [[SimpleAudioEngine sharedEngine]soundSourceForFile:file];
    self.duration = [source durationInSeconds];
    //NSLog(@"setSoundFile: Duration =  %2.2f", duration);
}

- (void) setPlaying:(BOOL)pl
{
    if(!_playing && pl)
    {
        if (!soundFile) return;
        effect = [[SimpleAudioEngine sharedEngine]playEffect:soundFile];
        _playing = pl && (BOOL)effect;
    }
    else if(/*_playing && */ effect &&!pl)
    {
        [[SimpleAudioEngine sharedEngine]stopEffect:effect];
        effect = 0;
        _playing = NO;
    }
}

#pragma MARK Draw Delegate

-(BOOL) canDrawInterpolationForProperty:(NSString*) propName
{
    return (BOOL)[propName isEqualToString:@"playing"];
}

-(void) drawInterpolationInRect:(NSRect) rect forProperty:(NSString*) propName withStartValue:(id) startValue endValue:(id) endValue andDuration:(float) dur
{
    //NSLog(@"Start: %@  End: %@,  Duration: %2.2f", startValue, endValue, duratio);
    
    NSRect wholeRect = rect;
    wholeRect.size.width = duration*rect.size.width/dur;
    
    [imgInterpolPlay drawInRect:wholeRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
    
    [imgInterpolPlay drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:0.4];
    
    NSString * nm = [soundFile lastPathComponent];
    
    NSColor * color = [NSColor darkGrayColor];
    [color set];
    NSFont * font = [NSFont systemFontOfSize:(11.0f)];
    NSDictionary * att = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, color, NSForegroundColorAttributeName, nil];
    
    [nm drawAtPoint:NSMakePoint(rect.origin.x + 10, rect.origin.y - 1.5) withAttributes:att];
    
}

@end
