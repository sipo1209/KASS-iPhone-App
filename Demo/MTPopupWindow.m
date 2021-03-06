//
//  MTPopupWindow.m
//  PopupWindowProject
//
//  Created by Marin Todorov on 7/1/11.
//  Copyright 2011 Marin Todorov. MIT license
//  http://www.opensource.org/licenses/mit-license.php
//

#import "MTPopupWindow.h"
#import "UIView+ViewController.h"
#import "SFHFKeychainUtils.h"
#import "ViewHelper.h"

#define kShadeViewTag 1000

@interface MTPopupWindow(Private)
- (id)initWithSuperview:(UIView*)sview andFile:(NSString*)fName;
- (UITextField *) getTextFieldByTag:(NSArray *)subviews tag:(NSInteger *)tag;
@end

@implementation MTPopupWindow
@synthesize bgView = _bgView;
@synthesize bigPanelView = _bigPanelView;
@synthesize signUpView = _signUpView;
@synthesize signInView = _signInView;
@synthesize mtWindow = _mtWindow;
@synthesize viewController = _viewController;
//@synthesize renren = _renren;

/**
 * This is a public class method, it opens a popup window and loads the given content
 * @param NSString* fileName provide a file name to load a file from the app resources, or a URL to load a web page
 * @param UIView* view provide a UIViewController's view here (or other view)
 */
+(void)showWindowWithHTMLFile:(NSString*)fileName insideView:(UIView*)view
{
  MTPopupWindow *window = [[MTPopupWindow alloc] initWithSuperview:view andFile:fileName];
  DLog(@"MTPopupWindow::showWindowWithHTMLFile:window=%@", window);
}

+(void)showWindowWithUIView:(UIView*)view
{
    [[MTPopupWindow alloc] initWithSuperview:view andFile:nil];
}

/**
 * Initializes the class instance, gets a view where the window will pop up in
 * and a file name/ URL
 */
- (id)initWithSuperview:(UIView*)sview andFile:(NSString*)fName
{
    self = [super init];
    if (self) {
      
      // Initialization code here.
      self.bgView = [[UIView alloc] initWithFrame: sview.bounds];
      [sview addSubview: self.bgView];
        
      
      self.viewController = (MainTabBarViewController *)[sview firstAvailableUIViewController];
      
      // retain the current mtWindow
      self.mtWindow = self;
      
        if (nil == fName) {
            [self performSelector:@selector(doTransitionWithCustomizeView) withObject:nil afterDelay:0.1];
        } else{
            // proceed with animation after the bgView was added
            [self performSelector:@selector(doTransitionWithContentFile:) withObject:fName afterDelay:0.1];
        }
    }
  
    DLog(@"MTPopupWindow::initWithSuperview:viewController=%@", _viewController);
    
    return self;
}

-(void)doTransitionWithCustomizeView
{
    //faux view
    UIView* fauxView = [[UIView alloc] initWithFrame: CGRectMake(10, 10, 200, 200)];
    [self.bgView addSubview: fauxView];
    
    //the new panel
    self.bigPanelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bgView.frame.size.width, self.bgView.frame.size.height)];
    self.bigPanelView.center = CGPointMake( self.bgView.frame.size.width/2, self.bgView.frame.size.height/2);
    
    //add the window background
    UIImageView* background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:UI_IMAGE_LOGIN_BACKGROUND]];
    //background.center = CGPointMake(self.bigPanelView.frame.size.width/2, self.bigPanelView.frame.size.height/2 - 20);
    background.frame = CGRectMake((self.bgView.frame.size.width - background.frame.size.width)/2, 30, background.frame.size.width, background.frame.size.height);
    [self.bigPanelView addSubview: background];
    
    //add the close button
    int closeBtnOffset = 10;
    UIImage* closeBtnImg = [UIImage imageNamed:@"popupCloseBtn.png"];
    UIButton* closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:closeBtnImg forState:UIControlStateNormal];
    [closeBtn setFrame:CGRectMake( background.frame.origin.x + background.frame.size.width - closeBtnImg.size.width - closeBtnOffset, 
                                  background.frame.origin.y ,
                                  closeBtnImg.size.width + closeBtnOffset, 
                                  closeBtnImg.size.height + closeBtnOffset)];
    
    [closeBtn addTarget:self action:@selector(closePopupWindow) forControlEvents:UIControlEventTouchUpInside];
    [self.bigPanelView addSubview: closeBtn];
    
  
  UIImage* renrenButtonImg = [UIImage imageNamed:UI_IMAGE_RENREN_BUTTON];
  UIImage* renrenButtonPressImg = [UIImage imageNamed:UI_IMAGE_RENREN_BUTTON_PRESS];
  UIButton* renrenButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [renrenButton setImage:renrenButtonImg forState:UIControlStateNormal];
  [renrenButton setImage:renrenButtonPressImg forState:UIControlStateHighlighted];
  renrenButton.frame = CGRectMake((self.bigPanelView.frame.size.width - renrenButtonImg.size.width*2) / 2 + 136, 130.0, renrenButtonImg.size.width, renrenButtonImg.size.height);
  [renrenButton addTarget:self action:@selector(loginWithRenren) forControlEvents:UIControlEventTouchUpInside];
  [self.bigPanelView addSubview:renrenButton];
  
  
  UIImage* twitterButtonImg = [UIImage imageNamed:UI_IMAGE_WEIBO_BUTTON];
  UIImage* twitterButtonPressImg = [UIImage imageNamed:UI_IMAGE_WEIBO_BUTTON_PRESS];
    UIButton* twitterButton = [UIButton buttonWithType:UIButtonTypeCustom];
  [twitterButton setImage:twitterButtonImg forState:UIControlStateNormal];
  [twitterButton setImage:twitterButtonPressImg forState:UIControlStateHighlighted];
    twitterButton.frame = CGRectMake((self.bigPanelView.frame.size.width - twitterButtonImg.size.width*2) / 2 - 4, 130.0, twitterButtonImg.size.width, twitterButtonImg.size.height);
    [twitterButton addTarget:self action:@selector(loginWithWeibo) forControlEvents:UIControlEventTouchUpInside];
    [self.bigPanelView addSubview:twitterButton];
  

  
    UIImage* signUpButtonImg = [UIImage imageNamed:UI_IMAGE_SIGNUP_BUTTON];
    UIImage* signUpButtonPressImg = [UIImage imageNamed:UI_IMAGE_SIGNUP_BUTTON_PRESS];
    UIButton* signUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [signUpButton setImage:signUpButtonImg forState:UIControlStateNormal];
    [signUpButton setImage:signUpButtonPressImg forState:UIControlStateHighlighted];
    signUpButton.frame = CGRectMake(45.0, 280.0, signUpButtonImg.size.width, signUpButtonImg.size.height);
    [signUpButton addTarget:self action:@selector(toSignUpViewAction) forControlEvents:UIControlEventTouchUpInside];
    [self.bigPanelView addSubview:signUpButton];
    
    UIImage* signInButtonImg = [UIImage imageNamed:UI_IMAGE_SIGNIN_BUTTON];
    UIImage* signInButtonPressImg = [UIImage imageNamed:UI_IMAGE_SIGNIN_BUTTON_PRESS];
    UIButton* signInButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [signInButton setImage:signInButtonImg forState:UIControlStateNormal];
    [signInButton setImage:signInButtonPressImg forState:UIControlStateHighlighted];
    signInButton.frame = CGRectMake(170.0, 280.0, signUpButtonImg.size.width, signUpButtonImg.size.height);
    [signInButton addTarget:self action:@selector(toSignInViewAction) forControlEvents:UIControlEventTouchUpInside];
    [self.bigPanelView addSubview:signInButton];
    
    UIImage* startImg = [UIImage imageNamed:UI_IMAGE_LOGIN_SKIP_TEXT];
    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [startButton setImage:startImg forState:UIControlStateNormal];
    startButton.frame = CGRectMake((self.bigPanelView.frame.size.width - startImg.size.width) / 2, 360.0, startImg.size.width, startImg.size.height);
    [startButton addTarget:self action:@selector(startButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.bigPanelView addSubview:startButton];   
    
    //animation options
    UIViewAnimationOptions options = UIViewAnimationOptionTransitionFlipFromRight |
    UIViewAnimationOptionAllowUserInteraction    |
    UIViewAnimationOptionBeginFromCurrentState;
    
    //run the animation
    [UIView transitionFromView:fauxView toView:self.bigPanelView duration:0.5 options:options completion: ^(BOOL finished) {
        
        //dim the contents behind the popup window
        UIView* shadeView = [[UIView alloc] initWithFrame:self.bigPanelView.frame];
        shadeView.backgroundColor = [UIColor blackColor];
        shadeView.alpha = 0.3;
        shadeView.tag = kShadeViewTag;
        [self.bigPanelView addSubview: shadeView];
        [self.bigPanelView sendSubviewToBack: shadeView];
    }];    
}

/**
 * Afrer the window background is added to the UI the window can animate in
 * and load the UIWebView
 */
-(void)doTransitionWithContentFile:(NSString*)fName
{
    //faux view
    UIView* fauxView = [[UIView alloc] initWithFrame: CGRectMake(10, 10, 200, 200)];
    [self.bgView addSubview: fauxView];

    //the new panel
    self.bigPanelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bgView.frame.size.width, self.bgView.frame.size.height)];
    self.bigPanelView.center = CGPointMake( self.bgView.frame.size.width/2, self.bgView.frame.size.height/2);
    
    //add the window background
    UIImageView* background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popupWindowBack.png"]];
    //UIImageView* background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login.png"]];
    background.center = CGPointMake(self.bigPanelView.frame.size.width/2, self.bigPanelView.frame.size.height/2);
    [self.bigPanelView addSubview: background];
    
    //add the web view
    int webOffset = 10;
    UIWebView* web = [[UIWebView alloc] initWithFrame:CGRectInset(background.frame, webOffset, webOffset)];
    web.backgroundColor = [UIColor clearColor];
    
    if ([fName hasPrefix:@"http"]) {
        //load a web page
        web.scalesPageToFit = YES;
        [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString: fName]]];
    } else {
        //load a local file
        NSError* error = nil;
        NSString* fileContents = [NSString stringWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:fName] encoding:NSUTF8StringEncoding error: &error];
        if (error!=NULL) {
            NSLog(@"error loading %@: %@", fName, [error localizedDescription]);
        } else {
            [web loadHTMLString: fileContents baseURL:[NSURL URLWithString:@"file://"]];
        }
    }
    
    [self.bigPanelView addSubview: web];
    
    //animation options
    UIViewAnimationOptions options = UIViewAnimationOptionTransitionFlipFromRight |
                                        UIViewAnimationOptionAllowUserInteraction    |
                                        UIViewAnimationOptionBeginFromCurrentState;
    
    //run the animation
    [UIView transitionFromView:fauxView toView:self.bigPanelView duration:0.5 options:options completion: ^(BOOL finished) {
        
        //dim the contents behind the popup window
        UIView* shadeView = [[UIView alloc] initWithFrame:self.bigPanelView.frame];
        shadeView.backgroundColor = [UIColor blackColor];
        shadeView.alpha = 0.3;
        shadeView.tag = kShadeViewTag;
        [self.bigPanelView addSubview: shadeView];
        [self.bigPanelView sendSubviewToBack: shadeView];
    }];
}

/**
 * Login with Weibo trigger function
 */
-(void)loginWithWeibo
{
  NSLog(@"MTPopupWindow::loginWithWeibo");
  [[VariableStore sharedInstance] signInWeibo];
  [[self.bigPanelView viewWithTag: kShadeViewTag] removeFromSuperview];    
  [self performSelector:@selector(closePopupWindowAnimate) withObject:nil afterDelay:0.1];
}

-(void)loginWithRenren
{
  NSLog(@"MTPopupWindow::loginWithRenren");
  [[VariableStore sharedInstance] signInRenren];
  [[self.bigPanelView viewWithTag: kShadeViewTag] removeFromSuperview];    
  [self performSelector:@selector(closePopupWindowAnimate) withObject:nil afterDelay:0.1];
}

/**
 * Open signup view
 */
-(void)toSignUpViewAction
{
    DLog(@"Openning sign up view");
    //faux view
    self.signUpView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.bgView.frame.size.width, self.bgView.frame.size.height)];
    self.signUpView.center = CGPointMake( self.bgView.frame.size.width/2, self.bgView.frame.size.height/2);
    
    //add the window background
    UIImageView* background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:UI_IMAGE_LOGIN_FORM_BACKGROUND]];
    //UIImageView* background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login.png"]];
    background.center = CGPointMake(self.signUpView.frame.size.width/2, self.signUpView.frame.size.height/2 - 30);
    [self.signUpView addSubview: background];    
    
    UIImage* signUpButtonImg = [UIImage imageNamed:UI_IMAGE_SIGNUP_BUTTON2];
    UIImage* signUpButtonPressImg = [UIImage imageNamed:UI_IMAGE_SIGNUP_BUTTON_PRESS2];
    UIButton* signUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [signUpButton setImage:signUpButtonImg forState:UIControlStateNormal];
    [signUpButton setImage:signUpButtonPressImg forState:UIControlStateHighlighted];
    signUpButton.frame = CGRectMake(235, 50, signUpButtonImg.size.width, signUpButtonImg.size.height);
    [signUpButton addTarget:self action:@selector(signUpSubmitAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.signUpView addSubview:signUpButton];
  
    UIImage* backButtonImg = [UIImage imageNamed:UI_IMAGE_LOGIN_BACK_BUTTON];
    UIImage* backButtonPressImg = [UIImage imageNamed:UI_IMAGE_LOGIN_BACK_BUTTON_PRESS];
    UIButton* backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:backButtonImg forState:UIControlStateNormal];
    [backButton setImage:backButtonPressImg forState:UIControlStateHighlighted];
    backButton.frame = CGRectMake(25,50, backButtonImg.size.width, backButtonImg.size.height);
    [backButton addTarget:self action:@selector(signUpBackButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.signUpView addSubview:backButton];
    
    UITextField *nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, 95, 260, 40)];
    nameTextField.placeholder = @"姓名";
    nameTextField.borderStyle = UITextBorderStyleRoundedRect;
    nameTextField.keyboardType = UIKeyboardTypeDefault;
    nameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    nameTextField.returnKeyType = UIReturnKeyNext;
    nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    nameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter; 
    nameTextField.tag = 1;
    nameTextField.delegate = self;
    [self.signUpView addSubview:nameTextField];
    
    UITextField *emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, 135, 260, 40)];
    emailTextField.placeholder = @"邮箱";
    emailTextField.borderStyle = UITextBorderStyleRoundedRect;
    emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    emailTextField.returnKeyType = UIReturnKeyNext;
    emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    emailTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter; 
    emailTextField.tag = 2;
    emailTextField.delegate = self;
    [self.signUpView addSubview:emailTextField];
    
    UITextField *phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, 175, 260, 40)];
    phoneTextField.placeholder = @"手机";
    phoneTextField.borderStyle = UITextBorderStyleRoundedRect;
    phoneTextField.keyboardType = UIKeyboardTypePhonePad;
    phoneTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    phoneTextField.returnKeyType = UIReturnKeyNext;
    phoneTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    phoneTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter; 
    phoneTextField.tag = 3;
    phoneTextField.delegate = self;
    [self.signUpView addSubview:phoneTextField];
    
    UITextField *passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, 215, 260, 40)];
    passwordTextField.placeholder = @"密码";
    passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
    passwordTextField.keyboardType = UIKeyboardTypeDefault;
    passwordTextField.secureTextEntry = YES;
    passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter; 
    passwordTextField.returnKeyType = UIReturnKeyDone;
    passwordTextField.tag = 4;
    passwordTextField.delegate = self;
    [self.signUpView addSubview:passwordTextField];
    //animation options
    UIViewAnimationOptions options = UIViewAnimationOptionTransitionFlipFromRight |
    UIViewAnimationOptionAllowUserInteraction    |
    UIViewAnimationOptionBeginFromCurrentState;
    
    //run the animation
    [UIView transitionFromView:self.bigPanelView toView:self.signUpView duration:0.5 options:options completion: ^(BOOL finished) {
        
        //dim the contents behind the popup window
        UIView* shadeView = [[UIView alloc] initWithFrame:self.signUpView.frame];
        shadeView.backgroundColor = [UIColor blackColor];
        shadeView.alpha = 0.3;
        shadeView.tag = kShadeViewTag;
        [self.signUpView addSubview: shadeView];
        [self.signUpView sendSubviewToBack: shadeView];
    }];
    
    [nameTextField becomeFirstResponder];
}

-(void)signUpBackButtonAction
{
    //animation options
    UIViewAnimationOptions options = UIViewAnimationOptionTransitionFlipFromRight |
    UIViewAnimationOptionAllowUserInteraction    |
    UIViewAnimationOptionBeginFromCurrentState;
    
    //run the animation
    [UIView transitionFromView:self.signUpView toView:self.bigPanelView duration:0.5 options:options completion:nil];
}

-(void)signInBackButtonAction
{
    //animation options
    UIViewAnimationOptions options = UIViewAnimationOptionTransitionFlipFromRight |
    UIViewAnimationOptionAllowUserInteraction    |
    UIViewAnimationOptionBeginFromCurrentState;
    
    //run the animation
    [UIView transitionFromView:self.signInView toView:self.bigPanelView duration:0.5 options:options completion:nil];
}

-(void)signUpSubmitAction:(UIButton*)sender
{
    NSString *name = nil;
    NSString *email = nil;
    NSString *phone = nil;
    NSString *password = nil;
    for (UIView *view in sender.superview.subviews) {
        if ([view isKindOfClass:[UITextField class]] && view.tag == 1) {
            name = [((UITextField *)view) text];
        } else if ([view isKindOfClass:[UITextField class]] && view.tag == 2) {
            email = [((UITextField *)view) text];
        } else if ([view isKindOfClass:[UITextField class]] && view.tag == 3) {
            phone = [((UITextField *)view) text];
        } else if ([view isKindOfClass:[UITextField class]] && view.tag == 4) {
            password = [((UITextField *)view) text];
        } 
    }
    NSLog(@"Sign Up Info: %@ \n %@ \n %@ \n %@", name, email, phone, password);
    
    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:name,@"name",email,@"email",
                              password, @"password", phone, @"phone", nil];
  
  if (!email || !password || !name) {
    [ViewHelper showErrorAlert:@"用户信息不正确" :self];
  }else if (![User isEmailValid:email]) {
    [ViewHelper showErrorAlert:@"Email不正确":self];
  }else if (![User isNameValid:name]) {
    [ViewHelper showErrorAlert:@"用户名不正确":self];
  }else if (![User isPhoneValid:phone]) {
    [ViewHelper showErrorAlert:@"手机不正确":self];
  }else{
    [[VariableStore sharedInstance] signUpAccount:userInfo];
    [[self.bigPanelView viewWithTag: kShadeViewTag] removeFromSuperview];    
    [self performSelector:@selector(closePopupWindowAnimate) withObject:nil afterDelay:0.1];
  }
}

-(void)signInSubmitAction:(UIButton*)sender
{
    NSString *email = nil;
    NSString *password = nil;
    for (UIView *view in sender.superview.subviews) {
        if ([view isKindOfClass:[UITextField class]] && view.tag == 5) {
            email = [((UITextField *)view) text];
        } else if ([view isKindOfClass:[UITextField class]] && view.tag == 6) {
            password = [((UITextField *)view) text];
        } 
    }
  
    if (!email || !password) {
      [ViewHelper showErrorAlert:@"请填写完整信息":self];
      return;
    }
  
    NSLog(@"MTPopupWindow::signInSubmitAction: %@ \n %@", email, password);
    
    //TODO - Validation
    [[VariableStore sharedInstance] signInAccount:email:password];
  
    [[self.bigPanelView viewWithTag: kShadeViewTag] removeFromSuperview];    
    [self performSelector:@selector(closePopupWindowAnimate) withObject:nil afterDelay:0.1];
}

/**
 * Open signin view
 */
-(void)toSignInViewAction
{
    DLog(@"Openning sign in view");
    //faux view
    self.signInView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.bgView.frame.size.width, self.bgView.frame.size.height)];
    self.signInView.center = CGPointMake( self.bgView.frame.size.width/2, self.bgView.frame.size.height/2 - 30);
    
    //add the window background
    UIImageView* background = [[UIImageView alloc] initWithImage:[UIImage imageNamed:UI_IMAGE_LOGIN_FORM_BACKGROUND]];
    background.center = CGPointMake(self.signInView.frame.size.width/2, self.signInView.frame.size.height/2);
    [self.signInView addSubview: background];    
    
    UIImage* forgotPasswordImg = [UIImage imageNamed:UI_IMAGE_LOGIN_FORGOT_PASS];
    UIButton* forgotPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [forgotPasswordButton setImage:forgotPasswordImg forState:UIControlStateNormal];
    forgotPasswordButton.frame = CGRectMake((self.signInView.frame.size.width - forgotPasswordImg.size.width)/2, 265, forgotPasswordImg.size.width, forgotPasswordImg.size.height);
    [forgotPasswordButton addTarget:self action:@selector(forgotPasswordAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.signInView addSubview:forgotPasswordButton];
    
    UIImage* signInButtonImg = [UIImage imageNamed:UI_IMAGE_LOGIN_BUTTON];
    UIImage* signInButtonPressImg = [UIImage imageNamed:UI_IMAGE_LOGIN_BUTTON_PRESS];
    UIButton* signInButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [signInButton setImage:signInButtonImg forState:UIControlStateNormal];
    [signInButton setImage:signInButtonPressImg forState:UIControlStateHighlighted];
    signInButton.frame = CGRectMake(235, 80, signInButtonImg.size.width, signInButtonImg.size.height);
    [signInButton addTarget:self action:@selector(signInSubmitAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.signInView addSubview:signInButton];
    
    UIImage* backButtonImg = [UIImage imageNamed:UI_IMAGE_LOGIN_BACK_BUTTON];
    UIImage* backButtonPressImg = [UIImage imageNamed:UI_IMAGE_LOGIN_BACK_BUTTON_PRESS];
    UIButton* backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:backButtonImg forState:UIControlStateNormal];
    [backButton setImage:backButtonPressImg forState:UIControlStateHighlighted];
    backButton.frame = CGRectMake(25, 80, backButtonImg.size.width, backButtonImg.size.height);
    [backButton addTarget:self action:@selector(signInBackButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.signInView addSubview:backButton];
    
    UITextField *emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, 150, 260, 40)];
    emailTextField.placeholder = @"邮箱";
    emailTextField.borderStyle = UITextBorderStyleRoundedRect;
    emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    emailTextField.returnKeyType = UIReturnKeyNext;
    emailTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    emailTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter; 
    emailTextField.tag = 5;
    emailTextField.delegate = self;
    [self.signInView addSubview:emailTextField];
    
    
    UITextField *passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, 200, 260, 40)];
    passwordTextField.placeholder = @"密码";
    passwordTextField.borderStyle = UITextBorderStyleRoundedRect;
    passwordTextField.keyboardType = UIKeyboardTypeDefault;
    passwordTextField.secureTextEntry = YES;
    passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter; 
    passwordTextField.returnKeyType = UIReturnKeyDone;
    passwordTextField.tag = 6;
    passwordTextField.delegate = self;
    [self.signInView addSubview:passwordTextField];
    //animation options
    UIViewAnimationOptions options = UIViewAnimationOptionTransitionFlipFromRight |
    UIViewAnimationOptionAllowUserInteraction    |
    UIViewAnimationOptionBeginFromCurrentState;
  
    //load keychain info
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    NSString *email = [standardDefaults stringForKey:KassAppEmailKey];
  
    if (email) {
      emailTextField.text = email;
      NSError *error = nil;
      NSString *pasword = [SFHFKeychainUtils getPasswordForUsername:email andServiceName:KassServiceName error:&error];
      passwordTextField.text = pasword;
    }
    
    //run the animation
    [UIView transitionFromView:self.bigPanelView toView:self.signInView duration:0.5 options:options completion: ^(BOOL finished) {
        
        //dim the contents behind the popup window
        UIView* shadeView = [[UIView alloc] initWithFrame:self.signInView.frame];
        shadeView.backgroundColor = [UIColor blackColor];
        shadeView.alpha = 0.3;
        shadeView.tag = kShadeViewTag;
        [self.signInView addSubview: shadeView];
        [self.signInView sendSubviewToBack: shadeView];
    }];
    
    [emailTextField becomeFirstResponder];
}

/**
 * Removes the window background and calls the animation of the window
 */
-(void)closePopupWindow
{
    NSLog(@"in closePopupWindow");
    //remove the shade
    [[self.bigPanelView viewWithTag: kShadeViewTag] removeFromSuperview];    
    [self performSelector:@selector(closePopupWindowAnimate) withObject:nil afterDelay:0.1];
}

-(void)startButtonAction
{
    NSLog(@"Tap me");
    //remove the shade
    [[self.bigPanelView viewWithTag: kShadeViewTag] removeFromSuperview];    
    [self performSelector:@selector(closePopupWindowAnimate) withObject:nil afterDelay:0.1];
}

/**
 * Animates the window and when done removes all views from the view hierarchy
 * since they are all only retained by their superview this also deallocates them
 * finally deallocate the class instance
 */
-(void)closePopupWindowAnimate
{
    
    //faux view
    __block UIView* fauxView = [[UIView alloc] initWithFrame: CGRectMake(10, 10, 200, 200)];
    [self.bgView addSubview: fauxView];

    //run the animation
    UIViewAnimationOptions options = UIViewAnimationOptionTransitionFlipFromLeft |
    UIViewAnimationOptionAllowUserInteraction    |
    UIViewAnimationOptionBeginFromCurrentState;
    
    //hold to the bigPanelView, because it'll be removed during the animation
    //[bigPanelView retain];
    
    [UIView transitionFromView:self.bigPanelView toView:fauxView duration:0.5 options:options completion:^(BOOL finished) {

        //when popup is closed, remove all the views
        for (UIView* child in self.bigPanelView.subviews) {
            [child removeFromSuperview];
        }
        for (UIView* child in self.bgView.subviews) {
            [child removeFromSuperview];
        }
        //[bigPanelView release];
        [self.bgView removeFromSuperview];
        
        //[self release];
    }];
}

- (UITextField *) getTextFieldByTag:(NSArray *)subviews 
                                tag:(NSInteger *)tag
{
    for (UIView *textField in subviews) {
        if ([textField isKindOfClass:[UITextField class]] && (NSInteger *)textField.tag == tag ) {
            return (UITextField *)textField;
        }
    }
    return nil;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{
    if ([self.signUpView.subviews containsObject:textField]) {
        if (textField.tag == 1) {
            [textField resignFirstResponder];
            UITextField *nextTextField = [self getTextFieldByTag:textField.superview.subviews tag:(NSInteger *)2];
            if (nextTextField) {
                [nextTextField becomeFirstResponder];
            }
        } else if (textField.tag == 2) {
            [textField resignFirstResponder];
            UITextField *nextTextField = [self getTextFieldByTag:textField.superview.subviews tag:(NSInteger *)3];
            if (nextTextField) {
                [nextTextField becomeFirstResponder];
            }            
        } else if (textField.tag == 3) {
            [textField resignFirstResponder];
            UITextField *nextTextField = [self getTextFieldByTag:textField.superview.subviews tag:(NSInteger *)4];
            if (nextTextField) {
                [nextTextField becomeFirstResponder];
            }             
        } else if (textField.tag == 4) {
            // TODO
            [[self.bigPanelView viewWithTag: kShadeViewTag] removeFromSuperview];    
            [self performSelector:@selector(closePopupWindowAnimate) withObject:nil afterDelay:0.1];
        } 
    } else if ([self.signInView.subviews containsObject:textField]) {
        if (textField.tag == 5) {
            [textField resignFirstResponder];
            UITextField *nextTextField = [self getTextFieldByTag:textField.superview.subviews tag:(NSInteger *)6];
            if (nextTextField) {
                [nextTextField becomeFirstResponder];
            }   
        }

    }
    
    return YES;
}

@end