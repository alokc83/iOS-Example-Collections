//
//  SuperDBCell.h
//  
//
//  Created by Kevin Y. Kim on 1/22/13.
//
//

#import <UIKit/UIKit.h>

@interface SuperDBCell : UITableViewCell

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UITextField *textField;

@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) id value;

@property (strong, nonatomic) NSManagedObject *hero;

- (BOOL)isEditable;

@end
