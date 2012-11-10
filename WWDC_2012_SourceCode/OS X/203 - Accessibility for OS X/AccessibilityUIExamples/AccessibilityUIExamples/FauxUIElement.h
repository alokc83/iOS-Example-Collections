/*
 
     File: FauxUIElement.h
 Abstract: Object used to represent interface elements that are not otherwise accessible.
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 
 WWDC 2012 License
 
 NOTE: This Apple Software was supplied by Apple as part of a WWDC 2012
 Session. Please refer to the applicable WWDC 2012 Session for further
 information.
 
 IMPORTANT: This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple
 Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 
 */

#import <Cocoa/Cocoa.h>

// FauxUIElement may be used to represent interface elements that are not otherwise accessible.
//
// For example:
//   - Text and images drawn directly into a view.
//   - Custom controls that are not ideally implemented.
//   - Any sophisticated interface without a 1:1 mapping of accessible elements to views.
//
// Simply implement the FauxUIElement protocol on the parent object (usually a view) and add any faux
// elements to the array of accessibility children the parent returns from -accessibilityAttributeValue.
@class FauxUIElement;
@protocol FauxUIElementChildSupport
@optional
- (NSPoint)fauxUIElementPosition:(FauxUIElement *)fauxElement; // Position must be in screen coordinates.
- (NSSize)fauxUIElementSize:(FauxUIElement *)fauxElement;

- (id)fauxUIElementValue:(FauxUIElement *)fauxElement;
- (NSString *)fauxUIElementDescription:(FauxUIElement *)fauxElement;
- (NSString *)fauxUIElementHelp:(FauxUIElement *)fauxElement;

- (BOOL)isFauxUIElementFocusable:(FauxUIElement *)fauxElement;
- (void)fauxUIElement:(FauxUIElement *)fauxElement setFocus:(id)value;

- (NSArray *)fauxUIElementActionNames:(FauxUIElement *)fauxElement; // Static elements may return an empty array.
- (void)fauxUIElement:(FauxUIElement *)fauxElement performAction:(NSString *)action;

@end

@interface FauxUIElement : NSObject

// Required. Must be one of the role constants defined in NSAccessibility.h
@property (nonatomic, strong) NSString *role;

// Optional. Also defined in NSAccessibility.h
@property (nonatomic, strong) NSString *subrole;

// Required. Must implement the complete FauxUIElementChildSupport informal protocol.
@property (nonatomic, weak) id <FauxUIElementChildSupport> parent;

// Optional. Important to set a unique tag if multiple instances share a parent and role.
@property (nonatomic) NSInteger tag;

- (id)initWithRole:(NSString *)aRole subrole:(NSString *)subrole parent:(id <FauxUIElementChildSupport>)aParent;

+ (FauxUIElement *)elementWithRole:(NSString *)aRole parent:(id <FauxUIElementChildSupport>)aParent;
+ (FauxUIElement *)elementWithRole:(NSString *)aRole subrole:(NSString *)aSubrole parent:(id <FauxUIElementChildSupport>)aParent;

@end


