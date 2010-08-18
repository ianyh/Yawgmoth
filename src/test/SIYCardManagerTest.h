#import <SenTestingKit/SenTestingKit.h>
#import "SIYController.h"


@interface SIYCardManagerTest : SenTestCase {
	SIYCardManager *cardManager;
	NSManagedObject *fullCard;
}

- (void)testTempCardInsertAndFetch;
- (void)testCollectionCardInsertAndFetch;
- (void)testDeckInsertAndFetch;
- (void)testCardIncrement;

@end
