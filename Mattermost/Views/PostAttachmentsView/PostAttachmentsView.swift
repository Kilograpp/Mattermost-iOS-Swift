//
//  PostAttachmentsView.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 29.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

class PostAttachmentsView : UIView {
    init() {
        super.init(frame: CGRectZero)
        configureCollectionView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var collectionView : UICollectionView?
    
    
    static let attachmentsViewHeight = 80
}


private protocol Private : class {
    func configureCollectionView()
}

extension PostAttachmentsView : Private {
    private func configureCollectionView() {
//        UICollectionViewFlowLayout *layout= [[UICollectionViewFlowLayout alloc] init];
//        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
//        [self addSubview:_collectionView];
//        _collectionView.showsHorizontalScrollIndicator = NO;
//        _collectionView.backgroundColor = [UIColor whiteColor];
//        _collectionView.pagingEnabled = YES;
//        _collectionView.delegate = self;
//        _collectionView.dataSource = self;
//        [_collectionView registerClass:[KGAssignedPhotosCollectionViewCell class]
//        forCellWithReuseIdentifier:[KGAssignedPhotosCollectionViewCell reuseIdentifier]];
//        [_collectionView  mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.trailing.leading.top.bottom.equalTo(self);
//        }];
//        [_delegate willHideBrowser];
//        self.hidden = YES;
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        
        self.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        self.addSubview(self.collectionView!)
        self.collectionView?.backgroundColor = UIColor.redColor()
        self.collectionView?.translatesAutoresizingMaskIntoConstraints = false
        let left = NSLayoutConstraint(item: self.collectionView!, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: self.collectionView!, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint(item: self.collectionView!, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: self.collectionView!, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
        self.addConstraints([left, right, top, bottom])
    }
}
