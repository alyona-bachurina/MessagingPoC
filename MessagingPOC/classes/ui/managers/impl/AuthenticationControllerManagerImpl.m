//
//  Created by grizzly on 1/3/14.
//


#import "AuthenticationControllerManagerImpl.h"
#import "ApplicationContextService.h"
#import "ApplicationContext.h"
#import "TyphoonAssembly.h"
#import "ControllersAssembly.h"
#import "User.h"
#import "SplashViewController.h"
#import "UserService.h"


@interface AuthenticationControllerManagerImpl ()
@property(nonatomic, strong) NSObject <ApplicationContextService> *applicationContextService;
@property(nonatomic, strong) NSObject <UserService> *userService;
@property(nonatomic, strong) NSObject <ControllerProvider> *controllerProvider;
@end

@implementation AuthenticationControllerManagerImpl {

}

- (void)dealloc
{
   _applicationContextService = nil;
   _userService = nil;
   _controllerProvider = nil;
}


- (void)presentSplashScreen
{
   UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
   window.rootViewController = [[SplashViewController alloc] init];
}

- (void)doAutoLogin
{

   [self presentSplashScreen];

   double delayInSeconds = configValueFloat(@"splash.screen.timeout");
   dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t) (delayInSeconds * NSEC_PER_SEC));
   __weak typeof (self) weakSelf = self;
   dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
      [weakSelf tryAutoLogin];
   });
}

- (void)resolveAndPresentTopLevelViewController
{
   ApplicationContext *applicationContext = [self.applicationContextService getApplicationContext];
   AuthState authState = (AuthState) applicationContext.authState.intValue;
   UIViewController *result = nil;
   switch (authState) {
      case AUTH_FIRST_START:
      case AUTH_LOGGED_OUT:
      case AUTH_LOCKED: {
         result = [self prepareUnauthorizedUI];
         break;
      }
      case AUTH_LOGGED_IN: {

         result = [self prepareAuthorizedUI];

         break;
      }
   }
   UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
   window.rootViewController = result;
}

- (UIViewController *)prepareAuthorizedUI
{
   UIViewController *result;
   UIViewController *chat = [self.controllerProvider chatListViewController];
   chat.tabBarItem.image = [UIImage imageNamed:@"chat"];

   UIViewController *video = [self.controllerProvider videoChatListViewController];
   video.tabBarItem.image = [UIImage imageNamed:@"videochat"];

   UIViewController *contacts = [self.controllerProvider contactsViewController];
   contacts.tabBarItem.image = [UIImage imageNamed:@"contacts"];

   UIViewController *settings = [self.controllerProvider settingsViewController];
   settings.tabBarItem.image = [UIImage imageNamed:@"gear"];

   UITabBarController *tabBarController = [[UITabBarController alloc] init];
   [tabBarController setViewControllers:@[
         [[UINavigationController alloc] initWithRootViewController:chat],
         [[UINavigationController alloc] initWithRootViewController:video],
         [[UINavigationController alloc] initWithRootViewController:contacts],
         [[UINavigationController alloc] initWithRootViewController:settings]

   ] animated:NO];

   result = tabBarController;
   return result;
}

- (UIViewController *)prepareUnauthorizedUI
{
   UIViewController *result;
   UIViewController *first = [self.controllerProvider registerUserViewController];
   first.tabBarItem.image = [UIImage imageNamed:@"signup"];

   UIViewController *second = [self.controllerProvider loginViewController];
   second.tabBarItem.image = [UIImage imageNamed:@"key"];

   UITabBarController *tabBarController = [[UITabBarController alloc] init];
   [tabBarController setViewControllers:@[
         [[UINavigationController alloc] initWithRootViewController:first],
         [[UINavigationController alloc] initWithRootViewController:second]
   ] animated:NO];

   result = tabBarController;
   return result;
}

- (void)tryAutoLogin
{
   ApplicationContext *applicationContext = [self.applicationContextService getApplicationContext];
   if ([applicationContext isLocked] || [applicationContext isLoggedIn]) {

      UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
      SplashViewController *splash = (SplashViewController *) window.rootViewController;

      [splash startAnimatingWithMessage:NSLocalizedString(@"message.trying.autologin", nil)];
      __weak typeof (self) weakSelf = self;
      [self.userService loginWithUserName:applicationContext.currentUser.login password:applicationContext.password successBlock:^() {
         [weakSelf resolveAndPresentTopLevelViewController];
      } failBlock:^(NSError *error) {
         [weakSelf.userService logoutCurrentUser];
         [weakSelf resolveAndPresentTopLevelViewController];
      }];
   } else {
      [self resolveAndPresentTopLevelViewController];
   }
}


@end