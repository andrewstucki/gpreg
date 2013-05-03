//
//  FormTextField.h
//  Registration
//
//  Created by Andrew Stucki on 4/16/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import "NSControl+FormField.h"

@interface FormTextField : NSTextField
{
    id<FormFieldDelegate> fieldDelegate;
}

- (void)setPlaceholderString:(NSString *)aString;
- (NSString *)placeholderString;
- (void)setSize:(NSNumber *)size;

@end
