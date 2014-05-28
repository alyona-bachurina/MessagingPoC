//
//  Created by grizzly on 1/6/14.
//


#import "EntityAdapter.h"
#import "DataStore.h"
#import "User.h"
#import "NSManagedObject+SJODataKitAdditions.h"
#import "UserContact.h"
#import "Message.h"
#import "CallRecord.h"

@interface EntityAdapter ()
@property(nonatomic, strong) NSObject<DataStore> *store;
@property(nonatomic, strong) NSMutableDictionary *qbUsers;
@end


@implementation EntityAdapter {

}

- (id)init {
    self = [super init];
    if (self) {
        self.qbUsers = [NSMutableDictionary dictionary];
    }

    return self;
}


- (User *)userWithQBUser:(QBUUser *)user {

    [self.qbUsers setObject:user forKey: user.email];

    User *result = [User detachedInstanceWithContext: self.store.mainContext];
    result.email = user.email;
    result.login = user.login;
    result.id =  @(user.ID);
    return result;
}

- (UserContact *)detachedUserContactWithUser:(User*) contact online:(BOOL) online pending:(BOOL) pending {

    UserContact *result = [UserContact detachedInstanceWithContext: self.store.mainContext];
    result.contact = contact;
    result.online = @(online);
    result.pending = @(pending);
    return result;
}

- (QBUUser *)qbUserWithUser:(User *)user {
    return [self.qbUsers objectForKey: user.email];
}

- (Message *)messageWithQBChatMessage:(QBChatMessage *)qbChatMessage {
    Message *result = [Message detachedInstanceWithContext: self.store.mainContext];
    result.text = qbChatMessage.text;
    result.id =  qbChatMessage.ID;
    result.datetime = qbChatMessage.datetime;
    result.senderId = @(qbChatMessage.senderID);
    result.recipientId = @(qbChatMessage.recipientID);
    result.delayed = @(qbChatMessage.delayed);

    if(qbChatMessage.customParameters){
        result.customParameters = qbChatMessage.customParameters;
    }

    return result;
}

- (CallRecord *)callRecordWithCallerId:(NSUInteger)callerId sessionId:(NSString *)callId conferenceType:(enum QBVideoChatConferenceType)type {
    CallRecord *result = [CallRecord detachedInstanceWithContext: self.store.mainContext];
    result.callerId = @(callerId);
    result.id = callId;
    return result;
}
@end