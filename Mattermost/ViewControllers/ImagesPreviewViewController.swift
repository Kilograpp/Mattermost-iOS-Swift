//
//  ProfileViewController.swift
//  Mattermost
//
//  Created by TaHyKu on 04.12.16.
//  Copyright © 2016 Kilograpp. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import WebImage

private protocol Configuration: class {
    func configureWith(postLocalId: String, initalFileId: String)
}

final class ImagesPreviewViewController: UIViewController {
    
//MARK: Properties
    fileprivate var imageCollectionView: UICollectionView?// = self.setupCollectionView()
    fileprivate var flowLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    
    fileprivate var post: Post? = nil
    fileprivate var imageFiles: Results<File>?
   // public weak var delegate: ImagesPreviewViewControllerDelegate?
    
    fileprivate var initialImageIndex: Int = 0
    
//MARK: LifeCycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupCollectionView()
        
        self.view.backgroundColor = ColorBucket.whiteColor
        setupGestureRecognizers()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let offsetX = (self.imageCollectionView?.frame.width)! * CGFloat(self.initialImageIndex)
        self.imageCollectionView?.contentOffset = CGPoint(x: offsetX, y: 0)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        flowLayout.itemSize = view.bounds.size
    }
}


//MARK: Configuration
extension ImagesPreviewViewController: Configuration {
    func configureWith(postLocalId: String, initalFileId: String) {
        self.post = RealmUtils.realmForCurrentThread().object(ofType: Post.self, forPrimaryKey: postLocalId)

        self.imageFiles = self.post?.files.filter(NSPredicate(format: "isImage == true"))
        self.initialImageIndex = (self.imageFiles?.index(matching: NSPredicate(format: "identifier == %@", initalFileId)))!
    }
}


fileprivate protocol Setup: class {
    func setupCollectionView() -> UICollectionView
    func setupGestureRecognizers()
}

fileprivate protocol Action: class {
    func swipeAction(recognizer: UISwipeGestureRecognizer)
    func backAction()
    func saveAction()
}

fileprivate protocol Navigation: class {
    func returnToChatWith(direction: UISwipeGestureRecognizerDirection)
}

fileprivate protocol ImageOperation: class {
    func reload(imageIndexes:Int...)
    func scrollToImage(withIndex: Int, animated: Bool)
}


//MARK: Setup
extension ImagesPreviewViewController {
    func setupNavigationBar() {
        self.title = String(self.initialImageIndex + 1) + "/" + String(describing: (self.imageFiles?.count)!)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveAction))
    }
    
    func setupCollectionView() {
        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(ImagePreviewTableViewCell.self, forCellWithReuseIdentifier: "ImagePreviewTableViewCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = UIColor.clear
        
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
        
        let width = UIScreen.main.bounds.size.width * CGFloat((self.imageFiles?.count)!)
        collectionView.contentSize = CGSize(width: width, height: 1.0)
        
        self.imageCollectionView = collectionView
    }
    
    func setupGestureRecognizers() {
        let swipeUpGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(recognizer:)))
        swipeUpGestureRecognizer.direction = .up
        self.imageCollectionView?.addGestureRecognizer(swipeUpGestureRecognizer)
        
        let swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction(recognizer:)))
        swipeDownGestureRecognizer.direction = .down
        self.imageCollectionView?.addGestureRecognizer(swipeDownGestureRecognizer)
    }
}


//MARK: Action
extension ImagesPreviewViewController {
    func swipeAction(recognizer: UISwipeGestureRecognizer) {
        returnToChatWith(direction: recognizer.direction)
    }
    
    func backAction() {
        returnToChatWith(direction: .up)
    }
    
    func saveAction() {
        saveDisplayedImage()
    }
}


//MARK: Navigation
extension ImagesPreviewViewController: Navigation {
    func returnToChatWith(direction: UISwipeGestureRecognizerDirection) {
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionReveal
        transition.subtype = (direction == .up) ? kCATransitionFromTop : kCATransitionFromBottom
        
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        _ = self.navigationController?.popViewController(animated: false)
    }
}


//MARK: ImageOperation
extension ImagesPreviewViewController {
    func reload(imageIndexes:Int...) {
        if imageIndexes.isEmpty {
            self.imageCollectionView?.reloadData()
        } else {
            let indexPaths: [IndexPath] = imageIndexes.map({IndexPath(item: $0, section: 0)})
            self.imageCollectionView?.reloadItems(at: indexPaths)
        }
    }
    
    func scrollToImage(withIndex: Int, animated: Bool = false) {
        self.imageCollectionView?.scrollToItem(at: IndexPath(item: withIndex, section: 0), at: .centeredHorizontally, animated: animated)
    }
    
    func saveDisplayedImage() {
        let row = Int((self.imageCollectionView?.contentOffset.x)! / (self.imageCollectionView?.frame.width)!)
        let url = self.imageFiles?[row].downloadURL()
        let image = SDImageCache.shared().imageFromMemoryCache(forKey: url?.absoluteString)
        
        guard image != nil  else {
            AlertManager.sharedManager.showWarningWithMessage(message: "Wait download high-quality image, please.")
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(image!, self,
                                       #selector(image(_:didFinishSavingWithError:contextInfo:)),
                                       nil);
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        guard error == nil else {
            AlertManager.sharedManager.showErrorWithMessage(message: "Unable to save high-quality image. Check preferences.")
            return
        }
        
        AlertManager.sharedManager.showSuccesWithMessage(message: "Image was successfully saved to gallery")
    }
}


//MARK: UICollectionViewDataSource
extension ImagesPreviewViewController: UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ imageCollectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.imageFiles?.count)!
    }

    public func collectionView(_ imageCollectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageCollectionView.dequeueReusableCell(withReuseIdentifier: "ImagePreviewTableViewCell", for: indexPath) as! ImagePreviewTableViewCell
        
        let url = self.imageFiles?[indexPath.row].downloadURL()
        if let image = SDImageCache.shared().imageFromMemoryCache(forKey: url?.absoluteString) {
            cell.image = image
        } else {
            cell.showActivityIndicator()
            let thumbUrl = self.imageFiles?[indexPath.row].thumbURL()
            cell.image = SDImageCache.shared().imageFromMemoryCache(forKey: thumbUrl?.absoluteString)
            
            let imageDownloadCompletionHandler: SDWebImageCompletionWithFinishedBlock = {
                (image, error, cacheType, isFinished, imageUrl) in
                cell.hideActivityIndicator()
                guard image != nil else { return }
                
                cell.image = image
                SDImageCache.shared().store(image, forKey: url?.absoluteString)
            }
            
            SDWebImageManager.shared().downloadImage(with: url as URL!,
                                                     options: [ .handleCookies, .retryFailed ] ,
                                                     progress: nil,
                                                     completed: imageDownloadCompletionHandler)
        }
        
        return cell
    }
}


//MARK: UICollectionViewDelegate
extension ImagesPreviewViewController: UICollectionViewDelegate {
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.x / scrollView.frame.width + 1)
        self.title = String(currentPage) + "/" + String((self.imageFiles?.count)!)
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
