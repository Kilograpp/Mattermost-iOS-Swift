//
//  ProfileViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 04.12.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import UIKit



@objc protocol ImagesPreviewViewControllerDelegate {
    func galleryDidTapToClose(gallery: ImagesPreviewViewController)
}

private protocol Configuration: class {
    func configureWith(post: Post)
}


final class ImagesPreviewViewController: UIViewController {
    
//MARK: Properties
    fileprivate let titleLabel = UILabel()
    public lazy var imageCollectionView: UICollectionView = self.setupCollectionView()
    fileprivate var flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    fileprivate var post: Post? = nil
    public weak var delegate: ImagesPreviewViewControllerDelegate?
    
//MARK: LifeCycle
    public init(delegate: ImagesPreviewViewControllerDelegate) {
        super.init(nibName: nil, bundle: nil)

        self.delegate = delegate
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        flowLayout.itemSize = view.bounds.size
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupToolbar()
        
        self.view.backgroundColor = ColorBucket.whiteColor
        setupGestureRecognizer()
    }
}

//MARK: Configuration
extension ImagesPreviewViewController: Configuration {
    func configureWith(post: Post) {
        self.post = post
    }
}


fileprivate protocol Setup: class {
    func setupCollectionView() -> UICollectionView
    func setupGestureRecognizer()
}

fileprivate protocol Action: class {
    func singleTapAction(recognizer: UITapGestureRecognizer)
}

fileprivate protocol ImageOperation: class {
    func reload(imageIndexes:Int...)
    func scrollToImage(withIndex: Int, animated: Bool)
}


//MARK: Setup
extension ImagesPreviewViewController {
    func setupToolbar() {
        let width = UIScreen.main.bounds.width
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: width, height: 64))
        
        var barItems = Array<UIBarButtonItem>()
        
        barItems.append(UIBarButtonItem(image: UIImage(named: "navbar_back_icon"), style: .done,
                                              target: self, action: #selector(backAction)))
        barItems.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        
        self.titleLabel.frame = CGRect(x: 0, y: 0, width: 40, height: 30)
        self.titleLabel.backgroundColor = UIColor.clear
        self.titleLabel.textColor = ColorBucket.blackColor
        self.titleLabel.font = FontBucket.normalTitleFont
        self.titleLabel.text = "1/2"
        self.titleLabel.textAlignment = .center
        
        let titleBar = UIBarButtonItem(customView: self.titleLabel)
        barItems.append(titleBar)
        
        barItems.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil))
        toolbar.items = barItems
        
        self.view.addSubview(toolbar)
    }
    
    func setupCollectionView() -> UICollectionView {
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        // Set up collection view
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ImagePreviewTableViewCell.self, forCellWithReuseIdentifier: "ImagePreviewTableViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = UIColor.clear
        
        // Set up collection view constraints
        let leadingLayoutConstraint = NSLayoutConstraint(item: collectionView, attribute: .leading, relatedBy: .equal,
                                                         toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
        let topLayoutConstraint = NSLayoutConstraint(item: collectionView, attribute: .top, relatedBy: .equal,
                                                     toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
        let trailingLayoutConstraint = NSLayoutConstraint(item: collectionView, attribute: .trailing, relatedBy: .equal,
                                                          toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
        let bottomLayoutConstraint = NSLayoutConstraint(item: collectionView, attribute: .bottom, relatedBy: .equal,
                                                      toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
        
        let imageCollectionViewConstraints = [ leadingLayoutConstraint, topLayoutConstraint, trailingLayoutConstraint, bottomLayoutConstraint ]

        view.addSubview(collectionView)
        view.addConstraints(imageCollectionViewConstraints)
        
        collectionView.contentSize = CGSize(width: 1000.0, height: 1.0)
        
        return collectionView
    }
    
    func setupGestureRecognizer() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapAction(recognizer:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.delegate = self
        imageCollectionView.addGestureRecognizer(singleTap)
    }
}


//MARK: Action
extension ImagesPreviewViewController {
    func singleTapAction(recognizer: UITapGestureRecognizer) {
        delegate?.galleryDidTapToClose(gallery: self)
    }
    
    func backAction() {
        delegate?.galleryDidTapToClose(gallery: self)
    }
}


//MARK: ImageOperation
extension ImagesPreviewViewController {
    func reload(imageIndexes:Int...) {
        if imageIndexes.isEmpty {
            imageCollectionView.reloadData()
        } else {
            let indexPaths: [IndexPath] = imageIndexes.map({IndexPath(item: $0, section: 0)})
            imageCollectionView.reloadItems(at: indexPaths)
        }
    }
    
    func scrollToImage(withIndex: Int, animated: Bool = false) {
        imageCollectionView.scrollToItem(at: IndexPath(item: withIndex, section: 0), at: .centeredHorizontally, animated: animated)
    }
}


//MARK: UICollectionViewDataSource
extension ImagesPreviewViewController: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ imageCollectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }

    public func collectionView(_ imageCollectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: "ImagePreviewTableViewCell", for: indexPath) as! ImagePreviewTableViewCell
        let name: String = "judo_" + String(indexPath.row + 1) + ".jpg"
        cell.image = UIImage(named: name)
        return cell
    }
}


//MARK: UICollectionViewDelegate
extension ImagesPreviewViewController: UICollectionViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // If the scroll animation ended, update the page control to reflect the current page we are on
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? ImagePreviewTableViewCell {
            cell.configureForNewImage()
        }
    }
}


//MARK: UIGestureRecognizerDelegate
extension ImagesPreviewViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer is UITapGestureRecognizer &&
            gestureRecognizer is UITapGestureRecognizer &&
            otherGestureRecognizer.view is ImagePreviewTableViewCell &&
            gestureRecognizer.view == imageCollectionView
    }
}

