//
//  Created by grizzly on 1/7/14.
//


#import <Foundation/Foundation.h>
#import "ChatService.h"

@class Message;


@interface ChatServiceImpl : NSObject<ChatService>
- (Message *)saveMessage:(Message *)message;
@end