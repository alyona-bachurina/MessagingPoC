//
//  Created by grizzly on 1/8/14.
//


#import <Foundation/Foundation.h>

@class UserContact;

@protocol DirectChat <NSObject>
@property(nonatomic, strong) UserContact *destinationContact;
@end