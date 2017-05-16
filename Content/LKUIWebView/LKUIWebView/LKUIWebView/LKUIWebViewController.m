//
//  LKUIWebViewController.m
//  LKUIWebView
//
//  Created by Tinker on 2017/5/16.
//  Copyright © 2017年 Tinker. All rights reserved.
//

#import "LKUIWebViewController.h"
#import <WebKit/WebKit.h>

@interface LKUIWebViewController ()<UIWebViewDelegate,WKNavigationDelegate,WKUIDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) WKWebView *wkWebView;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) UIProgressView *progressView;

@property (nonatomic, strong) UIButton *reloadButton;
@property (nonatomic, strong) UIBarButtonItem *closeBarButtonItem;
@property (nonatomic, strong) UIBarButtonItem *backBarButtonItem;

@property (nonatomic, weak) id<UIGestureRecognizerDelegate> delegate;

@end

@implementation LKUIWebViewController

#pragma mark -
#pragma mark - LifeCycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self showLeftBarButtonItem];
    [self requestData];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.navigationController.viewControllers.count > 1) {
        self.delegate = self.navigationController.interactivePopGestureRecognizer.delegate;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = self.delegate;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return self.navigationController.viewControllers.count > 1;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return self.navigationController.viewControllers.count > 1;
}

- (void)dealloc{
    [_wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
}

#pragma mark -
#pragma mark - Public



#pragma mark -
#pragma mark - Private
- (void)setupUI{
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.reloadButton];
    
    if ([self isDeiceVersion8]) {
        [self.view addSubview:self.wkWebView];
    }else{
        [self.view addSubview:self.webView];
    }
    [self.view addSubview:self.progressView];
}

- (void)requestData{
    if (![self.url hasPrefix:@"http"]) {
        self.url = [NSString stringWithFormat:@"http://%@",self.url];
    }
    
    if ([self isDeiceVersion8]) {
        [self.wkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    }else{
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
    }
}

- (void)showLeftBarButtonItem {
    if ([_webView canGoBack] || [_wkWebView canGoBack]) {
        self.navigationItem.leftBarButtonItems = @[self.backBarButtonItem,self.closeBarButtonItem];
    } else {
        self.navigationItem.leftBarButtonItem = self.backBarButtonItem;
    }
}

- (BOOL)isDeiceVersion8{
    return (self.version?self.version: 7.0) >= 8.0;
//    return [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0;
}

- (CGFloat)viewOriginY{
    if (self.navigationController) {
        return 64;
    }else{
        return 0;
    }
}

- (CGFloat)viewHeight{
    if (self.navigationController) {
        return self.view.frame.size.height - 64;
    }else{
        return self.view.frame.size.height;
    }
}

#pragma mark -
#pragma mark - Event
// 监听WKWebView的进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        _progressView.progress = [change[@"new"] floatValue];
        if (_progressView.progress == 1.0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                _progressView.hidden = YES;
            });
        }
    }
}

- (void)webViewReload{
    [_webView reload];
    [_wkWebView reload];
}

- (void)closeBarButtonClick{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)backBarButtonClick{
    if ([_webView canGoBack] || [_wkWebView canGoBack]) {
        [_webView goBack];
        [_wkWebView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -
#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    webView.hidden = NO;
    // 不加载空白页
    if ([request.URL.scheme isEqual:@"abort"]) {
        webView.hidden = YES;
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    self.progressView.hidden = NO;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.progressView.progress = (arc4random()%100)/100.0;
    }];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    // 设置navi标题
    self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    // 修改item
    [self showLeftBarButtonItem];
    
    // 制作假进度
    [UIView animateWithDuration:0.5 animations:^{
        self.progressView.progress = 1.0;
    } completion:^(BOOL finished) {
        self.progressView.hidden = YES;
    }];
    
    // 取消刷新状态
    [_refreshControl endRefreshing];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    webView.hidden = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


#pragma mark -
#pragma mark - WKNavigationDelegate&&WKUIDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    webView.hidden = NO;
    _progressView.hidden = NO;
    // 不加载空白页
    if ([webView.URL.scheme isEqual:@"abort"]) {
        webView.hidden = YES;
    }else{
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    // 设置navi标题
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id text, NSError *error) {
        self.navigationItem.title = text;
    }];
    // 修改item
    [self showLeftBarButtonItem];
    // 取消刷新状态
    [_refreshControl endRefreshing];
}

//页面加载失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    webView.hidden = YES;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    [_refreshControl endRefreshing];
}

//HTTPS认证
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if ([challenge previousFailureCount] == 0) {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        } else {
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
        }
    } else {
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}

#pragma mark -
#pragma mark - Getter

- (UIWebView *)webView{
    if (!_webView) {
        _webView = [[UIWebView alloc]init];
        _webView.frame = CGRectMake(0, self.viewOriginY, self.view.frame.size.width, self.viewHeight);
        _webView.delegate = self;
        //添加下拉刷新
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0 && _canPullDownRefresh) {
            _wkWebView.scrollView.refreshControl = self.refreshControl;
        }
    }
    return _webView;
}

- (WKWebView *)wkWebView{
    if (!_wkWebView) {
        _wkWebView = [[WKWebView alloc]init];
        _wkWebView.frame = CGRectMake(0, self.viewOriginY, self.view.frame.size.width, self.viewHeight);
        _wkWebView.navigationDelegate = self;
        _wkWebView.UIDelegate = self;
        //添加此属性可触发侧滑返回上一网页与下一网页操作
        _wkWebView.allowsBackForwardNavigationGestures = YES;
        //添加下拉刷新
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0 && _canPullDownRefresh) {
            _wkWebView.scrollView.refreshControl = self.refreshControl;
        }
        //添加进度条监听
        [_wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _wkWebView;
}

- (UIRefreshControl *)refreshControl{
    if (!_refreshControl) {
        _refreshControl = [[UIRefreshControl alloc]init];
        [_refreshControl addTarget:self action:@selector(webViewReload) forControlEvents:UIControlEventValueChanged];
    }
    return _refreshControl;
}

- (UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc]init];
        _progressView.frame = CGRectMake(0, self.viewOriginY, self.view.frame.size.width, 1);
        _progressView.progressTintColor = [UIColor greenColor];
        _progressView.trackTintColor = [UIColor whiteColor];
    }
    return _progressView;
}

- (UIButton *)reloadButton{
    if (!_reloadButton) {
        _reloadButton = [UIButton buttonWithType:0];
        _reloadButton.bounds = CGRectMake(0, 0, 120, 120);
        _reloadButton.center = self.view.center;
        [_reloadButton setBackgroundImage:[UIImage imageNamed:@"sure_placeholder_error"] forState:UIControlStateNormal];
        [_reloadButton setTitle:@"网络连接失败，请检查您的网络设置" forState:UIControlStateNormal];
        [_reloadButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [_reloadButton setTitleEdgeInsets:UIEdgeInsetsMake(200, -50, 0, -50)];
        _reloadButton.titleLabel.numberOfLines = 0;
        _reloadButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _reloadButton;
}

- (UIBarButtonItem *)closeBarButtonItem{
    if (!_closeBarButtonItem) {
        _closeBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(closeBarButtonClick)];
    }
    return _closeBarButtonItem;
}

- (UIBarButtonItem *)backBarButtonItem{
    if (!_backBarButtonItem) {
        _backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backBarButtonClick)];
    }
    return _backBarButtonItem;
}

#pragma mark -
#pragma mark - Setter



@end
