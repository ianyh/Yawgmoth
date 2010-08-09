//
//  SIYDeckDataSource.m
//  Yawgmoth
//
//  Created by Ian Ynda-Hummel on 8/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SIYDeckDataSource.h"


@implementation SIYDeckDataSource

- (void)awakeFromNib
{
	colorToCount = [[NSMutableDictionary dictionary] retain];
}

- (void)reloadData
{
	NSArray *colorArray = [NSArray arrayWithObjects:@"G", @"R", @"B", @"U", @"W"];
	NSSet *cards = deck.cards;
	NSEnumerator *enumerator = [cards objectEnumerator];
	NSManagedObject *card;
	while ((card = [enumerator nextObject]) != nil) {
		NSString *manaCost = card.manaCost;
		int i = 0;
		for (; i < [colorArray count]; i++) {
			NSString *colorString = [colorArray objectAtIndex:i];
			NSRange range = [manaCost rangeOfString:@"G"];
			if (range.location != NSNotFound) {
				NSNumber *colorCount = [colorToCount objectForKey:colorString];
				if (colorCount == nil) {
					[colorToCount setObject:[NSNumber numberWithInt:1] forKey:colorString];
				} else {
					[colorToCount setObject:[NSNumber numberWithInt:[colorCount intValue]+1] forKey:colorString];
				}
			}
		}
	}	
}

- (void)setDeck:(NSManagedObject *)newDeck
{
	deck = newDeck;
	[self reloadData];
}

// 2d graph data source methods

- (unsigned int)numberOfLinesInTwoDGraphView:(SM2DGraphView *)inGraphView
{
	return 0;
}

- (NSArray *)twoDGraphView:(SM2DGraphView *)inGraphView dataForLineIndex:(unsigned int)inLineIndex
{
	return nil;
}

- (NSData *)twoDGraphView:(SM2DGraphView *)inGraphView dataObjectForLineIndex:(unsigned int)inLineIndex
{
	return nil;
}

- (double)twoDGraphView:(SM2DGraphView *)inGraphView maximumValueForLineIndex:(unsigned int)inLineIndex
				forAxis:(SM2DGraphAxisEnum)inAxis
{
	return 0.0;
}

- (double)twoDGraphView:(SM2DGraphView *)inGraphView minimumValueForLineIndex:(unsigned int)inLineIndex
				forAxis:(SM2DGraphAxisEnum)inAxis
{
	return 0.0;
}

- (NSDictionary *)twoDGraphView:(SM2DGraphView *)inGraphView attributesForLineIndex:(unsigned int)inLineIndex
{
	return nil;
}

// pie chart data source methods

- (unsigned int)numberOfSlicesInPieChartView:(SMPieChartView *)inPieChartView
{
	return [colorToCount count];
}

- (double)pieChartView:(SMPieChartView *)inPieChartView dataForSliceIndex:(unsigned int)inSliceIndex
{
	return [[[colorToCount allValues] objectAtIndex:inSliceIndex] intValue];
}

- (NSArray *)pieChartViewArrayOfSliceData:(SMPieChartView *)inPieChartView
{
	return [colorToCount allValues];
}

- (NSDictionary *)pieChartView:(SMPieChartView *)inPieChartView attributesForSliceIndex:(unsigned int)inSliceIndex
{
	return [NSDictionary dictionaryWithObject:[NSColor redColor] forKey:NSBackgroundColorAttributeName];
}

- (unsigned int)numberOfExplodedPartsInPieChartView:(SMPieChartView *)inPieChartView
{
	return 0;
}

@end
