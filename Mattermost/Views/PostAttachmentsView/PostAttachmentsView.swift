//
//  PostAttachmentsView.swift
//  Mattermost
//
//  Created by Igor Vedeneev on 29.08.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation

protocol PostAttachmentViewDataSource {
    func numberOfItems() -> Int
    func itemAtIndex(index: Int) -> AssignedPhotoViewItem
}

protocol PostAttachmentViewDelegate {
    func didRemovePhotoAtIndex(index: Int)
    func attachmentsViewWillAppear()
    func attachmentViewWillDisappear()
    
}

class PostAttachmentsView : UIView {
    init() {
        super.init(frame: CGRectZero)
        configureCollectionView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var collectionView : UICollectionView?
//    private var attachmentsArray : Array<AssignedPhotoViewItem>?
    var delegate : PostAttachmentViewDelegate?
    var dataSource : PostAttachmentViewDataSource?
    
    static let attachmentsViewHeight = 80
}


private protocol Private : class {
    func configureCollectionView()
}

private protocol Public : class {
    func updateProgressValueAtIndex(index: Int, value: Float)
    func updateAppearance()
}

extension PostAttachmentsView : Private {
    private func configureCollectionView() {
//        [_delegate willHideBrowser];
//        self.hidden = YES;
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        
        self.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        self.addSubview(self.collectionView!)
        //FIXME: real color
        self.collectionView?.backgroundColor = UIColor.whiteColor()
        
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        
        self.collectionView?.registerClass(PostAttachmentsViewCell.self, forCellWithReuseIdentifier: PostAttachmentsViewCell.identifier)
        
        self.collectionView?.translatesAutoresizingMaskIntoConstraints = false
        let left = NSLayoutConstraint(item: self.collectionView!, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: self.collectionView!, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint(item: self.collectionView!, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: self.collectionView!, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
        self.addConstraints([left, right, top, bottom])
    }
}

extension PostAttachmentsView : Public {
    func updateProgressValueAtIndex(index: Int, value: Float) {
        let cellAtIndex = self.collectionView?.cellForItemAtIndexPath(NSIndexPath(forItem:index, inSection: 0)) as! PostAttachmentsViewCell
        cellAtIndex.updateProgressViewWithValue(value)
    }
    
    func updateAppearance() {
        self.collectionView?.reloadData()
    }
}

extension PostAttachmentsView : UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.dataSource == nil {
            return 0
        }
        
        return (self.dataSource?.numberOfItems())!
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(PostAttachmentsViewCell.identifier, forIndexPath: indexPath)
        let convertedCell = cell as! PostAttachmentsViewCell
        convertedCell.configureWithItem((self.dataSource?.itemAtIndex(indexPath.row))!)
        
        return convertedCell
    }
}

extension PostAttachmentsView : UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 5, 5, 5)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return PostAttachmentsViewCell.itemSize
    }
}
