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
    func item(atIndex index: Int) -> AssignedAttachmentViewItem
}

protocol PostAttachmentViewDelegate {
    func didRemove(item: AssignedAttachmentViewItem)
    func attachmentsViewWillAppear()
    func attachmentViewWillDisappear()
}

class PostAttachmentsView : UIView {
    init() {
        super.init(frame: CGRect.zero)
        configureCollectionView()
        setupTopBarView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate var collectionView : UICollectionView?
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
    
    var isShown = false
    
    static let attachmentsViewHeight: CGFloat = 80
}


private protocol Private : class {
    func configureCollectionView()
    func setupConstraints()
    func setupTopBarView()
}

private protocol Public : class {
    func updateProgressValueAtIndex(_ index: Int, value: Float)
    func updateAppearance()
    func showAnimated()
    func hideAnimated()
    func removeActivityAt(index: Int)
}

extension PostAttachmentsView : Private {
    fileprivate func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        self.collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        self.addSubview(self.collectionView!)
        self.collectionView?.backgroundColor = ColorBucket.whiteColor
        
        self.collectionView?.delegate = self
        self.collectionView?.dataSource = self
        
        self.collectionView?.register(PostAttachmentsViewCell.self, forCellWithReuseIdentifier: PostAttachmentsViewCell.identifier)
        self.collectionView?.register(PostFileViewCell.self, forCellWithReuseIdentifier: PostFileViewCell.identifier)
        
        self.collectionView?.translatesAutoresizingMaskIntoConstraints = false
        let left = NSLayoutConstraint(item: self.collectionView!, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: self.collectionView!, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint(item: self.collectionView!, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: self.collectionView!, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        self.addConstraints([left, right, top, bottom])
    }
    
    fileprivate func setupConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.leftConstraint = NSLayoutConstraint(item: self, attribute: .left, relatedBy: .equal, toItem: self.anchorView, attribute: .left, multiplier: 1, constant: 0)
        self.rightConstraint = NSLayoutConstraint(item: self, attribute: .right, relatedBy: .equal, toItem: self.anchorView, attribute: .right, multiplier: 1, constant: 0)
        self.heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: PostAttachmentsView.attachmentsViewHeight)
        self.bottomConstraint = NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: self.anchorView, attribute: .top, multiplier: 1, constant: PostAttachmentsView.attachmentsViewHeight)
        self.superview!.addConstraints([self.leftConstraint!, self.rightConstraint!, self.heightConstraint!, self.bottomConstraint!])
    }
    
    func setupTopBarView() {
        let topBarView = UIView()
        topBarView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(topBarView)
        topBarView.backgroundColor = ColorBucket.lightGrayColor
        
        let left = NSLayoutConstraint(item: topBarView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1, constant: 0)
        let right = NSLayoutConstraint(item: topBarView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1, constant: 0)
        let height = NSLayoutConstraint(item: topBarView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 1)
        let top = NSLayoutConstraint(item: topBarView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
        self.addConstraints([left, right, height, top])
    }
}

extension PostAttachmentsView : Public {
    func updateProgressValueAtIndex(_ index: Int, value: Float) {
        guard let cellAtIndex = self.collectionView?.cellForItem(at: IndexPath(item:index, section: 0)) else { return }
        (cellAtIndex  as! PostAttachmentsViewCell).updateProgressViewWithValue(value)
    }
    
    func updateAppearance() {
        self.collectionView?.reloadData()
    }
    
    func showAnimated() {
        guard self.isShown == true else {
            self.delegate?.attachmentsViewWillAppear()
            self.isShown = true
            self.bottomConstraint!.constant = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.superview?.layoutIfNeeded()
            }) 
            
            return
        }
    }
    
    func hideAnimated() {
        self.delegate?.attachmentViewWillDisappear()
        self.isShown = false
        self.bottomConstraint!.constant = PostAttachmentsView.attachmentsViewHeight
        UIView.animate(withDuration: 0.3, animations: {
            self.superview?.layoutIfNeeded()
        }) 
    }
    
    func removeActivityAt(index: Int) {
        guard let cellAtIndex = self.collectionView?.cellForItem(at: IndexPath(item:index, section: 0)) else { return }
        (cellAtIndex  as! PostAttachmentsViewCell).viewWithTag(77)?.removeFromSuperview()
    }
}

extension PostAttachmentsView : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.dataSource == nil {
            return 0
        }
        
        return (self.dataSource?.numberOfItems())!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //FIXME: builder!
        let item = self.dataSource?.item(atIndex: indexPath.row)
        var reuseIdentifier = PostAttachmentsViewCell.identifier
        
        if item!.isFile {
            reuseIdentifier = PostFileViewCell.identifier
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        var convertedCell = cell as! PostAttachmentsViewCell
        if item!.isFile {
            convertedCell = cell as! PostFileViewCell
        }
        
        convertedCell.configureWithItem((self.dataSource?.item(atIndex: indexPath.row))!)
        convertedCell.removeTapHandler = {(imageItem) in
            self.delegate?.didRemove(item: imageItem)
            self.collectionView?.performBatchUpdates({ 
                self.collectionView?.deleteItems(at: [indexPath])
                self.collectionView?.reloadSections(IndexSet(integer: 0))
                }, completion: { (finished) in
                    
            })
        }
        
        return convertedCell
    }
}

extension PostAttachmentsView : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(5, 5, 5, 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return PostAttachmentsViewCell.itemSize
    }
}
