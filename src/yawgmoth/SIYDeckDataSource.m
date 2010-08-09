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
	
	[deckArrayController addObserver:self forKeyPath:@"selectedObjects" options:0 context:nil];
}

- (NSColor *)colorFromString:(NSString *)colorString
{
	if ([colorString isEqualToString:@"B"]) {
		return [NSColor blackColor];
	} else if ([colorString isEqualToString:@"U"]) {
		return [NSColor blueColor];
	} else if ([colorString isEqualToString:@"W"]) {
		return [NSColor whiteColor];
	} else if ([colorString isEqualToString:@"G"]) {
		return [NSColor greenColor];
	} else if ([colorString isEqualToString:@"R"]) {
		return [NSColor redColor];
	} else if ([colorString isEqualToString:@"Colorless"]) {
		return [NSColor grayColor];
	} else {
		return nil;
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"selectedObjects"]) {
		if ([[deckArrayController selectedObjects] count] > 0) {
			deck = [[deckArrayController selectedObjects] objectAtIndex:0];
			[self reloadData];
		} else {
			deck = nil;
		}
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)reloadData
{
	[colorToCount release];
	colorToCount = [[NSMutableDictionary dictionary] retain];
	
	NSArray *colorArray = [NSArray arrayWithObjects:@"G", @"R", @"B", @"U", @"W", nil];
	NSSet *cards = deck.metaCards;
	NSEnumerator *enumerator = [cards objectEnumerator];
	NSManagedObject *card;
	while ((card = [enumerator nextObject]) != nil) {
		NSString *manaCost = card.manaCost;
		if (manaCost == nil) continue;
		BOOL found = NO;
		int i = 0;
		for (; i < [colorArray count]; i++) {
			NSString *colorString = [colorArray objectAtIndex:i];
			NSRange range = [manaCost rangeOfString:colorString];
			if (range.location != NSNotFound) {
				found = YES;
				NSNumber *colorCount = [colorToCount objectForKey:colorString];
				if (colorCount == nil) {
					[colorToCount setObject:[NSNumber numberWithInt:1] forKey:colorString];
				} else {
					[colorToCount setObject:[NSNumber numberWithInt:[colorCount intValue]+1] forKey:colorString];
				}
			}
		}
		if (!found && manaCost != nil && ![manaCost isEqualToString:@""]) {
			NSNumber *colorCount = [colorToCount objectForKey:@"Colorless"];
			if (colorCount == nil) {
				[colorToCount setObject:[NSNumber numberWithInt:1] forKey:@"Colorless"];
			} else {
				[colorToCount setObject:[NSNumber numberWithInt:[colorCount intValue]+1] forKey:@"Colorless"];
			}
		}
	}
	
	[colorPieChart reloadData];
	[colorPieChart reloadAttributes];
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
	NSString *colorString = [[colorToCount allKeys] objectAtIndex:inSliceIndex];
	NSColor *color = [self colorFromString:colorString];
	
	return [NSDictionary dictionaryWithObject:color forKey:NSBackgroundColorAttributeName];
}

- (unsigned int)numberOfExplodedPartsInPieChartView:(SMPieChartView *)inPieChartView
{
	return 0;
}

@end
