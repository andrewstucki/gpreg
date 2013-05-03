//
//  FormTextFieldCell.m
//  Registration
//
//  Created by Andrew Stucki on 4/22/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import "FormTextFieldCell.h"

@implementation FormTextFieldCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    [super drawWithFrame:cellFrame inView:controlView];
    
    if ([(NSControl *)controlView drawHandles]) {
        NSRect outlineFrame = cellFrame;
        outlineFrame.size.width -= 0;
        outlineFrame.size.height -= 0;
        NSBezierPath *mask = [NSBezierPath bezierPathWithRect:outlineFrame];
        [mask addClip];
        
        [self drawHandleAtPoint:NSMakePoint(NSMinX(cellFrame), NSMinY(cellFrame))];
        [self drawHandleAtPoint:NSMakePoint(NSMidX(cellFrame), NSMinY(cellFrame))];
        [self drawHandleAtPoint:NSMakePoint(NSMaxX(cellFrame), NSMinY(cellFrame))];
        [self drawHandleAtPoint:NSMakePoint(NSMinX(cellFrame), NSMidY(cellFrame))];
        [self drawHandleAtPoint:NSMakePoint(NSMaxX(cellFrame), NSMidY(cellFrame))];
        [self drawHandleAtPoint:NSMakePoint(NSMinX(cellFrame), NSMaxY(cellFrame))];
        [self drawHandleAtPoint:NSMakePoint(NSMidX(cellFrame), NSMaxY(cellFrame))];
        [self drawHandleAtPoint:NSMakePoint(NSMaxX(cellFrame), NSMaxY(cellFrame))];
        
        [mask setLineWidth:4];
        [[NSColor colorWithCalibratedRed:0.510 green:0.643 blue:0.804 alpha:1] setStroke];
        [mask stroke];
    }
}

- (void)drawHandleAtPoint:(NSPoint)point
{
    
    NSLog(@"Drawing point at %f, %f", point.x, point.y);
    
    // Figure out a rectangle that's centered on the point but lined up with device pixels.
    NSRect handleBounds;
    handleBounds.origin.x = point.x - kFieldHandleHalfWidth;
    handleBounds.origin.y = point.y - kFieldHandleHalfWidth;
    handleBounds.size.width = kFieldHandleWidth;
    handleBounds.size.height = kFieldHandleWidth;
    //    handleBounds = [view centerScanRect:handleBounds];
    
    // Draw the shadow of the handle.
//    NSRect handleShadowBounds = NSOffsetRect(handleBounds, 1.0f, 1.0f);
//    [[NSColor controlDarkShadowColor] set];
//    NSRectFill(handleShadowBounds);
    
    // Draw the handle itself.
    [[NSColor knobColor] set];
    NSRectFill(handleBounds);
    
}

@end
