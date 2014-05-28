//
//  Created by grizzly on 1/8/14.
//


#import <Foundation/Foundation.h>

typedef void (^DidSelectValue)(id);
typedef void (^DidCancelSelection)();

@protocol PickerViewController <NSObject>
@property (copy) DidSelectValue doneBlock;
@property (copy) DidCancelSelection cancelBlock;
@end