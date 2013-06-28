//
//  NTAnnotation.h
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
