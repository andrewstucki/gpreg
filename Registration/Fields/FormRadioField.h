//
//  FormRadioField.h
//  Registration
//
//  Created by Andrew Stucki on 4/18/13.
//  Copyright (c) 2013 Gracepoint. All rights reserved.
//

#import "NSControl+FormField.h"

@interface FormRadioField : NSMatrix
{
    id<FormFieldDelegate> fieldDelegate;
}

@end
