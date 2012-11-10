//
//  PageView.m
//  WWDCQuotes
//
//  Created by Johannes Fortmann on 6/5/12.
//  Copyright (c) 2012 Johannes Fortmann. All rights reserved.
//

#import "PageView.h"

#define PAGE_BACKGROUND_COLOR [UIColor colorWithHue:0.11 saturation:0.2 brightness:1.0 alpha:1.0]


@implementation PageView
{
    NSArray *_paragraphBounds;
}

- (void)updatePage {
    self.image = [self renderPageWithSize:self.bounds.size];
}

-(void)setPage:(Page *)page {
    if(_page != page) {
        _page = page;
        [self updatePage];
    }
}

-(void)setUnstyledDrawing:(BOOL)unstyledDrawing {
    if(_unstyledDrawing != unstyledDrawing) {
        _unstyledDrawing = unstyledDrawing;
        [self updatePage];
    }
}

-(void)setLineHeight:(float)lineHeight {
    if(lineHeight !=_page.lineHeight) {
        _page.lineHeight = lineHeight;
        [self updatePage];
    }
}

-(float)lineHeight {
    return _page.lineHeight;
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

/*
 Render the page here: we assume we are already in a normalized coordinate system which maps our standard aspect ratio (3:4) to (1:1)
 The reason why we do this is to reuse the same drawing code for both the preview and the full screen; for full screen rendering, we map
 the whole view, whereas the preview maps the whole preview image to a quarter of the page.
 */
+ (NSArray *)renderPage:(Page *)page withSize:(CGSize)size usingUnstyledDrawing:(BOOL)unstyledDrawing {
    CGRect pageRect = CGRectMake(0, 0, size.width, size.height);
    NSMutableArray *paragraphBounds = [[NSMutableArray alloc] init];
    
    // fill background
    [PAGE_BACKGROUND_COLOR set];
    [[UIBezierPath bezierPathWithRect:pageRect] fill];
    
    pageRect = CGRectInset(pageRect, 20., 20.);
    
    for(NSDictionary *paragraph in page.paragraphs) {
        CGRect bounds = CGRectMake(pageRect.origin.x, pageRect.origin.y, 0, 0);
        
        if(unstyledDrawing) {
            NSString *text = [page stringForParagraph:paragraph];
            
            UIFont *font = [UIFont fontWithName:@"HoeflerText-Regular" size:24.0];
            
            // draw text with the old, legacy path
            [[UIColor blackColor] set];
            bounds.size = [text drawInRect:pageRect withFont:font];
        } else {

            // TODO: draw attributed text with new string drawing
            NSAttributedString *text = [page attributedStringForParagraph:paragraph];
            NSStringDrawingContext *textContext = [[NSStringDrawingContext alloc] init];

            [text drawWithRect:pageRect options:NSStringDrawingUsesLineFragmentOrigin context:textContext];
            bounds = CGRectOffset(textContext.totalBounds, pageRect.origin.x, pageRect.origin.y);
        }
        
        [paragraphBounds addObject:[NSValue valueWithCGRect:bounds]];
        
        pageRect.origin.y += bounds.size.height;
    }
    
    return paragraphBounds;
}








- (void)selectParagraphAtPosition:(CGPoint)position showMenu:(BOOL)shouldShowMenu{
    _page.selectedParagraph = NSNotFound;
    
    CGRect bounds = CGRectZero;
    for(NSValue *boundsValue in _paragraphBounds) {
        bounds = [boundsValue CGRectValue];
        
        if(CGRectContainsPoint(bounds, position)) {
            _page.selectedParagraph = [_paragraphBounds indexOfObject:boundsValue];
            break;
        }
    }
    
    if(shouldShowMenu) {
        [self becomeFirstResponder];
        UIMenuController *theMenu = [UIMenuController sharedMenuController];
        
        [theMenu setTargetRect:bounds inView:self];
        [theMenu update];
        [theMenu setMenuVisible:YES animated:YES];
    } else {
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    }

    [self updatePage];
}


+ (UIImage *)renderPagePreview:(Page *)page withSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    
    CGAffineTransform scale = CGAffineTransformMakeScale(.5, .5);
    CGContextConcatCTM(UIGraphicsGetCurrentContext(), scale);
    
    [[self class] renderPage:page withSize:CGSizeMake(1024, 768) usingUnstyledDrawing:NO];
    
    UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return ret;
}

- (UIImage *)renderPageWithSize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    
    // render and hang on to paragraph bounds for hit testing
    _paragraphBounds = [[self class] renderPage:_page withSize:size usingUnstyledDrawing:_unstyledDrawing];
    
    UIImage *ret = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return ret;
}



-(void)copy:(id)sender {
    
}

@end
