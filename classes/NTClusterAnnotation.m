//
//  NTClusterAnnotation.m
//  Clustered Annotations
//
//  Created by Hermann on 22.06.13.
//  Copyright (c) 2013 Hermann Klecker. All rights reserved.
//

#import "NTClusterAnnotation.h"
#import "constants.h"

@implementation NTClusterAnnotation

- (id) init {
	
	self = [super init];
	if (self) {
		self.clusteredAnnotations = [NSMutableSet set];
	}
	return self;
}

- (id)initWithTitle:(NSString *)ttl andCoordinate:(CLLocationCoordinate2D)c2d {

	// Just in case. In this sample project this method is never called on this class.
	self = [super initWithTitle:ttl andCoordinate:c2d];
	if (self) {
		self.clusteredAnnotations = [NSMutableSet set];
	}
	return self;
}

#pragma mark - overwriting getters of the superclass

- (NSString *) title {
	
	// In the current implementation this method is not being called at all.
	// However, the protocol should be fulfilled in some meaningful way. Just in case.
	
	return [NSString stringWithFormat:@"%d items", [self.clusteredAnnotations count]];
}

- (CLLocationCoordinate2D) coordinate {
	
	// This overwrites the getter of the superclass.
	
	// If the coordinate still hast initial value of 0/0 then calculate the average coordinate of
	// all individual annotations in the cluster 
	
	CLLocationCoordinate2D superCoordinate = [super coordinate];
	
	if (!superCoordinate.latitude && !superCoordinate.longitude) {
		// The coordinate has not been set so far. Its values are 0/0.
		
		// Caluclate the average of all coordinate values and use this as coordinate of the cluster.
		// This will form some sort of weighted center where the cluster is closer to a majority
		// of individual annotations. This will result in some nice explosion annimation when zooming
		// back in when the user selects the cluster.
		
		// Alternatively you could calculate the bounding box and choose the center/geographic middle
		// of that area.
		
		for (NTAnnotation *annotation in self.clusteredAnnotations) {
			superCoordinate.latitude	+= annotation.coordinate.latitude;
			superCoordinate.longitude	+= annotation.coordinate.longitude;
		}
		superCoordinate.latitude  /= [self.clusteredAnnotations count];
		superCoordinate.longitude /= [self.clusteredAnnotations count];
		[super setCoordinate:superCoordinate];
	}
	
	return superCoordinate;
}

- (void)dealloc {
	[self.clusteredAnnotations removeAllObjects];
	self.clusteredAnnotations = nil ;
}

- (BOOL)tochesAnnotation:(NTAnnotation*)annotation inMap:(MKMapView *)mapView {
	
	for (NTAnnotation *myAnnotation in self.clusteredAnnotations) {
		if ([myAnnotation tochesAnnotation:annotation inMap:mapView]) {
			return YES;
		}
	}
	return NO;
}

- (BOOL) geoTochesAnnotation:(NTAnnotation*)annotation inMap:(MKMapView *)mapView {
	
	for (NTAnnotation *myAnnotation in self.clusteredAnnotations) {
		if ([myAnnotation geoTochesAnnotation:annotation inMap:mapView]) {
			return YES;
		}
	}
	return NO;
}

- (NSMutableSet*) annotationSet {
	return self.clusteredAnnotations;
}

- (NSString *) reuseID {

	return @"clusterViewID";
}


- (MKAnnotationView *) annotationView:(MKAnnotationView*)reuseView {
	
	UILabel *numberLabel;
	if (!reuseView) {
		reuseView					= [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:[self reuseID]];
		UIImageView *view			= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cluster.png"]];
		numberLabel					= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 35, 14)];
		numberLabel.center			= view.center;
		numberLabel.textColor		= [UIColor whiteColor];
		numberLabel.backgroundColor = [UIColor clearColor];
		numberLabel.textAlignment	= NSTextAlignmentCenter;
		numberLabel.font			= [UIFont boldSystemFontOfSize:14];
		numberLabel.tag				= kNumberTag;
		numberLabel.adjustsFontSizeToFitWidth = YES;

		[view addSubview:numberLabel];

		reuseView.frame				= view.frame;
		reuseView.canShowCallout	= NO;
		[reuseView addSubview:view];
	} else {
		numberLabel = (UILabel *)[reuseView viewWithTag:kNumberTag];
	}

	numberLabel.text = [NSString stringWithFormat:@"%d", [self.clusteredAnnotations count]];
	
	return reuseView;
}

@end
