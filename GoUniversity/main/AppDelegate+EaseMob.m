
#import "AppDelegate+EaseMob.h"
#import "EMCallManagerDelegate.h"

@implementation AppDelegate (EaseMob)
- (void)easemobApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    if (launchOptions) {
        NSDictionary*userInfo = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
        if(userInfo)
        {
            [self didReceiveRemoteNotification:userInfo];
        }
    }
    
//    _connectionState = eEMConnectionConnected;
    
    [self registerRemoteNotification];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *appkey = [ud stringForKey:@"identifier_appkey"];
    if (!appkey)
    {
        appkey = @"pinlv#gouniversity";
        [ud setObject:appkey forKey:@"identifier_appkey"];
    }
    NSNumber *specifyServer = [ud objectForKey:@"identifier_enable"];
    if (!specifyServer)
    {
        specifyServer = [NSNumber numberWithBool:NO];
        [ud setObject:specifyServer forKey:@"identifier_enable"];
    }
    NSString *imServer = [ud stringForKey:@"identifier_imserver"];
    if (!imServer)
    {
        imServer = @"im1.easemob.com";
        [ud setObject:imServer forKey:@"identifier_imserver"];
    }
    NSString *imPort = [ud stringForKey:@"identifier_import"];
    if (!imPort)
    {
        imPort = @"443";
        [ud setObject:imPort forKey:@"identifier_import"];
    }
    NSString *restServer = [ud stringForKey:@"identifier_restserver"];
    if (!restServer)
    {
        restServer = @"a1.easemob.com";
        [ud setObject:restServer forKey:@"identifier_restserver"];
    }
    [ud synchronize];
    
#warning SDK注册 APNS文件的名字, 需要与后台上传证书时的名字一一对应
    NSString *apnsCertName = nil;
#if DEBUG
    apnsCertName = @"chatdemoui_dev";
#else
    apnsCertName = @"chatdemoui";
#endif

    if (![specifyServer boolValue])
    {
        [[EaseMob sharedInstance] registerSDKWithAppKey:appkey
                                           apnsCertName:apnsCertName
                                            otherConfig:@{kSDKConfigEnableConsoleLogger:[NSNumber numberWithBool:YES]}];
    }
    else
    {
        //Only for internal use to test
        NSDictionary *dic = @{kSDKAppKey:appkey,
                              kSDKApnsCertName:apnsCertName,
                              kSDKServerApi:restServer,
                              kSDKServerChat:imServer,
                              kSDKServerGroupDomain:@"conference.easemob.com",
                              kSDKServerChatDomain:@"easemob.com",
                              kSDKServerChatPort:imPort};
        id easemob = [EaseMob sharedInstance];
        SEL selector = @selector(registerPrivateServerWithParams:);
        [easemob performSelector:selector withObject:dic];
    }
    
    // 登录成功后，自动去取好友列表
    // SDK获取结束后，会回调
    // - (void)didFetchedBuddyList:(NSArray *)buddyList error:(EMError *)error方法。
    [[EaseMob sharedInstance].chatManager setIsAutoFetchBuddyList:YES];
    
    // 注册环信监听
    [self registerEaseMobNotification];
    [[EaseMob sharedInstance] application:application
            didFinishLaunchingWithOptions:launchOptions];
    
    [self setupNotifiers];
}


// 监听系统生命周期回调，以便将需要的事件传给SDK
- (void)setupNotifiers{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidEnterBackgroundNotif:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidFinishLaunching:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidBecomeActiveNotif:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillResignActiveNotif:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appDidReceiveMemoryWarning:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWillTerminateNotif:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appProtectedDataWillBecomeUnavailableNotif:)
                                                 name:UIApplicationProtectedDataWillBecomeUnavailable
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appProtectedDataDidBecomeAvailableNotif:)
                                                 name:UIApplicationProtectedDataDidBecomeAvailable
                                               object:nil];
}

#pragma mark - notifiers
- (void)appDidEnterBackgroundNotif:(NSNotification*)notif{
    [[EaseMob sharedInstance] applicationDidEnterBackground:notif.object];
}

- (void)appWillEnterForeground:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationWillEnterForeground:notif.object];
}

- (void)appDidFinishLaunching:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationDidFinishLaunching:notif.object];
}

- (void)appDidBecomeActiveNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationDidBecomeActive:notif.object];
}

- (void)appWillResignActiveNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationWillResignActive:notif.object];
}

- (void)appDidReceiveMemoryWarning:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationDidReceiveMemoryWarning:notif.object];
}

- (void)appWillTerminateNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationWillTerminate:notif.object];
}

- (void)appProtectedDataWillBecomeUnavailableNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationProtectedDataWillBecomeUnavailable:notif.object];
}

- (void)appProtectedDataDidBecomeAvailableNotif:(NSNotification*)notif
{
    [[EaseMob sharedInstance] applicationProtectedDataDidBecomeAvailable:notif.object];
}

// 将得到的deviceToken传给SDK
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    [[EaseMob sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

// 注册deviceToken失败，此处失败，与环信SDK无关，一般是您的环境配置或者证书配置有误
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    [[EaseMob sharedInstance] application:application didFailToRegisterForRemoteNotificationsWithError:error];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"apns.failToRegisterApns", Fail to register apns)
                                                    message:error.description
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                          otherButtonTitles:nil];
    [alert show];
}

// 注册推送
- (void)registerRemoteNotification{
    UIApplication *application = [UIApplication sharedApplication];
    application.applicationIconBadgeNumber = 0;

    if([application respondsToSelector:@selector(registerUserNotificationSettings:)])
    {
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    }
}

#pragma mark - registerEaseMobNotification
- (void)registerEaseMobNotification{
    [self unRegisterEaseMobNotification];
    // 将self 添加到SDK回调中，以便本类可以收到SDK回调
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

- (void)unRegisterEaseMobNotification{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}



#pragma mark - IChatManagerDelegate
// 开始自动登录回调
-(void)willAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error
{
    UIAlertView *alertView = nil;
    if (error) {
        alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"login.errorAutoLogin", @"Automatic logon failure") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        
        //发送自动登陆状态通知
        
    }
    else{
//        alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"login.beginAutoLogin", @"Start automatic login...") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        
        //将旧版的coredata数据导入新的数据库
        EMError *error = [[EaseMob sharedInstance].chatManager importDataToNewDatabase];
        if (!error) {
            error = [[EaseMob sharedInstance].chatManager loadDataFromDatabase];
        }
    }
    
    [alertView show];
}

// 结束自动登录回调
-(void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error
{
    UIAlertView *alertView = nil;
    if (error) {
        alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"login.errorAutoLogin", @"Automatic logon failure") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        
        //发送自动登陆状态通知
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        [def setObject:[NSNumber numberWithBool:NO] forKey:@"loginstate"];
        [def synchronize];
    }
    else{
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        [def setObject:[NSNumber numberWithBool:YES] forKey:@"loginstate"];
        [def synchronize];
        //获取群组列表
        [[EaseMob sharedInstance].chatManager asyncFetchMyGroupsList];
        
//        alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:NSLocalizedString(@"login.endAutoLogin", @"End automatic login...") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    }
    
    [alertView show];
}

// 好友申请回调
- (void)didReceiveBuddyRequest:(NSString *)username
                       message:(NSString *)message
{
   
}

// 离开群组回调
- (void)group:(EMGroup *)group didLeave:(EMGroupLeaveReason)reason error:(EMError *)error
{
    NSString *tmpStr = group.groupSubject;
    NSString *str;
    if (!tmpStr || tmpStr.length == 0) {
        NSArray *groupArray = [[EaseMob sharedInstance].chatManager groupList];
        for (EMGroup *obj in groupArray) {
            if ([obj.groupId isEqualToString:group.groupId]) {
                tmpStr = obj.groupSubject;
                break;
            }
        }
    }
    
    if (reason == eGroupLeaveReason_BeRemoved) {
        str = [NSString stringWithFormat:NSLocalizedString(@"group.beKicked", @"you have been kicked out from the group of \'%@\'"), tmpStr];
    }
   
}

// 申请加入群组被拒绝回调
- (void)didReceiveRejectApplyToJoinGroupFrom:(NSString *)fromId
                                   groupname:(NSString *)groupname
                                      reason:(NSString *)reason
                                       error:(EMError *)error{
    if (!reason || reason.length == 0) {
        reason = [NSString stringWithFormat:NSLocalizedString(@"group.beRefusedToJoin", @"be refused to join the group\'%@\'"), groupname];
    }
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:reason delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}

//接收到入群申请
- (void)didReceiveApplyToJoinGroup:(NSString *)groupId
                         groupname:(NSString *)groupname
                     applyUsername:(NSString *)username
                            reason:(NSString *)reason
                             error:(EMError *)error
{
    if (!groupId || !username) {
        return;
    }
    
    if (!reason || reason.length == 0) {
        reason = [NSString stringWithFormat:NSLocalizedString(@"group.applyJoin", @"%@ apply to join groups\'%@\'"), username, groupname];
    }
    else{
        reason = [NSString stringWithFormat:NSLocalizedString(@"group.applyJoinWithName", @"%@ apply to join groups\'%@\'：%@"), username, groupname, reason];
    }
    
}

// 已经同意并且加入群组后的回调
- (void)didAcceptInvitationFromGroup:(EMGroup *)group
                               error:(EMError *)error
{
    if(error)
    {
        return;
    }
    
    NSString *groupTag = group.groupSubject;
    if ([groupTag length] == 0) {
        groupTag = group.groupId;
    }
    
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"group.agreedAndJoined", @"agreed and joined the group of \'%@\'"), groupTag];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"prompt", @"Prompt") message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}


// 绑定deviceToken回调
- (void)didBindDeviceWithError:(EMError *)error
{
    
}

// 网络状态变化回调
- (void)didConnectionStateChanged:(EMConnectionState)connectionState
{
}

// 打印收到的apns信息
-(void)didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSError *parseError = nil;
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:userInfo
                                                        options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *str =  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"apns.content", @"Apns content")
                                                    message:str
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"ok", @"OK")
                                          otherButtonTitles:nil];
    [alert show];

}

@end
