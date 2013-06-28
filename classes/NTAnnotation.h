//
//  NTAnnotation.h
//  Clustered Annotations
//
//  Created by Hermann on 22.06.13.
//  Copyright (c) 2013 Hermann Klecker. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface NTAnnotation : NSObject <MKAnnotation>

// The follwoing pooperties fulfil the MKAnnotation protocol.
@property (nonatomic)			CLLocationCoordinate2D	coordinate;
@property (nonatomic, copy)		NSString				*title;
@property (nonatomic, copy)		NSString				*subtitle;


// An init method for which the title and the coordinate are given.
- (id) initWithTitle:(NSString *)ttl andCoordinate:(CLLocationCoordinate2D)c2d;

// The touchesAnnotation method returns YES when self and the annotation passed in
// overlap. It requires a reference to the corresponding mapView for proper coordinate
// conversions.
- (BOOL) tochesAnnotation:(NTAnnotation*)annotation inMap:(MKMapView *)mapView;

// This is an alternative to touchesAnnotation. It does the same but does not rely on
// specific methods of MKMapView. It may be easier transferred into 3rd party framworks etc.
- (BOOL) geoTochesAnnotation:(NTAnnotation*)annotation inMap:(MKMapView *)mapView;

// annotationSet returns all annotations as a set.
// This method helps simplifying the algorithm. NTAnnotation will return itself as the only
// member of a set. Subclasses may return larger sets.
- (NSMutableSet*) annotationSet;

// Retuns the reuse identifier of the related annotation views.
// Reuse identifiers should be unique amongst views of the same structure and
// different for views of diffrent structure. (Especially subviews)
- (NSString *) reuseID;

// annotationView returns the annotation view of the current annotation.
// Passed in is a view that may be fetchted for reusage. If a view is given
// then the method is supposed to reuse the view. If nil is passed in then
// the method will create a new MKAnnnotationView object. 
- (MKAnnotationView *) annotationView:(MKAnnotationView*)reuseView;

@end
