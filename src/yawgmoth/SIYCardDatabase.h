//
//  SIYCardDatabase.h
//  Yawgmoth
//
//  Created by Ian Ynda-Hummel on 7/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FMDatabase.h"

@interface SIYCardDatabase : NSObject {
	FMDatabase *db;
	
	NSString *filterString;
}

- (NSString *)cardValueType:(NSString *)type fromDBAtIndex:(NSInteger)rowIndex;
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;
- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex;
- (void)updateFilter:(NSString *)newFilterString;
- (NSString *)queryWithSelection:(NSString *)selectionStatement singleSelection:(BOOL)isSingleSelection;

@end
