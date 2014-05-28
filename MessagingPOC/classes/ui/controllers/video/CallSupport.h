//
//  Created by grizzly on 1/10/14.
//


#import <Foundation/Foundation.h>

@class CallRecord;

@protocol CallSupport <NSObject>
@property(nonatomic, strong) CallRecord *callRecord;
@end