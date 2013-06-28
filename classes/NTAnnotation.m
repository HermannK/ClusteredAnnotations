//
//  NTAnnotation.m
//  Clustered Annotations
//
//  Created by Hermann on 22.06.13.
//  Copyright (c) 2013 Hermann Klecker
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction,
//  including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do
//  so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "NTAnnotation.h"
#import "constants.h"


@implementation NTAnnotation 

@synthesize title, coordinate;

- (id)initWithTitle:(NSString *)ttl andCoordinate:(CLLocationCoordinate2D)c2d {
	self = [super init];
	if (self) {
		title = ttl;
		coordinate = c2d;
	}
	return self;
}

- (void)dealloc {
	title		= nil ;
}

- (BOOL)tochesAnnotation:(NTAnnotation*)annotation inMap:(MKMapView *)mapView {
	
	// This variant uses methods of the MKMapView object to transform geo coordinates into the correlated view coordinate system
	// according to the current zoom factor.
	
	CGPoint firstPoint		= [mapView convertCoordinate:self.coordinate toPointToView:mapView];
	CGPoint secondPoint		= [mapView convertCoordinate:annotation.coordinate toPointToView:mapView];
	float	verticalDiff	= ABS(firstPoint.y - secondPoint.y);
	float	horizontalDiff	= ABS(firstPoint.x - secondPoint.x);
	
	// Compare the distance betwenn the points with the average size of the annotations in height or with resprectively.
	// Return YES if both distances are smaller.
	return ((horizontalDiff <= kNTAnnotationSizeX) && (verticalDiff <= kNTAnnotationSizeY));
}

- (BOOL) geoTochesAnnotation:(NTAnnotation*)annotation inMap:(MKMapView *)mapView {
	
	// This variant simply uses rule-of-proportion or rule-of-three math.
	// It does not require any coordinate transformation and can therefore be used with
	// Map APIs that do not provide those transformations.
	
	float latDiff = ABS(self.coordinate.latitude  - annotation.coordinate.latitude);
	float lonDiff = ABS(self.coordinate.longitude - annotation.coordinate.longitude);
	
	MKCoordinateSpan span = mapView.region.span;
	
	// Calculate how often an annotation of average size
	float itemsVertical		= mapView.frame.size.height / kNTAnnotationSizeY;
	float itemsHorizontal	= mapView.frame.size.width  / kNTAnnotationSizeX;
	
	// Determine if the difference between the latitudes and longitudes is smaller than the minimum space required for each annotation view.
	// (That is the span in geo coordinates divided by number of annotation views that may fit into it.)
	// Return YES if both distances are smaller.
	return ((span.latitudeDelta/itemsVertical > latDiff) && (span.longitudeDelta/itemsHorizontal > lonDiff));
}

- (NSMutableSet*) annotationSet {
	return ([NSMutableSet setWithObject:self]);
}


- (NSString *) reuseID {
	
	return @"annotationViewID";
}

- (MKAnnotationView *) annotationView:(MKAnnotationView*)reuseView {
	
	if (!reuseView) {
		reuseView					= [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:[self reuseID]];
		UIImageView *view			= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"annotation.png"]];
		reuseView.frame				= view.frame;
		reuseView.canShowCallout	= YES;
		[reuseView addSubview:view];
	}
	
	return reuseView;
}

@end
