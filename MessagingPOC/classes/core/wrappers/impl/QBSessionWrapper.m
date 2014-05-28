//
//  Created by grizzly on 1/6/14.
//


#import "QBSessionWrapper.h"
#import "QBBaseWrapper+protected.h"

@implementation QBSessionWrapper {

}

- (id)init {
    self = [super init];
    if (self) {
        [self setupQuickBloxCredentials];
    }

    return self;
}


-(void)setupQuickBloxCredentials{

    [QBSettings setApplicationID:(NSUInteger) configValueNSInteger(@"qb.appdetails.applicationId")];
    [QBSettings setAuthorizationKey: configObject(@"qb.appdetails.authorizationKey")];
    [QBSettings setAuthorizationSecret: configObject(@"qb.appdetails.authorizationSecret")];
    [QBSettings setAccountKey:configObject(@"qb.appdetails.account.key")];

    #ifdef DEBUG
    [QBSettings setLogLevel:QBLogLevelDebug];
    #else
    [QBSettings setLogLevel:QBLogLevelNothing];
    #endif

    NSMutableDictionary *videoChatConfiguration = [[QBSettings videoChatConfiguration] mutableCopy];
    [videoChatConfiguration setObject:@20 forKey:kQBVideoChatCallTimeout];
    [videoChatConfiguration setObject:AVCaptureSessionPresetLow forKey:kQBVideoChatFrameQualityPreset];
    [videoChatConfiguration setObject:@2 forKey:kQBVideoChatVideoFramesPerSecond];
    [videoChatConfiguration setObject:@3 forKey:kQBVideoChatP2PTimeout];
    [QBSettings setVideoChatConfiguration:videoChatConfiguration];

}

- (void) startSessionWithCompleteBlock:(StartSessionCompleteBlock) completeBlock {

    NSString *blockId = [[NSProcessInfo processInfo] globallyUniqueString];

    [self.completeBlocks setObject: completeBlock forKey: blockId];

    NSObject<Cancelable>* cancellable = [QBAuth createSessionWithDelegate:self context: (__bridge void *)(blockId)];
    [self.cancelableOperations setObject: cancellable forKey: blockId];
}

- (void) startSessionWithLogin:(NSString*)login password:(NSString*) password completeBlock:(StartSessionCompleteBlock) completeBlock {

    NSString *blockId = [[NSProcessInfo processInfo] globallyUniqueString];

    [self.completeBlocks setObject: completeBlock forKey: blockId];

    QBASessionCreationRequest *extendedAuthRequest = [QBASessionCreationRequest request];
    extendedAuthRequest.userLogin = login;
    extendedAuthRequest.userPassword = password;

    NSObject<Cancelable>* cancellable = [QBAuth createSessionWithExtendedRequest:extendedAuthRequest delegate:self context: (__bridge void *) (blockId)];

    [self.cancelableOperations setObject: cancellable forKey: blockId];
}

- (void)completedWithResult:(Result *)result context:(void *)contextInfo {

    NSError *error = nil;

    if(result.success){
        DLog(@"Successfully created QB session.");
    }else{
       logErrorList(result.errors);
       error = [NSError errorWithDomain:ERROR_DOMAIN_SERVER_API code:ERROR_CODE_API_ERROR userInfo: @{NSLocalizedDescriptionKey: result.errors.lastObject} ];
    }

    NSString* blockId = (__bridge NSString *)(contextInfo);
    StartSessionCompleteBlock block = [self.completeBlocks objectForKey: blockId];


    block(error);

    [self.completeBlocks removeObjectForKey: blockId];
    [self.cancelableOperations removeObjectForKey: blockId];
}

- (void)destroySession:(StartSessionCompleteBlock)completeBlock {

    NSString *blockId = [[NSProcessInfo processInfo] globallyUniqueString];

    [self.completeBlocks setObject: completeBlock forKey: blockId];

    NSObject<Cancelable>* cancellable = [QBAuth destroySessionWithDelegate: self context: (__bridge void *) (blockId)];

    [self.cancelableOperations setObject: cancellable forKey: blockId];

}


@end