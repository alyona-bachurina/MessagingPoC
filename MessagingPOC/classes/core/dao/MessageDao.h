//
//  Created by grizzly on 1/8/14.
//


#import <Foundation/Foundation.h>

@class Message;
@class UserContact;
@class CallRecord;
@class User;

@protocol MessageDao <NSObject>

- (Message *)saveMessage:(Message *)message;

- (NSArray *)getMessagesHistoryForContact:(UserContact *)contact;

- (NSArray *)getUnreadMessagesFromContact:(UserContact *)contact;

- (void)markMessageRead:(Message *)message;

- (NSArray *)getCallsHistoryForUser:(User *)user;

- (CallRecord *)saveCallRecord:(CallRecord *)record;
@end