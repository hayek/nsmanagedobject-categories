//
//  Address.h
//  Sample
//
//  Created by amir hayek on 1/27/14.
//  Copyright (c) 2014 Jaehwa Han. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Contact;

@interface Address : NSManagedObject

@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) Contact *contact;

@end
