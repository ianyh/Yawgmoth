//
//  SIYDataModelManagedObject.h
//  Yawgmoth
//
//  Created by Ian Ynda-Hummel on 7/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSManagedObject (Card)

@property (nonatomic, retain) NSNumber * convertedManaCost;
@property (nonatomic, retain) NSString * manaCost;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * power;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSString * rarity;
@property (nonatomic, retain) NSString * superType;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * toughness;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSManagedObject * deck;

@end

@interface NSManagedObject (LibraryCard)

@property (nonatomic, retain) NSNumber * convertedManaCost;
@property (nonatomic, retain) NSString * manaCost;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * power;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSString * rarity;
@property (nonatomic, retain) NSString * superType;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * toughness;
@property (nonatomic, retain) NSString * type;

@end

@interface NSManagedObject (TempCard)

@property (nonatomic, retain) NSNumber * convertedManaCost;
@property (nonatomic, retain) NSString * manaCost;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * power;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSString * rarity;
@property (nonatomic, retain) NSString * superType;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * toughness;
@property (nonatomic, retain) NSString * type;

@end

@interface NSManagedObject (Deck)

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* cards;
- (void)addCardsObject:(NSManagedObject *)value;
- (void)removeCardsObject:(NSManagedObject *)value;
- (void)addCards:(NSSet *)value;
- (void)removeCards:(NSSet *)value;

@end


