//
//  AppDelegate.m
//  MessagingPOC
//
//  Created by Alyona on 1/2/14.
//  Copyright (c) 2014 Waverley. All rights reserved.
//

#import <Typhoon/TyphoonBlockComponentFactory.h>
#import "AppDelegate.h"
#import "ControllersAssembly.h"
#import "CoreComponentsAssembly.h"
#import "ServicesAssembly.h"
#import "AuthenticationControllerManager.h"
#import "DataAccessAssembly.h"
#import "UserService.h"
#import "DataStore.h"

@interface AppDelegate ()
@property(nonatomic) id factory;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
   self.window.backgroundColor = [UIColor whiteColor];
   [self.window makeKeyAndVisible];

   self.factory = [TyphoonBlockComponentFactory factoryWithAssemblies:@[
         [ControllersAssembly assembly],
         [CoreComponentsAssembly assembly],
         [ServicesAssembly assembly],
         [DataAccessAssembly assembly]]];

   id<AuthenticationControllerManager> authManager = [self.factory authenticationControllerManager];
   [authManager doAutoLogin];
   return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
   [[self.factory userService] lockCurrentUser];
   [[self.factory dataStore] save];

   id<AuthenticationControllerManager> authManager = [self.factory authenticationControllerManager];
   [authManager presentSplashScreen];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
   id<AuthenticationControllerManager> authManager = [self.factory authenticationControllerManager];
   [authManager doAutoLogin];
}

- (void)applicationWillResignActive:(UIApplication *)application
{

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

}

- (void)applicationWillTerminate:(UIApplication *)application
{

}

@end
