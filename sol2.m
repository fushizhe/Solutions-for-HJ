/*如何理解MVVM框架，它的优点和缺点在哪？运用此框架编写一段代码，建议采用ReactiveCocoa库实现

对于传统的Model-View-Controller框架，在iOS开发中，Controller部分也就是viewController很容易变得比较庞大和复杂。
由于Controller承担了Model和View之间的桥梁作用，所以Controller通常和对应的View和Model的耦合度非常高，这也造成了
对其做单元测试非常不容易。

MVVM代表Model View View-Model，它是一个经过优化的MVC。它首先将视图和控制器连接起来，并将表示逻辑从Controller中移出
放到一个新的对象里，即View-Model，也就是负责将Model数据转换为View可以呈现的东西。三者之间的结构为：
View/ViewController ————> ViewModel ————> Model 
这里ViewController对象直接持有一个ViewModel对象。ViewModel对象又直接持有Model对象。箭头不能被反向。 
*/


/*ReactiveCocoa主要解决3个问题，其一：传统iOS开发过程中，状态及状态之间依赖过多
RAC 通过引入信号（Signal）的概念，来代替传统 iOS 开发中对于控件状态变化检查的代理（delegate）模式或 target-action 模式。
因为 RAC 的信号是可以组合（combine）的，所以可以轻松地构造出另一个新的信号出来，然后将按钮的enabled状态与新的信号绑定。如下所示：
*/
RAC(self.logInButton, enabled) = [RACSignal
    combineLatest:@[
        self.usernameTextField.rac_textSignal,
        self.passwordTextField.rac_textSignal,
        RACObserve(LoginManager.sharedManager, loggingIn),
        RACObserve(self, loggedIn)
    ] reduce:^(NSString *username, NSString *password, NSNumber *loggingIn, NSNumber *loggedIn) {
        return @(username.length > 0 && password.length > 0 && !loggingIn.boolValue && !loggedIn.boolValue);
    }];

/*其二，引入MVVM框架。RAC的信号机制很容易将某一个 Model变量的变化与界面关联，所以非常容易应用 Model-View-ViewModel
框架。通过引入 ViewModel 层，然后用 RAC 将 ViewModel 与 View 关联，View 层的变化可以直接响应 ViewModel 层的变化，
这使得 Controller 变得更加简单，由于 View 不再与 Model 绑定，也增加了 View 的可重用性。*/
/*假设现有博客model模型MYArticleModel，对应的viewModel可以通过实现-initWithArticleModel来构建视图模型*/

- (instancetype)initWithArticleModel:(MYArticleModel *)model {
    self = [super init];

    if (nil != self) {
        // 设置intro属性和model的属性的级联关系.
        RAC(self, intro) = [RACSignal combineLatest:@[RACObserve(model, title), RACObserve(model, desc)] reduce:^id(NSString * title, NSString * desc){
            NSString * intro = [NSString stringWithFormat: @"标题:%@ 内容:%@", model.title, model.desc];

            return intro;
        }];

        // 设置self.blogId与model.id的相互关系.
        [RACObserve(model, id) subscribeNext:^(id x) {
            self.blogId = x;
        }];
    }

    return self;
}
//Controller的代码如下，得到了精简

@interface MYMVVMPostViewController ()
@property (strong, nonatomic) UIWebView * webView;
@end

@implementation MYMVVMPostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [RACObserve(self.viewModel, content) subscribeNext:^(id x) {
        [self updateView];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (UIWebView *)webView
{
    if (nil == _webView) {
        _webView = [[UIWebView alloc] init];

        [self.view addSubview: _webView];

        [_webView makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        }];
    }

    return _webView;
}

/**
 * 更新视图.
 */
- (void) updateView
{
    [self.webView loadHTMLString: self.viewModel.content baseURL:nil];
}

@end

/*其三，统一消息传递机制
iOS中有各种消息传递机制，包括 KVO、Notification、delegation、block 以及 target-action 方式。
RAC 将传统的 UI 控件事件进行了封装，使得以上各种消息传递机制都可以用 RAC 来完成。示例代码如下：
*/

// KVO
[RACObserve(self, username) subscribeNext:^(id x) {
    NSLog(@" 成员变量 username 被修改成了：%@", x);
}];

// target-action
self.button.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
    NSLog(@" 按钮被点击 ");
    return [RACSignal empty];
}];

// Notification
[[[NSNotificationCenter defaultCenter]
    rac_addObserverForName:UIKeyboardDidChangeFrameNotification
                    object:nil]
    subscribeNext:^(id x) {
        NSLog(@" 键盘 Frame 改变 ");
    }
];

// Delegate
[[self rac_signalForSelector:@selector(viewWillAppear:)] subscribeNext:^(id x) {
    debugLog(@"viewWillAppear 方法被调用 %@", x);
}];