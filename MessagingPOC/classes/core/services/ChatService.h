//
//  Created by grizzly on 1/7/14.
//


#import <Foundation/Foundation.h>

@class User;
@class ContactsViewController;
@class UserContact;
@class Message;
@class CallRecord;

typedef void(^CommonCallActionBlock)(CallRecord *record);
typedef void(^CommonChatActionBlock)();



@protocol ChatService <NSObject>

- (void)subscribeObject:(NSObject *)subscriber onContactListUpdtatesWithBlock:(CommonChatActionBlock)block;

- (void)subscribeObject:(NSObject *)subscriber onMessagesListUpdtatesWithBlock:(CommonChatActionBlock)block;

- (void)subscribeObject:(NSObject *)subscriber onUnreadMessagesCountChangedWithBlock:(CommonChatActionBlock)block;

- (void)subscribeObject:(NSObject *)subscriber onReceiveCallWithBlock:(CommonCallActionBlock)block;

- (void)subscribeObject:(NSObject *)subscriber onDidNotAnswerCallWithBlock:(CommonCallActionBlock)block;

- (void)subscribeObject:(NSObject *)subscriber onDidAcceptCallByUserWithBlock:(CommonCallActionBlock)block;

- (void)subscribeObject:(NSObject *)subscriber onDidRejectCallByUserWithBlock:(CommonCallActionBlock)block;

- (void)subscribeObject:(NSObject *)subscriber onDidStopCallByUserWithBlock:(CommonCallActionBlock)block;

- (void)subscribeObject:(NSObject *)subscriber onDidStartCallRequestWithBlock:(CommonCallActionBlock)block;

- (void)unsubscribe:(NSObject*)subscriber;

- (void)addContact:(User *)user;

- (Message *)sendMessage:(NSString *)text toContact:(UserContact *)contact;

- (NSArray *)getMessagesHistoryForContact:(UserContact *)contact;

- (NSDictionary *)getUnreadMessagesForContacts:(NSArray *)contacts;

- (void)markMessagesRead:(NSArray *)messages;

- (CallRecord *)startCallWithContact:(UserContact *)userContact callerView:(UIView *)callerVideoView recipientView:(UIView*)destinationVideoView;

- (NSArray *)getRecentCallHistory;

- (void)finishCallWithCallRecord:(CallRecord *)callRecord;

- (void)cancelCall:(CallRecord *)record;

- (void)rejectWithCallRecord:(CallRecord *)callRecord;

- (void)acceptWithCallRecord:(CallRecord *)callRecord callerView:(UIView *)callerVideoView recipientView:(UIView*)destinationVideoView;
@end