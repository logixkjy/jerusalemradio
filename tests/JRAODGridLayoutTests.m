#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "UIAODListViewController.h"

@interface JRAODGridLayoutTests : XCTestCase <UICollectionViewDataSource>
@end
@implementation JRAODGridLayoutTests
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section { return 6; }
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)view cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [view dequeueReusableCellWithReuseIdentifier:@"Program" forIndexPath:indexPath];
}
- (void)testExactlyTwoProgramsFitEachRowAtPhoneWidthsAndAfterResizing {
    UIAODListCollectionViewFlowLayout *layout = [UIAODListCollectionViewFlowLayout new];
    UICollectionView *collection = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collection.dataSource = self;
    UIAODListViewController *controller = [UIAODListViewController new];
    collection.delegate = (id<UICollectionViewDelegate>)controller;
    [collection registerClass:UIAODListCollectionViewCell.class forCellWithReuseIdentifier:@"Program"];
    for (NSNumber *screenWidth in @[@320, @375, @393, @430, @440]) {
        collection.frame = CGRectMake(0, 0, screenWidth.doubleValue - 32, 700);
        [layout invalidateLayout]; [collection reloadData]; [collection layoutIfNeeded];
        XCTAssertEqualObjects(collection.delegate, controller);
        UICollectionViewLayoutAttributes *first = [layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
        UICollectionViewLayoutAttributes *second = [layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0]];
        UICollectionViewLayoutAttributes *third = [layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:0]];
        XCTAssertEqualWithAccuracy(first.frame.origin.y, second.frame.origin.y, 0.5);
        XCTAssertGreaterThanOrEqual(CGRectGetMinX(second.frame), CGRectGetMaxX(first.frame));
        XCTAssertLessThanOrEqual(CGRectGetMaxX(second.frame), collection.bounds.size.width + 0.5);
        XCTAssertGreaterThan(CGRectGetMinY(third.frame), CGRectGetMaxY(first.frame));
    }
}
- (void)testProgramArtworkAndLabelsStayInsideTheirCellWhenItsWidthChanges {
    UIAODListCollectionViewCell *cell = [[UIAODListCollectionViewCell alloc] initWithFrame:CGRectMake(0,0,136,212)];
    for (NSNumber *width in @[@136, @172, @204]) {
        cell.frame = CGRectMake(0,0,width.doubleValue,width.doubleValue + 76);
        [cell setNeedsLayout]; [cell layoutIfNeeded];
        XCTAssertGreaterThan(cell.image.bounds.size.width, 0);
        XCTAssertLessThanOrEqual(CGRectGetMaxX(cell.image.frame), cell.bounds.size.width);
        XCTAssertEqualWithAccuracy(cell.image.bounds.size.width, cell.image.bounds.size.height, 0.5);
        XCTAssertGreaterThanOrEqual(CGRectGetMinY(cell.title.frame), CGRectGetMaxY(cell.image.frame));
        XCTAssertGreaterThanOrEqual(CGRectGetMinY(cell.subTitle.frame), CGRectGetMaxY(cell.title.frame));
        XCTAssertLessThanOrEqual(CGRectGetMaxY(cell.subTitle.frame), cell.bounds.size.height);
    }
}
@end
