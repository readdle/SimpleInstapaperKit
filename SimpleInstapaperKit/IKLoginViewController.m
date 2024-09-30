//
//  IKLoginViewController.m
//  SimpleInstapaperKitExample
//
//  Created by David Beck on 12/3/12.
//  Copyright (c) 2012 ThinkUltimate. All rights reserved.
//
//  https://github.com/davbeck/SimpleInstapaperKit
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//  - Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
//  - Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
//  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
//  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
//  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
//  OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
//  OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "IKLoginViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "IKRequest.h"

const NSInteger kUsernameFieldClearButtonTag = 111;
const NSInteger kPasswordFieldClearButtonTag = 112;

@interface IKLoginViewController ()

@property (strong, nonatomic) IBOutlet UITableViewCell *usernameCell;
@property (strong, nonatomic) IBOutlet UILabel *usernameTitle;
@property (strong, nonatomic) IBOutlet UITextField *usernameField;
@property (strong, nonatomic) IBOutlet UIButton *usernameFieldClearButton;
@property (strong, nonatomic) IBOutlet UITableViewCell *passwordCell;
@property (strong, nonatomic) IBOutlet UILabel *passwordTitle;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UIButton *passwordFieldClearButton;
@property (strong, nonatomic) IBOutlet UITableViewCell *loadingCell;
@property (strong, nonatomic) IBOutlet UITextField *loadingField;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (strong, nonatomic) IBOutlet UIView *headerView;

- (IBAction)selectNext:(id)sender;
- (IBAction)login:(id)sender;

@end

@implementation IKLoginViewController
{
	BOOL _loading;
	void(^_completionHandler)(BOOL loggedIn);
}

- (void)_setLoading:(BOOL)loading
{
	_loading = loading;
	
	[self.tableView reloadData];
	
	CATransition *animation = [CATransition animation];
	[animation setDuration:0.25];
	[animation setType:kCATransitionFade];
	[self.view.layer addAnimation:animation forKey:nil];
}

- (UINavigationItem *)navigationItem
{
	UINavigationItem *navigationItem = [super navigationItem];
	
	navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Login", nil)
																		 style:UIBarButtonItemStyleDone
																		target:self action:@selector(login:)];
	navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																					 target:self action:@selector(cancel:)];
	
	UILabel *title = [[UILabel alloc] init];
	title.text = NSLocalizedString(@"Instapaper", nil);
	title.font = [UIFont fontWithName:@"Georgia" size:22.0];
	title.backgroundColor = [UIColor clearColor];
	title.textColor = self.primaryTextColor;
	[title sizeToFit];
	navigationItem.titleView = title;
	
	return navigationItem;
}

- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        self.title = NSLocalizedString(@"Instapaper", nil);
        [self setupColors];
    }
    
    return self;
}

- (id)initWithCompletionHandler:(void(^)(BOOL loggedIn))completion
{
    NSBundle *nibBundle = nil;
#if SWIFT_PACKAGE
    nibBundle = SWIFTPM_MODULE_BUNDLE;
#endif
	self = [self initWithNibName:nil bundle:nibBundle];
	if (self != nil) {
		_completionHandler = [completion copy];
        [self setupColors];
	}
	
	return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
#if SWIFT_PACKAGE
    if (nibBundleOrNil == nil) {
        nibBundleOrNil = SWIFTPM_MODULE_BUNDLE;
    }
#endif
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self != nil) {
		self.title = NSLocalizedString(@"Instapaper", nil);
        [self setupColors];
	}
	
	return self;
}

- (void)setupColors {
    self.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:1.f];
    
    self.cellBackgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:1.f];
    self.cellBackgroundColorSelected = [UIColor colorWithRed:242 green:242 blue:247 alpha:1.f];
    
    self.primaryTextColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.f];
    self.secondaryTextColor = UIColor.darkGrayColor;
    self.placeholderTextColor = UIColor.lightGrayColor;
    self.linkTextColor = [UIColor colorWithRed:0 green:122 blue:255 alpha:1.f];
    
    self.clearButtonTintColor = UIColor.lightGrayColor;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.loadingField];
    
    self.tableView.backgroundColor = self.backgroundColor;
    
    self.usernameFieldClearButton.tag = kUsernameFieldClearButtonTag;
    self.passwordFieldClearButton.tag = kPasswordFieldClearButtonTag;
    
    [self.usernameField addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.passwordField addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.navigationController.navigationBar.tintColor = self.primaryTextColor;
    
    self.tableView.backgroundColor = self.backgroundColor;
	
    NSDictionary *placeholderAttributes = @{ NSForegroundColorAttributeName: self.placeholderTextColor };
    
    NSString *usernameFieldPlaceholder = self.usernameField.placeholder ?: @"or email address";
    NSAttributedString *usernameFieldAttributedPlaceholder = [[NSAttributedString alloc] initWithString:usernameFieldPlaceholder attributes:placeholderAttributes];
    
    NSString *passwordFieldPlaceholder = self.passwordField.placeholder ?: @"if you have any";
    NSAttributedString *passwordFieldAttributedPlaceholder = [[NSAttributedString alloc] initWithString:passwordFieldPlaceholder attributes:placeholderAttributes];
    
    self.usernameTitle.textColor = self.secondaryTextColor;

    self.usernameField.text = [IKRequest username];
    self.usernameField.textColor = self.primaryTextColor;
    self.usernameField.attributedPlaceholder = usernameFieldAttributedPlaceholder;
    self.usernameField.backgroundColor = UIColor.clearColor;
    self.usernameField.keyboardAppearance = self.keyboardAppearance;
        
    self.passwordTitle.textColor = self.secondaryTextColor;

    self.passwordField.text = [IKRequest password];
    self.passwordField.textColor = self.primaryTextColor;
    self.passwordField.attributedPlaceholder = passwordFieldAttributedPlaceholder;
    self.passwordField.backgroundColor = UIColor.clearColor;
    self.passwordField.keyboardAppearance = self.keyboardAppearance;
    
    self.usernameFieldClearButton.tintColor = self.clearButtonTintColor;
    self.passwordFieldClearButton.tintColor = self.clearButtonTintColor;
	
    [self.usernameField becomeFirstResponder];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (_loading) {
		return 1;
	}
	
	return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
	if (_loading) {
		cell = self.loadingCell;
	}
	
	if (indexPath.row == 0) {
		cell = self.usernameCell;
	} else if (indexPath.row == 1) {
		cell = self.passwordCell;
	}
	
    cell.backgroundColor = self.cellBackgroundColor;
    cell.selectedBackgroundView.backgroundColor = self.cellBackgroundColorSelected;
    
	return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
		[self.usernameField becomeFirstResponder];
	} else {
		[self.passwordField becomeFirstResponder];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (_loading) {
		return 44.0 * 2.0;
	}
	
	return 44.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	return self.headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return self.headerView.frame.size.height;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	return self.footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return self.footerView.frame.size.height;
}


#pragma mark - Actions

- (IBAction)login:(id)sender
{
	[self _setLoading:YES];
	
	
	[IKRequest setUsername:self.usernameField.text password:self.passwordField.text completed:^(BOOL success, NSInteger statusCode) {
		if (success) {
			if (_completionHandler != nil) {
				_completionHandler(YES);
				_completionHandler = nil;
			}
			
			[self cancel:nil];
		} else {
			NSString *reason;
			
			if (statusCode == 403) {
				reason = NSLocalizedString(@"Invalid username or password.", nil);
			} else {
				reason = NSLocalizedString(@"The service encountered an error. Please try again later.", nil);
			}
			

            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Login Failed", nil)
                                                                                     message:reason
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self.passwordField becomeFirstResponder];
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
			
			[self _setLoading:NO];
		}
	}];
}

- (IBAction)cancel:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
	
	if (_completionHandler != nil) {
		_completionHandler(NO);
	}
}

- (IBAction)selectNext:(id)sender
{
	[self.passwordField becomeFirstResponder];
}

#pragma mark - Text Field Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self updateClearButtonVisibilityForTextField:textField];
}

- (void)textFieldTextDidChange:(UITextField *)textField {
    [self updateClearButtonVisibilityForTextField:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == self.passwordField) {
		[self login:textField];
		return NO;
	}
	
	return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self updateClearButtonVisibilityForTextField:textField];
    [self.loadingField becomeFirstResponder];
}

#pragma mark -

- (void)updateClearButtonVisibilityForTextField:(UITextField *)textField {
    BOOL shouldDisplayClearButton = textField.text.length > 0 && textField.isFirstResponder;
    
    if (textField == self.usernameField) {
        self.usernameFieldClearButton.hidden = !shouldDisplayClearButton;
    }
    else if (textField == self.passwordField) {
        self.passwordFieldClearButton.hidden = !shouldDisplayClearButton;
    }
    else {
        NSAssert(NO, @"Failed to update clear button visibility: unknown text field.");
    }
}

#pragma mark - IBActions

- (IBAction)clearTextField:(UIButton *)sender {
    if (sender.tag == kUsernameFieldClearButtonTag) {
        self.usernameField.text = @"";
    }
    else if (sender.tag == kPasswordFieldClearButtonTag) {
        self.passwordField.text = @"";
    }
    
    sender.hidden = YES;
}

@end
