//
//  Header.h
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

#ifndef constants_h
#define constants_h

#define kNTAnnotationSizeX						25.0f
#define kNTAnnotationSizeY						25.0f

#define kNTExplostionAnnimationSpeediPhone		0.3f
#define kNTExplostionAnnimationSpeediPad		0.5f
#define kNTInitialSpaniPhone					5000.0f
#define kNTInitialSpaniPad						7000.0f

// The following is a factor. Use 1.2 for an insect of 20%.
#define kNTMapInsectsPercentage					1.2f

#define kNumberTag								8274

#define kNTAnnotationReuseIdentifier			@"NTAnnotation"
#define kNTClusterReuseidentifier				@"NTCluster"

#define	kAnnotationsKey							@"annotations"
#define kNameKey								@"name"
#define	kPostcodeKey							@"postcode"
#define kCityKey								@"city"
#define kStreetKey								@"street"
#define	kNumberKey								@"number"
#define kLatitudeKey							@"lat"
#define kLongitudeKey							@"lon"

#endif
