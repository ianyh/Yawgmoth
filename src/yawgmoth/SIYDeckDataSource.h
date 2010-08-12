#import <Cocoa/Cocoa.h>
#import <SM2DGraphView/SM2DGraphView.h>
#import <SM2DGraphView/SMPieChartView.h>

// data to index:
//  distribution of land mana

@interface SIYDeckDataSource : NSObject {
	NSManagedObject *deck;
	
	IBOutlet NSArrayController *deckArrayController;
	
	NSMutableDictionary *colorToCount;
	NSMutableDictionary *typeToCount;
	NSMutableArray *costCounts;
	int maxCost;
	int maxCostCount;

	IBOutlet NSTextField *cardCount;
	IBOutlet SMPieChartView *colorPieChart;
	IBOutlet SMPieChartView *typePieChart;
	IBOutlet SM2DGraphView *manaCurveGraph;
}

- (void)reloadData;
- (NSColor *)colorFromString:(NSString *)colorString;

// 2d graph data source methods
- (unsigned int)numberOfLinesInTwoDGraphView:(SM2DGraphView *)inGraphView;
- (NSArray *)twoDGraphView:(SM2DGraphView *)inGraphView dataForLineIndex:(unsigned int)inLineIndex;
- (NSData *)twoDGraphView:(SM2DGraphView *)inGraphView dataObjectForLineIndex:(unsigned int)inLineIndex;
- (double)twoDGraphView:(SM2DGraphView *)inGraphView maximumValueForLineIndex:(unsigned int)inLineIndex
				forAxis:(SM2DGraphAxisEnum)inAxis;
- (double)twoDGraphView:(SM2DGraphView *)inGraphView minimumValueForLineIndex:(unsigned int)inLineIndex
				forAxis:(SM2DGraphAxisEnum)inAxis;
- (NSDictionary *)twoDGraphView:(SM2DGraphView *)inGraphView attributesForLineIndex:(unsigned int)inLineIndex;

// pie chart data source methods
- (unsigned int)numberOfSlicesInPieChartView:(SMPieChartView *)inPieChartView;
- (double)pieChartView:(SMPieChartView *)inPieChartView dataForSliceIndex:(unsigned int)inSliceIndex;
- (NSArray *)pieChartViewArrayOfSliceData:(SMPieChartView *)inPieChartView;
- (NSDictionary *)pieChartView:(SMPieChartView *)inPieChartView attributesForSliceIndex:(unsigned int)inSliceIndex;
- (unsigned int)numberOfExplodedPartsInPieChartView:(SMPieChartView *)inPieChartView;

@end
