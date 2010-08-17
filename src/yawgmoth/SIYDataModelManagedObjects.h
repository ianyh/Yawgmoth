#import <Cocoa/Cocoa.h>
#import "SIYMetaCard.h"

@interface NSManagedObject (Card)

@property (nonatomic, retain) NSNumber * convertedManaCost;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * manaCost;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * power;
@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSString * rarity;
@property (nonatomic, retain) NSString * set;
@property (nonatomic, retain) NSString * superType;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * toughness;
@property (nonatomic, retain) NSString * type;

@end

@interface NSManagedObject (CollectionCard)

@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) SIYMetaCard * metaCard;

@end

@interface NSManagedObject (MetaCard)

@property (nonatomic, retain) NSSet* cards;
@property (nonatomic, retain) NSManagedObject * deck;

@end

@interface NSManagedObject (Deck)

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* metaCards;
- (void)addMetaCardsObject:(NSManagedObject *)value;
- (void)removeMetaCardsObject:(NSManagedObject *)value;
- (void)addMetaCards:(NSSet *)value;
- (void)removeMetaCards:(NSSet *)value;

@end


