#import <Cocoa/Cocoa.h>


@interface SIYMetaCard : NSManagedObject

@property (nonatomic, retain) NSNumber * quantity;
@property (nonatomic, retain) NSSet* cards;
@property (nonatomic, retain) NSManagedObject * deck;

- (void)addCardsObject:(NSManagedObject *)value;
//- (void)removeCardsObject:(NSManagedObject *)value;
- (void)addCards:(NSSet *)value;
//- (void)removeCards:(NSSet *)value;

@end
