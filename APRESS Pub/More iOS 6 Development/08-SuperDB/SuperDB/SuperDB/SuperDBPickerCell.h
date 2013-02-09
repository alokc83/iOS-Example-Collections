//
//  SuperDBPickerCell.h
//  SuperDB
//
//  Created by Kevin Y. Kim on 1/22/13.
//  Copyright (c) 2013 Kevin Y. Kim. All rights reserved.
//

#import "SuperDBEditCell.h"

@interface SuperDBPickerCell : SuperDBEditCell <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) NSArray *values;

@end