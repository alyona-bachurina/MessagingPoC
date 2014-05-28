#import "RegisterUserViewController.h"
#import "AuthenticationControllerManager.h"
#import "UserService.h"

@class TPKeyboardAvoidingScrollView;
@protocol UserService;


@interface RegisterUserViewController (_protected) <UITextFieldDelegate>
@property(nonatomic, strong) UITextField *txtUserName;
@property(nonatomic, strong) UILabel *lblUserName;
@property(nonatomic, strong) TPKeyboardAvoidingScrollView *scrollContainer;
@property(nonatomic, strong) UILabel *lblPassword;
@property(nonatomic, strong) UITextField *txtPassword;
@property(nonatomic, strong) UILabel *lblConfirmPassword;
@property(nonatomic, strong) UITextField *txtConfirmPassword;
@property(nonatomic, strong) UILabel *lblEmail;
@property(nonatomic, strong) UITextField *txtEmail;
@property(nonatomic, strong) UIButton *btnJoinUs;
@property(nonatomic) BOOL shouldGoToNext;
@property(nonatomic, strong) UIToolbar *keyBoardToolBar;

@property(nonatomic, strong) NSObject<UserService>* userService;
@property(nonatomic, strong) NSObject<AuthenticationControllerManager>* controllerManager;
@end