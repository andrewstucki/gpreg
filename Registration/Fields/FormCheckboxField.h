//
//  FormCheckboxField.h
//  Registration
//
//  Created by Andrew Stucki on 4/18/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import "NSControl+FormField.h"

@interface FormCheckboxField : NSMatrix
{
    id<FormFieldDelegate> fieldDelegate;
}

@end
