//
//  Created by grizzly on 1/10/14.
//


#import <Foundation/Foundation.h>

@protocol ControllerProvider;
@class UserContact;
@class CallRecord;

@interface UIViewController (ChatSupport)
- (void)presentChatControllerForUserContact:(UserContact *)contact animated:(BOOL)animated controllerProvider:(id<ControllerProvider>)controllerProvider;
- (void)presentVideoChatControllerForUserContact:(UserContact *)contact animated:(BOOL)animated controllerProvider:(id<ControllerProvider>)controllerProvider;
- (void)presentVideoChatControllerForCallRecord:(CallRecord*)callRecord animated:(BOOL)animated controllerProvider:(id<ControllerProvider>)controllerProvider;
@end