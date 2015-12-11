//
//  NCVideoPlayerViewController.m
//  SocialSearcher
//
//  Created by NakCheonJung on 11/1/15.
//  Copyright © 2015 ncjung. All rights reserved.
//

#import "NCVideoPlayerViewController.h"
#import <YTPlayerView.h>
#import "NCYoutubeDataContainer.h"

#pragma mark - Definition

@interface NCVideoPlayerViewController() <YTPlayerViewDelegate>
{
    UIVisualEffectView* _visualEffectView;

    // data
    NSString* _defaultVideoID;
    NSString* _strTitle;
}
@property (strong, nonatomic) IBOutlet UIView *viewBackground;
@property (strong, nonatomic) IBOutlet UIView *viewPlayerContainer;
@property (strong, nonatomic) IBOutlet UIButton *btnClose;
@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
// custom ui
@property (strong, nonatomic) YTPlayerView* defaultYoutubeVideoPlayer;
@end

@interface NCVideoPlayerViewController(CreateMethods)
-(BOOL)createBackground;
-(BOOL)createDefaultVideoPlayer;
-(BOOL)createTitle;
@end

@interface NCVideoPlayerViewController(PrivateMethods)
-(BOOL)privateInitializeSetting;
-(BOOL)privateInitializeUI;
@end

@interface NCVideoPlayerViewController(selectors)
// default youtube player
-(void)selectorReceivedPlaybackStartedNotification:(NSNotification*)notification;
@end

#pragma mark - Implementation

@implementation NCVideoPlayerViewController

#pragma mark - class life cycle

-(id)init
{
    self = [super init];
    if (self) {
        NSLog(@"NCVideoPlayerViewController::INIT");
    }
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self privateInitializeSetting];
    [self privateInitializeUI];
}

-(void)dealloc
{
    NSLog(@"NCVideoPlayerViewController::DEALLOC");
}

#pragma mark - view controller

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    // remove view - apples recommendation
    if (![self.navigationController.topViewController isEqual:self]) {
        UIViewController* topController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (topController.presentedViewController) {
            topController = topController.presentedViewController;
            if ([topController isEqual:self]) {
                break;
            }
        }
        if (!topController) {
            [self.view removeFromSuperview];
            self.view = nil;
        }
        else {
            DLog(@"NOT REMOVE VIEW::modal viewcontoller::%@", [self class]);
        }
    }
    else {
        DLog(@"NOT REMOVE VIEW::top viewcontoller::%@", [self class]);
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

-(void)viewDidLayoutSubviews
{
    _visualEffectView.frame = _viewBackground.bounds;

    NCVideoPlayerViewController* __weak weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong NCVideoPlayerViewController* strongSelf = weakSelf;
        strongSelf.defaultYoutubeVideoPlayer.frame = strongSelf.viewPlayerContainer.frame;
    });
}

#pragma mark - create methods

-(BOOL)createBackground
{
    // blur effect
    UIVisualEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView* visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = _viewBackground.bounds;
    _visualEffectView = visualEffectView;
    _visualEffectView.alpha = 1.0;
    [_viewBackground addSubview:_visualEffectView];

    return YES;
}

-(BOOL)createDefaultVideoPlayer
{
    if (!_defaultYoutubeVideoPlayer) {
        _defaultYoutubeVideoPlayer = [[YTPlayerView alloc] init];
        [self.view addSubview:_defaultYoutubeVideoPlayer];
        
        NSDictionary* playerVars = @{
                                     @"controls" : @1,
                                     @"playsinline" : @1,
                                     @"autohide" : @1,
                                     @"showinfo" : @0,
                                     @"modestbranding" : @1
                                     };
        _defaultYoutubeVideoPlayer.delegate = self;
        [_defaultYoutubeVideoPlayer loadWithVideoId:_defaultVideoID playerVars:playerVars];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(selectorReceivedPlaybackStartedNotification:)
                                                     name:@"Playback started"
                                                   object:nil];
    }
    
    return YES;
}

-(BOOL)createTitle
{
    _lblTitle.text = _strTitle;
    return YES;
}

#pragma mark - private methods

-(BOOL)privateInitializeSetting
{
    NSString* videoID = [_dicInfo valueForKeyPath:@"snippet.resourceId.videoId"];
    if (!videoID) {
        videoID = [_dicInfo valueForKeyPath:@"id.videoId"];
    }
    _defaultVideoID = videoID;
    
    _strTitle = [_dicInfo valueForKeyPath:@"snippet.title"];
    return YES;
}

-(BOOL)privateInitializeUI
{
    [self createBackground];
    [self createDefaultVideoPlayer];
    [self createTitle];
    return YES;
}

#pragma mark - selectors

-(void)selectorReceivedPlaybackStartedNotification:(NSNotification*)notification
{
    DLog(@"selectorReceivedPlaybackStartedNotification");
}

- (IBAction)selectorCloseButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - YTPlayerViewDelegate

/**
 * Invoked when the player view is ready to receive API calls.
 *
 * @param playerView The YTPlayerView instance that has become ready.
 */
- (void)playerViewDidBecomeReady:(YTPlayerView *)playerView
{
    DLog(@"playerViewDidBecomeReady");
}

/**
 * Callback invoked when player state has changed, e.g. stopped or started playback.
 *
 * @param playerView The YTPlayerView instance where playback state has changed.
 * @param state YTPlayerState designating the new playback state.
 */
- (void)playerView:(YTPlayerView *)playerView didChangeToState:(YTPlayerState)state
{
    NSString* message = [NSString stringWithFormat:@"Player state changed: %ld\n", (long)state];
    DLog(@"playerView:didChangeToState: %@", message);
    
    if (kYTPlayerStateUnstarted == state) {
        //[self createForcePlayButton];
    }
}

/**
 * Callback invoked when playback quality has changed.
 *
 * @param playerView The YTPlayerView instance where playback quality has changed.
 * @param quality YTPlaybackQuality designating the new playback quality.
 */
- (void)playerView:(YTPlayerView *)playerView didChangeToQuality:(YTPlaybackQuality)quality
{
    DLog(@"playerView:didChangeToQuality");
}

/**
 * Callback invoked when an error has occured.
 *
 * @param playerView The YTPlayerView instance where the error has occurred.
 * @param error YTPlayerError containing the error state.
 */
- (void)playerView:(YTPlayerView *)playerView receivedError:(YTPlayerError)error
{
    DLog(@"playerView:receivedError");
}


/**
 * Callback invoked frequently when playBack is plaing.
 *
 * @param playerView The YTPlayerView instance where the error has occurred.
 * @param playTime float containing curretn playback time.
 */
- (void)playerView:(YTPlayerView *)playerView didPlayTime:(float)playTime
{
    DLog(@"playerView:didPlayTime");
}

@end
