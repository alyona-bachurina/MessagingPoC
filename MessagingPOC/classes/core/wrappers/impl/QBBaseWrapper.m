//
//  Created by grizzly on 1/6/14.
//


#import "QBBaseWrapper.h"
#import "QBBaseWrapper+protected.h"


@interface QBBaseWrapper()
@property(nonatomic, strong) NSMutableDictionary *completeBlocks;
@property(nonatomic, strong) NSMutableDictionary *cancelableOperations;
@end

@implementation QBBaseWrapper {

}

- (id)init {
    self = [super init];
    if (self) {
        _completeBlocks = [NSMutableDictionary dictionary];
        _cancelableOperations = [NSMutableDictionary dictionary];
    }

    return self;
}

- (void)dealloc {
    [self cancelAll];
    _completeBlocks=nil;
    _cancelableOperations=nil;
}

- (void) cancelAll{
   for(NSObject<Cancelable>* cancelable in self.cancelableOperations.allValues){
       [cancelable cancel];
   }
   [[self completeBlocks] removeAllObjects];
   [[self cancelableOperations] removeAllObjects];
}

@end