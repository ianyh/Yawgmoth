//
//  SIYDeckDataSource.h
//  Yawgmoth
//
//  Created by Ian Ynda-Hummel on 8/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SM2DGraphView/SM2DGraphView.h>
#import <SM2DGraphView/SMPieChartView.h>

// data to index:
//  distribution of colors
//  distribution of land mana
//  distribution of converted costs
//  distribution of types

@interface SIYDeckDataSource : NSObject {
	NSManagedObject *deck;
	
	NSMutableDictionary *colorToCount;
	NSMutableDictionary *typeToCount;
	NSMutableDictionary *costToCount;
	
	IBOutlet SMPieChartView *colorPieChart;
	IBOutlet SMPieChartView *typePieChart;
	IBOutlet SM2DGraphView *manaCurveGraph;
}

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
