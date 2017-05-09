//
//  NSArray+Custom.h
//  HttpCapture
//
//  Created by liuyihao1216 on 16/8/17.
//  Copyright © 2016年 liuyihao1216. All rights reserved.
//

#import "SidebarMenuViewController.h"
#import "UIViewAdditions.h"
#import "UIViewController+NavigationBar.h"
#import "HttpCapture-swift.h"
#import "UINavigationController+FDFullscreenPopGesture.h"

@interface SidebarMenuViewController()
{
    float barheight;
    float naviheight;
    UIPanGestureRecognizer * panGesture;
    UIControl * control;
    BOOL allowPan;
}


@end

@implementation SideBarModel

- (id)initWithName:(NSString*)name vc:(nullable UIViewController *)vc
{
    if (self = [super init]) {
        self.name = name;
        self.vc = vc;
    }
    
    return self;
}

@end

@implementation SidebarMenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
    }
    
    return self;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.navigationBar.hidden = true;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    barheight = 49;
    naviheight = 64;
    
    self.automaticallyAdjustsScrollViewInsets = false;
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height - naviheight) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:_tableView];
    
    [self addTargetViewControllerForIndex:0];
    
    panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panChange:)];
    panGesture.delegate = self;
    [self.view addGestureRecognizer:panGesture];
    
    control = [[UIControl alloc]initWithFrame:CGRectMake(250, 0, self.view.width - 250, self.view.height)];
    [control addTarget:self action:@selector(toggleSidebar) forControlEvents:UIControlEventTouchUpInside];
    control.hidden = true;
    [self.view addSubview:control];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)panChange:(UIGestureRecognizer *)recoginzer{
    float xPosition = self.containerController.view.frame.origin.x;
    CGPoint p = [(UIPanGestureRecognizer *)recoginzer velocityInView:recoginzer.view];
    CGPoint touchPoint = [recoginzer locationInView:KEY_WINDOW];
    
    if (self.containerController.childViewControllers.count >= 1)
    {
//        UIViewController * vc = self.containerController.viewControllers.lastObject;
//        if ([vc isKindOfClass:[CommonWebViewController class]] && [recoginzer isMemberOfClass:[UIPanGestureRecognizer class]] && ((CommonWebViewController *)vc).webView.canGoBack == true )
//        {
//            id<SideBarDelegate> delegate = vc;
//            [delegate swipePanGestureHandler:recoginzer];
//            return;
//        }
    }
    if (xPosition == 0 && p.x < 0) {
        return;
    }
    CGFloat x = touchPoint.x > 250 ? 250 : touchPoint.x;
    
    if (recoginzer.state == UIGestureRecognizerStateFailed || recoginzer.state == UIGestureRecognizerStatePossible) {
        NSLog(@"asdfas");
    }
    
    if (recoginzer.state == UIGestureRecognizerStateBegan)
    {
        [UIView animateWithDuration:0.2f animations:^{
            self.containerController.view.frame = CGRectMake(x, self.containerController.view.frame.origin.y, self.containerController.view.frame.size.width, self.containerController.view.frame.size.height);
        } completion:^(BOOL finished) {
            
        }];
    }
    else if (recoginzer.state == UIGestureRecognizerStateChanged)
    {
        self.containerController.view.frame = CGRectMake(x, self.containerController.view.frame.origin.y, self.containerController.view.frame.size.width, self.containerController.view.frame.size.height);
    }
    else if (recoginzer.state == UIGestureRecognizerStateEnded || recoginzer.state == UIGestureRecognizerStateFailed)
    {
        [self toggleSidebar:recoginzer animationFinishBlock:nil];
    }
}

- (void)addShadowToViewController:(UIViewController *)viewController {
    
    [viewController.view.layer setCornerRadius:4];
    
    [viewController.view.layer setShadowColor:[UIColor blackColor].CGColor];
    
    [viewController.view.layer setShadowOpacity:0.2];
    
    [viewController.view.layer setShadowOffset:CGSizeMake(-4, -4)];
}


#pragma mark - public class methods
- (void)addTargetViewControllerForIndex:(NSUInteger)index {
    if (self.menuItemViewControllers.count > index) {
        UIViewController *currentViewController = [self.menuItemViewControllers objectAtIndex:index];
        
        [self addSidebarButtonForViewController:currentViewController];
        
        if([[self.containerController childViewControllers] count] > 0) {
            [self sendMsgToChildViewController:currentViewController];
            
            [self removeTargetViewController];
            
            [self.containerController pushViewController:currentViewController animated:NO];
        }
        else {
            self.containerController = [[UINavigationController alloc] initWithRootViewController:currentViewController];
            self.containerController.view.backgroundColor = [UIColor whiteColor];
            [self addShadowToViewController:self.containerController];
            [self addChildViewController:self.containerController];
            [self.view addSubview:self.containerController.view];
            [self.containerController setNavigationBarHidden:true];
            [self.containerController didMoveToParentViewController:self];
        }
    }
}

- (void)removeTargetViewController {
    NSArray *childViewContorllersOfContainer = [self.containerController childViewControllers];
    UIViewController *theChildViewController = [childViewContorllersOfContainer lastObject];
    [theChildViewController removeFromParentViewController];
    [theChildViewController.view removeFromSuperview];
}

- (void)addSidebarButtonForViewController:(UIViewController *)viewController {
    [[viewController.navigationBar viewWithTag:1002] removeFromSuperview];
    if ([viewController isKindOfClass:[CaptureBaseViewController class]])
    {
        ((CaptureBaseViewController*) viewController).leftBtn.hidden = true;
    }
    if ([viewController.navigationBar viewWithTag:1000] == nil) {
        UIButton *sidebarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        sidebarButton.tag = 1000;
        UIImage *image = [UIImage imageNamed:self.sideBarButtonImageName];
        [sidebarButton setImage:image forState:UIControlStateNormal];
        [sidebarButton setShowsTouchWhenHighlighted:YES];
        sidebarButton.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        
        [sidebarButton addTarget:self action:@selector(toggleSidebar) forControlEvents:UIControlEventTouchUpInside];
        CGFloat width = 30;
        sidebarButton.frame = CGRectMake(10, 44/2 - width/2 + 20, width, width);
        [viewController.navigationBar addSubview:sidebarButton];
    }
}

- (void)toggleSidebar
{
    [self toggleSidebar:nil animationFinishBlock:nil];
}

- (void)backBtnClick
{
    [self.containerController dismissViewControllerAnimated:true completion:nil];
}

- (void)resign{
    NSArray *childViewContorllersOfContainer = [self.containerController childViewControllers];
    UIViewController *theChildViewController = [childViewContorllersOfContainer lastObject];
    if ([theChildViewController isKindOfClass:[ToolBarWebViewController class]]) {
        [[(ToolBarWebViewController *)theChildViewController textfield] resignFirstResponder];
    }
    if ([theChildViewController isKindOfClass:[ComposeToolViewController class]]) {
        [[(ComposeToolViewController *)theChildViewController textfield] resignFirstResponder];
        [[(ComposeToolViewController *)theChildViewController textView] resignFirstResponder];
    }
    if ([theChildViewController isKindOfClass:[PreviewViewController class]]) {
        [[(PreviewViewController *)theChildViewController searchBar] resignFirstResponder];
    }
}

- (void)sendMsgToChildViewController:(UIViewController *)currentViewController
{
    if (currentViewController != [self.containerController childViewControllers].lastObject) {
        UIViewController * vc = [[self.containerController childViewControllers] lastObject];
        if ([vc respondsToSelector:@selector(toggle:)])
        {
            id<SideBarDelegate> delegate = vc;
            [delegate toggle:ToggleClose];
        }
        
        if ([currentViewController isKindOfClass:[UploadViewController class]]) {
            [[HttpCaptureManager shareInstance] saveHAR];
        }
    }
}

- (int)getMenuItemViewControllerIndex:(NSIndexPath *)indexPath{
    int currentIndex = 0;
    if (self.menuItemNames.count > indexPath.section)
    {
        NSArray * ar = [self.menuItemNames objectAtIndex:indexPath.section];
        SideBarModel * m = [ar objectAtIndex:indexPath.row];
        return [self.menuItemViewControllers indexOfObject:m.vc];
    }
    return currentIndex;
}

- (void)selectIndexPath:(NSIndexPath *)indexPath animationFinishBlock:(void (^)(BOOL finish))block
{
    if (indexPath == nil) {
        return;
    }
    
    if (self.menuItemNames.count > indexPath.section)
    {
        NSArray * ar = [self.menuItemNames objectAtIndex:indexPath.section];
        SideBarModel * m = [ar objectAtIndex:indexPath.row];
        
        if ([m.name isEqualToString:@"在浏览器打开"])
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[HttpCaptureManager shareInstance] currentUrl]]];
        }
        else if ([m.name isEqualToString:@"网址导航"])
        {
            for (int i = 0 ; i < self.menuItemViewControllers.count;i++) {
                UIViewController * vc = [self.menuItemViewControllers objectAtIndex:i];
                if ([vc isMemberOfClass:[ToolBarWebViewController class]])
                {
                    [((ToolBarWebViewController *)vc) backToPage:0];
                    break;
                }
            }
        }
        else if ([m.name isEqualToString:@"帮助"])
        {
            for (int i = 0 ; i < self.menuItemViewControllers.count;i++) {
                UIViewController * vc = [self.menuItemViewControllers objectAtIndex:i];
                if ([vc isMemberOfClass:[ToolBarWebViewController class]])
                {
                    [((ToolBarWebViewController *)vc) backToPage:1];
                    break;
                }
            }
        }
    }

    
    int menuItemIndex = [self getMenuItemViewControllerIndex:indexPath];
    if (self.menuItemViewControllers.count > menuItemIndex)
    {
        [self configPreViewVC:menuItemIndex];
        
        [self addTargetViewControllerForIndex:menuItemIndex];
        [self toggleSidebar:nil animationFinishBlock:block];
    }
}

- (void)pushItemViewCtrl:(int)index{
    if (self.menuItemViewControllers.count > index) {
        [self configPreViewVC:index];
        
        UIViewController * vc = [self.menuItemViewControllers objectAtIndex:index];
        vc.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:[[UIView alloc] initWithFrame:CGRectZero]];
        [self.containerController pushViewController:vc animated:true];
        if ([vc respondsToSelector:@selector(configLeftBtn)])
        {
            [vc performSelector:@selector(configLeftBtn) withObject:nil];
        }
    }
}

- (void)configPreViewVC:(int)index
{
    if (self.menuItemViewControllers.count > index) {
        if ([[self.menuItemViewControllers objectAtIndex:index] isKindOfClass:[PreviewViewController class]])
        {
            PreviewViewController * previewVC = [self.menuItemViewControllers objectAtIndex:index];
            [[HttpCaptureManager shareInstance] getAllEntries:^(NSMutableArray * _Nonnull re) {
                previewVC.entries = re;
                [previewVC configTempEntries];
            }];
        }
        if ([[self.menuItemViewControllers objectAtIndex:index] isMemberOfClass:[ConsoleLogViewController class]])
        {
            TextViewController * textVC = [self.menuItemViewControllers objectAtIndex:index];
            ToolBarWebViewController * toolBarVC = nil;
            
            for (UIViewController * vc in self.menuItemViewControllers)
            {
                if ([vc isMemberOfClass:[ToolBarWebViewController class]]) {
                    toolBarVC = vc;
                    break;
                }
            }
            
            dispatch_queue_t queue = [toolBarVC.webView logQueue];
            dispatch_async(queue, ^{
                NSArray * paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
                NSString * diskCachePath = [paths[0] stringByAppendingPathComponent:@"/consoleLog.txt"];
                NSString * content = [[NSString alloc] initWithContentsOfFile:diskCachePath encoding:NSUTF8StringEncoding error:nil];
                dispatch_async(dispatch_get_main_queue(), ^{
                    textVC.text = content;
                });
            });
        }
    }
}

- (UITableView *)getSideBarTableView{
    return self.tableView;
}

- (NSIndexPath *)getSearchWebControllerIndexPath{
//    for (int i = 0 ; i < self.menuItemViewControllers.count;i++) {
//        UIViewController * vc = [self.menuItemViewControllers objectAtIndex:i];
//        if ([vc isMemberOfClass:[ToolBarWebViewController class]])
//        {
//            return [NSIndexPath indexPathForRow:i inSection:0];
//        }
//    }
    
    for (int i = 0; i < self.menuItemNames.count; i++) {
        NSArray * ar = [self.menuItemNames objectAtIndex:i];
        for (SideBarModel * item in ar) {
            if ([item.vc isKindOfClass:[ToolBarWebViewController class]])
            {
                return [NSIndexPath indexPathForRow:item.row inSection:item.section];
            }
        }
    }
    
    return nil;
}

- (NSIndexPath *)getMenuItemIndexPath:(UIViewController *)vcc
{
//    for (int i = 0 ; i < self.menuItemViewControllers.count;i++) {
//        UIViewController * vc = [self.menuItemViewControllers objectAtIndex:i];
//        if (vc == vcc)
//        {
//            return [NSIndexPath indexPathForRow:i inSection:0];
//        }
//    }
    
    for (int i = 0; i < self.menuItemNames.count; i++) {
        NSArray * ar = [self.menuItemNames objectAtIndex:i];
        for (SideBarModel * item in ar) {
            if (item.vc == vcc)
            {
                return [NSIndexPath indexPathForRow:item.row inSection:item.section];
            }
        }
    }
    return nil;
}

- (void)setToolbarURL:(NSString*)url
{
    for (int i = 0 ; i < self.menuItemViewControllers.count;i++) {
        UIViewController * vc = [self.menuItemViewControllers objectAtIndex:i];
        if ([vc isMemberOfClass:[ToolBarWebViewController class]])
        {
            ((ToolBarWebViewController *)vc).entryUrl = url;
            break;
        }
    }
}

- (void)clearSnapShotsArray
{
    for (int i = 0 ; i < self.menuItemViewControllers.count;i++) {
        UIViewController * vc = [self.menuItemViewControllers objectAtIndex:i];
        if ([vc isMemberOfClass:[ToolBarWebViewController class]])
        {
            [((ToolBarWebViewController *)vc) clearSnapShotsArray];
            break;
        }
    }
}

- (void)replaceWebView
{
    for (int i = 0 ; i < self.menuItemViewControllers.count;i++) {
        UIViewController * vc = [self.menuItemViewControllers objectAtIndex:i];
        if ([vc isMemberOfClass:[ToolBarWebViewController class]])
        {
            [((ToolBarWebViewController *)vc) replaceWebView];
            break;
        }
    }
}

- (void)changeTitle:(NSString *)url{
    for (int i = 0 ; i < self.menuItemViewControllers.count;i++) {
        UIViewController * vc = [self.menuItemViewControllers objectAtIndex:i];
        if ([vc isMemberOfClass:[ToolBarWebViewController class]])
        {
            ((ToolBarWebViewController *)vc).textfield.text = url;
            break;
        }
    }
}

- (void)toggleSidebar:(id)isPan animationFinishBlock:(void (^)(BOOL finish))block{
    [self resign];
    float xPosition = self.containerController.view.frame.origin.x;
    if ([isPan isKindOfClass:[UIGestureRecognizer class]]) {
        if(xPosition < 250/2.0) {
            [UIView animateWithDuration:0.3f animations:^{
                self.containerController.view.frame = CGRectMake(0.0f, self.containerController.view.frame.origin.y, self.containerController.view.frame.size.width, self.containerController.view.frame.size.height);
            } completion:^(BOOL finished) {
                control.hidden = true;
                if (block) {
                    block(true);
                }
            }];
        }
        else {
            float distanceToMove = 250.0f;
            [UIView animateWithDuration:0.3f animations:^(void){
                self.containerController.view.frame = CGRectMake(distanceToMove, self.containerController.view.frame.origin.y, self.containerController.view.frame.size.width, self.containerController.view.frame.size.height);
            }completion:^(BOOL finished) {
                control.hidden = false;
                if (block) {
                    block(true);
                }
            }];
        }
    }
    else{
        if(xPosition > 0) {
            [UIView animateWithDuration:0.3f animations:^(void){
                self.containerController.view.frame = CGRectMake(0.0f, self.containerController.view.frame.origin.y, self.containerController.view.frame.size.width, self.containerController.view.frame.size.height);
            }completion:^(BOOL finished) {
                control.hidden = true;
                if (block) {
                    block(true);
                }
            }];
        }
        else {
            float distanceToMove = 250.0f;
            [UIView animateWithDuration:0.3f animations:^(void){
                self.containerController.view.frame = CGRectMake(distanceToMove, self.containerController.view.frame.origin.y, self.containerController.view.frame.size.width, self.containerController.view.frame.size.height);
            }completion:^(BOOL finished) {
                control.hidden = false;
                if (block) {
                    block(true);
                }
            }];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.menuItemNames.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.menuItemNames.count > section) {
        return ((NSArray *)self.menuItemNames[section]).count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (self.menuItemNames.count > indexPath.section)
    {
        NSArray * ar = (NSArray *)self.menuItemNames[indexPath.section];
        SideBarModel * m = [ar objectAtIndex:indexPath.row];
        m.section = indexPath.section;
        m.row = indexPath.row;
        [cell.textLabel setText:m.name];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.01;
    }
    return 10;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    
    [self selectIndexPath:indexPath animationFinishBlock:nil];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch locationInView:self.view].x > 50 && gestureRecognizer.state == UIGestureRecognizerStatePossible) {
        return false;
    }
    
    return true;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;
{
//    NSLog(@"gestureRecognizer = %@,%@,%@",gestureRecognizer,otherGestureRecognizer,[self.navigationController fd_fullscreenPopGestureRecognizer]);
    
//    NSLog(@"viewedsd = %@,%@,%i",otherGestureRecognizer.view,otherGestureRecognizer,[otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]);
    

//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
//    {
        if ([self.containerController.viewControllers.lastObject isKindOfClass:[UploadViewController class]] ||
            [self.containerController.viewControllers.lastObject isKindOfClass:[HostViewController class]])
        {
            if (otherGestureRecognizer.view.superview == ((UploadViewController*)self.containerController.viewControllers.lastObject).tableView)
            {
                return true;
            }
        }
        
        return false;
//    }
//
//    return true;
}

@end
