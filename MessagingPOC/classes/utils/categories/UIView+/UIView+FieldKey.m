//
//  Created by grizzly on 3/26/13.
//


#import <objc/runtime.h>
#import "UIView+FieldKey.h"


@implementation UIView (FieldKey)

static NSString * kKey = @"kFieldKey";
static NSString * kStringFieldValue = @"kStringFieldValue";



- (void) setFieldKey:(NSString *)key {
   objc_setAssociatedObject(self, &kKey, key, OBJC_ASSOCIATION_COPY);
}


- (NSString *) getFieldKey {
    NSObject *obj = objc_getAssociatedObject(self, &kKey);
    NSString* result = nil;
    if (obj&&[obj isKindOfClass:[NSString class]]){
        result = (NSString *) obj;
    }
    return result;
}

@end