#import "JRBiblePlayback.h"
#import "JRBiblePlaybackPolicy.h"
@import AVFoundation;
@import MediaPlayer;

NSString * const JRBiblePlaybackChanged = @"JRBiblePlaybackChanged";
@interface JRBiblePlayback ()
@property (nonatomic, readwrite) NSArray *books;
@property (nonatomic, readwrite) NSString *playingBookID;
@property (nonatomic, copy, readwrite) NSArray<NSDictionary *> *playingItems;
@property (nonatomic) STKAudioPlayer *player;
@property (nonatomic) NSTimer *heartbeat;
@property (nonatomic) double pendingSeek;
@property (nonatomic) NSDate *sleepDeadline;
@property (nonatomic, readwrite) NSInteger sleepMode;
@property (nonatomic) NSString *sleepBookID;
@property (nonatomic) NSUInteger generation;
@property (nonatomic) NSString *programName;
@property (nonatomic) MPMediaItemArtwork *programArtwork;
@property (nonatomic, copy) NSDictionary *currentItem;
@property (nonatomic) BOOL moving;
@property (nonatomic) BOOL sleepAwaitingPlayback;
@end
@implementation JRBiblePlayback
+ (instancetype)shared { static JRBiblePlayback *value; static dispatch_once_t once; dispatch_once(&once, ^{ value = [self new]; }); return value; }
- (NSString *)storageKey { return [NSString stringWithFormat:@"BibleResume.%d", [URLAddressManager getLocal]]; }
- (NSDictionary *)resumeRecord { return [[NSUserDefaults standardUserDefaults] dictionaryForKey:self.storageKey]; }
- (NSInteger)repeatMode { return [[NSUserDefaults standardUserDefaults] integerForKey:@"BibleRepeatMode"] % 3; }
- (void)setRepeatMode:(NSInteger)value { [[NSUserDefaults standardUserDefaults] setInteger:value % 3 forKey:@"BibleRepeatMode"]; [self changed]; }
- (BOOL)active {
    // PR_ID is also updated by the legacy live-info poller. Audio ownership and
    // the actual AOD item identify this session, independently of browsing/live metadata.
    return self.player && self.player == ((AppDelegate *)UIApplication.sharedApplication.delegate).avAudioPlayer &&
        [GetCommonData.audio_mode isEqualToString:@"AOD"] && [GetCommonData.aodData[@"PR_ID"] isEqualToString:@"002005"];
}
- (void)changed { [self updateNowPlayingInfo]; [[NSNotificationCenter defaultCenter] postNotificationName:JRBiblePlaybackChanged object:self]; }
- (NSString *)baseURL { return [URLAddressManager getLocal] == ES ? BASE_URL_ES : ([URLAddressManager getLocal] == PT ? BASE_URL_PT : BASE_URL_KR); }
- (void)loadBooks:(void (^)(BOOL))completion {
    NSString *key = [NSString stringWithFormat:@"BibleBooks.%d", [URLAddressManager getLocal]];
    [GetURLAddressManager getProgramList:[self.baseURL stringByAppendingString:@"/api/program/getBibleBooks"] CompletionHandler:^(id data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *books = [data isKindOfClass:NSDictionary.class] ? data[@"data"] : nil;
            BOOL valid = !error && [books isKindOfClass:NSArray.class] && books.count > 0;
            if (valid) { self.books = books; [[NSUserDefaults standardUserDefaults] setObject:books forKey:key]; }
            else self.books = [[NSUserDefaults standardUserDefaults] arrayForKey:key];
            completion(self.books.count > 0);
        });
    }];
}
- (void)loadBook:(NSString *)bookID completion:(void (^)(NSArray *, NSDictionary *, NSError *))completion {
    NSString *url = [NSString stringWithFormat:@"%@/api/program/view/PR_ID/002005/BB_ID/%@/oType/asc/limit/200", self.baseURL, bookID];
    [GetURLAddressManager getProgramList:url CompletionHandler:^(id data, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *contents = [data isKindOfClass:NSDictionary.class] ? data[@"CONTENTS"] : nil;
            NSArray *items = [contents isKindOfClass:NSDictionary.class] ? contents[@"data"] : nil;
            NSDictionary *info = [data isKindOfClass:NSDictionary.class] && [data[@"PR_INFO"] isKindOfClass:NSDictionary.class] ? data[@"PR_INFO"][@"data"] : nil;
            BOOL empty = [contents isKindOfClass:NSDictionary.class] && [contents[@"status"] integerValue] == 400;
            NSError *failure = error;
            if (!failure && !empty && ![items isKindOfClass:NSArray.class]) failure = [NSError errorWithDomain:@"BibleAPI" code:1 userInfo:nil];
            completion([items isKindOfClass:NSArray.class] ? items : @[], [info isKindOfClass:NSDictionary.class] ? info : nil, failure);
        });
    }];
}
- (void)playItem:(NSDictionary *)item bookID:(NSString *)bookID items:(NSArray *)items position:(double)position {
    if (![item[@"CT_SOURCE_STREAM"] isKindOfClass:NSString.class] || !bookID.length) return;
    [self savePosition];
    self.generation++; self.moving = NO;
    [((AppDelegate *)UIApplication.sharedApplication.delegate).avAudioPlayer stop];
    self.currentItem = item;
    self.playingBookID = bookID; self.playingItems = items; self.pendingSeek = MAX(0, position);
    GetCommonData.playingAODGroupItems = nil;
    GetCommonData.PR_ID = @"002005"; GetCommonData.aodData = item; GetCommonData.CT_NO = item[@"CT_NO"]; GetCommonData.audio_mode = @"AOD";
    STKAudioPlayerOptions options = {0}; options.enableVolumeMixer = YES;
    self.player = [[STKAudioPlayer alloc] initWithOptions:options];
    ((AppDelegate *)UIApplication.sharedApplication.delegate).avAudioPlayer = self.player; self.player.delegate = self;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [self.player playURL:[NSURL URLWithString:item[@"CT_SOURCE_STREAM"]]];
    self.sleepAwaitingPlayback = NO;
    if (self.sleepMode == 5) self.sleepBookID = bookID;
    [self startHeartbeat];
    [self savePosition]; [self changed];
}
- (void)startHeartbeat {
    if (!self.heartbeat) {
        self.heartbeat = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(tick) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.heartbeat forMode:NSRunLoopCommonModes];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(savePosition) name:UIApplicationDidEnterBackgroundNotification object:nil];
        MPRemoteCommandCenter *commands = MPRemoteCommandCenter.sharedCommandCenter;
        [commands.nextTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) { if (!self.active) return MPRemoteCommandHandlerStatusNoSuchContent; [self move:1 automatic:NO]; return MPRemoteCommandHandlerStatusSuccess; }];
        [commands.previousTrackCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) { if (!self.active) return MPRemoteCommandHandlerStatusNoSuchContent; [self move:-1 automatic:NO]; return MPRemoteCommandHandlerStatusSuccess; }];
        [commands.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) { if (!self.active) return MPRemoteCommandHandlerStatusNoSuchContent; [self.player resume]; return MPRemoteCommandHandlerStatusSuccess; }];
        [commands.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent *event) { if (!self.active) return MPRemoteCommandHandlerStatusNoSuchContent; self.generation++; self.moving = NO; [self.player pause]; [self savePosition]; return MPRemoteCommandHandlerStatusSuccess; }];
    }
}
- (void)savePosition {
    if (!self.active || self.player.state == STKAudioPlayerStateError) return;
    double position = self.pendingSeek > 0 ? self.pendingSeek : self.player.progress;
    [[NSUserDefaults standardUserDefaults] setObject:@{@"BB_ID":self.playingBookID, @"CT_NO":GetCommonData.CT_NO, @"title":GetCommonData.aodData[@"CT_NAME"] ?: @"", @"position":@(position)} forKey:self.storageKey];
}
- (void)togglePlayback {
    if (!self.active) return;
    if (self.player.state == STKAudioPlayerStatePaused) [self.player resume];
    else if (self.player.state == STKAudioPlayerStateStopped || self.player.state == STKAudioPlayerStateError) {
        [self playItem:GetCommonData.aodData bookID:self.playingBookID items:self.playingItems position:[self.resumeRecord[@"position"] doubleValue]];
    }
    else { self.generation++; self.moving = NO; [self savePosition]; [self.player pause]; }
    [self changed];
}
- (void)move:(NSInteger)direction automatic:(BOOL)automatic {
    if (!self.active || self.moving) return;
    NSUInteger index = [self.playingItems indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) { return [item[@"CT_NO"] isEqual:GetCommonData.CT_NO]; }];
    if (index == NSNotFound) return;
    BOOL stopAtBookEnd = self.sleepMode == 5 && [self.sleepBookID isEqual:self.playingBookID];
    NSInteger next = JRBibleNextChapter(index, self.playingItems.count, (int)direction, automatic, (int)self.repeatMode, stopAtBookEnd);
    if (next == JRBibleStop) { self.sleepMode = 0; [self changed]; return; }
    if (next >= 0) { [self playItem:self.playingItems[next] bookID:self.playingBookID items:self.playingItems position:0]; return; }
    NSUInteger bookIndex = [self.books indexOfObjectPassingTest:^BOOL(NSDictionary *book, NSUInteger idx, BOOL *stop) { return [book[@"BB_ID"] isEqual:self.playingBookID]; }];
    if (bookIndex == NSNotFound) return;
    NSInteger target = (NSInteger)bookIndex + direction;
    while (target >= 0 && target < self.books.count && [self.books[target][@"count"] integerValue] == 0) target += direction;
    if (target < 0 || target >= self.books.count) { [self changed]; return; }
    NSString *bookID = self.books[target][@"BB_ID"]; NSUInteger generation = self.generation;
    self.moving = YES;
    __block UIBackgroundTaskIdentifier task = [UIApplication.sharedApplication beginBackgroundTaskWithExpirationHandler:^{}];
    [self loadBook:bookID completion:^(NSArray *items, NSDictionary *info, NSError *error) {
        if (generation == self.generation && self.active) {
            self.moving = NO;
            if (!error && items.count) { if (info) GetCommonData.aodMetaData = info; [self playItem:direction > 0 ? items.firstObject : items.lastObject bookID:bookID items:items position:0]; }
            else [self changed];
        }
        if (task != UIBackgroundTaskInvalid) { [UIApplication.sharedApplication endBackgroundTask:task]; task = UIBackgroundTaskInvalid; }
    }];
}
- (void)cycleSleep {
    self.sleepMode = (self.sleepMode + 1) % 6;
    self.sleepAwaitingPlayback = self.sleepMode && !self.active;
    [self startHeartbeat];
    NSInteger minutes[] = {0,15,30,60,120,0};
    self.sleepDeadline = self.sleepMode > 0 && self.sleepMode < 5 ? [NSDate dateWithTimeIntervalSinceNow:minutes[self.sleepMode] * 60] : nil;
    self.sleepBookID = self.playingBookID; self.player.volume = 1; [self changed];
}
- (NSString *)sleepLabel {
    if (self.sleepMode == 5) return @"이 권 끝나면";
    if (!self.sleepDeadline) return @"끄기";
    NSInteger seconds = MAX(0, (NSInteger)ceil(self.sleepDeadline.timeIntervalSinceNow));
    return [NSString stringWithFormat:@"%ld:%02ld", (long)seconds/60, (long)seconds%60];
}
- (void)tick {
    if (!self.active) {
        if (!self.sleepAwaitingPlayback || (self.sleepDeadline && self.sleepDeadline.timeIntervalSinceNow <= 0)) {
            self.sleepMode = 0; self.sleepDeadline = nil; self.sleepAwaitingPlayback = NO;
        }
        [self changed]; return;
    }
    [self restorePendingSeekIfReady];
    [self savePosition];
    if (self.sleepDeadline) {
        double remaining = self.sleepDeadline.timeIntervalSinceNow;
        self.player.volume = MIN(1, MAX(0, remaining / 5));
        if (remaining <= 0) { self.generation++; self.moving = NO; [self.player pause]; self.player.volume = 1; self.sleepDeadline = nil; self.sleepMode = 0; }
    }
    [self changed];
}
- (void)updateProgramInfo:(NSDictionary *)info artwork:(UIImage *)artwork {
    NSString *name = info[@"PR_NAME"];
    if ([name isKindOfClass:NSString.class] && name.length) self.programName = name;
    if (artwork) {
        // Capture this image; a handler reading CommonData.thum can return another program later.
        UIImage *image = artwork;
        self.programArtwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:image.size requestHandler:^UIImage *(CGSize size) { return image; }];
    }
    [self updateNowPlayingInfo];
}
- (void)updateNowPlayingInfo {
    if (!self.active) return;
    NSString *name = self.programName ?: @"성경낭독";
    NSString *chapter = (self.currentItem ?: GetCommonData.aodData)[@"CT_NAME"];
    if (![chapter isKindOfClass:NSString.class]) chapter = @"";
    if (!self.programArtwork) {
        UIImage *image = [UIImage imageNamed:@"default_image"];
        if (image) self.programArtwork = [[MPMediaItemArtwork alloc] initWithBoundsSize:image.size requestHandler:^UIImage *(CGSize size) { return image; }];
    }
    // Replace the complete record, including artist/album/artwork from the prior program.
    NSMutableDictionary *info = [@{
        MPMediaItemPropertyTitle: chapter.length ? [NSString stringWithFormat:@"%@ %@", name, chapter] : name,
        MPMediaItemPropertyArtist: name,
        MPMediaItemPropertyAlbumTitle: name,
        MPNowPlayingInfoPropertyElapsedPlaybackTime: @(self.player.progress),
        MPMediaItemPropertyPlaybackDuration: @(self.player.duration),
        MPNowPlayingInfoPropertyPlaybackRate: @(self.player.state == STKAudioPlayerStatePlaying ? 1 : 0),
        MPNowPlayingInfoPropertyIsLiveStream: @NO
    } mutableCopy];
    if (self.programArtwork) info[MPMediaItemPropertyArtwork] = self.programArtwork;
    MPNowPlayingInfoCenter.defaultCenter.nowPlayingInfo = info;
}
// Streaming duration may arrive after the first Playing callback.
- (void)restorePendingSeekIfReady {
    if (!self.active || self.pendingSeek <= 0 || self.player.duration <= 0 || self.player.state != STKAudioPlayerStatePlaying) return;
    double seek = self.pendingSeek; self.pendingSeek = 0;
    [self.player seekToTime:MIN(seek, MAX(0, self.player.duration - 1))];
}
- (void)audioPlayer:(STKAudioPlayer *)player stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (player != self.player || !self.active) return;
        if (state == STKAudioPlayerStatePlaying) [self restorePendingSeekIfReady];
        [((AppDelegate *)UIApplication.sharedApplication.delegate) stopAnimatedLodingView]; [self changed];
    });
}
- (void)audioPlayer:(STKAudioPlayer *)player didFinishPlayingQueueItemId:(NSObject *)queueItemId withReason:(STKAudioPlayerStopReason)reason andProgress:(double)progress andDuration:(double)duration {
    dispatch_async(dispatch_get_main_queue(), ^{ if (player == self.player && self.active && reason == STKAudioPlayerStopReasonEof) { [self move:1 automatic:YES]; } });
}
- (void)audioPlayer:(STKAudioPlayer *)player didStartPlayingQueueItemId:(NSObject *)queueItemId {}
- (void)audioPlayer:(STKAudioPlayer *)player didFinishBufferingSourceWithQueueItemId:(NSObject *)queueItemId {}
- (void)audioPlayer:(STKAudioPlayer *)player didCancelQueuedItems:(NSArray *)queuedItems {}
- (void)audioPlayer:(STKAudioPlayer *)player unexpectedError:(STKAudioPlayerErrorCode)errorCode {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (player != self.player || !self.active) return;
        self.generation++;
        self.moving = NO;
        [((AppDelegate *)UIApplication.sharedApplication.delegate) stopAnimatedLodingView];
        [self changed];
    });
}
@end
