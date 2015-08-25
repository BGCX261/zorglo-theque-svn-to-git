//
//  ZTSerieValueTransformer.m
//  ZorgloThèque
//
//  Created by Benjamin Dehalu on 1/03/10.
//  Copyright 2010 Banque Centrale Européenne. All rights reserved.
//

#import "ZTStringToSerieTransformer.h"
#import "ZTSerieManagedObject.h"

@implementation ZTStringToSerieTransformer

+ (Class)transformedValueClass
{
	return [ZTSerieManagedObject class];
}

- (id) init
{
	return [super initWithEntityName:@"Serie"];
}

@end
