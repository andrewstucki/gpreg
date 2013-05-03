//
//  FormField.h
//  Registration
//
//  Created by Andrew Stucki on 4/18/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FormFieldNotifications.h"
#import "FormFieldDelegate.h"

enum {
    kFieldNoHandle = 0,
    kFieldUpperLeftHandle = 1,
    kFieldUpperMiddleHandle = 2,
    kFieldUpperRightHandle = 3,
    kFieldMiddleLeftHandle = 4,
    kFieldMiddleRightHandle = 5,
    kFieldLowerLeftHandle = 6,
    kFieldLowerMiddleHandle = 7,
    kFieldLowerRightHandle = 8,
};

extern CGFloat kFieldHandleWidth;
extern CGFloat kFieldHandleHalfWidth;

@interface NSControl (FormField)

@property BOOL drawHandles;

+ (id)defaultField;
- (BOOL)isHandleAtPoint:(NSPoint)handlePoint underPoint:(NSPoint)point;
- (NSInteger)handleUnderPoint:(NSPoint)point;
- (BOOL)isContentsUnderPoint:(NSPoint)point;
- (NSInteger)resizeByMovingHandle:(NSInteger)handle toPoint:(NSPoint)point;
- (void)flipHorizontally;
- (void)flipVertically;
- (NSRect)boundsOrFrame;

- (void)setFieldDelegate:(id)aDelegate;
- (id)fieldDelegate;

//- (void)drawHandleAtPoint:(NSPoint)point;
- (void)setNeedsDisplay:(BOOL)display withSelectionHandles:(BOOL)handles;

@end
