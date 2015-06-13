//
//  NewsListCell.m
//  iSearch
//
//  Created by kaala on 15/6/13.
//  Copyright (c) 2015年 Intfocus. All rights reserved.
//

#import "NewsListCell.h"

@implementation NewsListCell

- (void)awakeFromNib {
    // Initialization code
    self.backgroundColor=[UIColor clearColor];
    self.textLabel.numberOfLines=0;
    self.detailTextLabel.numberOfLines=0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)prepareForReuse{
    [super prepareForReuse];
    
}

-(CGSize)sizeForCell:(NSString*)text withWidth:(NSInteger)width{
    self.textLabel.text=text;
    self.textLabel.frame=CGRectMake(0, 0, width, 50000);
    [self.textLabel sizeToFit];
    CGRect r=self.textLabel.frame;
    return r.size;
}

@end
