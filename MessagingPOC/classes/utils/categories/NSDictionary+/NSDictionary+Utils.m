//
//  Created by grizzly on 10/29/13.
//


#import "NSDictionary+Utils.h"


@implementation NSDictionary (Utils)
- (id)firstKeyForValue:(NSObject *)value {
    NSObject *result = nil;
    NSArray *keys = [self allKeysForObject: value];
    if([keys count]){
        result = [keys firstObject];
    }
    return result;

}

@end