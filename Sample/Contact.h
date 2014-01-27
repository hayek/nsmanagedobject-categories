//
//  Contact.h
//  Sample
//
//  Created by amir hayek on 1/27/14.
//  Copyright (c) 2014 Jaehwa Han. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Address, PhoneNumber;

@interface Contact : NSManagedObject

@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Address *address;
@property (nonatomic, retain) NSSet *phoneNumbers;
@end

@interface Contact (CoreDataGeneratedAccessors)

- (void)addPhoneNumbersObject:(PhoneNumber *)value;
- (void)removePhoneNumbersObject:(PhoneNumber *)value;
- (void)addPhoneNumbers:(NSSet *)values;
- (void)removePhoneNumbers:(NSSet *)values;

@end
