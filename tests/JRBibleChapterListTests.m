#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
@import MediaPlayer;
#import "AppDelegate.h"
#import "CommonData.h"
#import "UIAODSubListViewController.h"
#import "JRBiblePlayback.h"

@interface UIAODSubListViewController (ChapterListTests)
- (void)setupBible;
- (void)updatePlaybackProgressFromTimer:(NSTimer *)timer;
- (void)selectBibleBookButton:(UIButton *)button;
- (void)renderBooks;
- (void)changeBibleTestament;
- (void)biblePlaybackChanged;
- (void)selectBibleBook:(NSString *)bookID;
- (BOOL)usesProgramGroups;
- (void)renderProgramGroups;
- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@end

// Replace only the audio/network boundary. Notifications, list updates, request
// invalidation and the table data source below execute the production controller.
@interface JRPlaybackFixture : JRBiblePlayback
@property (nonatomic) NSString *fixtureBookID;
@property (nonatomic) NSArray *fixtureItems;
@property (nonatomic) NSString *nextBookID;
@property (nonatomic) NSArray *nextItems;
@property (nonatomic) NSMutableArray *pendingLoads;
@property (nonatomic) NSDictionary *selectedItem;
@property (nonatomic) NSString *selectedBook;
@property (nonatomic) double selectedPosition;
@end
@implementation JRPlaybackFixture
- (BOOL)active { return YES; }
- (NSString *)playingBookID { return self.fixtureBookID; }
- (NSArray *)playingItems { return self.fixtureItems; }
- (NSArray *)books { return @[@{@"BB_ID":@"01", @"name":@"창세기", @"chapters":@8, @"unit":@"장", @"count":@8, @"testament":@"OT"}, @{@"BB_ID":@"02", @"name":@"출애굽기", @"chapters":@8, @"unit":@"장", @"count":@8, @"testament":@"OT"}]; }
- (NSInteger)repeatMode { return 0; }
- (NSInteger)sleepMode { return 0; }
- (NSDictionary *)resumeRecord { return nil; }
- (void)loadBooks:(void (^)(BOOL))completion { completion(YES); }
- (void)loadBook:(NSString *)bookID completion:(void (^)(NSArray *, NSDictionary *, NSError *))completion {
    [self.pendingLoads addObject:[completion copy]];
}
- (void)playItem:(NSDictionary *)item bookID:(NSString *)bookID items:(NSArray *)items position:(double)position {
    self.selectedItem = item; self.selectedBook = bookID; self.selectedPosition = position;
}
- (void)move:(NSInteger)direction automatic:(BOOL)automatic {
    if (self.nextItems) {
        self.fixtureBookID = self.nextBookID; self.fixtureItems = self.nextItems;
        GetCommonData.CT_NO = self.fixtureItems.firstObject[@"CT_NO"];
    } else {
        NSUInteger index = [self.fixtureItems indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) { return [item[@"CT_NO"] isEqual:GetCommonData.CT_NO]; }];
        GetCommonData.CT_NO = self.fixtureItems[index + direction][@"CT_NO"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:JRBiblePlaybackChanged object:self];
}
@end

@interface JRChapterListControllerFixture : UIAODSubListViewController
@end
@implementation JRChapterListControllerFixture
- (void)loadView { self.view = [[UIView alloc] initWithFrame:CGRectMake(0,0,390,844)]; }
- (void)viewDidLoad {
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0,700,390,144)];
    self.tb_AODSubList = [[UITableView alloc] initWithFrame:CGRectMake(0,0,390,640) style:UITableViewStylePlain];
    self.tb_AODSubList.dataSource = (id<UITableViewDataSource>)self;
    self.tb_AODSubList.delegate = (id<UITableViewDelegate>)self;
    [self.view addSubview:self.tb_AODSubList];
    [self setValue:[UIView new] forKey:@"biblePanel"];
}
- (void)playAOD { }
@end

@interface JRSharedPlayerControllerFixture : UIBaseViewController
@property (nonatomic) NSUInteger playbackStarts;
@end
@implementation JRSharedPlayerControllerFixture
- (void)playAOD {
    self.playbackStarts++;
    GetCommonData.CT_NO = GetCommonData.aodData[@"CT_NO"];
}
@end

@interface JRBiblePlayback (ResumeTimerTests)
- (void)tick;
- (void)restorePendingSeekIfReady;
@end
@interface JRTimerResumeFixture : JRBiblePlayback
@property (nonatomic) BOOL fixtureActive;
@end
@implementation JRTimerResumeFixture
- (BOOL)active { return self.fixtureActive; }
- (void)savePosition {}
- (void)startHeartbeat {} // Keep this isolated session out of global remote commands.
@end
@interface JRSeekProbe : NSObject
@property (nonatomic) double progress;
@property (nonatomic) float volume;
@property (nonatomic) double duration;
@property (nonatomic) double soughtPosition;
@property (nonatomic) NSInteger seekCount;
@end
@implementation JRSeekProbe
- (STKAudioPlayerState)state { return STKAudioPlayerStatePlaying; }
- (void)seekToTime:(double)position { self.soughtPosition = position; self.seekCount++; }
@end

static JRPlaybackFixture *playbackFixture;
static JRBiblePlayback *nowPlayingSessionOverride;
static id JRFixtureShared(id cls, SEL selector) { return nowPlayingSessionOverride ?: playbackFixture; }

@interface JRBibleChapterListTests : XCTestCase
@property (nonatomic) JRChapterListControllerFixture *controller;
@property (nonatomic) IMP originalShared;
@property (nonatomic) NSDictionary *savedState;
@end
@implementation JRBibleChapterListTests
- (NSArray *)itemsForBook:(NSString *)bookID {
    NSMutableArray *items = [NSMutableArray new];
    for (NSInteger i = 1; i <= 8; i++) [items addObject:@{@"PR_ID":@"002005", @"CT_NO":[NSString stringWithFormat:@"%@-%ld",bookID,(long)i], @"CT_NAME":[NSString stringWithFormat:@"%@ %ld장",[bookID isEqual:@"01"] ? @"창세기" : @"출애굽기",(long)i]}];
    return items;
}
- (void)setUp {
    [super setUp];
    self.savedState = @{@"CT_NO":GetCommonData.CT_NO ?: NSNull.null, @"PR_ID":GetCommonData.PR_ID ?: NSNull.null, @"audio_mode":GetCommonData.audio_mode ?: NSNull.null, @"aodData":GetCommonData.aodData ?: NSNull.null, @"playingAODGroupItems":GetCommonData.playingAODGroupItems ?: NSNull.null};
    playbackFixture = [JRPlaybackFixture new]; playbackFixture.fixtureBookID = @"01"; playbackFixture.fixtureItems = [self itemsForBook:@"01"]; playbackFixture.pendingLoads = [NSMutableArray new];
    self.originalShared = method_setImplementation(class_getClassMethod(JRBiblePlayback.class,@selector(shared)), (IMP)JRFixtureShared);
    GetCommonData.PR_ID = @"002005"; GetCommonData.audio_mode = @"AOD"; GetCommonData.CT_NO = playbackFixture.fixtureItems.firstObject[@"CT_NO"];
    self.controller = [JRChapterListControllerFixture new]; self.controller.PR_ID = @"002005";
    [self.controller loadViewIfNeeded];
    [self.controller setValue:@"01" forKey:@"selectedBookID"];
    self.controller.arr_programSubList = playbackFixture.fixtureItems;
    [[NSNotificationCenter defaultCenter] addObserver:self.controller selector:@selector(biblePlaybackChanged) name:JRBiblePlaybackChanged object:nil];
}
- (void)tearDown {
    [[NSNotificationCenter defaultCenter] removeObserver:self.controller];
    method_setImplementation(class_getClassMethod(JRBiblePlayback.class,@selector(shared)), self.originalShared);
    for (NSString *key in self.savedState) [GetCommonData setValue:self.savedState[key] == NSNull.null ? nil : self.savedState[key] forKey:key];
    self.controller = nil; playbackFixture = nil; nowPlayingSessionOverride = nil;
    [super tearDown];
}
- (void)assertPlayingBookVisible {
    XCTAssertEqualObjects([self.controller valueForKey:@"selectedBookID"], playbackFixture.playingBookID);
    XCTAssertEqualObjects(self.controller.arr_programSubList, playbackFixture.fixtureItems);
    XCTAssertEqual([self.controller tableView:self.controller.tb_AODSubList numberOfRowsInSection:0], 8);
    XCTAssertEqual(playbackFixture.pendingLoads.count, 0, @"A track transition already has its book; do not clear it and refetch.");
}
- (void)testNextChapterKeepsSameBookVisible {
    [self.controller nextTrack];
    [self assertPlayingBookVisible];
}
- (void)testNextChapterReturnsFromBrowsingAnotherBookWithoutEmptyingTheList {
    [self.controller setValue:@"02" forKey:@"selectedBookID"];
    self.controller.arr_programSubList = [self itemsForBook:@"02"];
    [self.controller nextTrack];
    [self assertPlayingBookVisible];
}
- (void)testNextBookUsesAlreadyLoadedChaptersWithoutASecondRequest {
    playbackFixture.nextBookID = @"02"; playbackFixture.nextItems = [self itemsForBook:@"02"];
    [self.controller nextTrack];
    [self assertPlayingBookVisible];
}
- (void)testNextChapterRecoversAnEmptySameBookList {
    self.controller.arr_programSubList = @[];
    [self.controller nextTrack];
    [self assertPlayingBookVisible];
}
- (void)testDelayedBrowseResponseCannotOverwriteThePlayingBook {
    [self.controller selectBibleBook:@"02"];
    void (^completeOldRequest)(NSArray *, NSDictionary *, NSError *) = playbackFixture.pendingLoads.lastObject;
    [playbackFixture.pendingLoads removeAllObjects];
    [self.controller nextTrack];
    completeOldRequest([self itemsForBook:@"02"], nil, nil);
    [self assertPlayingBookVisible];
}
- (void)testHeartbeatPreservesAnotherBookUntilTheChapterActuallyChanges {
    [self.controller biblePlaybackChanged];
    [self.controller setValue:@"02" forKey:@"selectedBookID"];
    NSArray *browsingItems = [self itemsForBook:@"02"];
    self.controller.arr_programSubList = browsingItems;
    [self.controller setValue:@"02" forKey:@"loadedBibleBookID"];
    [self.controller biblePlaybackChanged];
    XCTAssertEqualObjects([self.controller valueForKey:@"selectedBookID"], @"02");
    XCTAssertEqualObjects(self.controller.arr_programSubList, browsingItems);
}
- (void)testLiveMetadataCannotDisableTheOwnedBiblePlayer {
    JRBiblePlayback *session = [JRBiblePlayback new];
    STKAudioPlayer *player = (STKAudioPlayer *)(id)[NSObject new];
    AppDelegate *app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    STKAudioPlayer *previousPlayer = app.avAudioPlayer;
    @try {
        [session setValue:player forKey:@"player"];
        app.avAudioPlayer = player;
        GetCommonData.aodData = playbackFixture.fixtureItems.firstObject;
        GetCommonData.PR_ID = @"some-live-program";
        XCTAssertTrue(session.active, @"The active audio item is Bible; the legacy live-info program ID must not route Next to a different player.");
    } @finally {
        app.avAudioPlayer = previousPlayer;
    }
}

- (void)testConsecutiveNextChaptersKeepEveryEpisodeRowRendered {
    for (NSInteger chapter = 2; chapter <= 8; chapter++) {
        [self.controller nextTrack];
        [self assertPlayingBookVisible];
        NSString *expectedContentID = [NSString stringWithFormat:@"01-%ld",(long)chapter];
        XCTAssertEqualObjects(GetCommonData.CT_NO, expectedContentID);
        for (NSInteger row = 0; row < 8; row++) {
            UITableViewCell *cell = [self.controller tableView:self.controller.tb_AODSubList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
            UILabel *title = (UILabel *)[cell.contentView.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIView *view, NSDictionary *bindings) { return [view isKindOfClass:UILabel.class]; }]].firstObject;
            NSString *expectedTitle = [NSString stringWithFormat:@"창세기 %ld장", (long)row + 1];
            XCTAssertEqualObjects(title.text, expectedTitle);
        }
    }
}

- (void)testSelectingThePlayingBookNeverClearsItsAlreadyLoadedChapters {
    [self.controller selectBibleBook:@"01"];
    [self assertPlayingBookVisible];
}

- (void)testInlineBookPanelUsesThreeColumnWidthsAndTabsDoNotLoadChapters {
    UISegmentedControl *tabs = [[UISegmentedControl alloc] initWithItems:@[@"구약", @"신약"]];
    tabs.selectedSegmentIndex = 0;
    UIScrollView *grid = [UIScrollView new];
    [self.controller setValue:tabs forKey:@"bibleTabs"];
    [self.controller setValue:grid forKey:@"bookGrid"];
    [self.controller renderBooks];
    XCTAssertEqual(grid.subviews.count, 2);
    UIButton *first = (UIButton *)grid.subviews[0];
    UIButton *second = (UIButton *)grid.subviews[1];
    XCTAssertEqualWithAccuracy(first.bounds.size.width, floor((390.0 - 44) / 3), 0.01);
    XCTAssertEqualWithAccuracy(second.frame.origin.x, first.bounds.size.width + 10, 0.01);
    XCTAssertEqualObjects(first.currentTitle, @"창세기");
    NSArray *chapters = self.controller.arr_programSubList;
    tabs.selectedSegmentIndex = 1;
    [self.controller changeBibleTestament];
    XCTAssertEqualObjects(self.controller.arr_programSubList, chapters);
    XCTAssertEqual(playbackFixture.pendingLoads.count, 0);
}
- (void)testSleepTimerCanBeSelectedBeforePlaybackAndExpires {
    JRTimerResumeFixture *session = [JRTimerResumeFixture new];
    [session cycleSleep];
    XCTAssertEqual(session.sleepMode, 1);
    [session tick];
    XCTAssertEqual(session.sleepMode, 1);
    [session setValue:[NSDate dateWithTimeIntervalSinceNow:-1] forKey:@"sleepDeadline"];
    [session tick];
    XCTAssertEqual(session.sleepMode, 0);
    for (NSInteger mode = 1; mode <= 5; mode++) {
        [session cycleSleep]; XCTAssertEqual(session.sleepMode, mode);
    }
    XCTAssertEqualObjects(session.sleepLabel, @"이 권 끝나면");
    [session cycleSleep]; XCTAssertEqual(session.sleepMode, 0);
}
- (void)testResumeWaitsForStreamingDurationAndSeeksOnlyOnce {
    JRTimerResumeFixture *session = [JRTimerResumeFixture new]; session.fixtureActive = YES;
    JRSeekProbe *probe = [JRSeekProbe new];
    [session setValue:probe forKey:@"player"];
    [session setValue:@125 forKey:@"pendingSeek"];
    [session restorePendingSeekIfReady];
    XCTAssertEqual(probe.seekCount, 0);
    probe.duration = 300;
    [session restorePendingSeekIfReady];
    [session restorePendingSeekIfReady];
    XCTAssertEqual(probe.seekCount, 1);
    XCTAssertEqualWithAccuracy(probe.soughtPosition, 125, 0.01);
}

- (void)testBookButtonOnlyChangesListAndPlayStartsSelectedBookAtFirstChapter {
    UIButton *button = [UIButton new]; button.accessibilityIdentifier = @"02";
    [self.controller selectBibleBookButton:button];
    void (^complete)(NSArray *, NSDictionary *, NSError *) = playbackFixture.pendingLoads.lastObject;
    NSArray *items = [self itemsForBook:@"02"];
    complete(items, nil, nil);
    XCTAssertEqualObjects(self.controller.arr_programSubList, items);
    XCTAssertNil(playbackFixture.selectedItem, @"Selecting a book must not interrupt playback.");
    [self.controller play];
    XCTAssertEqualObjects(playbackFixture.selectedBook, @"02");
    XCTAssertEqualObjects(playbackFixture.selectedItem, items.firstObject);
    XCTAssertEqual(playbackFixture.selectedPosition, 0);
}

- (void)testOrdinaryAODEpisodeShareArtworkFitsInsideItsButton {
    self.controller.PR_ID = @"another-program";
    UITableViewCell *cell = [self.controller tableView:self.controller.tb_AODSubList cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    cell.frame = CGRectMake(0, 0, 390, 100);
    [cell setNeedsLayout]; [cell layoutIfNeeded];
    UIButton *share = (UIButton *)[cell.contentView.subviews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIView *view, NSDictionary *bindings) { return [view isKindOfClass:UIButton.class]; }]].firstObject;
    XCTAssertNotNil(share);
    [share setNeedsLayout]; [share layoutIfNeeded];
    XCTAssertGreaterThan(share.imageView.bounds.size.width, 0);
    XCTAssertLessThanOrEqual(share.imageView.bounds.size.width, 20.1);
    XCTAssertLessThanOrEqual(share.imageView.bounds.size.height, 20.1);
    XCTAssertTrue(CGRectContainsRect(share.bounds, share.imageView.frame));
}

- (void)testBibleNowPlayingReplacesPreviousProgramMetadata {
    NSDictionary *previous = MPNowPlayingInfoCenter.defaultCenter.nowPlayingInfo;
    JRTimerResumeFixture *session = [JRTimerResumeFixture new]; session.fixtureActive = YES;
    JRSeekProbe *probe = [JRSeekProbe new]; probe.duration = 300; probe.progress = 20;
    [session setValue:probe forKey:@"player"];
    GetCommonData.aodData = @{@"PR_ID":@"002005", @"CT_NAME":@"창세기 1장"};
    MPNowPlayingInfoCenter.defaultCenter.nowPlayingInfo = @{MPMediaItemPropertyTitle:@"북적북적 북클럽", MPMediaItemPropertyArtist:@"이전 진행자", MPMediaItemPropertyAlbumTitle:@"이전 프로그램"};
    @try {
        [session tick];
        NSDictionary *info = MPNowPlayingInfoCenter.defaultCenter.nowPlayingInfo;
        XCTAssertEqualObjects(info[MPMediaItemPropertyTitle], @"성경낭독 창세기 1장");
        XCTAssertEqualObjects(info[MPMediaItemPropertyArtist], @"성경낭독");
        XCTAssertEqualObjects(info[MPMediaItemPropertyAlbumTitle], @"성경낭독");
        XCTAssertNotNil(info[MPMediaItemPropertyArtwork]);
        XCTAssertEqualObjects(info[MPNowPlayingInfoPropertyElapsedPlaybackTime], @20);
    } @finally {
        MPNowPlayingInfoCenter.defaultCenter.nowPlayingInfo = previous;
    }
}

- (void)testBibleArtworkIsCapturedAndLegacyTimerCannotReplaceItsMetadata {
    NSDictionary *previous = MPNowPlayingInfoCenter.defaultCenter.nowPlayingInfo;
    UIImage *previousSharedImage = GetCommonData.thum;
    JRTimerResumeFixture *session = [JRTimerResumeFixture new]; session.fixtureActive = YES;
    JRSeekProbe *probe = [JRSeekProbe new]; probe.duration = 300;
    [session setValue:probe forKey:@"player"];
    GetCommonData.aodData = @{@"PR_ID":@"002005", @"CT_NAME":@"창세기 1장", @"CT_SPEAKER":@"이전 진행자", @"CT_TOPIC":@"이전 프로그램"};
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(32,32)];
    UIImage *bibleImage = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) { [UIColor.blueColor setFill]; UIRectFill(CGRectMake(0,0,32,32)); }];
    @try {
        [session updateProgramInfo:@{@"PR_NAME":@"성경낭독"} artwork:bibleImage];
        GetCommonData.thum = [UIImage imageNamed:@"default_image"];
        nowPlayingSessionOverride = session;
        self.controller.mainDelegate = [AppDelegate new];
        self.controller.mainDelegate.avAudioPlayer = (STKAudioPlayer *)(id)probe;
        self.controller.isPlaying = NO;
        [self.controller updatePlaybackProgressFromTimer:nil];
        NSDictionary *info = MPNowPlayingInfoCenter.defaultCenter.nowPlayingInfo;
        XCTAssertEqualObjects(info[MPMediaItemPropertyTitle], @"성경낭독 창세기 1장");
        MPMediaItemArtwork *art = info[MPMediaItemPropertyArtwork];
        XCTAssertEqualObjects(UIImagePNGRepresentation([art imageWithSize:CGSizeMake(32,32)]), UIImagePNGRepresentation(bibleImage));
        GetCommonData.aodData = @{@"PR_ID":@"002005", @"CT_NAME":@"출애굽기 1장"};
        [session updateNowPlayingInfo];
        XCTAssertEqualObjects(MPNowPlayingInfoCenter.defaultCenter.nowPlayingInfo[MPMediaItemPropertyTitle], @"성경낭독 출애굽기 1장");
        session.fixtureActive = NO;
        NSDictionary *otherProgram = @{MPMediaItemPropertyTitle:@"다른 프로그램"};
        MPNowPlayingInfoCenter.defaultCenter.nowPlayingInfo = otherProgram;
        [session updateNowPlayingInfo];
        XCTAssertEqualObjects(MPNowPlayingInfoCenter.defaultCenter.nowPlayingInfo[MPMediaItemPropertyTitle], @"다른 프로그램");
    } @finally {
        nowPlayingSessionOverride = nil;
        GetCommonData.thum = previousSharedImage;
        MPNowPlayingInfoCenter.defaultCenter.nowPlayingInfo = previous;
    }
}

- (void)testPinnedBiblePanelKeepsChapterListClearAfterScrolling {
    self.controller.lmg_subImg = [UIImageView new];
    [self.controller setValue:[UIButton new] forKey:@"btn_programShare"];
    [self.controller setupBible];
    UIWindowScene *scene = (UIWindowScene *)UIApplication.sharedApplication.connectedScenes.allObjects.firstObject;
    UIWindow *window = [[UIWindow alloc] initWithWindowScene:scene];
    window.rootViewController = self.controller;
    [window makeKeyAndVisible];
    @try {
        [self.controller.view setNeedsLayout]; [self.controller.view layoutIfNeeded];
        UITableView *table = self.controller.tb_AODSubList;
        [table reloadData]; [table layoutIfNeeded];
        [table setContentOffset:CGPointMake(0, 510) animated:NO];
        [table layoutIfNeeded];
        [self.controller.view setNeedsLayout]; [self.controller.view layoutIfNeeded];
        UIView *panel = [self.controller valueForKey:@"biblePanel"];
        CGFloat pinnedOrigin = panel.frame.origin.y;
        [self.controller viewDidLayoutSubviews];
        XCTAssertEqualWithAccuracy(panel.frame.origin.y, pinnedOrigin, 0.1);
        XCTAssertEqualWithAccuracy(panel.bounds.size.height, 240, 0.1);
        CAGradientLayer *gradient = [self.controller valueForKey:@"biblePanelGradient"];
        XCTAssertTrue(CGRectEqualToRect(gradient.frame, panel.bounds));
        if (@available(iOS 26.0, *)) {
            XCTAssertTrue(table.topEdgeEffect.hidden);
            XCTAssertTrue(table.bottomEdgeEffect.hidden);
            UIScrollView *books = [self.controller valueForKey:@"bookGrid"];
            XCTAssertTrue(books.topEdgeEffect.hidden);
            XCTAssertTrue(books.bottomEdgeEffect.hidden);
        }
        UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:self.controller.view.bounds.size];
        UIImage *image = [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) { [self.controller.view drawViewHierarchyInRect:self.controller.view.bounds afterScreenUpdates:YES]; }];
        XCTAttachment *attachment = [XCTAttachment attachmentWithImage:image];
        attachment.name = @"Bible chapters after scrolling"; attachment.lifetime = XCTAttachmentLifetimeKeepAlways;
        [self addAttachment:attachment];
    } @finally { window.hidden = YES; window.rootViewController = nil; }
}

- (void)testSeasonPanelUsesServerGroupsAndDoesNotNeedAnAppUpdateForNewSeasons {
    self.controller.PR_ID = @"003013";
    UIScrollView *grid = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 366, 124)];
    [self.controller setValue:grid forKey:@"groupGrid"];
    [self.controller setValue:@[
        @{@"BB_ID":@"01", @"name":@"시즌 1", @"range":@"1~100회", @"count":@101},
        @{@"BB_ID":@"02", @"name":@"시즌 2", @"range":@"101~120회", @"count":@20},
        @{@"BB_ID":@"07", @"name":@"시즌 7", @"range":@"201~220회", @"count":@20}
    ] forKey:@"programGroups"];
    [self.controller setValue:@"02" forKey:@"selectedGroupID"];
    XCTAssertTrue([self.controller usesProgramGroups]);
    [self.controller renderProgramGroups];
    XCTAssertEqual(grid.subviews.count, 3);
    UIButton *first = (UIButton *)grid.subviews.firstObject;
    UIButton *second = (UIButton *)grid.subviews[1];
    UIButton *newSeason = (UIButton *)grid.subviews[2];
    XCTAssertEqualWithAccuracy(first.bounds.size.width, floor((390.0 - 34) / 2), 0.1);
    XCTAssertEqualWithAccuracy(second.frame.origin.x, first.bounds.size.width + 10, 0.1);
    XCTAssertEqualObjects(newSeason.currentTitle, @"시즌 7\n201~220회");
    XCTAssertEqualObjects(second.currentTitle, @"시즌 2\n101~120회");
    XCTAssertTrue((second.accessibilityTraits & UIAccessibilityTraitSelected) != 0);
}

- (void)testGroupedProgramHeaderReservesTheSafeAreaForTheBackButton {
    self.controller.PR_ID = @"003013";
    UIView *panel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 390, 176)];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    [panel.layer addSublayer:gradient];
    [self.controller setValue:panel forKey:@"groupPanel"];
    [self.controller setValue:gradient forKey:@"groupPanelGradient"];
    [self.controller setValue:[UIView new] forKey:@"groupTopBar"];
    [self.controller setValue:[UIButton buttonWithType:UIButtonTypeSystem] forKey:@"groupBackButton"];
    [self.controller setValue:[UILabel new] forKey:@"lbl_mainTitle"];
    [self.controller setValue:[UILabel new] forKey:@"groupHint"];
    [self.controller setValue:[UILabel new] forKey:@"groupBadge"];
    [self.controller setValue:[UIScrollView new] forKey:@"groupGrid"];

    [self.controller viewDidLayoutSubviews];

    UIView *topBar = [self.controller valueForKey:@"groupTopBar"];
    UIButton *backButton = [self.controller valueForKey:@"groupBackButton"];
    XCTAssertEqualWithAccuracy(CGRectGetHeight(topBar.frame), 44, 0.1);
    XCTAssertTrue(CGRectContainsRect(topBar.bounds, [topBar convertRect:backButton.bounds fromView:backButton]));
    XCTAssertEqualWithAccuracy(CGRectGetMinY(self.controller.tb_AODSubList.frame), CGRectGetMaxY(topBar.frame), 0.1);
}

- (void)testGroupNextAndPreviousStayInsideThePlayingSeasonOnAnotherScreen {
    nowPlayingSessionOverride = [JRTimerResumeFixture new];
    self.controller.PR_ID = @"003009";
    self.controller.arr_programSubList = @[
        @{@"PR_ID":@"003009", @"CT_NO":@"season-1", @"CT_NAME":@"시즌 2 1회"},
        @{@"PR_ID":@"003009", @"CT_NO":@"season-2", @"CT_NAME":@"시즌 2 2회"}
    ];
    [self.controller tableView:self.controller.tb_AODSubList didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    GetCommonData.CT_NO = @"season-1";
    self.controller.arr_programSubList = @[];

    JRSharedPlayerControllerFixture *sharedPlayer = [JRSharedPlayerControllerFixture new];
    sharedPlayer.view = [UIView new];
    [sharedPlayer prevTrack];
    XCTAssertEqual(sharedPlayer.playbackStarts, 0);
    XCTAssertFalse([[sharedPlayer valueForKey:@"loadingTrack"] boolValue]);
    [sharedPlayer nextTrack];
    XCTAssertEqualObjects(GetCommonData.aodData[@"CT_NO"], @"season-2");
    XCTAssertEqual(sharedPlayer.playbackStarts, 1);
    [sharedPlayer nextTrack];
    XCTAssertEqualObjects(GetCommonData.aodData[@"CT_NO"], @"season-2");
    XCTAssertEqual(sharedPlayer.playbackStarts, 1);
    XCTAssertFalse([[sharedPlayer valueForKey:@"loadingTrack"] boolValue]);
    [sharedPlayer prevTrack];
    XCTAssertEqualObjects(GetCommonData.aodData[@"CT_NO"], @"season-1");
    XCTAssertEqual(sharedPlayer.playbackStarts, 2);
}

@end
