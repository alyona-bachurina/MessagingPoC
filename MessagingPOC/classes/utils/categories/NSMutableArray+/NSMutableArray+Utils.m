//
//  Created by grizzly on 10/30/13.
//


#import "NSMutableArray+Utils.h"


@implementation NSMutableArray (Utils)

-(void)removeString:(NSString*)right{
    NSMutableIndexSet *indexesToRemove = [NSMutableIndexSet indexSet];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString* left = obj;
        if([right isEqualToString:left]){
            [indexesToRemove addIndex: idx];
        }
    }];
    [self removeObjectsAtIndexes: indexesToRemove];
}

@end