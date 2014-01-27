//
//  PhoneNumber.h
//  Sample
//
//  Created by amir hayek on 1/27/14.
//  Copyright (c) 2014 Jaehwa Han. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contact;

@interface PhoneNumber : NSManagedObject

@property (nonatomic, retain) NSNumber * number;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) Contact *contact;

@end
