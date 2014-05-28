//
//  Created by grizzly on 1/7/14.
//


#import "ChatServiceImpl.h"
#import "ChatWrapper.h"
#import "ApplicationContextService.h"
#import "UserService.h"
#import "Message.h"
#import "UserContact.h"
#import "Message.h"
#import "MessageDao.h"
#import "User.h"
#import "ApplicationContext.h"
#import "CallRecord.h"

const NSString*kContactListUpdates=@"kContactListUpdates";
const NSString*kMessageReceived=@"kMessageReceived";
const NSString*kReadMessagesCountChanged=@"kReadMessagesCountChanged";
const NSString*kCallReceived=@"kCallReceived";
const NSString*kDidNotAnswerCall=@"kDidNotAnswerCall";
const NSString*kDidAcceptCallByUser=@"kDidAcceptCallByUser";
const NSString*kDidRejectCallByUser =@"kDidRejectCallByUser";
const NSString*kDidStopCallByUser =@"kDidStopCallByUser";
const NSString*kDidStartCallRequest =@"kDidStartCallRequest";

@interface ChatServiceImpl ()
@property(nonatomic, strong) NSObject<ApplicationContextService> *applicationContextService;
@property(nonatomic, strong) NSObject<UserService> *userService;
@property(nonatomic, strong) NSObject<ChatWrapper> *chatWrapper;
@property(nonatomic, strong) NSObject<MessageDao> *messageDao;

@property(nonatomic, strong) NSDictionary *subscriptions;
@end

@implementation ChatServiceImpl {

}

- (id)init {
    self = [super init];
    if (self) {
        self.subscriptions = @{
                kContactListUpdates: [NSMutableDictionary dictionary],
                kMessageReceived: [NSMutableDictionary dictionary],
                kReadMessagesCountChanged: [NSMutableDictionary dictionary],
                kCallReceived: [NSMutableDictionary dictionary],
                kDidNotAnswerCall: [NSMutableDictionary dictionary],
                kDidAcceptCallByUser: [NSMutableDictionary dictionary],
                kDidRejectCallByUser : [NSMutableDictionary dictionary],
                kDidStopCallByUser : [NSMutableDictionary dictionary],
                kDidStartCallRequest : [NSMutableDictionary dictionary]
        };

    }

    return self;
}

#pragma subscription management

- (void) subscribeForChatChanges {

    __weak typeof (self) weakSelf = self;
    [self.chatWrapper subscribeForContactListDidChangeWithBlock:^(NSArray *userContacts){
        [weakSelf.userService saveUserContacts: userContacts];
        DLog(@"recieved update of contact list: %@", userContacts);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableDictionary *dictionary = [weakSelf.subscriptions objectForKey: kContactListUpdates];
            [dictionary.allValues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                void (^block)() = obj;
                block();
            }];
        });
    }];

    [self.chatWrapper subscribeForMessageReceiveWithBlock:^(Message *detachedMessage, NSError *error) {
        [weakSelf saveMessage:detachedMessage];
        DLog(@"recieved message: %@", detachedMessage);
        dispatch_async(dispatch_get_main_queue(), ^{
            [@[kMessageReceived, kReadMessagesCountChanged] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSMutableDictionary *dictionary = [weakSelf.subscriptions objectForKey: obj];
                [dictionary.allValues enumerateObjectsUsingBlock:^(id callbackBlock, NSUInteger itemIdx, BOOL * shouldStop) {
                    void (^block)() = callbackBlock;
                    block();
                }];
            }];
        });
    }];

    [self.chatWrapper subscribeForReceiveCallRequestWithBlock:^(CallRecord *detachedRecord) {
        [weakSelf callSimpleBlockForSubscriptionKey:kCallReceived callRecord: detachedRecord];
    }];

    [self.chatWrapper subscribeForDidNotAnswerCallRequestWithBlock:^(CallRecord *record) {
        [weakSelf callSimpleBlockForSubscriptionKey:kDidNotAnswerCall callRecord:record ];
    }];

    [self.chatWrapper subscribeForDidAcceptCallByUserWithBlock:^(CallRecord *record) {
        [weakSelf callSimpleBlockForSubscriptionKey: kDidAcceptCallByUser callRecord:record];
    }];

    [self.chatWrapper subscribeForDidRejectCallByUserWithBlock:^(CallRecord *record) {
        [weakSelf callSimpleBlockForSubscriptionKey:kDidRejectCallByUser callRecord:record ];
    }];

    [self.chatWrapper subscribeForDidStopCallByUserWithBlock:^(CallRecord *record) {
        [weakSelf callSimpleBlockForSubscriptionKey:kDidStopCallByUser callRecord:record ];
    }];

    [self.chatWrapper subscribeForDidStartCallRequestWithBlock:^(CallRecord *record) {
        [weakSelf callSimpleBlockForSubscriptionKey:kDidStartCallRequest callRecord:record ];
    }];

}

- (void)callSimpleBlockForSubscriptionKey:(NSString const *)key callRecord:(CallRecord *)detachedRecord {
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        CallRecord *record = [weakSelf saveCallRecord:detachedRecord];
        NSMutableDictionary *dictionary = [weakSelf.subscriptions objectForKey:key];
        [dictionary.allValues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            CommonCallActionBlock block = obj;
            block(record);
        }];
    });
}

- (void)subscribeObject:(NSObject *)subscriber onMessagesListUpdtatesWithBlock:(CommonChatActionBlock)block {
    NSMutableDictionary *dictionary = [self.subscriptions objectForKey: kMessageReceived];
    [dictionary setObject:block forKey: [NSValue valueWithNonretainedObject: subscriber]];
}

- (void)subscribeObject:(NSObject *)subscriber onUnreadMessagesCountChangedWithBlock:(CommonChatActionBlock)block {
    NSMutableDictionary *dictionary = [self.subscriptions objectForKey: kReadMessagesCountChanged];
    [dictionary setObject:block forKey: [NSValue valueWithNonretainedObject: subscriber]];
}

- (void)subscribeObject:(NSObject *)subscriber onContactListUpdtatesWithBlock:(CommonChatActionBlock)block {
    NSMutableDictionary *dictionary = [self.subscriptions objectForKey: kContactListUpdates];
    [dictionary setObject:block forKey: [NSValue valueWithNonretainedObject: subscriber]];
}

- (void)subscribeObject:(NSObject *)subscriber onReceiveCallWithBlock:(CommonCallActionBlock)block {

    NSMutableDictionary *dictionary = [self.subscriptions objectForKey: kCallReceived];
    [dictionary setObject:block forKey: [NSValue valueWithNonretainedObject: subscriber]];
}

- (void)subscribeObject:(NSObject *)subscriber onDidNotAnswerCallWithBlock:(CommonCallActionBlock)block {
    NSMutableDictionary *dictionary = [self.subscriptions objectForKey: kDidNotAnswerCall];
    [dictionary setObject:block forKey: [NSValue valueWithNonretainedObject: subscriber]];
}

- (void)subscribeObject:(NSObject *)subscriber onDidAcceptCallByUserWithBlock:(CommonCallActionBlock)block {
    NSMutableDictionary *dictionary = [self.subscriptions objectForKey: kDidAcceptCallByUser];
    [dictionary setObject:block forKey: [NSValue valueWithNonretainedObject: subscriber]];
}

- (void)subscribeObject:(NSObject *)subscriber onDidRejectCallByUserWithBlock:(CommonCallActionBlock)block {
    NSMutableDictionary *dictionary = [self.subscriptions objectForKey:kDidRejectCallByUser];
    [dictionary setObject:block forKey: [NSValue valueWithNonretainedObject: subscriber]];
}

- (void)subscribeObject:(NSObject *)subscriber onDidStopCallByUserWithBlock:(CommonCallActionBlock)block {
    NSMutableDictionary *dictionary = [self.subscriptions objectForKey:kDidStopCallByUser];
    [dictionary setObject:block forKey: [NSValue valueWithNonretainedObject: subscriber]];
}

- (void)subscribeObject:(NSObject *)subscriber onDidStartCallRequestWithBlock:(CommonCallActionBlock)block {
    NSMutableDictionary *dictionary = [self.subscriptions objectForKey:kDidStartCallRequest];
    [dictionary setObject:block forKey: [NSValue valueWithNonretainedObject: subscriber]];
}


- (void)unsubscribe:(NSObject*)subscriber{
    [self.subscriptions enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [obj removeObjectForKey: [NSValue valueWithNonretainedObject: subscriber]];
    }];

}

#pragma mark services

- (void)addContact:(User *)contact {
    [[self chatWrapper] addContact:contact];
}

- (NSDictionary *)getUnreadMessagesForContacts:(NSArray *)contacts {

    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity: contacts.count];
    [contacts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UserContact *userContact = obj;
        NSArray *messages = [self.messageDao getUnreadMessagesFromContact: userContact];
        if(messages.count){
            [result setObject: @(messages.count) forKey: userContact.contact.id];
        }
    }];

    return result;
}

- (void)markMessagesRead:(NSArray *)messages {

    [messages enumerateObjectsUsingBlock:^(id message, NSUInteger idx, BOOL *stop) {
        [self.messageDao markMessageRead:message];
    }];

    NSMutableDictionary *dictionary = [self.subscriptions objectForKey: kReadMessagesCountChanged];
    [dictionary.allValues enumerateObjectsUsingBlock:^(id callbackBlock, NSUInteger itemIdx, BOOL * shouldStop) {
        void (^block)() = callbackBlock;
        block();
    }];
}


- (NSArray *)getMessagesHistoryForContact:(UserContact *)contact {
    NSArray *result = [self.messageDao getMessagesHistoryForContact:contact];
    return result;
}


- (Message *)saveMessage:(Message *)message {
    Message *result = [self.messageDao saveMessage: message];
    return result;
}

- (Message *)sendMessage:(NSString *)text toContact:(UserContact *)contact {
    Message *detachedMessage =[[self chatWrapper] sendMessage: text toContact: contact];
    Message *result = [self.messageDao saveMessage: detachedMessage];
    return result;
}

- (CallRecord *)startCallWithContact:(UserContact *)userContact callerView:(UIView *)callerVideoView recipientView:(UIView*)destinationVideoView{
    CallRecord *detachedRecord = [self.chatWrapper startCallWithContact:userContact callerView:callerVideoView recipientView:destinationVideoView];
    CallRecord *result = [self saveCallRecord: detachedRecord];
    return result;
}

- (CallRecord *)saveCallRecord:(CallRecord *)detachedRecord {
    CallRecord * record = [self.messageDao saveCallRecord:detachedRecord];

    ApplicationContext* applicationContext = [self.applicationContextService getApplicationContext];
    User* currentUser = [applicationContext currentUser];

    // resolve recipientId (for incoming calls)
    if(record.recipientId.integerValue==0){
        [record setRecipientId:[currentUser id]];
    }

    // resolve user contact
    if(!record.userContact){

        NSInteger targetUserId;
        if([record.recipientId integerValue] == [[currentUser id] integerValue]){
            targetUserId = [[record callerId] integerValue];
        }else{
            targetUserId = [[record recipientId] integerValue];
        }
        UserContact *targetUserContact = [self.userService findContactByUserId: targetUserId];
        [record setUserContact:targetUserContact];
        record = [self.messageDao saveCallRecord:record];
    }

    return record;
}

- (NSArray *)getRecentCallHistory {
    ApplicationContext* applicationContext = self.applicationContextService.getApplicationContext;
    return [self.messageDao getCallsHistoryForUser:[applicationContext currentUser]];

}

- (void)finishCallWithCallRecord:(CallRecord *)callRecord {
    [self.chatWrapper finishCallWithCallRecord:callRecord];
    [self saveCallRecord: callRecord];
}

- (void)cancelCall:(CallRecord *)record{
    [self.chatWrapper cancelCall: record];
}

- (void)rejectWithCallRecord:(CallRecord *)callRecord {
    [self.chatWrapper rejectCallWithCallRecord: callRecord];

}

- (void)acceptWithCallRecord:(CallRecord *)callRecord callerView:(UIView *)callerVideoView recipientView:(UIView*)destinationVideoView{
    [self.chatWrapper acceptCallWithCallRecord:callRecord callerView:callerVideoView recipientView:destinationVideoView];
}


@end