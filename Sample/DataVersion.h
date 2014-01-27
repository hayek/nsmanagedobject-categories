//
//  DataVersion.h
//  Sample
//
//  Created by amir hayek on 1/27/14.
//  Copyright (c) 2014 Jaehwa Han. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DataVersion : NSManagedObject

@property (nonatomic, retain) NSString * modelName;
@property (nonatomic, retain) NSNumber * timestamp;

@end
