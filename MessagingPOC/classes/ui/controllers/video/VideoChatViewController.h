//
//  Created by grizzly on 1/10/14.
//


#import <Foundation/Foundation.h>
#import "DirectChat.h"
#import "CallSupport.h"

@class DACircularProgressView;


@interface VideoChatViewController : UIViewController<DirectChat, CallSupport>


@end