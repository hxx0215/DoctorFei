//
//  ContactSendGroupMessageViewController.m
//  DoctorFei_iOS
//
//  Created by hxx on 1/14/15.
//
//

#import "ContactSendGroupMessageViewController.h"
#import "ContactViewController.h"
#import "TITokenField.h"
#import "Friends.h"
#import <UIImageView+WebCache.h>
#import "DataUtil.h"
#import "ImageUtil.h"
#import <JSONKit.h>
#import "MBProgressHUD.h"
#import "ChatAPI.h"
@interface ContactSendGroupMessageViewController ()<TITokenFieldDelegate, UITextViewDelegate>
@property (nonatomic, strong)NSArray *friends;
@property (nonatomic, strong)TITokenFieldView *tokenFieldView;
@property (nonatomic, strong)UITextView *messageView;
@property (nonatomic, assign)CGFloat keyboardHeight;
@property (nonatomic, strong)NSMutableArray *selectedFriends;
- (IBAction)confirmButtonClicked:(id)sender;
@end

@implementation ContactSendGroupMessageViewController
{
    BOOL isBeginForTextView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    isBeginForTextView = YES;
    self.friends = [Friends MR_findByAttribute:@"isFriend" withValue:@YES];
    _tokenFieldView = [[TITokenFieldView alloc] initWithFrame:self.view.bounds];
    [_tokenFieldView setSourceArray:self.friends];
    [self.view addSubview:_tokenFieldView];
    [_tokenFieldView.tokenField setDelegate:self];
    [_tokenFieldView setForcePickSearchResult:YES];
    [_tokenFieldView setShouldSearchInBackground:NO];
    [_tokenFieldView setShouldSortResults:NO];
    [_tokenFieldView.tokenField addTarget:self action:@selector(tokenFieldFrameDidChange:) forControlEvents:(UIControlEvents)TITokenFieldControlEventFrameDidChange];
    [_tokenFieldView.tokenField setTokenizingCharacters:[NSCharacterSet characterSetWithCharactersInString:@",;."]]; // Default is a comma
    [_tokenFieldView.tokenField setPromptText:@"收件人:"];
    [_tokenFieldView.tokenField setPlaceholder:@"点击+号选取收件人"];
    
    UIButton * addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [addButton setFrame:CGRectMake(0, 0, 44, 44)];
    [addButton setImageEdgeInsets:UIEdgeInsetsMake(14, 14, 0, 0)];
    [addButton setTintColor:UIColorFromRGB(0x6EA800)];
    [addButton addTarget:self action:@selector(showContactsPicker:) forControlEvents:UIControlEventTouchUpInside];
    [_tokenFieldView.tokenField setRightView:addButton];
    [_tokenFieldView.tokenField addTarget:self action:@selector(tokenFieldChangedEditing:) forControlEvents:UIControlEventEditingDidBegin];
    [_tokenFieldView.tokenField addTarget:self action:@selector(tokenFieldChangedEditing:) forControlEvents:UIControlEventEditingDidEnd];
    
    _messageView = [[UITextView alloc] initWithFrame:_tokenFieldView.contentView.bounds];
    [_messageView setScrollEnabled:NO];
    [_messageView setAutoresizingMask:UIViewAutoresizingNone];
    [_messageView setDelegate:self];
    [_messageView setFont:[UIFont systemFontOfSize:15]];
    [_messageView setText:@"请输入群发信息内容"];
    [_tokenFieldView.contentView addSubview:_messageView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    self.selectedFriends = [NSMutableArray new];
    // You can call this on either the view on the field.
    // They both do the same thing.
    [_tokenFieldView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_tokenFieldView resignFirstResponder];
    [_messageView resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    ContactViewController *contact = [segue destinationViewController];
    contact.contactMode = ContactViewControllerModeGMAddFriend;
    contact.didSelectFriends = ^(NSArray *friendArr){
//        NSLog(@"%@",friendArr);
        [_tokenFieldView.tokenField removeAllTokens];
        [self.selectedFriends removeAllObjects];
        for (Friends *fr in friendArr){
            TIToken * token = [_tokenFieldView.tokenField addTokenWithTitle:fr.realname representedObject:fr];
            [_tokenFieldView.tokenField layoutTokensAnimated:YES];
            [token setTintColor:UIColorFromRGB(0x6EA800)];
        }
        self.selectedFriends = [friendArr mutableCopy];
    };
//    NSMutableArray *ma = [NSMutableArray new];
//    for (TIToken *token in _tokenFieldView.tokenField.tokens){
//        [ma addObject:token.title];
//    }
    contact.selectedArray = self.selectedFriends;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    if (isBeginForTextView) {
        isBeginForTextView = NO;
        textView.text = @"";
    }
    return YES;
}
- (void)keyboardWillShow:(NSNotification *)notification {
    
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboardHeight = keyboardRect.size.height > keyboardRect.size.width ? keyboardRect.size.width : keyboardRect.size.height;
    [self resizeViews];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    _keyboardHeight = 0;
    [self resizeViews];
}
- (void)resizeViews {
    int tabBarOffset = self.tabBarController == nil ?  0 : self.tabBarController.tabBar.frame.size.height;
    [_tokenFieldView setFrame:((CGRect){_tokenFieldView.frame.origin, {self.view.bounds.size.width, self.view.bounds.size.height + tabBarOffset - _keyboardHeight}})];
    [_messageView setFrame:_tokenFieldView.contentView.bounds];
}

- (void)tokenFieldFrameDidChange:(TITokenField *)tokenField {
    [self textViewDidChange:_messageView];
}
- (void)textViewDidChange:(UITextView *)textView {
    
    CGFloat oldHeight = _tokenFieldView.frame.size.height - _tokenFieldView.tokenField.frame.size.height;
    CGFloat newHeight = textView.contentSize.height + textView.font.lineHeight;
    
    CGRect newTextFrame = textView.frame;
    newTextFrame.size = textView.contentSize;
    newTextFrame.size.height = newHeight;
    
    CGRect newFrame = _tokenFieldView.contentView.frame;
    newFrame.size.height = newHeight;
    
    if (newHeight < oldHeight){
        newTextFrame.size.height = oldHeight;
        newFrame.size.height = oldHeight;
    }
    
    [_tokenFieldView.contentView setFrame:newFrame];
    [textView setFrame:newTextFrame];
    [_tokenFieldView updateContentSize];
}
- (void)showContactsPicker:(id)sender {
    
    // Show some kind of contacts picker in here.
    // For now, here's how to add and customize tokens.
    [self performSegueWithIdentifier:@"ContactSendGMSequeIdentifier" sender:sender];
//    NSArray * names = self.friends;
//    
//    TIToken * token = [_tokenFieldView.tokenField addTokenWithTitle:[names objectAtIndex:(arc4random() % names.count)]];
//    [token setAccessoryType:TITokenAccessoryTypeDisclosureIndicator];
//    // If the size of the token might change, it's a good idea to layout again.
//    [_tokenFieldView.tokenField layoutTokensAnimated:YES];
//    
//    NSUInteger tokenCount = _tokenFieldView.tokenField.tokens.count;
//    [token setTintColor:((tokenCount % 3) == 0 ? [TIToken redTintColor] : ((tokenCount % 2) == 0 ? [TIToken greenTintColor] : [TIToken blueTintColor]))];
    
    
}

- (void)tokenFieldChangedEditing:(TITokenField *)tokenField {
    // There's some kind of annoying bug where UITextFieldViewModeWhile/UnlessEditing doesn't do anything.
    [tokenField setRightViewMode:(tokenField.editing ? UITextFieldViewModeAlways : UITextFieldViewModeNever)];
}


- (BOOL)tokenField:(TITokenField *)field shouldUseCustomSearchForSearchString:(NSString *)searchString
{
    return NO;//([searchString isEqualToString:@"contributors"]);
}


- (void)tokenField:(TITokenField *)field performCustomSearchForSearchString:(NSString *)searchString withCompletionHandler:(void (^)(NSArray *))completionHandler
{
    completionHandler(self.friends);
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        //Send a Github API request to retrieve the Contributors of this project.
//        //Using a syncrhonous request in a Background Thread to not over-complexify the demo project
//        NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"https://api.github.com/repos/thermogl/TITokenField/contributors"]];
//        NSURLResponse * response = nil;
//        NSError * error = nil;
//        NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
//        
//        NSMutableArray *results = [[NSMutableArray alloc] init];
//        
//        if (error == nil) {
//            NSError *errorJSON;
//            NSArray *contributors = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&errorJSON];
//            
//            for (NSDictionary *user in contributors) {
//                [results addObject:[user objectForKey:@"login"]];
//            }
//        }
//        
//        
//        dispatch_async(dispatch_get_main_queue(), ^(void) {
//            //Finally call the completionHandler with the results array!
//            completionHandler(results);
//        });
//    });
}

- (UIImage *)tokenField:(TITokenField *)tokenField searchResultImageForRepresentedObject:(id)object{
    Friends *fr = (Friends *)object;
    UIImage *defaultImage = [UIImage imageNamed:@"list_user-small_example_pic"];
    if (fr.icon != nil && fr.icon.length > 0) {
        UIImageView *img = [UIImageView new];
        [img sd_setImageWithURL:[NSURL URLWithString:fr.icon] placeholderImage:defaultImage];
        return img.image;
    }
    return defaultImage;
}

- (NSString *)tokenField:(TITokenField *)tokenField searchResultStringForRepresentedObject:(id)object{
    Friends *fr = (Friends *)object;
    return [DataUtil nameStringForFriend:fr].string;
}

- (NSString *)tokenField:(TITokenField *)tokenField displayStringForRepresentedObject:(id)object{
    Friends *fr = (Friends *)object;
    return [DataUtil nameStringForFriend:fr].string;
}
- (void)tokenField:(TITokenField *)tokenField didAddToken:(TIToken *)token{
    NSLog(@"%@",token);
    token.tintColor = UIColorFromRGB(0x6EA800);
    [self.selectedFriends addObject:[token representedObject]];
}
- (void)tokenField:(TITokenField *)tokenField didRemoveToken:(TIToken *)token{
    NSLog(@"%@",token);
    [self.selectedFriends removeObject:[token representedObject]];
}
//- (CGFloat)tokenField:(TITokenField *)tokenField resultsTableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 65.0f;
//}

- (void)sendGroupMessage {

    NSNumber *userId = [[NSUserDefaults standardUserDefaults]objectForKey:@"UserId"];
    NSMutableArray *userArray = [NSMutableArray array];
    for (Friends *friend in _selectedFriends) {
        [userArray addObject:@{@"id":friend.userId, @"type": friend.userType}];
    }
    NSDictionary *param = @{
                            @"userid": userId,
                            @"usertype": @2,
                            @"msgtype": @"text",
                            @"content": _messageView.text,
                            @"senduserids": [userArray JSONString]
                            };
    NSLog(@"%@",param);
    [ChatAPI setChatGroupSendWithParameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",error.localizedDescription);
    }];
    
}
- (IBAction)confirmButtonClicked:(id)sender {
    if (isBeginForTextView || _messageView.text.length == 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText  = @"请输入消息内容";
        [hud hide:YES afterDelay:1.0f];
        return;
    }
    if (_selectedFriends.count == 0) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view.window animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.labelText  = @"请添加收件人";
        [hud hide:YES afterDelay:1.0f];
        return;
    }
    [self sendGroupMessage];
}
@end
