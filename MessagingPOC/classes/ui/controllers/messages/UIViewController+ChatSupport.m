//
//  Created by grizzly on 1/10/14.
//


#import "UIViewController+ChatSupport.h"
#import "UIViewController+Utils.h"
#import "UserContact.h"
#import "DirectChat.h"
#import "ControllerProvider.h"
#import "CallSupport.h"
#import "CallRecord.h"


@implementation UIViewController (ChatSupport)

- (void)presentChatControllerForUserContact:(UserContact *)contact animated:(BOOL)animated controllerProvider:(id<ControllerProvider>)controllerProvider{
    UIViewController<DirectChat>* chatViewController = [controllerProvider chatViewController];
    chatViewController.destinationContact = contact;
    UINavigationController *uiNavigationController = [[UINavigationController alloc] initWithRootViewController: chatViewController];
    [self presentViewController:uiNavigationController animated: animated completion:nil];
}

- (void)presentVideoChatControllerForUserContact:(UserContact *)contact animated:(BOOL)animated controllerProvider:(id<ControllerProvider>)controllerProvider{
    UIViewController<DirectChat, CallSupport>* chatViewController = [controllerProvider videoChatViewController];
    chatViewController.destinationContact = contact;
    UINavigationController *uiNavigationController = [[UINavigationController alloc] initWithRootViewController: chatViewController];
    [self presentViewController:uiNavigationController animated: animated completion:nil];
}

- (void)presentVideoChatControllerForCallRecord:(CallRecord*)callRecord animated:(BOOL)animated controllerProvider:(id<ControllerProvider>)controllerProvider{
    UIViewController<DirectChat, CallSupport>* chatViewController = [controllerProvider videoChatViewController];
    chatViewController.destinationContact = callRecord.userContact;
    chatViewController.callRecord = callRecord;
    UINavigationController *uiNavigationController = [[UINavigationController alloc] initWithRootViewController: chatViewController];

    UIViewController *topViewController = [self topViewController];

    [topViewController presentViewController:uiNavigationController animated: animated completion:nil];
}

@end