//
//  NTClusterAnnotation.h
//  Clustered Annotations
//
//  Created by Hermann on 22.06.13.
//  Copyright (c) 2013 Hermann Klecker. All rights reserved.
//

#import "NTAnnotation.h"

@interface NTClusterAnnotation : NTAnnotation

// The set clusteredAnnotations stores all those annotations that belong to a given cluster. 
@property (nonatomic, strong)	NSMutableSet		*clusteredAnnotations;

@end
