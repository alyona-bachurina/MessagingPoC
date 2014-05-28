//
//  Created by grizzly on 1/6/14.
//


#import <Foundation/Foundation.h>

@class  User;
@class UserContact;
@class Message;
@class CallRecord;

@interface EntityAdapter : NSObject
- (User *)userWithQBUser:(QBUUser *)user;
- (QBUUser *)qbUserWithUser:(User *)user;
- (UserContact *)detachedUserContactWithUser:(User*) contact online:(BOOL) online pending:(BOOL) pending ;

- (Message *)messageWithQBChatMessage:(QBChatMessage *)qbChatMessage;

- (CallRecord *)callRecordWithCallerId:(NSUInteger)callerId sessionId:(NSString *)callId conferenceType:(enum QBVideoChatConferenceType)type;
@end