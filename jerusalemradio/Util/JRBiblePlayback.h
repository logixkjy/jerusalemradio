#import <Foundation/Foundation.h>
#import "STKAudioPlayer.h"

extern NSString * const JRBiblePlaybackChanged;
@interface JRBiblePlayback : NSObject <STKAudioPlayerDelegate>
+ (instancetype)shared;
@property (nonatomic, readonly) NSArray<NSDictionary *> *books;
@property (nonatomic, readonly) NSDictionary *resumeRecord;
@property (nonatomic, readonly) NSString *playingBookID;
@property (nonatomic, copy, readonly) NSArray<NSDictionary *> *playingItems;
@property (nonatomic, readonly) BOOL active;
@property (nonatomic) NSInteger repeatMode;
@property (nonatomic, readonly) NSInteger sleepMode;
@property (nonatomic, readonly) NSString *sleepLabel;
- (void)loadBooks:(void (^)(BOOL success))completion;
- (void)loadBook:(NSString *)bookID completion:(void (^)(NSArray *items, NSDictionary *info, NSError *error))completion;
- (void)playItem:(NSDictionary *)item bookID:(NSString *)bookID items:(NSArray *)items position:(double)position;
// Bible-owned metadata stays independent of the legacy shared program image.
- (void)updateProgramInfo:(NSDictionary *)info artwork:(UIImage *)artwork;
- (void)updateNowPlayingInfo;
- (void)togglePlayback;
- (void)move:(NSInteger)direction automatic:(BOOL)automatic;
- (void)cycleSleep;
- (void)savePosition;
@end
