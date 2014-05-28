//
//  Created by grizzly on 1/3/14.
//


#import "ControllersAssembly.h"
#import "LoginViewController.h"
#import "ChatListViewController.h"
#import "AuthenticationControllerManagerImpl.h"
#import "TyphoonCollaboratingAssemblyProxy.h"
#import "ServicesAssembly.h"
#import "ChatViewController.h"
#import "VideoChatListViewController.h"
#import "ContactsViewController.h"
#import "SearchContactViewController.h"
#import "SettingsViewController.h"
#import "ContactPickerViewController.h"
#import "ContactDetailsViewController.h"
#import "VideoChatViewController.h"

#pragma GCC diagnostic ignored "-Wundeclared-selector"

@implementation ControllersAssembly {
}

- (void)resolveCollaboratingAssemblies
{
   _serviceComponents = (id) [TyphoonCollaboratingAssemblyProxy proxy];
}

- (id)chatViewController
{
   return [TyphoonDefinition withClass:[ChatViewController class] configuration:^(TyphoonDefinition *definition) {
      [definition injectProperty:@selector(userService) with:[_serviceComponents userService]];
      [definition injectProperty:@selector(chatService) with:[_serviceComponents chatService]];
      [definition injectProperty:@selector(applicationContextService) with:[_serviceComponents applicationContextService]];
   }];
}

- (id)chatListViewController
{
   return [TyphoonDefinition withClass:[ChatListViewController class] configuration:^(TyphoonDefinition *definition) {
      [definition injectProperty:@selector(userService) with:[_serviceComponents userService]];
      [definition injectProperty:@selector(chatService) with:[_serviceComponents chatService]];
      [definition injectProperty:@selector(controllerProvider) with:self];
      [definition setAfterInjections:@selector(setupSubscriptions)];
   }];
}

- (id)authenticationControllerManager
{
   return [TyphoonDefinition withClass:[AuthenticationControllerManagerImpl class] configuration:^(TyphoonDefinition *definition) {
      [definition injectProperty:@selector(applicationContextService) with:[_serviceComponents applicationContextService]];
      [definition injectProperty:@selector(userService) with:[_serviceComponents userService]];
      [definition injectProperty:@selector(controllerProvider) with:self];
      [definition setScope:TyphoonScopeSingleton];
   }];
}

- (id)videoChatViewController
{
   return [TyphoonDefinition withClass:[VideoChatViewController class] configuration:^(TyphoonDefinition *definition) {
      [definition injectProperty:@selector(chatService) with:[_serviceComponents chatService]];
      [definition injectProperty:@selector(applicationContextService) with:[_serviceComponents applicationContextService]];
   }];
}

- (id)searchContactViewController
{
   return [TyphoonDefinition withClass:[SearchContactViewController class] configuration:^(TyphoonDefinition *definition) {
      [definition injectProperty:@selector(userService) with:[_serviceComponents userService]];
      [definition injectProperty:@selector(chatService) with:[_serviceComponents chatService]];
   }];
}

- (id)loginViewController
{
   return [TyphoonDefinition withClass:[LoginViewController class] configuration:^(TyphoonDefinition *definition) {
      [definition injectProperty:@selector(userService) with:[_serviceComponents userService]];
      [definition injectProperty:@selector(controllerManager) with:[self authenticationControllerManager]];
      [definition injectProperty:@selector(applicationContextService) with:[_serviceComponents applicationContextService]];
   }];
}

- (id)registerUserViewController
{
   return [TyphoonDefinition withClass:[RegisterUserViewController class] configuration:^(TyphoonDefinition *definition) {
      [definition injectProperty:@selector(userService) with:[_serviceComponents userService]];
      [definition injectProperty:@selector(controllerManager) with:[self authenticationControllerManager]];
   }];
}


- (id)videoChatListViewController
{
   return [TyphoonDefinition withClass:[VideoChatListViewController class] configuration:^(TyphoonDefinition *definition) {
      [definition injectProperty:@selector(chatService) with:[_serviceComponents chatService]];
      [definition injectProperty:@selector(applicationContextService) with:[_serviceComponents applicationContextService]];
      [definition injectProperty:@selector(controllerProvider) with:self];
      [definition setAfterInjections:@selector(setupSubscriptions)];
   }];
}

- (id)contactsViewController
{
   return [TyphoonDefinition withClass:[ContactsViewController class] configuration:^(TyphoonDefinition *definition) {
      [definition injectProperty:@selector(userService) with:[_serviceComponents userService]];
      [definition injectProperty:@selector(chatService) with:[_serviceComponents chatService]];
      [definition injectProperty:@selector(controllerProvider) with:self];
   }];
}

- (id)contactPickerController
{
   return [TyphoonDefinition withClass:[ContactPickerViewController class] configuration:^(TyphoonDefinition *definition) {
      [definition injectProperty:@selector(userService) with:[_serviceComponents userService]];
      [definition injectProperty:@selector(chatService) with:[_serviceComponents chatService]];
   }];
}

- (id)settingsViewController
{
   return [TyphoonDefinition withClass:[SettingsViewController class] configuration:^(TyphoonDefinition *definition) {
      [definition injectProperty:@selector(userService) with:[_serviceComponents userService]];
      [definition injectProperty:@selector(applicationContextService) with:[_serviceComponents applicationContextService]];
      [definition injectProperty:@selector(controllerManager) with:[self authenticationControllerManager]];
   }];
}

- (id)contactDetailsViewController
{
   return [TyphoonDefinition withClass:[ContactDetailsViewController class] configuration:^(TyphoonDefinition *definition) {
      [definition injectProperty:@selector(controllerProvider) with:self];
   }];
}


@end