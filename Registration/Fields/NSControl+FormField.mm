//
//  FormField.m
//  Registration
//
//  Created by Andrew Stucki on 4/18/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import "NSControl+FormField.h"
#import <objc/runtime.h>

static char const * const kDrawHandlesKey = "DrawHandles";

@implementation NSControl (FormField)

@dynamic drawHandles;

CGFloat kFieldHandleWidth = 6.0f;
CGFloat kFieldHandleHalfWidth = 6.0f / 2.0f;

///////////note changes of bounds to frame

+ (id)defaultField
{
    return [[NSControl alloc] init];
}

- (NSInteger)handleUnderPoint:(NSPoint)point {
    
    // Check handles at the corners and on the sides.
    NSInteger handle = kFieldNoHandle;
    NSRect bounds = [self boundsOrFrame];
    if ([self isHandleAtPoint:NSMakePoint(NSMinX(bounds), NSMinY(bounds)) underPoint:point]) {
        handle = kFieldUpperLeftHandle;
    } else if ([self isHandleAtPoint:NSMakePoint(NSMidX(bounds), NSMinY(bounds)) underPoint:point]) {
        handle = kFieldUpperMiddleHandle;
    } else if ([self isHandleAtPoint:NSMakePoint(NSMaxX(bounds), NSMinY(bounds)) underPoint:point]) {
        handle = kFieldUpperRightHandle;
    } else if ([self isHandleAtPoint:NSMakePoint(NSMinX(bounds), NSMidY(bounds)) underPoint:point]) {
        handle = kFieldMiddleLeftHandle;
    } else if ([self isHandleAtPoint:NSMakePoint(NSMaxX(bounds), NSMidY(bounds)) underPoint:point]) {
        handle = kFieldMiddleRightHandle;
    } else if ([self isHandleAtPoint:NSMakePoint(NSMinX(bounds), NSMaxY(bounds)) underPoint:point]) {
        handle = kFieldLowerLeftHandle;
    } else if ([self isHandleAtPoint:NSMakePoint(NSMidX(bounds), NSMaxY(bounds)) underPoint:point]) {
        handle = kFieldLowerMiddleHandle;
    } else if ([self isHandleAtPoint:NSMakePoint(NSMaxX(bounds), NSMaxY(bounds)) underPoint:point]) {
        handle = kFieldLowerRightHandle;
    }
    return handle;
}

- (BOOL)isHandleAtPoint:(NSPoint)handlePoint underPoint:(NSPoint)point {
    
    // Check a handle-sized rectangle that's centered on the handle point.
    NSRect handleBounds;
    handleBounds.origin.x = handlePoint.x - kFieldHandleHalfWidth;
    handleBounds.origin.y = handlePoint.y - kFieldHandleHalfWidth;
    handleBounds.size.width = kFieldHandleWidth;
    handleBounds.size.height = kFieldHandleWidth;
    return NSPointInRect(point, handleBounds);
    
}

- (BOOL)isContentsUnderPoint:(NSPoint)point {
    
    // Just check against the graphic's bounds.
    return NSPointInRect(point, [self boundsOrFrame]);
    
}

- (NSInteger)resizeByMovingHandle:(NSInteger)handle toPoint:(NSPoint)point {
    
    // Start with the original bounds.
    NSRect bounds = [self boundsOrFrame];
    
    // Is the user changing the width of the graphic?
    if (handle==kFieldUpperLeftHandle || handle==kFieldMiddleLeftHandle || handle==kFieldLowerLeftHandle) {
        
        // Change the left edge of the graphic.
        bounds.size.width = NSMaxX(bounds) - point.x;
        bounds.origin.x = point.x;
        
    } else if (handle==kFieldUpperRightHandle || handle==kFieldMiddleRightHandle || handle==kFieldLowerRightHandle) {
        
        // Change the right edge of the graphic.
        bounds.size.width = point.x - bounds.origin.x;
        
    }
    
    // Did the user actually flip the graphic over?
    if (bounds.size.width<0.0f) {
        
        // The handle is now playing a different role relative to the graphic.
        static NSInteger flippings[9];
        static BOOL flippingsInitialized = NO;
        if (!flippingsInitialized) {
            flippings[kFieldUpperLeftHandle] = kFieldUpperRightHandle;
            flippings[kFieldUpperMiddleHandle] = kFieldUpperMiddleHandle;
            flippings[kFieldUpperRightHandle] = kFieldUpperLeftHandle;
            flippings[kFieldMiddleLeftHandle] = kFieldMiddleRightHandle;
            flippings[kFieldMiddleRightHandle] = kFieldMiddleLeftHandle;
            flippings[kFieldLowerLeftHandle] = kFieldLowerRightHandle;
            flippings[kFieldLowerMiddleHandle] = kFieldLowerMiddleHandle;
            flippings[kFieldLowerRightHandle] = kFieldLowerLeftHandle;
            flippingsInitialized = YES;
        }
        handle = flippings[handle];
        
        // Make the graphic's width positive again.
        bounds.size.width = 0.0f - bounds.size.width;
        bounds.origin.x -= bounds.size.width;
        
        // Tell interested subclass code what just happened.
        [self flipHorizontally];
        
    }
    
    // Is the user changing the height of the graphic?
    if (handle==kFieldUpperLeftHandle || handle==kFieldUpperMiddleHandle || handle==kFieldUpperRightHandle) {
        
        // Change the top edge of the graphic.
        bounds.size.height = NSMaxY(bounds) - point.y;
        bounds.origin.y = point.y;
        
    } else if (handle==kFieldLowerLeftHandle || handle==kFieldLowerMiddleHandle || handle==kFieldLowerRightHandle) {
        
        // Change the bottom edge of the graphic.
        bounds.size.height = point.y - bounds.origin.y;
        
    }
    
    // Did the user actually flip the graphic upside down?
    if (bounds.size.height<0.0f) {
        
        // The handle is now playing a different role relative to the graphic.
        static NSInteger flippings[9];
        static BOOL flippingsInitialized = NO;
        if (!flippingsInitialized) {
            flippings[kFieldUpperLeftHandle] = kFieldLowerLeftHandle;
            flippings[kFieldUpperMiddleHandle] = kFieldLowerMiddleHandle;
            flippings[kFieldUpperRightHandle] = kFieldLowerRightHandle;
            flippings[kFieldMiddleLeftHandle] = kFieldMiddleLeftHandle;
            flippings[kFieldMiddleRightHandle] = kFieldMiddleRightHandle;
            flippings[kFieldLowerLeftHandle] = kFieldUpperLeftHandle;
            flippings[kFieldLowerMiddleHandle] = kFieldUpperMiddleHandle;
            flippings[kFieldLowerRightHandle] = kFieldUpperRightHandle;
            flippingsInitialized = YES;
        }
        handle = flippings[handle];
        
        // Make the graphic's height positive again.
        bounds.size.height = 0.0f - bounds.size.height;
        bounds.origin.y -= bounds.size.height;
        
        // Tell interested subclass code what just happened.
        [self flipVertically];
        
    }
    
    // Done.
    [self setFrame:bounds];
    return handle;
    
}

- (void)flipHorizontally {
    
    // Live to be overridden.
    
}


- (void)flipVertically {
    
    // Live to be overridden.
    
}

- (NSRect)boundsOrFrame
{
    return [self frame];
    //    if ([[self class] isSubclassOfClass:NSClassFromString(@"NSTextField")]) {
//        return [self frame];
//    }
//    return [self bounds];
}

- (void)setFieldDelegate:(id)aDelegate
{
    if ([[self getInstanceVariables] containsObject:@"fieldDelegate"]) {
        Ivar variable = class_getInstanceVariable([self class], "fieldDelegate");
        object_setIvar(self, variable, aDelegate);
    }
}

- (id)fieldDelegate
{
    if ([[self getInstanceVariables] containsObject:@"fieldDelegate"]) {
        Ivar variable = class_getInstanceVariable([self class], "fieldDelegate");
        return object_getIvar(self, variable);
    }
    return nil;
}

- (NSArray *)getInstanceVariables {
    NSMutableArray *props = [NSMutableArray array];
    unsigned int outCount, i;
    Ivar *properties = class_copyIvarList([self class], &outCount);
    for (i = 0; i < outCount; i++) {
        Ivar property = properties[i];
        NSString *propertyName = [[NSString alloc] initWithUTF8String:ivar_getName(property)];
        [props addObject:propertyName];
    }
    
    free(properties);
    return props;
}

//[field setNeedsDisplay:YES withSelectionHandles:drawSelectionHandles];
- (void)setNeedsDisplay:(BOOL)display withSelectionHandles:(BOOL)handles
{
    [self setNeedsDisplay:display];
    [self setDrawHandles:handles];
//    drawHandles = handles;
//    drawHandles = handles;
}

- (void)setDrawHandles:(BOOL)drawHandles
{
    NSNumber *number = [NSNumber numberWithBool:drawHandles];
    objc_setAssociatedObject(self, kDrawHandlesKey, number , OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)drawHandles
{
    NSNumber *number = objc_getAssociatedObject(self, kDrawHandlesKey);
    return [number boolValue];
}

@end
