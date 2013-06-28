//
//  ViewController.m
//  Clustered Annotations
//
//  Created by Hermann on 22.06.13.
//  Copyright (c) 2013 Hermann Klecker. All rights reserved.
//

#import "ViewController.h"

#import "NTAnnotation.h"
#import "NTClusterAnnotation.h"

#import "constants.h"

@interface ViewController ()

@end

@implementation ViewController {
	
	NSMutableSet		*setA;	// set of all annotations that may be displayed
	NSMutableSet		*setC;	// set of clusters to be displayed
	NSMutableSet		*setD;	// subset of A of those annotations that are to be displayed
	NSMutableSet		*setM;	// subset of A of those annotations that are within the bounds/span of the map window.
	NSMutableSet		*setP;	// set of the pairs of annotations, that touch or overlap each other.
	
	NTClusterAnnotation *originalCluster; 
	
}


- (id) initWithCoder:(NSCoder *)aDecoder {
	
	self = [super initWithCoder:aDecoder];
	if (self) {
		setA = [NSMutableSet set];
		setC = [NSMutableSet set];
		setD = [NSMutableSet set];
		setM = [NSMutableSet set];
		setP = [NSMutableSet set];
	}
	return self;
}

#pragma mark - Annotation clustering

- (BOOL)doesAnnotation:(NTAnnotation *)firstAnnotation touchAnnotation:(NTAnnotation *)secondAnnotation{
	
	// This variant uses methods of the MKMapView object to transform geo coordinates into the correlated view coordinate system
	// according to the current zoom factor.
	
	CGPoint firstPoint		= [self.mapView convertCoordinate:firstAnnotation.coordinate toPointToView:self.mapView];
	CGPoint secondPoint		= [self.mapView convertCoordinate:secondAnnotation.coordinate toPointToView:self.mapView];
	float	verticalDiff	= ABS(firstPoint.y - secondPoint.y);
	float	horizontalDiff	= ABS(firstPoint.x - secondPoint.x);
	
	// Compare the distance betwenn the points with the average size of the annotations in height or with resprectively.
	// Return YES if both distances are smaller. 
	return ((horizontalDiff <= kNTAnnotationSizeX) && (verticalDiff <= kNTAnnotationSizeY));
}

- (BOOL)geoDoesAnnotation:(NTAnnotation *)firstAnnotation touchAnnotation:(NTAnnotation *)secondAnnotation{
	
	// This variant simply uses rule-of-proportion or rule-of-three math.
	// It does not require any coordinate transformation and can therefore be used with
	// Map APIs that do not provide those transformations.
	
	float latDiff = ABS(firstAnnotation.coordinate.latitude  - secondAnnotation.coordinate.latitude);
	float lonDiff = ABS(firstAnnotation.coordinate.longitude - secondAnnotation.coordinate.longitude);
	
	MKCoordinateSpan span = self.mapView.region.span;
	
	// Calculate how often an annotation of average size
	float itemsVertical		= self.mapView.frame.size.height / kNTAnnotationSizeY;
	float itemsHorizontal	= self.mapView.frame.size.width  / kNTAnnotationSizeX;
	
	// Determine if the difference between the latitudes and longitudes is smaller than the minimum space required for each annotation view.
	// (That is the span in geo coordinates divided by number of annotation views that may fit into it.)
	// Return YES if both distances are smaller.
	return ((span.latitudeDelta/itemsVertical > latDiff) && (span.longitudeDelta/itemsHorizontal > lonDiff));
}

- (void) visibleAnnotations{
	// This method determines which annotations of allAnnotations are visible within the current span of the mapView
	// It creates a new set with those annotations and returns it.
	
	setM = [NSMutableSet set];
	
	//Determine the bounding box which corresponds to the map views' currently spanned area.
	CLLocationCoordinate2D topLeft, bottomRight;
	
	topLeft.longitude		= self.mapView.region.center.longitude  - (self.mapView.region.span.longitudeDelta / 2);
	topLeft.latitude		= self.mapView.region.center.latitude   - (self.mapView.region.span.latitudeDelta  / 2);
	bottomRight.longitude	= self.mapView.region.center.longitude  + (self.mapView.region.span.longitudeDelta / 2);
	bottomRight.latitude	= self.mapView.region.center.latitude   + (self.mapView.region.span.latitudeDelta  / 2);
	
	// Add each annotation from within the set allAnnotations to the returned set visibleAnnotations which is within the bounding box.
	for (NTAnnotation* anAnnotation in setA) {
		if (   (anAnnotation.coordinate.longitude >= topLeft.longitude)
			&& (anAnnotation.coordinate.longitude <= bottomRight.longitude)
			&& (anAnnotation.coordinate.latitude  >= topLeft.latitude)
			&& (anAnnotation.coordinate.latitude  <= bottomRight.latitude)) {
			[setM addObject:anAnnotation];
		}
	}
}

- (void) clusterTheAnnotations {
	
	// Empty the set
	[setC removeAllObjects];
	
	for (NTAnnotation *annotation in setM) {
		NTClusterAnnotation *clusterFound = nil;
		
		// Iterate over a copy of the set (an array in this case) because we change the contents of
		// the set probably even several times per loop.
		for (NTAnnotation *clusterAnnotation in [setC allObjects]) {
			if ([clusterAnnotation tochesAnnotation:annotation inMap:self.mapView]) {
				// A match was found!
				// If this is the first match then the annotation just needs to be combined with the
				// touching annotation or cluster.
				if (!clusterFound) {
					// This is the first touch
					// If the touching annotation is a cluster then we just need to add the current
					// annotation. If it is a single annotation then a new cluster must be created and added
					// to setC while the single annotation must be removed.
					if ([clusterAnnotation isKindOfClass:[NTClusterAnnotation class]]) {
						// Remember the current cluster for potential unifications with more clusters or annotations
						// that may be found touching annotation
						clusterFound = (NTClusterAnnotation *)clusterAnnotation;
						// Add the annotation to the cluster
						[[(NTClusterAnnotation*)clusterAnnotation clusteredAnnotations] addObject:annotation];
					} else {
						// replace the single annotation in setC by a new cluster.
						NTClusterAnnotation * newCluster = [[NTClusterAnnotation alloc] init];
						[newCluster.clusteredAnnotations addObject:clusterAnnotation];
						[newCluster.clusteredAnnotations addObject:annotation];
						clusterFound = newCluster;
						[setC addObject:newCluster];
						[setC removeObject:clusterAnnotation];
					}
				} else {
					// This is a second (or more) touch.
					// The touching annotation or cluster needs to be combined with the cluster that
					// has been found earlier and removed from setC.
					[clusterFound.clusteredAnnotations unionSet:[clusterAnnotation annotationSet]];
					[setC removeObject:clusterAnnotation];
				}
			}  // touch was found
		} // iteration over setC
		
		// if no touches were found then the annotation needs to be added to setC as a single annotation.
		if (!clusterFound) {
			[setC addObject:annotation];
		}
	} // iteration over setM
}
	
- (void) addAllTheAnnotations {
	
	[self visibleAnnotations];

	[self clusterTheAnnotations];
	
	// Before adding any annotations remove the existing ones.
	[self.mapView removeAnnotations:[self.mapView annotations]];
	[self.mapView addAnnotations:[setC allObjects]];
	[self.mapView addAnnotations:[setD allObjects]];
}

#pragma  mark - View Controller Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	// Read the sample data from json file into dictionary and array.
	NSString		*filePath		= [[NSBundle mainBundle] pathForResource:@"annotationLocationsJson" ofType:@"txt"];
	NSData			*locationsData	= [NSData dataWithContentsOfFile:filePath];
	NSError			*error;
	NSDictionary	*locationsDict	= [NSJSONSerialization JSONObjectWithData:locationsData options:kNilOptions error:&error];

	// Create set A - all annotations
	NSArray			*locationsArray = [locationsDict objectForKey:kAnnotationsKey];
	for (NSDictionary *location in locationsArray) {
		
		CLLocationCoordinate2D coordinate;
		
		NSString *title			= [location objectForKey:kNameKey];
		coordinate.latitude		= [[location objectForKey:kLatitudeKey] floatValue];
		coordinate.longitude	= [[location objectForKey:kLongitudeKey] floatValue];

		NTAnnotation *annotation = [[NTAnnotation alloc] initWithTitle:title andCoordinate:coordinate];

		[setA addObject:annotation];
	}
	
	// Just for the user's convenience place the map center to a place where the test data objects are located
	// and set some reasonable region.
	// The initial span may vary from iPhone to iPad
	float initalSpan = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? kNTInitialSpaniPad : kNTInitialSpaniPhone;
	
	MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(48.697616, 9.165135), initalSpan, initalSpan);
	[self.mapView setRegion:region animated:YES];

	[self addAllTheAnnotations];
}


//- (void)didReceiveMemoryWarning
//{
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

#pragma mark - MapView Delegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
	
	[self addAllTheAnnotations];
}

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{	
	if (![annotation isKindOfClass:[NTAnnotation class]]) {
		// better deal with the error here
		return nil;
	}
	
	NTAnnotation * ntAnnotation = (NTAnnotation *) annotation;
	
	MKAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:[ntAnnotation reuseID]];


	annotationView = [ntAnnotation annotationView:annotationView];
	
	return annotationView;
}


#pragma mark Animation

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
	
	// if a cluster is selected then expand the cluster.
	
	if ([view.annotation isKindOfClass:[NTClusterAnnotation class]]) {
		// Identify the bounding box around all annotations of the cluster
		NTClusterAnnotation *cluster = (NTClusterAnnotation*) view.annotation;
		float latMax = -91.0f;
		float latMin = +91.0f;
		float lonMax = -181.0f;
		float lonMin = +181.0f;
		for (NTAnnotation *annotation in cluster.clusteredAnnotations) {
			if (latMax < annotation.coordinate.latitude) {
				latMax = annotation.coordinate.latitude;
			}
			if (lonMax < annotation.coordinate.longitude) {
				lonMax = annotation.coordinate.longitude;
			}
			if (latMin > annotation.coordinate.latitude) {
				latMin = annotation.coordinate.latitude;
			}
			if (lonMin > annotation.coordinate.longitude) {
				lonMin = annotation.coordinate.longitude;
			}
		}
		
		// Before actually zooming in, save the current cluster for break-off animation later
		originalCluster = cluster;
		
		// Define the new visible region. The new center is the middle of the bounding box and
		// the new span is the difference between the coordingates of the bounding edges plus
		// some percentage for some decent insects.
		
		MKCoordinateRegion newRegion;
		newRegion.center.longitude		= (lonMax + lonMin)/2;		// BTW, this should be equal to the coordinates of the clusterAnnotation anyway.			
		newRegion.center.latitude		= (latMax + latMin)/2;
		newRegion.span.latitudeDelta	= (latMax - latMin) * kNTMapInsectsPercentage;
		newRegion.span.longitudeDelta	= (lonMax - lonMin) * kNTMapInsectsPercentage;
		
		[self.mapView setRegion:newRegion animated:YES];
	}
	
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {

	// Only animate them when there is an origin given, which is the case when
	// the originalCluster was selected by the user and the mapView was zoomed 
	// into the cluster's area programmatically.
	if (originalCluster) {
		
		// TEST TEST
		NSLog(@"lat: %f, lon:%f", originalCluster.coordinate.latitude, originalCluster.coordinate.longitude);
		
		// The animation speed varies from iPhone (e.g. 0.3s) to iPad (e.g. 0.5s).
		float animationDuration = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? kNTExplostionAnnimationSpeediPad : kNTExplostionAnnimationSpeediPhone;
		
		// For the explosion-like animation we start off at the position of the original cluster.
		CGPoint centerPoint = [self.mapView convertCoordinate:originalCluster.coordinate toPointToView:self.view];
		
		MKAnnotationView *aV;
		for (aV in views) {
			// Only animate those views which were part of the original cluster
			NTAnnotation * annotation = (NTAnnotation *) aV.annotation;
			
			if ([annotation isKindOfClass:[NTAnnotation class]] && [annotation.annotationSet isSubsetOfSet:originalCluster.clusteredAnnotations]) {
				CGRect endFrame = aV.frame;
				
				// Annotation views within MKMapViews have rather strange coordinates, such as (2.19495e+06, 1.43981e+6).
				// As I did not find a reliable way of converting to those coordinates (of the mapView's content view I suppose)
				// I'd rather work with offsets.
				CGPoint annotationPoint = [self.mapView convertCoordinate:[annotation coordinate] toPointToView:self.view];
				
				//aV.frame = CGRectMake(aV.frame.origin.x, aV.frame.origin.y - 1000, aV.frame.size.width, aV.frame.size.height);
				aV.frame = CGRectMake(aV.frame.origin.x + (centerPoint.x - annotationPoint.x),
									  aV.frame.origin.y + (centerPoint.y - annotationPoint.y),
									  aV.frame.size.width,
									  aV.frame.size.height);
				
				[UIView beginAnimations:nil context:NULL];
				[UIView setAnimationDuration:animationDuration];
				[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
				[aV setFrame:endFrame];
				[UIView commitAnimations];
			}
		}
		
		// clear the original cluster to avoid unwanted animations
		originalCluster = nil;	
	}
}



@end
