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
    func didRemovePhoto(photo: AssignedPhotoViewItem)
    func attachmentsViewWillAppear()
    func attachmentViewWillDisappear()
}

class PostAttachmentsView : UIView {
    init() {
        super.init(frame: CGRectZero)
        configureCollectionView()
        setupTopBarView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var collectionView : UICollectionView?
    var delegate : PostAttachmentViewDelegate?
    var dataSource : PostAttachmentViewDataSource?
    
    var leftConstraint: NSLayoutConstraint?
    var rightConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?
    var bottomConstraint: NSLayoutConstraint?
    
    var anchorView: UIView? {
        didSet {
            setupConstraints()
        }
    }
    
    static let attachmentsViewHeight: CGFloat = 80
}


private protocol Private : class {
    func configureCollectionView()
    func setupConstraints()
    func setupTopBarView()
}

private protocol Public : class {
    func updateProgressValueAtIndex(index: Int, value: Float)
    func updateAppearance()
    func showAnimated()
    func hideAnimated()
}

extension PostAttachmentsView : Private {
    private func configureCollectionView() {
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
    
    private func setupConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.leftConstraint = NSLayoutConstraint(item: self, attribute: .Left, relatedBy: .Equal, toItem: self.anchorView, attribute: .Left, multiplier: 1, constant: 0)
        self.rightConstraint = NSLayoutConstraint(item: self, attribute: .Right, relatedBy: .Equal, toItem: self.anchorView, attribute: .Right, multiplier: 1, constant: 0)
        self.heightConstraint = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: PostAttachmentsView.attachmentsViewHeight)
        self.bottomConstraint = NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: self.anchorView, attribute: .Top, multiplier: 1, constant: PostAttachmentsView.attachmentsViewHeight)
        self.superview!.addConstraints([self.leftConstraint!, self.rightConstraint!, self.heightConstraint!, self.bottomConstraint!])
    }
    
    func setupTopBarView() {
        let topBarView = UIView()
        topBarView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(topBarView)
        topBarView.backgroundColor = ColorBucket.lightGrayColor
        
        let left = NSLayoutConstraint(item: topBarView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: topBarView, attribute: .Right, relatedBy: .Equal, toItem: self, attribute: .Right, multiplier: 1, constant: 0)
        let height = NSLayoutConstraint(item: topBarView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: 1)
        let top = NSLayoutConstraint(item: topBarView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
        self.addConstraints([left, right, height, top])
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
    
    func showAnimated() {
        self.bottomConstraint!.constant = 0
        UIView.animateWithDuration(0.3) { 
            self.superview?.layoutIfNeeded()
        }
    }
    
    func hideAnimated() {
        self.bottomConstraint!.constant = PostAttachmentsView.attachmentsViewHeight
        UIView.animateWithDuration(0.3) {
            self.superview?.layoutIfNeeded()
        }

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
        convertedCell.removeTapHandler = {(imageItem) in
            self.delegate?.didRemovePhoto(imageItem)
//            self.collectionView?.performBatchUpdates({ 
//                self.collectionView?.deleteItemsAtIndexPaths([indexPath])
//                self.collectionView?.reloadSections(NSIndexSet(index: 0))
//                }, completion: { (finished) in
//                    
//            })
        }
        
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
