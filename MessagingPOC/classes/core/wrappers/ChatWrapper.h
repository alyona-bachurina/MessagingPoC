//
//  Created by grizzly on 1/7/14.
//


#import <Foundation/Foundation.h>

@class Message;
@class CallRecord;


typedef NS_ENUM(int, VideoChatConferenceType){
    VideoChatConferenceTypeUndefined = 0,
    VideoChatConferenceTypeAudioAndVideo = 1,
    VideoChatConferenceTypeAudio = 2,
};

typedef void(^LoginToChatCompletionBlock)(NSError*);
typedef void(^DidReceiveMessageBlock)(Message* message, NSError*);
typedef void(^LoadUserContactsCompleteBlock)(NSArray* userContacts);
typedef void(^ContactListDidChangeBlock)(NSArray* userContacts);

typedef void(^DidReceiveCallRequestBlock)(CallRecord *record);
typedef void(^DidNotAnswerCallRequestBlock)(CallRecord *record);
typedef void(^DidAcceptCallByUserBlock)(CallRecord *record);
typedef void(^DidRejectCallByUserBlock)(CallRecord *record);
typedef void(^DidStopCallByUserBlock)(CallRecord *record);
typedef void(^DidStartCallRequestBlock)(CallRecord *record);

@class User;
@class UserContact;

@protocol ChatWrapper <NSObject>

- (void)subscribeForContactListDidChangeWithBlock:(ContactListDidChangeBlock)contactListDidChangeBlock;

- (void)subscribeForMessageReceiveWithBlock:(DidReceiveMessageBlock)didReceiveMessageBlock;

- (void)loginWithUser:(User *)user password:password completionBlock:(LoginToChatCompletionBlock)completionBlock;

- (void)loadContactListWithCompletionBlock:(LoadUserContactsCompleteBlock) userContacts;

- (BOOL)addContact:(User *)user;

- (void)logoutCurrentUser;

- (Message *)sendMessage:(NSString *)text toContact:(UserContact *)contact;

- (CallRecord *)startCallWithContact:(UserContact *)userContact callerView:(UIView *)callerVideoView recipientView:(UIView*)destinationVideoView;

- (void)subscribeForReceiveCallRequestWithBlock:(DidReceiveCallRequestBlock)didReceiveCallRequestBlock;
- (void)subscribeForDidNotAnswerCallRequestWithBlock:(DidNotAnswerCallRequestBlock)didNotAnswerCallRequestBlock;
- (void)subscribeForDidAcceptCallByUserWithBlock:(DidAcceptCallByUserBlock)didAcceptCallByUserBlock;
- (void)subscribeForDidRejectCallByUserWithBlock:(DidRejectCallByUserBlock)didRejectCallByUserBlock;
- (void)subscribeForDidStopCallByUserWithBlock:(DidStopCallByUserBlock)stopCallByUserBlock;
- (void)subscribeForDidStartCallRequestWithBlock:(DidStartCallRequestBlock)didStartCallRequestBlock;

- (void)finishCallWithCallRecord:(CallRecord *)record;

- (void)cancelCall:(CallRecord *)record ;

- (void)rejectCallWithCallRecord:(CallRecord *)record;

- (void)acceptCallWithCallRecord:(CallRecord *)callRecord callerView:(UIView *)callerVideoView recipientView:(UIView*)destinationVideoView;
@end