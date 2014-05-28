//
//  Created by grizzly on 1/9/14.
//


#import <Foundation/Foundation.h>

@protocol ControllerProvider <NSObject>
- (id)loginViewController;

- (id)registerUserViewController;

- (id)chatListViewController;

- (id)chatViewController;

- (id)videoChatListViewController;

- (id)videoChatViewController;

- (id)contactsViewController;

- (id)searchContactViewController;

- (id)contactPickerController;

- (id)settingsViewController;

- (id)contactDetailsViewController;

- (id)authenticationControllerManager;
@end