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
	typeToCount = [[NSMutableDictionary dictionary] retain];
	costCounts = [[NSMutableArray array] retain];
	
	[deckArrayController addObserver:self forKeyPath:@"selectedObjects" options:0 context:nil];
}

- (NSColor *)colorFromString:(NSString *)string
{
	if ([string isEqualToString:@"B"] || [string isEqualToString:@"Sorcery"]) {
		return [NSColor blackColor];
	} else if ([string isEqualToString:@"U"] || [string isEqualToString:@"Instant"]) {
		return [NSColor blueColor];
	} else if ([string isEqualToString:@"W"] || [string isEqualToString:@"Planeswalker"]) {
		return [NSColor whiteColor];
	} else if ([string isEqualToString:@"G"] || [string isEqualToString:@"Creature"]) {
		return [NSColor greenColor];
	} else if ([string isEqualToString:@"R"] || [string isEqualToString:@"Land"]) {
		return [NSColor redColor];
	} else if ([string isEqualToString:@"Colorless"] || [string isEqualToString:@"Artifact Creature"]) {
		return [NSColor grayColor];
	} else if ([string isEqualToString:@"Artifact Creature"]) {
		return [NSColor darkGrayColor];
	} else if ([string isEqualToString:@"Enchantment"]) {
		return [NSColor magentaColor];
	} else {
		return [NSColor orangeColor];
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
	
	[typeToCount release];
	typeToCount = [[NSMutableDictionary dictionary] retain];
	
	[costCounts release];
	costCounts = [[NSMutableArray array] retain];
	
	NSArray *colorArray = [NSArray arrayWithObjects:@"G", @"R", @"B", @"U", @"W", nil];
	NSSet *cards = deck.metaCards;
	NSEnumerator *enumerator = [cards objectEnumerator];
	NSManagedObject *card;
	while ((card = [enumerator nextObject]) != nil) {
		NSString *manaCost = card.manaCost;
		if (manaCost != nil) {
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
		
		NSString *superType = card.superType;
		NSNumber *typeCount = [typeToCount objectForKey:superType];
		if (typeCount == nil) {
			[typeToCount setObject:[NSNumber numberWithInt:1] forKey:superType];
		} else {
			[typeToCount setObject:[NSNumber numberWithInt:[typeCount intValue]+1] forKey:superType];
		}
		
		NSNumber *convertedManaCost = card.convertedManaCost;
		if (convertedManaCost != nil) {
			int convertedManaCostValue = [convertedManaCost	intValue];
			while ([costCounts count] <= convertedManaCostValue + 1) {
				[costCounts addObject:[NSNumber numberWithInt:0]];
			}

			NSNumber *costCount = [costCounts objectAtIndex:convertedManaCostValue];
			[costCounts replaceObjectAtIndex:convertedManaCostValue withObject:[NSNumber numberWithInt:[costCount intValue]+1]];
		}
	}
	
	[colorPieChart refreshDisplay:self];
	[typePieChart refreshDisplay:self];
	[manaCurveGraph refreshDisplay:self];
}

// 2d graph data source methods

- (unsigned int)numberOfLinesInTwoDGraphView:(SM2DGraphView *)inGraphView
{
	return 1;
}

- (NSArray *)twoDGraphView:(SM2DGraphView *)inGraphView dataForLineIndex:(unsigned int)inLineIndex
{
	NSMutableArray *data = [NSMutableArray array];
	int cost = 0;
	for (; cost < [costCounts count]; cost++) {
		NSString *point = NSStringFromPoint( NSMakePoint(cost, [[costCounts objectAtIndex:cost] intValue]) );
		[data addObject:point];
	}
	return [NSArray arrayWithArray:data];
}

- (NSData *)twoDGraphView:(SM2DGraphView *)inGraphView dataObjectForLineIndex:(unsigned int)inLineIndex
{
	return nil;
}

- (double)twoDGraphView:(SM2DGraphView *)inGraphView maximumValueForLineIndex:(unsigned int)inLineIndex
				forAxis:(SM2DGraphAxisEnum)inAxis
{
	if (inAxis == kSM2DGraph_Axis_X) {
		return [costCounts count] - 1;
	} else {
		int maxCount = 0;
		int cost = 0;
		for (; cost < [costCounts count]; cost++) {
			if ([[costCounts objectAtIndex:cost] intValue] > maxCount) {
				maxCount = [[costCounts objectAtIndex:cost] intValue];
			}
		}
		return maxCount + 1;
	}
}

- (double)twoDGraphView:(SM2DGraphView *)inGraphView minimumValueForLineIndex:(unsigned int)inLineIndex
				forAxis:(SM2DGraphAxisEnum)inAxis
{
	if (inAxis == kSM2DGraph_Axis_Y) {
		return 0.0;
	} else {
		return -1.0;
	}
}

- (NSDictionary *)twoDGraphView:(SM2DGraphView *)inGraphView attributesForLineIndex:(unsigned int)inLineIndex
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithBool:YES], SM2DGraphBarStyleAttributeName,
			[NSNumber numberWithInt:kSM2DGraph_Width_None], SM2DGraphLineWidthAttributeName,
			nil];
}

// pie chart data source methods

- (unsigned int)numberOfSlicesInPieChartView:(SMPieChartView *)inPieChartView
{
	if (inPieChartView == colorPieChart) {
		return [colorToCount count];
	} else {
		return [typeToCount count];
	}
}

- (double)pieChartView:(SMPieChartView *)inPieChartView dataForSliceIndex:(unsigned int)inSliceIndex
{
	if (inPieChartView == colorPieChart) {
		return [[[colorToCount allValues] objectAtIndex:inSliceIndex] intValue];
	} else {
		return [[[typeToCount allValues] objectAtIndex:inSliceIndex] intValue];
	}
}

- (NSArray *)pieChartViewArrayOfSliceData:(SMPieChartView *)inPieChartView
{
	if (inPieChartView == colorPieChart) {
		return [colorToCount allValues];
	} else {
		return [typeToCount allValues];
	}
}

- (NSDictionary *)pieChartView:(SMPieChartView *)inPieChartView attributesForSliceIndex:(unsigned int)inSliceIndex
{
	NSColor *color;
	if (inPieChartView == colorPieChart) {
		color = [self colorFromString:[[colorToCount allKeys] objectAtIndex:inSliceIndex]];
	} else {
		color = [self colorFromString:[[typeToCount allKeys] objectAtIndex:inSliceIndex]];
	}
	
	return [NSDictionary dictionaryWithObject:color forKey:NSBackgroundColorAttributeName];
}

- (unsigned int)numberOfExplodedPartsInPieChartView:(SMPieChartView *)inPieChartView
{
	return 0;
}

- (NSString *)pieChartView:(SMPieChartView *)inPieChartView labelForSliceIndex:(unsigned int)inSliceIndex
{
	if (inPieChartView == typePieChart) {
		return [[typeToCount allKeys] objectAtIndex:inSliceIndex];
	} else {
		return nil;
	}
}

@end
