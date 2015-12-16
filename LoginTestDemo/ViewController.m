//
//  ViewController.m
//  LoginTestDemo
//
//  Created by Csx on 15/12/16.
//  Copyright © 2015年 Wise Sight. All rights reserved.
//

#import "ViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ViewController ()<UITextFieldDelegate>
{
    UITextField * phoneTF;
    UITextField * passwordTF;
    UIButton * messageBtn;
    UIButton * confirmBtn;
    CGFloat width;
    CGFloat height;
    NSTimer *timer;//控制验证码倒计时的定时器
    int seconds;//记录倒计时的秒数
    UIActivityIndicatorView* indicatorView;//转圈的标志
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"登录";
    self.view.backgroundColor=UIColorFromRGB(0xfff1f6);
    self.navigationController.navigationBar.backgroundColor = [UIColor cyanColor];
    width = self.view.frame.size.width;
    height= self.view.frame.size.height;
    
    phoneTF = [[UITextField alloc]initWithFrame:CGRectMake((width-200)/2, 100, 200, 40)];
    phoneTF.delegate = self;
    phoneTF.placeholder = @"请输入手机号";
    [phoneTF setValue:UIColorFromRGB(0xd5d5d5) forKeyPath:@"_placeholderLabel.textColor"];
    [phoneTF setValue:[UIFont boldSystemFontOfSize:15] forKeyPath:@"_placeholderLabel.font"];
    phoneTF.borderStyle = UITextBorderStyleLine;
    phoneTF.backgroundColor = [UIColor grayColor];
    phoneTF.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:phoneTF];
    
    passwordTF =[[UITextField alloc]initWithFrame:CGRectMake((width-200)/2, 160, 100, 40)];
    passwordTF.delegate = self;
    passwordTF.placeholder = @"请输入验证码";
    [passwordTF setValue:UIColorFromRGB(0xdddddd) forKeyPath:@"_placeholderLabel.textColor"];
    [passwordTF setValue:[UIFont boldSystemFontOfSize:15] forKeyPath:@"_placeholderLabel.font"];
//    passwordTF.secureTextEntry = YES;
    passwordTF.keyboardType = UIKeyboardTypeNumberPad;
    passwordTF.borderStyle = UITextBorderStyleLine;
    passwordTF.backgroundColor = [UIColor grayColor];
    [self.view addSubview:passwordTF];
    
    messageBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    messageBtn.frame = CGRectMake((width-200)/2+120, 160, 80, 40);
    [messageBtn addTarget:self action:@selector(messageBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [messageBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [messageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    messageBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    messageBtn.backgroundColor = [UIColor blueColor];
    [self.view addSubview:messageBtn];
    
    confirmBtn=[UIButton buttonWithType:UIButtonTypeSystem];
    confirmBtn.frame = CGRectMake((width-200)/2, 220, 200, 40);
    [confirmBtn setTitle:@"确  认" forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmBtn.backgroundColor = [UIColor blueColor];
    [confirmBtn addTarget:self action:@selector(confirmBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmBtn];
    //转圈的标志
    indicatorView =[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicatorView.hidesWhenStopped =YES;
    indicatorView.color=[UIColor blackColor];
    indicatorView.center =self.view.center;
    [self.view addSubview:indicatorView];
    
}
//手机号码验证是否合法
-(BOOL)isValidateMobile:(NSString *)mobile
{
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    
    return [phoneTest evaluateWithObject:mobile];
}
//点击获取验证码按钮时判断输入的格式是否正确
- (BOOL)ecurityCodeSuccess{
    if ([phoneTF.text isEqualToString:@""]) {
        [phoneTF becomeFirstResponder];
        NSLog(@"--您还未输入的手机号--");
        return NO;
    }
    if (![self isValidateMobile:phoneTF.text]) {
        [phoneTF becomeFirstResponder];
        NSLog(@"--您输入的手机号格式有误--");
        return NO;
    }
    return YES;
}

//点击获取验证码按钮调用的函数
- (void)messageBtnClicked
{
    if ([self ecurityCodeSuccess] == NO) {
        return;
    }
    if ([indicatorView isAnimating]) {
        return;
    }
    [indicatorView startAnimating];
    
    seconds=60;
    [messageBtn setTitle:[NSString stringWithFormat:@"(%d)",seconds] forState:UIControlStateNormal];
    messageBtn.backgroundColor = [UIColor lightGrayColor];
    messageBtn.userInteractionEnabled=NO;
    [timer invalidate];
    timer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeFire:) userInfo:nil repeats:YES];
    [NSThread detachNewThreadSelector:@selector(getAuthCodeRequest) toTarget:self withObject:nil];
}
-(void)timeFire:(NSTimer *)theTimer{
    if(seconds <= 0){
        messageBtn.backgroundColor = [UIColor blueColor];
        messageBtn.userInteractionEnabled=YES;
        [timer setFireDate:[NSDate distantFuture]];
        [messageBtn setTitle:@"重发验证码" forState:UIControlStateNormal];
    }else{
        messageBtn.adjustsImageWhenHighlighted=NO;
        messageBtn.backgroundColor = [UIColor lightGrayColor];
        [messageBtn setTitle:[NSString stringWithFormat:@"(%d)",seconds] forState:UIControlStateNormal];
    }
    seconds--;
}
-(void)getAuthCodeRequest
{
    [indicatorView stopAnimating];
    [indicatorView removeFromSuperview];
    NSLog(@"网络请求验证码");
}

- (BOOL)registerSuccess{
    if ([phoneTF.text isEqualToString:@""]) {
        [phoneTF becomeFirstResponder];
        return NO;
    }
    if (![self isValidateMobile:phoneTF.text]) {
        [phoneTF becomeFirstResponder];
        
        return NO;
    }
    if ([passwordTF.text isEqualToString:@""]) {
        [passwordTF becomeFirstResponder];
        return NO;
    }
    return YES;
}
//点击确认按钮调用的函数
- (void)confirmBtnClicked
{
    [phoneTF resignFirstResponder];
    [passwordTF resignFirstResponder];
    
    if ([self registerSuccess] == YES) {
        NSLog(@"----登录成功----");
    }else{
        return;
    }
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldClear:(UITextField *)textField{
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    //NSLog(@"%d %d",range.length,range.location);
    NSString * toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string]; //得到输入框的内容
    if (phoneTF == textField)  //判断是否时我们想要限定的那个输入框
    {
        if ([toBeString length] > 11) { //如果输入框内容大于11则弹出警告
            textField.text = [toBeString substringToIndex:11];
            return NO;
        }
    }
    return YES;
}

//隐藏键盘
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [phoneTF resignFirstResponder];
    [passwordTF resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
