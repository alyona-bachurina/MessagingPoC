#import "QBBaseWrapper.h"

@interface QBBaseWrapper(_protected)
@property(nonatomic, strong) NSMutableDictionary *completeBlocks;
@property(nonatomic, strong) NSMutableDictionary *cancelableOperations;
@end